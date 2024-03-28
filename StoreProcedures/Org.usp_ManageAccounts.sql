CREATE PROCEDURE Org.usp_ManageAccounts
  @jsonDoc NVARCHAR(MAX),
  @outputJson NVARCHAR(MAX) OUTPUT
AS
  SET NOCOUNT ON
  BEGIN usp_ManageAccounts:
    DECLARE @user NVARCHAR(250) =
    (
      SELECT User
      FROM OPENJSON(@jsonDoc) WITH ([User] NVARCHAR(250) '$.user')
    )

    DECLARE @input TABLE 
    (
        Account     NVARCHAR(50)    NOT NULL,
        AccountType CHAR(1),
        UpdatedAccount NVARCHAR(50),
        UpdatedType    CHAR(1),
        RemoveFlag BIT DEFAULT 0
    )

    DECLARE @output TABLE (
      Id INT,
      [Name] NVARCHAR(50),
      AccountType CHAR(1)
    )

    BEGIN usp_Cursor:
      INSERT INTO @input
      (
          Account,
          AccountType,
          UpdatedAccount,
          UpdatedType,
          RemoveFlag
      )
      SELECT Account, AccountType, UpdatedAccount, UpdatedType, RemoveFlag
      FROM OPENJSON(@jsonDoc, '$.accounts')
      WITH (
          Account  NVARCHAR(50)   '$.name',
          AccountType CHAR(1)     '$.type',
          RemoveFlag  BIT '$.remove',
          UpdatedAccount  NVARCHAR(50)    '$.change.name',
          UpdatedType     CHAR(1)         '$.change.type'
      ) AS A1


      BEGIN usp_Body:
        MERGE INTO Org.tblAccount as target
        USING @input as source
        ON target.[Name] = source.Account
        WHEN NOT MATCHED THEN
            INSERT
            (
                [Name],
                [AccountType],
                [LastMaintenanceUser]
            )
            VALUES 
            (
                source.Account,
                source.AccountType,
                @user
            )
        WHEN MATCHED AND source.RemoveFlag = 1 THEN
            DELETE
        WHEN MATCHED THEN
            UPDATE SET
            target.[Name] = coalesce(source.UpdatedAccount, target.[Name]),
            target.AccountType = coalesce(source.UpdatedType, target.AccountType),
            target.LastMaintenanceUser = @user
        OUTPUT inserted.AccountId, inserted.[Name], inserted.AccountType INTO @output;
        ;

        SET @outputJson = (
          SELECT ISNULL(
            (SELECT Id AS [id]
                  ,O1.[Name] AS [name]
                  ,O1.AccountType AS [type] 
              FROM @output O1
                   INNER JOIN Org.tblAccount O2
              ON O1.Id = O2.AccountId
              FOR JSON PATH)
            , '[]') AS [accounts]
          FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
      END
    END
  END
RETURN 0

/*
  Example Execution:
    EXEC org.usp_ManageAccounts
    @jsonDoc = N'{
      "user": "developer@staffwisellc.com",
      "accounts": [
          {
              "name": "Southern Bank - Main",
              "type": "C"
              "remove": true,
              "change": {
                  "name": "Southern Bank",
                  "type": "S"
              }
          },
          {...}
      ]
    }'

  Example Output:
  {
    "accounts": [
        {
            "id": 1,
            "name": "Southern Bank",
            "type": "S"
        },
        {...}
    ]
  }
*/