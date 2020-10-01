CREATE TABLE [dbo].[AllocationGrantMockUp] (
    [Grant]        NVARCHAR (200) NULL,
    [CountryCode]  NVARCHAR (3)   NULL,
    [BusinessUnit] NVARCHAR (100) NULL,
    [BoardLine]    NVARCHAR (100) NULL,
    [BvaLevel1]    NVARCHAR (100) NULL,
    [Deptcode]     NVARCHAR (3)   NULL,
    [AcctCode1]    INT            NULL,
    [AcctCode2]    INT            NULL,
    [AcctCode3]    INT            NULL,
    [AcctCode4]    INT            NULL,
    [AcctCode5]    INT            NULL,
    [AcctCode6]    INT            NULL,
    [AcctCode7]    INT            NULL,
    [AcctCode8]    INT            NULL,
    [Amount]       FLOAT (53)     NULL,
    [mapping_year] INT            NULL,
    [RestrictID]   BIGINT         IDENTITY (1, 1) NOT NULL,
    [Priority]     BIGINT         NULL,
    [StartDate]    DATE           NULL,
    [EndDate]      DATE           NULL
);

