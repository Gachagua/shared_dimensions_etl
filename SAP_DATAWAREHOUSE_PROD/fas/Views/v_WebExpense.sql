/*
Update date: 18/7/2018
Updated by: Marika
Update:
	v4: AV 2019-09-18
	V3:
		Added Job grade
		Removed the month and year fields - we have date dims
	V2: Clean up the query before handing over to FAS
*/
CREATE VIEW fas.v_WebExpense
AS
SELECT        dbo.Expense.ExpenseId, dbo.Expense.ExpenseCodeName AS ExpenseCode, dbo.Expense.ExpenseTypeName AS ExpenseType, dbo.Expense.Description, dbo.Expense.Quantity, dbo.Expense.UnitPrice, 
                         dbo.Expense.TotalCost, dbo.Expense.CurrencyCode, dbo.Expense.USDCost, dbo.Expense.FullName AS Requester, dbo.Expense.Email AS RequesterEmail, jg.JobGradeName AS JobGrade, 
                         CASE JobGradeName WHEN 'JG5temp' THEN '5' WHEN 'Senior Field Director' THEN '4' WHEN 'Field Director' THEN '3' WHEN 'Field Manager' THEN '2' WHEN 'Field Officer' THEN '1' WHEN NULL 
                         THEN '0' ELSE jg.JobGradeCode END AS JG_Num, dbo.Expense.Approver, dbo.Expense.Comments, dbo.Expense.CashAdvance, dbo.Expense.SapJournalEntryNumber, dbo.Expense.CountryCode AS LocationCountryCode, 
                         CASE WHEN expense.CountryCode = 'US' THEN 'GLB' WHEN expense.locationcode = 'GLB' THEN 'GLB' WHEN Dept.departmentType = 'Global' THEN 'GLB' ELSE expense.countrycode END AS BvaCountryCode, 
                         dbo.Expense.CountryName, dbo.Expense.DepartmentCode, dbo.Expense.DepartmentName, Dept.DepartmentType AS LocationCode, dbo.Expense.LocationName, [$(OAF_SHARED_DIMENSIONS)].dbo.v_Projects.ProjectCode, 
                         [$(OAF_SHARED_DIMENSIONS)].dbo.v_Projects.ProjectName, [$(OAF_SHARED_DIMENSIONS)].dbo.v_Projects.ProjectId, dbo.Expense.ExpenseDate, dbo.Expense.CreateDate, dbo.Expense.Status, 
                         CASE [status] WHEN 'Approved' THEN 'Approved' WHEN 'Awaiting_SAP_Import' THEN 'Approved' WHEN 'Bank_Uploaded' THEN 'Approved' WHEN 'Draft' THEN 'Draft' WHEN 'Failed_SAP_Import' THEN 'Payment error' WHEN 'FinanceApproved'
                          THEN 'Approved' WHEN 'Paid' THEN 'Paid' WHEN 'PayrollExported' THEN 'Paid' WHEN 'Rejected' THEN 'Rejected' WHEN 'SAP_Loaded' THEN 'Approved' WHEN 'Submitted' THEN 'Submitted' ELSE 'OTHER' END AS SimpleStatus
FROM            dbo.Expense LEFT OUTER JOIN
                         dbo.DepartmentAllocation AS Dept ON dbo.Expense.DepartmentCode = Dept.DepartmentCode AND (dbo.Expense.ExpenseYear = Dept.mapping_year OR
                         dbo.Expense.ExpenseYear < 2016 AND Dept.mapping_year = 2016) LEFT OUTER JOIN
                         fas.v_JobGrade AS jg ON dbo.Expense.JobGradeId = jg.JobGradeId LEFT OUTER JOIN
                         [$(OAF_SHARED_DIMENSIONS)].dbo.v_Projects ON dbo.Expense.ProjectId = [$(OAF_SHARED_DIMENSIONS)].dbo.v_Projects.ProjectId
WHERE        (dbo.Expense.ExpenseTypeName <> 'QOL')

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Expense"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Dept"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "jg"
            Begin Extent = 
               Top = 6
               Left = 293
               Bottom = 136
               Right = 463
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "v_Projects (OAF_SHARED_DIMENSIONS.dbo)"
            Begin Extent = 
               Top = 6
               Left = 501
               Bottom = 136
               Right = 671
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'fas', @level1type = N'VIEW', @level1name = N'v_WebExpense';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'fas', @level1type = N'VIEW', @level1name = N'v_WebExpense';

