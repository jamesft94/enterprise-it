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


# 2. Global Baseline Group: Every Active Employee
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

# 4. Emergency Break-Glass Group (Static / Assigned only via Git PR)
resource "azuread_group" "break_glass_exclude" {
  display_name     = "SG-Sec-BreakGlass-Accounts"
  description      = "Emergency admin accounts excluded from Conditional Access to prevent lockouts"
  security_enabled = true
}