/*
V19 18/11/2019 DK 
	Updated Season Logic to include SAPSeasonID
V18 03/10/2018 DK: 
	Updated AP RowTotal to RowTotalLocal
	Updated Sourcing Team Logic
V17 13/08/2019 DK:
	Filtered out Canceled POs in the Complete chain, Web portal origin section
V16 20/06/2019 DK: 
	Updated Purchaser Logic to the SAP origin chain 
	Updated Countrycode pull in SAP Origin section
	updated Requestor in SAP Origin section
	Removed UserCode Line in the Where clause
	updated Sourcing team in in SAP Origin section
	Added Season
V15 18/06/2019 DK:
	Updated document joins from BaseDocumentReference to BaseDocumentEntry 
V14 14/05/2019 MW:
	Added field for Incountry vs Inputs
V13 25/01/2019 DK:
	Edited to pull from new tables after deletion of old tables
V11:
	Reordered status case for web purchases
V10:
	Updated OPOR, POR1 to PurchaseOrders
	Updated OUSR to pull from DimSAPUsers
	Updated PDN1, OPDN to pull from GoodsReciept
	Updated OIGE IGE1 to pull from GoodsIssues
V8:
	Updated PurchaseRequests - POR1 join to use updated fields
V7:
	Slight updated of ordering of case statements for web origin purchases
V6:
	Joined SAP Origin to AllocationProReqLeadTime after updating Lead time in AllocationProReqLeadTime
V5:
	Updated OHEM to pull from HR database
V4:
	Corrected PO section (pulled old section from version 1
	Added warehouse name to Complete, Issued section (other sections are null)
V3:
	when a store request has the status "ready for pick up" it is now considered undelivered, not delivered
V2: 
	added section for requests serviced from stock
	removed the DimSalesEmployees, OHEM join for portal origin requests
*/

CREATE VIEW pro.v_KPIs AS

--Procurement Order Tracker
--USE OAF_SAP_DATAWAREHOUSE;

------------ Complete chain, SAP origin ---------matching

Select distinct
'Complete, SAP' as chunk
,Case when PR.countrycode = 'US' and PR.U_TRSR_Country = 'KENYA' then 'KE'
when PR.countrycode = 'US' and PR.U_TRSR_Country = 'BURUNDI' then 'BI'
when PR.countrycode = 'US' and PR.U_TRSR_Country = 'TANZANIA' then 'TZ'
when PR.countrycode = 'US' and PR.U_TRSR_Country = 'RWANDA' then 'RW'
when PR.countrycode = 'US' and PR.U_TRSR_Country = 'MALAWI' then 'MW'
when PR.countrycode = 'US' and PR.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
when PR.countrycode = 'US' and PR.U_TRSR_Country = 'ZAMBIA' then 'ZA'
when PR.countrycode = 'US' and PR.U_TRSR_Country = 'UGANDA' then 'UG'
else PR.CountryCode end as countrycode
,PRLT.MinQty
,PRLT.MaxQty
,PRLT.LeadTime
,CASE 
		When isnull(PRLT.LeadTime,'') = '' then '0 - Unknown'
		WHEN PRLT.LeadTime <= 14 THEN '1 - Easy'
		WHEN PRLT.LeadTime = 21 THEN '2 - Medium'
		WHEN PRLT.LeadTime = 28 THEN '2 - Medium'
		WHEN PRLT.LeadTime = 35 THEN '3 - Hard'
		WHEN PRLT.LeadTime = 42 THEN '3 - Hard'
		WHEN PRLT.LeadTime = 56 THEN '3 - Hard'
		WHEN PRLT.LeadTime > 56 THEN '4 - Very hard'
		ELSE 'Other' END as Difficulty
