/*
Updates:
	V3 DK 2019-10-22: Update Att. 2 to use the correct file extension field 
	V2 DK 2019-10-08: Added U_webprid and Requestor and also changed table pull from Delivery to use Deliveries 
	V1 MW 2019-09-03: Adapted from log.v_Movements v21 just replaceing the wharehouse bit of the where clause with a warehouse column to include all warehouses

*/

CREATE view dbo.v_MovementsAll as
--use oaf_sap_datawarehouse;

select 
	BinLocations.Sublevel1Code as Bin
	,InventoryLogs.[Location] as Warehouse
	,Warehouse.[Type] as WarehouseType
	,case
		when actiontype IN (20,2) then CAST(ISNULL(-BinTransactionLogs.Quantity,-InventoryLogs.Quantity) as float) 
		else CAST(ISNULL(BinTransactionLogs.Quantity,InventoryLogs.Quantity) as float) 
	end as Quantity
	,Case 
		-- first, when there are multiple bin lines for each OILM line (OILM is at the item/warehouse level; query is at item/warehouse/bin/(batch) level), 
		-- then the total value of the line is a percentatge based on the Bin Quantity / Total Quantity
		When InventoryLogs.Quantity <> 0 and (
			Select count(t3.Sublevel1Code) 
			from InventoryLogs t1  
			Left Join BinTransactionLogs t2 on t2.MessageID = t1.MessageID and t2.CountryCode = t1.CountryCode
			left join BinLocations t3 on t2.BinInternalNumber = t3.InternalNumber and t2.CountryCode = t3.CountryCode
			where InventoryLogs.[Location] = t1.[Location] and InventoryLogs.ItemCode = t1.ItemCode and t1.DocumentEntry = InventoryLogs.DocumentEntry and InventoryLogs.TransactionType = t1.TransactionType and InventoryLogs.DocumentLineNumber = t1.DocumentLineNumber and t1.CountryCode = InventoryLogs.CountryCode
		) > 1 Then cast(WarehouseJournal.TransactionValue * ISNULL(BinTransactionLogs.Quantity,InventoryLogs.Quantity) / InventoryLogs.Quantity as float) 
		Else  cast(WarehouseJournal.TransactionValue as float) 
	end As LineTotal
	-- repeat all that crazy logic for usd
	,Case 
		When InventoryLogs.Quantity <> 0 and (
			Select count(t3.Sublevel1Code) 
			from InventoryLogs t1  
			Left Join BinTransactionLogs t2 on t2.MessageID = t1.MessageID and t2.CountryCode = t1.CountryCode
			left join BinLocations t3 on t2.BinInternalNumber = t3.InternalNumber and t2.CountryCode = t3.CountryCode
			where InventoryLogs.[Location] = t1.[Location] and InventoryLogs.ItemCode = t1.ItemCode and t1.DocumentEntry = InventoryLogs.DocumentEntry and InventoryLogs.TransactionType = t1.TransactionType and InventoryLogs.DocumentLineNumber = t1.DocumentLineNumber and t1.CountryCode = InventoryLogs.CountryCode
		) > 1 Then cast(WarehouseJournal.TransactionValue * ISNULL(BinTransactionLogs.Quantity,InventoryLogs.Quantity) / InventoryLogs.Quantity / ExchangeRates.Rate  as float) 
		Else  cast(WarehouseJournal.TransactionValue/ExchangeRates.Rate as float) 
	end As LineTotalUSD
	,InventoryLogs.ItemCode
	,Item.InvntryUom as UoM
	,Item.ItemName as ItemName
	,Item.ItmsGrpNam as ItemGroup 
	,AccumulatorType as AccumType
	,ActionType
	,case when actiontype in (1,2,19,20) then 'Y' else 'N' end as [QuantityTx]
	,cast(InventoryLogs.DocumentDate as datetime) as DocDate
	,InventoryLogs.CreateDate
	,InventoryLogs.BaseReference as SAPDocNum
	,InventoryLogs.DocumentLineNumber as SAPLineNum
	,InventoryLogs.DepartmentCode as DeptCode
	,InventoryLogs.LocationCode as LocCode
	,InventoryLogs.BaseTransactionType as BaseType
	,InventoryLogs.TransactionType as TransType
	,Case when InventoryLogs.BaseTransactionType = '202' then 'Production Order'
		when InventoryLogs.TransactionType = '13' then	'A/R Invoice'
		When InventoryLogs.TransactionType = '14' Then	'A/R Credit Memo'
		When InventoryLogs.TransactionType = '15' Then	'Delivery'
		When InventoryLogs.TransactionType = '16' Then	'Delivery'
		When InventoryLogs.TransactionType = '132' Then 'Correction Invoice'
		When InventoryLogs.TransactionType = '20' Then	'Goods Receipt PO'
		When InventoryLogs.TransactionType = '202' Then 'Production Order'
		When InventoryLogs.TransactionType = '21' Then	'Goods Return'
		When InventoryLogs.TransactionType = '18' Then	'A/P Invoice'
		When InventoryLogs.TransactionType = '19' Then	'A/P Credit Memo'
		When InventoryLogs.TransactionType = '-2' Then	'Opening Balance'
		When InventoryLogs.TransactionType = '58' Then	'Stock Update'
		When InventoryLogs.TransactionType = '59' Then	'Goods Receipt'
		When InventoryLogs.TransactionType = '60' Then	'Goods Issue'
		When InventoryLogs.TransactionType = '68' Then	'Work Instructions'
		When InventoryLogs.TransactionType = '67' Then	'Inventory Transfers'
		When InventoryLogs.TransactionType = '-1' Then	'All Transactions'
		When InventoryLogs.TransactionType = '162' Then	'Inventory Revaluation'
		When InventoryLogs.TransactionType = '69' Then	'Landed Costs'
		When InventoryLogs.TransactionType = '310000001' Then	'Initial Quantity'
		When InventoryLogs.TransactionType = '10000071' Then	'Inventory Posting'
		else 'Other' end as [DocType]
	,DimSAPUsers.UserCODE as UserCode
	,DimSAPUsers.UserNAME as UserName
	,Case 	
		When InventoryLogs.TransactionType = '15' Then	Deliveries.U_WHR
		When InventoryLogs.TransactionType = '18' Then	APInvoices.U_WHR
		When InventoryLogs.TransactionType = '67' Then	InventoryTransfers.U_WHR
		When InventoryLogs.TransactionType = '59' Then	GoodsReceipts.U_WHR
		When InventoryLogs.TransactionType = '60' Then	GoodsIssues.U_WHR
		--When InventoryLogs.TransactionType = '20' Then	GoodsReceiptPO.U_WHR --to be included after field is added to the DW
		else NULL 
	end as [ReceiptNum]
	,Case 	
		When InventoryLogs.TransactionType = '15' Then	Deliveries.Comments
		When InventoryLogs.TransactionType = '18' Then	APInvoices.Comments
		When InventoryLogs.TransactionType = '67' Then	InventoryTransfers.Comments
		When InventoryLogs.TransactionType = '59' Then	GoodsReceipts.Comments
		When InventoryLogs.TransactionType = '60' Then	GoodsIssues.Comments
		When InventoryLogs.TransactionType = '20' Then	GoodsReceiptPO.Comments
		--When InventoryLogs.TransactionType = '10000071'	Then InventoryPosting.
		else NULL 
	end as Remarks
	,replace(ATC1.filename,'#','%23') as [Att. 1 Name]
	,CASE 
		WHEN ATC1.filename IS NULL and InventoryPosting.U_Attachment1 is null THEN NULL 
		WHEN ATC1.filename IS NOT NULL then replace(replace(CAST(ATC1.TargetPath AS nvarchar(MAX)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/') + '\' + Concat(replace(replace(ATC1.FileName,'%', '%25'), '#', '%23'), '.', ATC1.FileExtension)
		ELSE replace(replace(replace(replace(cast(InventoryPosting.U_Attachment1 as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '%', '%25'), '#', '%23'), '\', '/')
	END AS [Att. 1] 
	,replace(ATC2.filename,'#','%23') as [Att. 2 Name]
	,CASE 
		WHEN ATC2.filename IS NULL and InventoryPosting.U_Attachment1 is null THEN NULL 
		WHEN ATC2.filename IS NOT NULL then replace(replace(CAST(ATC2.TargetPath AS nvarchar(MAX)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/') + '\' + Concat(replace(replace(ATC2.FileName,'%', '%25'), '#', '%23'), '.', ATC2.FileExtension)
		ELSE replace(replace(replace(replace(cast(InventoryPosting.U_Attachment2 as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '%', '%25'), '#', '%23'), '\', '/')
	END AS [Att. 2]
	,InventoryLogs.CountryCode
	,InventoryLogs.DocumentEntry as DocEntry
	,coalesce(Deliveries.Canceled,InventoryTransfers.Canceled, APInvoices.Canceled) as Canceled --ODLN and OWTR are both mising the field canceled
	,Country.CountryName 
	,Case
		when InventoryLogs.TransactionType = '67' and ActionType = 1 then 'Transfer In'
		when InventoryLogs.TransactionType = '67' and ActionType = 2 then 'Transfer Out'
		when InventoryLogs.TransactionType = '67' and ActionType = 19 then 'Bin In'
		when InventoryLogs.TransactionType = '67' and ActionType = 20 then 'Bin Out'
	else 'Not a transfer' end as 'InventoryTransferType'
	,GoodsIssues.U_WebPRID as WebGoodsIssueID
	,coalesce(APInvoices.U_WebPRID,GoodsIssues.U_WebPRID,GoodsReceiptPO.u_webprid,Deliveries.U_WebPRID,InventoryTransfers.U_WebPRID) WebPRID
	,coalesce(APInvoices.U_Requestor,GoodsIssues.U_Requestor,GoodsReceiptPO.Requestor,Deliveries.U_Requestor,InventoryTransfers.U_Requestor) Requestor


from InventoryLogs
left join DimWarehouses as Warehouse on InventoryLogs.[Location] = Warehouse.WarehouseCode and InventoryLogs.CountryID = Warehouse.CountryID 
Left Join BinTransactionLogs on BinTransactionLogs.MessageID = InventoryLogs.MessageID and InventoryLogs.Countrycode = BinTransactionLogs.CountryCode
left join BinLocations on BinTransactionLogs.BinInternalNumber = BinLocations.InternalNumber and InventoryLogs.Countrycode = BinLocations.CountryCode
left join DimItem as Item on InventoryLogs.itemcode=item.itemcode and InventoryLogs.countrycode=item.countrycode
left join WarehouseJournal on 
	InventoryLogs.TransactionType = WarehouseJournal.TransactionType 
	and InventoryLogs.DocumentEntry = WarehouseJournal.CreatedBy
	and InventoryLogs.itemcode = WarehouseJournal.ItemCode 
	and InventoryLogs.[Location] = WarehouseJournal.Warehouse 
	and InventoryLogs.DocumentLineNumber = WarehouseJournal.DocumentRowNumber 
	and InventoryLogs.Countrycode = WarehouseJournal.CountryCode
	and WarehouseJournal.TransactionNumber is not null -- this might be required bc of a warehouse error - follow up
left join DimSAPUsers on DimSAPUsers.USERID = InventoryLogs.UserSignature and InventoryLogs.Countrycode = DimSAPUsers.CountryCode
left join ExchangeRates on InventoryLogs.CountryCode = ExchangeRates.CountryCode and ExchangeRates.Currency = 'USD' and InventoryLogs.DocumentDate = ExchangeRates.RateDate
join [$(OAF_SHARED_DIMENSIONS)].dbo.dimcountry country on InventoryLogs.countryid = country.countryid

--Source Doc + attachment ---
left join GoodsIssues on GoodsIssues.DocumentEntry = InventoryLogs.DocumentEntry and InventoryLogs.TransactionType = '60' and InventoryLogs.Countrycode = GoodsIssues.CountryCode and InventoryLogs.DocumentLineNumber = GoodsIssues.RowNumber
left join GoodsReceiptPO on GoodsReceiptPO.DocumentEntry = InventoryLogs.DocumentEntry and InventoryLogs.TransactionType ='20' and InventoryLogs.CountryCode = GoodsReceiptPO.CountryCode and GoodsReceiptPO.RowNumber = InventoryLogs.DocumentLineNumber
left join GoodsReceipts on GoodsReceipts.DocumentEntry = InventoryLogs.DocumentEntry and InventoryLogs.TransactionType = '59' and InventoryLogs.Countrycode = GoodsReceipts.CountryCode and GoodsReceipts.RowNumber = InventoryLogs.DocumentLineNumber
left join APInvoices on APInvoices.DocumentEntry = InventoryLogs.DocumentEntry and InventoryLogs.TransactionType = '18' and InventoryLogs.Countrycode = APInvoices.CountryCode and APInvoices.RowNumber = InventoryLogs.DocumentLineNumber
Left Join InventoryTransfers on InventoryTransfers.DocumentEntry = InventoryLogs.DocumentEntry and InventoryLogs.TransactionType = '67' and InventoryLogs.Countrycode = InventoryTransfers.CountryCode and InventoryTransfers.RowNumber = InventoryLogs.DocumentLineNumber --- added this to join at row level
left join Deliveries on Deliveries.DocumentEntry = InventoryLogs.DocumentEntry and InventoryLogs.TransactionType = '15' and InventoryLogs.Countrycode = Deliveries.CountryCode
	and Deliveries.RowNumber = InventoryLogs.DocumentLineNumber --- added this to join at row level
left join InventoryPosting on InventoryPosting.documententry = InventoryLogs.DocumentEntry and InventoryLogs.TransactionType = '10000071' and InventoryLogs.Countrycode=InventoryPosting.countrycode and InventoryPosting.DocLineNum = InventoryLogs.documentlinenumber
Left join Attachments as ATC1 on ATC1.AbsoluteEntry  = case 
				when InventoryLogs.TransactionType = '60' Then GoodsIssues.AttachmentEntry
				when InventoryLogs.TransactionType = '59' Then GoodsReceipts.AttachmentEntry 
				When InventoryLogs.TransactionType = '67' Then InventoryTransfers.AttachmentEntry 
				when InventoryLogs.TransactionType = '15' Then Deliveries.AttachmentEntry 
				when InventoryLogs.TransactionType = '18' Then APInvoices.AttachmentEntry 
				when InventoryLogs.TransactionType = '20' Then GoodsReceiptPO.AttachmentEntry
				End 
				and ATC1.RowNumber = 1 -- attachment 
				and InventoryLogs.Countrycode = ATC1.CountryCode
Left join Attachments as ATC2 on ATC2.AbsoluteEntry = case 
				when InventoryLogs.TransactionType = '60' Then GoodsIssues.AttachmentEntry
				when InventoryLogs.TransactionType = '59' Then GoodsReceipts.AttachmentEntry 
				when InventoryLogs.TransactionType = '67' Then InventoryTransfers.AttachmentEntry 
				when InventoryLogs.TransactionType = '15' Then Deliveries.AttachmentEntry
				when InventoryLogs.TransactionType = '18' Then APInvoices.AttachmentEntry 
				when InventoryLogs.TransactionType = '20' Then GoodsReceiptPO.AttachmentEntry
				End 
				and ATC2.RowNumber = 2 -- attachment
				and InventoryLogs.Countrycode = ATC2.CountryCode

where InventoryLogs.AccumulatorType=1 
