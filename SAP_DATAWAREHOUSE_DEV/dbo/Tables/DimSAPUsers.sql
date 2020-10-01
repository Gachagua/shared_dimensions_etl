CREATE TABLE [dbo].[DimSAPUsers] (
    [UserCode]             NVARCHAR (25)  NULL,
    [UserName]             NVARCHAR (155) NULL,
    [SuperUser]            VARCHAR (1)    NULL,
    [Email]                NVARCHAR (100) NULL,
    [CountryCode]          NVARCHAR (50)  NULL,
    [UserSignature]        SMALLINT       NULL,
    [SAPUserID]            INT            IDENTITY (1, 1) NOT NULL,
    [UserID]               INT            NULL,
    [Locked]               VARCHAR (1)    NULL,
    [CreateDate]           DATETIME       NULL,
    [UpdateDate]           DATETIME       NULL,
    [ScreenLock]           SMALLINT       NULL,
    [FailedLog]            INT            NULL,
    [PasswordNeverExpires] VARCHAR (1)    NULL,
    [LastLogin]            DATETIME       NULL,
    [Groups]               INT            NULL
);


GO
CREATE COLUMNSTORE INDEX [_dta_index_DimSAPUsers_12_1174295243__col__]
    ON [dbo].[DimSAPUsers]([UserCode], [UserName], [SuperUser], [Email], [CountryCode], [UserSignature], [SAPUserID], [UserID]);


GO
CREATE STATISTICS [_dta_stat_1174295243_9_5_1_2]
    ON [dbo].[DimSAPUsers]([UserID], [CountryCode], [UserCode], [UserName]);


GO
CREATE STATISTICS [_dta_stat_1174295243_5_9_1]
    ON [dbo].[DimSAPUsers]([CountryCode], [UserID], [UserCode]);


GO
CREATE STATISTICS [_dta_stat_1174295243_2_9]
    ON [dbo].[DimSAPUsers]([UserName], [UserID]);

