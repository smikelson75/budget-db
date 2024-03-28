CREATE FUNCTION Org.udf_ListCategories()
RETURNS NVARCHAR(MAX)
AS
BEGIN
    RETURN
    (
        SELECT ISNULL(
            (
                SELECT CategoryId AS [Id]
                    ,[Name] AS [name]
                    ,[LastMaintenanceUser] AS [modifiedby]
                    ,[LastMaintenanceTimestamp] AS [modifieddate]
                FROM Org.tblCategory
                FOR JSON PATH
            ), '[]'
        ) AS [categories]
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )
END