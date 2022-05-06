terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.91.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate12574"
    container_name       = "tfstate-temporal"
    key                  = "base.terraform.tfstate"
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  # subscription_id = var.subscription
  # client_secret   = "..."
  # tenant_id       = "..."
}

resource "azurerm_resource_group" "base_resource_group" {
  name     = var.resource_group_name
  location = var.location
}
resource "azurerm_network_watcher" "network_watcher" {
  name                = "production-nwwatcher"
  location            = var.location
  resource_group_name = azurerm_resource_group.base_resource_group.name
}
resource "azurerm_container_registry" "acr" {
  name                = var.registry_name
  resource_group_name = azurerm_resource_group.base_resource_group.name
  location            = azurerm_resource_group.base_resource_group.location
  sku                 = "Basic"
  admin_enabled       = false
}
