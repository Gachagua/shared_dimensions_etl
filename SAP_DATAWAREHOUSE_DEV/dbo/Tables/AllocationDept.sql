CREATE TABLE [dbo].[AllocationDept] (
    [U_CountryCode]       NCHAR (3)        NULL,
    [U_DeptOrig]          NCHAR (3)        NULL,
    [U_Month]             INT              NULL,
    [U_DeptAllocate]      NCHAR (3)        NULL,
    [mapping_year]        INT              NULL,
    [U_AllocationPercent] DECIMAL (18, 10) NULL
);

