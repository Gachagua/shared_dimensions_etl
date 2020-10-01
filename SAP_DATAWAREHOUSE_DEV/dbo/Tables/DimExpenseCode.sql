CREATE TABLE [dbo].[DimExpenseCode] (
    [ExpenseCodeid]    INT            NOT NULL,
    [ExpenseCodeName]  NVARCHAR (MAX) NULL,
    [ExpenseCodeValue] INT            NOT NULL,
    [ExpenseTypeId]    INT            NULL,
    [Active]           BIT            NOT NULL,
    [StaffLevelId]     INT            NULL
);

