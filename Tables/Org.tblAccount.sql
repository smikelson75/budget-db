CREATE TABLE Org.tblAccount (
    AccountId INT IDENTITY(1,1) NOT NULL,
    LastMaintenanceTimestamp SMALLDATETIME NOT NULL DEFAULT GETDATE(),
    LastMaintenanceUser NVARCHAR(30) NOT NULL,
    SystemStart DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT DF_Account_SystemStart DEFAULT SYSUTCDATETIME(),
    SystemEnd DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN CONSTRAINT DF_Account_SystemEnd DEFAULT '9999-12-31 23:59:59',
    [Name] NVARCHAR(50) NOT NULL,
    AccountType CHAR(1) NOT NULL,
    CONSTRAINT PK_Account PRIMARY KEY (AccountId),
    CONSTRAINT UQ_Account_Name UNIQUE ([Name]),
    CONSTRAINT CK_AccountType CHECK (AccountType IN ('C', 'S', 'R', 'L', 'O')),
    PERIOD FOR SYSTEM_TIME (SystemStart, SystemEnd)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = Org.tblAccount_h), DATA_COMPRESSION = PAGE);

/*
Account Types:
C - Checking
S - Savings
R - Credit Cardsss
L - Loan
O - Other
*/