CREATE VIEW fin.v_WebPayments AS

--use oaf_sap_datawarehouse;

select
Paymentid,
payment.ExpenseId,
payment.PaymentBatchHistoryId,
payment.SAPJournalEntryNumber,
InternalPaymentNumber,
payment.Approver,
(select countryname from [$(OAF_SHARED_DIMENSIONS)].dbo.DimCountry country where country.countrycode = payment.countrycode) Country,
PaymentType,
IsNull(CarrierName,BankName + '-' + BankBranchName) [Bank_CarrierName],
IsNull(Recipient, BankAccountName) Recipient,
IsNull(PhoneNumber,BankAccontNumber) Account_PhoneNumber,
SWIFTCode BankCode,
payment.Description,
payment.ExpenseDate,
payment.CreatedDate,
Payment.DepartmentCode,
Payment.LocationCode,
JobGradeName,
(select  projectcode from [$(OAF_SHARED_DIMENSIONS)].dbo.DimProjects project where project.ProjectID = payment.projectid) project,
(select aspnetusers.fullname from expense left join [$(OAF_HR_DATAWAREHOUSE)].dbo.aspnetusers on aspnetusers.id = expense.applicationuserid where expense.expenseid = payment.expenseid) Requester,
payment.StatusID,
WPStatus.StatusName,
payment.ExpenseCodeValue,
TotalCostCredit Credit,
TotalCostDebit Debit,
payment.CurrencyCode,
payment.CasualWorkerId,
dateadd(hour, 3, GETUTCDATE()) Timestamp
,Expense.ExpenseHeaderId as HeaderId
,DocumentTypeName
,isnull(blobname, 'attachments-expense/' + GuidFileName) FilePath

from WebPayments payment 
left join DimDocumentType documenttype on documenttype.documenttypeid = payment.documenttypeid
left join expense on payment.expenseId = expense.expenseid
left join DimFile [file] on isnull(expense.expenseheaderid, expense.expenseid) = isnull([File].expenseheaderid, [file].expenseid)
left join WebExpenseStatus WPStatus on payment.StatusId = WPStatus.StatusId

where documenttypename in ('Local Staff Expense','Casual Worker','Expenses For Others') 


