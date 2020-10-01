--use oaf_sap_datawarehouse;


CREATE VIEW fas.v_Budget_Expense AS
select * from dbo.[@OAF_BUDGET]
