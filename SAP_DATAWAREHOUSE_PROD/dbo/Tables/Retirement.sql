CREATE TABLE [dbo].[Retirement] (
    [ItemCode]              NVARCHAR (50)   NULL,
    [DocumentEntry]         INT             NULL,
    [ReferenceDate]         DATETIME        NULL,
    [PeriodCategory]        NVARCHAR (10)   NULL,
    [RetirementLocalAmount] NUMERIC (19, 6) NULL,
    [RetirementUSDAmount]   NUMERIC (19, 6) NULL,
    [JETransactionID]       INT             NULL,
    [CountryCode]           NVARCHAR (3)    NULL,
    [ReversalTransactionID] INT             NULL,
    [DocumentStatus]        VARCHAR (1)     NULL
);

