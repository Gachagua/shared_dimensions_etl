CREATE VIEW fas.v_TxPull_Intercompany_Inventory
AS
SELECT DISTINCT 
                         fas.v_TxPull.[Create Date], fas.v_TxPull.[Payment Date], fas.v_TxPull.[Database], fas.v_TxPull.U_NAME, fas.v_TxPull.[Country JE Trans No.], fas.v_TxPull.[JE Line No.], fas.v_TxPull.Account, fas.v_TxPull.[Account Name], 
                         fas.v_TxPull.ShortCode, fas.v_TxPull.ShortName, fas.v_TxPull.[Contra Account], fas.v_TxPull.[Contra Account Name], fas.v_TxPull.[Line Memo], fas.v_TxPull.Remarks, fas.v_TxPull.Department, fas.v_TxPull.Location, 
                         fas.v_TxPull.[Expense Type], fas.v_TxPull.[Local Debit], fas.v_TxPull.[Local Credit], fas.v_TxPull.[Local Balance], fas.v_TxPull.[Local Currency], fas.v_TxPull.[USD Debit], fas.v_TxPull.[USD Credit], fas.v_TxPull.[USD Balance], 
                         fas.v_TxPull.[Reconciliation Date], fas.v_TxPull.TransactionType, fas.v_TxPull.Transaction_Type, fas.v_TxPull.[Document Description], fas.v_TxPull.Reversed, fas.v_TxPull.[Doc Num], fas.v_TxPull.BatchNumber, 
                         dbo.APInvoices.DocumentNumber, dbo.APInvoices.U_ARRec
FROM            fas.v_TxPull LEFT OUTER JOIN
                         dbo.OutgoingPayments ON fas.v_TxPull.TransactionType = 46 AND fas.v_TxPull.[Doc Num] = dbo.OutgoingPayments.DocumentNumber AND fas.v_TxPull.[Database] = dbo.OutgoingPayments.CountryCode LEFT OUTER JOIN
                         dbo.APInvoices ON dbo.OutgoingPayments.InvoiceCategory = '18' AND dbo.OutgoingPayments.DocumentEntry = dbo.APInvoices.DocumentEntry AND dbo.OutgoingPayments.CountryCode = dbo.APInvoices.CountryCode
WHERE        (fas.v_TxPull.Account = '2021015')

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
         Begin Table = "v_TxPull (fas)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 246
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OutgoingPayments"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 288
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "APInvoices"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 337
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
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
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
', @level0type = N'SCHEMA', @level0name = N'fas', @level1type = N'VIEW', @level1name = N'v_TxPull_Intercompany_Inventory';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'fas', @level1type = N'VIEW', @level1name = N'v_TxPull_Intercompany_Inventory';

