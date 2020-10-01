CREATE VIEW fas.[v_TxPull_Fast] AS      
/*
Update date: 29/1/2019
Updated by: Diana
View updated: 9/8/2018
Update notes:
	v5: updated pull from ojdt to JournalEntries
	v4: Updated pull from flat_jdt to JournalEntries
	V3:
		- added a join to get contra account father number category
	V2:
		- removed PHC1 join to speed it up
		- haven't altered the view yet
*/
--use OAF_SAP_DATAWAREHOUSE;

Select 
	JDT.createdate as [Create Date],
	JDT.PostingDate as [Payment Date],
	JDT.CountryCode as [Database],
	OUSR.UserName,
	JDT.TransactionID as [Country JE Trans No.],
	JDT.RowNumber as [JE Line No.],
	JDT.AccountCode as [Account],
	OACT.AcctName as [Account Name],
	JDT.BPAccountCode as ShortCode,
	OCRD.cardname as ShortName,
	JDT.OffsetAccount [Contra Account],
	case
		when isnull(OCRD2.cardname,'')='' Then OACT2.AcctName
	else OCRD2.CardName  End as [Contra Account Name],
	JDT.RowDetails as [Line Memo],
	isnull(JDT.U_JE_Remarks,'') as Remarks,
	JDT.DepartmentCode as [Department],
	JDT.LocationCode as [Location],
	JDT.DistributionRule as [Expense Type],
	JDT.Debit as [Local Debit],
	JDT.Credit as [Local Credit],
	JDT.Debit - JDT.Credit  as [Local Balance],
	null as [Local Currency],
	JDT.SystemDebitAmount as [USD Debit],
	JDT.SystemCreditAmount as [USD Credit],
	JDT.SystemDebitAmount - JDT.SystemCreditAmount as [USD Balance],
	JDT.ReconciliationDate as [Reconciliation Date],
	JDT.TransactionType as [TransactionType],
	TT.[Transaction] AS Transaction_Type,
	COALESCE(JDT.U_JE_Remarks,JDT.RowDetails) as [Document Description],  --U_Remarks first, then AP line, then JDT1 line) 	2/9/17
	--COALESCE(JDT.U_JE_Remarks, case when pch1.itemcode is null then PCH1.Dscription else PCH1.[text] end,JDT.linememo) as [Document Description],  --U_Remarks first, then AP line, then JDT1 line) 	2/9/17
	case
		when ISNULL(JDT.ReverseTransaction,'')<>'' then 'Reversal entries'
		when exists (select * from JournalEntries as T4 where T4.ReverseTransaction = JDT.TransactionID and T4.CountryCode = JDT.CountryCode) then 'Reversed'
	else 'Valid' end as Reversed,
	JDT.BaseReference as [Doc Num],
	--OACT2.FatherNum,
	--OACT2.AcctName as ContraCategrory,
	--OACT3.FatherNum,
	OACT3.AcctName as ContraCategrory
	
FROM JournalEntries as JDT
Left Join OACT			ON  OACT.AcctCode=JDT.AccountCode   and OACT.countrycode = JDT.countrycode
Left Join OACT OACT2	ON OACT2.AcctCode=JDT.OffsetAccount and OACT2.countrycode = JDT.countrycode -- to get contra name and contra father
Left Join OACT OACT3	ON OACT2.FatherNum=OACT3.AcctCode and OACT2.countrycode = OACT3.countrycode -- to get father name
left join OCRD on OCRD.CardCode = JDT.BPAccountCode and  JDT.countrycode =  OCRD.countrycode 
left join OCRD OCRD2 on OCRD2.CardCode = JDT.OffsetAccount and  JDT.countrycode =  OCRD2.countrycode
left join DimSapUsers OUSR on JDT.UserSignature = OUSR.USERID and JDT.Countrycode = OUSR.Countrycode
left join dbo.DimTransactionType TT on JDT.TransactionType = TT.TransId  
/*left join PCH1 
	on JDT.TransType = 18 --limit to only AP Invoices (we could do this for other documents eventually)
	and year(JDT.refdate) > 2016 --limit to 2017 entries as the line to line feature was not turned on in 2016
	and JDT.docline >= 0 --will default to -1 if the line has no link (e.g. vendor payable from invoice)
	and JDT.Createdby = PCH1.Docentry --link the Invoice internal number (docentry) it's reference in JDJDT link (createdby)
	and JDT.docline = PCH1.LineNum --link invoice line to JDT1 line
	and JDT.countrycode = PCH1.countrycode
	*/
;
  