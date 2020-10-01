/*
LOGIC NOTES:
Converting Time fields to DateTime format - WDD table track time at the hour:minute level. Draft and document tables track time at the hour:minute:second level. This requires slightly different logic for converting string to datetime depending on character lenght of time value.

To do -
	 The original query joined to header tables, check that it still works when joining to the flattened tables

V5: DK-17-09-2019 - Added APCreditMemos, GoodReceipts, GoodIssues, InventoryTransfers,ARInvoices
	 
V4: MW-30-07-2019 - Added GRPOs
				  - Took out the DimTransactionType join for sections with only one type of doc
V3:
	MW-30-07-2019 - Changed the update logic to only include updates that happened more than 10 seconds after the create date. 
					There were lots of updates one second later that aren't "true" updates
				  - Added the same country logic as in the raw documents
				  - Added sourcing team
V2:
	DK-17-07-2019 - Joined to DimTransactionType

*/
--use oaf_sap_datawarehouse;
CREATE view dbo.SapMetadata as

select ROW_NUMBER() OVER(PARTITION BY ObjectType, DraftEntry, DocumentEntry ORDER BY [DateTime]) 
    AS Row#, * from(

---Returns when the draft was created

(Select distinct
	Drafts.ObjectType,
	DimTransactionType.[Transaction] as TransactionType,
	Drafts.DocumentEntry DraftEntry,
	Drafts.DocumentNumber [DraftNum],
		-- all at doc header level
	coalesce(APInvoices.DocumentEntry,PurchaseOrders.DocumentEntry,APDownPayments.DocumentEntry,GoodsReceiptPO.DocumentEntry,GoodsIssues.DocumentEntry,ARInvoices.DocumentEntry
		,GoodsReceipts.DocumentEntry,APCreditMemos.DocumentEntry,InventoryTransfers.DocumentEntry) as DocumentEntry,
	coalesce(APInvoices.DocumentNumber,PurchaseOrders.DocumentNumber,APDownPayments.DocumentNumber,GoodsReceiptPO.DocumentNumber,GoodsIssues.DocumentNumber 
		,ARInvoices.DocumentNumber,GoodsReceipts.DocumentNumber,APCreditMemos.DocumentNumber,InventoryTransfers.DocumentNumber) as DocumentNumber,
	coalesce(APInvoices.DocumentDate,PurchaseOrders.DocumentDate,APDownPayments.DocumentDate,GoodsReceiptPO.DocumentDate,GoodsIssues.DocumentDate,ARInvoices.DocumentDate
		,GoodsReceipts.DocumentDate,APCreditMemos.DocumentDate,InventoryTransfers.DocumentDate) as DocumentDate,
	coalesce(APInvoices.DocumentSubmissionDate,PurchaseOrders.DocumentSubmissionDate,APDownPayments.DocumentSubmissionDate,GoodsReceiptPO.DocumentSubmissionDate, GoodsIssues.DocumentSubmissionDate ,ARInvoices.DocumentSubmissionDate,GoodsReceipts.DocumentSubmissionDate,APCreditMemos.DocumentSubmissionDate, InventoryTransfers.DocumentSubmissionDate ) as DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	DimSapUsers.UserName [ActionUser],
	Drafts.CreateDate [Date],
	Drafts.CreateTime [Time],
	Drafts.CreateDate + case when len(Drafts.CreateTime) = 6 then CAST(STUFF(STUFF(Drafts.CreateTime,5,0,':'),3,0,':') as Datetime)
		when len(Drafts.CreateTime) = 5 then CAST(STUFF(STUFF(Drafts.CreateTime,4,0,':'),2,0,':') as Datetime)
		when len(Drafts.CreateTime) = 4 then CAST('00:' + STUFF(Drafts.CreateTime,3,0,':') as Datetime)
		when len(Drafts.CreateTime) = 3 then CAST('00:0' + STUFF(Drafts.CreateTime,2,0,':') as Datetime)
		when len(Drafts.CreateTime) = 2 then CAST('00:00:' + cast(Drafts.CreateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Draft Created' Action, -- updated manually based on section
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team -- eventually, we might want this field to just be the code
	,CASE
		WHEN Drafts.CountryCode = 'US' THEN 'Global'
		WHEN APInvoices.U_Season is not null then 'Global'
		WHEN PurchaseOrders.U_Season is not null then 'Global'
		WHEN APDownPayments.U_Season is not null then 'Global'
		WHEN GoodsReceiptPO.U_Season is not null then 'Global'
		WHEN GoodsReceipts.U_Season is not null then 'Global'
		WHEN GoodsIssues.U_Season is not null then 'Global'
		WHEN APCreditMemos.U_Season is not null then 'Global'
		WHEN ARInvoices.U_Season is not null then 'Global'
		WHEN InventoryTransfers.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,Drafts.CountryCode
	,Case 
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'KENYA' then 'KE'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'BURUNDI' then 'BI'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'TANZANIA' then 'TZ'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'RWANDA' then 'RW'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'MALAWI' then 'MW'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'ETHIOPIA' then 'ETH'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'ZAMBIA' then 'ZA'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'UGANDA' then 'UG'
	else Drafts.CountryCode end as [Database]

from Drafts
	left join DimSapUsers on 
		DimSapUsers.UserID = Drafts.UserSignature and 
		DimSAPUsers.CountryCode = Drafts.CountryCode
	left join DimTransactionType  on 
		Drafts.ObjectType = DimTransactionType.transid

	left join APInvoices on 
		APInvoices.DocumentDraftInternalID = Drafts.DocumentEntry and 
		APInvoices.CountryCode = Drafts.CountryCode
	left join PurchaseOrders on 
		PurchaseOrders.DocumentDraftInternalID = Drafts.DocumentEntry and 
		PurchaseOrders.CountryCode = Drafts.CountryCode
	left join APDownPayments on 
		APDownPayments.DocumentDraftInternalID = Drafts.DocumentEntry and 
		APDownPayments.CountryCode = Drafts.CountryCode
	left join GoodsReceiptPO on 
		GoodsReceiptPO.DocumentDraftInternalID = Drafts.DocumentEntry and 
		GoodsReceiptPO.CountryCode = Drafts.CountryCode
	left join ARInvoices on 
		ARInvoices.DocumentDraftInternalID = Drafts.DocumentEntry and 
		ARInvoices.CountryCode = Drafts.CountryCode
	left join GoodsReceipts on 
		GoodsReceipts.DocumentDraftInternalID = Drafts.DocumentEntry and 
		GoodsReceipts.CountryCode = Drafts.CountryCode
	left join GoodsIssues on 
		GoodsIssues.DocumentDraftInternalID = Drafts.DocumentEntry and 
		GoodsIssues.CountryCode = Drafts.CountryCode
	left join InventoryTransfers on 
		InventoryTransfers.DocumentDraftInternalID = Drafts.DocumentEntry and 
		InventoryTransfers.CountryCode = Drafts.CountryCode
	left join APCreditMemos on 
		APCreditMemos.DocumentDraftInternalID = Drafts.DocumentEntry and 
		APCreditMemos.CountryCode = Drafts.CountryCode

where Drafts.ObjectType in (204, 22, 18, 20,13,19,59,60,67) -- this also needs updating when adding new documents
)
Union All 

---Returns when the draft was last updated
(Select distinct
	Drafts.ObjectType,
	DimTransactionType.[Transaction] as TransactionType,
	Drafts.DocumentEntry DraftEntry,
	Drafts.DocumentNumber [DraftNum],
	coalesce(APInvoices.DocumentEntry,PurchaseOrders.DocumentEntry,APDownPayments.DocumentEntry,GoodsReceiptPO.DocumentEntry,GoodsIssues.DocumentEntry,ARInvoices.DocumentEntry
		,GoodsReceipts.DocumentEntry,APCreditMemos.DocumentEntry,InventoryTransfers.DocumentEntry) as DocumentEntry,
	coalesce(APInvoices.DocumentNumber,PurchaseOrders.DocumentNumber,APDownPayments.DocumentNumber,GoodsReceiptPO.DocumentNumber,GoodsIssues.DocumentNumber 
		,ARInvoices.DocumentNumber,GoodsReceipts.DocumentNumber,APCreditMemos.DocumentNumber,InventoryTransfers.DocumentNumber) as DocumentNumber,
	coalesce(APInvoices.DocumentDate,PurchaseOrders.DocumentDate,APDownPayments.DocumentDate,GoodsReceiptPO.DocumentDate,GoodsIssues.DocumentDate,ARInvoices.DocumentDate
		,GoodsReceipts.DocumentDate,APCreditMemos.DocumentDate,InventoryTransfers.DocumentDate) as DocumentDate,
	coalesce(APInvoices.DocumentSubmissionDate,PurchaseOrders.DocumentSubmissionDate,APDownPayments.DocumentSubmissionDate,GoodsReceiptPO.DocumentSubmissionDate, GoodsIssues.DocumentSubmissionDate ,ARInvoices.DocumentSubmissionDate,GoodsReceipts.DocumentSubmissionDate,APCreditMemos.DocumentSubmissionDate, InventoryTransfers.DocumentSubmissionDate ) as DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = Drafts.UserSignature2 and 
			DimSAPUsers.CountryCode = Drafts.CountryCode
	) [ActionUser],
	Drafts.UpdateDate [Date],
	Drafts.UpdateTime [Time],
	Drafts.UpdateDate + case when len(Drafts.UpdateTime) = 6 then CAST(STUFF(STUFF(Drafts.UpdateTime,5,0,':'),3,0,':') as Datetime)
		when len(Drafts.UpdateTime) = 5 then CAST(STUFF(STUFF(Drafts.UpdateTime,4,0,':'),2,0,':') as Datetime)
		when len(Drafts.UpdateTime) = 4 then CAST('00:' + STUFF(Drafts.UpdateTime,3,0,':') as Datetime)
		when len(Drafts.UpdateTime) = 3 then CAST('00:0' + STUFF(Drafts.UpdateTime,2,0,':') as Datetime)
		when len(Drafts.UpdateTime) = 2 then CAST('00:00:' + cast(Drafts.UpdateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Draft Updated' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN Drafts.CountryCode = 'US' THEN 'Global'
		WHEN APInvoices.U_Season is not null then 'Global'
		WHEN PurchaseOrders.U_Season is not null then 'Global'
		WHEN APDownPayments.U_Season is not null then 'Global'
		WHEN GoodsReceiptPO.U_Season is not null then 'Global'
		WHEN GoodsIssues.U_Season is not null then 'Global'
		WHEN GoodsReceipts.U_Season is not null then 'Global'
		WHEN ARInvoices.U_Season is not null then 'Global'
		WHEN APCreditMemos.U_Season is not null then 'Global'
		WHEN InventoryTransfers.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,Drafts.CountryCode
	,Case 
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'KENYA' then 'KE'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'BURUNDI' then 'BI'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'TANZANIA' then 'TZ'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'RWANDA' then 'RW'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'MALAWI' then 'MW'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'ETHIOPIA' then 'ETH'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'ZAMBIA' then 'ZA'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'UGANDA' then 'UG'
	else Drafts.CountryCode end as [Database]

from Drafts
	left join DimSapUsers on 
		DimSapUsers.UserID = Drafts.UserSignature and 
		DimSAPUsers.CountryCode = Drafts.CountryCode
	left join DimTransactionType  on 
		Drafts.ObjectType = DimTransactionType.transid

	left join APInvoices on 
		APInvoices.DocumentDraftInternalID = Drafts.DocumentEntry and
		APInvoices.CountryCode = Drafts.CountryCode
	left join PurchaseOrders on 
		PurchaseOrders.DocumentDraftInternalID = Drafts.DocumentEntry and
		PurchaseOrders.CountryCode = Drafts.CountryCode
	left join APDownPayments on 
		APDownPayments.DocumentDraftInternalID = Drafts.DocumentEntry and
		APDownPayments.CountryCode = Drafts.CountryCode
	left join GoodsReceiptPO on 
		GoodsReceiptPO.DocumentDraftInternalID = Drafts.DocumentEntry and 
		GoodsReceiptPO.CountryCode = Drafts.CountryCode
		left join ARInvoices on 
		ARInvoices.DocumentDraftInternalID = Drafts.DocumentEntry and 
		ARInvoices.CountryCode = Drafts.CountryCode
	left join GoodsReceipts on 
		GoodsReceipts.DocumentDraftInternalID = Drafts.DocumentEntry and 
		GoodsReceipts.CountryCode = Drafts.CountryCode
	left join GoodsIssues on 
		GoodsIssues.DocumentDraftInternalID = Drafts.DocumentEntry and 
		GoodsIssues.CountryCode = Drafts.CountryCode
	left join InventoryTransfers on 
		InventoryTransfers.DocumentDraftInternalID = Drafts.DocumentEntry and 
		InventoryTransfers.CountryCode = Drafts.CountryCode
	left join APCreditMemos on 
		APCreditMemos.DocumentDraftInternalID = Drafts.DocumentEntry and 
		APCreditMemos.CountryCode = Drafts.CountryCode

where 
	(Drafts.CreateTime <= Drafts.UpdateTime - 10 or Drafts.CreateDate <> Drafts.UpdateDate) 
	and Drafts.ObjectType in (204, 22, 18, 20,13,19,59,60,67)
)	
Union All

---Returns approval decisions
(select distinct
	DocsForConfirmation.ObjectType, 
	DimTransactionType.[Transaction] as TransactionType,
	DocsForConfirmation.DraftEntry, 
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = DocsForConfirmation.DraftEntry
			and Drafts.ObjectType = DocsForConfirmation.ObjectType
			and Drafts.CountryCode = DocsForConfirmation.CountryCode
	) DraftNum,
	DocsForConfirmation.DocumentEntry,
	coalesce(APInvoices.DocumentNumber,PurchaseOrders.DocumentNumber,APDownPayments.DocumentNumber,GoodsReceiptPO.DocumentNumber,GoodsIssues.DocumentNumber 
		,ARInvoices.DocumentNumber,GoodsReceipts.DocumentNumber,APCreditMemos.DocumentNumber,InventoryTransfers.DocumentNumber) as DocumentNumber,
	coalesce(APInvoices.DocumentDate,PurchaseOrders.DocumentDate,APDownPayments.DocumentDate,GoodsReceiptPO.DocumentDate,GoodsIssues.DocumentDate,ARInvoices.DocumentDate
		,GoodsReceipts.DocumentDate,APCreditMemos.DocumentDate,InventoryTransfers.DocumentDate) as DocumentDate,
	coalesce(APInvoices.DocumentSubmissionDate,PurchaseOrders.DocumentSubmissionDate,APDownPayments.DocumentSubmissionDate,GoodsReceiptPO.DocumentSubmissionDate, 
		GoodsIssues.DocumentSubmissionDate ,ARInvoices.DocumentSubmissionDate,GoodsReceipts.DocumentSubmissionDate,APCreditMemos.DocumentSubmissionDate,
		InventoryTransfers.DocumentSubmissionDate ) as DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],	
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = DocsForConfirmation.uSERid 
			and DimSAPUsers.CountryCode = DocsForConfirmation.CountryCode
	) [ActionUser],
	DocsForConfirmation.UpdateDate [Date],
	DocsForConfirmation.UpdateTime [Time],
	DocsForConfirmation.UpdateDate + case when len(DocsForConfirmation.updateTime) = 6 then CAST(STUFF(STUFF(DocsForConfirmation.updateTime,5,0,':'),3,0,':') as Datetime)
		when len(DocsForConfirmation.updateTime) = 5 then CAST(STUFF(STUFF(DocsForConfirmation.updateTime,4,0,':'),2,0,':') as Datetime)
		when len(DocsForConfirmation.updateTime) = 4 then CAST(STUFF(DocsForConfirmation.updateTime,3,0,':') as Datetime) 
		when len(DocsForConfirmation.updateTime) = 3 then CAST(STUFF(DocsForConfirmation.updateTime,2,0,':') as Datetime)
		when len(DocsForConfirmation.updateTime) = 2 then CAST(STUFF(DocsForConfirmation.updateTime,0,0,':') as Datetime)
		when len(DocsForConfirmation.UpdateTime) = 2 then CAST('00:' + cast(DocsForConfirmation.Updatetime as nvarchar(2)) as datetime) 
	end [DateTime],
	Case 
		when DocsForConfirmation.Status = 'Y' Then ApprovalType + ' - Approved'
		when DocsForConfirmation.Status = 'N' Then ApprovalType + ' - Rejected'
	Else ApprovalType + ' - Other' End [Action],
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN DocsForConfirmation.CountryCode = 'US' THEN 'Global'
		WHEN APInvoices.U_Season is not null then 'Global'
		WHEN PurchaseOrders.U_Season is not null then 'Global'
		WHEN APDownPayments.U_Season is not null then 'Global'
		WHEN GoodsReceiptPO.U_Season is not null then 'Global'
		WHEN GoodsReceipts.U_Season is not null then 'Global'
		WHEN GoodsIssues.U_Season is not null then 'Global'
		WHEN APCreditMemos.U_Season is not null then 'Global'
		WHEN ARInvoices.U_Season is not null then 'Global'
		WHEN InventoryTransfers.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,DocsForConfirmation.CountryCode
	,Case 
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'KENYA' then 'KE'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'BURUNDI' then 'BI'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'TANZANIA' then 'TZ'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'RWANDA' then 'RW'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'MALAWI' then 'MW'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'ETHIOPIA' then 'ETH'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'ZAMBIA' then 'ZA'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'UGANDA' then 'UG'
	else DocsForConfirmation.CountryCode end as [Database]

From DocsForConfirmation 
	left join DimSapUsers on 
		DimSapUsers.UserID = DocsForConfirmation.OwnerID
		and DimSAPUsers.CountryCode = DocsForConfirmation.CountryCode
	left join DimTransactionType  on 
		DocsForConfirmation.ObjectType = DimTransactionType.transid

	left join APInvoices on 
		APInvoices.DocumentDraftInternalID = DocsForConfirmation.DraftEntry and
		APInvoices.CountryCode = DocsForConfirmation.CountryCode
	left join PurchaseOrders on 
		PurchaseOrders.DocumentDraftInternalID = DocsForConfirmation.DocumentEntry
		and PurchaseOrders.CountryCode = DocsForConfirmation.CountryCode
	left join APDownPayments on 
		APDownPayments.DocumentDraftInternalID = DocsForConfirmation.DraftEntry
		and APDownPayments.CountryCode = DocsForConfirmation.CountryCode
	left join GoodsReceiptPO on 
		GoodsReceiptPO.DocumentDraftInternalID = DocsForConfirmation.DraftEntry
		and GoodsReceiptPO.CountryCode = DocsForConfirmation.CountryCode
	left join ARInvoices on 
		ARInvoices.DocumentDraftInternalID = DocsForConfirmation.DraftEntry and 
		ARInvoices.CountryCode = DocsForConfirmation.CountryCode
	left join GoodsReceipts on 
		GoodsReceipts.DocumentDraftInternalID = DocsForConfirmation.DraftEntry and 
		GoodsReceipts.CountryCode = DocsForConfirmation.CountryCode
	left join GoodsIssues on 
		GoodsIssues.DocumentDraftInternalID = DocsForConfirmation.DraftEntry and 
		GoodsIssues.CountryCode = DocsForConfirmation.CountryCode
	left join InventoryTransfers on 
		InventoryTransfers.DocumentDraftInternalID = DocsForConfirmation.DraftEntry and 
		InventoryTransfers.CountryCode = DocsForConfirmation.CountryCode
	left join APCreditMemos on 
		APCreditMemos.DocumentDraftInternalID = DocsForConfirmation.DraftEntry and 
		APCreditMemos.CountryCode = DocsForConfirmation.CountryCode

where 
	DocsForConfirmation.updatedate is not null and 
	DocsForConfirmation.ObjectType in (18, 22, 204, 20,13,19,59,60,67)
)
Union All

