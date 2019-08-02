# Service Principle
variable "client_id" {
  default = "__client_id__"
}

variable "client_secret" {
  default = "__client_secret__"
}


# Resource Group
variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "aks-rg"
}


# ACR
variable "acr_name" {
  default = "__acr_name__"
}


# AKS
variable "aks_cluster_name" {
  description = "Name used for both AKS Cluster and DNS Prefix"
  default     = "MyAksClusterName01"
}

variable "kubernetes_version" {
  default = "1.14.3"
}

variable "agent_count" {
  default = 1
}

variable "vm_size" {
  default = "Standard_D1_v2"
}

variable "max_pods" {
  default = 100
}

variable "os_type" {
  default = "Linux"
}

variable "os_disk_size_gb" {
  default = 30
}

variable "environment" {
  default = "dev"
}
