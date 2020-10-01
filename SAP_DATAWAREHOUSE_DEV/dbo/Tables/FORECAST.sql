CREATE TABLE [dbo].[FORECAST] (
    [U_CountryCode] NVARCHAR (10)   NULL,
    [U_DeptCode]    NVARCHAR (10)   NULL,
    [U_AcctCode]    INT             NULL,
    [U_BudgetDate]  DATETIME        NULL,
    [U_LocalBudget] NUMERIC (19, 6) NULL,
    [U_USDBudget]   NUMERIC (19, 6) NULL,
    [Version]       INT             NULL,
    [CreateDate]    DATETIME        NULL
);

