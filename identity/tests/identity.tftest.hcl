# `terraform test` runs these against a mocked provider: no tenant, no credentials.
# They check the logic in users.tf and groups.tf before anything reaches Entra ID.

mock_provider "azuread" {}

variables {
  domain = "contoso.onmicrosoft.com"
}

run "one_account_per_row" {
  command = plan

  assert {
    condition     = length(azuread_user.employee) == 7
    error_message = "Expected one account per row in users.csv."
  }
}

run "norwegian_letters_in_sign_in_name" {
  command = plan

  assert {
    condition     = azuread_user.employee["1004"].user_principal_name == "lars.odegard@contoso.onmicrosoft.com"
    error_message = "Ødegård should become odegard."
  }
}

run "only_active_people_can_sign_in" {
  command = plan

  assert {
    condition     = azuread_user.employee["1001"].account_enabled == true
    error_message = "Active employee should be enabled."
  }
  assert {
    condition     = azuread_user.employee["1003"].account_enabled == false
    error_message = "Leaver should be disabled."
  }
  assert {
    condition     = azuread_user.employee["1007"].account_enabled == false
    error_message = "Pending joiner should be disabled until the first day."
  }
}

run "department_groups_are_dynamic" {
  command = plan

  assert {
    condition     = azuread_group.department["Sales"].dynamic_membership[0].rule == "(user.department -eq \"Sales\") -and (user.accountEnabled -eq true)"
    error_message = "Sales group rule is wrong."
  }
}

run "unknown_department_is_rejected" {
  command = plan

  variables {
    departments = ["Engineering"]
  }

  expect_failures = [azuread_user.employee]
}
