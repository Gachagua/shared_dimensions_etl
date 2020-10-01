CREATE TABLE [dbo].[OIBQ] (
    [AbsEntry]    INT             NULL,
    [ItemCode]    NVARCHAR (50)   NULL,
    [BinAbs]      INT             NULL,
    [OnHandQty]   NUMERIC (19, 6) NULL,
    [WhsCode]     NVARCHAR (8)    NULL,
    [Freezed]     VARCHAR (1)     NULL,
    [FreezeDoc]   INT             NULL,
    [CountryCode] NVARCHAR (3)    NULL
);

