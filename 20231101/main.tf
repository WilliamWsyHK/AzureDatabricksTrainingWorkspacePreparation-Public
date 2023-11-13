provider "azurerm" {
  features {}
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  skip_provider_registration = true
}

data "azurerm_client_config" "current" {
}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

locals {
  training_date = "20231101"

  user_csv_path = "users.csv"
  entra_id_student_group_display_name = "Databricks Training Students ${local.training_date}"
  entra_id_instructor_group_display_name = "Databricks Training Instructors ${local.training_date}"

  azure_databricks_workspace_naming_prefix = "dbtraining-${local.training_date}"
  metastore_name = "training-${local.training_date}"
  azure_databricks_unity_catalog_admin_group_display_name = "Databricks Unity Catalog Administrators"

  instructor_data_engineering_dbc_path = "${path.module}/ADB-Bootcamp-DE-${local.training_date}-Instructor.dbc"
  instructor_data_science_dbc_path = "${path.module}/ADB-Bootcamp-DS-${local.training_date}-Instructor.dbc"
  student_data_engineering_dbc_path = "${path.module}/ADB-Bootcamp-DE-${local.training_date}-Student.dbc"
  student_data_science_dbc_path = "${path.module}/ADB-Bootcamp-DS-${local.training_date}-Student.dbc"

  data_engineering_databricks_path = "ADB-Bootcamp-DE-${local.training_date}"
  data_science_databricks_path = "ADB-Bootcamp-DS-${local.training_date}"

  data_engineering_cluster_spark_version = "11.3.x-scala2.12"
  data_science_cluster_spark_version = "12.2.x-cpu-ml-scala2.12"

  tags = {
    Environment = "Training"
    Owner       = lookup(data.external.me.result, "name")
  }
}

module "entra_id" {
  source = "../modules/entra_id"

  tenant_id = var.tenant_id
  client_id = var.client_id
  client_secret = var.client_secret
  user_csv_path = local.user_csv_path
  databricks_student_group_display_name = local.entra_id_student_group_display_name
  databricks_instructor_group_display_name = local.entra_id_instructor_group_display_name
}

module "databricks" {
  source = "../modules/databricks"

  region = var.region
  tenant_id = var.tenant_id
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret

  tags = local.tags

  training_date = local.training_date

  azure_databricks_users = module.entra_id.users

  azure_databricks_account_id = var.databricks_account_id
  azure_databricks_metastore_name = local.metastore_name
  azure_databricks_unity_catalog_admin_group_display_name = local.azure_databricks_unity_catalog_admin_group_display_name
  azure_databricks_workspace_naming_prefix = local.azure_databricks_workspace_naming_prefix

  instructor_data_engineering_dbc_path = local.instructor_data_engineering_dbc_path
  instructor_data_science_dbc_path = local.instructor_data_science_dbc_path
  student_data_engineering_dbc_path = local.student_data_engineering_dbc_path
  student_data_science_dbc_path = local.student_data_science_dbc_path

  data_engineering_databricks_path = local.data_engineering_databricks_path
  data_science_databricks_path = local.data_science_databricks_path

  data_engineering_cluster_spark_version = local.data_engineering_cluster_spark_version
  data_science_cluster_spark_version = local.data_science_cluster_spark_version
}

output "databricks_host" {
  value = module.databricks.databricks_host
}