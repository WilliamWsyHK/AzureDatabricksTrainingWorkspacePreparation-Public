terraform {
  required_providers {
    azuread = {
      source = "registry.terraform.io/hashicorp/azuread"
    }
    azurerm = {
      source = "registry.terraform.io/hashicorp/azurerm"
    }
    databricks = {
      source = "registry.terraform.io/databricks/databricks"
    }
  }
}

provider "azuread" {
  tenant_id = var.tenant_id
  client_id = var.client_id
  client_secret = var.client_secret
}

provider "azurerm" {
  features {}
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  skip_provider_registration = true
}

provider "databricks" {
  alias = "accounts"
  host = "https://accounts.azuredatabricks.net"
  account_id = var.azure_databricks_account_id
  azure_tenant_id = var.tenant_id
  azure_client_id = var.client_id
  azure_client_secret = var.client_secret
}