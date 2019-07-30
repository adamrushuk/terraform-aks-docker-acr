:: This will create an Azure resource group, Storage account and Storage container, used to store terraform remote state
::
:: When using Windows agent in Azure DevOps, use batch scripting.
:: For batch files use the prefix "call" before every azure command.

call az group create --location eastus --name $(terraformstoragerg)

call az storage account create --name $(terraformstorageaccount) --resource-group $(terraformstoragerg) ^
--location eastus --sku Standard_LRS

call az storage container create --name terraform --account-name $(terraformstorageaccount)
