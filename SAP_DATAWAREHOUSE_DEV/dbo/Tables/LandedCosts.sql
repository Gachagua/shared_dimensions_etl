CREATE TABLE [dbo].[LandedCosts] (
    [DocumentEntry]            INT             NULL,
    [ObjectType]               NVARCHAR (20)   NULL,
    [AgentName]                NVARCHAR (100)  NULL,
    [Description]              NVARCHAR (250)  NULL,
    [DocumentDate]             DATETIME        NULL,
    [DocumentNumber]           INT             NULL,
    [UserSignature]            SMALLINT        NULL,
    [CreateDate]               DATETIME        NULL,
    [DocumetTotal]             NUMERIC (19, 6) NULL,
    [BusinessPartnerName]      NVARCHAR (100)  NULL,
    [BaseDOcumentInternalID]   INT             NULL,
    [BaseDocumentType]         INT             NULL,
    [LoadType]                 VARCHAR (1)     NULL,
    [TotalCosts]               NUMERIC (19, 6) NULL,
    [CostCode]                 NVARCHAR (2)    NULL,
    [CountryCode]              NVARCHAR (3)    NULL,
    [TtlCostLC]                NUMERIC (19, 6) NULL,
    [OriginalBaseDocumentType] NVARCHAR (11)   NULL,
    [OriBAbsEnt]               INT             NULL,
    [BaseLineNumber]           INT             NULL
);

