CREATE TABLE [dbo].[DimWebBankAccounts] (
    [BankAccountId]     INT            NULL,
    [ApplicationUserId] NVARCHAR (450) NULL,
    [BankAccontNumber]  NVARCHAR (50)  NULL,
    [BankAccountName]   NVARCHAR (100) NULL,
    [BankName]          NVARCHAR (100) NULL,
    [Default]           BIT            NULL,
    [BankBranchName]    NVARCHAR (100) NULL,
    [Line]              SMALLINT       NULL,
    [SwiftCode]         NVARCHAR (20)  NULL,
    [EmployeeId]        INT            NULL,
    [Active]            BIT            NULL,
    [Validated]         BIT            NULL
);

