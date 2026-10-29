# ============================================================================
# STEP 5A: Bind FreeIPA Authentication to Entra ID R&D Dynamic Group
# Purpose: Allow FreeIPA (v4.9.10+ External IdP) to authenticate R&D users 
#          via Entra ID OIDC + MFA, scoped strictly to SG-Dept-RnD-Engineering.
# ============================================================================

resource "azuread_application" "freeipa_sso" {
  display_name     = "SSO-FreeIPA-RnD-Linux-Infrastructure"
  sign_in_audience = "AzureADMyOrg"

  app_role {
    allowed_member_types = ["User"]
    description          = "Allow assigned R&D members to sign in to FreeIPA"
    display_name         = "FreeIPA access"
    enabled              = true
    id                   = "7c57f8db-c3fb-4c8f-9f19-90bace745de6"
    value                = "FreeIPA.Access"
  }

  web {
    redirect_uris = ["https://ipa.example/ipa/idp/authn"]
  }
}

resource "azuread_service_principal" "freeipa_sso" {
  client_id                    = azuread_application.freeipa_sso.client_id
  app_role_assignment_required = true # Block non-R&D users from authenticating
}

# Automatically grant FreeIPA OIDC login to our R&D Dynamic Group from Step 2
resource "azuread_app_role_assignment" "rnd_group_to_freeipa" {
  app_role_id         = azuread_application.freeipa_sso.app_role_ids["FreeIPA.Access"]
  principal_object_id = azuread_group.departments["rnd"].object_id
  resource_object_id  = azuread_service_principal.freeipa_sso.object_id
}