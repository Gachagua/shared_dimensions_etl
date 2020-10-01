CREATE TABLE [dbo].[CRD1] (
    [Address]     NVARCHAR (100) NOT NULL,
    [CardCode]    NVARCHAR (15)  NOT NULL,
    [Street]      NVARCHAR (100) NULL,
    [Block]       NVARCHAR (100) NULL,
    [City]        NVARCHAR (100) NULL,
    [County]      NVARCHAR (100) NULL,
    [Country]     NVARCHAR (3)   NULL,
    [ObjType]     NVARCHAR (20)  NULL,
    [LicTradNum]  NVARCHAR (32)  NULL,
    [LineNum]     INT            NULL,
    [AdresType]   CHAR (1)       NOT NULL,
    [Address2]    NVARCHAR (50)  NULL,
    [Address3]    NVARCHAR (50)  NULL,
    [CountryCode] NVARCHAR (20)  NULL
);

