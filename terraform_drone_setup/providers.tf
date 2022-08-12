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
  }
  backend "azurerm" {
    resource_group_name  = "pauls-demo-storage-group"
    storage_account_name = "paulbnimbletfstore"
    container_name       = "tfstate"
    key                  = "drone.setup.tfstate"
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
  tenant_id = "c8f73ab6-9d96-4a57-8b91-d22c63acec71"
}