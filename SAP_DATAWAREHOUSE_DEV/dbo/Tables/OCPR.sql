CREATE TABLE [dbo].[OCPR] (
    [CntctCode]   INT            NOT NULL,
    [CardCode]    NVARCHAR (15)  NOT NULL,
    [Name]        NVARCHAR (50)  NOT NULL,
    [Position]    NVARCHAR (90)  NULL,
    [Address]     NVARCHAR (100) NULL,
    [Tel1]        NVARCHAR (20)  NULL,
    [Tel2]        NVARCHAR (20)  NULL,
    [Cellolar]    NVARCHAR (50)  NULL,
    [E_MailL]     NVARCHAR (100) NULL,
    [DataSource]  CHAR (1)       NULL,
    [UserSign]    SMALLINT       NULL,
    [updateDate]  DATETIME2 (3)  NULL,
    [Title]       NVARCHAR (10)  NULL,
    [Active]      CHAR (1)       NULL,
    [FirstName]   NVARCHAR (50)  NULL,
    [MiddleName]  NVARCHAR (50)  NULL,
    [Lastname]    NVARCHAR (50)  NULL,
    [CountryCode] NVARCHAR (3)   NULL
);

