--use oaf_sap_datawarehouse;

create view fas.v_GrantTransactions as

select
	GrantTx.[Date]
	,GrantTx.Account as AccountCode
	,GrantTx.[Account Name] as AccountName
	,-GrantTx.[Actual Balance USD] as Spend
	,GrantRestricts.RestrictID
	,GrantRestricts.[Grant] as GrantName
	,GrantTx.Country as CountryName
	,GrantTx.[Database] as DatabaseName
	,GrantTx.Department as DepartmentCode
	,GrantTx.[Dept Allocated] as DepartmentName
	,GrantTx.ProjectCode
	,GrantTx.ProjectName
	,GrantTx.Business_Unit as BusinessUnit
	,GrantTx.Boardline as BoardLine
	,GrantTx.BVA_Level_1_Grants as BVALevel1
	,GrantTx.BVALevel2
	,GrantTx.[JE Num] as JENumber
	,GrantTx.Line_ID + 1 as LineID
	,GrantTx.Transaction_Type as TransactionType
	,GrantTx.[Doc Num] as DocumentNumber
	,GrantTx.Remarks

From GrantAllocations as GrantTx
left join AllocationGrant as GrantRestricts
	on GrantTx.RestrictID = GrantRestricts.RestrictID