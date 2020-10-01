CREATE TABLE [dbo].[APCreditMemo.Old] (
    [DocumentEntry]           INT             NULL,
    [DocumentNumber]          INT             NULL,
    [DocumentDate]            DATETIME        NULL,
    [CreateDate]              DATETIME        NULL,
    [DocumentDraftInternalID] INT             NULL,
    [BusinessPartnerName]     NVARCHAR (100)  NULL,
    [DocumentTotal]           NUMERIC (19, 6) NULL,
    [DocumentTotalUSD]        NUMERIC (19, 6) NULL,
    [Comments]                NVARCHAR (254)  NULL,
    [UserSignature]           SMALLINT        NULL,
    [ObjectType]              NVARCHAR (20)   NULL,
    [Canceled]                VARCHAR (1)     NULL,
    [U_Season]                NVARCHAR (10)   NULL,
    [U_InputsApprover]        NVARCHAR (3)    NULL,
    [BaseDocumentInternalID]  INT             NULL,
    [BaseDocumentType]        INT             NULL,
    [CountryCode]             NVARCHAR (3)    NULL
);

