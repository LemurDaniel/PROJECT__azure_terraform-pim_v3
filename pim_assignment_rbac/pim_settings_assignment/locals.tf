
locals {

  pim_role_management_policy_url_base = "https://management.azure.com/%s/providers/Microsoft.Authorization/roleManagementPolicies/%s?api-version=2020-10-01"

  management_policy_rules_default = local.settings_assignment_default #jsondecode(file("${path.module}/.assignment_settings_default.json"))
  role_managment_rule_level = {
    eligible = "Eligibility"
    active   = "Assignment"
  }

  expiration_request_id = format("Expiration_Admin_%s", local.role_managment_rule_level[var.schedule_type])
  enablement_request_id = format("Enablement_Admin_%s", local.role_managment_rule_level[var.schedule_type])


  #####################################################################################################
  ##############  Expiration-Settings for Assignments
  #####################################################################################################

  is_expiration_permanent = lower(var.assignment_schedule) == "permanent"
  is_expiration_disabled  = lower(var.assignment_schedule) == "disabled"
  is_expiration_scheduled = local.is_expiration_permanent == false && local.is_expiration_disabled == false

  expiration_value = local.is_expiration_scheduled ? coalesce(regex("(\\d+[.]\\d+)|(\\d+)", lower(var.assignment_schedule))...) : 365000 # regex filter out int, or float | else set to 1000 years.
  expiration_type  = local.is_expiration_scheduled ? coalesce(regex("(day)|(month)|(year)", lower(var.assignment_schedule))...) : "day"
  expiration_days = {
    year  = floor(local.expiration_value * 365)
    month = floor(local.expiration_value * 30) # If 31 Days * 3 => Azure Portal will show '3 Months + 3 Days'
    day   = floor(local.expiration_value)
  }

  expiration_rule_custom = {

    isExpirationRequired = local.is_expiration_scheduled
    maximumDuration      = "P${local.expiration_days[local.expiration_type]}D"
    id                   = local.expiration_request_id,
    ruleType             = "RoleManagementPolicyExpirationRule"
    target = {
      caller = "Admin"
      operations = [
        "All"
      ],
      level               = local.role_managment_rule_level[var.schedule_type]
      targetObjects       = null
      inheritableSettings = null
      enforcedSettings    = null
    }

  }

  #####################################################################################################
  ##############  Enablement-Settings for Assignments
  #####################################################################################################
  enablement_rules_lookup = {
    "mfa"           = "MultiFactorAuthentication",
    "justification" = "Justification"
  }

  enablement_requirements_rules = [
    for rule in var.enablement_rules :
    local.enablement_rules_lookup[lower(rule)]
  ]

  enablement_rule_custom = {

    enabledRules = local.enablement_requirements_rules
    id           = local.enablement_request_id
    ruleType     = "RoleManagementPolicyEnablementRule"
    target = {
      caller = "Admin"
      level  = local.role_managment_rule_level[var.schedule_type]
      operations = [
        "All"
      ]
    }
  }

}

