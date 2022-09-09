locals {

  # Pim assignment on Root Managment Group acfroot-dev/acfroot-prod
  pim_assignments_rbac_mgm_root = {
    "mgm_${var.governance_settings.root_management_group.name}" = {
      assignment_scope = format("/managementGroups/%s", var.governance_settings.root_management_group.name)
      pim_assignments  = var.governance_settings.root_management_group.pim_assignment
    }
  }

  # Pim assignment on Level1/Level2-Management Groups
  pim_assignments_rbac_per_mgm = [
    for mgm_level in values(var.governance_settings.management_groups) :
    {
      for mgm_name, mgm_settings in mgm_level :
      "mgm_${mgm_name}" => {
        assignment_scope = format("/managementGroups/%s", mgm_name)
        pim_assignments  = mgm_settings.pim_assignment
      }
    }
  ]

  # Pim assignment on subscriptions in Foundation
  pim_assignments_rbac_per_subs = {
    for subscription_name, subscription_settings in var.subscriptions :
    "subs_${subscription_name}" => {
      assignment_scope = "/subscriptions/${subscription_settings.id}"
      pim_assignments  = subscription_settings.pim_assignment
    }
  }

  pim_assignments_rbac_all_per_scope = merge(
      local.pim_assignments_rbac_mgm_root,
      local.pim_assignments_rbac_per_subs,
      local.pim_assignments_rbac_per_mgm[*]...
  )
}


