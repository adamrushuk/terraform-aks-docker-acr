# Retrieve storage key for Terraform storage account

# Get storage access key
$key = (Get-AzureRmStorageAccountKey -ResourceGroupName "$(terraform_storage_rg)" -AccountName "$(terraform_storage_account)").Value[0]

# Update Azure DevOps Pipeline variable
Write-Host "##vso[task.setvariable variable=storage_key]$key"
