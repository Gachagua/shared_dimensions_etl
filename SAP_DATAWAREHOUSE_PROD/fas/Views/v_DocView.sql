/*
Notes:
v15: 2019-10-03 DK - Updated Rowtotal to RowTotalLocal
V14: 2019-04-09 MW - Switch to DimCountry from the shared dimensions
V13: 2019-03-15 MW - The replace for \ to / was only for the first part of the concatenated bit, had to move it to include whole attachment string
V12: 2019-02-15 DK- Edited attachments path to one thats working
V11: 2019-02-06 DK- Edited attachments path
V10: 2019-29-01 DK- changed pull from VPM4 to OutgoingPayments
V9: 2018-11-09 MW: updated url to accomodate for % in file names
V8: Changed field names to match previous views (AccountCode to AcctCode, DocumentDate to DocDate, DocumentNumber as DocNum, 
		UserName as U_Name, BusinessPartnerName as CardName, BusinessPartnerCode as CardCode,TransactionID as TransID, Ocrcode2, OcrCode3
V7: Changed pull from remaining old tables to new ones. 
V6: Changed pull from flat_pch to ApInvoices, ATC1 to Attachments
V5: Added a replace for attachments with # in the url
V4: Updated the Attachment path to pull from the new URLs
V3: Added where clause for filtering either by CreateDate or PostingDate
V2: Added Outgoing Payment information
*/

CREATE view fas.v_DocView as
--use oaf_sap_datawarehouse;

---- APInvoices -----
select 
	PCH.Countrycode as DB,
	PCH.DocumentNumber as docnum,
	'A/P Invoice' as DocType,
	PCH.DocumentDate as DocDate,	
	PCH.CreateDate,
	PCH.CANCELED,
	PCH.UserSignature,
	OUSR.UserName as U_NAME,
	PCH.BusinessPartnerName as CardName,
	PCH.Comments as [Doc Comments],
	PCH.BusinessPartnerCode as CardCode,
	PCH.TransactionID as TransID,
	PCH.AccountCode as AcctCode,
	PCH.ItemCode,
	PCH.[Description] as Dscription,
	PCH.Quantity,
	PCH.RowTotalLocal[Total RWF],
	PCH.RowTotalUSD [Total FC],
	PCH.DocumentCurrency,
	PCH.RowTotalUSD [Total USD],
	--PCH1.FreeTxt,
	PCH.[Text] [Line Comments],
	PCH.DepartmentCode as OcrCode2,
	PCH.LocationCode as OcrCode3,
CASE 
	WHEN ATC1.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC1.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043')+ '\' + Concat(replace(replace(ATC1.FileName, '%', '%25'), '#', '%23'), '.', ATC1.FileExtension) , '\', '/')

 END AS [Att. 1], 
                         
CASE 
	WHEN ATC2.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC2.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043')+ '\' + Concat(replace(replace(ATC2.FileName, '%', '%25'), '#', '%23'), '.', ATC2.FileExtension), '\', '/')
 END AS [Att. 2], 

CASE 
	WHEN ATC3.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC3.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC3.FileName, '%', '%25'), '#', '%23'), '.', ATC3.FileExtension), '\', '/')
 END AS [Att. 3], 

CASE 
	WHEN ATC4.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC4.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC4.FileName, '%', '%25'), '#', '%23'), '.', ATC4.FileExtension), '\', '/')
 END AS [Att. 4], 

CASE 
	WHEN ATC5.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC5.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC5.FileName, '%', '%25'), '#', '%23'), '.', ATC5.FileExtension), '\', '/')
END AS [Att. 5]

	,case -- country
		when PCH.LocationCode = 'GLB' then 'Global'
		when PCH.CountryCode ='US' then 'Global'
		when t4.departmentType = 'Global' then 'Global' 
		else t5.CountryName
	end as Country
	,OACT.AcctName
	,Concat(PCH.CountryCode,'_',ISNULL(PCH.DepartmentCode,'')) as Country_Department
	
