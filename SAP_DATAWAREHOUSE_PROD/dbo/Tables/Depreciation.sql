CREATE TABLE [dbo].[Depreciation] (
    [AssetClass]           NVARCHAR (20)   NULL,
    [ItemCode]             NVARCHAR (50)   NULL,
    [DocumentEntry]        INT             NULL,
    [DepreciationArea]     NVARCHAR (15)   NULL,
    [ReferenceDate]        DATETIME        NULL,
    [PeriodCategory]       NVARCHAR (10)   NULL,
    [DepreciationAmount]   NUMERIC (19, 6) NULL,
    [BalanceAccount]       NVARCHAR (15)   NULL,
    [JETransactionID]      INT             NULL,
    [CountryCode]          NVARCHAR (3)    NULL,
    [AccountDetermination] NVARCHAR (15)   NULL,
    [DocumentStatus]       VARCHAR (1)     NULL,
    [Canceled]             VARCHAR (1)     NULL
);

