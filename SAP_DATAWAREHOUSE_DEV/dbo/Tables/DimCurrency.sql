CREATE TABLE [dbo].[DimCurrency] (
    [Currencyid]    INT            NOT NULL,
    [CurrencyCode]  NVARCHAR (MAX) NULL,
    [ExpenseTypeId] INT            NULL,
    [CountryId]     INT            NULL
);