from APInvoices PCH
Left Join DimSAPUsers as OUSR on PCH.UserSignature = OUSR.USERID and PCH.Countrycode = OUSR.Countrycode
Left join DepartmentAllocation t4 on PCH.DepartmentCode = t4.DepartmentCode and year(PCH.DocumentDate) = t4.mapping_year
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimCountry t5 on t5.countrycode = PCH.countrycode
Left join Attachments as ATC1 on PCH.AttachmentEntry = ATC1.AbsoluteEntry  
				and ATC1.CountryCode = PCH.Countrycode
				and ATC1.RowNumber = 1 -- attachment
Left join Attachments as ATC2 on ATC2.AbsoluteEntry  = PCH.AttachmentEntry 
				and ATC2.CountryCode = PCH.Countrycode
				and ATC2.RowNumber = 2 -- attachment
Left join Attachments as ATC3 on ATC3.AbsoluteEntry  = PCH.AttachmentEntry 
				and ATC3.CountryCode = PCH.Countrycode
				and ATC3.RowNumber = 3 -- attachment
Left join Attachments ATC4 on ATC4.AbsoluteEntry  = PCH.AttachmentEntry 
				and ATC4.CountryCode = PCH.Countrycode
				and ATC4.RowNumber = 4 -- attachment
Left join Attachments ATC5 on ATC5.AbsoluteEntry  = PCH.AttachmentEntry 
				and ATC5.CountryCode = PCH.Countrycode
				and ATC5.RowNumber = 5 -- attachment
left join OACT on PCH.AccountCode = OACT.Acctcode and PCH.countrycode = OACT.countrycode

Union All 

------ GoodsReceipts-----------

select 
	IGN.Countrycode as DB,
	IGN.DocumentNumber,
	'Goods Receipt' as DocType,
	IGN.DocumentDate,	
	IGN.CreateDate,
	NULL as CANCELED,
	IGN.UserSignature,
	OUSR.UserName,
	NULL as CardCode,
	NULL as CardName,
	IGN.Comments as [Doc Comments],
	IGN.TransactionNumber,
	IGN.AccountCode as AcctCode,
	IGN.ItemCode,
	IGN.Description,
	IGN.Quantity,
	IGN.RowTotal [Total RWF],
	IGN.RowTotalForeignCurrency [Total FC],
	IGN.Currency,
	IGN.RowTotalUSD [Total USD],
	--PCH1.FreeTxt,
	IGN.[Text] [Line Comments],
	IGN.DepartmentCode,
	IGN.LocationCode,

CASE 
	WHEN ATC1.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC1.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '\' + Concat(replace(replace(ATC1.FileName, '%', '%25'), '#', '%23'), '.', ATC1.FileExtension), '\', '/')

 END AS [Att. 1], 
                         
CASE 
	WHEN ATC2.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC2.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '\' + Concat(replace(replace(ATC2.FileName, '%', '%25'), '#', '%23'), '.', ATC2.FileExtension), '\', '/')
 END AS [Att. 2], 

CASE 
	WHEN ATC3.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC3.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC3.FileName, '%', '%25'), '#', '%23'), '.', ATC3.FileExtension), '\', '/')
 END AS [Att. 3], 

CASE 
	WHEN ATC4.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC4.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC4.FileName, '%', '%25'), '#', '%23'), '.', ATC4.FileExtension), '\', '/')
 END AS [Att. 4], 

CASE 
	WHEN ATC5.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC5.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC5.FileName, '%', '%25'), '#', '%23'), '.', ATC5.FileExtension), '\', '/')
END AS [Att. 5]

	,case -- country
		when IGN.LocationCode = 'GLB' then 'Global'
		when IGN.CountryCode ='US' then 'Global'
		when t4.departmentType = 'Global' then 'Global' 
		else t5.CountryName
	end as Country
	,OACT.AcctName
	,Concat(IGN.CountryCode,'_',ISNULL(IGN.DepartmentCode,'')) as Country_Department

