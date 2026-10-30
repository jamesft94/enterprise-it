# ============================================================================
# "Monitor-First" Conditional Access Policies as Code
# Purpose: Gradually roll out Zero Trust controls (Report-Only -> Enforced)
#          while guaranteeing Break-Glass accounts are never locked out.
# ISO 27001 Control: A.5.15 (Access Control) & A.8.5 (Secure Authentication)
# ============================================================================


## This resource is subject to a restrictive API request limit of 1 request/second. 
## Whilst Terraform will automatically back-off and retry throttled requests, 
## if you have a large number of resource changes to make, you may wish to reduce 
## parallelism or specify extended custom resource timeouts.
resource "azuread_conditional_access_policy" "zero_trust_policies" {
  for_each     = var.ca_policies
  display_name = each.value.display_name
  state        = each.value.state

  conditions {
    client_app_types = ["browser", "mobileAppsAndDesktopClients"]
    sign_in_risk_levels = ["low", "medium", "high"]
    user_risk_levels    = ["low", "medium", "high"]

    applications {
      included_applications = ["All"]
    }

    locations {
      included_locations = ["All"]
      excluded_locations = ["AllTrusted"]
    }

    users {
      # Dynamically target either All Active Employees or a specific Department Group from Step 2
      included_groups = [
        each.value.target_group_key == "all"
        ? azuread_group.all_active_employees.object_id
        : azuread_group.departments[each.value.target_group_key].object_id
      ]

      # SAFETY NET: Always exclude our Authoritative Break-Glass Group from Step 2
      excluded_groups = [
        azuread_group.break_glass_exclude.object_id
      ]
    }
  }

  grant_controls {
    operator          = "AND"
    built_in_controls = each.value.grant_controls
  }

  session_controls {
    sign_in_frequency        = each.value.session_hours
    sign_in_frequency_period = "hours"
  }
}