-- =========================================
-- Database schema for myKafkaXSD.xsd
-- =========================================

-- 1. Root / Header Table
IF OBJECT_ID('CrtMessages', 'U') IS NOT NULL DROP TABLE CrtMessages;
CREATE TABLE CrtMessages (
    MessageId INT IDENTITY(1,1) PRIMARY KEY,
    Action NVARCHAR(100),
    ApplicationSource NVARCHAR(100),
    CRTVersionNumber NVARCHAR(50),
    ModeType NVARCHAR(50),
    RootType NVARCHAR(50),
    Timestamp NVARCHAR(100),
    ReceivedAt DATETIME DEFAULT GETDATE(),
    RawPayload XML
);
GO

-- 2. CPY Records (1-to-1 relationships flattened into the table)
IF OBJECT_ID('CpyRecords', 'U') IS NOT NULL DROP TABLE CpyRecords;
CREATE TABLE CpyRecords (
    CpyRecordId INT IDENTITY(1,1) PRIMARY KEY,
    MessageId INT FOREIGN KEY REFERENCES CrtMessages(MessageId) ON DELETE CASCADE,
    CpyId NVARCHAR(255),
    
    -- CPYIdentification - Legal
    ClassOfLegalEntity NVARCHAR(255),
    INSEELegalName NVARCHAR(MAX),
    LongName NVARCHAR(MAX),
    NormalizedLegalName NVARCHAR(MAX),
    ShortName NVARCHAR(255),
    
    -- CPYIdentification - Person
    BirthDate NVARCHAR(50),
    BirthPlace NVARCHAR(255),
    FirstName NVARCHAR(255),
    LastName NVARCHAR(255),
    MaritalStatus NVARCHAR(50),
    Sex NVARCHAR(50),
    
    -- CPYRoles
    CalyonPrimaryCoverageUnit NVARCHAR(255),
    ESFWorldwidePilotEntity NVARCHAR(255),
    ForcedCalyonPrimaryCoverageUnit NVARCHAR(255),
    FraneRunEntity NVARCHAR(255),
    FraneRunManager NVARCHAR(255),
    PilotDivision NVARCHAR(255),
    RMCCalyon NVARCHAR(255),
    ReportingEntity NVARCHAR(255),
    UEWorldwidePilotEntity NVARCHAR(255),
    
    -- CPYCharacteristics
    BAFIAccountingCode NVARCHAR(255),
    BaselPortfolio NVARCHAR(255),
    CalyonRelationType NVARCHAR(255),
    CalyonRelationTypeReviewDate DATE,
    Category NVARCHAR(255),
    CategoryValidationDate NVARCHAR(100),
    CategoryValidationStatus NVARCHAR(100),
    ControlCountry NVARCHAR(100),
    ControlCountryValidationDate NVARCHAR(100),
    ControlCountryValidationStatus NVARCHAR(100),
    KiwisRelationType NVARCHAR(255),
    KiwisRelationTypeReviewDate DATE,
    NAFActivityCode NVARCHAR(255),
    NAFActivityCodeRev2 NVARCHAR(255),
    NationalityCountry NVARCHAR(100),
    NationalityCountryValidationDate NVARCHAR(100),
    NationalityCountryValidationStatus NVARCHAR(100),
    PrincipalBusinessArea NVARCHAR(255),
    PrincipalBusinessAreaValidationDate NVARCHAR(100),
    PrincipalBusinessAreaValidationStatus NVARCHAR(100),
    PublicPrivateCode NVARCHAR(100),
    ResidenceCountry NVARCHAR(100),
    ResidenceCountryValidationDate NVARCHAR(100),
    ResidenceCountryValidationStatus NVARCHAR(100),
    RiskCountry NVARCHAR(100),
    NAFActivityCodeRev2INSEE NVARCHAR(255),
    NationalityCountryFS NVARCHAR(100),
    NationalityCountryFSValidationStatus NVARCHAR(100),
    NationalityCountryFSValidationDate NVARCHAR(100),
    ResidenceCountryFS NVARCHAR(100),
    ResidenceCountryFSValidationStatus NVARCHAR(100),
    ResidenceCountryFSValidationDate NVARCHAR(100),
    CategoryFS NVARCHAR(255),
    CategoryFSValidationStatus NVARCHAR(100),
    CategoryFSValidationDate NVARCHAR(100),
    PrincipalBusinessAreaFS NVARCHAR(255),
    PrincipalBusinessAreaFSValidationStatus NVARCHAR(100),
    PrincipalBusinessAreaFSValidationDate NVARCHAR(100),
    ControlCountryFS NVARCHAR(100),
    ControlCountryFSValidationStatus NVARCHAR(100),
    ControlCountryFSValidationDate NVARCHAR(100),
    
    -- Adress
    AddressCity NVARCHAR(255),
    AddressLine1 NVARCHAR(MAX),
    AddressLine2 NVARCHAR(MAX),
    AddressState NVARCHAR(100),
    AddressZipCode NVARCHAR(50),
    
    -- CPYInternalRatings
    InternalRatingDate DATE,
    FinalInternalRating NVARCHAR(100),
    Methodology NVARCHAR(255),
    Reason NVARCHAR(MAX),
    
    -- CPYLifeCycle
    LifeCycleCreationDate DATE,
    InCreationFlag NVARCHAR(10),
    KiwisRelationShipCode NVARCHAR(100),
    KiwisRelationShipCodeReviewDate DATE,
    LifeCycleModificationDate DATE,
    LifeCycleModifiedBy NVARCHAR(100),
    RelationShipCode NVARCHAR(100),
    RelationShipCodeReviewDate DATE,
    LifeCycleUpdateDate DATE,
    
    -- CPYLinks
    GroupLinkDate DATE,
    ParentCPHid NVARCHAR(255),
    ParentCPHlongName NVARCHAR(MAX),
    ParentId NVARCHAR(255),
    ProposedParentCPH NVARCHAR(255),
    SubsidiaryParent NVARCHAR(255),
    CPMBranchFlag NVARCHAR(10),
    
    -- CPYTradeData
    DealingRestriction NVARCHAR(255),
    DealingRestrictionReviewDate DATE,
    Depository NVARCHAR(255),
    FiduciaryRole NVARCHAR(255),
    FiduciaryRoleType NVARCHAR(255),
    FundOriginator NVARCHAR(255),
    PrincipalSponsor NVARCHAR(255),
    RegroupingCPY NVARCHAR(255),
    SponsorType NVARCHAR(255),
    DNDRequestor NVARCHAR(255),
    
    -- CPYCasaData
    CAConsoId NVARCHAR(255),
    EconomicAgentCode NVARCHAR(255),
    GroupCreditAgricoleFlag NVARCHAR(10),
    
    -- DFAClassification
    DFACommo NVARCHAR(100),
    DFACredits NVARCHAR(100),
    DFAEntity NVARCHAR(255),
    DFAEquity NVARCHAR(100),
    DFAFX NVARCHAR(100),
    DFARates NVARCHAR(100),
    DFAClientClassification15a6 NVARCHAR(100),
    
    -- EMIRClassification
    Emirclassification NVARCHAR(255),
    
    -- MifidData
    MifidClientClassificationFlag NVARCHAR(10),
    MifidInitialNotificationDate DATE,
    MifidInitialNotificationStatus NVARCHAR(100),
    MifidInternalSuitabilityRating NVARCHAR(100),
    MifidLawClassificationFlag NVARCHAR(10),
    MifidVanilleProductExperience NVARCHAR(100),
    
    -- KYCData
    KYCRating NVARCHAR(100),
    KYCStatus NVARCHAR(100),
    KYCValidationDate DATE,
    WorldwideKYCId NVARCHAR(255),
    
    -- Nydata
    NYlocalKactusStatus NVARCHAR(100),
    NYlocalRelationShipCode NVARCHAR(100),
    NYOFAC NVARCHAR(100),
    NYPatriotAct NVARCHAR(100),
    NYPatriotActCertificationDate NVARCHAR(100),
    NYUsCompliant NVARCHAR(100),
    
    -- ISOAddress
    ISOAddressDepartment NVARCHAR(255),
    ISOAddressSubDepartment NVARCHAR(255),
    ISOAddressBuildingName NVARCHAR(255),
    ISOAddressFloor NVARCHAR(50),
    ISOAddressRoom NVARCHAR(50),
    ISOAddressStreetName NVARCHAR(255),
    ISOAddressStreetNumber NVARCHAR(50),
    ISOAddressPostBox NVARCHAR(100),
    ISOAddressRepetitionIndex NVARCHAR(50),
    ISOAddressTrackType NVARCHAR(100),
    ISOAddressCity NVARCHAR(255),
    ISOAddressZipCode NVARCHAR(50),
    ISOAddressTownLocName NVARCHAR(255),
    ISOAddressDistrictName NVARCHAR(255),
    ISOAddressState NVARCHAR(255)
);
GO

