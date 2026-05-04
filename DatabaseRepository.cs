using Dapper;
using System.Data;
using Microsoft.Data.SqlClient;
using KafkaXmlConsumer.Models;
using System.Threading.Tasks;
using System.Linq;
using System;

namespace KafkaXmlConsumer
{
    public class DatabaseRepository
    {
        private readonly string _connectionString;

        public DatabaseRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task EnsureDatabaseAndTablesCreatedAsync()
        {
            var builder = new SqlConnectionStringBuilder(_connectionString);
            var dbName = builder.InitialCatalog;
            builder.InitialCatalog = "master";
            
            using var masterConnection = new SqlConnection(builder.ConnectionString);
            await masterConnection.OpenAsync();
            var checkDbQuery = $"SELECT db_id('{dbName}')";
            var result = await masterConnection.ExecuteScalarAsync(checkDbQuery);
            if (result == null)
            {
                await masterConnection.ExecuteAsync($"CREATE DATABASE [{dbName}]");
            }

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            
            var createTablesQuery = @"
            IF OBJECT_ID('CrtMessages', 'U') IS NULL
            CREATE TABLE CrtMessages (
                MessageId INT IDENTITY(1,1) PRIMARY KEY,
                ActionType NVARCHAR(100),
                ApplicationSource NVARCHAR(100),
                CRTVersionNumber NVARCHAR(50),
                ModeType NVARCHAR(50),
                Timestamp NVARCHAR(100),
                ReceivedAt DATETIME DEFAULT GETDATE(),
                RawPayload XML
            );

            IF OBJECT_ID('CpyRecords', 'U') IS NULL
            CREATE TABLE CpyRecords (
                CpyRecordId INT IDENTITY(1,1) PRIMARY KEY,
                MessageId INT FOREIGN KEY REFERENCES CrtMessages(MessageId),
                CpyId NVARCHAR(255),
                LegalName NVARCHAR(MAX),
                FirstName NVARCHAR(255),
                LastName NVARCHAR(255),
                Category NVARCHAR(255),
                NationalityCountry NVARCHAR(100),
                ResidenceCountry NVARCHAR(100),
                City NVARCHAR(100)
            );
            ";
            await connection.ExecuteAsync(createTablesQuery);
        }

        public async Task InsertMessageAsync(Crt crt, string rawXml)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            using var transaction = connection.BeginTransaction();
            
            try
            {
                var insertMsgQuery = @"
                    INSERT INTO CrtMessages (ActionType, ApplicationSource, CRTVersionNumber, ModeType, Timestamp, RawPayload)
                    OUTPUT INSERTED.MessageId
                    VALUES (@ActionType, @AppSource, @Version, @ModeType, @Timestamp, @RawPayload);";

                var messageId = await connection.ExecuteScalarAsync<int>(insertMsgQuery, new {
                    ActionType = crt.Header?.Action,
                    AppSource = crt.Header?.ApplicationSource,
                    Version = crt.Header?.CrtVersionNumber,
                    ModeType = crt.Header?.ModeType,
                    Timestamp = crt.Header?.Timestamp,
                    RawPayload = rawXml
                }, transaction);

                if (crt.Body != null) 
                {
                    var insertCpyQuery = @"
                        INSERT INTO CpyRecords (MessageId, CpyId, LegalName, FirstName, LastName, Category, NationalityCountry, ResidenceCountry, City)
                        VALUES (@MessageId, @CpyId, @LegalName, @FirstName, @LastName, @Category, @NationalityCountry, @ResidenceCountry, @City);";
                    
                    foreach(var cpy in crt.Body)
                    {
                        await connection.ExecuteAsync(insertCpyQuery, new {
                            MessageId = messageId,
                            CpyId = cpy.Id,
                            LegalName = cpy.CpyIdentification?.Legal?.NormalizedLegalName ?? cpy.CpyIdentification?.Legal?.LongName,
                            FirstName = cpy.CpyIdentification?.Person?.FirstName,
                            LastName = cpy.CpyIdentification?.Person?.LastName,
                            Category = cpy.CpyCharacteristics?.Category,
                            NationalityCountry = cpy.CpyCharacteristics?.NationalityCountry,
                            ResidenceCountry = cpy.CpyCharacteristics?.ResidenceCountry,
                            City = cpy.Adress?.City
                        }, transaction);
                    }
                }

                transaction.Commit();
            }
            catch(Exception)
            {
                transaction.Rollback();
                throw;
            }
        }
    }
}
