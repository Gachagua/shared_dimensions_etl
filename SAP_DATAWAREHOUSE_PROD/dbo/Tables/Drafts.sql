CREATE TABLE [dbo].[Drafts] (
    [DocumentEntry]          INT             NULL,
    [DocumentNumber]         INT             NULL,
    [UserSignature]          SMALLINT        NULL,
    [ProductionTime]         SMALLINT        NULL,
    [DocumentDate]           DATETIME        NULL,
    [BusinessPartnerName]    NVARCHAR (100)  NULL,
    [CreateDate]             DATETIME        NULL,
    [DocumentStatus]         VARCHAR (1)     NULL,
    [DocumentTotal]          NUMERIC (19, 6) NULL,
    [ObjectType]             NVARCHAR (20)   NULL,
    [AuthorizationStatus]    VARCHAR (1)     NULL,
    [CountryCode]            NVARCHAR (3)    NULL,
    [BusinessPartnerCode]    NVARCHAR (15)   NULL,
    [CreateTime]             INT             NULL,
    [UpdateTime]             INT             NULL,
    [UserSignature2]         SMALLINT        NULL,
    [DocumentSubmissionDate] DATETIME        NULL,
    [UpdateDate]             DATETIME        NULL
);

