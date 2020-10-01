CREATE TABLE [dbo].[Docs_For_Approval] (
    [WtmCode]     INT           NULL,
    [DocEntry]    INT           NULL,
    [IsDraft]     VARCHAR (1)   NULL,
    [ObjType]     NVARCHAR (20) NULL,
    [CreateDate]  DATETIME      NULL,
    [WddCode]     INT           NULL,
    [CountryCode] NVARCHAR (3)  NULL
);

