CREATE TABLE [dbo].[DimWarehouseItems] (
    [WarehouseCode]   NVARCHAR (8)    NOT NULL,
    [itemcode]        NVARCHAR (50)   NOT NULL,
    [AveragePrice]    NUMERIC (19, 6) NOT NULL,
    [OnHandQuantity]  NUMERIC (19, 6) NOT NULL,
    [Locked]          CHAR (1)        NULL,
    [itemname]        NVARCHAR (100)  NULL,
    [ItmsGrpNam]      NVARCHAR (20)   NULL,
    [U_SUB_GR]        NVARCHAR (40)   NULL,
    [validfor]        CHAR (1)        NULL,
    [validFrom]       DATETIME        NULL,
    [Validto]         DATETIME        NULL,
    [CountryId]       INT             NOT NULL,
    [WarehouseItemID] INT             IDENTITY (1, 1) NOT NULL,
    [Active]          BIT             NULL
);

