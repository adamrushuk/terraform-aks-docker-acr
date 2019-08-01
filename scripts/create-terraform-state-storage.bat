:: This will create an Azure resource group, Storage account and Storage container, used to store terraform remote state
::
:: When using Windows agent in Azure DevOps, use batch scripting.
:: For batch files use the prefix "call" before every azure command.

:: Resource Group
call az group create --location eastus --name "$(terraform_storage_rg)"

:: Storage Account
call az storage account create --name "$(terraform_storage_account)" --resource-group "$(terraform_storage_rg)" ^
--location eastus --sku Standard_LRS

:: Storage Container
call az storage container create --name terraform --account-name "$(terraform_storage_account)"
