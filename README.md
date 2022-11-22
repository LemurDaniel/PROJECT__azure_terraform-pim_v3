## Implementation of a PIM_v3-Deployment with Settings for Azure via Terraform
Got good feedback from Teamlead and meant I'm allowed to share it on my personal git, so leaving it here.

Currenlty PIM isnt't supported by azurerm, so null_resources are used to make API-Calls.

Credits: Teamlead [Bartosz Kubiack](https://www.linkedin.com/mwlite/in/bartoszkubiak-it)
for Providing helpful Resources and Feedback.

Note: 
This module only supports PIM for RBAC-Roles, as of no requirement for manageing AD-Roles via Terraform, as of yet.

### Module Usage:

- The module assigns PIM-Roles with corresponding settings on a scope defined by `assignment_scope`. This value can be of Form:
   - `managementGroups/<management_group_name>`
   - `/subscriptions/<subscription_name>`
   - `/subscriptions/<subscription_name>/resourceGroups/<resource_group_name>`
   - `/subscriptions/<subscription_name>/resourceGroups/<resource_group_name>/providers/<provider_name>/<resource_name>`

- For each PIM-Assignment a corresponding Azure AAD Group gets created with naming `acf_pimv3_<scope_type>_<scope_name>_<assignment_name>_<schedule_type>__BASE` and `aad_group_owner_ids` defines the owners of said groups.

- When `enable_manual_member_group` is true another AAD with naming `acf_pimv3_<scope_type>_<scope_name>_<assignment_name>_<schedule_type>__ManualMembers` gets created for assigning non-terraform managed members. (For example Manually or via Access Packages, etc.)

- All PIM-Assignments for that specific scope are defined under the key `pim_assignments`.


It's meant to use a for_each to iterate over all different scopes with defined PIM-Assignments. So the terraform object for each scope should look like this:



```terraform

locals {
   pim_assignments_rbac_all_per_scope = {
    mgm_solution = {
      assignment_scope = "managementGroups/solution"
      pim_assignments = {
        // .
        // .
        // .
      }
    }

    mgm_sandbox = {
      assignment_scope = "managementGroups/sandbox"
      pim_assignments = {
        // .
        // .
        // .
      }
    }
  }
}


module "pim_assignment_rbac" {
  source = "./pim_assignment_rbac"

  for_each = {
    for scope_name, scope_config in local.pim_assignments_rbac_all_per_scope :
    scope_name => scope_config
   if length(values(scope_config.pim_assignments)) > 0
  }

  assignment_scope    = each.value.assignment_scope
  pim_assignments     = each.value.pim_assignments
  aad_group_owner_ids = [data.azurerm_client_config.current.object_id]

  enable_manual_member_group      = [] (optional)
  default_group_members           = [] (optional)
  default_group_members_eligible  = [] (optional)
  default_group_members_active    = [] (optional)
  pim_defaults = {} (optional)
}

```



## Defining a PIM-Assignment on a Scope

PIM-Assignments are defined for each scope under pim_assigments as follows:

```terraform

locals {
  pim_assignments_rbac_all_per_scope = {
    mgm_sandbox = {
      assignment_scope = "managementGroups/sandbox"
      pim_assignments = {
        "<assignment_name>" = {
          role_name_rbac      = "<rbac_role_name_for_pim"
          assignment_eligible = "<Null | Disabled | Permanent | #/#.# Year(s) | #/#.# Month(s) | #/#.# Day(s)" // Assignment length for eligible assignments
          assignment_active   = "<Null | Disabled | Permanent | #/#.# Year(s) | #/#.# Month(s) | #/#.# Day(s)" // Assignment length for active assignments (can be 1 Month(s) or 1.5 Month(s), etc.)
          
          assignment_members_eligible = ["user_principal_name", "aad_group_name", "obejct_id"]
          assignment_members_active   = ["user_principal_name", "aad_group_name", "obejct_id"]

          settings_activation = {
            maximum_duration   = "<0.5-24 Hour(s)"                     // Maximum Activation length for eligible assignment activations
            activation_rules   = ["Justification", "Ticketing", "MFA"] // Activation Rules for eligible assignment activations
            required_approvers = []                                    // Email_list|aad_group_names of additional required approvers
          }
        }

        "DNSZoneContrib" = {
          role_name_rbac      = "DNS Zone Contributor"
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

```




## Adusting Settings for PIM-Assignemnt

- As alread defined in the upper Module, several adjustments can be made to PIM-Assignments. Since the Relationship between PIM-Settings and Assignemnts per Scope is as Such: Each Scope has ONE-Set of Settings for Each RBAC-Role, but can have multiple assignments for Each RBAC-Role. So for other use cases it might be sensible to extract the Modules for PIM-settings of the Current Implementation to another custom Module.

- Additional Settings are defined in the same PIM-Assignments Blocks as optional-Keys. Leaving them out will either deploy any predefined defaults under `pim_defaults` or make no changes to those settings.



```terraform

locals {
  pim_assignments_rbac_all_per_scope = {
    mgm_sandbox = {
      assignment_scope = "managementGroups/sandbox"
      pim_assignments = {
        "<assignment_name>" = {
          role_name_rbac      = "<rbac_role_name_for_pim"
          assignment_eligible = "<Null | Disabled | Permanent | #/#.# Year(s) | #/#.# Month(s) | #/#.# Day(s)" // Assignment length for eligible assignments
          assignment_active   = "<Null | Disabled | Permanent | #/#.# Year(s) | #/#.# Month(s) | #/#.# Day(s)" // Assignment length for active assignments (can be 1 Month(s) or 1.5 Month(s), etc.)

          assignment_members_eligible = ["user_principal_name", "aad_group_name", "obejct_id"]
          assignment_members_active   = ["user_principal_name", "aad_group_name", "obejct_id"]

          settings_activation = {
            maximum_duration   = "<0.5-24 Hour(s)"                     // Maximum Activation length for eligible assignment activations
            activation_rules   = ["Justification", "Ticketing", "MFA"] // Activation Rules for eligible assignment activations
            required_approvers = []                                    // Email_list|aad_group_names of additional required approvers
          }

          notifications_eligible = {
            eligible_notice_admin = {
              default_recipients      = "true|false"
              notification_level      = "All|Critical"
              notification_recipients = []
            }
            eligible_notice_requestor = {
              default_recipients      = "true|false"
              notification_level      = "All|Critical"
              notification_recipients = []
            }
            eligible_notice_approver = {
              default_recipients      = "true|false"
              notification_level      = "All|Critical"
              notification_recipients = []
            }
          }

          notifications_activation = {
            activation_notice_admin = {
              default_recipients      = "true|false"
              notification_level      = "All|Critical"
              notification_recipients = []
            }
            activation_notice_requestor = {
              default_recipients      = "true|false"
              notification_level      = "All|Critical"
              notification_recipients = []
            }
            activation_notice_approver = {
              default_recipients      = "true|false"
              notification_level      = "All|Critical"
              notification_recipients = []
            }
          }

          notifications_assignment = {
            assignment_notice_admin = {
              default_recipients      = "true|false"
              notification_level      = "All|Critical"
              notification_recipients = []
            }
            assignment_notice_requestor = {
              default_recipients      = "true|false"
              notification_level      = "All|Critical"
              notification_recipients = []
            }
            assignment_notice_approver = {
              default_recipients      = "true|false"
              notification_level      = "All|Critical"
              notification_recipients = []
            }
          }
        }
      }
    }
  }
}

```

