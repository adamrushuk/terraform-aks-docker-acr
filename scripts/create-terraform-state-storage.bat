:: This will create an Azure resource group, Storage account and Storage container, used to store terraform remote state
::
:: When using Windows agent in Azure DevOps, use batch scripting.
:: For batch files use the prefix "call" before every azure command.

:: Show env vars
set

:: Resource Group
call az group create --location eastus --name %TERRAFORM_STORAGE_RG%

:: Storage Account
call az storage account create --name %TERRAFORM_STORAGE_ACCOUNT% --resource-group %TERRAFORM_STORAGE_RG% ^
--location eastus --sku Standard_LRS

:: Storage Container
call az storage container create --name terraform --account-name %TERRAFORM_STORAGE_ACCOUNT%
