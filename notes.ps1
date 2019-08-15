# Setup Azure Service Principal
az ad sp create-for-rbac --name "terraform-aks-docker-acr"

# Run pipeline, then once AKS deployed, continue below

# Connect to AKS
az aks get-credentials --resource-group aks-rg --name MyAksClusterName01

# View AKS Dashboard
az aks browse --resource-group aks-rg --name MyAksClusterName01

# Check context (should show AKS cluster name, eg: MyAksClusterName01)
kubectl config current-context

# Show resources
kubectl get all

# Get External IP for NGINX demo
kubectl get svc nginxdemo

# [OPTIONAL] Delete nginx demo resources
kubectl delete deployment,svc nginxdemo
kubectl get pod --watch


### Install Helm ###
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



### Install Jenkins ###
# List current Helm releases
helm list

# Install Jenkins
helm install --name jenkins stable/jenkins

# Show all resources for Jenkins (filter by label)
kubectl get all -l "helm.sh/chart=jenkins-1.5.0"

# Monitor pod and service building
kubectl get pod -l "helm.sh/chart=jenkins-1.5.0" --watch
kubectl get svc --namespace default -w jenkins
# Check pod events
kubectl describe pod -l "helm.sh/chart=jenkins-1.5.0"


## Find connection details
# First view complete Service config in JSON format
kubectl get svc --namespace default jenkins -o json
# Get Jenkins Loadbalancer URL using jsonpath, eg: {.status.loadBalancer.ingress[0].ip} and {.spec.ports[0].port}
kubectl get svc --namespace default jenkins -o jsonpath="http://{.status.loadBalancer.ingress[0].ip}:{.spec.ports[0].port}"

# Get admin password (you need bash installed to decode using base64 cmd)
$jenkinsAdminPassword = kubectl get secret --namespace default jenkins -o jsonpath="{.data.jenkins-admin-password}"
bash -c "echo $jenkinsAdminPassword | base64 --decode"


## Cleanup
helm delete jenkins --purge


# Troubleshooting
kubectl describe svc jenkins-agent
kubectl get svc jenkins-agent -o yaml
kubectl get svc jenkins-agent --watch
