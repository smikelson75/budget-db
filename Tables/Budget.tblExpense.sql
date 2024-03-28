CREATE TABLE Budget.tblExpense (
    ExpenseId INT NOT NULL CONSTRAINT DF_Expense_ExpenseId DEFAULT NEXT VALUE FOR Budget.seqAssignment,
    LastMaintenanceTimestamp SMALLDATETIME NOT NULL DEFAULT GETDATE(),
    LastMaintenanceUser NVARCHAR(30) NOT NULL,
    SystemStart DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT DF_Expense_SystemStart DEFAULT SYSUTCDATETIME(),
    SystemEnd DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN CONSTRAINT DF_Expense_SystemEnd DEFAULT '9999-12-31 23:59:59',
    [Name] NVARCHAR(50) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    EstimatedDueDate DATE NOT NULL,
    BudgetInstanceId INT NOT NULL,
    CONSTRAINT PK_Expense PRIMARY KEY (ExpenseId),
    CONSTRAINT FK_Expense_BudgetInstance FOREIGN KEY (BudgetInstanceId) REFERENCES Budget.tblBudgetInstance(BudgetInstanceId),
    PERIOD FOR SYSTEM_TIME (SystemStart, SystemEnd) 
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = Budget.tblExpense_h), DATA_COMPRESSION = PAGE);
GO

CREATE INDEX IX_Expense_BudgetInstanceId ON Budget.tblExpense (BudgetInstanceId) WITH (DATA_COMPRESSION = PAGE);
GO