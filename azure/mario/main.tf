terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subid
}

resource "azurerm_resource_group" "rg" {
  location = var.region
  name     = "${var.project}-aks-rg"
}

resource "azurerm_kubernetes_cluster" "cl" {
  location            = azurerm_resource_group.rg.location
  name                = "${var.project}-aks"
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.project}-dns"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name            = var.project
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 32
    node_count      = 1
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}