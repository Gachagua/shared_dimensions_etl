-- use oaf_sap_datawarehouse
CREATE VIEW fas.v_TxPull AS      
/*
Update notes:
	V8: DK 2019-09-24
		- Added Due Date
	V7: MW 2019-06-12
		- updated from transaction_type to DimTransactionType
	V6: MW 2019-04-14
		- Added project field
	V5: DK 2019-03-29
		- Added BatchNumber to the query
	V4 MW 2019-02-04:
		- Added AP Invoice back in (since it's indexed)
		- This version has updated tables
	V2:
		- removed PHC1 join to speed it up
		- haven't altered the view yet
*/
Select
	JDT.createdate as [Create Date],
	JDT.PostingDate as [Payment Date],
	JDT.DueDate as [Due Date],
	JDT.CountryCode as [Database],
	JDT.Project,
	OUSR.UserName as U_NAME,
	JDT.TransactionID as [Country JE Trans No.],
	JDT.RowNumber as [JE Line No.],
	JDT.AccountCode as [Account],
	OACT.AcctName as [Account Name],
	JDT.BPAccountCode as ShortCode,
	OCRD.businesspartnername as ShortName,
	JDT.OffsetAccount [Contra Account],
	case
		when isnull(OCRD2.businesspartnername,'')='' Then OACT2.AcctName
	else OCRD2.businesspartnername  End as [Contra Account Name],
	JDT.RowDetails as [Line Memo],
	isnull(JDT.U_JE_Remarks,'') as Remarks,
	JDT.DepartmentCode as [Department],
	JDT.LocationCode as [Location],
	JDT.distributionrule as [Expense Type],
	JDT.Debit as [Local Debit],
	JDT.Credit as [Local Credit],
	JDT.Debit - JDT.Credit  as [Local Balance],
	null as [Local Currency],
	JDT.SystemDebitAmount as [USD Debit],
	JDT.SystemCreditAmount as [USD Credit],
	JDT.SystemDebitAmount - JDT.SystemCreditAmount as [USD Balance],
	JDT.ReconciliationDate as [Reconciliation Date],
	JDT.TransactionType,
	TT.[Transaction] AS Transaction_Type,
	--COALESCE(JDT.U_JE_Remarks,JDT.rowdetails) as [Document Description],  --U_Remarks first, then AP line, then JDT1 line) 	2/9/17
	COALESCE(JDT.U_JE_Remarks, case when pch1.itemcode is null then PCH1.Description else PCH1.[text] end,JDT.RowDetails) as [Document Description],  --U_Remarks first, then AP line, then JDT1 line) 	2/9/17
	case
		when ISNULL(JDT.ReverseTransaction,'')<>'' then 'Reversal entries'
		when exists (select * from JournalEntries as T4 where T4.ReverseTransaction = JDT.TransactionID and T4.CountryCode = JDT.CountryCode) then 'Reversed'
	else 'Valid' end as Reversed,
	JDT.BaseReference as [Doc Num],
	JDT.BatchNumber

FROM JournalEntries as JDT
Left Join OACT ON OACT.AcctCode = JDT.AccountCode and OACT.countrycode = JDT.countrycode
left join BusinessPartners as OCRD on OCRD.businesspartnercode = JDT.BPAccountCode and  JDT.countrycode =  OCRD.countrycode
Left Join OACT OACT2 ON OACT2.Acctcode= JDT.OffsetAccount and OACT2.countrycode = JDT.countrycode
left join BusinessPartners OCRD2 on OCRD2.businesspartnercode = JDT.OffsetAccount and  JDT.countrycode =  OCRD2.countrycode
left join DimSapUsers as OUSR on JDT.UserSignature = OUSR.USERID and JDT.Countrycode = OUSR.Countrycode
left join DimTransactionType TT on JDT.TransactionType = TT.TransId  
left join APInvoices PCH1
	on JDT.TransactionType = 18 --limit to only AP Invoices (we could do this for other documents eventually)
	and year(JDT.PostingDate) > 2016 --limit to 2017 entries as the line to line feature was not turned on in 2016
	and JDT.docline >= 0 --will default to -1 if the line has no link (e.g. vendor payable from invoice)
	and JDT.Createdby = PCH1.DocumentEntry --link the Invoice internal number (docentry) it's reference in JDJDT link (createdby)
	and JDT.docline = PCH1.RowNumber --link invoice line to JDT1 line
	and JDT.countrycode = PCH1.countrycode


;
