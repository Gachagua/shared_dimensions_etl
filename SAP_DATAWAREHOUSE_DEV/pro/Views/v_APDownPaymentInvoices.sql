

/*
updates 
V3-DK-2019-08-19 
	-Added LocationCode
	-Added DocumentSubmissionDate
	-Added Attachments
- updated BaseDocumentType
- updated SourcingTeam
- added season
- updated BaseDocumentEntry to BaseDocRef
- Added WarehouseCode
- UpdatedCountry
*/
CREATE view [pro].[v_APDownPaymentInvoices] as
--use OAF_SAP_DATAWAREHOUSE;


select 
	CONCAT(APDP.DocumentNumber,'_',APDP.RowNumber+1) as [APDP ID], 
	APDP.DocumentNumber,
	APDP.RowNumber,
	APDP.DocumentEntry as [Backend APDP ID],
	APDP.CreateDate,
	APDP.DocumentDate,
	APDP.DocumentDueDate,
	APDP.DocumentSubmissionDate,
	APDP.PurQuotationRequiredDate as [Desired Delivery Date],
	Case when APDP.countrycode = 'US' and APDP.U_TRSR_Country = 'KENYA' then 'KE'
		when APDP.countrycode = 'US' and APDP.U_TRSR_Country = 'BURUNDI' then 'BI'
		when APDP.countrycode = 'US' and APDP.U_TRSR_Country = 'TANZANIA' then 'TZ'
		when APDP.countrycode = 'US' and APDP.U_TRSR_Country = 'RWANDA' then 'RW'
		when APDP.countrycode = 'US' and APDP.U_TRSR_Country = 'MALAWI' then 'MW'
		when APDP.countrycode = 'US' and APDP.U_TRSR_Country = 'ETHIOPIA' then 'ETH'
		when APDP.countrycode = 'US' and APDP.U_TRSR_Country = 'ZAMBIA' then 'ZA'
		when APDP.countrycode = 'US' and APDP.U_TRSR_Country = 'UGANDA' then 'UG'
	else APDP.CountryCode end as [Database],
	APDP.DepartmentCode,
	APDP.LocationCode,
	APDP.ItemCode,
	APDP.BusinessPartnerName [Supplier/Vendor], 
	SAPUSER.UserName as DocumentCreator,
	CASE
		WHEN APDP.u_webPRID is not null THEN WebPR.Approver
		Else ISNULL(CountryAPDPprover.[Name],APDP.U_InputsApprover) 
	END as Approver,
	APDP.U_Requestor as Requestor,
	CASE
		WHEN APDP.U_WebPRID is not null THEN WebPR.Purchaser
		WHEN APDP.CountryCode = 'US' THEN isnull(GlobalPurchaser.[Name],APDP.U_Purchaser)
		ELSE EMP.[FullName] 
	END as Purchaser,
	APDP.U_WebPRID as WebPurchaseRequestID,
	APDP.BaseDocumentReference as SAPDPBaseDocumentID,
	case 
		when APDP.BaseDocumentType =-1 then Null
		else DimTransactionType.[Transaction]
	end as 'BaseDocumentType',
	APDP.WarehouseCode as WarehouseID,
	APDP.ItemID,
	APDP.CurrencyID,
	APDP.CountryID,
	APDP.DepartmentID,
	APDP.VendorID,
	APDP.RowTotal as LineTotalLocal,
	APDP.Price as PriceLocal,
	APDP.RowTotalUSD as LineTotalUSD,
	APDP.Currency,
	APDP.Quantity,
	APDP.DocumentStatus [Document Status],
	APDP.Canceled,
	APDP.U_Season [Season],
	APDP.[Text],
	APDP.[Description],
	APDP.Comments,
	case 
		when APDP.u_webPRID is null then 'SAP'
		else 'Web' 
	end as [RequestMethod],
	case 
		when APDP.countrycode = 'US' then 'Global' 
		when APDP.U_season is not null then 'Global' 
	Else 'InCountry' end as [SourcingTeam],
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

From APDownPayments APDP
	left join DimTransactionType  on 
		APDP.BaseDocumentType = DimTransactionType.transid
	Left join PurchaseRequestPortal WebPR on 
		WebPR.PurchaseRequestID = APDP.u_webPRID 
	left join [dbo].[@OAF_Requestor] CountryAPDPprover on 
		CountryAPDPprover.Code =APDP.U_InputsApprover 
		and APDP.CountryCode <> 'US'
	left join [dbo].[@OAF_Requestor] GlobalPurchaser on 
		GlobalPurchaser.Code =APDP.U_Requestor 
		and APDP.CountryCode = 'US'
	left join (SELECT Distinct SAPID, CountryCode, FullName FROM [$(OAF_HR_DATAWAREHOUSE)].dbo.Dimemployee) EMP on 
		APDP.documentowner = EMP.SAPID 
		and APDP.CountryCode=emp.CountryCode
	left join DimSAPUsers SAPUSER on 
		APDP.UserSign=SAPUSER.UserID and 
		APDP.CountryCode=SAPUSER.CountryCode
	left join dbo.Attachments ATC1 ON ATC1.AbsoluteEntry = APDP.AttachmentEntry AND ATC1.CountryCode = APDP.CountryCode AND ATC1.RowNumber = 1 
	left join dbo.Attachments AS ATC2 ON ATC2.AbsoluteEntry = APDP.AttachmentEntry AND ATC2.CountryCode = APDP.CountryCode AND ATC2.RowNumber = 2 
	left join dbo.Attachments AS ATC3 ON ATC3.AbsoluteEntry = APDP.AttachmentEntry AND ATC3.CountryCode = APDP.CountryCode AND ATC3.RowNumber = 3 
	left join dbo.Attachments AS ATC4 ON ATC4.AbsoluteEntry = APDP.AttachmentEntry AND ATC4.CountryCode = APDP.CountryCode AND ATC4.RowNumber = 4 
	left join dbo.Attachments AS ATC5 ON ATC5.AbsoluteEntry = APDP.AttachmentEntry AND ATC5.CountryCode = APDP.CountryCode AND ATC5.RowNumber = 5

where (LEFT(SAPUSER.UserCode,3) in ('GLB','PRC')) 



