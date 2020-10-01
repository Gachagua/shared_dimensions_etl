CREATE TABLE [dbo].[DimSAPProjects] (
    [Active]      VARCHAR (1)    NULL,
    [ValidFrom]   DATETIME       NULL,
    [ValidTo]     DATETIME       NULL,
    [CountryId]   INT            NULL,
    [ProjectCode] NVARCHAR (20)  NULL,
    [ProjectName] NVARCHAR (100) NULL,
    [U_Dept]      NVARCHAR (5)   NULL,
    [SAPActive]   VARCHAR (1)    NULL,
    [ProjectId]   INT            IDENTITY (1, 1) NOT NULL
);

