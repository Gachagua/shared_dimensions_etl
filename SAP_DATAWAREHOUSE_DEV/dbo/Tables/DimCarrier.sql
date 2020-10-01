CREATE TABLE [dbo].[DimCarrier] (
    [CarrierId]               INT            NOT NULL,
    [Active]                  BIT            NOT NULL,
    [CarrierName]             NVARCHAR (MAX) NULL,
    [CountryId]               INT            NOT NULL,
    [CarrierPaymentCodeValue] INT            NOT NULL
);

