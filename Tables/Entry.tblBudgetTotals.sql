CREATE TABLE Entry.tblBudgetTotals
(
    BudgetInstanceId INT NOT NULL,
    LastMaintenanceTimestamp SMALLDATETIME NOT NULL DEFAULT GETDATE(),
    LastMaintenanceUser nvarchar(30) NOT NULL,
    SystemStart DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT DF_BudgetTotals_SystemStart DEFAULT SYSUTCDATETIME(),
    SystemEnd DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN CONSTRAINT DF_BudgetTotals_SystemEnd DEFAULT '9999-12-31 23:59:59',
    CurrentBalance DECIMAL(10, 2) NOT NULL,
    RemainingBalance DECIMAL(10, 2) NOT NULL,
    CONSTRAINT PK_BudgetTotals PRIMARY KEY (BudgetInstanceId),
    CONSTRAINT FK_BudgetTotals_BudgetInstance FOREIGN KEY (BudgetInstanceId) REFERENCES Budget.tblBudgetInstance(BudgetInstanceId),
    PERIOD FOR SYSTEM_TIME (SystemStart, SystemEnd)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = Entry.tblItemTotals_h), DATA_COMPRESSION = PAGE);