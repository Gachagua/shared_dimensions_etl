/*
22/10/2019 DK
	Added DocumentSubmissionDate
17/09/2019 DK
	Updated the SourcingTeam logic in the WebPR section
24/07/2019
	Added ItemName
	Updated Season pull
	Updated SourcingTeam clause
20/06/2019
	Updated CountryCode
	Added Season
	Added PR Doc Num
	Added WarehouseName and WarehouseID
*/
--use OAF_SAP_DATAWAREHOUSE;
CREATE view pro.v_PurchaseRequests as 

-- from SAP
select 
	CONCAT(PR.DocumentNumber,'_',PR.RowNumber+1) as [PurchaseRequestID],
	PR.DocumentNumber, 
	PR.RowNumber+1 as RowNumber,
	PR.DocumentEntry as BackendPurchaseRequestID,
	PR.CreateDate,
	PR.DocumentDate,
	PR.PurQuotationRequiredDate as [Desired Delivery Date],
	PR.DocumentSubmissionDate,
	Case when PR.countrycode = 'US' and PR.U_TRSR_Country = 'KENYA' then 'KE'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'BURUNDI' then 'BI'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'RWANDA' then 'RW'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'MALAWI' then 'MW'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'UGANDA' then 'UG'
	else PR.CountryCode end as [Country],
	PR.DepartmentCode,
	PR.LocationCode,
	PR.WarehouseName,
	PR.ItemCode,
	PR.ItemName,
	null as [Supplier/Vendor], 
	SAPUSER.UserName as DocumentCreator,
	CASE 
		WHEN PR.PurchaseRequestID is null then isnull(CountryPRApprover.[Name],PR.U_Approver) 
		Else 'No SAP Approver'
	END as Approver,
	CASE
		WHEN PR.PurchaseRequestID is null THEN isnull(GlobalPurchaser.[Name],PR.U_requestor)
		ELSE EMP.[FullName] 
	END as Requestor,
	null as Purchaser,
	PR.ItemID,
	PR.CurrencyID,
	PR.CountryID,
	PR.DepartmentID,
	PR.WarehouseID,
	PR.VendorID,
	PR.LineTotal as LineTotalLocal,
	PR.UnitPrice as PriceLocal,
	PR.TotalSumSystemCurrency as LineTotalUSD,
	PR.Currency,
	PR.Quantity,
	PR.ReceivedQuantity,
	PR.RemainingQuantity,
	PR.DocumentStatus [Document Status],
	PR.Canceled as Canceled,
	isnull(PR.U_season,PR.SapSeasonID) as [Season],
	PR.[Text],
	PR.[Description],
	PR.Comments as Comments,
	case 
		when PR.PurchaseRequestID is null then 'SAP'
		else 'Web' 
	end as [RequestMethod],
	case 
		when PR.U_season is not null then 'Global'
		when PR.SeasonName is not null then 'Global'
		when PR.CountryCode = 'US' then 'Global'
	 Else 'InCountry' end as SourcingTeam,
	'Purchase' as ServicedbyFlag,
	Item.ItmsGrpNam

From PurchaseRequests PR

	left join [dbo].[@OAF_Requestor] CountryPRApprover on 
		CountryPRApprover.Code =PR.U_Approver 
		and PR.CountryCode <> 'US'
	left join [dbo].[@OAF_Requestor] GlobalPurchaser on 
		GlobalPurchaser.Code =PR.U_Requestor 
		and PR.CountryCode = 'US'
	left join (SELECT Distinct SAPID, CountryCode, FullName FROM [$(OAF_HR_DATAWAREHOUSE)].dbo.Dimemployee) EMP on 
		PR.documentowner = EMP.SAPID 
		and PR.CountryCode=emp.CountryCode
	left join DimSAPUsers SAPUSER on 
		PR.UserSignature=SAPUSER.UserID and 
		PR.CountryCode=SAPUSER.CountryCode
	left join DimItem Item on PR.itemid = Item.ItemID and PR.CountryCode=Item.CountryCode

where pr.PurchaseRequestID is null 

union all

-- from web portal
select 
	CAST(PR.PurchaseRequestID as nvarchar(10)) as [PurchaseRequestID], 
	CAST(PR.PurchaseRequestID as nvarchar(10)) as DocumentNumber,
	null as RowNumber,
	null as BackendPurchaseRequestID,
	PR.CreateDate,
	PR.DocumentDate,
	PR.PurQuotationRequiredDate as [Desired Delivery Date],
	PR.DocumentSubmissionDate,
	Case when PR.countrycode = 'US' and PR.U_TRSR_Country = 'KENYA' then 'KE'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'BURUNDI' then 'BI'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'RWANDA' then 'RW'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'MALAWI' then 'MW'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when PR.countrycode = 'US' and PR.U_TRSR_Country = 'UGANDA' then 'UG'
	else PR.CountryCode end as [Country],
	PR.DepartmentCode,
	PR.LocationCode,
	PR.WarehouseName,
	PR.ItemCode,
	PR.ItemName,
	BP.BusinessPartnerName [Supplier/Vendor], 
	SAPUSER.UserName as DocumentCreator,
	PR.ApproverName as Approver,
	PR.UserName as Requestor,
	PR.Purchaser  as Purchaser,
	PR.ItemID,
	PR.CurrencyID,
	PR.CountryID,
	PR.DepartmentID,
	PR.WarehouseID,
	PR.VendorID,
	PR.LineTotal as LineTotalLocal,
	PR.UnitPrice as PriceLocal,
	PR.TotalSumSystemCurrency as LineTotalUSD,
	PR.Currency,
	PR.Quantity,
	PR.ReceivedQuantity,
	PR.RemainingQuantity,
	PR.StatusName [Document Status],
	null as Canceled,
	isnull(PR.U_season,PR.SapSeasonID) as [Season],
	null as [Text],
	null as [Description],
	PR.Comments as Comments,
	case 
		when PR.PurchaseRequestID is null then 'SAP'
		else 'Web' 
	end as [RequestMethod],
	case 
		when PR.U_season is not null then 'Global'
		when PR.SeasonName is not null then 'Global'
		when PR.CountryCode = 'US' then 'Global'
		when PR.PurchaseRequestType is null and PR.U_season is null and Pr.SeasonName is null then 'InCountry'
		Else PR.PurchaseRequestType 
	end as SourcingTeam,
	WebPR.ServicedbyFlag as ServicebyFlag,
	Item.ItmsGrpNam

From PurchaseRequests PR

	Left join PurchaseRequestPortal WebPR on 
		WebPR.PurchaseRequestID = PR.purchaserequestID 
	left join DimSAPUsers SAPUSER on 
		PR.UserSignature=SAPUSER.UserID and 
		PR.CountryCode=SAPUSER.CountryCode
	left join BusinessPartners BP on
		PR.VendorID = BP.WebVendorID
	left join DimItem Item on PR.itemid = Item.WebItemId and PR.CountryCode=Item.CountryCode
where pr.PurchaseRequestID is not null 


