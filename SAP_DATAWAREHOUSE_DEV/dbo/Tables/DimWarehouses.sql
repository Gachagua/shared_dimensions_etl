CREATE TABLE [dbo].[DimWarehouses] (
    [WarehouseName]  NVARCHAR (100) NULL,
    [WarehouseCode]  NVARCHAR (20)  NULL,
    [CountryID]      INT            NULL,
    [DimWarehouseId] INT            IDENTITY (1, 1) NOT NULL,
    [WebWarehouseId] INT            NULL,
    [Active]         BIT            NULL,
    [Type]           NVARCHAR (50)  NULL
);

