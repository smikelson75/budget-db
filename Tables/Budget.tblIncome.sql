CREATE TABLE Budget.tblIncome (
    IncomeId INT NOT NULL CONSTRAINT DF_Income_IncomeId DEFAULT NEXT VALUE FOR Budget.seqAssignment,
    LastMaintenanceTimestamp SMALLDATETIME NOT NULL DEFAULT GETDATE(),
    LastMaintenanceUser NVARCHAR(30) NOT NULL,
    SystemStart DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT DF_Income_SystemStart DEFAULT SYSUTCDATETIME(),
    SystemEnd DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN CONSTRAINT DF_Income_SystemEnd DEFAULT '9999-12-31 23:59:59',
    [Name] NVARCHAR(50) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    BudgetInstanceId INT NOT NULL,
    CONSTRAINT PK_Income PRIMARY KEY (IncomeId),
    CONSTRAINT FK_Income_BudgetInstance FOREIGN KEY (BudgetInstanceId) REFERENCES Budget.tblBudgetInstance(BudgetInstanceId),
    CONSTRAINT UQ_Income_Name_BudgetInstanceId UNIQUE ([Name], BudgetInstanceId),
    PERIOD FOR SYSTEM_TIME (SystemStart, SystemEnd) 
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = Budget.tblIncome_h), DATA_COMPRESSION = PAGE);
GO

CREATE INDEX IX_Income_BudgetInstanceId ON Budget.tblIncome (BudgetInstanceId) WITH (DATA_COMPRESSION = PAGE);
GO