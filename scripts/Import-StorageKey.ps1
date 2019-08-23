# Retrieve storage key for Terraform storage account and assign to pipeline variable
[CmdletBinding()]
param (
    $StorageResourceGroupName,
    $StorageAccountName
)

# Get storage access key
$taskMessage = "Finding Key for Storage Account: [$StorageAccountName]"
Write-Output "STARTED: $taskMessage..."
try {
    $getAzStorageAccountKeyParams = @{
        ResourceGroupName = $StorageResourceGroupName
        AccountName       = $StorageAccountName
        ErrorAction       = "Stop"
        Verbose           = $true
    }
    $key = (Get-AzStorageAccountKey @getAzStorageAccountKeyParams).Value[0]

    Write-Output "FINISHED: $taskMessage."
} catch {
    Write-Output "##vso[task.logissue type=error]ERROR: $taskMessage."
    throw
}

# Update pipeline variable
$message = "Updating Storage Account Key pipeline variable"
Write-Output "STARTED: $message"
Write-Output "##vso[task.setvariable variable=storage_key]$key"
Write-Output "FINISHED: $message"
