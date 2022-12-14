
locals {

  settings_assignment_default = {

    Expiration_Admin_Eligibility = {
      id                   = "Expiration_Admin_Eligibility"
      isExpirationRequired = true
      maximumDuration      = "P365D"
      ruleType             = "RoleManagementPolicyExpirationRule"
      target = {
        caller = "Admin"
        level  = "Eligibility"
        operations = [
          "All"
        ]
      }
    }

    Enablement_Admin_Eligibility = {
      enabledRules = []
      id           = "Enablement_Admin_Eligibility"
      ruleType     = "RoleManagementPolicyEnablementRule"
      target = {
        caller = "Admin"
        level  = "Eligibility"
        operations = [
          "All"
        ]
      }
    }

    Expiration_Admin_Assignment = {
      id                   = "Expiration_Admin_Assignment"
      isExpirationRequired = true
      maximumDuration      = "P180D"
      ruleType             = "RoleManagementPolicyExpirationRule"
      target = {
        caller = "Admin"
        level  = "Assignment"
        operations = [
          "All"
        ]
      }
    }
    
    Enablement_Admin_Assignment = {
      enabledRules = [
        "Justification"
      ]
      id       = "Enablement_Admin_Assignment"
      ruleType = "RoleManagementPolicyEnablementRule"
      target = {
        caller = "Admin"
        level  = "Assignment"
        operations = [
          "All"
        ]
      }
    }

  }
}
