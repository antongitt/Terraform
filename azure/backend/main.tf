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
  name     = "terraform-rg"
  location = var.region
}

resource "azurerm_storage_account" "sa" {
  name                            = "terraformsa${substr(var.subid, strrid(var.subid, "-") + 1, 12)}" # https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview#storage-account-name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "sc" {
  name                  = "terraform"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "local_file" "backend_tf" {
  filename        = "../${var.project}/backend.tf"
  file_permission = "0644"
  content         = <<EOT
terraform {
  backend "azurerm" {
    resource_group_name  = "${azurerm_resource_group.rg.name}"
    storage_account_name = "${azurerm_storage_account.sa.name}"
    container_name       = "${azurerm_storage_container.sc.name}"
    key                  = ".tfstate"
  }
}
EOT
}
