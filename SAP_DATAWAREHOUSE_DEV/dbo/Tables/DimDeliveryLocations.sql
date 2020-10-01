CREATE TABLE [dbo].[DimDeliveryLocations] (
    [DeliveryLocationId]      INT            NULL,
    [Active]                  BIT            NULL,
    [CountryId]               INT            NULL,
    [DeliveryLocationName]    NVARCHAR (MAX) NULL,
    [DestinationCountryId]    INT            NULL,
    [DefaultDeliveryLocation] BIT            NULL
);

