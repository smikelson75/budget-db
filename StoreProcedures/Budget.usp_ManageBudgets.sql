CREATE PROCEDURE Budget.usp_ManageBudgets
  @jsonDoc NVARCHAR(MAX),
  @outputJson NVARCHAR(MAX) OUTPUT
AS
  SET NOCOUNT ON
  BEGIN usp_ManageBudgets:
    DECLARE @user NVARCHAR(250) =
    (
      SELECT User
      FROM OPENJSON(@jsonDoc) WITH ([User] NVARCHAR(250) '$.user')
    )

    DECLARE @input TABLE (
        BudgetName  NVARCHAR(50)    NOT NULL,
        ScheduleType CHAR(1),
        Amount DECIMAL(10, 2) DEFAULT 0.00,
        UpdatedName  NVARCHAR(50),
        UpdatedAmount DECIMAL(10, 2),
        RemoveFlag   BIT    DEFAULT 0
    )

    DECLARE @output TABLE (
      Id INT,
      [Name] NVARCHAR(50),
      ScheduleType CHAR(1),
      Amount DECIMAL(10, 2)
    )
  
    BEGIN usp_Cursor:
      INSERT INTO @input
      (
          BudgetName,
          ScheduleType,
          Amount,
          UpdatedName,
          UpdatedAmount,
          RemoveFlag
      )
      SELECT BudgetName, ScheduleType, Amount, UpdatedName, UpdatedAmount, RemoveFlag
      FROM OPENJSON(@jsonDoc, '$.budgets')
      WITH
      (
          BudgetName  NVARCHAR(50) '$.name',
          ScheduleType CHAR(1)    '$.type',
          Amount DECIMAL(10, 2) '$.amount',
          UpdatedName NVARCHAR(50) '$.change.name',
          UpdatedAmount DECIMAL(10, 2) '$.change.amount',
          RemoveFlag BIT '$.remove'
      )

      BEGIN usp_Body:
        MERGE INTO Budget.tblBudget as target 
        USING @input AS source
        ON target.[Name] = source.BudgetName
        WHEN NOT MATCHED THEN
            INSERT
            (
                [Name],
                [ScheduleType],
                [Amount],
                [LastMaintenanceUser]
            )
            VALUES
            (
                source.BudgetName,
                source.ScheduleType,
                source.Amount,
                @user
            )
        WHEN MATCHED AND source.RemoveFlag = 1 THEN
            DELETE
        WHEN MATCHED THEN
            UPDATE SET
                target.[Name] = coalesce(source.UpdatedName, target.[Name]),
                target.Amount = coalesce(source.UpdatedAmount, target.Amount),
                target.LastMaintenanceTimestamp = GETDATE(),
                target.LastMaintenanceUser = @user
        OUTPUT inserted.BudgetId, inserted.[Name], inserted.ScheduleType, inserted.Amount INTO @output;
        ;

        SET @outputJson = (
            SELECT ISNULL(
            (SELECT O1.Id AS [id], O1.[Name] AS [name], O1.ScheduleType AS [type], O1.Amount AS [amount]
              FROM @output O1
                    INNER JOIN Budget.tblBudget O2
                ON O1.Id = O2.BudgetId
                FOR JSON PATH), '[]') AS [budgets]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
          )

      END
    END
  END

  /*
  Budget Schedule Types:
  M - Monthly
  W - Weekly
  B - Bi-Weekly
  */

  /*
    Example Execution:
    EXEC Budget.usp_ManageBudgets
    @jsonDoc = N'
    {
      "user": "user1",
      "budgets": [
        {
          "name": "Budget1",
          "type": "M",
          "amount": 100.00,
          "remove": false,
          "change": {
            "name": "Budget2",
            "amount": 200.00
          }
        },
        {...}
      ]
    }'

    Example Output:
    {
      "budgets": [
        {
          "id": 1,
          "name": "Budget2",
          "type": "M",
          "amount": 200.00
        },
        {...}
      ]
    }
  */