--Returns when the AP invoice was created
(Select distinct
	18 ObjectType,
	'A/P Invoice' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = APInvoices.DocumentDraftInternalID and
			Drafts.CountryCode = APInvoices.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	DimSapUsers.UserName [ActionUser],
	APInvoices.CreateDate [Date],
	APInvoices.CreateTime [Time],
	APInvoices.CreateDate + case when len(APInvoices.CreateTime) = 6 then CAST(STUFF(STUFF(APInvoices.CreateTime,5,0,':'),3,0,':') as Datetime)
		when len(APInvoices.CreateTime) = 5 then CAST(STUFF(STUFF(APInvoices.CreateTime,4,0,':'),2,0,':') as Datetime)
		when len(APInvoices.CreateTime) = 4 then CAST('00:' + STUFF(APInvoices.CreateTime,3,0,':') as Datetime)
		when len(APInvoices.CreateTime) = 3 then CAST('00:0' + STUFF(APInvoices.CreateTime,2,0,':') as Datetime)
		when len(APInvoices.CreateTime) = 2 then CAST('00:00:' + cast(APInvoices.CreateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Created' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN APInvoices.CountryCode = 'US' THEN 'Global'
		WHEN APInvoices.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,APInvoices.CountryCode
	,Case 
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'KENYA' then 'KE'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'BURUNDI' then 'BI'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'RWANDA' then 'RW'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'MALAWI' then 'MW'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'UGANDA' then 'UG'
	else APInvoices.CountryCode end as [Database]

from APInvoices
	left join DimSapUsers on 
		DimSapUsers.UserID = APInvoices.UserSignature and 
		DimSAPUsers.CountryCode = APInvoices.CountryCode
)
Union All

--Returns when the Purchase Order was created
(Select distinct
	22 ObjectType,
	'Purchase Order' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = PurchaseOrders.DocumentDraftInternalID AND
			Drafts.CountryCode = PurchaseOrders.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	DimSapUsers.UserName [ActionUser],
	PurchaseOrders.CreateDate [Date],
	PurchaseOrders.CreateTime [Time],
	PurchaseOrders.CreateDate + case when len(PurchaseOrders.CreateTime) = 6 then CAST(STUFF(STUFF(PurchaseOrders.CreateTime,5,0,':'),3,0,':') as Datetime)
		when len(PurchaseOrders.CreateTime) = 5 then CAST(STUFF(STUFF(PurchaseOrders.CreateTime,4,0,':'),2,0,':') as Datetime)
		when len(PurchaseOrders.CreateTime) = 4 then CAST('00:' + STUFF(PurchaseOrders.CreateTime,3,0,':') as Datetime)
		when len(PurchaseOrders.CreateTime) = 3 then CAST('00:0' + STUFF(PurchaseOrders.CreateTime,2,0,':') as Datetime)
		when len(PurchaseOrders.CreateTime) = 2 then CAST('00:00:' + cast(PurchaseOrders.CreateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Created' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN PurchaseOrders.CountryCode = 'US' THEN 'Global'
		WHEN PurchaseOrders.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,PurchaseOrders.CountryCode
	,Case 
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'KENYA' then 'KE'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'BURUNDI' then 'BI'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'RWANDA' then 'RW'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'MALAWI' then 'MW'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'UGANDA' then 'UG'
	else PurchaseOrders.CountryCode end as [Database]

from PurchaseOrders
	left join DimSapUsers on 
		DimSapUsers.UserID = PurchaseOrders.UserSignature AND
		DimSapUsers.CountryCode = PurchaseOrders.CountryCode
)
Union All 

--Returns when the AP down payment invoice was created
(Select distinct
	204 ObjectType,
	'A/P Down Payment' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = APDownPayments.DocumentDraftInternalID AND
			Drafts.CountryCode = APDownPayments.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	DimSapUsers.UserName [ActionUser],
	APDownPayments.CreateDate [Date],
	APDownPayments.CreateTime [Time],
	APDownPayments.CreateDate + case when len(APDownPayments.CreateTime) = 6 then CAST(STUFF(STUFF(APDownPayments.CreateTime,5,0,':'),3,0,':') as Datetime)
		when len(APDownPayments.CreateTime) = 5 then CAST(STUFF(STUFF(APDownPayments.CreateTime,4,0,':'),2,0,':') as Datetime)
		when len(APDownPayments.CreateTime) = 4 then CAST('00:' + STUFF(APDownPayments.CreateTime,3,0,':') as Datetime)
		when len(APDownPayments.CreateTime) = 3 then CAST('00:0' + STUFF(APDownPayments.CreateTime,2,0,':') as Datetime)
		when len(APDownPayments.CreateTime) = 2 then CAST('00:00:' + cast(APDownPayments.CreateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Created' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN APDownPayments.CountryCode = 'US' THEN 'Global'
		WHEN APDownPayments.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,APDownPayments.CountryCode
	,Case 
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'KENYA' then 'KE'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'BURUNDI' then 'BI'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'RWANDA' then 'RW'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'MALAWI' then 'MW'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'UGANDA' then 'UG'
	else APDownPayments.CountryCode end as [Database]

from APDownPayments
	left join DimSapUsers on 
		DimSapUsers.UserID = APDownPayments.UserSign and
		DimSapUsers.CountryCode = APDownPayments.CountryCode
)
Union All

--Returns when the GRPO was created
(Select distinct
	20 ObjectType,
	'Goods Receipt PO' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = GoodsReceiptPO.DocumentDraftInternalID and
			Drafts.CountryCode = GoodsReceiptPO.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	DimSapUsers.UserName [ActionUser],
	GoodsReceiptPO.CreateDate [Date],
	GoodsReceiptPO.CreateTime [Time],
	GoodsReceiptPO.CreateDate + case when len(GoodsReceiptPO.CreateTime) = 6 then CAST(STUFF(STUFF(GoodsReceiptPO.CreateTime,5,0,':'),3,0,':') as Datetime)
		when len(GoodsReceiptPO.CreateTime) = 5 then CAST(STUFF(STUFF(GoodsReceiptPO.CreateTime,4,0,':'),2,0,':') as Datetime)
		when len(GoodsReceiptPO.CreateTime) = 4 then CAST('00:' + STUFF(GoodsReceiptPO.CreateTime,3,0,':') as Datetime)
		when len(GoodsReceiptPO.CreateTime) = 3 then CAST('00:0' + STUFF(GoodsReceiptPO.CreateTime,2,0,':') as Datetime)
		when len(GoodsReceiptPO.CreateTime) = 2 then CAST('00:00:' + cast(GoodsReceiptPO.CreateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Created' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN GoodsReceiptPO.CountryCode = 'US' THEN 'Global'
		WHEN GoodsReceiptPO.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,GoodsReceiptPO.CountryCode
	,Case 
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'KENYA' then 'KE'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'BURUNDI' then 'BI'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'RWANDA' then 'RW'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'MALAWI' then 'MW'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'UGANDA' then 'UG'
	else GoodsReceiptPO.CountryCode end as [Database]

from GoodsReceiptPO
	left join DimSapUsers on 
		DimSapUsers.UserID = GoodsReceiptPO.UserSignature and 
		DimSAPUsers.CountryCode = GoodsReceiptPO.CountryCode
)
Union All

--Returns when the AP Credit Memo was created
(Select distinct
	19 ObjectType,
	'AP Credit Memo' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = APCreditMemos.DocumentDraftInternalID and
			Drafts.CountryCode = APCreditMemos.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	DimSapUsers.UserName [ActionUser],
	APCreditMemos.CreateDate [Date],
	APCreditMemos.CreateTime [Time],
	APCreditMemos.CreateDate + case when len(APCreditMemos.CreateTime) = 6 then CAST(STUFF(STUFF(APCreditMemos.CreateTime,5,0,':'),3,0,':') as Datetime)
		when len(APCreditMemos.CreateTime) = 5 then CAST(STUFF(STUFF(APCreditMemos.CreateTime,4,0,':'),2,0,':') as Datetime)
		when len(APCreditMemos.CreateTime) = 4 then CAST('00:' + STUFF(APCreditMemos.CreateTime,3,0,':') as Datetime)
		when len(APCreditMemos.CreateTime) = 3 then CAST('00:0' + STUFF(APCreditMemos.CreateTime,2,0,':') as Datetime)
		when len(APCreditMemos.CreateTime) = 2 then CAST('00:00:' + cast(APCreditMemos.CreateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Created' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN APCreditMemos.CountryCode = 'US' THEN 'Global'
		WHEN APCreditMemos.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,APCreditMemos.CountryCode
	,Case 
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'KENYA' then 'KE'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'BURUNDI' then 'BI'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'RWANDA' then 'RW'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'MALAWI' then 'MW'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'UGANDA' then 'UG'
	else APCreditMemos.CountryCode end as [Database]

from APCreditMemos
	left join DimSapUsers on 
		DimSapUsers.UserID = APCreditMemos.UserSignature and 
		DimSAPUsers.CountryCode = APCreditMemos.CountryCode
)
Union All

--Returns when the Goods Issue was created
(Select distinct
	60 ObjectType,
	'Goods Issue' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = GoodsIssues.DocumentDraftInternalID and
			Drafts.CountryCode = GoodsIssues.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	DimSapUsers.UserName [ActionUser],
	GoodsIssues.CreateDate [Date],
	GoodsIssues.CreateTime [Time],
	GoodsIssues.CreateDate + case when len(GoodsIssues.CreateTime) = 6 then CAST(STUFF(STUFF(GoodsIssues.CreateTime,5,0,':'),3,0,':') as Datetime)
		when len(GoodsIssues.CreateTime) = 5 then CAST(STUFF(STUFF(GoodsIssues.CreateTime,4,0,':'),2,0,':') as Datetime)
		when len(GoodsIssues.CreateTime) = 4 then CAST('00:' + STUFF(GoodsIssues.CreateTime,3,0,':') as Datetime)
		when len(GoodsIssues.CreateTime) = 3 then CAST('00:0' + STUFF(GoodsIssues.CreateTime,2,0,':') as Datetime)
		when len(GoodsIssues.CreateTime) = 2 then CAST('00:00:' + cast(GoodsIssues.CreateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Created' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN GoodsIssues.CountryCode = 'US' THEN 'Global'
		WHEN GoodsIssues.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,GoodsIssues.CountryCode
	,Case 
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'KENYA' then 'KE'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'BURUNDI' then 'BI'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'RWANDA' then 'RW'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'MALAWI' then 'MW'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'UGANDA' then 'UG'
	else GoodsIssues.CountryCode end as [Database]

from GoodsIssues
	left join DimSapUsers on 
		DimSapUsers.UserID = GoodsIssues.UserSignature and 
		DimSAPUsers.CountryCode = GoodsIssues.CountryCode
)
Union All

--Returns when the Goods Receipt was created
(Select distinct
	59 ObjectType,
	'Goods Receipt' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = GoodsReceipts.DocumentDraftInternalID and
			Drafts.CountryCode = GoodsReceipts.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	DimSapUsers.UserName [ActionUser],
	GoodsReceipts.CreateDate [Date],
	GoodsReceipts.CreateTime [Time],
	GoodsReceipts.CreateDate + case when len(GoodsReceipts.CreateTime) = 6 then CAST(STUFF(STUFF(GoodsReceipts.CreateTime,5,0,':'),3,0,':') as Datetime)
		when len(GoodsReceipts.CreateTime) = 5 then CAST(STUFF(STUFF(GoodsReceipts.CreateTime,4,0,':'),2,0,':') as Datetime)
		when len(GoodsReceipts.CreateTime) = 4 then CAST('00:' + STUFF(GoodsReceipts.CreateTime,3,0,':') as Datetime)
		when len(GoodsReceipts.CreateTime) = 3 then CAST('00:0' + STUFF(GoodsReceipts.CreateTime,2,0,':') as Datetime)
		when len(GoodsReceipts.CreateTime) = 2 then CAST('00:00:' + cast(GoodsReceipts.CreateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Created' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN GoodsReceipts.CountryCode = 'US' THEN 'Global'
		WHEN GoodsReceipts.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,GoodsReceipts.CountryCode
	,Case 
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'KENYA' then 'KE'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'BURUNDI' then 'BI'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'RWANDA' then 'RW'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'MALAWI' then 'MW'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'UGANDA' then 'UG'
	else GoodsReceipts.CountryCode end as [Database]

from GoodsReceipts
	left join DimSapUsers on 
		DimSapUsers.UserID = GoodsReceipts.UserSignature and 
		DimSAPUsers.CountryCode = GoodsReceipts.CountryCode
)
Union All

--Returns when the Inventory Transfer was created
(Select distinct
	67 ObjectType,
	'Inventory Transfer' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = InventoryTransfers.DocumentDraftInternalID and
			Drafts.CountryCode = InventoryTransfers.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	DimSapUsers.UserName [ActionUser],
	InventoryTransfers.CreateDate [Date],
	InventoryTransfers.CreateTime [Time],
	InventoryTransfers.CreateDate + case when len(InventoryTransfers.CreateTime) = 6 then CAST(STUFF(STUFF(InventoryTransfers.CreateTime,5,0,':'),3,0,':') as Datetime)
		when len(InventoryTransfers.CreateTime) = 5 then CAST(STUFF(STUFF(InventoryTransfers.CreateTime,4,0,':'),2,0,':') as Datetime)
		when len(InventoryTransfers.CreateTime) = 4 then CAST('00:' + STUFF(InventoryTransfers.CreateTime,3,0,':') as Datetime)
		when len(InventoryTransfers.CreateTime) = 3 then CAST('00:0' + STUFF(InventoryTransfers.CreateTime,2,0,':') as Datetime)
		when len(InventoryTransfers.CreateTime) = 2 then CAST('00:00:' + cast(InventoryTransfers.CreateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Created' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN InventoryTransfers.CountryCode = 'US' THEN 'Global'
		WHEN InventoryTransfers.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,InventoryTransfers.CountryCode
	,Case 
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'KENYA' then 'KE'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'BURUNDI' then 'BI'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'RWANDA' then 'RW'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'MALAWI' then 'MW'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'UGANDA' then 'UG'
	else InventoryTransfers.CountryCode end as [Database]

from InventoryTransfers
	left join DimSapUsers on 
		DimSapUsers.UserID = InventoryTransfers.UserSignature and 
		DimSAPUsers.CountryCode = InventoryTransfers.CountryCode
)
Union All 

--Returns when the AR Invoice was created
(Select distinct
	13 ObjectType,
	'AR Invoice' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = ARInvoices.DocumentDraftInternalID and
			Drafts.CountryCode = ARInvoices.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	DimSapUsers.UserName [ActionUser],
	ARInvoices.CreateDate [Date],
	ARInvoices.CreateTime [Time],
	ARInvoices.CreateDate + case when len(ARInvoices.CreateTime) = 6 then CAST(STUFF(STUFF(ARInvoices.CreateTime,5,0,':'),3,0,':') as Datetime)
		when len(ARInvoices.CreateTime) = 5 then CAST(STUFF(STUFF(ARInvoices.CreateTime,4,0,':'),2,0,':') as Datetime)
		when len(ARInvoices.CreateTime) = 4 then CAST('00:' + STUFF(ARInvoices.CreateTime,3,0,':') as Datetime)
		when len(ARInvoices.CreateTime) = 3 then CAST('00:0' + STUFF(ARInvoices.CreateTime,2,0,':') as Datetime)
		when len(ARInvoices.CreateTime) = 2 then CAST('00:00:' + cast(ARInvoices.CreateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Created' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN ARInvoices.CountryCode = 'US' THEN 'Global'
		WHEN ARInvoices.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,ARInvoices.CountryCode
	,Case 
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'KENYA' then 'KE'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'BURUNDI' then 'BI'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'RWANDA' then 'RW'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'MALAWI' then 'MW'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'UGANDA' then 'UG'
	else ARInvoices.CountryCode end as [Database]

from ARInvoices
	left join DimSapUsers on 
		DimSapUsers.UserID = ARInvoices.UserSignature and 
		DimSAPUsers.CountryCode = ARInvoices.CountryCode
)
Union All

--Returns the last time the AP invoice was updated
(Select distinct
	18 ObjectType,
	'A/P Invoice' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = APInvoices.DocumentDraftInternalID AND
			Drafts.CountryCode = APInvoices.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = APInvoices.UserSignature2 AND
			DimSapUsers.CountryCode = APInvoices.CountryCode
	) [ActionUser],
	APInvoices.UpdateDate [Date],
	UpdateTime [Time],
	APInvoices.UpdateDate + case when len(UpdateTime) = 6 then CAST(STUFF(STUFF(UpdateTime,5,0,':'),3,0,':') as Datetime)
		when len(UpdateTime) = 5 then CAST(STUFF(STUFF(UpdateTime,4,0,':'),2,0,':') as Datetime)
		when len(UpdateTime) = 4 then CAST('00:' + STUFF(UpdateTime,3,0,':') as Datetime)
		when len(UpdateTime) = 3 then CAST('00:0' + STUFF(UpdateTime,2,0,':') as Datetime)
		when len(UpdateTime) = 2 then CAST('00:00:' + cast(UpdateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Updated' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN APInvoices.CountryCode = 'US' THEN 'Global'
		WHEN APInvoices.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,APInvoices.CountryCode
	,Case 
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'KENYA' then 'KE'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'BURUNDI' then 'BI'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'RWANDA' then 'RW'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'MALAWI' then 'MW'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when APInvoices.countrycode = 'US' and APInvoices.U_TRSR_Country = 'UGANDA' then 'UG'
	else APInvoices.CountryCode end as [Database]

from APInvoices 
	left join DimSapUsers on 
		DimSapUsers.UserID = APInvoices.UserSignature AND
		DimSapUsers.CountryCode = APInvoices.CountryCode

Where (APInvoices.Updatedate <> APInvoices.Createdate or CreateTime <= UpdateTime - 10)
)
Union All

--Returns the last time the Purchase ORder  was updated
(Select distinct
	22 ObjectType,
	'Purchase Order' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = PurchaseOrders.DocumentDraftInternalID AND
			Drafts.CountryCode = PurchaseOrders.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = PurchaseOrders.UserSignature2 AND
			DimSapUsers.CountryCode = PurchaseOrders.CountryCode
	) [ActionUser],
	PurchaseOrders.UpdateDate [Date],
	UpdateTime [Time],
	PurchaseOrders.UpdateDate + case when len(UpdateTime) = 6 then CAST(STUFF(STUFF(UpdateTime,5,0,':'),3,0,':') as Datetime)
		when len(UpdateTime) = 5 then CAST(STUFF(STUFF(UpdateTime,4,0,':'),2,0,':') as Datetime)
		when len(UpdateTime) = 4 then CAST('00:' + STUFF(UpdateTime,3,0,':') as Datetime)
		when len(UpdateTime) = 3 then CAST('00:0' + STUFF(UpdateTime,2,0,':') as Datetime)
		when len(UpdateTime) = 2 then CAST('00:00:' + cast(UpdateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Updated' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN PurchaseOrders.CountryCode = 'US' THEN 'Global'
		WHEN PurchaseOrders.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,PurchaseOrders.CountryCode
	,Case 
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'KENYA' then 'KE'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'BURUNDI' then 'BI'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'RWANDA' then 'RW'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'MALAWI' then 'MW'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when PurchaseOrders.countrycode = 'US' and PurchaseOrders.U_TRSR_Country = 'UGANDA' then 'UG'
	else PurchaseOrders.CountryCode end as [Database]

from PurchaseOrders 
	left join DimSapUsers on 
		DimSapUsers.UserID = PurchaseOrders.UserSignature AND
		DimSapUsers.CountryCode = PurchaseOrders.CountryCode

Where (PurchaseOrders.Updatedate <> PurchaseOrders.Createdate or CreateTime <= UpdateTime - 10)
)
Union All 

--Returns last time the AP down payment invoice was updated
(Select distinct
	204 ObjectType,
	'A/P Down Payment' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = APDownPayments.DocumentDraftInternalID AND
			Drafts.CountryCode = APDownPayments.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = APDownPayments.UserSignature2 AND
			DimSapUsers.CountryCode = APDownPayments.CountryCode
	) [ActionUser],
	APDownPayments.UpdateDate [Date],
	UpdateTime [Time],
	APDownPayments.UpdateDate + case when len(UpdateTime) = 6 then CAST(STUFF(STUFF(UpdateTime,5,0,':'),3,0,':') as Datetime)
		when len(UpdateTime) = 5 then CAST(STUFF(STUFF(UpdateTime,4,0,':'),2,0,':') as Datetime)
		when len(UpdateTime) = 4 then CAST('00:' + STUFF(UpdateTime,3,0,':') as Datetime)
		when len(UpdateTime) = 3 then CAST('00:0' + STUFF(UpdateTime,2,0,':') as Datetime)
		when len(UpdateTime) = 2 then CAST('00:00:' + cast(UpdateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Updated' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN APDownPayments.CountryCode = 'US' THEN 'Global'
		WHEN APDownPayments.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,APDownPayments.CountryCode
	,Case 
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'KENYA' then 'KE'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'BURUNDI' then 'BI'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'RWANDA' then 'RW'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'MALAWI' then 'MW'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when APDownPayments.countrycode = 'US' and APDownPayments.U_TRSR_Country = 'UGANDA' then 'UG'
	else APDownPayments.CountryCode end as [Database]
		
from APDownPayments 
	left join DimSapUsers on 
		DimSapUsers.UserID = APDownPayments.UserSign and
		DimSapUsers.CountryCode = APDownPayments.CountryCode

Where (APDownPayments.Updatedate <> APDownPayments.Createdate or CreateTime <= UpdateTime - 10)
)
Union All 

--Returns last time the GRPO was updated
(Select distinct
	20 ObjectType,
	'Goods Receipt PO' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = GoodsReceiptPO.DocumentDraftInternalID AND
			Drafts.CountryCode = GoodsReceiptPO.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = GoodsReceiptPO.UserSignature2 AND
			DimSapUsers.CountryCode = GoodsReceiptPO.CountryCode
	) [ActionUser],
	GoodsReceiptPO.UpdateDate [Date],
	UpdateTime [Time],
	GoodsReceiptPO.UpdateDate + case when len(UpdateTime) = 6 then CAST(STUFF(STUFF(UpdateTime,5,0,':'),3,0,':') as Datetime)
		when len(UpdateTime) = 5 then CAST(STUFF(STUFF(UpdateTime,4,0,':'),2,0,':') as Datetime)
		when len(UpdateTime) = 4 then CAST('00:' + STUFF(UpdateTime,3,0,':') as Datetime)
		when len(UpdateTime) = 3 then CAST('00:0' + STUFF(UpdateTime,2,0,':') as Datetime)
		when len(UpdateTime) = 2 then CAST('00:00:' + cast(UpdateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Updated' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN GoodsReceiptPO.CountryCode = 'US' THEN 'Global'
		WHEN GoodsReceiptPO.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,GoodsReceiptPO.CountryCode
	,Case 
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'KENYA' then 'KE'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'BURUNDI' then 'BI'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'RWANDA' then 'RW'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'MALAWI' then 'MW'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when GoodsReceiptPO.countrycode = 'US' and GoodsReceiptPO.U_TRSR_Country = 'UGANDA' then 'UG'
	else GoodsReceiptPO.CountryCode end as [Database]
		
from GoodsReceiptPO 
	left join DimSapUsers on 
		DimSapUsers.UserID = GoodsReceiptPO.UserSignature and
		DimSapUsers.CountryCode = GoodsReceiptPO.CountryCode

Where (GoodsReceiptPO.Updatedate <> GoodsReceiptPO.Createdate or CreateTime <= UpdateTime - 10)
)
Union All 

--Returns last time the AP Credit Memo was updated
(Select distinct
	19 ObjectType,
	'AP Credit Memo' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = APCreditMemos.DocumentDraftInternalID AND
			Drafts.CountryCode = APCreditMemos.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = APCreditMemos.UserSignature2 AND
			DimSapUsers.CountryCode = APCreditMemos.CountryCode
	) [ActionUser],
	APCreditMemos.UpdateDate [Date],
	UpdateTime [Time],
	APCreditMemos.UpdateDate + case when len(UpdateTime) = 6 then CAST(STUFF(STUFF(UpdateTime,5,0,':'),3,0,':') as Datetime)
		when len(UpdateTime) = 5 then CAST(STUFF(STUFF(UpdateTime,4,0,':'),2,0,':') as Datetime)
		when len(UpdateTime) = 4 then CAST('00:' + STUFF(UpdateTime,3,0,':') as Datetime)
		when len(UpdateTime) = 3 then CAST('00:0' + STUFF(UpdateTime,2,0,':') as Datetime)
		when len(UpdateTime) = 2 then CAST('00:00:' + cast(UpdateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Updated' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN APCreditMemos.CountryCode = 'US' THEN 'Global'
		WHEN APCreditMemos.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,APCreditMemos.CountryCode
	,Case 
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'KENYA' then 'KE'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'BURUNDI' then 'BI'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'RWANDA' then 'RW'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'MALAWI' then 'MW'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when APCreditMemos.countrycode = 'US' and APCreditMemos.U_TRSR_Country = 'UGANDA' then 'UG'
	else APCreditMemos.CountryCode end as [Database]
		
from APCreditMemos 
	left join DimSapUsers on 
		DimSapUsers.UserID = APCreditMemos.UserSignature and
		DimSapUsers.CountryCode = APCreditMemos.CountryCode

Where (APCreditMemos.Updatedate <> APCreditMemos.Createdate or CreateTime <= UpdateTime - 10)
)
Union All 

--Returns last time the Goods Issue was updated
(Select distinct
	60 ObjectType,
	'Goods Issue' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = GoodsIssues.DocumentDraftInternalID AND
			Drafts.CountryCode = GoodsIssues.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = GoodsIssues.UserSignature2 AND
			DimSapUsers.CountryCode = GoodsIssues.CountryCode
	) [ActionUser],
	GoodsIssues.UpdateDate [Date],
	UpdateTime [Time],
	GoodsIssues.UpdateDate + case when len(UpdateTime) = 6 then CAST(STUFF(STUFF(UpdateTime,5,0,':'),3,0,':') as Datetime)
		when len(UpdateTime) = 5 then CAST(STUFF(STUFF(UpdateTime,4,0,':'),2,0,':') as Datetime)
		when len(UpdateTime) = 4 then CAST('00:' + STUFF(UpdateTime,3,0,':') as Datetime)
		when len(UpdateTime) = 3 then CAST('00:0' + STUFF(UpdateTime,2,0,':') as Datetime)
		when len(UpdateTime) = 2 then CAST('00:00:' + cast(UpdateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Updated' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN GoodsIssues.CountryCode = 'US' THEN 'Global'
		WHEN GoodsIssues.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,GoodsIssues.CountryCode
	,Case 
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'KENYA' then 'KE'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'BURUNDI' then 'BI'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'RWANDA' then 'RW'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'MALAWI' then 'MW'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when GoodsIssues.countrycode = 'US' and GoodsIssues.U_TRSR_Country = 'UGANDA' then 'UG'
	else GoodsIssues.CountryCode end as [Database]
		
from GoodsIssues 
	left join DimSapUsers on 
		DimSapUsers.UserID = GoodsIssues.UserSignature and
		DimSapUsers.CountryCode = GoodsIssues.CountryCode

Where (GoodsIssues.Updatedate <> GoodsIssues.Createdate or CreateTime <= UpdateTime - 10)
)
Union All 

--Returns last time the Goods Receipt was updated
(Select distinct
	59 ObjectType,
	'Goods Receipt' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = GoodsReceipts.DocumentDraftInternalID AND
			Drafts.CountryCode = GoodsReceipts.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = GoodsReceipts.UserSignature2 AND
			DimSapUsers.CountryCode = GoodsReceipts.CountryCode
	) [ActionUser],
	GoodsReceipts.UpdateDate [Date],
	UpdateTime [Time],
	GoodsReceipts.UpdateDate + case when len(UpdateTime) = 6 then CAST(STUFF(STUFF(UpdateTime,5,0,':'),3,0,':') as Datetime)
		when len(UpdateTime) = 5 then CAST(STUFF(STUFF(UpdateTime,4,0,':'),2,0,':') as Datetime)
		when len(UpdateTime) = 4 then CAST('00:' + STUFF(UpdateTime,3,0,':') as Datetime)
		when len(UpdateTime) = 3 then CAST('00:0' + STUFF(UpdateTime,2,0,':') as Datetime)
		when len(UpdateTime) = 2 then CAST('00:00:' + cast(UpdateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Updated' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN GoodsReceipts.CountryCode = 'US' THEN 'Global'
		WHEN GoodsReceipts.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,GoodsReceipts.CountryCode
	,Case 
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'KENYA' then 'KE'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'BURUNDI' then 'BI'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'RWANDA' then 'RW'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'MALAWI' then 'MW'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when GoodsReceipts.countrycode = 'US' and GoodsReceipts.U_TRSR_Country = 'UGANDA' then 'UG'
	else GoodsReceipts.CountryCode end as [Database]
		
from GoodsReceipts 
	left join DimSapUsers on 
		DimSapUsers.UserID = GoodsReceipts.UserSignature and
		DimSapUsers.CountryCode = GoodsReceipts.CountryCode

Where (GoodsReceipts.Updatedate <> GoodsReceipts.Createdate or CreateTime <= UpdateTime - 10)
)
Union All 

--Returns last time the Inventory Transfer was updated
(Select distinct
	67 ObjectType,
	'Inventory Transfer' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = InventoryTransfers.DocumentDraftInternalID AND
			Drafts.CountryCode = InventoryTransfers.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = InventoryTransfers.UserSignature2 AND
			DimSapUsers.CountryCode = InventoryTransfers.CountryCode
	) [ActionUser],
	InventoryTransfers.UpdateDate [Date],
	UpdateTime [Time],
	InventoryTransfers.UpdateDate + case when len(UpdateTime) = 6 then CAST(STUFF(STUFF(UpdateTime,5,0,':'),3,0,':') as Datetime)
		when len(UpdateTime) = 5 then CAST(STUFF(STUFF(UpdateTime,4,0,':'),2,0,':') as Datetime)
		when len(UpdateTime) = 4 then CAST('00:' + STUFF(UpdateTime,3,0,':') as Datetime)
		when len(UpdateTime) = 3 then CAST('00:0' + STUFF(UpdateTime,2,0,':') as Datetime)
		when len(UpdateTime) = 2 then CAST('00:00:' + cast(UpdateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Updated' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN InventoryTransfers.CountryCode = 'US' THEN 'Global'
		WHEN InventoryTransfers.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,InventoryTransfers.CountryCode
	,Case 
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'KENYA' then 'KE'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'BURUNDI' then 'BI'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'RWANDA' then 'RW'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'MALAWI' then 'MW'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when InventoryTransfers.countrycode = 'US' and InventoryTransfers.U_TRSR_Country = 'UGANDA' then 'UG'
	else InventoryTransfers.CountryCode end as [Database]
		
from InventoryTransfers 
	left join DimSapUsers on 
		DimSapUsers.UserID = InventoryTransfers.UserSignature and
		DimSapUsers.CountryCode = InventoryTransfers.CountryCode

Where (InventoryTransfers.Updatedate <> InventoryTransfers.Createdate or CreateTime <= UpdateTime - 10)

Union All 

--Returns last time the AR Invoice was updated
(Select distinct
	13 ObjectType,
	'AR Invoices' as TransactionType,
	DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = ARInvoices.DocumentDraftInternalID AND
			Drafts.CountryCode = ARInvoices.CountryCode
	) [DraftNum] ,
	DocumentEntry,
	DocumentNumber,
	DocumentDate,
	DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = ARInvoices.UserSignature2 AND
			DimSapUsers.CountryCode = ARInvoices.CountryCode
	) [ActionUser],
	ARInvoices.UpdateDate [Date],
	UpdateTime [Time],
	ARInvoices.UpdateDate + case when len(UpdateTime) = 6 then CAST(STUFF(STUFF(UpdateTime,5,0,':'),3,0,':') as Datetime)
		when len(UpdateTime) = 5 then CAST(STUFF(STUFF(UpdateTime,4,0,':'),2,0,':') as Datetime)
		when len(UpdateTime) = 4 then CAST('00:' + STUFF(UpdateTime,3,0,':') as Datetime)
		when len(UpdateTime) = 3 then CAST('00:0' + STUFF(UpdateTime,2,0,':') as Datetime)
		when len(UpdateTime) = 2 then CAST('00:00:' + cast(UpdateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Updated' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN ARInvoices.CountryCode = 'US' THEN 'Global'
		WHEN ARInvoices.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,ARInvoices.CountryCode
	,Case 
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'KENYA' then 'KE'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'BURUNDI' then 'BI'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'RWANDA' then 'RW'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'MALAWI' then 'MW'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when ARInvoices.countrycode = 'US' and ARInvoices.U_TRSR_Country = 'UGANDA' then 'UG'
	else ARInvoices.CountryCode end as [Database]
		
from ARInvoices 
	left join DimSapUsers on 
		DimSapUsers.UserID = ARInvoices.UserSignature and
		DimSapUsers.CountryCode = ARInvoices.CountryCode

Where (ARInvoices.Updatedate <> ARInvoices.Createdate or CreateTime <= UpdateTime - 10)
)
Union All 

--Returns when the Document was updated 
(Select distinct
	DocumentHistory.ObjectType,
	DimTransactionType.[Transaction] as TransactionType,
	DocumentHistory.DocumentDraftInternalID DraftEntry,
	(
		select DocumentNumber 
		from Drafts 
		where 
			Drafts.DocumentEntry = DocumentHistory.DocumentDraftInternalID and
			Drafts.CountryCode = DocumentHistory.CountryCode
	) [DraftNum] ,
	DocumentHistory.DocumentEntry,
	DocumentHistory.DocumentNumber,
	DocumentHistory.DocumentDate,
	DocumentHistory.DocumentSubmissionDate,
	DimSapUsers.UserName [DocCreator],
	(
		select UserName 
		From DimSapUsers 
		where 
			DimSapUsers.UserID = DocumentHistory.UserSignature2 and
			DimSapUsers.CountryCode = DocumentHistory.CountryCode
	) [ActionUser],
	DocumentHistory.UpdateDate [Date],
	DocumentHistory.UpdateTime [Time],
	DocumentHistory.UpdateDate + case when len(DocumentHistory.UpdateTime) = 6 then CAST(STUFF(STUFF(DocumentHistory.UpdateTime,5,0,':'),3,0,':') as Datetime)
		when len(DocumentHistory.UpdateTime) = 5 then CAST(STUFF(STUFF(DocumentHistory.UpdateTime,4,0,':'),2,0,':') as Datetime)
		when len(DocumentHistory.UpdateTime) = 4 then CAST('00:' + STUFF(DocumentHistory.UpdateTime,3,0,':') as Datetime)
		when len(DocumentHistory.UpdateTime) = 3 then CAST('00:0' + STUFF(DocumentHistory.UpdateTime,2,0,':') as Datetime)
		when len(DocumentHistory.UpdateTime) = 2 then CAST('00:00:' + cast(DocumentHistory.UpdateTime as nvarchar(2)) as datetime)  end [DateTime],
	'Document Updated' Action,
	case when LEFT(DimSapUsers.UserCode,3) in ('GLB','PRC') then 'Sourcing' else 'Other' end as Team
	,CASE
		WHEN DocumentHistory.CountryCode = 'US' THEN 'Global'
		WHEN APInvoices.U_Season is not null then 'Global'
		WHEN PurchaseOrders.U_Season is not null then 'Global'
		WHEN APDownPayments.U_Season is not null then 'Global'
		WHEN GoodsReceipts.U_Season is not null then 'Global'
		WHEN GoodsIssues.U_Season is not null then 'Global'
		WHEN APCreditMemos.U_Season is not null then 'Global'
		WHEN ARInvoices.U_Season is not null then 'Global'
		WHEN InventoryTransfers.U_Season is not null then 'Global'
	ELSE 'InCountry' end as SourcingTeam
	,DocumentHistory.CountryCode
	,Case 
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'KENYA' then 'KE'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'BURUNDI' then 'BI'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'TANZANIA' then 'TZ'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'RWANDA' then 'RW'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'MALAWI' then 'MW'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'ETHIOPIA' then 'ETH'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'ZAMBIA' then 'ZA'
		when COALESCE(APInvoices.countrycode,PurchaseOrders.CountryCode,APDownPayments.CountryCode,GoodsReceiptPO.CountryCode,GoodsIssues.CountryCode,ARInvoices.CountryCode
			,GoodsReceipts.CountryCode,APCreditMemos.CountryCode,InventoryTransfers.CountryCode) = 'US' and 
			COALESCE(APInvoices.U_TRSR_Country,PurchaseOrders.U_TRSR_Country,APDownPayments.U_TRSR_Country,GoodsReceiptPO.U_TRSR_Country,GoodsIssues.U_TRSR_Country
			,ARInvoices.U_TRSR_Country,GoodsReceipts.U_TRSR_Country,APCreditMemos.U_TRSR_Country,InventoryTransfers.U_TRSR_Country) = 'UGANDA' then 'UG'
	else DocumentHistory.CountryCode end as [Database]

from DocumentHistory
	left join DimSapUsers on 
		DimSapUsers.UserID = DocumentHistory.UserSignature and
		DimSapUsers.CountryCode = DocumentHistory.CountryCode
	left join DimTransactionType  on 
		DocumentHistory.ObjectType = DimTransactionType.transid
	left join APInvoices on 
		APInvoices.DocumentDraftInternalID = DocumentHistory.DocumentEntry and 
		APInvoices.CountryCode = DocumentHistory.CountryCode
	left join PurchaseOrders on 
		PurchaseOrders.DocumentDraftInternalID = DocumentHistory.DocumentEntry and 
		PurchaseOrders.CountryCode = DocumentHistory.CountryCode
	left join APDownPayments on 
		APDownPayments.DocumentDraftInternalID = DocumentHistory.DocumentEntry and 
		APDownPayments.CountryCode = DocumentHistory.CountryCode
	left join GoodsReceiptPO on 
		GoodsReceiptPO.DocumentDraftInternalID = DocumentHistory.DocumentEntry and 
		GoodsReceiptPO.CountryCode = DocumentHistory.CountryCode
	left join ARInvoices on 
		ARInvoices.DocumentDraftInternalID = DocumentHistory.DocumentEntry and 
		ARInvoices.CountryCode = DocumentHistory.CountryCode
	left join GoodsReceipts on 
		GoodsReceipts.DocumentDraftInternalID = DocumentHistory.DocumentEntry and 
		GoodsReceipts.CountryCode = DocumentHistory.CountryCode
	left join GoodsIssues on 
		GoodsIssues.DocumentDraftInternalID = DocumentHistory.DocumentEntry and 
		GoodsIssues.CountryCode = DocumentHistory.CountryCode
	left join InventoryTransfers on 
		InventoryTransfers.DocumentDraftInternalID = DocumentHistory.DocumentEntry and 
		InventoryTransfers.CountryCode = DocumentHistory.CountryCode
	left join APCreditMemos on 
		APCreditMemos.DocumentDraftInternalID = DocumentHistory.DocumentEntry and 
		APCreditMemos.CountryCode = DocumentHistory.CountryCode
	
where DocumentHistory.ObjectType in (18, 22, 204, 2018, 22, 204, 20,13,19,59,60,67) and 
	(DocumentHistory.Updatedate <> DocumentHistory.CreateDate or DocumentHistory.CreateTime <= DocumentHistory.UpdateTime - 10)
)
)
) A

