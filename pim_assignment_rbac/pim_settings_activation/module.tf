
data "azuread_user" "on_activation_required_approvers" {
  for_each = toset([
    for approver in var.activation_required_approvers :
    approver if length(regexall("^.+@.+[.].+$", lower(approver))) > 0
  ])

  //mail_nickname = each.key
  user_principal_name = each.key
}

data "azuread_group" "on_activation_required_approvers" {
  for_each = toset([
    for approver in var.activation_required_approvers :
    approver if length(regexall("^.+@.+[.].+$", lower(approver))) == 0
  ])

  display_name = each.key
}



# NUll Resource calling the PIM v3 ARM API

# ! On Replacement the destroy local-exec is called, setting the default values !
# ! An immediate call with new values leads to not updating correctly, leaving the default values !
# ! The Time-Sleep causes some wating time after, destruction(setting default values), before applying the updated values !
resource "time_sleep" "wait_15_seconds__pim_activation_settings" {
  create_duration = "15s"

  triggers = {
    role_management_patch_url            = format(local.pim_role_management_policy_url_base, var.scope_resource_id, var.role_management_policy_guid)
    activation_rule_request_body_custom  = local.activation_rule_request_body_custom
    activation_rule_request_body_default = local.activation_rule_request_body_default
  }
}
resource "null_resource" "pim_activation_settings" {

  depends_on = [
    time_sleep.wait_15_seconds__pim_activation_settings
  ]

  triggers = {
    role_management_patch_url = format(local.pim_role_management_policy_url_base, var.scope_resource_id, var.role_management_policy_guid)

    activation_rule_request_body_custom  = local.activation_rule_request_body_custom
    activation_rule_request_body_default = local.activation_rule_request_body_default
  }

  provisioner "local-exec" {
    command = "az rest --method PATCH --headers Content-type=application/json --url '${self.triggers.role_management_patch_url}' --body '${self.triggers.activation_rule_request_body_custom}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "az rest --method PATCH --headers Content-type=application/json --url '${self.triggers.role_management_patch_url}' --body '${self.triggers.activation_rule_request_body_default}'"
  }

}
