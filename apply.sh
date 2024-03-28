#! /bin/bash

# Exit on error
set -e

# Define variables
SERVER="localhost"
DATABASE="Budgets"
USERNAME="$1"
PASSWORD="$2"
DACPAC="./bin/Debug/Budget.dacpac"

# Build the project
dotnet build

# Use sqlpackage to load the .dacpac file
sqlpackage /Action:Publish /SourceFile:"${DACPAC}" /TargetConnectionString:"Server=tcp:${SERVER},1433;Initial Catalog=${DATABASE};User ID=${USERNAME};Password=${PASSWORD};TrustServerCertificate=True;Connection Timeout=30;"