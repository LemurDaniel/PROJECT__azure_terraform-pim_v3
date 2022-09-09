

variable "assignment_name" {
  type        = string
  nullable    = false
  description = "(Required) The name of the PIM-Assignment, used in the AD-Group Naming."
}

variable "assignment_scope" {
  type        = string
  nullable    = false
  description = "(Required) The assignment scope of from '/managementGroups/{management-group-name}' or '/subscriptions/{subscription-name}/...'"
}

variable "assignment_scope_name" {
  type        = string
  default     = null
  description = "(Optional) Name of the assignment Scope. (Important for Subscriptions to use DisplayName instead of Subsription Id) "
}

variable "aad_group_owner_ids" {
  type        = list(string)
  description = "(Required) List of Ids set as owner to the created AAD Groups."
}


#################

variable "role_definition" {
  type        = object({
    id = string
    displayName = string
  })
  nullable    = false
  description = "(Required) The RBAC-Roledefinition"
}

variable "assignment_schedule" {
  type    = string
  default = null
  description = "(Optional) The assignment schedule. Allowed values  are 'Null', 'Disabled', 'Permanent', '# Years', '# Months' or '# Days'. 'Disabled' => AD-Group Persists with no Assignment. 'Null' => Neither AD-Group or Assignment remains."

  validation {
    condition     = var.assignment_schedule == null || can(regex("^(disabled)$|^(permanent)$|^(\\d+ {0,1}days{0,1})$|^(((\\d+[.]\\d+)|(\\d+)) {0,1}((months{0,1})|(years{0,1})))$", lower(var.assignment_schedule)))
    error_message = "Allowed values for input_parameter are 'Null', 'Disabled', 'Permanent', '# Years', '# Months'  or '# Days'."
  }
}

variable "schedule_type" {
  type        = string
  nullable    = false
  description = "(Required) The schedule type decides whether an 'active' or 'eligible' assignment gets created."

  validation {
    condition     = contains(["active", "eligible"], var.schedule_type)
    error_message = "Allowed values for input_parameter are 'Eligible', or 'Active'."
  }
}
