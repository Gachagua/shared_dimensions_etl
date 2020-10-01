CREATE TABLE [dbo].[SummaryRosterData] (
    [Date_Updated]                      DATE            NULL,
    [Country]                           VARCHAR (80)    NULL,
    [CurrencyCode]                      VARCHAR (3)     NULL,
    [OAFOperationalYear]                INT             NULL,
    [TotalClients]                      INT             NULL,
    [TotalCredit]                       DECIMAL (18, 2) NULL,
    [TotalRepaid]                       DECIMAL (18, 2) NULL,
    [TotalRepaid_IncludingOverpayments] DECIMAL (18, 2) NULL
);

