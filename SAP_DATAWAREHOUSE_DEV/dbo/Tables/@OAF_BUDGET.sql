CREATE TABLE [dbo].[@OAF_BUDGET] (
    [U_CountryCode] NVARCHAR (10)   NULL,
    [U_DeptCode]    NVARCHAR (10)   NULL,
    [U_AcctCode]    INT             NULL,
    [U_BudgetDate]  DATETIME        NULL,
    [U_LocalBudget] NUMERIC (19, 6) NULL,
    [U_USDBudget]   NUMERIC (19, 6) NULL,
    [U_Version]     INT             NULL
);


GO
CREATE STATISTICS [_dta_stat_725577623_1_2_3]
    ON [dbo].[@OAF_BUDGET]([U_CountryCode], [U_DeptCode], [U_AcctCode]);


GO
CREATE STATISTICS [_dta_stat_725577623_1_3_4_7]
    ON [dbo].[@OAF_BUDGET]([U_CountryCode], [U_AcctCode], [U_BudgetDate], [U_Version]);

