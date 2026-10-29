# ============================================================================
# SENSIO ENTERPRISE IT BLUEPRINT: "Monitor-First" Conditional Access as Code
# Purpose: Prevent 24/7 operational lockouts by defaulting new security 
#          policies to Report-Only mode before enforcement.
# ISO 27001 Control: A.5.15 (Access Control) & A.8.32 (Change Management)
# ============================================================================

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }
  }
}

resource "azuread_conditional_access_policy" "require_compliant_device_rnd" {
  display_name = "CA010-R&D-Require-Compliant-Or-Managed-Device [Managed by Terraform]"
  
  # Core Philosophy: Monitor first in Log Analytics, enforce only after 0 false positives
  state = var.policy_rollout_stages["require_compliant_device_rnd"]

  conditions {
    client_app_types = ["browser", "mobileAppsAndDesktopClients"]

    applications {
      included_applications = ["All"]
    }

    users {
      included_groups = [var.rnd_engineering_group_id]
      excluded_groups = [var.break_glass_group_id]
    }
  }

  grant_controls {
    operator          = "OR"
    built_in_controls = ["compliantDevice", "domainJoinedDevice"]
  }
}