from GoodsReceipts IGN
Left Join DimSAPUsers as OUSR on IGN.UserSignature = OUSR.USERID and IGN.Countrycode = OUSR.Countrycode
Left join DepartmentAllocation t4 on IGN.DepartmentCode = t4.DepartmentCode and year(IGN.DocumentDate) = t4.mapping_year
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimCountry t5 on t5.countrycode = IGN.countrycode
Left join Attachments ATC1 on IGN.AttachmentEntry = ATC1.AbsoluteEntry  
				and ATC1.CountryCode = IGN.Countrycode
				and ATC1.RowNumber = 1 -- attachment
Left join Attachments ATC2 on ATC2.AbsoluteEntry  = IGN.AttachmentEntry 
				and ATC2.CountryCode = IGN.Countrycode
				and ATC2.RowNumber = 2 -- attachment
Left join Attachments ATC3 on ATC3.AbsoluteEntry  = IGN.AttachmentEntry 
				and ATC3.CountryCode = IGN.Countrycode
				and ATC3.RowNumber = 3 -- attachment
Left join Attachments ATC4 on ATC4.AbsoluteEntry  = IGN.AttachmentEntry 
				and ATC4.CountryCode = IGN.Countrycode
				and ATC4.RowNumber = 4 -- attachment
Left join Attachments ATC5 on ATC5.AbsoluteEntry  = IGN.AttachmentEntry 
				and ATC5.CountryCode = IGN.Countrycode
				and ATC5.RowNumber = 5 -- attachment
left join OACT on IGN.AccountCode = OACT.Acctcode and IGN.countrycode = OACT.countrycode

Union All 

-----GoodsIssues ------
select 
	IGE.Countrycode as DB,
	IGE.DocumentNumber,
	'Goods Issue' as DocType,
	IGE.DocumentDate,	
	IGE.CreateDate,
	NULL as CANCELED,
	IGE.UserSignature,
	OUSR.UserName,
	NULL as CardCode,
	NULL as CardName,
	IGE.Comments as [Doc Comments],
	IGE.TransactionNumber,
	IGE.AccountCode as AcctCode,
	IGE.ItemCode,
	IGE.Description,
	IGE.Quantity,
	IGE.RowTotal [Total RWF],
	IGE.RowTotalForeignCurrency [Total FC],
	IGE.Currency,
	IGE.RowTotalUSD [Total USD],
	--PCH1.FreeTxt,
	IGE.[Text] [Line Comments],
	IGE.DepartmentCode,
	IGE.LocationCode,
CASE 
	WHEN ATC1.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC1.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '\' + Concat(replace(replace(ATC1.FileName, '%', '%25'), '#', '%23'), '.', ATC1.FileExtension), '\', '/')

 END AS [Att. 1], 
                         
CASE 
	WHEN ATC2.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC2.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '\' + Concat(replace(replace(ATC2.FileName, '%', '%25'), '#', '%23'), '.', ATC2.FileExtension), '\', '/')
 END AS [Att. 2], 

CASE 
	WHEN ATC3.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC3.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC3.FileName, '%', '%25'), '#', '%23'), '.', ATC3.FileExtension), '\', '/')
 END AS [Att. 3], 

CASE 
	WHEN ATC4.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC4.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC4.FileName, '%', '%25'), '#', '%23'), '.', ATC4.FileExtension), '\', '/')
 END AS [Att. 4], 

CASE 
	WHEN ATC5.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC5.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC5.FileName, '%', '%25'), '#', '%23'), '.', ATC5.FileExtension), '\', '/')
END AS [Att. 5],

case -- country
		when IGE.LocationCode = 'GLB' then 'Global'
		when IGE.CountryCode ='US' then 'Global'
		when t4.departmentType = 'Global' then 'Global' 
		else t5.CountryName
	end as Country
	,OACT.AcctName
	,Concat(IGE.CountryCode,'_',ISNULL(IGE.DepartmentCode,'')) as Country_Department

from GoodsIssues IGE
Left Join DimSAPUsers as OUSR on IGE.UserSignature = OUSR.USERID and IGE.Countrycode = OUSR.Countrycode
Left join DepartmentAllocation t4 on IGE.DepartmentCode = t4.DepartmentCode and year(IGE.DocumentDate) = t4.mapping_year
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimCountry t5 on t5.countrycode = IGE.countrycode
Left join Attachments ATC1 on IGE.AttachmentEntry = ATC1.AbsoluteEntry  
				and ATC1.CountryCode = IGE.Countrycode
				and ATC1.RowNumber = 1 -- attachment
