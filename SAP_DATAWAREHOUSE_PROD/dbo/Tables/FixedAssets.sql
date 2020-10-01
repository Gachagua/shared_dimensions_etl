CREATE TABLE [dbo].[FixedAssets] (
    [TransactionID]      INT              NULL,
    [BaseReference]      NVARCHAR (11)    NULL,
    [AccountCode]        NVARCHAR (15)    NULL,
    [AssetClass]         NVARCHAR (20)    NULL,
    [AccountName]        NVARCHAR (100)   NULL,
    [DocumentDate]       DATETIME         NULL,
    [Period]             DATETIME         NULL,
    [Debit]              NUMERIC (19, 6)  NULL,
    [Credit]             NUMERIC (19, 6)  NULL,
    [SystemDebitAmount]  NUMERIC (38, 19) NULL,
    [SystemCreditAmount] NUMERIC (38, 19) NULL,
    [TransactionType]    NVARCHAR (20)    NULL,
    [ItemCode]           NVARCHAR (50)    NULL,
    [ItemName]           NVARCHAR (100)   NULL,
    [BalanceAccount]     NVARCHAR (15)    NULL,
    [Database]           NVARCHAR (20)    NULL,
    [RowDetails]         NVARCHAR (50)    NULL
);

