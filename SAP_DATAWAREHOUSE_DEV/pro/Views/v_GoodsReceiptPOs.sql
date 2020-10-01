/*
updates 
- MW 2019-11-13 v5: added UoM (not updated yet, waiting for Addition of field to the warehouse)
- DK 2019-08-19 - Updated Date fields , Added LocationCode
- AV 2019-08-06 - removed filter usercode where clause because Log users now create GRPOs for sourcing orders.
- AV 2019-08-06 - added GRPO.[Truck Reg ID] & 	GRPO.[Truck Driver Contact],
- AV 2019-07-31 - added WarehouseID as Warehouse

- updated BaseDocumentType
- updated SourcingTeam
- added season
- updated BaseDocumentEntry to BaseDocRef
- Added WarehouseCode
- UpdatedCountry
- Added Desired Delivery Date


*/
--use OAF_SAP_DATAWAREHOUSE;
CREATE view pro.v_GoodsReceiptPOs as

select
	CONCAT(GRPO.DocumentNumber,'_',GRPO.RowNumber+1) as [GRPOID],
	GRPO.DocumentNumber,
	GRPO.RowNumber+1 as RowNumber,
	GRPO.DocumentEntry as [BackendGRPOID],
	GRPO.CreateDate,
	GRPO.DocumentDate,
	GRPO.DocumentSubmissionDate,
	GRPO.DeliveryDate,
	GRPO.PurQuotationRequiredDate as [Desired Delivery Date],
	Case when GRPO.countrycode = 'US' and GRPO.U_TRSR_Country = 'KENYA' then 'KE'
		when GRPO.countrycode = 'US' and GRPO.U_TRSR_Country = 'BURUNDI' then 'BI'
		when GRPO.countrycode = 'US' and GRPO.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when GRPO.countrycode = 'US' and GRPO.U_TRSR_Country = 'RWANDA' then 'RW'
		when GRPO.countrycode = 'US' and GRPO.U_TRSR_Country = 'MALAWI' then 'MW'
		when GRPO.countrycode = 'US' and GRPO.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when GRPO.countrycode = 'US' and GRPO.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when GRPO.countrycode = 'US' and GRPO.U_TRSR_Country = 'UGANDA' then 'UG'
	else GRPO.CountryCode end as [Database],
	GRPO.DepartmentCode,
	GRPO.LocationCode,
	GRPO.ItemCode,
	GRPO.BusinessPartnerName [Supplier/Vendor], 
	SAPUSER.UserName as DocumentCreator,
	CASE
		WHEN GRPO.u_webPRID is not null THEN WebPR.Approver
		Else ISNULL(CountryApprover.[Name],GRPO.U_InputsApprover) 
	END as Approver,
	GRPO.U_Requestor as Requestor,
	CASE
		WHEN GRPO.U_WebPRID is not null THEN WebPR.Purchaser
		WHEN GRPO.CountryCode = 'US' THEN isnull(GlobalPurchaser.[Name],GRPO.U_requestor)
		ELSE EMP.[FullName] 
	END as Purchaser,
	GRPO.U_WebPRID as WebPurchaseRequestID,
	GRPO.BaseDocumentReference as SAPBaseDocumentID,
	case 
		when GRPO.BaseDocumentType = -1 then Null
		else DimTransactionType.[Transaction]
	end as 'BaseDocumentType',

	GRPO.WarehouseID as Warehouse,
	GRPO.ItemID,
	GRPO.CurrencyID,
	GRPO.CountryID,
	GRPO.DepartmentID,
	GRPO.VendorID,
	GRPO.rowtotal as LineTotalLocal,
	GRPO.Price as PriceLocal,
	GRPO.TotalSumUSD as LineTotalUSD,
	GRPO.Currency,
	GRPO.Quantity,
	GRPO.DocumentStatus [Document Status],
	GRPO.Canceled,
	GRPO.U_Season [Season],
	GRPO.[Text],
	GRPO.[Description],
	GRPO.Comments,
	GRPO.[Truck Reg ID],
	GRPO.[Truck Driver Contact],
	GRPO.CustomerSatisfaction,
	case 
		when GRPO.u_webPRID is null then 'SAP'
		else 'Web' 
	end as [RequestMethod],
	case 
		when GRPO.countrycode = 'US' then 'Global' 
		when GRPO.U_Season is not null then 'Global' 
	Else 'InCountry' end as SourcingTeam,
	GRPO.UoMCode

From GoodsReceiptPO GRPO

	Left join PurchaseRequestPortal WebPR on 
		WebPR.PurchaseRequestID = GRPO.u_webPRID 
	left join [dbo].[@OAF_Requestor] CountryApprover on 
		CountryApprover.Code =grPO.U_InputsApprover 
		and GRPO.CountryCode <> 'US'
	left join [dbo].[@OAF_Requestor] GlobalPurchaser on 
		GlobalPurchaser.Code =GRPO.U_Requestor 
		and GRPO.CountryCode = 'US'
	left join (SELECT Distinct SapID, CountryCode, FullName FROM [$(OAF_HR_DATAWAREHOUSE)].dbo.Dimemployee) EMP on 
		GRPO.documentowner = EMP.sapid 
		and GRPO.CountryCode=emp.CountryCode
	left join DimSAPUsers SAPUSER on 
		GRPO.UserSignature=SAPUSER.UserID and 
		GRPO.CountryCode=SAPUSER.CountryCode
	left join DimTransactionType  on 
		GRPO.BaseDocumentType = DimTransactionType.transid

--Where (LEFT(SAPUSER.UserCode,3) in ('GLB','PRC'))
