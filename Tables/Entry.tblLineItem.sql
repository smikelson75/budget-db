CREATE TABLE Entry.tblLineItem (
    LineItemId INT IDENTITY(1,1) NOT NULL,
    LastMaintenanceTimestamp SMALLDATETIME NOT NULL DEFAULT GETDATE(),
    LastMaintenanceUser nvarchar(30) NOT NULL,
    SystemStart DATETIME2(0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT DF_LineItem_SystemStart DEFAULT SYSUTCDATETIME(),
    SystemEnd DATETIME2(0) GENERATED ALWAYS AS ROW END HIDDEN CONSTRAINT DF_LineItem_SystemEnd DEFAULT '9999-12-31 23:59:59',
    [Name] NVARCHAR(50) NOT NULL,
    BudgetAssignmentId INT NOT NULL,
    AssignmentType CHAR(1) NOT NULL,
    AccountId INT NOT NULL,
    CategoryId INT NOT NULL,
    PostedDate DATE NOT NULL,
    RectifiedDate DATE NULL,    
    ItemAmount DECIMAL(10, 2) NOT NULL,   
    CONSTRAINT PK_LineItem PRIMARY KEY (LineItemId),
    CONSTRAINT FK_LineItem_Account FOREIGN KEY (AccountId) REFERENCES Org.tblAccount(AccountId), 
    CONSTRAINT FK_LineItem_Category FOREIGN KEY (CategoryId) REFERENCES Org.tblCategory(CategoryId),
    CONSTRAINT CK_LineItem_AssignmentType CHECK (AssignmentType IN ('I', 'E')),
    PERIOD FOR SYSTEM_TIME (SystemStart, SystemEnd)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = Entry.tblLineItem_h), DATA_COMPRESSION = PAGE);
GO

CREATE INDEX IX_LineItem_BudgetAssignmentId ON Entry.tblLineItem (BudgetAssignmentId) WITH (DATA_COMPRESSION = PAGE);
GO

CREATE INDEX IX_LineItem_AccountId ON Entry.tblLineItem (AccountId) WITH (DATA_COMPRESSION = PAGE);
GO

CREATE INDEX IX_LineItem_CategoryId ON Entry.tblLineItem (CategoryId) WITH (DATA_COMPRESSION = PAGE);
GO