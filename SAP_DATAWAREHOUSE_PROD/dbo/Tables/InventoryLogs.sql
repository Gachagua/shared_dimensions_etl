CREATE TABLE [dbo].[InventoryLogs] (
    [Quantity]              NUMERIC (19, 6) NULL,
    [Price]                 NUMERIC (19, 6) NULL,
    [ItemCode]              NVARCHAR (50)   NULL,
    [MessageID]             INT             NULL,
    [CreateDate]            DATETIME        NULL,
    [ActionType]            INT             NULL,
    [Location]              NVARCHAR (8)    NULL,
    [DocumentPriceCurrency] NVARCHAR (3)    NULL,
    [DocumentPriceRate]     NUMERIC (19, 6) NULL,
    [DocumentEntry]         INT             NULL,
    [TransactionType]       INT             NULL,
    [DocumentLineNumber]    INT             NULL,
    [DocumentDate]          DATETIME        NULL,
    [BaseReference]         NVARCHAR (11)   NULL,
    [DepartmentCode]        NVARCHAR (8)    NULL,
    [LocationCode]          NVARCHAR (8)    NULL,
    [BaseTransactionType]   INT             NULL,
    [UserSignature]         SMALLINT        NULL,
    [AccumulatorType]       INT             NULL,
    [CountryCode]           NVARCHAR (3)    NULL,
    [CreateDateID]          INT             NULL,
    [DocumentDateID]        INT             NULL,
    [DepartmentID]          INT             NULL,
    [LocationID]            INT             NULL,
    [CountryID]             INT             NULL,
    [ItemID]                INT             NULL,
    [ItemGroupName]         NVARCHAR (100)  NULL,
    [WarehouseID]           INT             NULL
);


GO
CREATE NONCLUSTERED INDEX [IL_IDX]
    ON [dbo].[InventoryLogs]([ItemCode] ASC, [Location] ASC, [AccumulatorType] ASC, [CountryCode] ASC)
    INCLUDE([Quantity], [MessageID], [CreateDate], [ActionType], [DocumentEntry], [TransactionType], [DocumentLineNumber], [DocumentDate], [BaseReference], [DepartmentCode], [LocationCode], [BaseTransactionType], [UserSignature], [CountryID], [ItemGroupName]);

