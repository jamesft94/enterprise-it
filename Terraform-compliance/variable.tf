variable "ca_policies" {
  description = "Conditional Access policies with explicit rollout state control"
  type = map(object({
    display_name    = string
    state           = string # Must be: enabledForReportingButNotEnforced, enabled, or disabled
    target_group_key = string # "all" or a key from var.department_groups (e.g., "rnd")
    grant_controls  = list(string)
    session_hours   = number
  }))

  default = {
    # Policy 1: Baseline MFA for all active staff (Already burned-in & enforced)
    baseline_mfa_all_staff = {
      display_name     = "CA001-Global-Require-MFA-All-Active-Staff"
      state            = "enabled"
      target_group_key = "all"
      grant_controls   = ["mfa"]
      session_hours    = 24
    }

    # Policy 2: Require Intune/Compliant Device for R&D (Currently in 14-day Monitor-First mode!)
    rnd_require_compliant_device = {
      display_name     = "CA002-RnD-Require-Compliant-Device [Monitor-First]"
      state            = "enabledForReportingButNotEnforced"
      target_group_key = "rnd"
      grant_controls   = ["mfa", "compliantDevice"]
      session_hours    = 12
    }
  }

  # Guardrail: Prevent typos in policy states
  validation {
    condition = alltrue([
      for k, v in var.ca_policies : contains(["enabled", "disabled", "enabledForReportingButNotEnforced"], v.state)
    ])
    error_message = "State must be 'enabledForReportingButNotEnforced', 'enabled', or 'disabled'."
  }
}
