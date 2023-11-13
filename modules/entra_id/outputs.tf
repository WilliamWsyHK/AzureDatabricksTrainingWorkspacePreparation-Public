output "users" {
  value = [
    for user in azuread_user.users:
    {
      user_principal_name = user.user_principal_name
      job_title = user.job_title
    }
  ]
}