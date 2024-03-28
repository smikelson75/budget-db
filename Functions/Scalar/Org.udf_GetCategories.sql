CREATE FUNCTION Org.udf_GetCategories
(
    @jsonDoc NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN
    (
        SELECT ISNULL(
            (
                SELECT T1.CategoryId AS [Id]
                    ,[Name] AS [name]
                    ,[LastMaintenanceUser] AS [modifiedby]
                    ,[LastMaintenanceTimestamp] AS [modifieddate]
                FROM Org.tblCategory T1
                Where T1.CategoryId IN (
                    SELECT T2.CategoryId
                    FROM OPENJSON(@jsonDoc, '$.categories')
                    WITH (
                        CategoryId INT '$.id'
                    ) AS T2
                )
                FOR JSON PATH
            ), '[]'
        ) AS [categories]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )
END