,PR.DocumentDate as [Doc Date]
,ISNULL(OUSR.UserName,OUSR_R.UserName) as [User]
----PR------------
,CASE 
	WHEN PR.RowStatus='O' and isnull(PO.Quantity,0) = 0 then '1 - Not yet ordered'
	WHEN PR.RowStatus='C' and isnull(PO.Quantity,0) = 0 then '0 - Closed without order'
	WHEN PR.RowStatus='C' and PO.CANCELED = 'Y' then '0 - Closed without order'
	WHEN coalesce(GR.Quantity,PCH1.Quantity,0) = 0 and PO.RowStatus = 'C' then '3 - Closed without delivery'
	WHEN PR.Quantity > PO.Quantity and PO.Quantity <> 0 and coalesce(GR.Quantity,PCH1.Quantity,0) = 0 then '2 - Partially ordered'
	WHEN PO.Quantity >= PR.Quantity and coalesce(GR.Quantity,PCH1.Quantity,0) = 0 then '4 - Ordered but not yet delivered'
	WHEN PO.Quantity <> 0 and IsNull(GR.Quantity,PCH1.Quantity) < PO.Quantity then '5 - Partially delivered'
	WHEN coalesce(GR.Quantity,PCH1.Quantity,0) >= PR.Quantity then '6 - Full request delivered'
	WHEN coalesce(GR.Quantity,PCH1.Quantity,0) >= PO.Quantity then '7 - Full order delivered (less than requested)'
	ELSE 'Other' END as [Doc Status]
