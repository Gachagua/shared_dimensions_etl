CREATE TABLE [dbo].[DocumentHistory] (
    [ObjectType]              NVARCHAR (20) NULL,
    [DocumentDraftInternalID] INT           NULL,
    [DocumentEntry]           INT           NULL,
    [DocumentNumber]          INT           NULL,
    [DocumentDate]            DATETIME      NULL,
    [UserSignature]           SMALLINT      NULL,
    [UserSignature2]          SMALLINT      NULL,
    [UpdateDate]              DATETIME      NULL,
    [UpdateTime]              INT           NULL,
    [CreateDate]              DATETIME      NULL,
    [CreateTime]              INT           NULL,
    [DocumentSubmissionDate]  DATETIME      NULL,
    [CountryCode]             NVARCHAR (3)  NULL
);

