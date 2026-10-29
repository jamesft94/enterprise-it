# ============================================================================
# STEP 4: Illustrative Intune Cross-OS Device Compliance Payloads
# Purpose: Define what makes a Windows, Mac, or Linux laptop "Compliant" for 
#          Conditional Access, without locking out users abruptly mid-workday.
# ISO 27001 Control: A.8.1 (User Endpoint Devices) & A.8.7 (Malware/EDR)
# ============================================================================

# 1. Define our Cross-OS Compliance Standards in one readable map
variable "os_compliance_baselines" {
  description = "Minimum ISO 27001 endpoint security requirements across Windows, macOS, and Linux"
  type = map(object({
    display_name           = string
    os_platform            = string
    require_disk_encryption = bool   # BitLocker (Win), FileVault (Mac), LUKS (Linux)
    require_firewall        = bool
    require_edr_healthy     = bool   # Defender for Endpoint / CrowdStrike active
    grace_period_days       = number # "Monitor-First" buffer before blocking access!
  }))

  default = {
    windows = {
      display_name            = "INTUNE-COMP-Windows11-ISO27001-Baseline"
      os_platform             = "windows10AndLater"
      require_disk_encryption = true
      require_firewall        = true
      require_edr_healthy     = true
      grace_period_days       = 31 # User gets 31 days to remediate before lockout
    }
    macos = {
      display_name            = "INTUNE-COMP-macOS-ISO27001-Baseline"
      os_platform             = "macOS"
      require_disk_encryption = true
      require_firewall        = true
      require_edr_healthy     = true
      grace_period_days       = 31
    }
    linux = {
      display_name            = "INTUNE-COMP-UbuntuLinux-RnD-Baseline"
      os_platform             = "linux"
      require_disk_encryption = true
      require_firewall        = true
      require_edr_healthy     = true
      grace_period_days       = 31
    }
  }
}

# 2. Construct illustrative Microsoft Graph payloads. This file does not create
#    or assign Intune policies; a reviewed deployment integration is required.
locals {
  intune_graph_payloads = {
    for os_key, policy in var.os_compliance_baselines : os_key => {
      displayName = policy.display_name
      description = "Managed by Terraform. Enforces encryption, EDR, and firewall with a ${policy.grace_period_days}-day grace period."
      
      # Core Security Controls (BitLocker / FileVault / LUKS + Firewall + EDR)
      bitLockerEnabled              = policy.os_platform == "windows10AndLater" ? policy.require_disk_encryption : null
      storageRequireEncryption      = policy.require_disk_encryption
      firewallEnabled               = policy.require_firewall
      defenderEnabled               = policy.require_edr_healthy
      deviceThreatProtectionEnabled = policy.require_edr_healthy

      # This sample payload models a remediation window; verify supported rule
      # names and platform-specific schema before sending it to Microsoft Graph.
      scheduledActionsForRule = [
        {
          ruleName = "PasswordRequired"
          scheduledActionConfigurations = [
            {
              actionType             = "block"
              gracePeriodHours       = policy.grace_period_days * 24
              notificationTemplateId = "00000000-0000-0000-0000-000000000000"
            }
          ]
        }
      ]

      # Assign Linux policy to R&D Dynamic Group; Windows/Mac to All Active Employees
      targetGroupId = (
        os_key == "linux"
        ? azuread_group.departments["rnd"].object_id
        : azuread_group.all_active_employees.object_id
      )
    }
  }
}

# 3. Output the Graph API payloads so CI/CD (or az rest / msgraph provider) applies them
output "intune_compliance_policies_planned" {
  description = "Illustrative payloads only; no Intune policies or assignments are created by this configuration."
  value       = local.intune_graph_payloads
}