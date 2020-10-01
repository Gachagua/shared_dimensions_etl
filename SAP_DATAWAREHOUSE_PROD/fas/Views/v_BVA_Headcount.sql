/*
Date: 1/2/2018
Updated by: Marika
Update notes: 
V5 2019-04-09 MW - pull from DimCountry in the shared dimensions (vs SAP db)
V3: Added column for database, added a column for country_department (BVA permissions), deleted salary, benefits and tax columns
V2: Added a column for account code that corresponds to the account code for that JG's salary account
*/

--USE OAF_SAP_DATAWAREHOUSE;
CREATE VIEW fas.v_BVA_Headcount AS  

-- Headcount actuals  
select
	t1.payrollMonth as Date
	,case -- country    
		when t1.paypointcode = 'GLB' then 'Global'    
		when t1.Country ='US' then 'Global'    
		when t4.departmentType = 'Global' then 'Global'     
	else t5.CountryName   end as Country
	,t1.DepartmentCode as DeptCode
	,t4.departmentname as Department
	,1 as headcount
	,null as version
	,'Actual' as type
	,t1.EmployeeName
	,t1.StartDate
	,t1.JobTitle
	,case t1.jobgrade    
		when 'SFD' then 'Senior Field Director'   
		when 'JG5TEMP' then 'Extern (JG5)'   
		when 'FM' then 'Field Manager'    
		when 'FO' then 'Field Officer'   
		when 'FD' then 'Field Director'  
	else t2.BVA_Level_2 end as [Job Grade]
	,t1.PayGrade
	,CASE when t1.payrollMonth <= BC.ClsdThrough then 'Closed' else 'Pending' end as [Books Closed]   
	,case t1.jobgrade    
		when 'SFD' then 19    
		when 'FD' then 18    
		when 'FM' then 17    
		when 'FO' then 16    
		when 'JG5TEMP' then 27  
	 else t2.BVALevel2Order end as JGSort     
	,case t1.jobgrade    
		when 'SFD' then 6010013  
		when 'JG5TEMP' then 6011002   
		when 'FM' then 6010011   
		when 'FO' then 6010001  
		when 'FD' then 6010012 
    else t2.AcctCode end as [Account]  
	,t1.Country as [Database]
	,concat(case -- country    
		when t1.paypointcode = 'GLB' then 'ORG'    
		when t1.Country ='US' then 'ORG'    
		when t4.departmentType = 'Global' then 'ORG'     
	else t1.Country end,'_',t1.DepartmentCode) as Country_Department


from headcountsnapshot as t1  
join DepartmentAllocation as t4 on t1.DepartmentCode = t4.DepartmentCode and year(payrollMonth) = t4.Mapping_Year 
join [$(OAF_SHARED_DIMENSIONS)].dbo.DimCountry as t5 on t5.countrycode = t1.Country  
left join (select distinct bva.bva_level_2, bva.bvalevel2order, bva.AcctCode
			from allocationbvalevel as bva 
			where bva.bva_level_1 = 'Salary' and mapping_year = 2018 and CHARINDEX('Salary',bva.AcctName)<>0) t2 
	on t1.JobGrade = t2.bva_level_2  
left join BooksClosed BC on BC.countrycode = t1.country   

where year(t1.payrollMonth)>2016   
 
union all    

-- Headcount budget  
select
	u_budgetdate as date
	,case -- country    
		when t1.U_CountryCode ='US' then 'Global'   
		when t4.departmentType = 'Global' then 'Global'    
		else t5.CountryName
	end as Country
	,t1.u_deptcode as DeptCode
	,t4.departmentname as Department
	,u_headcountbudget as headcount
	,u_version as version
	,'Budget' as type
	,null as EmployeeName
	,null as StartDate
	,null as JobTitle
	,t2.BVA_Level_2 as [Job Grade]
	,null as PayGrade
	,'Closed' as [Books Closed]   -- always want to see the full budget
	,t2.BVALevel2Order    
	,t1.u_levelcode as Account
	,t1.U_CountryCode as [Database]
	,concat(case -- country    
			when t1.U_CountryCode ='US' then 'ORG'   
			when t4.departmentType = 'Global' then 'ORG'    
			else t1.U_CountryCode
		end,'_',t1.U_DeptCode) as Country_Department

from dbo.[@OAF_HEADCOUNTBUDGET] as t1  
join DepartmentAllocation as t4 on t1.u_deptcode = t4.DepartmentCode and year(u_budgetdate) = t4.Mapping_Year  
join [$(OAF_SHARED_DIMENSIONS)].dbo.DimCountry as t5 on t5.countrycode = t1.u_countrycode  
left join AllocationBvaLevel t2 on t1.u_levelcode = t2.acctcode and year(u_budgetdate) = t2.Mapping_Year -- limit to 2017 because want in JG terms  
 
 where year(u_budgetdate)>2016
;