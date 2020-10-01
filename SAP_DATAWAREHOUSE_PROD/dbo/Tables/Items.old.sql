CREATE TABLE [dbo].[Items.old] (
    [ItemCode]          NVARCHAR (50)   NULL,
    [ItemName]          NVARCHAR (100)  NULL,
    [U_Item_Visibility] NVARCHAR (10)   NULL,
    [U_SUB_GR]          NVARCHAR (40)   NULL,
    [ValidFrom]         DATETIME        NULL,
    [ValidTo]           DATETIME        NULL,
    [Locked]            VARCHAR (1)     NULL,
    [CountryCode]       NVARCHAR (10)   NULL,
    [createdate]        DATETIME        NULL,
    [GroupCode]         SMALLINT        NULL,
    [GroupName]         NVARCHAR (20)   NULL,
    [InventoryUOM]      NVARCHAR (100)  NULL,
    [InventoryItem]     VARCHAR (1)     NULL,
    [Active]            VARCHAR (1)     NULL,
    [ProcurementMethod] VARCHAR (1)     NULL,
    [PurchaseItem]      VARCHAR (3)     NULL,
    [ExpenseAccount]    NVARCHAR (15)   NULL,
    [IWeight1]          NUMERIC (19, 6) NULL,
    [AttachmentEntry]   INT             NULL,
    [CreateDateID]      INT             NULL,
    [CountryID]         INT             NULL
);

