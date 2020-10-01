--use oaf_sap_datawarehouse;


CREATE VIEW fas.v_Mapping_TrialBalance AS
select * from trial_balance_allocation
