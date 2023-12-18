terraform {
  required_providers {
    azurerm = {
      source = "registry.terraform.io/hashicorp/azurerm"
    }
    databricks = {
      source = "registry.terraform.io/databricks/databricks"
      configuration_aliases = [ databricks.accounts ]
    }
  }
}