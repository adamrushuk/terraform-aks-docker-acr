<#
.SYNOPSIS
    Updates a DNS A record with a new IP address
.DESCRIPTION
    Updates a DNS A record with a new IP address using the GoDaddy PowerShell module
.LINK
    https://www.powershellgallery.com/packages/Trackyon.GoDaddy
.NOTES
    Author:  Adam Rush
    Blog:    https://adamrushuk.github.io
    GitHub:  https://github.com/adamrushuk
    Twitter: @adamrushuk
#>

[CmdletBinding()]
param (
    $DomainName,
    $IPAddress,
    $ApiKey,
    $ApiSecret,
    $Ttl = 600
)

# Init
Install-Module -Name "Trackyon.GoDaddy"-Scope "CurrentUser" -Force -Verbose
$apiCredential = [pscredential]::new($ApiKey, (ConvertTo-SecureString -String $ApiSecret -AsPlainText -Force))

# Output Domain
Get-GDDomain -credentials $apiCredential -domain $DomainName | Out-String | Write-Verbose

# Output current records
Get-GDDomainRecord -credentials $apiCredential -domain $DomainName | Out-String | Write-Verbose

# Update A record
Set-GDDomainRecord -credentials $apiCredential -domain $DomainName -name '@' -ipaddress $IPAddress -type "A" -ttl $Ttl -Force
