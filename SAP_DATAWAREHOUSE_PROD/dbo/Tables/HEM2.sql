CREATE TABLE [dbo].[HEM2] (
    [empID]         INT            NOT NULL,
    [PaymentMode]   INT            NULL,
    [MobileCarrier] NVARCHAR (100) NULL,
    [MobileName]    NVARCHAR (50)  NULL,
    [MobileNumber]  NVARCHAR (50)  NULL,
    [WebExpenseId]  NVARCHAR (450) NULL,
    [AccountCode]   NVARCHAR (10)  NULL,
    [line]          SMALLINT       NULL,
    [CountryCode]   NVARCHAR (10)  NULL,
    [CarrierId]     INT            NULL,
    [Active]        NVARCHAR (2)   NULL,
    [U_BankCode]    NVARCHAR (20)  NULL
);