Left join Attachments ATC2 on ATC2.AbsoluteEntry  = IGE.AttachmentEntry 
				and ATC2.CountryCode = IGE.Countrycode
				and ATC2.RowNumber = 2 -- attachment
Left join Attachments ATC3 on ATC3.AbsoluteEntry  = IGE.AttachmentEntry 
				and ATC3.CountryCode = IGE.Countrycode
				and ATC3.RowNumber = 3 -- attachment
Left join Attachments ATC4 on ATC4.AbsoluteEntry  = IGE.AttachmentEntry 
				and ATC4.CountryCode = IGE.Countrycode
				and ATC4.RowNumber = 4 -- attachment
Left join Attachments ATC5 on ATC5.AbsoluteEntry  = IGE.AttachmentEntry 
				and ATC5.CountryCode = IGE.Countrycode
				and ATC5.RowNumber = 5 -- attachment
left join OACT on IGE.AccountCode = OACT.Acctcode and IGE.countrycode = OACT.countrycode

Union All 

-----AP Downpayments --------
select 
	DPO.Countrycode as DB,
	DPO.DocumentNumber,
	'A/P DP Invoice' as DocType,
	DPO.DocumentDate,	
	DPO.CreateDate,
	DPO.CANCELED,
	DPO.UserSign,
	OUSR.UserName,
	DPO.BusinessPartnerCode,
	DPO.BusinessPartnerName,
	DPO.Comments as [Doc Comments],
	DPO.TransactionID,
	DPO.AccountCode as AcctCode,
	DPO.ItemCode,
	DPO.[Description],
	DPO.Quantity,
	DPO.RowTotal [Total RWF],
	DPO.RowTotalForeignCurrency [Total FC],
	DPO.Currency,
	DPO.RowTotalUSD [Total USD],
	--PCH1.FreeTxt,
	DPO.[Text] [Line Comments],
	DPO.DepartmentCode,
	DPO.LocationCode,
CASE 
	WHEN ATC1.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC1.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '\' + Concat(replace(replace(ATC1.FileName, '%', '%25'), '#', '%23'), '.', ATC1.FileExtension), '\', '/')

 END AS [Att. 1], 
                         
CASE 
	WHEN ATC2.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC2.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '\' + Concat(replace(replace(ATC2.FileName, '%', '%25'), '#', '%23'), '.', ATC2.FileExtension), '\', '/')
 END AS [Att. 2], 

CASE 
	WHEN ATC3.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC3.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC3.FileName, '%', '%25'), '#', '%23'), '.', ATC3.FileExtension), '\', '/')
 END AS [Att. 3], 

CASE 
	WHEN ATC4.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC4.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC4.FileName, '%', '%25'), '#', '%23'), '.', ATC4.FileExtension), '\', '/')
 END AS [Att. 4], 

CASE 
	WHEN ATC5.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC5.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC5.FileName, '%', '%25'), '#', '%23'), '.', ATC5.FileExtension), '\', '/')
END AS [Att. 5],

case -- country
		when DPO.LocationCode = 'GLB' then 'Global'
		when DPO.CountryCode ='US' then 'Global'
		when t4.departmentType = 'Global' then 'Global' 
		else t5.CountryName
	end as Country
	,OACT.AcctName
	,Concat(DPO.CountryCode,'_',ISNULL(DPO.DepartmentCode,'')) as Country_Department

from APDownPayments DPO
Left Join DimSAPUsers as OUSR on DPO.UserSign = OUSR.USERID and DPO.Countrycode = OUSR.Countrycode
Left join DepartmentAllocation t4 on DPO.DepartmentCode = t4.DepartmentCode and year(DPO.DocumentDate) = t4.mapping_year
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimCountry t5 on t5.countrycode = DPO.countrycode
Left join Attachments ATC1 on DPO.AttachmentEntry = ATC1.AbsoluteEntry  
				and ATC1.CountryCode = DPO.Countrycode
				and ATC1.RowNumber = 1 -- attachment