-- 3. CPYLocalIdentification (1-to-many)
IF OBJECT_ID('CpyLocalIdentifications', 'U') IS NOT NULL DROP TABLE CpyLocalIdentifications;
CREATE TABLE CpyLocalIdentifications (
    CpyLocalIdentificationId INT IDENTITY(1,1) PRIMARY KEY,
    CpyRecordId INT FOREIGN KEY REFERENCES CpyRecords(CpyRecordId) ON DELETE CASCADE,
    AliasId NVARCHAR(255),
    AliasType NVARCHAR(100),
    KYCValidationStatus NVARCHAR(100),
    LocalRelationShipCode NVARCHAR(100),
    LocalRelationType NVARCHAR(100),
    RR NVARCHAR(100)
);
GO

-- 4. ExternalId for CPY (1-to-many)
IF OBJECT_ID('CpyExternalIds', 'U') IS NOT NULL DROP TABLE CpyExternalIds;
CREATE TABLE CpyExternalIds (
    CpyExternalId_PK INT IDENTITY(1,1) PRIMARY KEY,
    CpyRecordId INT FOREIGN KEY REFERENCES CpyRecords(CpyRecordId) ON DELETE CASCADE,
    ExternalAliasId NVARCHAR(255),
    ExternalAliasType NVARCHAR(100)
);
GO

