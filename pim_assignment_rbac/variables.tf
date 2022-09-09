variable "assignment_scope" {
  type        = string
  description = "(Required) The assignment scope of from '/managementGroups/{management-group-name}' or '/subscriptions/{subscription-name}/...'"
}

variable "aad_group_owner_ids" {
  type        = list(string)
  description = "(Required) List of Ids set as owner to the created AAD Groups."
}


variable "pim_defaults" {
  description = "(Optional) Default Configuration applied to all PIM-Settings if not specifed otherwise. (Settings not specifed here or in assignment remain as Azure Defaults)"
  default = {
    notifications_eligible = {
      eligible_notice_admin = {
        default_recipients = true
        notification_level = "Critical"
        notification_recipients = []
      }
      eligible_notice_requestor = {
        default_recipients = true
        notification_level = "All"
        notification_recipients = []
      }
      eligible_notice_approver = {
        default_recipients = true
        notification_level = "All"
        notification_recipients = []
      }
    }

    notifications_activation = {
      activation_notice_admin = {
        default_recipients = true
        notification_level = "Critical"
        notification_recipients = []
      }
    }
  }
  type = object({
      notifications_eligible = optional(object({
        eligible_notice_admin = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address   
        }))
        eligible_notice_requestor = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
        eligible_notice_approver = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
      }))

      notifications_assignment = optional(object({
        assignment_notice_admin = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address   
        }))
        assignment_notice_requestor = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
        assignment_notice_approver = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
      }))

      notifications_activation = optional(object({
        activation_notice_admin = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address   
        }))
        activation_notice_requestor = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
        activation_notice_approver = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
      }))
  })
}

variable "pim_assignments" {
  /*
  type = object({
    "string" = object({
      role_name_rbac = string

      assignment_eligible = optional(string)
      assignment_active   = optional(string)

      settings_activation = optional(object({
         maximum_duration = optional(string)  // "# hours"
         activation_rules = optional(list(string)) // ["Justification", "MFA", "Ticketing"]
         required_approvers = optional(list(string)) // user_principal_name
      }))

      notifications_eligible = optional(object({
        eligible_notice_admin = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address   
        }))
        eligible_notice_requestor = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
        eligible_notice_approver = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
      }))

      notifications_assignment = optional(object({
        assignment_notice_admin = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address   
        }))
        assignment_notice_requestor = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
        assignment_notice_approver = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
      }))

      notifications_activation = optional(object({
        activation_notice_admin = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address   
        }))
        activation_notice_requestor = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
        activation_notice_approver = optional(object({
            notification_level      = optional(string)  // "All" | "Critical"
            default_recipients      = optional(bool)
            notification_recipients = optional(list(string))  // Mail-Address 
        }))
      }))

    })
  })
  */

  description = "(Required) List of PIM-Assignments on the current scope."
}
