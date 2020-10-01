CREATE TABLE [dbo].[Attachments] (
    [AbsoluteEntry] INT            NULL,
    [RowNumber]     INT            NULL,
    [SourcePath]    NVARCHAR (MAX) NULL,
    [TargetPath]    NVARCHAR (MAX) NULL,
    [FileName]      NVARCHAR (254) NULL,
    [FileExtension] NVARCHAR (8)   NULL,
    [Date]          DATETIME       NULL,
    [UserID]        INT            NULL,
    [Copied]        VARCHAR (1)    NULL,
    [OverrideFile]  VARCHAR (1)    NULL,
    [CountryCode]   NVARCHAR (20)  NULL
);


GO
CREATE NONCLUSTERED INDEX [Attch_IDX]
    ON [dbo].[Attachments]([RowNumber] ASC)
    INCLUDE([AbsoluteEntry], [FileName], [FileExtension], [CountryCode]);


GO
CREATE NONCLUSTERED INDEX [attch_IDX2]
    ON [dbo].[Attachments]([RowNumber] ASC, [CountryCode] ASC)
    INCLUDE([AbsoluteEntry], [FileName], [FileExtension]);


GO
CREATE NONCLUSTERED INDEX [ATTCH_IDX3]
    ON [dbo].[Attachments]([RowNumber] ASC)
    INCLUDE([AbsoluteEntry], [FileName], [FileExtension], [CountryCode]);


GO
CREATE NONCLUSTERED INDEX [attch_idx4]
    ON [dbo].[Attachments]([AbsoluteEntry] ASC, [RowNumber] ASC, [CountryCode] ASC)
    INCLUDE([FileName], [FileExtension]);

