:: This will create an Azure resource group, Storage account and Storage container, used to store terraform remote state
::
:: When using Windows agent in Azure DevOps, use batch scripting.
:: For batch files use the prefix "call" before every azure command.

:: Show env vars
set

:: Resource Group
@echo "STARTED: Creating Resource Group..."
call az group create --location %RESOURCE_LOCATION% --name %TERRAFORM_STORAGE_RG%
@echo "##vso[task.setprogress value=25;]FINISHED: Creating Resource Group."

:: Storage Account
@echo "STARTED: Creating Storage Account..."
call az storage account create --name %TERRAFORM_STORAGE_ACCOUNT% --resource-group %TERRAFORM_STORAGE_RG% ^
--location %RESOURCE_LOCATION% --sku Standard_LRS
@echo "##vso[task.setprogress value=50;]FINISHED: Creating Storage Account."

:: Storage Container
@echo "STARTED: Creating Storage Container..."
call az storage container create --name terraform --account-name %TERRAFORM_STORAGE_ACCOUNT%
@echo "##vso[task.setprogress value=75;]FINISHED: Creating Storage Container."

:: Get latest supported AKS version and update Azure DevOps Pipeline variable
@echo "STARTED: Finding latest supported AKS version..."
for /f %%i in ('call az aks get-versions -l %RESOURCE_LOCATION% --query "orchestrators[-1].orchestratorVersion" -o tsv') do @set latest_aks_version=%%i
@echo Updating Pipeline variable with Latest AKS Version:
@echo %latest_aks_version%
@echo ##vso[task.setvariable variable=latest_aks_version]%latest_aks_version%
@echo "##vso[task.setprogress value=100;]FINISHED: Finding latest supported AKS version."
