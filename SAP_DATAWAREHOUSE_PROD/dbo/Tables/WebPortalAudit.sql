CREATE TABLE [dbo].[WebPortalAudit] (
    [AuditId]           INT             NULL,
    [ExpenseId]         INT             NULL,
    [TransDate]         DATETIME2 (7)   NULL,
    [Type]              NVARCHAR (MAX)  NULL,
    [UserName]          NVARCHAR (MAX)  NULL,
    [Description]       NVARCHAR (MAX)  NULL,
    [LocalCost]         NUMERIC (18, 2) NULL,
    [PurchaseRequestId] INT             NULL,
    [Quantity]          INT             NULL,
    [UnitPrice]         NUMERIC (18, 2) NULL,
    [StatusId]          INT             NULL,
    [WarehouseId]       INT             NULL
);