-- 5. AdditionalField (1-to-many)
IF OBJECT_ID('CpyAdditionalFields', 'U') IS NOT NULL DROP TABLE CpyAdditionalFields;
CREATE TABLE CpyAdditionalFields (
    AdditionalFieldId INT IDENTITY(1,1) PRIMARY KEY,
    CpyRecordId INT FOREIGN KEY REFERENCES CpyRecords(CpyRecordId) ON DELETE CASCADE,
    FieldType NVARCHAR(100) NOT NULL,
    FieldCode NVARCHAR(100) NOT NULL,
    FieldValue NVARCHAR(MAX)
);
GO

-- 6. Composition (1-to-many inside AdditionalField)
IF OBJECT_ID('CpyAdditionalFieldCompositions', 'U') IS NOT NULL DROP TABLE CpyAdditionalFieldCompositions;
CREATE TABLE CpyAdditionalFieldCompositions (
    CompositionId INT IDENTITY(1,1) PRIMARY KEY,
    AdditionalFieldId INT FOREIGN KEY REFERENCES CpyAdditionalFields(AdditionalFieldId) ON DELETE CASCADE
);
GO

-- 7. Field (1-to-many inside Composition)
IF OBJECT_ID('CpyAdditionalFieldCompositionFields', 'U') IS NOT NULL DROP TABLE CpyAdditionalFieldCompositionFields;
CREATE TABLE CpyAdditionalFieldCompositionFields (
    CompositionFieldId INT IDENTITY(1,1) PRIMARY KEY,
    CompositionId INT FOREIGN KEY REFERENCES CpyAdditionalFieldCompositions(CompositionId) ON DELETE CASCADE,
    FieldType NVARCHAR(100) NOT NULL,
    FieldCode NVARCHAR(100) NOT NULL,
    FieldValue NVARCHAR(MAX)
);
GO

