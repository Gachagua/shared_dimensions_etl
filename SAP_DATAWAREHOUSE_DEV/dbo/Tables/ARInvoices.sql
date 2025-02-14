﻿CREATE TABLE [dbo].[ARInvoices] (
    [Handwrtten]                      VARCHAR (1)     NULL,
    [Printed]                         VARCHAR (1)     NULL,
    [Address]                         NVARCHAR (254)  NULL,
    [Comments]                        NVARCHAR (254)  NULL,
    [UpdateDate]                      DATETIME        NULL,
    [CreateDate]                      DATETIME        NULL,
    [Weight]                          NUMERIC (19, 6) NULL,
    [Series]                          INT             NULL,
    [TaxDate]                         DATETIME        NULL,
    [DataSource]                      VARCHAR (1)     NULL,
    [Address2]                        NVARCHAR (254)  NULL,
    [ShipToCode]                      NVARCHAR (50)   NULL,
    [Max1099]                         NUMERIC (19, 6) NULL,
    [CEECFlag]                        VARCHAR (1)     NULL,
    [AssetDate]                       DATETIME        NULL,
    [U_TRSFR_LC_NO]                   INT             NULL,
    [ItemCode]                        NVARCHAR (50)   NULL,
    [Quantity]                        NUMERIC (19, 6) NULL,
    [Weight1]                         NUMERIC (19, 6) NULL,
    [Factor1]                         NUMERIC (19, 6) NULL,
    [Factor2]                         NUMERIC (19, 6) NULL,
    [Factor3]                         NUMERIC (19, 6) NULL,
    [Factor4]                         NUMERIC (19, 6) NULL,
    [StockSum]                        NUMERIC (19, 6) NULL,
    [UomEntry]                        INT             NULL,
    [UomCode]                         NVARCHAR (20)   NULL,
    [CountryCode]                     NVARCHAR (20)   NULL,
    [DocumentEntry]                   INT             NULL,
    [DocumentNumber]                  INT             NULL,
    [DocumentType]                    VARCHAR (1)     NULL,
    [Canceled]                        VARCHAR (1)     NULL,
    [DocumentStatus]                  VARCHAR (1)     NULL,
    [WarehouseStatus]                 VARCHAR (1)     NULL,
    [DocumentDate]                    DATETIME        NULL,
    [DocumentDueDate]                 DATETIME        NULL,
    [BusinessPartnerCode]             NVARCHAR (15)   NULL,
    [BusinessPartnerName]             NVARCHAR (100)  NULL,
    [BusinessPartnerReferenceNumber]  NVARCHAR (100)  NULL,
    [DiscountPercentage]              NUMERIC (19, 6) NULL,
    [TotalDiscount]                   NUMERIC (19, 6) NULL,
    [DocumentCurrency]                NVARCHAR (3)    NULL,
    [DocumentRate]                    NUMERIC (19, 6) NULL,
    [DocumentTotal]                   NUMERIC (19, 6) NULL,
    [DocumentTotalForeignCurrency]    NUMERIC (19, 6) NULL,
    [PaidForeignCurrency]             NUMERIC (19, 6) NULL,
    [GrossProfit]                     NUMERIC (19, 6) NULL,
    [GrossProfitForeignCurrency]      NUMERIC (19, 6) NULL,
    [Reference1]                      NVARCHAR (11)   NULL,
    [JournalRemarks]                  NVARCHAR (50)   NULL,
    [TransactionID]                   INT             NULL,
    [ReceiptNumber]                   INT             NULL,
    [GenerationTime]                  SMALLINT        NULL,
    [SalesEmployee]                   INT             NULL,
    [WarehouseUpdate]                 VARCHAR (1)     NULL,
    [ContactPerson]                   INT             NULL,
    [SystemPrice]                     NUMERIC (19, 6) NULL,
    [BaseCurrency]                    VARCHAR (1)     NULL,
    [TotalDiscountSystemCurrency]     NUMERIC (19, 6) NULL,
    [DocumentTotalSystemCurrency]     NUMERIC (19, 6) NULL,
    [PaidSystemCurrency]              NUMERIC (19, 6) NULL,
    [GrossProfitSystemCurrency]       NUMERIC (19, 6) NULL,
    [PostingPeriod]                   INT             NULL,
    [UserSignature]                   SMALLINT        NULL,
    [UserSignature2]                  SMALLINT        NULL,
    [DocumentDraftInternalID]         INT             NULL,
    [WorkStationID]                   INT             NULL,
    [LicensedDealerNumber]            NVARCHAR (32)   NULL,
    [ControlAccount]                  NVARCHAR (15)   NULL,
    [DownPaymentAmount]               NUMERIC (19, 6) NULL,
    [DownPaymentAmountSystemCurrency] NUMERIC (19, 6) NULL,
    [TotalPaidSum]                    NUMERIC (19, 6) NULL,
    [TotalPaidSumForeignCurrency]     NUMERIC (19, 6) NULL,
    [TotalPaidSumSystemCurrency]      NUMERIC (19, 6) NULL,
    [PayTo]                           NVARCHAR (50)   NULL,
    [ReserveInvoice]                  VARCHAR (1)     NULL,
    [VersionNumber]                   NVARCHAR (11)   NULL,
    [BusinessPartnerNameOverwritten]  VARCHAR (1)     NULL,
    [CreationTime]                    INT             NULL,
    [UpdateTime]                      INT             NULL,
    [RowNumber]                       INT             NULL,
    [TargetDocumentType]              INT             NULL,
    [TargetDocumentInternalID]        INT             NULL,
    [BaseDocumentReference]           NVARCHAR (16)   NULL,
    [BaseDocumentType]                INT             NULL,
    [BaseDocumentInternalID]          INT             NULL,
    [BaseRow]                         INT             NULL,
    [RowStatus]                       VARCHAR (1)     NULL,
    [Description]                     NVARCHAR (100)  NULL,
    [RowDeliveryDate]                 DATETIME        NULL,
    [RemainingOpenQuantity]           NUMERIC (19, 6) NULL,
    [PriceAfterDiscount]              NUMERIC (19, 6) NULL,
    [Currency]                        NVARCHAR (3)    NULL,
    [CurrencyRate]                    NUMERIC (19, 6) NULL,
    [RowTotal]                        NUMERIC (19, 6) NULL,
    [RowTotalForeignCurrency]         NUMERIC (19, 6) NULL,
    [OpenAmount]                      NUMERIC (19, 6) NULL,
    [OpenAmountForeignCurrency]       NUMERIC (19, 6) NULL,
    [WarehouseCode]                   NVARCHAR (8)    NULL,
    [AccountCode]                     NVARCHAR (15)   NULL,
    [GrossProfitBasePrice]            NUMERIC (19, 6) NULL,
    [UnitPrice]                       NUMERIC (19, 6) NULL,
    [CreditMemoAmount]                NUMERIC (19, 6) NULL,
    [InventoryUOM]                    VARCHAR (1)     NULL,
    [BaseBusinessPartnerCode]         NVARCHAR (15)   NULL,
    [RowTotalSystemCurrency]          NUMERIC (19, 6) NULL,
    [OpenAmountSystemCurrency]        NUMERIC (19, 6) NULL,
    [DistributionRule]                NVARCHAR (8)    NULL,
    [ProjectCode]                     NVARCHAR (20)   NULL,
    [TaxDefinition]                   NVARCHAR (8)    NULL,
    [GrossPrice]                      NUMERIC (19, 6) NULL,
    [PackingQuantity]                 NUMERIC (19, 6) NULL,
    [BaseDocumentNumber]              INT             NULL,
    [BusinessPartnerBaseDocument]     NVARCHAR (100)  NULL,
    [AdditionalIdentifier]            NVARCHAR (16)   NULL,
    [RowGrossProfit]                  NUMERIC (19, 6) NULL,
    [RowGrossProfitSystemCurrency]    NUMERIC (19, 6) NULL,
    [RowGrossProfitForeignCurrency]   NUMERIC (19, 6) NULL,
    [VisualOrder]                     INT             NULL,
    [ItemLastSalesPrice]              NUMERIC (19, 6) NULL,
    [OriginalItem]                    NVARCHAR (50)   NULL,
    [FreeText]                        NVARCHAR (100)  NULL,
    [BaseQuantity]                    NUMERIC (19, 6) NULL,
    [BaseOpenQuantity]                NUMERIC (19, 6) NULL,
    [WTaxLiable]                      VARCHAR (1)     NULL,
    [Unit]                            NVARCHAR (100)  NULL,
    [UOMValue]                        NUMERIC (19, 6) NULL,
    [ItemCost]                        NUMERIC (19, 6) NULL,
    [ConsumerSalesForecast]           VARCHAR (1)     NULL,
    [StockSumForeignCurrency]         NUMERIC (19, 6) NULL,
    [StockSumSystemCurrency]          NUMERIC (19, 6) NULL,
    [ShipToDescription]               NVARCHAR (254)  NULL,
    [TotalCalculationPrice]           VARCHAR (1)     NULL,
    [GrossTotal]                      NUMERIC (19, 6) NULL,
    [GrossTotalForeignCurrency]       NUMERIC (19, 6) NULL,
    [GrossTotalSystemCurrency]        NUMERIC (19, 6) NULL,
    [DistributeFreightCharges]        VARCHAR (1)     NULL,
    [DescriptionOverWritten]          VARCHAR (1)     NULL,
    [RemarksOverWritten]              VARCHAR (1)     NULL,
    [GrossProfitBaseMethod]           SMALLINT        NULL,
    [QuantityToShip]                  NUMERIC (19, 6) NULL,
    [DeliveredQuantity]               NUMERIC (19, 6) NULL,
    [OrderedQuantity]                 NUMERIC (19, 6) NULL,
    [COGSDistributionRule]            NVARCHAR (8)    NULL,
    [COFSAccountCode]                 NVARCHAR (15)   NULL,
    [ActualDeliveryDate]              DATETIME        NULL,
    [DepartmentCode]                  NVARCHAR (8)    NULL,
    [LocationCode]                    NVARCHAR (8)    NULL,
    [COGSDistributionRuleCode2]       NVARCHAR (8)    NULL,
    [COGSDistributionRuleCode3]       NVARCHAR (8)    NULL,
    [TotalCostOfGoodsSoldValue]       NUMERIC (19, 6) NULL,
    [TotalProfitBasePrice]            NUMERIC (19, 6) NULL,
    [UOMifBaseUnit]                   NVARCHAR (100)  NULL,
    [UOMValueIfBaseUnit]              NUMERIC (19, 6) NULL,
    [PriceSourceType]                 VARCHAR (1)     NULL,
    [VATGroupSource]                  VARCHAR (1)     NULL,
    [OpenQuantityforReturn]           NUMERIC (19, 6) NULL,
    [UOMEntryIfBaseUnit]              INT             NULL,
    [UOMCodeIfBaseUnit]               NVARCHAR (20)   NULL,
    [InventoryQuantity]               NUMERIC (19, 6) NULL,
    [OPenInventoryQuantity]           NUMERIC (19, 6) NULL,
    [ReferencedObjectType]            NVARCHAR (20)   NULL,
    [ReferencedDocumentNumber]        INT             NULL,
    [DocumentDateID]                  INT             NULL,
    [DocumentDueDateID]               INT             NULL,
    [UpdateDateID]                    INT             NULL,
    [CreateDateID]                    INT             NULL,
    [TaxDateID]                       INT             NULL,
    [AssetDateID]                     INT             NULL,
    [BusinessPartnerID]               INT             NULL,
    [CurrencyID]                      INT             NULL,
    [DepartmentID]                    INT             NULL,
    [LocationID]                      INT             NULL,
    [CountryID]                       INT             NULL,
    [ItemID]                          INT             NULL,
    [AttachmentEntry]                 INT             NULL,
    [Text]                            NVARCHAR (MAX)  NULL,
    [PaidToDate]                      NUMERIC (19, 6) NULL,
    [CreateTime]                      INT             NULL,
    [U_TRSR_Country]                  NVARCHAR (10)   NULL,
    [U_Season]                        NVARCHAR (10)   NULL,
    [DocumentSubmissionDate]          DATETIME        NULL
);

