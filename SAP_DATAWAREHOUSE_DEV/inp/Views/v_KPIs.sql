/*
Updates:
	V6 DK 02/04/2019:
		Edited to pull from new tables
	V5 MW 28-01-2019:
		Updated to pull from PurchaseRequests instead of PurchaseRequest
	V3: 
		Added season, purchaser, approver from PR
		Added fields previously missing from GRPOs and POs
		
	V2: changed OHEM to pull from HR database
		Added in logic for the request lead time
*/

--USE OAF_SAP_DATAWAREHOUSE
CREATE VIEW inp.v_KPIs AS


-- these are all coming from SAP source - need to add the web portal as a source
Select distinct 

PR.countrycode
,PRLT.LeadTime
,ISNULL(OUSR.UserName,OUSR_R.UserName) as [User]
,I.ItmsGrpNam as [Category]
,I.ItmsGrpCod
,I.ItemName
,PR.[Description] as Dscription
,CASE 
	WHEN PR.RowStatus='O' and isnull(POR1.Quantity,0) = 0 then '1 - Not yet ordered'
	WHEN PR.RowStatus='C' and isnull(POR1.Quantity,0) = 0 then '0 - Closed without order'
	WHEN PR.RowStatus='C' and POR1.CANCELED = 'Y' then '0 - Closed without Order'
	WHEN coalesce(PDN1.Quantity,INV1.Quantity,0) = 0 and POR1.DocumentStatus = 'C' then '3 - Closed without delivery'
	WHEN PR.Quantity > POR1.Quantity and POR1.Quantity <> 0 and coalesce(PDN1.Quantity,INV1.Quantity,0) = 0 then '2 - Partially ordered'
	WHEN POR1.Quantity >= PR.Quantity and coalesce(PDN1.Quantity,INV1.Quantity,0) = 0 then '4 - Ordered but not yet delivered'
	WHEN POR1.Quantity <> 0 and IsNull(PDN1.Quantity,INV1.Quantity) < POR1.Quantity then '5 - Partially delivered'
	WHEN coalesce(PDN1.Quantity,INV1.Quantity,0) >= PR.Quantity then '6 - Full request delivered'
	WHEN coalesce(PDN1.Quantity,INV1.Quantity,0) >= POR1.Quantity then '7 - Full order delivered (less than requested)'
	ELSE 'Other' END as [Doc Status]
