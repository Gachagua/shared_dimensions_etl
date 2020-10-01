CREATE TABLE [dbo].[ContactPersons] (
    [ContactCode]         INT            NULL,
    [BusinessPartnerCode] NVARCHAR (15)  NULL,
    [ContactPersonName]   NVARCHAR (50)  NULL,
    [Position]            NVARCHAR (90)  NULL,
    [Address]             NVARCHAR (100) NULL,
    [Telephone1]          NVARCHAR (20)  NULL,
    [Telephone2]          NVARCHAR (20)  NULL,
    [MobilePhone]         NVARCHAR (50)  NULL,
    [Email]               NVARCHAR (100) NULL,
    [DataSource]          VARCHAR (1)    NULL,
    [UserSignature]       SMALLINT       NULL,
    [UpdateDate]          DATETIME2 (3)  NULL,
    [Title]               NVARCHAR (10)  NULL,
    [Active]              VARCHAR (1)    NULL,
    [FirstName]           NVARCHAR (50)  NULL,
    [MiddleName]          NVARCHAR (50)  NULL,
    [LastName]            NVARCHAR (50)  NULL,
    [CountryCode]         NVARCHAR (3)   NULL
);