Left join Attachments ATC2 on ATC2.AbsoluteEntry  = DPO.AttachmentEntry 
				and ATC2.CountryCode = DPO.Countrycode
				and ATC2.RowNumber = 2 -- attachment
Left join Attachments ATC3 on ATC3.AbsoluteEntry  = DPO.AttachmentEntry 
				and ATC3.CountryCode = DPO.Countrycode
				and ATC3.RowNumber = 3 -- attachment
Left join Attachments ATC4 on ATC4.AbsoluteEntry  = DPO.AttachmentEntry 
				and ATC4.CountryCode = DPO.Countrycode
				and ATC4.RowNumber = 4 -- attachment
Left join Attachments ATC5 on ATC5.AbsoluteEntry  = DPO.AttachmentEntry 
				and ATC5.CountryCode = DPO.Countrycode
				and ATC5.RowNumber = 5 -- attachment
left join OACT on DPO.AccountCode = OACT.Acctcode and DPO.countrycode = OACT.countrycode

Union All 

------ Goods Receipt PO ------
select 
	PDN.Countrycode as DB,
	PDN.DocumentNumber,
	'Goods Receipt PO' as DocType,
	PDN.DocumentDate,	
	PDN.CreateDate,
	PDN.CANCELED,
	PDN.UserSignature,
	OUSR.UserName,
	PDN.BusinessPartnerCode,
	PDN.BusinessPartnerName,
	PDN.Comments as [Doc Comments],
	PDN.TransactionID,
	PDN.AccountCode as AcctCode,
	PDN.ItemCode,
	PDN.[Description],
	PDN.Quantity,
	PDN.RowTotal [Total RWF],
	PDN.TotalForeignCurrency [Total FC],
	PDN.Currency,
	PDN.TotalSumUSD [Total USD],
	--PCH1.FreeTxt,
	PDN.[Text] [Line Comments],
	PDN.departmentcode,
	PDN.locationcode,
CASE 
	WHEN ATC1.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC1.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '\' + Concat(replace(replace(ATC1.FileName, '%', '%25'), '#', '%23'), '.', ATC1.FileExtension), '\', '/')
 END AS [Att. 1], 
                         
CASE 
	WHEN ATC2.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC2.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '\' + Concat(replace(replace(ATC2.FileName, '%', '%25'), '#', '%23'), '.', ATC2.FileExtension), '\', '/')
 END AS [Att. 2], 

CASE 
	WHEN ATC3.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC3.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC3.FileName, '%', '%25'), '#', '%23'), '.', ATC3.FileExtension), '\', '/')
 END AS [Att. 3], 

CASE 
	WHEN ATC4.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC4.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC4.FileName, '%', '%25'), '#', '%23'), '.', ATC4.FileExtension), '\', '/')
 END AS [Att. 4], 

CASE 
	WHEN ATC5.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC5.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC5.FileName, '%', '%25'), '#', '%23'), '.', ATC5.FileExtension), '\', '/')
END AS [Att. 5]

	,case -- country
		when PDN.locationcode = 'GLB' then 'Global'
		when PDN.CountryCode ='US' then 'Global'
		when t4.departmentType = 'Global' then 'Global' 
		else t5.CountryName
	end as Country
	,OACT.AcctName
	,Concat(PDN.CountryCode,'_',ISNULL(PDN.departmentcode,'')) as Country_Department

from GoodsReceiptPO PDN
Left Join DimSAPUsers as OUSR on PDN.UserSignature = OUSR.USERID and PDN.Countrycode = OUSR.Countrycode
Left join DepartmentAllocation t4 on PDN.departmentcode = t4.DepartmentCode and year(PDN.DocumentDate) = t4.mapping_year
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimCountry t5 on t5.countrycode = PDN.countrycode
Left join Attachments ATC1 on PDN.AttachmentEntry = ATC1.AbsoluteEntry  
				and ATC1.CountryCode = PDN.Countrycode
				and ATC1.RowNumber = 1 -- attachment
Left join Attachments ATC2 on ATC2.AbsoluteEntry  = PDN.AttachmentEntry 
				and ATC2.CountryCode = PDN.Countrycode
				and ATC2.RowNumber = 2 -- attachment
