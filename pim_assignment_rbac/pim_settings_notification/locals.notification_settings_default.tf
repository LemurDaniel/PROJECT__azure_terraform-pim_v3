locals {

  settings_notification_default = {

    Notification_Admin_Admin_Eligibility = {
      id                         = "Notification_Admin_Admin_Eligibility"
      isDefaultRecipientsEnabled = true
      notificationLevel          = "All"
      notificationType           = "Email"
      recipientType              = "Admin"
      notificationRecipients     = []
      ruleType                   = "RoleManagementPolicyNotificationRule"
      target = {
        caller = "Admin"
        level  = "Eligibility"
        operations = [
          "All"
        ]
      }
    }

    Notification_Requestor_Admin_Eligibility = {
      id                         = "Notification_Requestor_Admin_Eligibility"
      isDefaultRecipientsEnabled = true
      notificationLevel          = "All"
      notificationType           = "Email"
      recipientType              = "Requestor"
      notificationRecipients     = []
      ruleType                   = "RoleManagementPolicyNotificationRule"
      target = {
        caller = "Admin"
        level  = "Eligibility"
        operations = [
          "All"
        ]
      }
    }

    Notification_Approver_Admin_Eligibility = {
      id                         = "Notification_Approver_Admin_Eligibility"
      isDefaultRecipientsEnabled = true
      notificationLevel          = "All"
      notificationType           = "Email"
      recipientType              = "Approver"
      notificationRecipients     = []
      ruleType                   = "RoleManagementPolicyNotificationRule"
      target = {
        caller = "Admin"
        level  = "Eligibility"
        operations = [
          "All"
        ]
      }
    }

    Notification_Admin_Admin_Assignment = {
      id                         = "Notification_Admin_Admin_Assignment"
      isDefaultRecipientsEnabled = true
      notificationLevel          = "All"
      notificationType           = "Email"
      recipientType              = "Admin"
      notificationRecipients     = []
      ruleType                   = "RoleManagementPolicyNotificationRule"
      target = {
        caller = "Admin"
        level  = "Assignment"
        operations = [
          "All"
        ]
      }
    }

    Notification_Requestor_Admin_Assignment = {
      id                         = "Notification_Requestor_Admin_Assignment"
      isDefaultRecipientsEnabled = true
      notificationLevel          = "All"
      notificationType           = "Email"
      recipientType              = "Requestor"
      notificationRecipients     = []
      ruleType                   = "RoleManagementPolicyNotificationRule"
      target = {
        caller = "Admin"
        level  = "Assignment"
        operations = [
          "All"
        ]
      }
    }

    Notification_Approver_Admin_Assignment = {
      id                         = "Notification_Approver_Admin_Assignment"
      isDefaultRecipientsEnabled = true
      notificationLevel          = "All"
      notificationType           = "Email"
      recipientType              = "Approver"
      notificationRecipients     = []
      ruleType                   = "RoleManagementPolicyNotificationRule"
      target = {
        caller = "Admin"
        level  = "Assignment"
        operations = [
          "All"
        ]
      }
    }

    Notification_Admin_EndUser_Assignment = {
      id                         = "Notification_Admin_EndUser_Assignment"
      isDefaultRecipientsEnabled = true
      notificationLevel          = "All"
      notificationType           = "Email"
      recipientType              = "Admin"
      notificationRecipients     = []
      ruleType                   = "RoleManagementPolicyNotificationRule"
      target = {
        caller = "EndUser"
        level  = "Assignment"
        operations = [
          "All"
        ]
      }
    }

    Notification_Requestor_EndUser_Assignment = {
      id                         = "Notification_Requestor_EndUser_Assignment"
      isDefaultRecipientsEnabled = true
      notificationLevel          = "All"
      notificationType           = "Email"
      recipientType              = "Requestor"
      notificationRecipients     = []
      ruleType                   = "RoleManagementPolicyNotificationRule"
      target = {
        caller = "EndUser"
        level  = "Assignment"
        operations = [
          "All"
        ]
      }
    }

    Notification_Approver_EndUser_Assignment = {
      id                         = "Notification_Approver_EndUser_Assignment"
      isDefaultRecipientsEnabled = true
      notificationLevel          = "All"
      notificationType           = "Email"
      recipientType              = "Approver"
      notificationRecipients     = []
      ruleType                   = "RoleManagementPolicyNotificationRule"
      target = {
        caller = "EndUser"
        level  = "Assignment"
        operations = [
          "All"
        ]
      }
    }

  }
}
