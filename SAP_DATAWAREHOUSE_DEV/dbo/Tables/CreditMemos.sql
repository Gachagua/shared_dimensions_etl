CREATE TABLE [dbo].[CreditMemos] (
    [ItemCode]             NVARCHAR (50)   NULL,
    [DocumentEntry]        INT             NULL,
    [DocumentNumber]       INT             NULL,
    [TransactionID]        INT             NULL,
    [RowNumber]            INT             NULL,
    [Quantity]             NUMERIC (19, 6) NULL,
    [TotalForeignCurrency] NUMERIC (19, 6) NULL,
    [TotalSumUSD]          NUMERIC (19, 6) NULL,
    [Rowtotal]             NUMERIC (19, 6) NULL,
    [CountryCode]          NVARCHAR (3)    NULL
);

