CREATE TABLE [dbo].[BusinessPartnerWithholdingTax] (
    [BusinessPartnerCode] NVARCHAR (15)   NULL,
    [WithholdingTaxCode]  NVARCHAR (4)    NULL,
    [WithholdingTaxName]  NVARCHAR (50)   NULL,
    [Rate]                NUMERIC (19, 6) NULL,
    [EffectiveFrom]       DATETIME        NULL,
    [Inactive]            VARCHAR (1)     NULL,
    [CountryCode]         NVARCHAR (3)    NULL
);