Left join Attachments ATC3 on ATC3.AbsoluteEntry  = PDN.AttachmentEntry 
				and ATC3.CountryCode = PDN.Countrycode
				and ATC3.RowNumber = 3 -- attachment
Left join Attachments ATC4 on ATC4.AbsoluteEntry  = PDN.AttachmentEntry 
				and ATC4.CountryCode = PDN.Countrycode
				and ATC4.RowNumber = 4 -- attachment
Left join Attachments ATC5 on ATC5.AbsoluteEntry  = PDN.AttachmentEntry 
				and ATC5.CountryCode = PDN.Countrycode
				and ATC5.RowNumber = 5 -- attachment
left join OACT on PDN.AccountCode = OACT.Acctcode and PDN.countrycode = OACT.countrycode

Union All 

----- PurchaseOrders -------

select 
	OPOR.Countrycode as DB,
	OPOR.DocumentNumber,
	'Purchase Order' as DocType,
	OPOR.DocumentDate,	
	OPOR.CreateDate,
	OPOR.CANCELED,
	OPOR.UserSignature,
	OUSR.UserName,
	OPOR.BusinessPartnerCode,
	OPOR.BusinessPartnerName,
	null as [Doc Comments], --OPOR.Comments 
	null, --OPOR.TransID,
	OPOR.AccountCode as AcctCode,
	OPOR.ItemCode,
	null,-- OPOR.[Description],
	OPOR.Quantity,
	OPOR.RowTotal [Total RWF],
	null,--OPOR.TotalFrgn [Total FC],
	OPOR.Currency,
	OPOR.RowTotalUSD [Total USD],
	--OPOR.FreeTxt,
	null,--OPOR.[Text] [Line Comments],
	OPOR.DepartmentCode as department,
	OPOR.LocationCode,
CASE 
	WHEN ATC1.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC1.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '\' + Concat(replace(replace(ATC1.FileName, '%', '%25'), '#', '%23'), '.', ATC1.FileExtension), '\', '/')
 END AS [Att. 1], 
                         
CASE 
	WHEN ATC2.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC2.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '\' + Concat(replace(replace(ATC2.FileName, '%', '%25'), '#', '%23'), '.', ATC2.FileExtension), '\', '/')
 END AS [Att. 2], 

CASE 
	WHEN ATC3.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC3.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC3.FileName, '%', '%25'), '#', '%23'), '.', ATC3.FileExtension), '\', '/')
 END AS [Att. 3], 

CASE 
	WHEN ATC4.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC4.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC4.FileName, '%', '%25'), '#', '%23'), '.', ATC4.FileExtension), '\', '/')
 END AS [Att. 4], 

