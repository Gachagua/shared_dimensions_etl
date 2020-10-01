CREATE TABLE [dbo].[DimBank] (
    [BankId]               INT            NULL,
    [Active]               BIT            NULL,
    [BankName]             NVARCHAR (MAX) NULL,
    [CountryId]            INT            NULL,
    [OafBankAccountNumber] NVARCHAR (MAX) NULL
);

