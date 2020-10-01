CREATE TABLE [dbo].[DimMobilePayments] (
    [MobilePaymentId]   INT            NULL,
    [PhoneNumber]       NVARCHAR (MAX) NULL,
    [Recipient]         NVARCHAR (MAX) NULL,
    [ApplicationUserId] NVARCHAR (450) NULL,
    [Default]           BIT            NULL,
    [CarrierId]         INT            NULL,
    [Line]              SMALLINT       NULL,
    [EmployeeId]        INT            NULL,
    [Active]            BIT            NULL,
    [Validated]         BIT            NULL
);

