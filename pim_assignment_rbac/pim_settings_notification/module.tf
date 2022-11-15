

#####################################################################################################
##############  Notification-Settings for Assignments
#####################################################################################################

locals {

  notification_rule_request_body_custom = jsonencode({
    properties = {
      rules = [
        for rule in local.notification_rules_by_recipient_type :
        rule.custom_rule
      ]
    }
  })

  # Reset to Azure Default Values on Destroy.
  notification_rule_request_body_default = jsonencode({
    properties = {
      rules = [
        for rule in local.notification_rules_by_recipient_type :
        rule.default_rule
      ]
    }
  })

}

# ! On Replacement the destroy local-exec is called, setting the default values !
# ! An immediate call with new values leads to not updating correctly, leaving the default values !
# ! The Time-Sleep causes some wating time after, destruction(setting default values), before applying the updated values !
resource "time_sleep" "wait_40_seconds__pim_assignment_notification_settings" {
  create_duration = "40s"

  triggers = {
    role_management_patch_url              = format(local.pim_role_management_policy_url_base, var.scope_resource_id, var.role_management_policy_guid)
    notification_rule_request_body_custom  = local.notification_rule_request_body_custom
    notification_rule_request_body_default = local.notification_rule_request_body_default
  }
}
resource "null_resource" "pim_assignment_notification_settings" {

  depends_on = [
    time_sleep.wait_40_seconds__pim_assignment_notification_settings
  ]
  triggers = {
    role_management_patch_url = format(local.pim_role_management_policy_url_base, var.scope_resource_id, var.role_management_policy_guid)

    notification_rule_request_body_custom  = local.notification_rule_request_body_custom
    notification_rule_request_body_default = local.notification_rule_request_body_default

  }

  provisioner "local-exec" {
    command = "az rest --method PATCH --headers Content-type=application/json --url '${self.triggers.role_management_patch_url}' --body '${self.triggers.notification_rule_request_body_custom}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "az rest --method PATCH --headers Content-type=application/json --url '${self.triggers.role_management_patch_url}' --body '${self.triggers.notification_rule_request_body_default}'"
  }

}
