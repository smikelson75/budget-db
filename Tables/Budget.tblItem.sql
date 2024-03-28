CREATE TABLE Budget.tblItem (
    ItemId INT IDENTITY(1,1) NOT NULL,
    LastMaintenanceTimestamp SMALLDATETIME NOT NULL DEFAULT GETDATE(),
    LastMaintenanceUser NVARCHAR(30) NOT NULL,
    SystemStart DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT DF_Item_SystemStart DEFAULT SYSUTCDATETIME(),
    SystemEnd DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN CONSTRAINT DF_Item_SystemEnd DEFAULT '9999-12-31 23:59:59',
    [Name] NVARCHAR(50) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    RepeatType CHAR(2) NOT NULL,
    StartsOnDate DATE NOT NULL,
    EndsOnDate DATE,
    BudgetId INT NOT NULL,
    CONSTRAINT PK_Item PRIMARY KEY (ItemId),
    CONSTRAINT FK_Item_Budget FOREIGN KEY (BudgetId) REFERENCES Budget.tblBudget(BudgetId),
    CONSTRAINT CK_Expense_RepeatType CHECK (RepeatType IN ('DL', 'WK', 'MT', 'YR', 'QT', 'LD', 'FM', 'PP')),
    PERIOD FOR SYSTEM_TIME (SystemStart, SystemEnd)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = Budget.tblItem_h), DATA_COMPRESSION = PAGE);
GO

CREATE INDEX IX_Item_BudgetId ON Budget.tblItem (BudgetId) WITH (DATA_COMPRESSION = PAGE);
GO

/*
RepeatType:
DL - Daily
WK - Weekly
MT - Monthly
YR - Yearly
QT - Quarterly
LD - Last Day of Month
FM - First Monday of Month
PP - Pay Period
*/