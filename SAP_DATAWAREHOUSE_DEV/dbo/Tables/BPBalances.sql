CREATE TABLE [dbo].[BPBalances] (
    [BusinessPartnerCode]                   NVARCHAR (15)   NULL,
    [AccountBalance]                        NUMERIC (19, 6) NULL,
    [OpenChecksBalance]                     NUMERIC (19, 6) NULL,
    [OpenGRPOBalance]                       NUMERIC (19, 6) NULL,
    [OpenOrdersBalance]                     NUMERIC (19, 6) NULL,
    [PaymentTermsCode]                      SMALLINT        NULL,
    [CreditLimit]                           NUMERIC (19, 6) NULL,
    [PayableLimit]                          NUMERIC (19, 6) NULL,
    [WithHoldingTaxDeduction]               NUMERIC (19, 6) NULL,
    [OpenDeliveryNoteBalanceUSD]            NUMERIC (19, 6) NULL,
    [OpenOrdersBalanceUSD]                  NUMERIC (19, 6) NULL,
    [OpenDeliveryNoteBalanceSystemCurrency] NUMERIC (19, 6) NULL,
    [OpenOrdersBalanceSystemCurrency]       NUMERIC (19, 6) NULL,
    [InterestPercentOnLiabilities]          NUMERIC (19, 6) NULL,
    [BalanceSystemCurrency]                 NUMERIC (19, 6) NULL,
    [BalanceUSD]                            NUMERIC (19, 6) NULL,
    [MinimumInterestLetterAmount]           NUMERIC (19, 6) NULL,
    [MaxExemptionAmount]                    NUMERIC (19, 6) NULL,
    [CountryCode]                           NVARCHAR (50)   NULL
);

