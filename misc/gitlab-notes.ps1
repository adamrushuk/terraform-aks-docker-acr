# Misc notes for installing / troubleshooting GitLab with Helm

# Reference
# https://docs.gitlab.com/charts/
# https://docs.gitlab.com/charts/installation/deployment.html
# Useful for manual config updates: https://medium.com/@zimareff/deploy-gitlab-ce-on-a-new-azure-kubernetes-cluster-9251100df5d7

# Vars
$aksClusterName = "MyAksClusterName01"


#region Init
<# [RunOnce] Setup Azure Service Principal
az ad sp create-for-rbac --name "terraform-aks-docker-acr"
#>


# Run pipeline, then once AKS deployed, continue below


# Merge AKS cluster details into ~\.kube\config
az aks get-credentials --resource-group aks-rg --overwrite-existing --name $aksClusterName

# View AKS Dashboard
Start-Job -ScriptBlock { az aks browse --resource-group aks-rg --name $using:aksClusterName }
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


#region GitLab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm search -l gitlab/gitlab

<# Manually added IP, eg:
Name: public_ip
DNS name label: gitlab-asr-01.eastus.cloudapp.azure.com
IP: 13.82.111.67
#>

# Install with https enabled
helm upgrade --namespace gitlab --install gitlab gitlab/gitlab `
    --timeout 600 `
    --set global.hosts.domain=gitlab-asr-01.eastus.cloudapp.azure.com `
    --set global.hosts.externalIP=13.82.111.67 `
    --set certmanager-issuer.email=me@test.com

# Install without https enabled
# Testing nip.io DNS: https://gitlab.com/charts/gitlab/blob/master/examples/values-minikube-minimum.yaml#L14
# Replace "192.168.99.100" with assigned Azure Public IP
helm upgrade --namespace gitlab --install gitlab gitlab/gitlab `
    --timeout 600 `
    --set global.hosts.domain=13-82-111-67-nip.io `
    --set global.hosts.externalIP=13.82.111.67 `
    --set global.hosts.https=false `
    --set global.ingress.enabled=false `
    --set global.ingress.tls.enabled=false `
    --set global.ingress.configureCertmanager=false

# Monitor
helm list
helm status gitlab
helm ls --all gitlab
kubectl logs -f -l app=sidekiq
kubectl logs -f -l app=unicorn --all-containers=true
kubectl logs -f -p gitlab-unicorn-b6fd44c4c-p8lm2 unicorn
kubectl logs -f -p gitlab-unicorn-b6fd44c4c-p8lm2 -c gitlab-workhorse
kubectl logs -f unicorn

# Added 2 more nodes (3 total), as struggling to deploy all resources
kubectl get node --watch

# Export current overrides used during install
helm get values gitlab > gitlab.yaml
#endregion GitLab


#region Cleanup
# Delete helm release
helm delete --purge gitlab
kubectl get pod --watch
kubectl get all -h

# Delete left over resources - Helm does not remove everything
kubectl get configmap,secrets,pv,pvc,hpa,pdb
kubectl delete configmap,secrets,pv,pvc,hpa,pdb -l release=gitlab
kubectl delete configmap --all

# Delete EVERY resource group that does NOT include tag: keep=true
$jobs = Get-AzResourceGroup | Where-Object {$_.Tags -eq $null -or $_.Tags.GetEnumerator().Name -notcontains "keep"} | Remove-AzResourceGroup -Force -AsJob
$jobs | Wait-Job
$jobs | Receive-Job -Keep
#endregion Cleanup
