# Misc notes for installing / troubleshooting Jenkins with Helm
# Vars
$aksRgName = "aks-asr1234-rg"
$aksClusterName = "MyAksClusterName01"


#region Init
<# [RunOnce] Setup Azure Service Principal
az ad sp create-for-rbac --name "terraform-aks-docker-acr"
#>


# Run pipeline, then once AKS deployed, continue below


# Merge AKS cluster details into ~\.kube\config
az aks get-credentials --resource-group $aksRgName --overwrite-existing --name $aksClusterName

# View AKS Dashboard
Start-Job -ScriptBlock { az aks browse --resource-group $using:aksRgName --name $using:aksClusterName }
# Also keep dashboard alive in another tab
Start-Job -ScriptBlock { while(1) {Invoke-RestMethod -Uri 127.0.0.1:8001 ; Start-Sleep -Seconds 60} }

# Check context (should show AKS cluster name, eg: MyAksClusterName01)
kubectl config current-context

# [OPTIONAL] List and change context if required
kubectl config view
kubectl config get-contexts
kubectl config use-context $aksClusterName

# [OPTIONAL] Permanently save the namespace for all subsequent kubectl commands in current context
kubectl config set-context --current --namespace=default

# Show resources
kubectl get all

# Get External IP for NGINX demo
kubectl get svc nginxdemo
kubectl get svc nginxdemo -o json
kubectl get svc nginxdemo -o jsonpath="{.status.loadBalancer.ingress[0].ip}"

# [OPTIONAL] Delete NGINX demo resources
kubectl delete deploy,svc nginxdemo
kubectl get pod --watch
#endregion Init


#region Install Helm
# Install Helm Client
choco install -y kubernetes-helm

# Check Helm version (initially only shows client version until Tiller installed on cluster)
helm version --short

# Install Tiller (the Helm server-side component)
helm init

# Monitor tiller installation
kubectl get deployment --namespace=kube-system -l name=tiller --watch

# Check Helm version (both Client and Server versions should now show)
helm version --short

# Show all Tiller k8s resources in cluster
kubectl get all --namespace=kube-system -l name=tiller
#endregion Install Helm


#region Jenkins
# List current Helm releases
helm list

# Install Jenkins
helm install --name jenkins stable/jenkins `
    --set master.servicePort=80 `
    --set master.slaveListenerServiceType=LoadBalancer `
    --set master.slaveListenerPort=80 `
    --set master.disabledAgentProtocols=null

# Monitor
helm ls --all jenkins

# Show all resources for Jenkins (filter by label)
kubectl get all -l "app.kubernetes.io/name=jenkins"

# Monitor pod and service building
kubectl get pod -l "app.kubernetes.io/name=jenkins" --watch
kubectl get svc jenkins --watch
kubectl get svc --watch
# Check pod events
kubectl describe pod -l "app.kubernetes.io/name=jenkins"


# Find connection details for Jenkins
# First view complete Service config in JSON format
kubectl get svc --namespace default jenkins
# Get Jenkins Loadbalancer URL using jsonpath, eg: {.status.loadBalancer.ingress[0].ip} and {.spec.ports[0].port}
kubectl get svc --namespace default jenkins -o jsonpath="http://{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"

# Get admin password (you need bash installed to decode using base64 cmd)
$jenkinsAdminPassword = kubectl get secret --namespace default jenkins -o jsonpath="{.data.jenkins-admin-password}"
bash -c "echo $jenkinsAdminPassword | base64 --decode" | clip
# Output example: X6XZ2JqIux

# TODO: Test using .NET methods
[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($jenkinsAdminPassword)) | clip
# Output example (not same as linux base64): V0RaWVdqSktjVWwxZUE9PQ==

# Configure local Agent for Windows
Remove-Item -Path "C:\Agents\Jenkins\remoting" -Recurse -Force
java -jar "C:\Users\$($env:USERNAME)\Downloads\agent.jar" `
    -jnlpUrl "http://jenkins:80/computer/windows/slave-agent.jnlp" `
    -secret 30a46115af78c2d0b588370d4274e0d84a1ae338b9d5cab9bac3161ee630dcc9 -workDir "C:\Agents\Jenkins"
#endregion Jenkins


#region Troubleshooting
kubectl describe svc jenkins-agent
kubectl get svc jenkins-agent -o yaml
kubectl get svc jenkins-agent --watch
#endregion Troubleshooting


#region Cleanup
# Delete helm release
helm delete --purge jenkins

# Delete EVERY resource group that does NOT include tag: keep=true
$jobs = Get-AzResourceGroup | Where-Object {$_.Tags -eq $null -or $_.Tags.GetEnumerator().Name -notcontains "keep"} | Remove-AzResourceGroup -Force -AsJob
$jobs | Wait-Job
$jobs | Receive-Job -Keep
#endregion Cleanup
