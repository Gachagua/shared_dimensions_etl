CREATE TABLE [dbo].[Deliveries] (
    [U_WHR]           NVARCHAR (30)  NULL,
    [Comments]        NVARCHAR (254) NULL,
    [CountryCode]     NVARCHAR (3)   NULL,
    [U_Request_ID]    NVARCHAR (50)  NULL,
    [AttachmentEntry] INT            NULL,
    [DocumentEntry]   INT            NULL,
    [DocumentNumber]  INT            NULL,
    [Canceled]        VARCHAR (1)    NULL,
    [U_Requestor]     NVARCHAR (50)  NULL,
    [RowNumber]       INT            NULL,
    [U_WebPRID]       INT            NULL
);

