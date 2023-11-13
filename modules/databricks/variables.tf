variable "region" {
  type = string
  sensitive = false
  description = "Azure region"
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

variable "tags" {
  type = map(string)
  sensitive = false
  description = "Tags for Azure resources"
}

variable "training_date" {
  type = string
  sensitive = false
  description = "Training date in format of yyyyMMdd (as part of naming)"
}

variable "azure_databricks_users" {
  type = list(object({
    user_principal_name = string
    job_title = string
  }))
  sensitive = false
  description = "List of Azure Databricks users"
}

variable "azure_databricks_account_id" {
  type = string
  sensitive = true
  description = "Azure Databricks account ID"
}

variable "azure_databricks_metastore_name" {
  type = string
  sensitive = false
  description = "Azure Databricks Metastore (Unity Catalog) name"
}

variable "azure_databricks_unity_catalog_admin_group_display_name" {
  type = string
  sensitive = false
  description = "Azure Databricks Unity Catalog admin group display name"
}

variable "azure_databricks_workspace_naming_prefix" {
  type = string
  sensitive = false
  description = "Azure Databricks naming prefix"
}

variable "instructor_data_engineering_dbc_path" {
  type = string
  sensitive = false
  description = "Instructor Data Engineering materials (.dbc) path"
}

variable "instructor_data_science_dbc_path" {
  type = string
  sensitive = false
  description = "Instructor Data Science materials (.dbc) path"
}

variable "student_data_engineering_dbc_path" {
  type = string
  sensitive = false
  description = "Student Data Engineering materials (.dbc) path"
}

variable "student_data_science_dbc_path" {
  type = string
  sensitive = false
  description = "Student Data Science materials (.dbc) path"
}

variable "data_engineering_databricks_path" {
  type = string
  sensitive = false
  description = "Azure Databricks path for Data Engineering materials after import (will be prefixed with user home path)"
}

variable "data_science_databricks_path" {
  type = string
  sensitive = false
  description = "Azure Databricks path for Data Science materials after import (will be prefixed with user home path)"
}

variable "data_engineering_cluster_spark_version" {
  type = string
  sensitive = false
  description = "Azure Databricks cluster version for Data Engineering"
}

variable "data_science_cluster_spark_version" {
  type = string
  sensitive = false
  description = "Azure Databricks cluster version for Data Science"
}