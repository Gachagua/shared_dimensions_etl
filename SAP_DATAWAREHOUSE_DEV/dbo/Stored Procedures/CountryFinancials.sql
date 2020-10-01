CREATE PROCEDURE [dbo].[CountryFinancials] @StartDate as Date, @EndDate as Date 
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
   SET NOCOUNT ON;

-- Insert statements for procedure here

Select   
t1.countrycode as [Database],  
DATEFROMPARTS(YEAR(t1.refdate),MONTH(t1.refdate),1) as [Month],
T1.ShortName as AcctCode,   
left(t1.account,1)+'. '+e.AcctName as [Level 1],   
c.AcctName as [Level 2],  
case  when isnull(T2.cardname,'')='' Then T3.AcctName+' ('+ t1.shortname+')' else t2.CardName+' ('+ t1.shortname+')'  End as [Account Name],
Account=(case when T3.AcctCode is Null then  T2.CardCode else   T3.AcctCode end),
Case
When (Left(T3.[AcctCode],1)='1' or Left(T2.CardCode,1)='1') then '1' 
When (Left(T3.[AcctCode],1)='2' or Left(T2.CardCode,1)='2') then '2'
When (Left(T3.[AcctCode],1)='3' or Left(T2.CardCode,1)='3') then '3'
When (Left(T3.[AcctCode],1)='4' or Left(T2.CardCode,1)='4') then '4'
When (Left(T3.[AcctCode],1)='5' or Left(T2.CardCode,1)='5') then '5'
When (Left(T3.[AcctCode],1)='6' or Left(T2.CardCode,1)='6') then '6'
When (Left(T3.[AcctCode],1)='7' or Left(T2.CardCode,1)='7') then '7' 
end as 'Chart',
SUM(t1.SysDeb) as [Debit (USD)],
SUM(t1.SysCred) as [Credit (USD)], 
Sum(t1.SysDeb - t1.SysCred) as [Balance (USD)],
case
when T1.CountryCode='US' and T3.ActCurr='USD' then  SUM(t1.SysDeb) 
when T1.CountryCode<>'US' and T3.ActCurr='USD' then  SUM(t1.SysDeb) 
when T1.CountryCode='US' and T3.ActCurr<>'USD' then  SUM(t1.FCDebit)
else SUM(t1.Debit)
end  as [Debit (Local)], 
case
when T1.CountryCode='US' and T3.ActCurr='USD' then  SUM(t1.SysCred) 
when T1.CountryCode<>'US' and T3.ActCurr='USD' then  SUM(t1.SysCred) 
when T1.CountryCode='US' and T3.ActCurr<>'USD' then SUM(t1.FCCredit)
else SUM(t1.Credit)
end as [Credit (Local)],
case
when T1.CountryCode='US' and T3.ActCurr='USD' then  SUM(t1.SysDeb - t1.SysCred)
when T1.CountryCode<>'US' and T3.ActCurr='USD' then  SUM(t1.SysDeb - t1.SysCred)
when T1.CountryCode='US' and T3.ActCurr<>'USD' then  SUM(t1.FCDebit - t1.FCCredit)
else SUM(t1.Debit-t1.Credit)
end as [Balance (Local)]

from OJDT T0  
left join jdt1 T1 on T0.transid = T1.transid and t0.countrycode = t1.countrycode
left join OCRD T2 on T1.Shortname = T2.CardCode  and t2.countrycode = t1.countrycode
left join OACT T3 on T1.Account = T3.AcctCode  
left join OACT b on b.AcctCode = T3.FatherNum  
left join OACT c on b.fathernum = c.acctcode  
left join OACT d on c.fathernum = d.AcctCode  
left join OACT e on d.fathernum = e.acctcode  

WHERE  (t1.countrycode='KE')


Group by 
DATEFROMPARTS(YEAR(t1.refdate),MONTH(t1.refdate),1),
T1.Project,  
T1.ShortName,
t1.account,
e.AcctName, 
c.AcctName, 
T3.ActCurr,
T2.cardname,
T2.CardCode,
T3.AcctName,
T3.AcctCode,
t1.countrycode



END
