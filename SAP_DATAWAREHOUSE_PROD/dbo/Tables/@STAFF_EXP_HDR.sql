﻿CREATE TABLE [dbo].[@STAFF_EXP_HDR] (
    [DocEntry]      INT            NULL,
    [DocNum]        INT            NULL,
    [Period]        INT            NULL,
    [Instance]      SMALLINT       NULL,
    [Series]        INT            NULL,
    [Handwrtten]    VARCHAR (1)    NULL,
    [Canceled]      VARCHAR (1)    NULL,
    [Object]        NVARCHAR (20)  NULL,
    [LogInst]       INT            NULL,
    [UserSign]      INT            NULL,
    [Transfered]    VARCHAR (1)    NULL,
    [Status]        VARCHAR (1)    NULL,
    [CreateDate]    DATETIME       NULL,
    [CreateTime]    SMALLINT       NULL,
    [UpdateDate]    DATETIME       NULL,
    [UpdateTime]    SMALLINT       NULL,
    [DataSource]    VARCHAR (1)    NULL,
    [RequestStatus] VARCHAR (1)    NULL,
    [Creator]       NVARCHAR (8)   NULL,
    [Remark]        NVARCHAR (MAX) NULL,
    [U_REMARKS]     NVARCHAR (MAX) NULL,
    [U_DATE]        DATETIME       NULL,
    [U_BK]          NVARCHAR (30)  NULL,
    [U_TRSR_ALT]    NVARCHAR (35)  NULL,
    [U_AUTO_STS]    NVARCHAR (40)  NULL,
    [U_AUTO_BANK]   NVARCHAR (7)   NULL,
    [U_ATTCH1]      NVARCHAR (MAX) NULL,
    [U_ATTCH2]      NVARCHAR (MAX) NULL,
    [U_REQUEST_ID]  NVARCHAR (25)  NULL,
    [U_REQ_NAME]    NVARCHAR (50)  NULL,
    [U_Approver]    NVARCHAR (50)  NULL,
    [U_PaidDate]    DATETIME       NULL,
    [CountryCode]   NVARCHAR (20)  NULL
);

