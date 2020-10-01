CREATE TABLE [dbo].[IncomingPayments] (
    [DocumentNumber]     INT             NULL,
    [TransferAccount]    NVARCHAR (15)   NULL,
    [CountryCode]        NVARCHAR (20)   NULL,
    [DocumentEntry]      INT             NULL,
    [PaidSystemCurrency] NUMERIC (19, 6) NULL,
    [InvoiceType]        NVARCHAR (20)   NULL
);

