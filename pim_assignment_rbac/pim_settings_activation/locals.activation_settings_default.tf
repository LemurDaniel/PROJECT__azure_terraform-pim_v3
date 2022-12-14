
locals {

  settings_activation_default = {

    Expiration_EndUser_Assignment = {
      id                   = "Expiration_EndUser_Assignment"
      isExpirationRequired = true
      maximumDuration      = "PT8H"
      ruleType             = "RoleManagementPolicyExpirationRule"
      Target = {
        caller = "EndUser"
        level  = "Assignment"
        operations = [
          "All"
        ]
      }
    }

    Enablement_EndUser_Assignment = {
      enabledRules = [
        "Justification"
      ]
      id       = "Enablement_EndUser_Assignment"
      ruleType = "RoleManagementPolicyEnablementRule"
      target = {
        caller = "EndUser"
        level  = "Assignment"
        operations = [
          "All"
        ]
      }
    }

    Approval_EndUser_Assignment = {
      id       = "Approval_EndUser_Assignment"
      ruleType = "RoleManagementPolicyApprovalRule"
      setting = {
        isApprovalRequired               = false
        isApprovalRequiredForExtension   = false
        isRequestorJustificationRequired = true
        approvalMode                     = "SingleStage"
        approvalStages = [
          {
            approvalStageTimeOutInDays      = 1
            escalationTimeInMinutes         = 0
            isApproverJustificationRequired = true
            isEscalationEnabled             = false
          }
        ]
      }
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
