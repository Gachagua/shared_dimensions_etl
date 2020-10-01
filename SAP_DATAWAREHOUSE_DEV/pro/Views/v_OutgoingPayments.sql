/*
Updates:
04-09-2019 DK:
	- Added LocationCode
*/

--USE [OAF_SAP_DATAWAREHOUSE]
CREATE view pro.v_OutgoingPayments as

SELECT
	CONCAT(OP.DocumentNumber,'_',OP.RowNumber+1) as OutgoingPaymentID,
	OP.DocumentNumber,
	OP.RowNumber+1 as RowNumber,
	OP.DocumentEntry as BackendOutgoingPayentID,
	OP.CreateDate,
	OP.UpdateDate,
	OP.DocumentDate,
	OP.CountryCode as [Database],
	OP.DepartmentCode,
	OP.LocationCode,
	OP.BusinessPartnerCode,
	OP.BusinessPartnerName [Supplier/Vendor], 
	OP.U_VendorAdd as VendorAddress,
	OP.U_PAYEE_NAME as PayeeName,
	OP.U_IN_BANK as PayeeBank,
	SAPUSER.UserName as DocumentCreator,
	COALESCE(AP.documentnumber,APDP.documentnumber, OP.BaseDocumentEntry) as SAPBaseDocumentID,
	case 
		when OP.InvoiceCategory =-1 then Null
		else TT.[Transaction]
	end as 'BaseDocumentType',
	OP.CountryID,
	OP.DepartmentID,
	OP.VendorID,
	OP.DocumentTotal as DocumentTotalLocal,
	OP.DocumentTotalSC as DocumentTotalUSD,
	OP.PaidInSC AS InvAmountUSD, 
	OP.PaidToInvoice as InvAmount, 
	OP.AppliedWTax as WtAppld, 
	OP.AppliedWTaxSystemCurrency as WtAppldSC,
	OP.DocumentCurrency as Currency,
	OP.Canceled,
	OP.JournalRemarks,
	OP.Comments,
	case 
		when ISNULL(APDP.u_webPRID,AP.U_WebPRID) is null then 'SAP'
		else 'Web' 
	end as [RequestMethod],
	case when OP.countrycode = 'US' then 'Global' Else 'InCountry' end as SourcingTeam

FROM dbo.OutgoingPayments OP 
	LEFT JOIN  dbo.ApInvoices AP ON 
		OP.BaseDocumentEntry = AP.documententry 
		AND AP.CountryCode = OP.CountryCode 
		AND OP.InvoiceCategory = 18
	LEFT JOIN dbo.APDownPayments APDP ON 
		OP.BaseDocumentEntry = APDP.DocumentEntry
		AND APDP.CountryCode = OP.CountryCode 
		AND OP.InvoiceCategory = 204 
	left join DimSAPUsers SAPUSER on 
		OP.UserSign=SAPUSER.UserID 
		and OP.CountryCode=SAPUSER.CountryCode
	LEFT JOIN DimTransactionType TT ON
		OP.InvoiceCategory = TT.TransId

	-- These joins are only used in the where clause to limit to Sourcing OPs
	Left join DimSAPUsers as WhereUsers ON
		ISNULL(APDP.UserSign,AP.UserSignature) = WhereUsers.UserID AND
		ISNULL(APDP.CountryCode,AP.CountryCode) = WhereUsers.CountryCode

where LEFT(WhereUsers.UserCode,3) in ('GLB','PRC')
