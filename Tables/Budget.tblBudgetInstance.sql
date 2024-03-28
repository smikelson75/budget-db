CREATE TABLE Budget.tblBudgetInstance (
    BudgetInstanceId INT IDENTITY(1,1) NOT NULL,
    LastMaintenanceTimestamp SMALLDATETIME NOT NULL DEFAULT GETDATE(),
    LastMaintenanceUser NVARCHAR(30) NOT NULL,
    SystemStart DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT DF_BudgetInstance_SystemStart DEFAULT SYSUTCDATETIME(),
    SystemEnd DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN CONSTRAINT DF_BudgetInstance_SystemEnd DEFAULT '9999-12-31 23:59:59',
    [Name] NVARCHAR(50) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    BudgetId INT NOT NULL,
    CONSTRAINT PK_BudgetInstance PRIMARY KEY (BudgetInstanceId),
    CONSTRAINT UQ_BudgetInstance_StartDate_EndDate UNIQUE (StartDate, EndDate),
    CONSTRAINT FK_BudgetInstance_Budget FOREIGN KEY (BudgetId) REFERENCES Budget.tblBudget(BudgetId),
    PERIOD FOR SYSTEM_TIME (SystemStart, SystemEnd)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = Budget.tblBudgetInstance_h), DATA_COMPRESSION = PAGE);
GO

CREATE INDEX IX_BudgetInstance_BudgetId ON Budget.tblBudgetInstance (BudgetId) WITH (DATA_COMPRESSION = PAGE);
GO