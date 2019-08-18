# terraform-aks-docker-acr

Using Terraform to deploy AKS and ACR for custom Docker container usage.

A phased approach will be used, starting out simple, with a view to build functionality over time.

## Azure Build Pipeline

First, an Azure Build Pipeline will be created using the classic GUI editor, including these tasks:

1. [ ] Copy the following files into artifact staging area:
  1. [ ] Scripts needed for release pipeline.
  1. [ ] Terraform configuration files.
  1. [ ] Kubernetes manifest files to test AKS cluster - use simple NGINX demo deployment.
1. [ ] Publish a versioned build artifact.

## Azure Release Pipeline

An Azure Release Pipeline will then be created using the classic GUI editor, with two stages, Provision and Deploy.

### Provision Stage

The Provision stage will contain the following tasks:

   1. [ ] Provision Terraform Storage using Azure CLI task - used to store Terraform state files.
   1. [ ] Retrieve storage key and update Pipeline variable using Azure PowerShell task.
   1. [ ] Replace tokens with Pipeline variables in Terraform configuration files.
   1. [ ] Run `terraform init` to initialise the backend and download dependencies.
   1. [ ] Run `terraform plan` to create an execution plan showing changes that will be made once applied.
   1. [ ] Run `terraform apply` to apply the Terraform configuration files.

### Deploy Stage

## Multi-Stage Azure Pipeline using YAML
