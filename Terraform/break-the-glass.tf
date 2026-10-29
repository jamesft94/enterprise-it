# ============================================================================
# AUTHORITATIVE BREAK-GLASS GROUP MANAGEMENT (Git PR + Drift Protection)
# Any manual changes in the Entra Portal will be overwritten on the next run.
# ISO 27001 Control: A.5.15 (Access Control) & A.8.2 (Privileged Access Rights)
# ============================================================================

# 1. Explicit list of approved emergency accounts (Changes require a Git PR)
variable "approved_break_glass_upns" {
  description = "Explicit list of emergency Break-Glass UPNs. Must use cloud-only .onmicrosoft.com domains."
  type        = set(string)

  validation {
    condition = length(var.approved_break_glass_upns) >= 2 && alltrue([
      for upn in var.approved_break_glass_upns : endswith(upn, ".onmicrosoft.com")
    ])
    error_message = "Provide at least two real emergency account UPNs using the tenant's .onmicrosoft.com domain."
  }
}

data "azuread_user" "break_glass_users" {
  for_each            = var.approved_break_glass_upns
  user_principal_name = each.value
}

resource "azuread_group" "break_glass_exclude" {
  display_name       = "SG-Sec-BreakGlass-Accounts"
  description        = "Emergency accounts excluded from Conditional Access. Strictly managed via Terraform."
  security_enabled   = true
  assignable_to_role = true # Prevents regular Group Admins from modifying this group!

  # Manual portal additions are wiped out automatically on the next Terraform run.
  members = [
    for user in data.azuread_user.break_glass_users : user.object_id
  ]
}