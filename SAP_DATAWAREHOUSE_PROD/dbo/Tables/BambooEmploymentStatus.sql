CREATE TABLE [dbo].[BambooEmploymentStatus] (
    [BambooHrEmploymentStatusId] INT            NULL,
    [Date]                       NVARCHAR (MAX) NULL,
    [EmploymentStatus]           NVARCHAR (50)  NULL,
    [TerminationReasonId]        NVARCHAR (50)  NULL,
    [TerminationTypeId]          NVARCHAR (50)  NULL,
    [UserId]                     NVARCHAR (450) NULL,
    [terminationRehireId]        NVARCHAR (50)  NULL
);

