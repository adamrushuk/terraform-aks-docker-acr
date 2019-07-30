# Retrieve storage key for Terraform storage account
$key = (Get-AzureRmStorageAccountKey -ResourceGroupName $(terraformstoragerg) -AccountName $(terraformstorageaccount)).Value[0]

# Update Azure DevOps Pipeline variable
Write-Host "##vso[task.setvariable variable=storagekey]$key"
