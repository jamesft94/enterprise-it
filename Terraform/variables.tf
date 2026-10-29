variable "policy_rollout_stages" {
  description = "Controls whether policies are in 'report_only' (burn-in) or 'enforced' mode."
  type        = map(string)
  default = {
    require_compliant_device_rnd = "enabledForReportingButNotEnforced" # 14-day burn-in
    block_legacy_auth            = "enabled"                           # Fully enforced
  }

  validation {
    condition = alltrue([
      for k, v in var.policy_rollout_stages : contains(["enabled", "disabled", "enabledForReportingButNotEnforced"], v)
    ])
    error_message = "Policy state must be enabled, disabled, or enabledForReportingButNotEnforced."
  }
}

variable "rnd_engineering_group_id" {
  description = "Entra ID Object ID for R&D / Engineering group"
  type        = string
  default     = "00000000-0000-0000-0000-000000000001"
}

variable "break_glass_group_id" {
  description = "Emergency Break-Glass accounts excluded from all CA policies"
  type        = string
  default     = "00000000-0000-0000-0000-000000000999"
}
