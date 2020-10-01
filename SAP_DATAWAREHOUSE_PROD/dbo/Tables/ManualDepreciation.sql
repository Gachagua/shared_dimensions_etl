CREATE TABLE [dbo].[ManualDepreciation] (
    [RowTotal]       NUMERIC (19, 6) NULL,
    [DocumentEntry]  INT             NULL,
    [ItemCode]       NVARCHAR (50)   NULL,
    [RowNumber]      INT             NULL,
    [CountryCode]    NVARCHAR (3)    NULL,
    [DocumentStatus] VARCHAR (1)     NULL
);

