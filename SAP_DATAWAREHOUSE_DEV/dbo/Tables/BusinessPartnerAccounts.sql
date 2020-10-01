CREATE TABLE [dbo].[BusinessPartnerAccounts] (
    [Branch]              NVARCHAR (50)  NULL,
    [BankCode]            NVARCHAR (30)  NULL,
    [ControlKey]          NVARCHAR (2)   NULL,
    [BankKey]             INT            NULL,
    [BusinessPartnerCode] NVARCHAR (15)  NULL,
    [AccountName]         NVARCHAR (250) NULL,
    [AccountNumber]       NVARCHAR (50)  NULL,
    [SwiftCode]           NVARCHAR (50)  NULL,
    [CountryCode]         NVARCHAR (5)   NULL
);

