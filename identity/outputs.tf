output "accounts" {
  description = "Each employee's sign-in name and whether the account is enabled."
  value = {
    for id, u in azuread_user.employee : u.user_principal_name => u.account_enabled
  }
}

output "groups" {
  description = "Dynamic groups to target with licences, Intune policies and app access."
  value = concat(
    [azuread_group.all_employees.display_name],
    [for g in azuread_group.department : g.display_name],
  )
}
