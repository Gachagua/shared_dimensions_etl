CREATE TABLE [dbo].[BinTransactionLogs] (
    [Quantity]                 NUMERIC (19, 6) NULL,
    [MessageID]                INT             NULL,
    [CountryCode]              NVARCHAR (50)   NULL,
    [InternalNumber]           INT             NULL,
    [BinInternalNumber]        INT             NULL,
    [MasterDataInternalNumber] INT             NULL,
    [LogInternalID]            INT             NULL
);

