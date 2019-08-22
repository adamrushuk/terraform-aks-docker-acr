# Retrieve storage key for Terraform storage account and assign to pipeline variable
[CmdletBinding()]
param (
    $StorageResourceGroupName,
    $StorageAccountName
)

# Get storage access key
$taskMessage = "Finding Key for Storage Account: [$StorageAccountName]"
Write-Verbose -Message "STARTED: $taskMessage..."
try {
    $getAzureRmStorageAccountKeyParams = @{
        ResourceGroupName = $StorageResourceGroupName
        AccountName       = $StorageAccountName
        ErrorAction       = "Stop"
        Verbose           = $true
    }
    $key = (Get-AzureRmStorageAccountKey @getAzureRmStorageAccountKeyParams).Value[0]

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
