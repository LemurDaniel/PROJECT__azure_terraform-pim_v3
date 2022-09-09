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
############### Activation-Settings specific variables
################################################################################

variable "maximum_activation_duration" {
  description = "(Required) In hours - Refers to the PIM-Setting: 'Activation maximum duration'"
  nullable    = false
  validation {
    condition     = can(regex("^((\\d+.[05])|(\\d))+ {0,1}hours{0,1}$", lower(var.maximum_activation_duration)))
    error_message = "Value must be entered as '# Hours', '#.0 Hours' or '#.5 Hours'."
  }
}

variable "activation_enablement_rules" {
  type        = list(string)
  nullable    = false
  description = "(Required) Rules for Activation of Eligible-Assignments."

  validation {
    condition     = length(setsubtract([for rule in var.activation_enablement_rules : lower(rule)], ["justification", "ticketing", "mfa"])) == 0
    error_message = "Allowed values for input_parameter are 'Justification', 'MFA' and 'Ticketing'."
  }
}

variable "activation_required_approvers" {
  description = "(Optional) Defaults to 'Empty List' - Refers to the PIM-Setting: 'Require Approval to Activate'"
  nullable    = false
  default     = []
}
