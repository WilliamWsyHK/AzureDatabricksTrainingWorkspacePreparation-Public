terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.78"
    }
    databricks = {
      source = "databricks/databricks"
      version = "~> 1.29"
    }
  }
}