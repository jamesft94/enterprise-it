# Dynamic groups: Entra ID works out who is a member from the user's attributes.
# Nobody adds people to these by hand, and Terraform doesn't either.
#
# Assign things to these groups once, and every joiner, mover and leaver follows:
#   - M365 licence      -> assigned to grp-all-employees (group-based licensing)
#   - Intune apps and compliance/config policies -> assigned to the department groups
#   - App access (SSO)  -> assigned to the department groups
#
# Disabled accounts drop out of every group, which frees their licence.

resource "azuread_group" "all_employees" {
  display_name     = "grp-all-employees"
  description      = "All active employees. Managed by Terraform; membership is automatic."
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "(user.employeeId -ne null) -and (user.accountEnabled -eq true)"
  }
}

resource "azuread_group" "department" {
  for_each = toset(var.departments)

  display_name     = "grp-dept-${lower(each.key)}"
  description      = "Active employees in ${each.key}. Managed by Terraform; membership is automatic."
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "(user.department -eq \"${each.key}\") -and (user.accountEnabled -eq true)"
  }
}
