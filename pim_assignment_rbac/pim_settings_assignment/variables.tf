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
############### Assignment-Settings specific variables
################################################################################

variable "schedule_type" {
  type        = string
  nullable    = false
  description = "(Required) The schedule type decides whether an 'active' or 'eligible' assignment gets created."

  validation {
    condition     = contains(["active", "eligible"], var.schedule_type)
    error_message = "Allowed values for input_parameter are 'Eligible', or 'Active'."
  }
}

variable "assignment_schedule" {
  type        = string
  nullable    = false
  description = "(Required) The assignment schedule. Allowed values are 'Disabled', 'Permanent', '# Years', '# Months' or '# Days'."

  validation {
    condition     = can(regex("^(disabled)$|^(permanent)$|^(\\d+ {0,1}days{0,1})$|^(((\\d+[.]\\d+)|(\\d+)) {0,1}((months{0,1})|(years{0,1})))$", lower(var.assignment_schedule)))
    error_message = "Allowed values for input_parameter are 'Disabled', 'Permanent', '# Years', '# Month' or '# Days'."
  }
}



# Rules for active-assignments (justification, mfa) are not changed.
# Only usefull for active-assignments outside of terraform, when settings are managed via Terraform.
# From a practical perspective, Active-Assignments of PIM via Terraform doesn't differ much from normal Role-Assignments.

variable "enablement_rules" {
  type        = list(string)
  nullable    = false
  description = "(Optional) Rules for Enabling Assignment. (Currently disabled option)"
  default     = ["justification"]
  validation {
    condition     = length(setsubtract([for rule in var.enablement_rules : lower(rule)], ["justification", "mfa"])) == 0
    error_message = "Allowed values for input_parameter are 'justification', 'mfa'."
  }
}
