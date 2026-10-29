# One row in users.csv = one account in Entra ID.
#
#   Joiner : add a row with status "pending" (account created, but disabled)
#            change it to "active" on the first day
#   Mover  : change the department; dynamic groups move the person automatically
#   Leaver : change status to "leaver"; never delete the row

locals {
  users = { for u in csvdecode(file("${path.module}/users.csv")) : u.employee_id => u }

  # "Lars Ødegård" -> "lars.odegard"
  usernames = {
    for id, u in local.users : id => replace(replace(replace(replace(
      lower("${u.first_name}.${u.last_name}"),
    "æ", "ae"), "ø", "o"), "å", "a"), " ", "-")
  }
}

resource "azuread_user" "employee" {
  for_each = local.users

  user_principal_name = "${local.usernames[each.key]}@${var.domain}"
  mail_nickname       = local.usernames[each.key]
  display_name        = "${each.value.first_name} ${each.value.last_name}"
  given_name          = each.value.first_name
  surname             = each.value.last_name
  employee_id         = each.key
  department          = each.value.department
  job_title           = each.value.job_title
  usage_location      = var.usage_location

  account_enabled = each.value.status == "active"

  # Entra generates a random initial password. It must be changed at first sign-in.
  force_password_change = true

  lifecycle {
    # Removing a row would delete the account and its mailbox and files.
    # Terraform refuses instead. Leavers are disabled with status = "leaver".
    prevent_destroy = true

    # After the first sign-in the password belongs to the user. Don't reset it.
    ignore_changes = [force_password_change]

    precondition {
      condition     = contains(["pending", "active", "leaver"], each.value.status)
      error_message = "users.csv: status for ${each.key} must be pending, active or leaver."
    }
    precondition {
      condition     = contains(var.departments, each.value.department)
      error_message = "users.csv: department '${each.value.department}' for ${each.key} is not in var.departments."
    }
  }
}
