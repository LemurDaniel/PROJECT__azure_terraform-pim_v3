
/*
resource "azurerm_management_group" "root" {
  display_name = "acfroot"
  name         = "acfroot"
}

resource "azurerm_management_group" "management" {
  display_name               = "management"
  name                       = "management-test"
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "solution" {
  display_name               = "solution"
  name                       = "solution-test"
  parent_management_group_id = azurerm_management_group.root.id
}

resource "azurerm_management_group" "sandbox" {
  display_name               = "sandbox"
  name                       = "sandbox-test"
  parent_management_group_id = azurerm_management_group.root.id
}
*/



locals {

  pim_assignments_rbac_all_per_scope = {
    "acfroot" = {
      assignment_scope = "/managementGroups/acfroot"
      pim_assignments = {
        "DNSZoneContrib" = {
          role_name_rbac      = "DNS Zone Contributor"
          assignment_eligible = "Permanent"
          settings_activation = {
            maximum_duration = "1 Hours"
            activation_rules = ["Justification", "MFA"]
          }


          notifications_eligible = {
            eligible_notice_admin = {
              default_recipients = true
              notification_level = "All"
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
              notification_level = "All"
              notification_recipients = []
            }
          }
        }
        "DNSPrivZoneContrib" = {
          role_name_rbac      = "Private DNS Zone Contributor"
          assignment_eligible = "Permanent"
          settings_activation = {
            maximum_duration = "1 Hours"
            activation_rules = ["Justification", "MFA"]
          }
        }
        "BackupContrib" = {
          role_name_rbac      = "Backup Contributor"
          assignment_eligible = "Permanent"
          settings_activation = {
            maximum_duration = "1 Hours"
            activation_rules = ["Justification", "MFA"]
          }
        }
        "BackupOperator" = {
          role_name_rbac      = "Backup Operator"
          assignment_eligible = "Permanent"
          settings_activation = {
            maximum_duration = "3 Hours"
            activation_rules = ["Justification", "MFA"]
          }
        }
        "SAContrib" = {
          role_name_rbac      = "Storage Account Contributor"
          assignment_eligible = "Permanent"
          settings_activation = {
            maximum_duration = "3 Hours"
            activation_rules = ["Justification", "MFA"]
          }
        }
        "VMContrib" = {
          role_name_rbac      = "Virtual Machine Contributor"
          assignment_eligible = "Permanent"
          settings_activation = {
            maximum_duration = "1 Hours"
            activation_rules = ["Justification", "MFA"]
          }
        }
        "QuotaReqOp" = {
          role_name_rbac      = "Quota Request Operator"
          assignment_eligible = "Permanent"
          settings_activation = {
            maximum_duration = "1 Hours"
            activation_rules = ["Justification", "MFA"]
          }
        }
        "MgmtGrpContrib" = {
          role_name_rbac      = "Management Group Contributor"
          assignment_eligible = "Permanent"
          settings_activation = {
            maximum_duration = "1 Hours"
            activation_rules = ["Justification", "MFA"]
          }
        }
        "Contrib" = {
          role_name_rbac      = "Contributor"
          assignment_eligible = "Permanent"
          settings_activation = {
            maximum_duration = "1 Hours"
            activation_rules = ["Justification", "MFA"]
          }
        }
        "SAContribBlobData" = {
          role_name_rbac      = "Storage Blob Data Contributor"
          assignment_eligible = "Permanent"
          settings_activation = {
            maximum_duration = "1 Hours"
            activation_rules = ["Justification", "MFA"]
          }
        }
      }
    }
  }
}

data "azurerm_client_config" "current" {}


module "pim_assignment_rbac" {
  source = "./pim_assignment_rbac"

  for_each = {
    for scope_name, scope_config in local.pim_assignments_rbac_all_per_scope :
    scope_name => scope_config
    if length(values(scope_config.pim_assignments)) > 0
  }

  assignment_scope = each.value.assignment_scope
  pim_assignments  = each.value.pim_assignments
  aad_group_owner_ids   = [data.azurerm_client_config.current.object_id]
}



/*
Map of Objects in following pattern required:
{

  "mgm_name" = {
    assignment_scope = "/managementGroups/..."
    pim_assignments = {
      
    }
  }

  "mgm_name2" = {
    assignment_scope = "/managementGroups/{management-group-name}"
    pim_assignments = {
      
    }
  }

  "subs_name1" = {
    assignment_scope = "/subscription/{subscription-id}"
    pim_assignments = {
      
    }
  }

  # Extendable, but not used in Future. Only MGM- and SUBS-Level.
  "rg_name1" = {
    assignment_scope = "/subscription/{subscription-id}/resourceGroups/{resource-group-name}"
    pim_assignments = {
      
    }
  }

  "res_name1" = {
    assignment_scope = "/subscription/{subscription-id}/resourceGroups/{resource-group-name}/providers/{resource-provider}/{resource-type}/{resource-name}"
    pim_assignments = {
      
    }
  }
}


*/
