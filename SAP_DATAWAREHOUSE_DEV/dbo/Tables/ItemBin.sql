CREATE TABLE [dbo].[ItemBin] (
    [ItemCode]          NVARCHAR (50)   NULL,
    [CountryCode]       NVARCHAR (2)    NULL,
    [OnHandQuantity]    NUMERIC (19, 6) NULL,
    [WarehouseCode]     NVARCHAR (8)    NULL,
    [ItemFrozen]        VARCHAR (1)     NULL,
    [FrozenBy]          INT             NULL,
    [BinInternalNumber] INT             NULL,
    [InternalNumber]    INT             NULL,
    [ItemID]            INT             NULL,
    [CountryID]         INT             NULL
);

