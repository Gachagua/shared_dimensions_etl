CREATE TABLE [dbo].[ItemWarehouseBalances] (
    [Itemcode]                  NVARCHAR (50)   NULL,
    [WarehouseCode]             NVARCHAR (8)    NULL,
    [InStock]                   NUMERIC (19, 6) NULL,
    [AveragePrice]              NUMERIC (19, 6) NULL,
    [Ordered]                   NUMERIC (19, 6) NULL,
    [ConsignmentGoodsWarehouse] NUMERIC (19, 6) NULL,
    [CountedQuantity]           NUMERIC (19, 6) NULL,
    [IsCommited]                NUMERIC (19, 6) NULL,
    [CountryCode]               NVARCHAR (3)    NULL
);

