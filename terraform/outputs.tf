output "kubernetes_master_fqdn" {
  value = "${azurerm_kubernetes_cluster.aks.fqdn}"
}

output "kubernetes_client_certificate" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate}"
}

output "kubernetes_config" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
}
