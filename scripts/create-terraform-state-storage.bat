:: This will create an Azure resource group, Storage account and Storage container, used to store terraform remote state
::
:: When using Windows agent in Azure DevOps, use batch scripting.
:: For batch files use the prefix "call" before every azure command.

:: Show env vars
set

:: Resource Group
call az group create --location %RESOURCE_LOCATION% --name %TERRAFORM_STORAGE_RG%

:: Storage Account
call az storage account create --name %TERRAFORM_STORAGE_ACCOUNT% --resource-group %TERRAFORM_STORAGE_RG% ^
--location %RESOURCE_LOCATION% --sku Standard_LRS

:: Storage Container
call az storage container create --name terraform --account-name %TERRAFORM_STORAGE_ACCOUNT%

:: Get latest supported AKS version and update Azure DevOps Pipeline variable
SET latest_aks_version=(call az aks get-versions -l %RESOURCE_LOCATION% --query 'orchestrators[-1].orchestratorVersion' -o tsv)
@echo ##vso[task.setvariable variable=latest_aks_version]%latest_aks_version%
