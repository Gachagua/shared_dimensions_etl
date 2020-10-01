CREATE TABLE [dbo].[OPRJ] (
    [PrjCode]     NVARCHAR (20)  NULL,
    [PrjName]     NVARCHAR (100) NULL,
    [Locked]      VARCHAR (1)    NULL,
    [DataSource]  VARCHAR (1)    NULL,
    [UserSign]    SMALLINT       NULL,
    [ValidFrom]   DATETIME       NULL,
    [ValidTo]     DATETIME       NULL,
    [Active]      VARCHAR (1)    NULL,
    [LogInstanc]  INT            NULL,
    [UserSign2]   SMALLINT       NULL,
    [UpdateDate]  DATETIME       NULL,
    [U_Dept]      NVARCHAR (5)   NULL,
    [CountryCode] NVARCHAR (3)   NULL
);

