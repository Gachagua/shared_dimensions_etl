CREATE TABLE [dbo].[HEAORECAST] (
    [U_CountryCode]     NVARCHAR (10) NULL,
    [U_DeptCode]        NVARCHAR (10) NULL,
    [U_LevelCode]       INT           NULL,
    [U_BudgetDate]      DATETIME      NULL,
    [U_HeadcountBudget] INT           NULL,
    [U_HeadcountActual] INT           NULL,
    [Version]           INT           NULL,
    [CreateDate]        DATE          NULL
);