-- 8. SC (Childs of CPY)
IF OBJECT_ID('ScRecords', 'U') IS NOT NULL DROP TABLE ScRecords;
CREATE TABLE ScRecords (
    ScRecordId INT IDENTITY(1,1) PRIMARY KEY,
    CpyRecordId INT FOREIGN KEY REFERENCES CpyRecords(CpyRecordId) ON DELETE CASCADE,
    ScId NVARCHAR(255) NOT NULL,
    
    -- SCIdentification
    CalyonGroupSCFlag NVARCHAR(10),
    Country NVARCHAR(100),
    LongName NVARCHAR(MAX),
    ProfitCenter NVARCHAR(255),
    SCType NVARCHAR(100),
    SCinternalType NVARCHAR(100),
    ShortName NVARCHAR(255),
    
    -- SCRoles
    ReportingEntity NVARCHAR(255),
    ResponsibilityCenter NVARCHAR(255),
    
    -- Adress
    AddressCity NVARCHAR(255),
    AddressLine1 NVARCHAR(MAX),
    AddressLine2 NVARCHAR(MAX),
    AddressState NVARCHAR(100),
    AddressZipCode NVARCHAR(50),
    
    -- SCLifeCycle
    CentralStatusCode NVARCHAR(100),
    CreationDate DATE,
    ModificationDate DATE,
    ModifiedBy NVARCHAR(100),
    UpdateDate DATE,
    
    -- ISOAddress
    ISOAddressDepartment NVARCHAR(255),
    ISOAddressSubDepartment NVARCHAR(255),
    ISOAddressBuildingName NVARCHAR(255),
    ISOAddressFloor NVARCHAR(50),
    ISOAddressRoom NVARCHAR(50),
    ISOAddressStreetName NVARCHAR(255),
    ISOAddressStreetNumber NVARCHAR(50),
    ISOAddressPostBox NVARCHAR(100),
    ISOAddressRepetitionIndex NVARCHAR(50),
    ISOAddressTrackType NVARCHAR(100),
    ISOAddressCity NVARCHAR(255),
    ISOAddressZipCode NVARCHAR(50),
    ISOAddressTownLocName NVARCHAR(255),
    ISOAddressDistrictName NVARCHAR(255),
    ISOAddressState NVARCHAR(255)
);
GO

-- 9. SCLocalIdentification (1-to-many)
IF OBJECT_ID('ScLocalIdentifications', 'U') IS NOT NULL DROP TABLE ScLocalIdentifications;
CREATE TABLE ScLocalIdentifications (
    ScLocalIdentificationId INT IDENTITY(1,1) PRIMARY KEY,
    ScRecordId INT FOREIGN KEY REFERENCES ScRecords(ScRecordId) ON DELETE CASCADE,
    AliasId NVARCHAR(255),
    AliasType NVARCHAR(100),
    LocalParentId NVARCHAR(255),
    LocalStatusCode NVARCHAR(100),
    OperationsManager NVARCHAR(255)
);
GO

-- 10. ExternalId for SC (1-to-many)
IF OBJECT_ID('ScExternalIds', 'U') IS NOT NULL DROP TABLE ScExternalIds;
CREATE TABLE ScExternalIds (
    ScExternalId_PK INT IDENTITY(1,1) PRIMARY KEY,
    ScRecordId INT FOREIGN KEY REFERENCES ScRecords(ScRecordId) ON DELETE CASCADE,
    ExternalAliasId NVARCHAR(255),
    ExternalAliasType NVARCHAR(100)
);
GO
