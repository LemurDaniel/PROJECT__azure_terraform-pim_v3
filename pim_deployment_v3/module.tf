


# Use for_each on submodule for easier code.
# Iterates over all scopes with pim_assignments
# Map of Scopes required to look as below.
# Theoratically extendable to all scopes from Mgm to resource.
module "pim_assignment_rbac" {
  source = "./pim_assignment_rbac"

  for_each = {
    for scope_name, scope_config in local.pim_assignments_rbac_all_per_scope :
    scope_name => scope_config
    if length(values(scope_config.pim_assignments)) > 0
  }

  assignment_scope = each.value.assignment_scope
  pim_assignments  = each.value.pim_assignments
  aad_group_owner_ids   = var.aad_group_owner_ids
}


# TODO NOTE
# Each Scope gets its own ad group
# Maybe add different resources in same scope_level (like subscription) to same ad_group???
# As of only one group per scope.

/*
Map of Objects in following pattern gets created:
{

  "mgm_name" = {
    assignment_scope = "/managementGroups/..."
    pim_assignments = {
      "QuotaReqOp" = {
          role_name_rbac = "Quota Request Operator"
          settings = {
            maximumGrantPeriodInMinutes = "60"
            requireMFA                  = true
            requireJustification        = true
            notifications = {
              membersAssignmentEligableRole = {}
              membersAssignmentActiveRole   = {}
              membersActivateRole           = {}
            }
          }
        }
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
