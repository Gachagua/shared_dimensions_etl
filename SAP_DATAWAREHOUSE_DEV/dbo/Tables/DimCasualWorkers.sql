CREATE TABLE [dbo].[DimCasualWorkers] (
    [CasualWorkerId]       INT            NULL,
    [CasualName]           NVARCHAR (MAX) NULL,
    [CasualPhoneNumber]    NVARCHAR (MAX) NULL,
    [CasualWorkerStatusId] INT            NULL,
    [CountryId]            INT            NULL,
    [LocationId]           INT            NULL,
    [RelatedToFo]          BIT            NULL,
    [SiteId]               INT            NULL,
    [RegionId]             INT            NULL,
    [NationalIdNumber]     INT            NULL,
    [UserId]               NVARCHAR (450) NULL,
    [CasualMobileName]     NVARCHAR (MAX) NULL,
    [MobileCarrierId]      INT            NULL,
    [BirthDate]            DATETIME2 (7)  NULL,
    [Active]               BIT            NULL
);

