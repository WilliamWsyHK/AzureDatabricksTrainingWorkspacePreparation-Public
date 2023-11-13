variable "tenant_id" {
  type = string
  sensitive = true
  description = "Azure tenant ID"
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

variable "user_csv_path" {
  type = string
  sensitive = false
  description = "Path to the User csv file"
}

variable "databricks_student_group_display_name" {
  type = string
  sensitive = false
  description = "Databricks student group display name in Microsoft Entra ID"
}

variable "databricks_instructor_group_display_name" {
  type = string
  sensitive = false
  description = "Databricks instructor group display name in Microsoft Entra ID"
}