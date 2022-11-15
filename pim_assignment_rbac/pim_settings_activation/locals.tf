
locals {

  pim_role_management_policy_url_base = "https://management.azure.com/%s/providers/Microsoft.Authorization/roleManagementPolicies/%s?api-version=2020-10-01"

  management_policy_rules_default = local.settings_activation_default  #jsondecode(file("${path.module}/.activation_settings_default.json"))


  #####################################################################################################
  ##############  Settings for Activation Duration of Eligible Assignments
  #####################################################################################################

  activation_duration_value = tonumber(coalesce(regex("(\\d+.\\d+)|(\\d+)", var.maximum_activation_duration)...))
  activation_duration_hours = floor(local.activation_duration_value)
  activation_duration_minutes = floor((local.activation_duration_value % 1) * 60)
  activation_duration_rule = {

    isExpirationRequired = true
    maximumDuration      = format("PT%sH%sM", local.activation_duration_hours, local.activation_duration_minutes)
    id                   = "Expiration_EndUser_Assignment"
    ruleType             = "RoleManagementPolicyExpirationRule"
    target = {
      caller = "EndUser"
      operations = [
        "All"
      ]
      level               = "Assignment"
      #targetObjects       = null
      #inheritableSettings = null
      #enforcedSettings    = null
    }
  }


  #####################################################################################################
  ##############  Settings for Activation Rules of Eligible Assignments
  #####################################################################################################

  enablement_rules_lookup = {
    "mfa"           = "MultiFactorAuthentication",
    "justification" = "Justification"
    "ticketing"     = "Ticketing"
  }

  activation_enablement_rules = [
    for rule in var.activation_enablement_rules :
    local.enablement_rules_lookup[lower(rule)]
  ]

  activation_enablement_rule = {
    enabledRules = local.activation_enablement_rules
    id           = "Enablement_EndUser_Assignment"
    ruleType     = "RoleManagementPolicyEnablementRule"
    target = {
      caller = "EndUser"
      level  = "Assignment"
      operations = [
        "All"
      ]
      #targetObjects       = null
      #inheritableSettings = null
      #enforcedSettings    = null
    }
  }


  #####################################################################################################
  ##############  Settings for Activation Approvers of Eligible Assignments
  #####################################################################################################

  activation_approvers_rule = {
    id       = "Approval_EndUser_Assignment"
    ruleType = "RoleManagementPolicyApprovalRule"
    setting = {
      isApprovalRequired               = length(var.activation_required_approvers) > 0
      isApprovalRequiredForExtension   = false
      isRequestorJustificationRequired = true
      approvalMode                     = "SingleStage"
      approvalStages = [
        {
          approvalStageTimeOutInDays      = 1
          isApproverJustificationRequired = true
          isEscalationEnabled             = false
          escalationApprovers             = null
          escalationTimeInMinutes         = 0
          primaryApprovers = flatten([
            [
              for required_approver in data.azuread_user.on_activation_required_approvers :
              {
                id          = required_approver.id
                description = replace("User - ${required_approver.display_name}", " ", "_") #TODO Spaces causing errors with az API-Request
                isBackup    = false
                userType    = "User"
              }
            ],
            [
              for required_approver in data.azuread_group.on_activation_required_approvers :
              {
                id          = required_approver.id
                description = replace("Group - ${required_approver.display_name}", " ", "_") #TODO Spaces causing errors with az API-Request
                isBackup    = false
                userType    = "Group"
              }
            ]
          ])
        }
      ]
    }
    target = {
      caller = "EndUser"
      operations = [
        "All"
      ],
      level               = "Assignment"
      #targetObjects       = null
      #inheritableSettings = null
      #enforcedSettings    = null
    }
  }


  #####################################################################################################
  ##############  Creating Request Bodies
  #####################################################################################################

  activation_rule_request_body_custom = jsonencode({
    properties = {
      rules = [
        local.activation_enablement_rule,       
        local.activation_duration_rule,
        local.activation_approvers_rule
      ]
    }
  })

  # Reset to Azure Default Values on Destroy.
  activation_rule_request_body_default = jsonencode({
    properties = {
      rules = [
        local.management_policy_rules_default["Expiration_EndUser_Assignment"],
        local.management_policy_rules_default["Enablement_EndUser_Assignment"],
        local.management_policy_rules_default["Approval_EndUser_Assignment"]
      ]
    }
  })
}

