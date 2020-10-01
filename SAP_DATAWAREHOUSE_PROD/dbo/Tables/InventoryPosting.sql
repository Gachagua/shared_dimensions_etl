CREATE TABLE [dbo].[InventoryPosting] (
    [CreateDate]        DATETIME        NULL,
    [CountryCode]       NVARCHAR (3)    NULL,
    [DocumentEntry]     INT             NULL,
    [DocumentNumber]    INT             NULL,
    [BaseDocumentEntry] INT             NULL,
    [BaseDocumentType]  INT             NULL,
    [BaseDocumentRow]   INT             NULL,
    [CountDate]         DATETIME        NULL,
    [DocumentDate]      DATETIME        NULL,
    [DocLineNum]        INT             NULL,
    [Price]             NUMERIC (19, 6) NULL,
    [Quantity]          NUMERIC (19, 6) NULL,
    [OnHandBefore]      NUMERIC (19, 6) NULL,
    [DocTotalLocal]     NUMERIC (19, 6) NULL,
    [DocTotalUSD]       NUMERIC (19, 6) NULL,
    [DiffPercent]       NUMERIC (19, 6) NULL,
    [CountQuantity]     NUMERIC (19, 6) NULL,
    [U_Attachment1]     NVARCHAR (MAX)  NULL,
    [U_Attachment2]     NVARCHAR (MAX)  NULL
);

