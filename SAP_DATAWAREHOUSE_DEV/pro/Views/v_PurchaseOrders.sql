/*
V4: 13-11-2019 MW - added UoM
V3: 19-08-2019 DK- Updated Dates 
- Added LocationCode
- updated BaseDocumentType
- Added DocumentNumber without Rownumber
- updated SourcingTeam
- added season
- updated BaseDocumentEntry to BaseDocRef
- Updated Country
- updated LineTotalLocal
- Added DesiredDeliveryDate
- Added ItemName

steps to completion
	1 - draft view for Purchase orders (done)
	2 - marika reviews and approves (in progress)
	3 - draft views for all other tables
	4 - create the data flow by selecting all from the views
*/

--use OAF_SAP_DATAWAREHOUSE ;
CREATE view pro.v_PurchaseOrders as

select  distinct
	CONCAT(PO.DocumentNumber,'_',PO.RowNumber+1) as [PurchaseOrderID],
	PO.DocumentNumber,
	PO.RowNumber+1 as RowNumber,
	PO.DocumentEntry as [BackendPurchaseOrderID] ,
	PO.CreateDate,
	PO.DocumentDate,
	PO.DocumentDueDate as OwnerShipDate,
	PO.U_U_DP_Date as DeliveryDate,
	PO.DocumentSubmissionDate,
	PO.PurQuotationRequiredDate as [Desired Delivery Date],
	Case when PO.countrycode = 'US' and PO.U_TRSR_Country = 'KENYA' then 'KE'
		when PO.countrycode = 'US' and PO.U_TRSR_Country = 'BURUNDI' then 'BI'
		when PO.countrycode = 'US' and PO.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when PO.countrycode = 'US' and PO.U_TRSR_Country = 'RWANDA' then 'RW'
		when PO.countrycode = 'US' and PO.U_TRSR_Country = 'MALAWI' then 'MW'
		when PO.countrycode = 'US' and PO.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when PO.countrycode = 'US' and PO.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when PO.countrycode = 'US' and PO.U_TRSR_Country = 'UGANDA' then 'UG'
	else PO.CountryCode end as [Database],
	PO.DepartmentCode,
	PO.LocationCode,
	PO.ItemCode,
	PO.ItemName,
	PO.BusinessPartnerName as [Supplier/Vendor],
	SAPUSER.Username as DocumentCreator,
	CASE
		WHEN u_webPRID is not null THEN WebPR.Approver
		ELSE ISNULL(CountryApprover.[Name],PO.U_Approver) 
	END as Approver,
	WebPR.Requester,
	CASE
		WHEN u_webPRID is not null THEN WebPR.Purchaser
		WHEN PO.CountryCode = 'US' THEN isnull(GlobalPurchaser.[Name],PO.U_requestor)
		ELSE EMP.[FullName] 
	END as Purchaser,
	PO.u_inputsapprover as GlobalSourcingApprover,
	PO.U_WebPRID as WebPurchaseRequestID,
	PO.BaseDocumentReference as SAPBaseDocumentID, 
	case 
		when PO.BaseDocumentType =-1 then Null 
		else DimTransactionType.[Transaction]
	end as 'BaseDocumentType',
	PO.WarehouseCode as WarehouseID,
	PO.ItemID,
	PO.CurrencyID,
	PO.CountryID,
	PO.DepartmentID,
	PO.VendorID,
	case 
		when PO.CountryCode = 'US' and PO.Currency<>'USD'  then PO.RowTotalForeignCurrency 
	else PO.RowTotal end as LineTotalLocal, --for some cases, the rowtotalfrgn is not filled in the us DB
	PO.Price as PriceLocal,
	PO.RowTotalUSD as LineTotalUSD,
	PO.Currency,
	PO.Quantity,
	PO.DocumentStatus,
	PO.Canceled,
	PO.[Text],
	PO.[Description],
	PO.Comments,
	case 
		when PO.u_webPRID is null then 'SAP' 
		else 'Web' 
	end as [RequestMethod],
	case 
		when PO.countrycode = 'US' then 'Global'
		when po.U_Season is not null then 'Global'  
	Else 'InCountry' end as SourcingTeam,
	PO.U_Season as Season,
	PO.UoMCode as UoM

	
from purchaseorders PO 
	left join DimTransactionType  on 
		PO.BaseDocumentType = DimTransactionType.transid
	left join [dbo].[@OAF_Requestor] CountryApprover on 
		CountryApprover.Code =PO.U_Approver 
		and PO.CountryCode <> 'US'
	left join [dbo].[@OAF_Requestor] GlobalPurchaser on 
		GlobalPurchaser.Code =PO.U_Requestor 
		and PO.CountryCode = 'US'
	left join purchaserequestportal WebPR on 
		PO.u_webprid = WebPR.purchaserequestid
	left join (SELECT Distinct SapID, CountryCode, FullName FROM [$(OAF_HR_DATAWAREHOUSE)].dbo.Dimemployee) EMP on 
		PO.documentowner = EMP.sapid 
		and PO.CountryCode=emp.CountryCode
	left join DimSAPUsers SAPUSER on 
		PO.UserSignature=SAPUSER.UserID and 
		po.CountryCode=SAPUSER.CountryCode

		
/*
- Pre-WP (might have to sort this out for others):
	- Country sourching
		- Purcharser: JOIN oaf_hr_datawarehouse.dbo.dimemployee on PO.DocumentOwner = DimEmployee.SapID and CountryCode
		- Requester: 
		- Department Approver: JOIN OAF_SAP_DATAWAREHOUSE.dbo.[@oaf_requestor] on PO.U_Approver = [@oaf_requestor].Code
	- Global sourcing
		- Purchaser: JOIN OAF_SAP_DATAWAREHOUSE.dbo.[@oaf_requestor] on PO.U_Requestor = [@oaf_requestor].Code
		- Requestor: 
		- Department Approver:
- Post-WP (all documents):
	- Requestor: U_Reqestor / or PRP
	- All others: Join PurchaseRequestPortal on PuchaseOrders.U_WebPRID = PurchaseRequestPortal.PurchaseRequestID
*/

--select  RowTotalForeignCurrency, Price, UnitPrice, RowTotal, RowTotalUSD,* from PurchaseOrders
--select top 5 * from PurchaseRequests where PurchaseRequestID=31784
--select * from PurchaseOrders where documentnumber =20000238