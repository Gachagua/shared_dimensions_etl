CREATE TABLE [dbo].[JournalEntries] (
    [CreatedBy]                       INT             NULL,
    [Project]                         NVARCHAR (20)   NULL,
    [DataSource]                      VARCHAR (1)     NULL,
    [UpdateDate]                      DATETIME        NULL,
    [CreateDate]                      DATETIME        NULL,
    [Series]                          INT             NULL,
    [Number]                          INT             NULL,
    [U_STAFF_EXP_NO]                  INT             NULL,
    [U_ATTCH1]                        NVARCHAR (MAX)  NULL,
    [U_ATTCH2]                        NVARCHAR (MAX)  NULL,
    [Debit]                           NUMERIC (19, 6) NULL,
    [Credit]                          NUMERIC (19, 6) NULL,
    [SourceID]                        INT             NULL,
    [Closed]                          VARCHAR (1)     NULL,
    [LineType]                        INT             NULL,
    [U_Row_No]                        INT             NULL,
    [U_BANK_NAME]                     NVARCHAR (100)  NULL,
    [U_BANK_ACCT_NO]                  NVARCHAR (20)   NULL,
    [U_WIP_PROJECT]                   NVARCHAR (30)   NULL,
    [U_JE_REMARKS]                    NVARCHAR (MAX)  NULL,
    [U_PAYEE_NAME]                    NVARCHAR (100)  NULL,
    [U_LCC]                           NVARCHAR (10)   NULL,
    [U_WebExpNum]                     INT             NULL,
    [U_Upload_Sts]                    NVARCHAR (20)   NULL,
    [U_Status]                        NVARCHAR (20)   NULL,
    [U_ExpenseId]                     INT             NULL,
    [DocLine]                         INT             NULL,
    [CountryCode]                     NVARCHAR (20)   NULL,
    [ProjectCode]                     NVARCHAR (20)   NULL,
    [TransactionID]                   INT             NULL,
    [TransactionType]                 NVARCHAR (20)   NULL,
    [BaseReference]                   NVARCHAR (11)   NULL,
    [PostingDate]                     DATETIME        NULL,
    [Details]                         NVARCHAR (50)   NULL,
    [TotalLocalCurrency]              NUMERIC (19, 6) NULL,
    [TotalForeignCurrency]            NUMERIC (19, 6) NULL,
    [TotalUSD]                        NUMERIC (19, 6) NULL,
    [UserSignature]                   SMALLINT        NULL,
    [ReverseTransaction]              INT             NULL,
    [DocumentSeries]                  INT             NULL,
    [GenerationTime]                  SMALLINT        NULL,
    [DocumentType]                    NVARCHAR (60)   NULL,
    [BAseAmountForeignCurrency]       NUMERIC (19, 6) NULL,
    [BaseTransactionNumber]           INT             NULL,
    [RowNumber]                       INT             NULL,
    [AccountCode]                     NVARCHAR (15)   NULL,
    [SystemCreditAmount]              NUMERIC (19, 6) NULL,
    [SystemDebitAmount]               NUMERIC (19, 6) NULL,
    [DebitForeignCurrency]            NUMERIC (19, 6) NULL,
    [CreditForeignCurrency]           NUMERIC (19, 6) NULL,
    [ForeignCurrency]                 NVARCHAR (3)    NULL,
    [SourceRowNumber]                 SMALLINT        NULL,
    [BPAccountCode]                   NVARCHAR (15)   NULL,
    [InternalReconciliationNumber]    INT             NULL,
    [ExternalReconciliationNumber]    INT             NULL,
    [OffsetAccount]                   NVARCHAR (15)   NULL,
    [RowDetails]                      NVARCHAR (50)   NULL,
    [Reference3]                      NVARCHAR (100)  NULL,
    [PostingDate2]                    DATETIME        NULL,
    [Reference1]                      NVARCHAR (100)  NULL,
    [Reference2]                      NVARCHAR (100)  NULL,
    [TransactionCode]                 NVARCHAR (4)    NULL,
    [DistributionRule]                NVARCHAR (8)    NULL,
    [ReconciliationDate]              DATETIME        NULL,
    [LinkedTransactionId]             INT             NULL,
    [LinkedRowNumber]                 INT             NULL,
    [LinkType]                        VARCHAR (1)     NULL,
    [DebitCreditLine]                 VARCHAR (1)     NULL,
    [StornoAccountCode]               NVARCHAR (15)   NULL,
    [BalanceDueDebit]                 NUMERIC (19, 6) NULL,
    [BalanceDueCredit]                NUMERIC (19, 6) NULL,
    [BalanceDueDebitForeignCurrency]  NUMERIC (19, 6) NULL,
    [BalanceDueCreditForeignCurrency] NUMERIC (19, 6) NULL,
    [BalanceDueDebitUSD]              NUMERIC (19, 6) NULL,
    [BalanceDueCreditUSD]             NUMERIC (19, 6) NULL,
    [DepartmentCode]                  NVARCHAR (8)    NULL,
    [LocationCode]                    NVARCHAR (8)    NULL,
    [CreateDateID]                    INT             NULL,
    [UpdateDateID]                    INT             NULL,
    [CurrencyID]                      INT             NULL,
    [PostingDateID]                   INT             NULL,
    [DepartmentID]                    INT             NULL,
    [LocationID]                      INT             NULL,
    [AccountID]                       INT             NULL,
    [CountryID]                       INT             NULL,
    [ProjectName]                     NVARCHAR (100)  NULL,
    [ReferenceDate]                   DATETIME        NULL,
    [BankExportDate]                  DATETIME        NULL,
    [TransactionCurrency]             NVARCHAR (3)    NULL,
    [DueDate]                         DATETIME        NULL,
    [BatchNumber]                     INT             NULL,
    [ETLDate]                         DATETIME        NULL,
    [U_ATTCH3]                        NVARCHAR (MAX)  NULL,
    [U_ATTCH4]                        NVARCHAR (MAX)  NULL,
    [U_ATTCH5]                        NVARCHAR (MAX)  NULL,
    [U_Manual_Reversal]               INT             NULL,
    [LineReference3]                  NVARCHAR (150)  NULL,
    [LineReference1]                  NVARCHAR (150)  NULL,
    [LineReference2]                  NVARCHAR (150)  NULL
);


