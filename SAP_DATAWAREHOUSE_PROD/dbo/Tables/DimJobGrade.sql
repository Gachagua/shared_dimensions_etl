CREATE TABLE [dbo].[DimJobGrade] (
    [JobGradeId]   INT            NOT NULL,
    [JobGradeCode] INT            NOT NULL,
    [JobGradeName] NVARCHAR (MAX) NULL,
    [Active]       BIT            NOT NULL
);

