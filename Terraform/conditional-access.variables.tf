variable "ca_policies" {
  description = "Conditional Access policies with explicit rollout state control"
  type = map(object({
    display_name     = string
    state            = string # Must be: enabledForReportingButNotEnforced, enabled, or disabled
    target_group_key = string # "all" or a key from var.department_groups (e.g., "rnd")
    grant_controls   = list(string)
    operator         = string # "AND" or "OR"
    session_hours    = number
  }))

  default = {
    # Start in report-only mode; enforcement requires an explicit reviewed change.
    baseline_mfa_all_staff = {
      display_name     = "CA001-Global-Require-MFA-All-Users"
      state            = "enabledForReportingButNotEnforced"
      target_group_key = "all"
      grant_controls   = ["mfa"]
      operator         = "OR"
      session_hours    = 24
    }

    rnd_require_compliant_device = {
      display_name     = "CA002-RnD-Require-Compliant-Device [Monitor-First]"
      state            = "enabledForReportingButNotEnforced"
      target_group_key = "rnd"
      grant_controls   = ["mfa", "compliantDevice"]
      operator         = "AND"
      session_hours    = 12
    }
  }

  # Guardrail: Prevent typos in policy states
  validation {
    condition = alltrue([
      for policy in values(var.ca_policies) : contains(["enabled", "disabled", "enabledForReportingButNotEnforced"], policy.state)
    ])
    error_message = "State must be 'enabledForReportingButNotEnforced', 'enabled', or 'disabled'."
  }

  validation {
    condition = alltrue([
      for policy in values(var.ca_policies) : policy.target_group_key == "all" || contains(keys(var.department_groups), policy.target_group_key)
    ])
    error_message = "Each target_group_key must be 'all' or a key in department_groups."
  }
}
