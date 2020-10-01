/*
Update:
V8: 2019-04-16 MW: added job title
V7: 2019-02-24 MW: added India and Nigeria, changed Global logic to be based on table vs hard coded
V6: 2018-11-06 MW: removed employee number as a way to match employees since ethiopia data frequently is missing that
V5:	Removed Zambia - it's in VIP now - and updated some logic to find termination dates
V4:	Added email via join with OHEM
V3:	Don't need to worry about leading zeros -- removed them from headcountsnapshot
V2: Added termination date, start date, email
*/

CREATE VIEW HR.v_NewCountryNotConfidential as
--use oaf_sap_datawarehouse;

-- JG1-4 (New Countries)
select
	emp.EmployeeNumber as EmployeeCode
	,CASE CHARINDEX(' ', emp.EmployeeName, 1)
		WHEN 0 THEN emp.EmployeeName -- empty or single word
		ELSE SUBSTRING(emp.EmployeeName, 1, CHARINDEX(' ', emp.EmployeeName, 1) - 1) -- multi-word
	END as FirstName
	,CASE CHARINDEX(' ', emp.EmployeeName, 1)
		WHEN 0 THEN emp.EmployeeName -- empty or single word
		ELSE SUBSTRING(emp.EmployeeName,CHARINDEX(' ', emp.EmployeeName, 1) + 1, len(emp.employeeName)) -- multi-word
	END as LastName
	,emp.EmployeeName as FullName
	,c.countryname as CountryLocation
	,emp.JobGrade
	,l.LocationName--city,
	,d.DepartmentName as Department
	,case
		when d.DepartmentType = 'Global' then 'Global'
		when c.CountryCode = 'US' then 'Global'
	else c.CountryName End as CountryFinance
	,emp.StartDate
	,Case when emp.payrollmonth > getdate() - 75 and year(emp.PayrollMonth) = year(getdate()) Then null else emp.payrollmonth + 30 end as TerminationDate
	,ohem.email as Email
	,'New Country' as SourceSystem
	,null as BambooHomeCountry
	,null as Manager
	,null as HomeEmail
	,emp.JobTitle

from headcountsnapshot emp
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimCountry c on emp.Country = c.CountryCode
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimLocations l on emp.PaypointCode = l.LocationCode and c.CountryID = l.CountryId
left join [$(OAF_SHARED_DIMENSIONS)].dbo.DimDepartments d on emp.DepartmentCode = d.DepartmentCode and c.CountryID = d.CountryId
left join [$(OAF_HR_DATAWAREHOUSE)].dbo.OHEM on 
	(ohem.firstname = emp.employeename and emp.country = ohem.countrycode and emp.country = 'eth')
	or (concat(ohem.firstname,' ',ohem.lastname) = emp.employeename and emp.country = ohem.countrycode and emp.country <> 'eth')

-- the below inner join selects only the max payroll month for each employee
inner join (
	select country, max(payrollmonth) as payrollmonth, employeeName
	from HeadcountSnapshot
	where country in ('ETH','MM','IN','NG')
	group by Country, employeeName
) b on 
	b.Country = emp.Country
	and b.EmployeeName = emp.EmployeeName 
	and b.payrollmonth = emp.PayrollMonth

where
	JobGrade not in ('JG5','JG6','JG7','JG5TEMP')
	and emp.Country in ('ETH','MM','IN','NG')