----PR------------
,CONCAT(PR.DocumentNumber,'_',PR.RowNumber+1) as [PR #]
,PR.DocumentDate [PR Doc Date]
,PR.CreateDate [PR Create Date]
,PR.Canceled as [PR Canceled?]
,PR.RowStatus as [PR Line Status]
,PR.U_Requestor as [Requester]
,coalesce(PR.ApproverName,PR.U_Approver,'') as [Approver]
,PR.DepartmentCode as [Department]
,PR.Text  as [Notes/Specifications]
,PR.UOMCode as [UoM]
,PR.Quantity as [Quantity Requested]
,PR.PurQuotationRequiredDate as [Desired Delivery Date]
,PR.U_TRSR_Country as [Country]
,PR.U_season as [Season]
,CASE 
	When PR.DocumentEntry is not null then PR.Purchaser
	When POR1.SalesEmployeeCode <> -1 then OSLP.SalesEmployeeName
	Else ISNULL(CONCAT(OHEM.firstName,' ',OHEM.Lastname),'Unassigned') end as [Purchaser]
----PO---------------------------
,Case when POR1.DocumentNumber is null then Null
	Else Concat(POR1.DocumentNumber,'_',POR1.RowNumber+1) end as [PO #]
,POR1.DocumentDate as [PO Date]
,POR1.CreateDate as [PO Create Date]
,POR1.BusinessPartnerName as [Vendor]
,POR1.CANCELED as [PO Canceled?]
,POR1.DocumentStatus as [PO Line Status]
,POR1.Quantity as [PO Quantity]
,POR1.Price as [PO Net Price]
,POR1.GrossPrice as [Gross Price]	
,CASE When POR1.Currency = 'USD' Then POR1.RowTotal else POR1.RowTotalForeignCurrency end as [Net Total]
,CASE When POR1.Currency = 'USD' Then POR1.TotalTax else POR1.TaxAmountUSD end as [VAT Total]
,CASE When POR1.Currency = 'USD' Then POR1.grosstotal else POR1.GrossTotalUSD end as [Gross Total]
,POR1.Currency as [PO Currency]
,convert(money, POR1.RowTotalUSD) as [PO Total Cost USD]
,convert(money, POR1.RowTotal) as [PO Total Cost]
,POR1.TaxAmountUSD as [PO VAT Total USD]
,POR1.GrossTotalUSD as [PO Gross Total USD]
----GRPO-----------------
,Case when PDN1.DocumentNumber is null then Null else CONCAT(PDN1.DocumentNumber,'_',PDN1.RowNumber+1) End as [GRPO #]
,PDN1.DocumentDate [GRPO Date]
,PDN1.CANCELED as [GRPO Canceled?]
,PDN1.DocumentStatus as [GRPO Line Status]
,PDN1.Quantity as [GRPO Quantity]
,PDN1.CustomerSatisfaction as [Customer Satisfaction]
--,PDN1.Price as [GRPO Unit Cost]
,PDN1.DocumentTotalSystemCurrency as [GRPO Gross Total USD]
,PDN1.TaxAmountSystemCurrency as [GRPO VAT Total USD]
,PDN1.DocumentTotalSystemCurrency - PDN1.TaxAmountSystemCurrency as [GRPO Net Total USD]
,convert(money, PDN1.RowTotal) as [GRPO Total Cost]
,convert(money, PDN1.TotalSumUSD) as [GRPO Total Cost USD]
,PDN1.Currency as [GRPO Currency]
----AR Invoice-----------------
,Case when INV1.DocumentNumber is null then Null else CONCAT(INV1.DocumentNumber,'_',INV1.RowNumber+1) End as [AR #]
,INV1.DocumentNumber as [AR Header #]
,INV1.DocumentDate [AR Date]
,INV1.CANCELED as [AR Canceled?]
,INV1.RowStatus as [AR Line Status]
,INV1.Quantity as [AR Quantity]
,INV1.PriceAfterDiscount as [AR Unit Cost]
,convert(money, INV1.RowTotal) as [AR Total Cost]
,convert(money, INV1.RowTotalSystemCurrency) as [AR Total Cost USD]
,INV1.Currency as [AR Currency]
,INV1.UOMCode as [AR UoM]

from dbo.PurchaseRequests as PR

Left join DimItem I on PR.ItemID = I.ItemID

Left join PurchaseOrders POR1
	on PR.DocumentEntry = POR1.BaseDocumentReference 
	and PR.RowNumber = POR1.BaseRow 
	and POR1.BaseDocumentType = '1470000113' -- PR basetype
	and POR1.canceled = 'N' --in (Select TPOR1.canceled from POR1 TPOR1 where POR1.docentry = TPOR1.docentry) -- PO rows
	and PR.countrycode = POR1.countrycode and POR1.Countrycode = 'US'

Left Join GoodsReceiptPO pdn1
	on POR1.DocumentEntry = PDN1.BaseDocumentReference 
	and POR1.RowNumber = PDN1.BaseDocumentRow 
	and PDN1.BaseDocumentType = 22 -- PO base doc
	and PDN1.Canceled = 'N' --in (Select TOPDN.canceled from OPDN TOPDN where PDN1.docentry = TOPDN.docentry) --- GRPO Rows
	and POR1.countrycode = PDN1.countrycode

Left join WarehouseJournal OINM
	on oinm.BaseReference = pdn1.DocumentNumber 
	and OINM.TransactionType = 20 
	and oinm.countrycode = pdn1.countrycode

Left Join ARInvoices INV1
	on INV1.ReferencedObjectType = OINM.TransactionType and -- from INV12
	INV1.ReferencedDocumentNumber = OINM.BaseReference and -- from INV12
	INV1.ItemId = PDN1.ItemId and -- from INV1
	INV1.WarehouseCode = OINM.Warehouse and -- from INV1
	inv1.countrycode = oinm.countrycode
/*
Left Join OPCH 
	on cast(INV1.docnum as nvarchar) = OPCH.U_ARRec 
	and OPCH.canceled = 'N' 
	and OPCH.countrycode <> 'US'
	and INV1.ItemCode in (Select TPCH1.ItemCode from PCH1 TPCH1 where TPCH1.docentry = OPCH.docentry and TPCH1.CountryCode = OPCH.CountryCode) --- AP Rows
Left join PCH1 on PCH1.docentry = OPCH.docentry and PCH1.countrycode = OPCH.countrycode
*/
Left join [$(OAF_HR_DATAWAREHOUSE)].dbo.OHEM on POR1.documentowner = ohem.empID and POR1.countrycode = OHEM.Countrycode --Purchaser
Left Join DimSalesEmployees as OSLP on POR1.SalesEmployeeCode = OSLP.SalesEmployeeCode and POR1.countrycode = OSLP.countrycode -- Employee ID
LEFT jOIN dimsapusers  as OUSR ON OUSR.USERID = POR1.UserSignature and OUSR.countrycode = POR1.countrycode  --PO creator 
LEFT jOIN DimSAPUsers as OUSR_R ON OUSR_R.UserID = PR.UserSignature and OUSR_R.countrycode = PR.countrycode  --PR creator 

left join dbo.AllocationProReqLeadTime as PRLT 
	ON PRLT.ItmsGrpCod = I.ItmsGrpCod
	AND PRLT.CountryCode = 'US'

where 
	LEFT(ISNULL(OUSR.UserCode,OUSR_R.UserCode),3) = 'GLB'
	--and PR.Canceled = 'N'
	and PR.DocumentEntry is not null -- from non-web system


