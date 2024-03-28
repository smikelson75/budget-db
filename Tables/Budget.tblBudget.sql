CREATE TABLE Budget.tblBudget (
    BudgetId INT IDENTITY(1,1) NOT NULL,
    LastMaintenanceTimestamp SMALLDATETIME NOT NULL DEFAULT GETDATE(),
    LastMaintenanceUser NVARCHAR(30) NOT NULL,
    SystemStart DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT DF_Budget_SystemStart DEFAULT SYSUTCDATETIME(),
    SystemEnd DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN CONSTRAINT DF_Budget_SystemEnd DEFAULT '9999-12-31 23:59:59',
    [Name] NVARCHAR(50) NOT NULL,
    ScheduleType CHAR(1) NOT NULL,
    Amount DECIMAL(10, 2) CONSTRAINT DF_Budget_Amount DEFAULT 0.00,
    CONSTRAINT PK_Budget PRIMARY KEY (BudgetId),
    CONSTRAINT CK_Budget_ScheduleType CHECK (ScheduleType IN ('M', 'W', 'B')),
    PERIOD FOR SYSTEM_TIME (SystemStart, SystemEnd)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = Budget.tblBudget_h), DATA_COMPRESSION = PAGE);

/*
ScheduleType:
M - Monthly
W - Weekly
B - Bi-Weekly
*/