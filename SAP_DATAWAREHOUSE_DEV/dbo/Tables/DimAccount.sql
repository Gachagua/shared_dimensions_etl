CREATE TABLE [dbo].[DimAccount] (
    [AcctCode]    NVARCHAR (15)  NOT NULL,
    [AcctName]    NVARCHAR (100) NULL,
    [CountryCode] NVARCHAR (10)  NULL,
    [Account_Key] INT            IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_DimAccount] PRIMARY KEY CLUSTERED ([Account_Key] ASC)
);

