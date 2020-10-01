CREATE TABLE [dbo].[Inventory_Log_Message] (
    [DocEntry]    INT             NULL,
    [LocCode]     NVARCHAR (8)    NULL,
    [Quantity]    NUMERIC (19, 6) NULL,
    [DocPrcCurr]  NVARCHAR (3)    NULL,
    [Price]       NUMERIC (19, 6) NULL,
    [DocPrcRate]  NUMERIC (19, 6) NULL,
    [ItemCode]    NVARCHAR (50)   NULL,
    [TransType]   INT             NULL,
    [DocLineNum]  INT             NULL,
    [MessageID]   INT             NULL,
    [DocDate]     DATETIME        NULL,
    [CreateDate]  DATETIME        NULL,
    [Base_Ref]    NVARCHAR (11)   NULL,
    [OcrCode2]    NVARCHAR (8)    NULL,
    [OcrCode3]    NVARCHAR (8)    NULL,
    [BaseType]    INT             NULL,
    [UserSign]    SMALLINT        NULL,
    [AccumType]   INT             NULL,
    [ActionType]  INT             NULL,
    [CountryCode] NVARCHAR (3)    NULL
);

