using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using System;
using System.Threading;
using System.Threading.Tasks;
using Confluent.Kafka;

namespace KafkaXmlConsumer
{
    public class Worker : BackgroundService
    {
        private readonly ILogger<Worker> _logger;
        private readonly IConfiguration _configuration;
        private readonly DatabaseRepository _repository;
        private readonly XmlProcessor _xmlProcessor;

        public Worker(ILogger<Worker> logger, IConfiguration configuration)
        {
            _logger = logger;
            _configuration = configuration;
            
            var connStr = _configuration.GetConnectionString("DefaultConnection");
            _repository = new DatabaseRepository(connStr);
            var xsdFilePath = _configuration.GetValue<string>("ValidationSettings:XsdFilePath") ?? "myKafkaXSD.xml";
            _xmlProcessor = new XmlProcessor(xsdFilePath);
        }

        public override async Task StartAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("Ensuring DB and tables exist...");
            try {
                await _repository.EnsureDatabaseAndTablesCreatedAsync();
            } catch (Exception ex) {
                _logger.LogError(ex, "Error creating database structure. Please ensure SQL Server is running.");
            }
            await base.StartAsync(cancellationToken);
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var bootstrapServers = _configuration.GetValue<string>("KafkaSettings:BootstrapServers");
            var topic = _configuration.GetValue<string>("KafkaSettings:Topic");
            var groupId = _configuration.GetValue<string>("KafkaSettings:GroupId");

            var config = new ConsumerConfig
            {
                BootstrapServers = bootstrapServers,
                GroupId = groupId,
                AutoOffsetReset = AutoOffsetReset.Earliest
            };

            using var consumer = new ConsumerBuilder<Ignore, string>(config).Build();
            consumer.Subscribe(topic);

            _logger.LogInformation($"Subscribed to Kafka topic {topic} at {bootstrapServers}");

            try
            {
                while (!stoppingToken.IsCancellationRequested)
                {
                    try
                    {
                        var consumeResult = consumer.Consume(stoppingToken);

                        if (consumeResult != null)
                        {
                            var rawXml = consumeResult.Message.Value;
                            _logger.LogInformation($"Received message at offset {consumeResult.Offset}");
                            
                            try {
                                var crtMessage = _xmlProcessor.Parse(rawXml);
                                _logger.LogInformation($"Successfully parsed XML. Action: {crtMessage?.Header?.Action}, Contains {crtMessage?.Body?.Count ?? 0} CPY records.");
                                
                                await _repository.InsertMessageAsync(crtMessage, rawXml);
                                _logger.LogInformation($"Successfully inserted message into MSSQL.");
                            }
                            catch (System.Xml.Schema.XmlSchemaValidationException validationEx) {
                                _logger.LogWarning(validationEx, $"Schema validation failed for message at offset {consumeResult.Offset}. Skipping message.");
                            }
                            catch (Exception ex) {
                                _logger.LogError(ex, "Error processing or inserting XML message.");
                            }
                        }
                    }
                    catch (ConsumeException e)
                    {
                        _logger.LogError(e, $"Consume error: {e.Error.Reason}");
                    }
                }
            }
            catch (OperationCanceledException)
            {
                consumer.Close();
            }
        }
    }
}
