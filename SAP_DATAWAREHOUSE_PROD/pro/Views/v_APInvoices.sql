/*
updates:
V3: DK - 2019-08-19 : 
	-Added LocationCode
	-Added DocumentSubmissionDate
	-Added Attachments		
v2: 
- updated BaseDocumentType
- updated SourcingTeam
- added season
- updated BaseDocumentEntry to BaseDocumentReference
- added ItemCode
- Added TaxCode
- Added Desired Delivery Date
- Added season logic for sourcing v InCountry
*/

--use OAF_SAP_DATAWAREHOUSE;
CREATE view pro.v_APInvoices as

select 
	CONCAT(AP.DocumentNumber,'_',AP.RowNumber+1) as APInvoiceID,
	AP.DocumentNumber,
	AP.RowNumber+1 as RowNumber,
	AP.DocumentEntry as BackendAPInvoiceID,
	AP.CreateDate,
	AP.DocumentDate,
	AP.DocumentDueDate,
	AP.DocumentSubmissionDate,
	AP.PurQuotationRequiredDate as [Desired Delivery Date],
	Case when AP.countrycode = 'US' and AP.U_TRSR_Country = 'KENYA' then 'KE'
		when AP.countrycode = 'US' and AP.U_TRSR_Country = 'BURUNDI' then 'BI'
		when AP.countrycode = 'US' and AP.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when AP.countrycode = 'US' and AP.U_TRSR_Country = 'RWANDA' then 'RW'
		when AP.countrycode = 'US' and AP.U_TRSR_Country = 'MALAWI' then 'MW'
		when AP.countrycode = 'US' and AP.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when AP.countrycode = 'US' and AP.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when AP.countrycode = 'US' and AP.U_TRSR_Country = 'UGANDA' then 'UG'
	else AP.CountryCode end as [Database],
	AP.DepartmentCode,
	AP.LocationCode,
	AP.ItemCode,
	AP.BusinessPartnerName [Supplier/Vendor], 
	SAPUSER.UserName as DocumentCreator,
	CASE
		WHEN AP.u_webPRID is not null THEN WebPR.Approver
		Else ISNULL(CountryApprover.[Name],AP.U_InputsApprover) 
	END as Approver,
	AP.U_Requestor as Requestor,
	CASE
		WHEN AP.U_WebPRID is not null THEN WebPR.Purchaser
		WHEN AP.CountryCode = 'US' THEN isnull(GlobalPurchaser.[Name],AP.U_Purchaser) -- 
		ELSE EMP.[FullName] 
	END as Purchaser,
	AP.U_WebPRID as WebPurchaseRequestID,
	AP.BaseDocumentReference as SAPBaseDocumentID,
	case 
		when AP.BaseDocumentType =-1 then Null
		else DimTransactionType.[Transaction]
	end as 'BaseDocumentType',
	AP.ItemID,
	AP.CurrencyID,
	AP.CountryID,
	AP.DepartmentID,
	AP.VendorID,
	AP.RowTotalLocal as LineTotalLocal,
	AP.Price as PriceLocal,
	AP.RowTotalUSD as LineTotalUSD,
	AP.PaidToDate [Paid to Date],
	AP.PriceCurrency as Currency,
	AP.TaxCode,
	AP.Quantity,
	AP.DocumentStatus [Document Status],
	AP.Canceled,
	AP.U_Season [Season],
	AP.[Text],
	AP.[Description],
	AP.Comments,
	case 
		when AP.u_webPRID is null then 'SAP'
		else 'Web' 
	end as [RequestMethod],
	case 
		when AP.countrycode = 'US' then 'Global'
		when AP.U_Season is not null then 'Global'
	Else 'InCountry' end as SourcingTeam,
	CASE 
		WHEN ATC1.filename IS NULL THEN NULL 
		WHEN ATC1.FileName IS NOT NULL THEN replace(replace(cast(ATC1.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/')+ '\' + Concat(replace(replace(ATC1.FileName, '%', '%25'), '#', '%23'), '.', ATC1.FileExtension)
		END AS [Att. 1], 
                         
	CASE 
		WHEN ATC2.filename IS NULL THEN NULL 
		WHEN ATC2.FileName IS NOT NULL THEN replace(replace(cast(ATC2.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/')+ '\' + Concat(replace(replace(ATC2.FileName, '%', '%25'), '#', '%23'), '.', ATC2.FileExtension)
		END AS [Att. 2], 

	CASE 
		WHEN ATC3.filename IS NULL THEN NULL 
		ELSE replace(replace(cast(ATC3.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/') + '/' + Concat(replace(replace(ATC3.FileName, '%', '%25'), '#', '%23'), '.', ATC3.FileExtension)
	END AS [Att. 3], 

	CASE 
		WHEN ATC4.filename IS NULL THEN NULL 
		ELSE replace(replace(cast(ATC4.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/') + '/' + Concat(replace(replace(ATC4.FileName, '%', '%25'), '#', '%23'), '.', ATC4.FileExtension)
	END AS [Att. 4], 

	CASE 
		WHEN ATC5.filename IS NULL THEN NULL 
		ELSE replace(replace(cast(ATC5.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/') + '/' + Concat(replace(replace(ATC5.FileName, '%', '%25'), '#', '%23'), '.', ATC5.FileExtension)
	END AS [Att. 5]

From APInvoices AP
	left join DimTransactionType  on 
		AP.BaseDocumentType = DimTransactionType.transid
	Left join PurchaseRequestPortal WebPR on 
		WebPR.PurchaseRequestID = AP.u_webPRID 
	left join [dbo].[@OAF_Requestor] CountryApprover on 
		CountryApprover.Code =AP.U_InputsApprover 
		and AP.CountryCode <> 'US'
	left join [dbo].[@OAF_Requestor] GlobalPurchaser on 
		GlobalPurchaser.Code =AP.U_Requestor 
		and AP.CountryCode = 'US'
	left join (SELECT Distinct SapID, CountryCode, FullName FROM [$(OAF_HR_DATAWAREHOUSE)].dbo.Dimemployee) EMP on 
		AP.documentowner = EMP.sapid 
		and AP.CountryCode=emp.CountryCode
	left join DimSAPUsers SAPUSER on 
		AP.UserSignature=SAPUSER.UserID and 
		AP.CountryCode=SAPUSER.CountryCode
	left join dbo.Attachments ATC1 ON ATC1.AbsoluteEntry = AP.AttachmentEntry AND ATC1.CountryCode = AP.CountryCode AND ATC1.RowNumber = 1 
	left join dbo.Attachments AS ATC2 ON ATC2.AbsoluteEntry = AP.AttachmentEntry AND ATC2.CountryCode = AP.CountryCode AND ATC2.RowNumber = 2 
	left join dbo.Attachments AS ATC3 ON ATC3.AbsoluteEntry = AP.AttachmentEntry AND ATC3.CountryCode = AP.CountryCode AND ATC3.RowNumber = 3 
	left join dbo.Attachments AS ATC4 ON ATC4.AbsoluteEntry = AP.AttachmentEntry AND ATC4.CountryCode = AP.CountryCode AND ATC4.RowNumber = 4 
	left join dbo.Attachments AS ATC5 ON ATC5.AbsoluteEntry = AP.AttachmentEntry AND ATC5.CountryCode = AP.CountryCode AND ATC5.RowNumber = 5

where (LEFT(SAPUSER.UserCode,3) in ('GLB','PRC'))

