variable "region" {
  type = string
  description = "Azure region"
  default = "eastasia"
}

variable "tenant_id" {
  type = string
  sensitive = true
  description = "Azure tenant ID"
}

variable "subscription_id" {
  type = string
  sensitive = true
  description = "Azure subscription ID"
}

variable "client_id" {
  type = string
  sensitive = true
  description = "Azure client (app) ID"
}

variable "client_secret" {
  type = string
  sensitive = true
  description = "Azure client (app) secret"
}

variable "azure_databricks_account_id" {
  type = string
  sensitive = true
  description = "Azure Databricks account ID"
}