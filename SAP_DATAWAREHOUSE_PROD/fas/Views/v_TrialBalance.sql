--use OAF_SAP_DATAWAREHOUSE;
CREATE view fas.v_TrialBalance as

select 
t2.countrycode as [Database],
ISNULL(t2.AccountCode,t0.acctcode) as Account, 
t0.acctname [Account Name],
Case When ISNULL(t2.AccountCode,t0.acctcode) < 2000000 Then 'ASSETS'
	When ISNULL(t2.AccountCode,t0.acctcode) < 3000000 Then 'LIABILITIES'
	When ISNULL(t2.AccountCode,t0.acctcode) < 4000000 Then 'NET ASSETS'
	When ISNULL(t2.AccountCode,t0.acctcode) < 5000000 Then 'REVENUES'
	Else 'EXPENSES' End as [Account Type],
t0.U_CodeType BVALevel1, 
t0.U_CodeSubType BVALevel2, 
t1.TB_Code, 
t1.TB_Name, 
T1.TB_Type,  
ABS(ISNULL(SUM(t2.SystemDebitAmount),0)) as [USD Debit],
ABS(ISNULL(SUM(t2.SystemCreditAmount),0)) as [USD Credit],
Isnull(SUM(T2.SystemDebitAmount-t2.SystemCreditAmount),0) as [USD Amount],
ABS(ISNULL(SUM(t2.debit),0)) as [Local Debit],
ABS(ISNULL(SUM(t2.credit),0)) as [Local Credit],
Isnull(SUM(T2.debit-t2.credit),0) as [local Amount],
case 
	when t2.transactionType <> '-3' then 'After year close date only' 
	else 'Include all up until end date' 
end as TxType,
CAST(DimDate.LastDayOfMonth as date) as LastDayOfMonth

from JournalEntries t2
full outer join OACT t0 on 
	t2.AccountCode = t0.acctcode and 
	--t2.PostingDate <= @EndDate and 
	t2.countrycode=t0.countrycode
left join trial_Balance_allocation t1 on t1.account = t0.acctcode
left join [$(OAF_SHARED_DIMENSIONS)].dbo.dimdate on dimdate.[date] = t2.PostingDate

where 
( 
	isnull(t2.AccountCode,'') <> '' and 
	t2.AccountCode < '4000000' and 
	--t2.PostingDate <= @EndDate and 
	t2.CountryCode is not null
)
/*
and (
	(
		year(t2.PostingDate) > @CloseYear 
		and t2.transactionType <> '-3'
	) or 
		year(t2.PostingDate) <= @CloseYear
)
*/
GROUP BY 
t2.countrycode,
t2.AccountCode, 
t0.acctcode,  
t0.acctname, 
t0.U_CodeType, 
t0.U_CodeSubType,
t1.TB_Code, 
t1.TB_Name, 
T1.TB_Type,
case when t2.transactionType <> '-3' then 'After year close date only' else 'Include all up until end date' end,
DimDate.LastDayOfMonth

-------------------IS Lines------------------------------------------------
union all

select 
t2.countrycode as [Database],
ISNULL(t2.AccountCode,t0.acctcode) as Account, 
t0.acctname [Account Name],
Case When  ISNULL(t2.AccountCode,t0.acctcode) < 2000000 Then 'ASSETS'
	When  ISNULL(t2.AccountCode,t0.acctcode) < 3000000 Then 'LIABILITIES'
	When  ISNULL(t2.AccountCode,t0.acctcode) < 4000000 Then 'NET ASSETS'
	When  ISNULL(t2.AccountCode,t0.acctcode) < 5000000 Then 'REVENUES'
	Else 'EXPENSES' End as [Account Type],
t0.U_CodeType BVALevel1, 
t0.U_CodeSubType BVALevel2, 
t1.TB_Code, 
t1.TB_Name, 
T1.TB_Type,  
ABS(ISNULL(SUM(t2.SystemDebitAmount),0)) as [USD Debit],
ABS(ISNULL(SUM(t2.SystemCreditAmount),0)) as [USD Credit],
Isnull(SUM(T2.SystemDebitAmount-t2.SystemCreditAmount),0) as [USD Amount],
ABS(ISNULL(SUM(t2.debit),0)) as [Local Debit],
ABS(ISNULL(SUM(t2.credit),0)) as [Local Credit],
Isnull(SUM(T2.debit-t2.credit),0) as [local Amount],
'Within start and end date' as TxType,
CAST(DimDate.LastDayOfMonth as date) as LastDayOfMonth

from JournalEntries t2
full outer join OACT t0 on 
	t2.AccountCode = t0.acctcode and 
	t2.countrycode = t0.countrycode 
	--and t2.PostingDate <= @EndDate and t2.PostingDate >= @StartDate
left join trial_Balance_allocation t1 on t1.account = t0.acctcode
left join [$(OAF_SHARED_DIMENSIONS)].dbo.dimdate on dimdate.[date] = t2.PostingDate

where 
	isnull(t2.AccountCode,'') <> '' and 
	t2.AccountCode >= '4000000' and 
	t2.CountryCode is not null and
	isnull(t2.transactionType,'') <> '-3' --and
--	t2.PostingDate <= @EndDate and 
--	t2.PostingDate >= @StartDate 

GROUP BY 
t2.countrycode,
t2.AccountCode, 
t0.acctcode,  
t0.acctname, 
t0.U_CodeType, 
t0.U_CodeSubType,
t1.TB_Code, 
t1.TB_Name, 
T1.TB_Type,
DimDate.LastDayOfMonth

