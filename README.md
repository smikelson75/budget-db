# Database: Budget-DB

This project is a SQL Database Project for a simple budgeting application. Project is written using Microsoft.Build.Sql's SDK-style database project for SQL Server.

See the [Microsoft documentation for Use SDK-style projects](https://learn.microsoft.com/en-us/azure-data-studio/extensions/sql-database-project-extension-sdk-style-projects) for more information.

## What you will need:

- [.NET SDK Version 6+](https://dotnet.microsoft.com/download)
- [Microsoft.Build.Sql](https://www.nuget.org/packages/Microsoft.Build.Sql)
- [sqlpackage](https://www.nuget.org/packages/Microsoft.SqlPackage/162.3.515-preview)

## Building and Deploying the Project

Currently, the build/deploy process is written in a bash script. It currently expects the database to be available on `localhost,1433`. To make it simple, the account must use SQL Authentication and must have the `db_owner` role.

To build the project, run the following command:

```bash
./apply.sh <username> <password>
```
