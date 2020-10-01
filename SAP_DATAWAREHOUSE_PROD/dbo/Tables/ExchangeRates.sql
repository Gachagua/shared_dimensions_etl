CREATE TABLE [dbo].[ExchangeRates] (
    [RateDate]      DATETIME        NULL,
    [Currency]      NVARCHAR (3)    NULL,
    [Rate]          NUMERIC (19, 6) NULL,
    [DataSource]    VARCHAR (1)     NULL,
    [UserSignature] SMALLINT        NULL,
    [CountryCode]   NVARCHAR (3)    NULL
);

