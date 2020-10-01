CREATE TABLE [dbo].[OHEM] (
    [firstname]    NVARCHAR (50)  NULL,
    [lastname]     NVARCHAR (50)  NULL,
    [middlename]   NVARCHAR (50)  NULL,
    [Location]     NVARCHAR (100) NULL,
    [Department]   NVARCHAR (20)  NULL,
    [PayGrade]     NVARCHAR (20)  NULL,
    [StaffLevel]   NVARCHAR (20)  NULL,
    [email]        NVARCHAR (100) NULL,
    [active]       CHAR (1)       NULL,
    [ExtEmpNo]     NVARCHAR (20)  NULL,
    [U_WebUser]    NVARCHAR (3)   NULL,
    [U_Dapprover]  NVARCHAR (50)  NULL,
    [U_Bapprover]  NVARCHAR (50)  NULL,
    [CountryCode]  NVARCHAR (10)  NULL,
    [EmpId]        INT            NULL,
    [U_U_JobGrade] INT            NULL
);

