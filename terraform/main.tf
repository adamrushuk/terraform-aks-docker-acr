# Provision an ACR, and an AKS cluster
resource "azurerm_resource_group" "aks" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.acr_name}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  location            = "${azurerm_resource_group.aks.location}"
  admin_enabled       = false
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.aks_cluster_name}"
  location            = "${azurerm_resource_group.aks.location}"
  resource_group_name = "${azurerm_resource_group.aks.name}"
  dns_prefix          = "${var.aks_cluster_name}"
  kubernetes_version  = "${var.kubernetes_version}"

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "${var.vm_size}"
    max_pods        = "${var.max_pods}"
    os_type         = "${var.os_type}"
    os_disk_size_gb = "${var.os_disk_size_gb}"
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  tags = {
    Environment = "${var.environment}"
  }
}
