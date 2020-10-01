﻿CREATE TABLE [dbo].[InventoryTransfers] (
    [Comments]                NVARCHAR (254) NULL,
    [U_WHR]                   NVARCHAR (30)  NULL,
    [DocumentEntry]           INT            NULL,
    [AttachmentEntry]         INT            NULL,
    [CountryCode]             NVARCHAR (3)   NULL,
    [U_Request_ID]            NVARCHAR (50)  NULL,
    [CountryID]               INT            NULL,
    [DocumentNumber]          INT            NULL,
    [Canceled]                VARCHAR (1)    NULL,
    [CreateTime]              INT            NULL,
    [UpdateTime]              INT            NULL,
    [UserSignature]           SMALLINT       NULL,
    [UserSignature2]          SMALLINT       NULL,
    [DocumentDraftInternalID] INT            NULL,
    [DocumentDate]            DATETIME       NULL,
    [DocumentSubmissionDate]  DATETIME       NULL,
    [U_TRSR_Country]          NVARCHAR (10)  NULL,
    [U_Season]                NVARCHAR (50)  NULL,
    [UpdateDate]              DATETIME       NULL,
    [CreateDate]              DATETIME       NULL,
    [U_WebPRID]               INT            NULL,
    [U_Requestor]             NVARCHAR (50)  NULL,
    [RowNumber]               INT            NULL
);

