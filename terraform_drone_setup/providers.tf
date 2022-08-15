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

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "argocd" {
  server_addr = "https://argo.${var.cluster_domain}/"
  auth_token  = var.argo_token
}