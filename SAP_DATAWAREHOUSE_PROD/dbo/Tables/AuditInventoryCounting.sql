CREATE TABLE [dbo].[AuditInventoryCounting] (
    [UpdateDate]                DATETIME        NULL,
    [CountDate]                 DATETIME        NULL,
    [Difference]                NUMERIC (19, 6) NULL,
    [CountryCode]               NVARCHAR (3)    NULL,
    [DocumentEntry]             INT             NULL,
    [DocumentNumber]            INT             NULL,
    [LogInstance]               INT             NULL,
    [UserCreating]              SMALLINT        NULL,
    [WarehouseCode]             NVARCHAR (8)    NULL,
    [ItemDescription]           NVARCHAR (100)  NULL,
    [InWarehouseQuantity]       NUMERIC (19, 6) NULL,
    [CountedQuantity]           NUMERIC (19, 6) NULL,
    [TotalDifferencePercentage] NUMERIC (19, 6) NULL,
    [BinLocationEntry]          INT             NULL,
    [UpdateDateID]              INT             NULL,
    [CountDateID]               INT             NULL,
    [Rownumber]                 INT             NULL
);


GO
CREATE NONCLUSTERED INDEX [ix_CountryCode_DocumentEntry_Rownumber]
    ON [dbo].[AuditInventoryCounting]([CountryCode] ASC, [DocumentEntry] ASC, [Rownumber] ASC);

