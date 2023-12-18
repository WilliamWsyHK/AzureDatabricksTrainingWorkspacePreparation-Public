resource "azurerm_resource_group" "this" {
  name     = "${var.azure_databricks_workspace_naming_prefix}-rg"
  location = var.region
  tags     = var.tags
}

resource "azurerm_storage_account" "unity_catalog" {
  name = "${lower(replace(var.azure_databricks_workspace_naming_prefix, "-", ""))}uc"
  resource_group_name = azurerm_resource_group.this.name
  location = azurerm_resource_group.this.location
  account_kind = "StorageV2"
  is_hns_enabled = true
  access_tier = "Hot"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_https_traffic_only = true
  min_tls_version = "TLS1_2"
}

resource "azurerm_storage_container" "unity_catalog" {
  name = "uc-container"
  storage_account_name = azurerm_storage_account.unity_catalog.name
  container_access_type = "private"
}

resource "azurerm_databricks_access_connector" "this" {
  name = "${var.azure_databricks_workspace_naming_prefix}-access-connector"
  resource_group_name = azurerm_resource_group.this.name
  location = azurerm_resource_group.this.location

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "databricks_access_connector_storage_access" {
  scope = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = azurerm_databricks_access_connector.this.identity[0].principal_id
}

resource "azurerm_databricks_workspace" "this" {
  name                        = "${var.azure_databricks_workspace_naming_prefix}-workspace"
  resource_group_name         = azurerm_resource_group.this.name
  location                    = azurerm_resource_group.this.location
  sku                         = "premium"
  managed_resource_group_name = "${var.azure_databricks_workspace_naming_prefix}-workspace-rg"
  tags                        = var.tags
}


provider "databricks" {
  alias = "workspace"
  host = azurerm_databricks_workspace.this.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.this.id
  azure_tenant_id = var.tenant_id
  azure_client_id = var.client_id
  azure_client_secret = var.client_secret
}

data "databricks_service_principal" "terraform" {
  provider = databricks.accounts

  application_id = var.client_id
}

data "databricks_group" "unity_catalog_admin" {
  provider = databricks.accounts

  display_name = var.azure_databricks_unity_catalog_admin_group_display_name
}

data "databricks_node_type" "node_type" {
  provider = databricks.workspace

  local_disk = true
  min_cores = 4
  min_memory_gb = 14

  depends_on = [
    azurerm_databricks_workspace.this
  ]
}

data "databricks_spark_version" "latest_lts_ml" {
  provider = databricks.workspace

  long_term_support = true
  ml = true

  depends_on = [
    azurerm_databricks_workspace.this
  ]
}

data "databricks_group" "workspace_admins" {
  provider = databricks.workspace

  display_name = "admins"

  depends_on = [
    azurerm_databricks_workspace.this
  ]
}

# resource "databricks_service_principal_role" "sp" {
#   provider = databricks.accounts

#   service_principal_id = databricks_service_principal.terraform.id
#   role = "account_admin"
# }

# resource "databricks_group_member" "sp" {
#   provider = databricks.accounts

#   group_id = data.databricks_group.unity_catalog_admin.id
#   member_id = databricks_service_principal.terraform.id
# }

resource "databricks_metastore" "this" {
  provider = databricks.accounts

  name = var.azure_databricks_metastore_name
  storage_root = format("abfss://%s@%s.dfs.core.windows.net/",
    azurerm_storage_container.unity_catalog.name,
    azurerm_storage_account.unity_catalog.name
  )
  owner = data.databricks_group.unity_catalog_admin.display_name
  region = azurerm_storage_account.unity_catalog.location

  force_destroy = true
}

resource "databricks_metastore_assignment" "this" {
  provider = databricks.accounts

  metastore_id = databricks_metastore.this.metastore_id
  workspace_id = azurerm_databricks_workspace.this.workspace_id
}

resource "databricks_metastore_data_access" "this" {
  provider = databricks.workspace

  metastore_id = databricks_metastore.this.metastore_id
  name = azurerm_databricks_workspace.this.name

  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.this.id
  }

  depends_on = [ databricks_metastore_assignment.this ]
}

resource "databricks_user" "students" {
  provider = databricks.workspace

  for_each = { for user in var.azure_databricks_users : user.user_principal_name => user if lower(user.job_title) == "student" }

  user_name = each.value.user_principal_name
}

resource "databricks_user" "instructors" {
  provider = databricks.workspace

  for_each = { for user in var.azure_databricks_users : user.user_principal_name => user if lower(user.job_title) == "instructor" }

  user_name = each.value.user_principal_name
}

resource "databricks_group_member" "workspace_admins" {
  provider = databricks.workspace

  for_each = { for user in databricks_user.instructors : user.user_name => user }

  group_id = data.databricks_group.workspace_admins.id
  member_id = each.value.id
}

resource "databricks_notebook" "students_de_notebook" {
  provider = databricks.workspace

  for_each = { for user in databricks_user.students : user.user_name => user }

  path = "${each.value.home}/${var.data_engineering_databricks_path}"
  # language = "PYTHON"
  format = "DBC"
  source = var.student_data_engineering_dbc_path
}

