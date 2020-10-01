CREATE TABLE [dbo].[WebInvoiceHeaderAudit] (
    [InvoiceHeaderAuditId] INT            NULL,
    [Action]               NVARCHAR (MAX) NULL,
    [AfterStatusId]        INT            NULL,
    [BeforeStatusId]       INT            NULL,
    [Description]          NVARCHAR (MAX) NULL,
    [InvoiceHeaderId]      INT            NULL,
    [TransDate]            DATETIME2 (7)  NULL,
    [UserId]               NVARCHAR (450) NULL
);

