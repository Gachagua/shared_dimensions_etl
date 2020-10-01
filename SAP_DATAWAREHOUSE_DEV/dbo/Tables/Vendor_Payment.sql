CREATE TABLE [dbo].[Vendor_Payment] (
    [DocEntry]    INT             NOT NULL,
    [DocNum]      INT             NULL,
    [CANCELED]    CHAR (1)        NULL,
    [DocDate]     DATETIME        NULL,
    [UserSign]    SMALLINT        NULL,
    [OwnerCode]   INT             NULL,
    [TrsfrAcct]   NVARCHAR (15)   NULL,
    [TransId]     INT             NULL,
    [CardCode]    NVARCHAR (15)   NULL,
    [AppliedSys]  NUMERIC (19, 6) NULL,
    [InvType]     NVARCHAR (20)   NULL,
    [OcrCode2]    NVARCHAR (8)    NULL,
    [OcrCode3]    NVARCHAR (8)    NULL,
    [CountryCode] NVARCHAR (20)   NULL,
    [Countryid]   INT             NULL,
    [Vendor_Key]  INT             NULL,
    [Account_Key] INT             NULL,
    [DateKey]     INT             NULL
);

