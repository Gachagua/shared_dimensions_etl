CREATE TABLE [dbo].[DimVendor] (
    [Vendor_Key]  INT            IDENTITY (1, 1) NOT NULL,
    [VendorID]    NVARCHAR (15)  NULL,
    [VendorName]  NVARCHAR (100) NULL,
    [VendorGroup] SMALLINT       NULL,
    [GroupName]   VARCHAR (19)   NOT NULL,
    [Address]     NVARCHAR (100) NULL,
    [Phone]       NVARCHAR (20)  NULL,
    [Status]      VARCHAR (8)    NULL,
    [CountryCode] NVARCHAR (20)  NULL,
    [CountryName] NVARCHAR (50)  NULL,
    [U_Approval]  NVARCHAR (15)  NULL,
    CONSTRAINT [PK_DimVendor] PRIMARY KEY CLUSTERED ([Vendor_Key] ASC)
);