CASE 
	WHEN ATC5.filename IS NULL THEN NULL 
	ELSE replace(replace(cast(ATC5.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043') + '/' + Concat(replace(replace(ATC5.FileName, '%', '%25'), '#', '%23'), '.', ATC5.FileExtension), '\', '/')
END AS [Att. 5]

	,case -- country
		when OPOR.LocationCode = 'GLB' then 'Global'
		when OPOR.CountryCode ='US' then 'Global'
		when t4.departmentType = 'Global' then 'Global' 
		else t5.CountryName
	end as Country
	,OACT.AcctName
	,Concat(OPOR.CountryCode,'_',ISNULL(OPOR.DepartmentCode,'')) as Country_Department

from PurchaseOrders OPOR
--Left join OPOR on OPOR.docentry = OPOR.docentry and OPOR.countrycode = OPOR.countrycode --PO Header 
Left Join DimSAPUsers as OUSR on OPOR.UserSignature = OUSR.USERID and OPOR.Countrycode = OUSR.Countrycode
Left join DepartmentAllocation t4 on OPOR.DepartmentCode = t4.DepartmentCode and year(OPOR.DocumentDate) = t4.mapping_year
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimCountry t5 on t5.countrycode = OPOR.countrycode
Left join Attachments ATC1 on OPOR.AttachmentEntry = ATC1.AbsoluteEntry  
				and ATC1.CountryCode = OPOR.Countrycode
				and ATC1.RowNumber = 1 -- attachment
Left join Attachments ATC2 on ATC2.AbsoluteEntry  = OPOR.AttachmentEntry 
				and ATC2.CountryCode = OPOR.Countrycode
				and ATC2.RowNumber = 2 -- attachment
Left join Attachments ATC3 on ATC3.AbsoluteEntry  = OPOR.AttachmentEntry 
				and ATC3.CountryCode = OPOR.Countrycode
				and ATC3.RowNumber = 3 -- attachment
Left join Attachments ATC4 on ATC4.AbsoluteEntry  = OPOR.AttachmentEntry 
				and ATC4.CountryCode = OPOR.Countrycode
				and ATC4.RowNumber = 4 -- attachment
Left join Attachments ATC5 on ATC5.AbsoluteEntry  = OPOR.AttachmentEntry 
				and ATC5.CountryCode = OPOR.Countrycode
				and ATC5.RowNumber = 5 -- attachment
left join OACT on OPOR.AccountCode = OACT.Acctcode and OPOR.countrycode = OACT.countrycode

Union All

------ OutGoing Payments ---------
select 
	VPM.Countrycode as DB,
	VPM.DocumentNumber,
	'Outgoing Payment' as DocType,
	VPM.DocumentDate,	
	VPM.CreateDate, 
	VPM.CANCELED,
	VPM.UserSign,
	OUSR.UserName,
	VPM.BusinessPartnerCode,
	VPM.BusinessPartnerName,
	VPM.Comments as [Doc Comments],
	VPM.TransferAccount,
	VPM.TransId,
	null [ItemCode], --not in outgoing payments
	t6.[Desctiption] as [Description],
	null [Quantity],
	VPM.DocumentTotal [Total Local],
	VPM.DocumentTotalSC [Total FC],
	VPM.DocumentCurrency [Currency],
	VPM.DocumentTotalSC [Total USD],
	--VPM1.FreeTxt,
	VPM.Comments as [Line Comments],
	VPM.DepartmentCode,
	VPM.LocationCode,
	--vpm.u_attch1,
	--vpm.u_attch2,
	--right(vpm.u_attch1,CHARINDEX('\',reverse(vpm.u_attch1)+'\')-1),
	CASE 
	WHEN VPM.U_ATTCH1 IS NULL THEN NULL 
	ELSE replace(replace(replace(replace(cast(VPM.U_ATTCH1 as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '%', '%25'), '#', '%23'), '\', '/')
 END AS [Att. 1], 
CASE 
	WHEN VPM.U_ATTCH2 IS NULL THEN NULL 
	ELSE replace(replace(replace(replace(cast(VPM.U_ATTCH2 as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '%', '%25'), '#', '%23'), '\', '/')
 END AS [Att. 2]
	,null as [Att. 3]--ATC3.filename
	,null as [Att. 4]--ATC4.filename
	,null as [Att. 5]--ATC5.filename

	,case -- country
		when VPM.LocationCode = 'GLB' then 'Global'
		when VPM.CountryCode ='US' then 'Global'
		--when t4.departmentType = 'Global' then 'Global' 
		else t5.CountryName
	end as Country
	,OACT.AcctName
	,null --Country_Department

from OutgoingPayments VPM
Left Join DimSAPUsers as OUSR on VPM.UserSign = OUSR.USERID and VPM.Countrycode = OUSR.Countrycode
--Left join DepartmentAllocation t4 on VPM.OCRCode2 = t4.DepartmentCode and year(VPM.DocumentDate) = t4.mapping_year
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimCountry t5 on t5.countrycode = VPM.countrycode
left join OACT on VPM.TransferAccount = OACT.Acctcode and VPM.countrycode = OACT.countrycode
left join OutgoingPayments t6 on VPM.DocumentEntry = T6.DocumentNumber and VPM.AccountCode = t6.AccountCode 


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[5] 4[15] 2[74] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'fas', @level1type = N'VIEW', @level1name = N'v_DocView';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'fas', @level1type = N'VIEW', @level1name = N'v_DocView';

