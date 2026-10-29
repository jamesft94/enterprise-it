# ============================================================================
# Terraform Group Management
# ============================================================================

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }
}


resource "azuread_group" "all_active_employees" {
  display_name     = "All-Active-Employees"
  description      = "Base M365 & Intune licensing group for all active staff"
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "(user.accountEnabled -eq true) and (user.employeeId -ne null)"
  }
}

resource "azuread_group" "departments" {
  for_each = var.department_groups

  display_name     = each.value.display_name
  description      = each.value.description
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "(user.accountEnabled -eq true) and (user.department -eq \"${each.value.hr_dept_name}\")"
  }
}