GO
CREATE NONCLUSTERED INDEX [BVAMethod2_IDX]
    ON [dbo].[JournalEntries]([DepartmentCode] ASC)
    INCLUDE([CreatedBy], [CreateDate], [U_STAFF_EXP_NO], [Debit], [Credit], [U_JE_REMARKS], [U_PAYEE_NAME], [DocLine], [CountryCode], [ProjectCode], [TransactionID], [TransactionType], [BaseReference], [UserSignature], [ReverseTransaction], [RowNumber], [AccountCode], [SystemCreditAmount], [SystemDebitAmount], [RowDetails], [LocationCode], [ProjectName], [ReferenceDate]);


GO
CREATE NONCLUSTERED INDEX [WTax_IDX]
    ON [dbo].[JournalEntries]([CountryCode] ASC, [AccountCode] ASC)
    INCLUDE([CreatedBy], [Debit], [Credit], [TransactionID], [TransactionType], [BaseReference], [PostingDate], [Details], [SystemCreditAmount], [SystemDebitAmount], [DebitForeignCurrency], [CreditForeignCurrency], [ReconciliationDate], [DepartmentCode], [TransactionCurrency]);


GO
CREATE NONCLUSTERED INDEX [JE_postingDate]
    ON [dbo].[JournalEntries]([PostingDateID] ASC)
    INCLUDE([PostingDate]);


GO
CREATE NONCLUSTERED INDEX [BVA_CCode]
    ON [dbo].[JournalEntries]([CountryCode] ASC, [ReverseTransaction] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_JE_Refdate]
    ON [dbo].[JournalEntries]([ReferenceDate] ASC)
    INCLUDE([CreatedBy], [CreateDate], [U_STAFF_EXP_NO], [Debit], [Credit], [U_JE_REMARKS], [U_PAYEE_NAME], [DocLine], [CountryCode], [ProjectCode], [TransactionID], [TransactionType], [BaseReference], [UserSignature], [ReverseTransaction], [RowNumber], [AccountCode], [SystemCreditAmount], [SystemDebitAmount], [RowDetails], [DepartmentCode], [LocationCode], [ProjectName]);


GO
CREATE NONCLUSTERED INDEX [Idx_JE_DeptCode_RefDate]
    ON [dbo].[JournalEntries]([DepartmentCode] ASC, [ReferenceDate] ASC)
    INCLUDE([CreatedBy], [U_STAFF_EXP_NO], [DocLine], [CountryCode], [TransactionType], [BaseReference], [UserSignature], [AccountCode], [SystemCreditAmount], [SystemDebitAmount], [LocationCode]);

