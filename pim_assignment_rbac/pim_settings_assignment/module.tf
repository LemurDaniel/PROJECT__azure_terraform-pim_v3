

#####################################################################################################
##############  Expiration-Settings for Assignments
#####################################################################################################

locals {
  assignment_rule_request_body_custom = jsonencode({
    properties = {
      rules = [
        local.expiration_rule_custom
      ]
    }
  })

  # Reset to Azure Default Values on Destroy.
  assignment_rule_request_body_default = jsonencode({
    properties = {
      rules = [
        local.management_policy_rules_default[local.expiration_request_id]
      ]
    }
  })
}

# ! On Replacement the destroy local-exec is called, setting the default values !
# ! An immediate call with new values leads to not updating correctly, leaving the default values !
# ! The Time-Sleep causes some wating time after, destruction(setting default values), before applying the updated values !
resource "time_sleep" "wait_25_seconds__pim_assignment_expiration_settings" {
  create_duration = "25s"

  triggers = {
    role_management_patch_url            = format(local.pim_role_management_policy_url_base, var.scope_resource_id, var.role_management_policy_guid)
    assignment_rule_request_body_custom  = local.assignment_rule_request_body_custom
    assignment_rule_request_body_default = local.assignment_rule_request_body_default
  }
}

resource "null_resource" "pim_assignment_expiration_settings" {

  depends_on = [
    time_sleep.wait_25_seconds__pim_assignment_expiration_settings
  ]

  count = local.is_expiration_disabled ? 0 : 1

  triggers = {
    role_management_patch_url            = format(local.pim_role_management_policy_url_base, var.scope_resource_id, var.role_management_policy_guid)
    assignment_rule_request_body_custom  = local.assignment_rule_request_body_custom
    assignment_rule_request_body_default = local.assignment_rule_request_body_default
  }

  provisioner "local-exec" {
    command = "az rest --method PATCH --headers Content-type=application/json --url '${self.triggers.role_management_patch_url}' --body '${self.triggers.assignment_rule_request_body_custom}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "az rest --method PATCH --headers Content-type=application/json --url '${self.triggers.role_management_patch_url}' --body '${self.triggers.assignment_rule_request_body_default}'"
  }

}



#####################################################################################################
##############  Enablement-Settings for Assignments
#####################################################################################################

locals {
  enablement_rule_request_body_custom = jsonencode({
    properties = {
      rules = [
        local.enablement_rule_custom
      ]
    }
  })

  # Reset to Azure Default Values on Destroy.
  enablement_rule_request_body_default = jsonencode({
    properties = {
      rules = [
        local.management_policy_rules_default[local.enablement_request_id]
      ]
    }
  })
}

# ! On Replacement the destroy local-exec is called, setting the default values !
# ! An immediate call with new values leads to not updating correctly, leaving the default values !
# ! The Time-Sleep causes some wating time after, destruction(setting default values), before applying the updated values !
resource "time_sleep" "wait_25_seconds__pim_assignment_enablement_settings" {
  create_duration = "25s"

  triggers = {
    role_management_patch_url            = format(local.pim_role_management_policy_url_base, var.scope_resource_id, var.role_management_policy_guid)
    enablement_rule_request_body_custom  = local.enablement_rule_request_body_custom
    enablement_rule_request_body_default = local.enablement_rule_request_body_default
  }

}

resource "null_resource" "pim_assignment_enablement_settings" {

  depends_on = [
    time_sleep.wait_25_seconds__pim_assignment_enablement_settings
  ]

  # For current implementation disabled, but works.
  count = var.schedule_type == "eligible" || var.schedule_type == "active" ? 0 : 1

  triggers = {
    role_management_patch_url            = format(local.pim_role_management_policy_url_base, var.scope_resource_id, var.role_management_policy_guid)
    enablement_rule_request_body_custom  = local.enablement_rule_request_body_custom
    enablement_rule_request_body_default = local.enablement_rule_request_body_default
  }

  provisioner "local-exec" {
    command = "az rest --method PATCH --headers Content-type=application/json --url '${self.triggers.role_management_patch_url}' --body '${self.triggers.enablement_rule_request_body_custom}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "az rest --method PATCH --headers Content-type=application/json --url '${self.triggers.role_management_patch_url}' --body '${self.triggers.enablement_rule_request_body_default}'"
  }


}
