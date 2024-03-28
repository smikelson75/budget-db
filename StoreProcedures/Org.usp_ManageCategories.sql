CREATE PROCEDURE Org.usp_ManageCategories
  @jsonDoc NVARCHAR(MAX),
  @outputJson NVARCHAR(MAX) OUTPUT
AS
  SET NOCOUNT ON
  BEGIN usp_ManageCategories:
    DECLARE @user NVARCHAR(250) =
    (
      SELECT User
      FROM OPENJSON(@jsonDoc) WITH ([User] NVARCHAR(250) '$.user')
    )

    DECLARE @patch BIT = (
      SELECT Patch
      FROM OPENJSON(@jsonDoc) WITH ([Patch] BIT '$.patch')
    )

    DECLARE @output TABLE (
      Id INT,
      Name NVARCHAR(50)
    )

    BEGIN usp_Cursor:
      BEGIN usp_Body:
        MERGE INTO Org.tblCategory as target
          USING 
          (
            SELECT COALESCE(Id, -1) AS Id, Category, RemoveFlag
            FROM OPENJSON(@jsonDoc, '$.categories')
            WITH 
            (
              Id INT '$.id',
              Category NVARCHAR(50) '$.name',
              RemoveFlag BIT '$.remove'
            )
          ) AS source
          ON target.CategoryId = source.Id
          WHEN NOT MATCHED THEN
            INSERT ([Name], [LastMaintenanceUser])
            VALUES (source.Category, @user)
          WHEN MATCHED AND source.RemoveFlag = 1 THEN
            DELETE
          WHEN MATCHED THEN
            UPDATE
            SET target.[Name] = 
                CASE 
                  WHEN @patch = 1 THEN coalesce(source.Category, target.[Name]) 
                  ELSE source.Category 
                END,
                target.LastMaintenanceTimestamp = GETDATE(),
                target.LastMaintenanceUser = @user
        OUTPUT inserted.CategoryId, inserted.[Name] INTO @output;

        SET @outputJson = (
          SELECT ISNULL(
            (SELECT O1.Id AS [id], O1.[Name] AS [name] 
              FROM @output O1
                    INNER JOIN Org.tblCategory O2
                ON O1.Id = O2.CategoryId
                FOR JSON PATH), '[]') AS [categories]
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER              
          )
      END
    END
  END
RETURN 0

/*
  Example Execution:

    EXEC Org.usp_ManageCategories
    @jsonDoc = N'{
      "user": "user",
      "patch": true,
      "categories": [
        {
          "id": -1,
          "name": "Cloud Services",
          "remove": true
        }, {...}
      ]
    }'

  Expected Output:
    {
      "categories": [
        {
          "id": 2,
          "name": "Cloud Services"
        }
      ]
    }
*/