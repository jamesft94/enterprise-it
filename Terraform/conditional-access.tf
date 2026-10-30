# ============================================================================
# "Monitor-First" Conditional Access Policies as Code
# Purpose: Gradually roll out Zero Trust controls (Report-Only -> Enforced)
#          while guaranteeing Break-Glass accounts are never locked out.
# ISO 27001 Control: A.5.15 (Access Control) & A.8.5 (Secure Authentication)
# ============================================================================

# ============================================================================
# The following API permissions are required in order to use this resource.
# When authenticated with a service principal, this resource requires the following 
# application roles: Policy.ReadWrite.ConditionalAccess and Policy.Read.All
# When authenticated with a user principal, this resource requires one of the following 
# directory roles: Conditional Access Administrator or Global Administrator
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

  #  In the Microsoft Entra admin center this condition was renamed from Location to Network; 
  #  this is a portal label change only and the underlying API is unchanged.
    locations {
      included_locations = ["All"]
      excluded_locations = ["AllTrusted"]
    }

    users {
      included_groups = [
        each.value.target_group_key == "all"
        ? azuread_group.all_active_employees.object_id
        : azuread_group.departments[each.value.target_group_key].object_id
      ]

      # SAFETY NET: Always exclude our Authoritative Break-Glass Group 
      excluded_groups = [
        azuread_group.break_glass_exclude.object_id
      ]
    }
  }

  grant_controls {
    operator          = each.value.operator
    built_in_controls = each.value.grant_controls
  }

  session_controls {
    application_enforced_restrictions_enabled = false
    disable_resilience_defaults                = false
    persistent_browser_mode = "never" 
    sign_in_frequency        = each.value.session_hours
    sign_in_frequency_period = "hours"
  }
}