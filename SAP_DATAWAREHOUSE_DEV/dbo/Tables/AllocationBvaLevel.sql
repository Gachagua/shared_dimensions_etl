CREATE TABLE [dbo].[AllocationBvaLevel] (
    [AcctCode]           FLOAT (53)     NULL,
    [AcctName]           NVARCHAR (255) NULL,
    [BVA_Level_2]        NVARCHAR (255) NULL,
    [BVA_Level_1]        NVARCHAR (255) NULL,
    [Overall_Category]   NVARCHAR (255) NULL,
    [Mapping_Year]       FLOAT (53)     NULL,
    [FatherNum]          VARCHAR (7)    NULL,
    [BVALevel2Order]     INT            NULL,
    [BVALevel1Order]     INT            NULL,
    [BVA_Level_1_Grants] VARCHAR (50)   NULL
);

