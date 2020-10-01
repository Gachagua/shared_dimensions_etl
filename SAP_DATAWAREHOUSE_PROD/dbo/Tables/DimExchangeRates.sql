CREATE TABLE [dbo].[DimExchangeRates] (
    [ExchangeRateId] INT             NULL,
    [CurrencyId]     INT             NULL,
    [Rate]           NUMERIC (13, 4) NULL,
    [RateDate]       DATETIME2 (7)   NULL,
    [RateMonth]      NVARCHAR (450)  NULL,
    [RateYear]       NVARCHAR (450)  NULL
);

