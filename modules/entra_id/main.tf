# Configure the Azure Active Directory Provider
provider "azuread" {
  tenant_id = var.tenant_id
  client_id = var.client_id
  client_secret = var.client_secret
}

# Retrieve domain information
data "azuread_domains" "default" {
  only_initial = true
}

data "azuread_client_config" "current" {}

locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
  users       = csvdecode(file(var.user_csv_path))
}

# Create users
resource "azuread_user" "users" {
  for_each = {
    for user in local.users :
      format(
        "%s.%s@%s",
        lower(user.first_name),
        lower(user.last_name),
        local.domain_name
      ) => user
  }

  user_principal_name = format(
    "%s.%s@%s",
    lower(each.value.first_name),
    lower(each.value.last_name),
    local.domain_name
  )

  password = format(
    "%s%s%s!",
    lower(each.value.last_name),
    substr(lower(each.value.first_name), 0, 1),
    length(each.value.first_name)
  )
  force_password_change = true

  display_name = "${each.value.first_name} ${each.value.last_name}"
  department   = each.value.department
  job_title    = each.value.job_title
}

resource "azuread_group" "student_group" {
  display_name = var.databricks_student_group_display_name
  owners = [data.azuread_client_config.current.object_id]
  security_enabled = true
  mail_enabled = false
}

resource "azuread_group_member" "students" {
  for_each = { for user in azuread_user.users : user.user_principal_name => user if lower(user.job_title) == "student" }

  group_object_id = azuread_group.student_group.id
  member_object_id = each.value.id
}

resource "azuread_group" "instructor_group" {
  display_name = var.databricks_instructor_group_display_name
  owners = [data.azuread_client_config.current.object_id]
  security_enabled = true
  mail_enabled = false
}

resource "azuread_group_member" "instructors" {
  for_each = { for user in azuread_user.users : user.user_principal_name => user if lower(user.job_title) == "instructor" }

  group_object_id = azuread_group.instructor_group.id
  member_object_id = each.value.id
}