CREATE TABLE [dbo].[IPF2] (
    [LaCAllcAcc]  NVARCHAR (15)   NULL,
    [Docentry]    INT             NOT NULL,
    [CountryCode] NVARCHAR (10)   NULL,
    [AuditKey]    INT             NULL,
    [OhType]      VARCHAR (1)     NULL,
    [CostSum]     NUMERIC (19, 6) NULL,
    [AlcCode]     NVARCHAR (2)    NULL
);

