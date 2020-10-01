CREATE TABLE [dbo].[ItemWarehouseBin] (
    [ItemCode]                NVARCHAR (50)   NULL,
    [ItemName]                NVARCHAR (100)  NULL,
    [Item Group]              NVARCHAR (20)   NULL,
    [item Sub Group]          NVARCHAR (40)   NULL,
    [Warehouse]               NVARCHAR (8)    NULL,
    [Bin]                     NVARCHAR (50)   NULL,
    [Batch Number]            NVARCHAR (36)   NULL,
    [Expiration Date]         DATETIME        NULL,
    [Manufacturing Date]      DATETIME        NULL,
    [Batch Attribute 1]       NVARCHAR (36)   NULL,
    [Batch Attribute 2]       NVARCHAR (36)   NULL,
    [OnHand]                  NUMERIC (19, 6) NULL,
    [Warehouse Average Price] NUMERIC (19, 6) NULL,
    [CountryCode]             NVARCHAR (3)    NULL
);

