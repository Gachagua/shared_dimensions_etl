CREATE TABLE [dbo].[DimSalesEmployees] (
    [SalesEmployeeID]   INT             IDENTITY (1, 1) NOT NULL,
    [SalesEmployeeCode] INT             NULL,
    [SalesEmployeeName] NVARCHAR (155)  NULL,
    [Memo]              NVARCHAR (50)   NULL,
    [Commission]        NUMERIC (19, 6) NULL,
    [GroupCode]         SMALLINT        NULL,
    [Locked]            VARCHAR (1)     NULL,
    [DataSource]        VARCHAR (1)     NULL,
    [UserSignature]     SMALLINT        NULL,
    [EmployeeID]        INT             NULL,
    [Active]            VARCHAR (1)     NULL,
    [Telephone]         NVARCHAR (20)   NULL,
    [Mobile]            NVARCHAR (50)   NULL,
    [Fax]               NVARCHAR (20)   NULL,
    [Email]             NVARCHAR (100)  NULL,
    [CountryCode]       NVARCHAR (3)    NULL
);

