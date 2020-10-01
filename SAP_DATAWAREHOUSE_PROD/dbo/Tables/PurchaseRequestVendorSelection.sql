CREATE TABLE [dbo].[PurchaseRequestVendorSelection] (
    [VendorSelectionID]   INT             NULL,
    [PurchaseRequestID]   INT             NULL,
    [PurchaseRequestType] NVARCHAR (50)   NULL,
    [PR Status]           NVARCHAR (50)   NULL,
    [QuotesProvisionDate] DATETIME2 (7)   NULL,
    [Purchaser]           NVARCHAR (201)  NULL,
    [Country]             NVARCHAR (50)   NULL,
    [SAPVendorID]         NVARCHAR (15)   NULL,
    [VendorName]          NVARCHAR (200)  NULL,
    [SAPItemID]           NVARCHAR (50)   NULL,
    [ItemName]            NVARCHAR (100)  NULL,
    [LeadTime]            NVARCHAR (200)  NULL,
    [ItemSpecification]   NVARCHAR (MAX)  NULL,
    [Comments]            NVARCHAR (MAX)  NULL,
    [Quantity]            INT             NULL,
    [UnitPrice]           NUMERIC (18, 2) NULL,
    [Currency]            NVARCHAR (50)   NULL,
    [Selected]            BIT             NULL
);

