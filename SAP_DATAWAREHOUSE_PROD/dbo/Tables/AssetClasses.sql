CREATE TABLE [dbo].[AssetClasses] (
    [Code]           NVARCHAR (20)   NULL,
    [Name]           NVARCHAR (100)  NULL,
    [AssetType]      VARCHAR (1)     NULL,
    [LimitFrom]      NUMERIC (19, 6) NULL,
    [LimitTo]        NUMERIC (19, 6) NULL,
    [DataSource]     VARCHAR (1)     NULL,
    [UserSignature]  SMALLINT        NULL,
    [LogInstance]    INT             NULL,
    [CreateDate]     DATETIME        NULL,
    [UpdatingUser]   SMALLINT        NULL,
    [UpdateDate]     DATETIME        NULL,
    [Branch]         INT             NULL,
    [AttributeGroup] INT             NULL,
    [SnapshotId]     INT             NULL,
    [CountryCode]    NVARCHAR (3)    NULL,
    [BalanceAccount] NVARCHAR (15)   NULL
);