,CONCAT(PR.DocumentNumber,'_',PR.RowNumber+1) as [PR #]
,PR.DocumentDate [PR Doc Date]
,PR.CreateDate [PR Create Date]
,PR.Canceled as [PR Canceled?]
,PR.RowStatus as [PR Line Status]
,null as [Web Status]
,PR.[username] as [Requester]
,CASE
		WHEN PR.PurchaseRequestID is not null THEN PR.ApproverName
		ELSE ISNULL(CountryApprover.[Name],PR.U_Approver) 
	END as [Approver]
,PR.DepartmentCode as [Department]
,I.ItmsGrpNam as [Category]
,I.ItmsGrpCod
,PR.Description as [Item/Service]
,PR.Text  as [Notes/Specifications]
,PR.UOMCode as [UoM]
,PR.Quantity as [Quantity Requested]
,PR.PurQuotationRequiredDate as [Desired Delivery Date]
----PO---------------------------
,Case when PO.DocumentNumber is null then Null
	Else Concat(PO.DocumentNumber,'_',PO.RowNumber+1) end as [PO #]
,Case when PO.BaseDocumentType = '1470000113' then 'Purchase Request' else null end [PO Source Document]
,PO.BaseDocumentType as [PO Source Doc Num]
,PO.DocumentDate as [PO Date]
,PO.CreateDate as [PO Create Date]
,PO.BusinessPartnerName as [Vendor]
,PO.CANCELED as [PO Canceled?]
,PO.RowStatus as [PO Line Status]
,PO.Quantity as [Quantity]
,COALESCE(GR.Price,PCH1.Price,PO.Price) as [Unit Cost]	-- need this
,convert(money, COALESCE(GR.RowTotal, PCH1.RowTotalLocal, PO.RowTotal)) as [Total Cost]
,convert(money, COALESCE(GR.TotalSumUSD, PCH1.RowTotalUSD, PO.RowTotalUSD)) as [Total Cost USD]
,COALESCE(GR.Currency, PCH1.Currency, PO.Currency) as [Currency]
,Case when PO.TargetType = 20 then 'GRPO'-- need this
	when PO.TargetType = 18 then 'A/P Invoice'
	when PO.TargetType = -1 then 'None'
	When PO.TargetType is Null then NULL
	Else 'Other' end as [Target Document]
,CASE 
	When PR.PurchaseRequestID is not null then PR.Purchaser
	When PO.SalesEmployeeCode <> -1 then DimSalesEmployees.SalesEmployeeName
	WHEN PO.CountryCode = 'US' THEN isnull(GlobalPurchaser.[Name],PO.U_requestor) -- added this logic from our recent findings
	Else ISNULL(CONCAT(OHEM.firstName,' ',OHEM.Lastname),'Unassigned') end as [Purchaser]
----GRPO/AP-----------------
,Case when GR.DocumentNumber is null and PCH1.DocumentNumber is null then Null
	When PCH1.DocumentNumber is not null then 'A/P Invoice'
	When GR.DocumentNumber is not null then 'GRPO'
	Else 'Other' end as [Receiving Document]
,Case When GR.DocumentNumber is null and PCH1.DocumentNumber is null then NULL
	when GR.DocumentNumber is null then CONCAT(PCH1.DocumentNumber,'_',PCH1.RowNumber+1)
	when PCH1.DocumentNumber is null then CONCAT(GR.DocumentNumber,'_',GR.RowNumber+1) End as [GRPO #]
,Case when Isnull(GR.BaseDocumentType,PCH1.BaseDocumentType) = 22 then 'Purchase Order' else null end as [GRPO Source Document]
,Isnull(GR.BaseDocumentEntry,PCH1.BaseDocumentEntry) as [GRPO Source Doc Num]
,ISNULL(GR.DocumentDate,PCH1.DocumentDate) [GRPO Date]
,IsNull(GR.CANCELED,PCH1.Canceled) as [GRPO Canceled?]
,IsNull(GR.RowStatus,PCH1.RowStatus) as [GRPO Line Status]
,IsNull(GR.Quantity,PCH1.Quantity) as [Quantity Delivered to Date]
,IsNull(GR.CustomerSatisfaction,PCH1.U_CusotmerSat) as [Customer Satisfaction]
,null[WarehouseName]
,case 
	when PR.U_season is not null then 'Global'
	when PR.SeasonName is not null then 'Global'
	when PR.CountryCode = 'US' then 'Global'
	when PR.PurchaseRequestType is null and PR.U_season is null and Pr.SeasonName is null then 'InCountry'
	Else PR.PurchaseRequestType end as SourcingTeam
,case 
		when PR.U_season is not null then PR.U_Season
		when PR.SeasonName is not null then PR.SeasonName
		when PR.sapseasonid is not null then Season.SeasonName
		else null
	end as Season
,null as FirstApproval


from PurchaseRequests PR

Left join DimItem I on PR.ItemID = I.ItemID

Left join PurchaseOrders as PO on PR.DocumentEntry = PO.BaseDocumentEntry 
	and PR.RowNumber = PO.BaseRow 
	and PO.BaseDocumentType = '1470000113'
	and PO.Canceled = 'N'
	and PR.countrycode = PO.countrycode

Left join [$(OAF_HR_DATAWAREHOUSE)].dbo.OHEM as OHEM on PO.DocumentOwner = OHEM.empID and PO.countrycode = OHEM.Countrycode --Purchaser

Left Join DimSalesEmployees  on PO.SalesEmployeeCode = DimSalesEmployees.SalesEmployeeCode and PO.countrycode = DimSalesEmployees.countrycode -- Employee ID please add

Left join GoodsReceiptPO as GR on PO.DocumentEntry = GR.BaseDocumentEntry 
	and PO.RowNumber = GR.BaseDocumentRow 
	and GR.BaseDocumentType = 22 
	and GR.Canceled = 'N' 
	and PO.countrycode = GR.countrycode

Left Join APInvoices as PCH1 on PO.DocumentEntry = PCH1.BaseDocumentEntry 
	and PO.RowNumber = PCH1.BaseRow 
	and PCH1.BaseDocumentType = 22 
	and PCH1.canceled = 'N' --- AP Rows
	and PO.countrycode = PCH1.countrycode

LEFT jOIN DimSAPUsers as OUSR ON OUSR.[UserID] = PO.USerSignature and OUSR.countrycode = PO.countrycode  --PO creator 

LEFT join DimSAPUsers as OUSR_R ON OUSR_R.[UserID] = PR.[UserSignature] and OUSR_R.countrycode = PR.countrycode  --PR creator 

left join AllocationProReqLeadTime as PRLT 
	ON PRLT.ItmsGrpCod = I.ItmsGrpCod
	AND PR.Quantity between PRLT.MinQty and PRLT.MaxQty
	and PR.countrycode = PRLT.CountryCode

left join [dbo].[@OAF_Requestor] GlobalPurchaser on 
	GlobalPurchaser.Code =PO.U_Requestor 
	and PO.CountryCode = 'US'
	
left join [dbo].[@OAF_Requestor] CountryApprover on 
	CountryApprover.Code =PO.U_Approver 
	and PO.CountryCode <> 'US'
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimSeasons Season on pr.sapseasonid= season.sapseasonid and pr.countrycode= season.countrycode

where 
	PR.Canceled = 'N'
	and PR.DocumentEntry is not null -- from non-web system

union all

------------ Complete chain, Web portal origin, issued ---------matching

Select
	'web, issued' as chunk
	,PR.countrycode
	,PRLT.MinQty
	,PRLT.MaxQty
	,PRLT.LeadTime
,CASE 
		When isnull(PRLT.LeadTime,'') = '' then '0 - Unknown'
		WHEN PRLT.LeadTime <= 14 THEN '1 - Easy'
		WHEN PRLT.LeadTime = 21 THEN '2 - Medium'
		WHEN PRLT.LeadTime = 28 THEN '2 - Medium'
		WHEN PRLT.LeadTime = 35 THEN '3 - Hard'
		WHEN PRLT.LeadTime = 42 THEN '3 - Hard'
		WHEN PRLT.LeadTime = 56 THEN '3 - Hard'
		WHEN PRLT.LeadTime > 56 THEN '4 - Very hard'
		ELSE 'Other' END as Difficulty
	,PR.DocumentDate as [Doc Date]
	,OUSR.UserName as [User]
	----PR------------
	,CASE 
		WHEN StatusName in ('Rejected','CANCELED','SAP Cancelled') then '0 - Closed without order'
		WHEN StatusName = 'PO Created' then '4 - Ordered but not yet delivered'
		WHEN StatusName in ('Partially Issued','SAP Partially Received','Ready for Pickup') then '5 - Partially delivered'
		WHEN StatusName in ('Received','Issued','SAP Received') then '6 - Full request delivered'
		WHEN StatusName is not null then '1 - Not yet ordered'
		WHEN GoodsIssues.RowStatus = 'C' then '3 - Closed without delivery'
		ELSE 'Other' END as [Doc Status]
	,CAST(PR.PurchaseRequestID as varchar(10)) as [PR #]
	,PR.DocumentDate [PR Doc Date]
	,PR.CreateDate [PR Create Date]
	,null as [PR Canceled?]
	,null as [PR Line Status]
	,PR.StatusName as [Web Status]
	,PR.UserName as [Requester]
	,PR.ApproverName as [Approver]
	,PR.DepartmentCode as [Department]
	,I.ItmsGrpNam as [Category]
	,I.ItmsGrpCod
	,I.ItemName as [Item/Service]
	,PR.Comments  as [Notes/Specifications]
	,I.InvntryUom as [UoM]
	,PR.Quantity as [Quantity Requested]
	,PR.PurQuotationRequiredDate as [Desired Delivery Date]
	----PO---------------------------
	,null [PO #]
	,null [PO Source Document]
	,null as [PO Source Doc Num]
	,null as [PO Date]
	,null as [PO Create Date]
	,null as [Vendor]
	,null as [PO Canceled?]
	,null as [PO Line Status]
	,GoodsIssues.Quantity as [Quantity]
	,GoodsIssues.Price as [Unit Cost]	-- need this
	,convert(money, GoodsIssues.RowTotal) as [Total Cost]
	,convert(money, GoodsIssues.RowTotalUSD) as [Total Cost USD] ------
	,GoodsIssues.Currency as [Currency]
	,null as [Target Document]
	,DimWarehouses.WarehouseName as Purchaser
	----GRPO/AP-----------------
	,Case when GoodsIssues.DocumentNumber is not null then 'Goods Issue' Else null end as [Receiving Document]
	,Case When GoodsIssues.DocumentNumber is null then NULL else CONCAT(GoodsIssues.DocumentNumber,'_',GoodsIssues.RowNumber+1) End as [GRPO #]
	,null as [GRPO Source Document]
	,null as [GRPO Source Doc Num]
	,GoodsIssues.DocumentDate [GRPO Date]
	,GoodsIssues.CANCELED as [GRPO Canceled?]
	,GoodsIssues.RowStatus as [GRPO Line Status]
	,GoodsIssues.Quantity as [Quantity Delivered to Date]
	,GoodsIssues.U_CustSat as [Customer Satisfaction]
	,DimWarehouses.WarehouseName
	,case 
		when PR.U_season is not null then 'Global'
		when PR.SeasonName is not null then 'Global'
		when PR.CountryCode = 'US' then 'Global'
		when PR.PurchaseRequestType is null and PR.U_season is null and Pr.SeasonName is null then 'InCountry'
		Else PR.PurchaseRequestType 
	end as SourcingTeam
	,case 
		when PR.U_season is not null then PR.U_Season
		when PR.SeasonName is not null then PR.SeasonName
		when PR.sapseasonid is not null then Season.SeasonName
		else null
	end as Season
	,(select min(a.Transdate) from WebPortalAudit a where a.PurchaseRequestId = PR.purchaserequestid and a.StatusId = 3) FirstApproval


from PurchaseRequests PR

Left join DimItem I on PR.ItemID = I.ItemID

left join PurchaseRequestPortal p on pr.PurchaseRequestID = p.PurchaseRequestID	

Left join GoodsIssues on P.GoodsIssueID = GoodsIssues.u_webPRID 

LEFT jOIN DimSAPUsers as OUSR ON OUSR.[UserID] = GoodsIssues .UserSignature and OUSR.countrycode = GoodsIssues .countrycode  --GI creator 

left join AllocationProReqLeadTime as PRLT 
	ON PRLT.ItmsGrpCod = I.ItmsGrpCod
	AND PR.Quantity between PRLT.MinQty and PRLT.MaxQty
	and PR.countrycode = PRLT.CountryCode
left join dbo.DimWarehouses on 
	PR.WarehouseID = DimWarehouses.WebWarehouseID
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimSeasons Season on pr.sapseasonid= season.sapseasonid and pr.countrycode= season.countrycode


where 
	--LEFT(OUSR.UserCode,3) = 'PRC' all are gonna be procurement
	--and PR.Canceled = 'N'
	PR.documententry is null -- from web system
	and StatusName not in ('Draft','Submitted')
	and p.servicedbyflag = 'Warehouse'

union all 

------------ Complete chain, Web portal origin, purchase --------- matching

Select
	'web, purchased' as chunk
	,PR.countrycode
	,PRLT.MinQty
	,PRLT.MaxQty
	,PRLT.LeadTime
,CASE 
		When isnull(PRLT.LeadTime,'') = '' then '0 - Unknown'
		WHEN PRLT.LeadTime <= 14 THEN '1 - Easy'
		WHEN PRLT.LeadTime = 21 THEN '2 - Medium'
		WHEN PRLT.LeadTime = 28 THEN '2 - Medium'
		WHEN PRLT.LeadTime = 35 THEN '3 - Hard'
		WHEN PRLT.LeadTime = 42 THEN '3 - Hard'
		WHEN PRLT.LeadTime = 56 THEN '3 - Hard'
		WHEN PRLT.LeadTime > 56 THEN '4 - Very hard'
		ELSE 'Other' END as Difficulty
	,PR.DocumentDate as [Doc Date]
	,ISNULL(OUSR.UserName,OUSR_R.UserName) as [User]

	----PR------------
	,CASE 
		WHEN StatusName in ('Rejected','CANCELED','SAP Cancelled','Closed') then '0 - Closed without order'
		WHEN StatusName = 'PO Created' then '4 - Ordered but not yet delivered'
		WHEN StatusName in ('Partially Issued','SAP Partially Received') then '5 - Partially delivered'
		WHEN StatusName in ('Received','Issued','Ready for Pickup','SAP Received') then '6 - Full request delivered'
		WHEN PO.Quantity >= PR.Quantity and coalesce(GR.Quantity,PCH1.Quantity,0) = 0 and PO.RowStatus = 'C' then '3 - Closed without delivery'
		WHEN StatusName is not null then '1 - Not yet ordered'
		WHEN PR.Quantity > PO.Quantity and PO.Quantity <> 0 and coalesce(GR.Quantity,PCH1.Quantity,0) = 0 then '2 - Partially ordered'
		WHEN PO.Quantity >= PR.Quantity and coalesce(GR.Quantity,PCH1.Quantity,0) = 0 then '4 - Ordered but not yet delivered'
		WHEN PO.Quantity <> 0 and IsNull(GR.Quantity,PCH1.Quantity) < PO.Quantity then '5 - Partially delivered'
		WHEN coalesce(GR.Quantity,PCH1.Quantity,0) >= PR.Quantity then '6 - Full request delivered'
		WHEN coalesce(GR.Quantity,PCH1.Quantity,0) >= PO.Quantity then '7 - Full order delivered (less than requested)'
		ELSE 'Other' END as [Doc Status]
	,CAST(PR.PurchaseRequestID as varchar(10)) as [PR #]
	,PR.DocumentDate [PR Doc Date]
	,PR.CreateDate [PR Create Date]
	,null as [PR Canceled?]
	,null as [PR Line Status]
	,PR.StatusName as [Web Status]
	,PR.UserName as [Requester]
	,PR.ApproverName as [Approver]
	,PR.DepartmentCode as [Department]
	,I.ItmsGrpNam as [Category]
	,I.ItmsGrpCod
	,I.ItemName as [Item/Service]
	,PR.Comments  as [Notes/Specifications]
	,I.InvntryUom as [UoM]
	,PR.Quantity as [Quantity Requested]
	,PR.PurQuotationRequiredDate as [Desired Delivery Date]
	----PO---------------------------
	,Case when PO.DocumentNumber is null then Null
		Else Concat(PO.DocumentNumber,'_',PO.RowNumber+1) end as [PO #]
	,Case when PO.BaseDocumentType = '1470000113' then 'Purchase Request' else null end [PO Source Document]
	,PO.BaseDocumentType as [PO Source Doc Num]
	,PO.DocumentDate as [PO Date]
	,PO.CreateDate as [PO Create Date]
	,PO.BusinessPartnerName as [Vendor]
	,PO.CANCELED as [PO Canceled?]
	,PO.RowStatus as [PO Line Status]
	,PO.Quantity as [Quantity]
	,COALESCE(GR.Price,PCH1.Price,PO.Price) as [Unit Cost]	-- need this
	,convert(money, COALESCE(GR.RowTotal, PCH1.RowTotalLocal, PO.RowTotal)) as [Total Cost]
	,convert(money, COALESCE(GR.TotalSumUSD, PCH1.RowTotalUSD, PO.RowTotalUSD)) as [Total Cost USD]
	,COALESCE(GR.Currency, PCH1.Currency, PO.Currency) as [Currency]
	,Case when PO.TargetType = 20 then 'GRPO'-- need this
		when PO.TargetType = 18 then 'A/P Invoice'
		when PO.TargetType = -1 then 'None'
		When PO.TargetType is Null then NULL
		Else 'Other' end as [Target Document]
	,ISNULL(PR.Purchaser,'Unassigned') as Purchaser
	----GRPO/AP-----------------
	,Case when GR.DocumentNumber is null and PCH1.DocumentNumber is null then Null
		When PCH1.DocumentNumber is not null then 'A/P Invoice'
		When GR.DocumentNumber is not null then 'GRPO'
		Else 'Other' end as [Receiving Document]
	,Case When GR.DocumentNumber is null and PCH1.DocumentNumber is null then NULL
		when GR.DocumentNumber is null then CONCAT(PCH1.DocumentNumber,'_',PCH1.RowNumber+1)
		when PCH1.DocumentNumber is null then CONCAT(GR.DocumentNumber,'_',GR.RowNumber+1) End as [GRPO #]
	,Case when Isnull(GR.BaseDocumentType,PCH1.BaseDocumentType) = 22 then 'Purchase Order' else null end as [GRPO Source Document]
	,Isnull(GR.BaseDocumentEntry,PCH1.BaseDocumentEntry) as [GRPO Source Doc Num]
	,ISNULL(GR.DocumentDate,PCH1.DocumentDate) [GRPO Date]
	,IsNull(GR.CANCELED,PCH1.Canceled) as [GRPO Canceled?]
	,IsNull(GR.RowStatus,PCH1.RowStatus) as [GRPO Line Status]
	,IsNull(GR.Quantity,PCH1.Quantity) as [Quantity Delivered to Date]
	,IsNull(GR.CustomerSatisfaction,PCH1.U_CusotmerSat) as [Customer Satisfaction]
	,null[WarehouseName]
	,case 
		when PR.U_season is not null then 'Global'
		when PR.SeasonName is not null then 'Global'
		when PR.CountryCode = 'US' then 'Global'
		when PR.PurchaseRequestType is null and PR.U_season is null and Pr.SeasonName is null then 'InCountry'
		Else PR.PurchaseRequestType 
	end as SourcingTeam
	,case 
		when PR.U_season is not null then PR.U_Season
		when PR.SeasonName is not null then PR.SeasonName
		when PR.sapseasonid is not null then Seasons.SeasonName
		else null
	end as Season
	,(select min(a.Transdate) from WebPortalAudit a where a.PurchaseRequestId = PR.purchaserequestid and a.StatusId = 3) FirstApproval

from PurchaseRequests PR

Left join DimItem I on PR.ItemID = I.ItemID
left join PurchaseRequestPortal p on pr.PurchaseRequestID = p.PurchaseRequestID	

Left join PurchaseOrders as PO on (PR.PurchaseRequestID = PO.u_webPRID) and PO.Canceled ='N'

Left join GoodsReceiptPO as GR on PO.DocumentEntry = GR.BaseDocumentEntry 
	and PO.RowNumber = GR.BaseDocumentRow 
	and GR.BaseDocumentType = 22 
	and GR.Canceled ='N' 
	and PO.countrycode = GR.countrycode

Left Join APInvoices as PCH1 on PO.DocumentEntry = PCH1.BaseDocumentEntry -- linked to PO in case an order skips grpo (this shouldn't happen)
	and PO.RowNumber = PCH1.BaseRow
	and PCH1.BaseDocumentType = 22 
	and PCH1.Canceled = 'N'
	and PO.countrycode = PCH1.countrycode

LEFT join DimSAPUsers as OUSR ON OUSR.[UserID] = PO.USerSignature and OUSR.countrycode = PO.countrycode  --PO creator 
LEFT jOIN DimSAPUsers as OUSR_R ON OUSR_R.[UserID] = PR.UserSignature and OUSR_R.countrycode = PR.countrycode  --PR creator 

left join AllocationProReqLeadTime as PRLT 
	ON PRLT.ItmsGrpCod = I.ItmsGrpCod  -- join instead on web category
	AND PR.Quantity between PRLT.MinQty and PRLT.MaxQty
	and PR.countrycode = PRLT.CountryCode
left JOIN [$(OAF_SHARED_DIMENSIONS)].dbo.DimSeasons as Seasons on pr.sapseasonid= Seasons.sapseasonid and pr.countrycode= Seasons.countrycode
	
where 
	--LEFT(OUSR.UserCode,3) = 'PRC' all are gonna be procurement
	--and PR.Canceled = 'N'
	PR.DocumentEntry is null -- from web system
	and StatusName not in ('Draft','Submitted')
	and p.servicedbyflag <> 'Warehouse'

