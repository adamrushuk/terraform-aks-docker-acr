# Wait for AKS Loadbalancer IP to exist, then updates Pipeline variable
# Merge AKS cluster details into ~\.kube\config
az aks get-credentials --resource-group aks-rg --overwrite-existing --name $aksClusterName

# Show resources
kubectl get all

# Wait for Loadbalancer IP to exist
# TODO add a timeout here to avoid endless loop
while (-not ($dnsIpAddress = kubectl get svc nginxdemo --ignore-not-found -o jsonpath="{.status.loadBalancer.ingress[0].ip}")) {
    Write-Host "##vso[task.logissue type=warning]LoadBalancer IP still PENDING. Waiting 10s..."
    Start-Sleep -Seconds 10
}

# Update pipeline variable
Write-Host "##vso[task.setvariable variable=dns_ip_address]$dnsIpAddress"
