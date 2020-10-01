CREATE TABLE [dbo].[OPRC] (
    [Locked]      VARCHAR (1)     NULL,
    [DataSource]  VARCHAR (1)     NULL,
    [UserSign]    SMALLINT        NULL,
    [ValidFrom]   DATETIME        NULL,
    [ValidTo]     DATETIME        NULL,
    [Active]      VARCHAR (1)     NULL,
    [LogInstanc]  INT             NULL,
    [UserSign2]   SMALLINT        NULL,
    [UpdateDate]  DATETIME        NULL,
    [PrcCode]     NVARCHAR (8)    NULL,
    [PrcName]     NVARCHAR (30)   NULL,
    [GrpCode]     NVARCHAR (4)    NULL,
    [Balance]     NUMERIC (19, 6) NULL,
    [DimCode]     SMALLINT        NULL,
    [CCTypeCode]  NVARCHAR (8)    NULL,
    [CountryCode] NVARCHAR (3)    NULL
);

