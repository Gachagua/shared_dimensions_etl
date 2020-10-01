CREATE TABLE [dbo].[JournalVouchers] (
    [JournalVoucherNumber] INT             NULL,
    [Status]               VARCHAR (1)     NULL,
    [NumberOfTransactions] SMALLINT        NULL,
    [PostingDate]          DATETIME        NULL,
    [TotalLocalCurrency]   NUMERIC (19, 6) NULL,
    [TotalUSD]             NUMERIC (19, 6) NULL,
    [TotalSystemCurrency]  NUMERIC (19, 6) NULL,
    [Details]              NVARCHAR (50)   NULL,
    [UserSignature]        SMALLINT        NULL,
    [Remarks]              NVARCHAR (50)   NULL,
    [CountryCode]          NVARCHAR (3)    NULL
);

