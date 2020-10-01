CREATE TABLE [dbo].[SAPUserLicenses] (
    [User_Code]    NVARCHAR (25)  NULL,
    [U_Name]       NVARCHAR (155) NULL,
    [Deleted/Live] VARCHAR (7)    NOT NULL,
    [E_Mail]       NVARCHAR (100) NULL,
    [License]      VARCHAR (50)   NULL,
    [SuperUser]    CHAR (1)       NULL,
    [Locked]       CHAR (1)       NULL,
    [updateDate]   DATETIME       NULL,
    [lastLogin]    DATETIME       NULL,
    [CountryCode]  NVARCHAR (10)  NULL
);

