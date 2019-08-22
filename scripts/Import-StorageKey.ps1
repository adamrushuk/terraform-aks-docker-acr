# Retrieve storage key for Terraform storage account and assign to pipeline variable

# Get storage access key
$taskMessage = "Finding Key for Storage Account: [$env:TERRAFORM_STORAGE_ACCOUNT]"
Write-Verbose -Message "STARTED: $taskMessage..."
try {
    $getAzureRmStorageAccountKeyParams = @{
        ResourceGroupName = $env:TERRAFORM_STORAGE_RG
        AccountName       = $env:TERRAFORM_STORAGE_ACCOUNT
        ErrorAction       = "Stop"
    }
    $key =(Get-AzureRmStorageAccountKey @getAzureRmStorageAccountKeyParams).Value[0]

    Write-Verbose -Message "FINISHED: $taskMessage."
} catch {
    Write-Host "##vso[task.logissue type=error]ERROR: $taskMessage."
    throw
}

# Update pipeline variable
$message = "Updating Storage Account Key pipeline variable"
Write-Host "STARTED: $message"
Write-Host "##vso[task.setvariable variable=storage_key]$key"
Write-Host "FINISHED: $message"
