
locals {

  pim_role_management_policy_url_base = "https://management.azure.com/%s/providers/Microsoft.Authorization/roleManagementPolicies/%s?api-version=2020-10-01"

  management_policy_rules_default = jsondecode(file(abspath("${path.module}/.notification_settings_default.json")))
  role_managment_rule_level = {
    eligible   = "Eligibility"
    active     = "Assignment"
    activation = "Assignment"
  }
  role_managment_rule_target = {
    eligible   = "Admin",
    active     = "Admin",
    activation = "EndUser"
  }

  #####################################################################################################
  ##############  Notificatios-Settings for Assignments/Activations
  #####################################################################################################

  # Gets Send on activation, elgible assignment or active assignment on role depending on context.
  notification_settings_by_recipient = {
    Admin = {
      request_id = format("Notification_Admin_%s_%s", local.role_managment_rule_target[var.notification_type], local.role_managment_rule_level[var.notification_type])
      settings   = var.notification_admin
    }
    Requestor = {
      request_id = format("Notification_Requestor_%s_%s", local.role_managment_rule_target[var.notification_type], local.role_managment_rule_level[var.notification_type])
      settings   = var.notification_requestor
    }
    Approver = {
      request_id = format("Notification_Approver_%s_%s", local.role_managment_rule_target[var.notification_type], local.role_managment_rule_level[var.notification_type])
      settings   = var.notification_approver
    }
  }

  notification_rules_by_recipient_type = {

    for recipient_type, notification in local.notification_settings_by_recipient :
    recipient_type => {

      # Default Rule for default values.
      default_rule = local.management_policy_rules_default[notification.request_id]
      # Custom Rule for custom values.
      custom_rule = {
        notificationType           = "Email"
        recipientType              = recipient_type
        isDefaultRecipientsEnabled = coalesce(lookup(notification.settings, "default_recipients", null), local.management_policy_rules_default[notification.request_id].isDefaultRecipientsEnabled)
        notificationLevel          = coalesce(lookup(notification.settings, "notification_level", null), local.management_policy_rules_default[notification.request_id].notificationLevel)
        notificationRecipients     = coalesce(lookup(notification.settings, "notification_recipients", null), local.management_policy_rules_default[notification.request_id].notificationRecipients)
        id                         = notification.request_id
        ruleType                   = "RoleManagementPolicyNotificationRule"
        target = {
          caller = local.role_managment_rule_target[var.notification_type]
          operations = [
            "All"
          ]
          level               = local.role_managment_rule_level[var.notification_type]
          targetObjects       = null
          inheritableSettings = null
          enforcedSettings    = null
        }
      }
    }
    if notification.settings != null
  }
}

