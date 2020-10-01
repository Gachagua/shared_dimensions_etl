CREATE TABLE [dbo].[AssetItemDepreciation] (
    [ItemCode]    NVARCHAR (50)   NULL,
    [PeriodCat]   NVARCHAR (10)   NULL,
    [DprArea]     NVARCHAR (15)   NULL,
    [VisOrder]    INT             NULL,
    [DprStart]    DATETIME        NULL,
    [DprEnd]      DATETIME        NULL,
    [UsefulLife]  INT             NULL,
    [RemainLife]  NUMERIC (19, 6) NULL,
    [DprType]     NVARCHAR (15)   NULL,
    [DprTypeC]    NVARCHAR (15)   NULL,
    [UsefulLfeC]  INT             NULL,
    [LogInstanc]  INT             NULL,
    [ObjType]     NVARCHAR (20)   NULL,
    [RemainDays]  NUMERIC (19, 6) NULL,
    [TotalUnits]  INT             NULL,
    [RemainUnit]  INT             NULL,
    [StanUnit]    INT             NULL,
    [CountryCode] NVARCHAR (3)    NULL
);

