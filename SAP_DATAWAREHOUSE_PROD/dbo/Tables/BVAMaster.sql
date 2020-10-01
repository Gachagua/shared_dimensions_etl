CREATE TABLE [dbo].[BVAMaster] (
    [bva_section]              VARCHAR (21)     NULL,
    [Date]                     DATETIME         NULL,
    [Year]                     INT              NULL,
    [Month]                    INT              NULL,
    [Database]                 NVARCHAR (20)    NULL,
    [Value Type]               VARCHAR (6)      NULL,
    [Account]                  NVARCHAR (15)    NULL,
    [Account Name]             NVARCHAR (255)   NULL,
    [BVALevel1]                NVARCHAR (255)   NULL,
    [BVALevel2]                NVARCHAR (255)   NULL,
    [Department]               NVARCHAR (10)    NULL,
    [Budget Balance Local]     NUMERIC (38, 16) NULL,
    [Actual Balance Local]     NUMERIC (20, 6)  NULL,
    [Budget Balance USD]       NUMERIC (38, 16) NULL,
    [Actual Balance USD]       NUMERIC (20, 6)  NULL,
    [Projection Balance Local] NUMERIC (38, 16) NULL,
    [Projection Balance USD]   NUMERIC (38, 16) NULL,
    [BVALevel1Order]           INT              NULL,
    [BVALevel2Order]           INT              NULL,
    [Board_Line_Order]         INT              NULL,
    [Dept Orig]                NVARCHAR (255)   NULL,
    [Dept Allocated]           NVARCHAR (255)   NULL,
    [Overall_Category]         NVARCHAR (255)   NULL,
    [Boardline]                NVARCHAR (255)   NULL,
    [Business_Unit]            NVARCHAR (255)   NULL,
    [Country]                  NVARCHAR (MAX)   NULL,
    [Department_Type]          NVARCHAR (255)   NULL,
    [JE Num]                   INT              NULL,
    [Doc Num]                  NVARCHAR (11)    NULL,
    [Create Date]              DATETIME         NULL,
    [Tx Status]                VARCHAR (15)     NULL,
    [Transaction_Type]         NVARCHAR (100)   NULL,
    [CostInitiative]           NVARCHAR (255)   NULL,
    [Books Closed]             VARCHAR (7)      NULL,
    [User]                     NVARCHAR (155)   NULL,
    [Remarks]                  NVARCHAR (MAX)   NULL,
    [requestor]                NVARCHAR (100)   NULL,
    [approver]                 NVARCHAR (50)    NULL,
    [Location]                 NVARCHAR (8)     NULL,
    [version]                  INT              NULL,
    [DeptOrigCode]             NVARCHAR (10)    NULL,
    [WebRequester]             NVARCHAR (MAX)   NULL,
    [WebApprover]              NVARCHAR (MAX)   NULL,
    [WebDescription]           NVARCHAR (MAX)   NULL,
    [ProjectCode]              NVARCHAR (20)    NULL,
    [ProjectName]              NVARCHAR (100)   NULL,
    [Line_ID]                  INT              NULL,
    [BVA_Level_1_Grants]       VARCHAR (50)     NULL
);


GO
CREATE NONCLUSTERED INDEX [BVAMaster_IDX1]
    ON [dbo].[BVAMaster]([Value Type] ASC)
    INCLUDE([Date], [Database], [Actual Balance Local], [Actual Balance USD], [JE Num], [DeptOrigCode], [Line_ID]);


GO
CREATE NONCLUSTERED INDEX [IDX_BVA_DATE]
    ON [dbo].[BVAMaster]([Date] ASC, [Year] ASC)
    INCLUDE([Actual Balance USD]);

