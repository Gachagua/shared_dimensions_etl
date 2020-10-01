/*
updates 
04-09-2019: DK 
	-Updated warehouse type in where clause 


- Added LocationCode
- updated SourcingTeam
- updated country

*/
--use OAF_SAP_DATAWAREHOUSE;

CREATE view pro.v_GoodsIssues as 

select 
	Case When GI.DocumentNumber is null then NULL else CONCAT(GI.DocumentNumber,'_',GI.RowNumber+1) End as [GoodsIssueID],
	GI.DocumentNumber,
	GI.RowNumber+1 as RowNumber,
	GI.DocumentEntry as BackendGoodsIssueID,
	GI.CreateDate,
	GI.DocumentDate,
	Case when GI.countrycode = 'US' and GI.U_TRSR_Country = 'KENYA' then 'KE'
		when GI.countrycode = 'US' and GI.U_TRSR_Country = 'BURUNDI' then 'BI'
		when GI.countrycode = 'US' and GI.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when GI.countrycode = 'US' and GI.U_TRSR_Country = 'RWANDA' then 'RW'
		when GI.countrycode = 'US' and GI.U_TRSR_Country = 'MALAWI' then 'MW'
		when GI.countrycode = 'US' and GI.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when GI.countrycode = 'US' and GI.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when GI.countrycode = 'US' and GI.U_TRSR_Country = 'UGANDA' then 'UG'
	else GI.CountryCode end as [Database],
	GI.DepartmentCode,
	GI.LocationCode,
	GI.ItemCode,
	GI.WarehouseCode,
	DW.WarehouseName,
	WebPR.Approver,
	WebPR.Requester,
	WebPR.PurchaseRequestId as WebPurchaseRequestID,
	DW.DimWarehouseId as WarehouseID,
	GI.ItemID,
	GI.CurrencyID,
	GI.CountryID,
	GI.DepartmentID,
	GI.RowTotal as LineTotalLocal,
	GI.Price as PriceLocal,
	GI.RowTotalUSD as LineTotalUSD,
	GI.Currency,
	GI.Quantity,
	GI.UomCode as UnitOfMeasure,
	WebPR.Status as RequestStatus,	
	GI.RowStatus as [GoodsIssueStatus],
	GI.Canceled,
	GI.[Description],
	GI.Comments,
	case 
		when GI.u_webPRID is null then 'SAP'
		else 'Web' 
	end as [RequestMethod],
	case when GI.countrycode = 'US' then 'Global' Else 'InCountry' end as SourcingTeam

from GoodsIssues GI
left join PurchaseRequestPortal WebPR on GI.U_WebPRID = WebPR.GoodsIssueID 
left join DimSAPUsers SAPUSER on 
		GI.UserSignature=SAPUSER.UserID and 
		GI.CountryCode=SAPUSER.CountryCode

left join DimWarehouses DW on GI.WarehouseCode = DW.WarehouseCode

where DW.[Type] ='Procurement'

