CREATE TABLE [dbo].[DimFile] (
    [FileId]                           INT            NULL,
    [ContentType]                      NVARCHAR (100) NULL,
    [ExpenseId]                        INT            NULL,
    [FileName]                         NVARCHAR (255) NULL,
    [FileType]                         INT            NULL,
    [FilePath]                         NVARCHAR (MAX) NULL,
    [GuidFileName]                     NVARCHAR (MAX) NULL,
    [PurchaseRequestId]                INT            NULL,
    [ExpenseHeaderId]                  INT            NULL,
    [BlobName]                         NVARCHAR (MAX) NULL,
    [PurchaseRequestVendorSelectionId] INT            NULL,
    [InvoiceHeaderId]                  INT            NULL,
    [DistributionRequestId]            INT            NULL,
    [InventoryTransferRequestId]       INT            NULL
);

