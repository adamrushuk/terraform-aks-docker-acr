provider "azurerm" {
  # Pin version to prevent automatic upgrades that may contain breaking changes
  version = "= 1.32.1"
}

# Deploying Terraform Remote State to Azure
terraform {
  # required_version = "= 0.12"
  backend "azurerm" {
    storage_account_name = "__terraform_storage_account__"
    container_name       = "__terraform_container_name__"
    key                  = "__terraform_key_name__"
    access_key           = "__storage_key__"
  }
}
