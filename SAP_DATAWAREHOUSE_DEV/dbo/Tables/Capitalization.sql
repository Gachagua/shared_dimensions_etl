CREATE TABLE [dbo].[Capitalization] (
    [ItemCode]                  NVARCHAR (50)   NULL,
    [DocumentEntry]             INT             NULL,
    [ReferenceDate]             DATETIME        NULL,
    [PeriodCategory]            NVARCHAR (10)   NULL,
    [CapitalizationLocalAmount] NUMERIC (19, 6) NULL,
    [CapitalizationUSDAmount]   NUMERIC (19, 6) NULL,
    [JETransactionID]           INT             NULL,
    [CountryCode]               NVARCHAR (3)    NULL,
    [RowNumber]                 INT             NULL
);

