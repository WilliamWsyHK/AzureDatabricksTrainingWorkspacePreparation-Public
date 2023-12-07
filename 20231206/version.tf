terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.78"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 2.2"
    }
  }
}