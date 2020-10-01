CREATE TABLE [dbo].[APInvoiceWTax] (
    [DocumentEntry]                INT             NULL,
    [WTaxAmount]                   NUMERIC (19, 6) NULL,
    [WTaxAmountForeignCurrency]    NUMERIC (19, 6) NULL,
    [WithholdingTaxCode]           NVARCHAR (4)    NULL,
    [WithholdingTaxName]           NVARCHAR (50)   NULL,
    [WithholdingTaxRate]           NUMERIC (19, 6) NULL,
    [WithholdingTaxCategory]       VARCHAR (1)     NULL,
    [WithholdingTaxCriteria]       VARCHAR (1)     NULL,
    [WithholdingTaxAccount]        NVARCHAR (15)   NULL,
    [TaxableAmount]                NUMERIC (19, 6) NULL,
    [TaxableAmountSystemCurrency]  NUMERIC (19, 6) NULL,
    [TaxableAmountForeignCurrency] NUMERIC (19, 6) NULL,
    [WTaxAmountSystemCurrency]     NUMERIC (19, 6) NULL,
    [CountryCode]                  NVARCHAR (50)   NULL,
    [UpdateDate]                   DATETIME        NULL
);

