terraform {

  required_version = ">=0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "2.27.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
    drone = {
      source = "jimsheldon/drone"
      version = "0.2.0"
    }
    argocd = {
      source = "oboukili/argocd"
      version = "3.2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "__tfstategroup__"
    storage_account_name = "__tfstatestore__"
    container_name       = "setup"
    key                  = "terraform.tfstate"
    access_key           = "__storagekey__"
  }
}

provider "azurerm" {
  features {}
}

provider "drone" {
  server = "https://drone.${var.cluster_domain}/"
  token  = var.drone_admin_token
}

provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_config.0.host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
  }
}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "argocd" {

  server_addr = "argo.${var.cluster_domain}:443"
  auth_token  = var.argo_token
}