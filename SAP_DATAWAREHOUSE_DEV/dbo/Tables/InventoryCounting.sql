CREATE TABLE [dbo].[InventoryCounting] (
    [Status]                    VARCHAR (1)     NULL,
    [CountDate]                 DATETIME        NULL,
    [CreateDate]                DATETIME        NULL,
    [UpdateDate]                DATETIME        NULL,
    [Remarks]                   NVARCHAR (MAX)  NULL,
    [CreateTime]                SMALLINT        NULL,
    [U_Attachment1]             NVARCHAR (MAX)  NULL,
    [U_Attachment2]             NVARCHAR (MAX)  NULL,
    [Counted]                   VARCHAR (1)     NULL,
    [Difference]                NUMERIC (19, 6) NULL,
    [CountryCode]               NVARCHAR (3)    NULL,
    [DocumentNumber]            INT             NULL,
    [DocumentEntry]             INT             NULL,
    [TotalDifference]           NUMERIC (19, 6) NULL,
    [TotalDifferencePercentage] NUMERIC (19, 6) NULL,
    [UserCreating]              SMALLINT        NULL,
    [WarehouseCode]             NVARCHAR (8)    NULL,
    [InWarehouseQuantity]       NUMERIC (19, 6) NULL,
    [CountedQuantity]           NUMERIC (19, 6) NULL,
    [BinLocationEntry]          INT             NULL,
    [ItemDescription]           NVARCHAR (100)  NULL,
    [ItemCode]                  NVARCHAR (50)   NULL,
    [CreateDateID]              INT             NULL,
    [ItemID]                    INT             NULL,
    [UpdateDateID]              INT             NULL,
    [CountDateID]               INT             NULL,
    [CountryID]                 INT             NULL,
    [TargetDocumentType]        INT             NULL,
    [TargetDocumentInternalID]  INT             NULL,
    [TargetDocumentRow]         INT             NULL,
    [RowNumber]                 INT             NULL
);


GO
CREATE NONCLUSTERED INDEX [IC_IDX]
    ON [dbo].[InventoryCounting]([Difference] ASC)
    INCLUDE([Status], [CountDate], [UpdateDate], [CountryCode], [DocumentNumber], [DocumentEntry], [UserCreating], [WarehouseCode], [BinLocationEntry], [ItemCode], [ItemID], [CountryID]);

