variable "scope_resource_id" {
  description = "(Required) The guid for the role management policy on the current scope to be updated."
  type        = string
  nullable    = false
}

variable "role_management_policy_guid" {
  description = "(Required) The guid for the role management policy on the current scope to be updated."
  type        = string
  nullable    = false
}


################################################################################
############### Notification-Settings specific variables
################################################################################

variable "notification_type" {
  type        = string
  nullable    = false
  description = "(Required) The notification type. Allowed values are 'active', 'eligible' or 'activation'."

  validation {
    condition     = contains(["eligible", "active", "activation"], var.notification_type)
    error_message = "Allowed values for input_parameter are 'Eligible', 'Activation', or 'Active'."
  }
}

variable "notification_admin" {
  type = object({
    notification_level      = optional(string)       // Default 'False'
    default_recipients      = optional(bool)         // Default 'True'
    notification_recipients = optional(list(string)) // Default 'Empty'
  })
  default     = null
  description = "(Optional) The notifications to admins on activation/assignment."

  validation {
    condition     = var.notification_admin == null ? true : length(setsubtract(keys(var.notification_admin), ["notification_level", "default_recipients", "notification_recipients"])) == 0
    error_message = "Allowed Settings are 'notification_level', 'default_recipients' and 'notification_recipients' "
  }

  validation {
    condition     = var.notification_admin == null ? true : (var.notification_admin.notification_level == null ? true : (can(regex("^(all)$|^(critical)$", lower(var.notification_admin.notification_level)))))
    error_message = "Allowed values for notification levels are 'All', 'Critical'"
  }

}

variable "notification_requestor" {
  type = object({
    notification_level      = optional(string)       // Default 'All'
    default_recipients      = optional(bool)         // Default 'True'
    notification_recipients = optional(list(string)) // Default 'Empty'
  })
  default     = null
  description = "(Optional) The notifications to requestors/assignees on activation/assignment."

  validation {
    condition     = var.notification_requestor == null ? true : length(setsubtract(keys(var.notification_requestor), ["notification_level", "default_recipients", "notification_recipients"])) == 0
    error_message = "Allowed Settings are 'notification_level', 'default_recipients' and 'notification_recipients' "
  }

  validation {
    condition     = var.notification_requestor == null ? true : (var.notification_requestor.notification_level == null ? true : (can(regex("^(all)$|^(critical)$", lower(var.notification_requestor.notification_level)))))
    error_message = "Allowed values for notification levels are 'All', 'Critical'"
  }

}

variable "notification_approver" {
  type = object({
    notification_level      = optional(string)       // Default 'False'
    default_recipients      = optional(bool)         // Default 'True'
    notification_recipients = optional(list(string)) // Default 'Empty'
  })
  default     = null
  description = "(Optional) The notifications to approvers on activation/assignment."


  validation {
    condition     = var.notification_approver == null ? true : length(setsubtract(keys(var.notification_approver), ["notification_level", "default_recipients", "notification_recipients"])) == 0
    error_message = "Allowed Settings are 'notification_level', 'default_recipients' and 'notification_recipients' "
  }

  validation {
    condition     = var.notification_approver == null ? true : (var.notification_approver.notification_level == null ? true : (can(regex("^(all)$|^(critical)$", lower(var.notification_approver.notification_level)))))
    error_message = "Allowed values for notification levels are 'All', 'Critical'"
  }

}
