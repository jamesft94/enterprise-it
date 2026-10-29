terraform {
  required_version = ">= 1.7"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }

  # State contains personal data, so keep it in a locked-down storage account.
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "stterraformstate"
  #   container_name       = "tfstate"
  #   key                  = "identity.tfstate"
  #   use_oidc             = true
  # }
}

# Credentials come from environment variables (ARM_TENANT_ID, ARM_CLIENT_ID, ARM_USE_OIDC)
# in the pipeline, or from `az login` when running locally.
provider "azuread" {}
