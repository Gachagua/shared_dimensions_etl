/*
v9 16-08-2019 DK - Added U_WebPRID to the query
v8 01/07/2019 MW - changed OP # to pull document number vs document entry
v7 12/06/2019 MW - updated from the table Transaction_type to DimTransactionType
v5 12/03/2019 DK - changed join to ApDownPayments to Outgoingpayments from documententry to ReceiptNum
v4: DK- changed join to APinvoices to OutgiongPayments.
V3: DK-updated reportt to pull data from new tables, updated Attachment path
V2: Added a replace for attachments with # in the url

*/
--use OAF_SAP_DATAWAREHOUSE;
CREATE VIEW [dbo].[OutgoingPayment_DocView] AS

SELECT distinct
	OVPM.CountryCode AS [Country Code], 
	OVPM.createdate AS [OP Create Date], 
	OVPM.DocumentCurrency as DocCurr, 
	OVPM.DocumentDate AS [OP Doc Date], 
	ovpm.DocumentNumber as [OP #], -- this was DocEntry; edited July 1 2019 MW
	OVPM.DocumentEntry AS [OP ID], 
	OVPM.BusinessPartnerCode AS VendorCode,
	OVPM.BusinessPartnerName AS Vendor, 
    OVPM.U_IN_BANK, 
	OVPM.U_PAYEE_NAME, 
	OVPM.U_BANK_ACCT_NO, 
	OVPM.U_Bank_Code,
	OVPM.U_VendorAdd, 
	OVPM.DocumentTotal as doctotal, 
	OVPM.DocumentTotalSC as doctotalsy,
	OVPM.InvoiceID,
	(SELECT [Transaction] FROM dbo.DimTransactionType WHERE (TransId = OVPM.InvoiceCategory)) AS InvType, 
	OVPM.PaidInSC AS InvAmountUSD, 
	OVPM.PaidToInvoice as InvAmount, 
	OVPM.AppliedWTax as WtAppld, 
	OVPM.AppliedWTaxSystemCurrency as WtAppldSC,
	isnull(OPCH.documentnumber, Isnull(ODPO.documentnumber, OVPM.DocumentEntry)) InvNum,
	isnull(OPCH.U_WebPRID, ODPO.U_WebPRID) AS WPPRID,
	OPCH.U_WebProcNumber WPPOID,
	OVPM.comments, 
	CASE 
		WHEN ATC1.filename IS NULL THEN NULL 
		WHEN ATC1.FileName IS NOT NULL THEN replace(replace(cast(ATC1.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/')+ '\' + Concat(replace(replace(ATC1.FileName, '%', '%25'), '#', '%23'), '.', ATC1.FileExtension)
		END AS [Att. 1], 
                         
	CASE 
		WHEN ATC2.filename IS NULL THEN NULL 
		WHEN ATC2.FileName IS NOT NULL THEN replace(replace(cast(ATC2.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/')+ '\' + Concat(replace(replace(ATC2.FileName, '%', '%25'), '#', '%23'), '.', ATC2.FileExtension)
		END AS [Att. 2], 

	CASE 
		WHEN ATC3.filename IS NULL THEN NULL 
		ELSE replace(replace(cast(ATC3.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/') + '/' + Concat(replace(replace(ATC3.FileName, '%', '%25'), '#', '%23'), '.', ATC3.FileExtension)
	END AS [Att. 3], 

	CASE 
		WHEN ATC4.filename IS NULL THEN NULL 
		ELSE replace(replace(cast(ATC4.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/') + '/' + Concat(replace(replace(ATC4.FileName, '%', '%25'), '#', '%23'), '.', ATC4.FileExtension)
	END AS [Att. 4], 

	CASE 
		WHEN ATC5.filename IS NULL THEN NULL 
		ELSE replace(replace(cast(ATC5.TargetPath as nvarchar(max)), '\\u188967.your-storagebox.de\backup\SAP_Documents', 'https://receipts.oneacrefund.org:8043'), '\', '/') + '/' + Concat(replace(replace(ATC5.FileName, '%', '%25'), '#', '%23'), '.', ATC5.FileExtension)
	END AS [Att. 5]

FROM dbo.OutgoingPayments OVPM 
	LEFT OUTER JOIN  dbo.ApInvoices OPCH ON 
		OVPM.BaseDocumentEntry = OPCH.documententry AND 
		OPCH.CountryCode = OVPM.CountryCode 
		AND OVPM.InvoiceCategory = 18 
	LEFT OUTER JOIN dbo.APDownPayments ODPO ON 
		OVPM.BaseDocumentEntry = ODPO.documententry AND
		--OVPM.documententry = ODPO.Receiptnum AND 
		ODPO.CountryCode = OVPM.CountryCode 
		AND OVPM.InvoiceCategory = 204 
	LEFT OUTER JOIN  dbo.Attachments ATC1 ON ATC1.AbsoluteEntry = ISNULL(OPCH.AttachmentEntry, ODPO.AttachmentEntry) AND ATC1.CountryCode = OVPM.CountryCode AND ATC1.RowNumber = 1 
	LEFT OUTER JOIN  dbo.Attachments AS ATC2 ON ATC2.AbsoluteEntry = ISNULL(OPCH.AttachmentEntry, ODPO.AttachmentEntry) AND ATC2.CountryCode = OVPM.CountryCode AND ATC2.RowNumber = 2 
	LEFT OUTER JOIN  dbo.Attachments AS ATC3 ON ATC3.AbsoluteEntry = ISNULL(OPCH.AttachmentEntry, ODPO.AttachmentEntry) AND ATC3.CountryCode = OVPM.CountryCode AND ATC3.RowNumber = 3 
	LEFT OUTER JOIN  dbo.Attachments AS ATC4 ON ATC4.AbsoluteEntry = ISNULL(OPCH.AttachmentEntry, ODPO.AttachmentEntry) AND ATC4.CountryCode = OVPM.CountryCode AND ATC4.RowNumber = 4 
	LEFT OUTER JOIN  dbo.Attachments AS ATC5 ON ATC5.AbsoluteEntry = ISNULL(OPCH.AttachmentEntry, ODPO.AttachmentEntry) AND ATC5.CountryCode = OVPM.CountryCode AND ATC5.RowNumber = 5


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[19] 4[6] 2[70] 3) )"
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
         Begin Table = "OutgoingPayments"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 285
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "APInvoices"
            Begin Extent = 
               Top = 6
               Left = 323
               Bottom = 136
               Right = 622
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "APDownPayments"
            Begin Extent = 
               Top = 6
               Left = 660
               Bottom = 136
               Right = 959
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ATC1"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ATC2"
            Begin Extent = 
               Top = 138
               Left = 246
               Bottom = 268
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ATC3"
            Begin Extent = 
               Top = 138
               Left = 454
               Bottom = 268
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ATC4"
            Begin Extent = 
               Top = 138
               Left = 662
               Bottom = 268
               Right = 832
            End
            DisplayFlags =', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'OutgoingPayment_DocView';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' 280
            TopColumn = 0
         End
         Begin Table = "ATC5"
            Begin Extent = 
               Top = 138
               Left = 870
               Bottom = 268
               Right = 1040
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'OutgoingPayment_DocView';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'OutgoingPayment_DocView';