resource "databricks_notebook" "instructors_de_notebook" {
  provider = databricks.workspace

  for_each = { for user in databricks_user.instructors : user.user_name => user }

  path = "${each.value.home}/${var.data_engineering_databricks_path}"
  # language = "PYTHON"
  format = "DBC"
  source = var.instructor_data_engineering_dbc_path
}

resource "databricks_notebook" "students_ds_notebook" {
  provider = databricks.workspace

  for_each = { for user in databricks_user.students : user.user_name => user }

  path = "${each.value.home}/${var.data_science_databricks_path}"
  # language = "PYTHON"
  format = "DBC"
  source = var.student_data_science_dbc_path
}

resource "databricks_notebook" "instructors_ds_notebook" {
  provider = databricks.workspace

  for_each = { for user in databricks_user.instructors : user.user_name => user }

  path = "${each.value.home}/${var.data_science_databricks_path}"
  # language = "PYTHON"
  format = "DBC"
  source = var.instructor_data_science_dbc_path
}

resource "databricks_cluster" "student_de_clusters" {
  provider = databricks.workspace

  for_each = { for user in databricks_user.students : user.user_name => user }

  cluster_name = "${each.key}'s DE Cluster"
  # spark_version = data.databricks_spark_version.latest_lts_ml.id
  spark_version = var.data_engineering_cluster_spark_version
  driver_node_type_id = data.databricks_node_type.node_type.id
  node_type_id = data.databricks_node_type.node_type.id
  data_security_mode = "SINGLE_USER"
  single_user_name = each.key
  autotermination_minutes = 30
  num_workers = 0

  spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }
}

resource "databricks_permissions" "student_de_cluster_usages" {
  provider = databricks.workspace

  for_each = { for cluster in databricks_cluster.student_de_clusters : cluster.cluster_name => cluster }

  cluster_id = each.value.id

  access_control {
    user_name = replace(each.key, "'s DE Cluster", "")
    permission_level = "CAN_RESTART"
  }
}

resource "databricks_cluster" "student_ml_clusters" {
  provider = databricks.workspace

  for_each = { for user in databricks_user.students : user.user_name => user }

  cluster_name = "${each.key}'s ML Cluster"
  # spark_version = data.databricks_spark_version.latest_lts_ml.id
  spark_version = var.data_science_cluster_spark_version
  driver_node_type_id = data.databricks_node_type.node_type.id
  node_type_id = data.databricks_node_type.node_type.id
  data_security_mode = "SINGLE_USER"
  single_user_name = each.key
  autotermination_minutes = 30
  num_workers = 0

  spark_conf = {
    "spark.databricks.cluster.profile" : "singleNode"
    "spark.master" : "local[*]"
  }

  custom_tags = {
    "ResourceClass" = "SingleNode"
  }
}

resource "databricks_permissions" "student_ml_cluster_usages" {
  provider = databricks.workspace

  for_each = { for cluster in databricks_cluster.student_ml_clusters : cluster.cluster_name => cluster }

  cluster_id = each.value.id

  access_control {
    user_name = replace(each.key, "'s ML Cluster", "")
    permission_level = "CAN_RESTART"
  }
}


resource "databricks_cluster" "instructor_de_clusters" {
  provider = databricks.workspace

  for_each = { for user in databricks_user.instructors : user.user_name => user }

  cluster_name = "${each.key}'s DE Cluster"
  # spark_version = data.databricks_spark_version.latest_lts_ml.id
  spark_version = var.data_engineering_cluster_spark_version
  driver_node_type_id = data.databricks_node_type.node_type.id
  node_type_id = data.databricks_node_type.node_type.id
  data_security_mode = "SINGLE_USER"
  single_user_name = each.key
  autotermination_minutes = 30
  num_workers = 2

  # spark_conf = {
  #   "spark.databricks.cluster.profile" : "singleNode"
  #   "spark.master" : "local[*]"
  # }

  # custom_tags = {
  #   "ResourceClass" = "SingleNode"
  # }
}

resource "databricks_cluster" "instructor_ml_clusters" {
  provider = databricks.workspace

  for_each = { for user in databricks_user.instructors : user.user_name => user }

  cluster_name = "${each.key}'s ML Cluster"
  # spark_version = data.databricks_spark_version.latest_lts_ml.id
  spark_version = var.data_science_cluster_spark_version
  driver_node_type_id = data.databricks_node_type.node_type.id
  node_type_id = data.databricks_node_type.node_type.id
  data_security_mode = "SINGLE_USER"
  single_user_name = each.key
  autotermination_minutes = 30
  num_workers = 2

  # spark_conf = {
  #   "spark.databricks.cluster.profile" : "singleNode"
  #   "spark.master" : "local[*]"
  # }

  # custom_tags = {
  #   "ResourceClass" = "SingleNode"
  # }
}

resource "databricks_cluster_policy" "dbacademy_dlt" {
  provider = databricks.workspace

  name = "DBAcademy DLT"
  definition = jsonencode({
    "cluster_type": {
      "type": "fixed",
      "value": "dlt"
    },
    "spark_conf.spark.databricks.cluster.profile": {
      "type": "fixed",
      "value": "singleNode",
      "hidden": false
    },
    "num_workers": {
      "type": "fixed",
      "value": 0,
      "hidden": false
    },
  })
}