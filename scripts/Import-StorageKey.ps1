# Retrieve storage key for Terraform storage account and assign to pipeline variable

# Get storage access key
$key = (Get-AzureRmStorageAccountKey -ResourceGroupName "$env:TERRAFORM_STORAGE_RG" -AccountName "$env:TERRAFORM_STORAGE_ACCOUNT").Value[0]

# Update pipeline variable
Write-Host "##vso[task.setvariable variable=storage_key]$key"
