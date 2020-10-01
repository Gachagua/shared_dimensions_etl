CREATE TABLE [dbo].[ItemBalances] (
    [ItemCode]           NVARCHAR (50)   NULL,
    [InStock]            NUMERIC (19, 6) NULL,
    [CountryCode]        NVARCHAR (5)    NULL,
    [IsCommited]         NUMERIC (19, 6) NULL,
    [OnOrder]            NUMERIC (19, 6) NULL,
    [AveragePrice]       NUMERIC (19, 6) NULL,
    [LastEvaluatedPrice] NUMERIC (19, 6) NULL,
    [LastPurchasePrice]  NUMERIC (19, 6) NULL
);

