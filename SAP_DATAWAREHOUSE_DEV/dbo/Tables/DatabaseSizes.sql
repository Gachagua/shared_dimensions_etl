CREATE TABLE [dbo].[DatabaseSizes] (
    [Database_Name] NVARCHAR (50)  NULL,
    [log_size_mb]   DECIMAL (8, 2) NULL,
    [row_size_mb]   DECIMAL (8, 2) NULL,
    [total_size_mb] DECIMAL (8, 2) NULL,
    [total_size_gb] DECIMAL (8, 2) NULL
);

