CREATE TABLE [dbo].[DepartmentAllocation] (
    [AllocationId]   INT            NOT NULL,
    [DepartmentId]   INT            NULL,
    [DepartmentCode] NVARCHAR (255) NULL,
    [DepartmentName] NVARCHAR (255) NULL,
    [DepartmentType] NVARCHAR (255) NULL,
    [mapping_year]   INT            NULL,
    [Dept_BusUnit]   NVARCHAR (50)  NULL,
    [Dept_Descrip]   NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([AllocationId] ASC)
);

