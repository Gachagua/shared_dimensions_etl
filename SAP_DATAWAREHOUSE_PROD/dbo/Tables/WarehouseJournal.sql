CREATE TABLE [dbo].[WarehouseJournal] (
    [CreateDate]                         DATETIME2 (3)   NULL,
    [TransactionType]                    INT             NULL,
    [BaseReference]                      NVARCHAR (11)   NULL,
    [DocumentDate]                       DATETIME2 (3)   NULL,
    [BusinessPartnerName]                NVARCHAR (100)  NULL,
    [ItemCode]                           NVARCHAR (50)   NULL,
    [ReceiptQuantity]                    NUMERIC (19, 6) NULL,
    [IssueQuantity]                      NUMERIC (19, 6) NULL,
    [Price]                              NUMERIC (19, 6) NULL,
    [CalcPrice]                          NUMERIC (19, 6) NULL,
    [Currency]                           NVARCHAR (3)    NULL,
    [Warehouse]                          NVARCHAR (8)    NULL,
    [Balance]                            NUMERIC (19, 6) NULL,
    [Comments]                           NVARCHAR (254)  NULL,
    [InventoryAccount]                   NVARCHAR (15)   NULL,
    [TransactionValue]                   NUMERIC (19, 6) NULL,
    [InventoryOffsetIncreaseAccount]     NVARCHAR (15)   NULL,
    [InventoryOffsetIncreaseValue]       NUMERIC (19, 6) NULL,
    [InventoryOffsetdecreaseAccount]     NVARCHAR (15)   NULL,
    [InventoryOffsetDecreaseValue]       NUMERIC (19, 6) NULL,
    [PriceDifferenceAccount]             NVARCHAR (15)   NULL,
    [PriceDifferenceValue]               NUMERIC (19, 6) NULL,
    [COGSAccount]                        NVARCHAR (15)   NULL,
    [COGSValue]                          NUMERIC (19, 6) NULL,
    [G/LDecreaseAccount]                 NVARCHAR (15)   NULL,
    [G/LDecreaseValue]                   NUMERIC (19, 6) NULL,
    [G/LIncreaseAccount]                 NVARCHAR (15)   NULL,
    [G/LIncreaseValue]                   NUMERIC (19, 6) NULL,
    [UserSignature]                      SMALLINT        NULL,
    [NegativeInventoryAdjustmentAccount] NVARCHAR (15)   NULL,
    [NegativeInventoryAdjustmentValue]   NUMERIC (19, 6) NULL,
    [Description]                        NVARCHAR (100)  NULL,
    [DocumentRowNumber]                  INT             NULL,
    [createdby]                          INT             NULL,
    [CountryCode]                        NVARCHAR (10)   NULL,
    [TransactionNumber]                  INT             NULL
);


GO
CREATE NONCLUSTERED INDEX [WHJ_IDX]
    ON [dbo].[WarehouseJournal]([TransactionType] ASC, [ItemCode] ASC, [Warehouse] ASC, [DocumentRowNumber] ASC, [createdby] ASC, [CountryCode] ASC)
    INCLUDE([TransactionValue]);

