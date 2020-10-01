CREATE TABLE [dbo].[Delivery] (
    [DocEntry]     INT            NULL,
    [AtcEntry]     INT            NULL,
    [U_WHR]        NVARCHAR (30)  NULL,
    [Comments]     NVARCHAR (254) NULL,
    [CountryCode]  NVARCHAR (3)   NULL,
    [U_Request_ID] NVARCHAR (50)  NULL,
    [canceled]     VARCHAR (1)    NULL
);

