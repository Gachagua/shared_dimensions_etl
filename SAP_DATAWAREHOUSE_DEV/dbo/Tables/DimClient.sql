CREATE TABLE [dbo].[DimClient] (
    [Client_Key]  INT            IDENTITY (1, 1) NOT NULL,
    [ClientID]    NVARCHAR (100) NULL,
    [ClientName]  NVARCHAR (100) NULL,
    [groupcode]   SMALLINT       NULL,
    [GroupName]   VARCHAR (19)   NULL,
    [Address]     NVARCHAR (100) NULL,
    [Phone1]      NVARCHAR (20)  NULL,
    [Status]      VARCHAR (8)    NULL,
    [CountryCode] NVARCHAR (20)  NULL,
    [CountryName] NVARCHAR (20)  NULL
);

