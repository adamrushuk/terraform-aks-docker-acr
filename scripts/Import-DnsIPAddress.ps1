# Retrieve DNS IP Address from "nginxdemo_svc.KubectlOutput" and assign to pipeline variable

# Get new public IP from LoadBalancer
$service = $env:NGINXDEMO_SVC_KUBECTLOUTPUT | ConvertFrom-Json
$dnsIpAddress = $service.status.loadBalancer.ingress[0].ip

if (-not $dnsIpAddress) {
    Write-Host "##vso[task.logissue type=error]LoadBalancer IP does not exist."
    Write-Error -Message "ERROR: LoadBalancer IP is blank"
}

# Update pipeline variable
Write-Host "##vso[task.setvariable variable=dns_ip_address]$dnsIpAddress"
