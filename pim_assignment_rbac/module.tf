# Technically settings should be defined seperatly from assignments, since they are general for each assignment
# Currently However we only have on PIM-Role Assignment per Scope, instead of multiple


#############################################################################################
#############   Deploy PIM-Eligible-Assignments-Activation-Settings
#############################################################################################

# Sets the 'Activation-Settings'-Portion in the PIM-Overview
module "pim_settings_activation_elgibile" {
  source = "./pim_settings_activation"

  for_each = {
    for assignment_name, pim_assignment in var.pim_assignments :
    assignment_name => {

      policy_guid            = data.external.role_management_policy_assignment[pim_assignment.role_name_rbac].result.policy_guid
      maximum_duration_hours = pim_assignment.settings_activation.maximum_duration
      required_approvers     = lookup(pim_assignment.settings_activation, "required_approvers", [])
      activation_rules = [
        for rule in pim_assignment.settings_activation.activation_rules :
        coalesce(regex("^(justification)$|^(mfa)$|^(ticketing)$", lower(rule))...)
        # Throws error when not one of: 'mfa', 'justification', 'ticketing'
      ]

      settings_activation_check = [
        for setting in keys(pim_assignment.settings_activation) :
        coalesce(regex("^(maximum_duration)$|^(activation_rules)$|^(required_approvers)$", lower(setting))...)
        # Throws error when not the correct terminology for keys is used. (To Prevent silently not setting of values)
      ]
    }
    if lookup(pim_assignment, "assignment_eligible", null) != null
    # Only set when an elgibile assignment exists
  }

  # Deployment Scope and Role Management Policy GUID
  scope_resource_id           = local.pim_current_scope_resource_id
  role_management_policy_guid = each.value.policy_guid

  # Activation-Settings specific variables.
  maximum_activation_duration   = each.value.maximum_duration_hours
  activation_enablement_rules   = each.value.activation_rules
  activation_required_approvers = each.value.required_approvers

}


#############################################################################################
#############   Deploy PIM-Assignment-Settings (eligible/active)
#############################################################################################

# Sets the 'Assignment-Settings'-Portion in the PIM-Overview for eligible-assignments
module "pim_settings_assignment_eligible" {
  source = "./pim_settings_assignment"

  # Filter out assignments with active enabled.
  for_each = {
    for assignment_name, pim_assignment in var.pim_assignments :
    assignment_name => pim_assignment
    if lookup(pim_assignment, "assignment_eligible", null) != null
  }

  # Deployment Scope and Role Management Policy GUID
  scope_resource_id           = local.pim_current_scope_resource_id
  role_management_policy_guid = data.external.role_management_policy_assignment[each.value.role_name_rbac].result.policy_guid

  # Assignment-Settings specific variables.
  schedule_type       = "eligible"
  assignment_schedule = each.value.assignment_eligible


  depends_on = [
    module.pim_settings_activation_elgibile
  ]
}


# Sets the 'Assignment-Settings'-Portion in the PIM-Overview for active-assignments
module "pim_settings_assignment_active" {
  source = "./pim_settings_assignment"

  # Filter out assignments with active enabled.
  for_each = {
    for assignment_name, pim_assignment in var.pim_assignments :
    assignment_name => pim_assignment
    if lookup(pim_assignment, "assignment_active", null) != null
  }

  # Deployment Scope and Role Management Policy GUID
  scope_resource_id           = local.pim_current_scope_resource_id
  role_management_policy_guid = data.external.role_management_policy_assignment[each.value.role_name_rbac].result.policy_guid

  # Assignment-Settings specific variables.
  schedule_type       = "active"
  assignment_schedule = each.value.assignment_active

  depends_on = [
    module.pim_settings_assignment_eligible
  ]
}


#############################################################################################
#############   Deploy PIM-Notification-Settings
#############################################################################################

locals {

  notifications_elgible = {
    for assignment_name, pim_assignment in var.pim_assignments :
    "${assignment_name}_notification_eligible" => {
      policy_guid = data.external.role_management_policy_assignment[pim_assignment.role_name_rbac].result.policy_guid

      notification_type = "eligible"
      notification_admin = lookup(
        lookup(pim_assignment, "notifications_eligible", lookup(var.pim_defaults, "notifications_eligible", null)),
      "eligible_notice_admin", null)

      notification_requestor = lookup(
        lookup(pim_assignment, "notifications_eligible", lookup(var.pim_defaults, "notifications_eligible", null)),
      "eligible_notice_requestor", null)

      notification_approver = lookup(
        lookup(pim_assignment, "notifications_eligible", lookup(var.pim_defaults, "notifications_eligible", null)),
      "eligible_notice_approver", null)


      notification_settings_check = [
        for notice_eligible in keys(lookup(pim_assignment, "notifications_eligible", var.pim_defaults.notifications_eligible)) :
        coalesce(regex("^(eligible_notice_admin)$|^(eligible_notice_requestor)$|^(eligible_notice_approver)$", lower(notice_eligible))...)
        # Throws error when not the correct terminology for keys is used. (To Prevent silently not setting of values)
      ]
    }
    if lookup(pim_assignment, "notifications_eligible", null) != null || lookup(var.pim_defaults, "notifications_eligible", null) != null
  }

  notifications_activation = {
    for assignment_name, pim_assignment in var.pim_assignments :
    "${assignment_name}_notification_activation" => {
      policy_guid = data.external.role_management_policy_assignment[pim_assignment.role_name_rbac].result.policy_guid

      notification_type = "activation"
      notification_admin = lookup(
        lookup(pim_assignment, "notifications_activation", lookup(var.pim_defaults, "notifications_activation", null)),
      "activation_notice_admin", null)

      notification_requestor = lookup(
        lookup(pim_assignment, "notifications_activation", lookup(var.pim_defaults, "notifications_activation", null)),
      "activation_notice_requestor", null)

      notification_approver = lookup(
        lookup(pim_assignment, "notifications_activation", lookup(var.pim_defaults, "notifications_activation", null)),
      "activation_notice_approver", null)

      notification_settings_check = [
        for notice_activation in keys(lookup(pim_assignment, "notifications_activation", var.pim_defaults.notifications_activation)) :
        coalesce(regex("^(activation_notice_admin)$|^(activation_notice_requestor)$|^(activation_notice_approver)$", lower(notice_activation))...)
        # Throws error when not the correct terminology for keys is used. (To Prevent silently not setting of values)
      ]
    }
    if lookup(pim_assignment, "notifications_activation", null) != null || lookup(var.pim_defaults, "notifications_activation", null) != null
  }

  notifications_active = {
    for assignment_name, pim_assignment in var.pim_assignments :
    "${assignment_name}_notification_active" => {
      policy_guid = data.external.role_management_policy_assignment[pim_assignment.role_name_rbac].result.policy_guid

      notification_type = "active"
      notification_admin = lookup(
        lookup(pim_assignment, "notifications_assignment", lookup(var.pim_defaults, "notifications_assignment", null)),
      "assignment_notice_admin", null)

      notification_requestor = lookup(
        lookup(pim_assignment, "notifications_assignment", lookup(var.pim_defaults, "notifications_assignment", null)),
      "assignment_notice_requestor", null)

      notification_approver = lookup(
        lookup(pim_assignment, "notifications_assignment", lookup(var.pim_defaults, "notifications_assignment", null)),
      "assignment_notice_approver", null)

      notification_settings_check = [
        for notice_active in keys(lookup(pim_assignment, "notifications_assignment", var.pim_defaults.notifications_assignment)) :
        coalesce(regex("^(assignment_notice_admin)$|^(assignment_notice_requestor)$|^(assignment_notice_approver)$", lower(notice_active))...)
        # Throws error when not the correct terminology for keys is used. (To Prevent silently not setting of values)
      ]
    }
    if lookup(pim_assignment, "notifications_assignment", null) != null || lookup(var.pim_defaults, "notifications_assignment", null) != null
  }

  notifications_by_type = merge(
    local.notifications_elgible,
    local.notifications_activation,
    local.notifications_active
  )

}

resource "time_sleep" "wait_10_seconds_settings_notification" {
  triggers = {
    settings = jsonencode(local.notifications_by_type)
  }

  create_duration = "10s"

  depends_on = [
    module.pim_settings_activation_elgibile,
    module.pim_settings_assignment_eligible,
    module.pim_settings_assignment_active
  ]
}

module "pim_settings_notification" {
  source = "./pim_settings_notification"

  for_each = local.notifications_by_type

  # Deployment Scope and Role Management Policy GUID
  scope_resource_id           = local.pim_current_scope_resource_id
  role_management_policy_guid = each.value.policy_guid

  # Notification-Settings specific variables.
  notification_type      = each.value.notification_type
  notification_admin     = each.value.notification_admin
  notification_requestor = each.value.notification_requestor
  notification_approver  = each.value.notification_approver

  depends_on = [
    time_sleep.wait_10_seconds_settings_notification
  ]
}


#############################################################################################
#############   Deploy PIM-Assignments (eligible/active)
#############################################################################################

resource "time_sleep" "wait_20_seconds_pim_assignments" {
  triggers = {
    settings = jsonencode(local.notifications_by_type)
  }

  create_duration = "20s"

  depends_on = [
    module.pim_settings_notification
  ]
}


locals {
  pim_assignments = {
    for assignment_name, pim_assignment in var.pim_assignments :
    assignment_name => merge(pim_assignment, {
      assignment_members_eligible = flatten(concat(var.default_group_members, var.default_group_members_eligible, lookup(pim_assignment, "assignment_members_eligible", [])))
      assignment_members_active   = flatten(concat(var.default_group_members, var.default_group_members_eligible, lookup(pim_assignment, "assignment_members_active", [])))
    })
  }
}
module "pim_assignment_eligible" {
  source = "./pim_assignment_rbac"

  # Filter out assignments with eligible enabled.
  for_each = {
    for assignment_name, pim_assignment in local.pim_assignments :
    assignment_name => pim_assignment
    if lookup(pim_assignment, "assignment_eligible", null) != null && (var.enable_manual_member_group || length(pim_assignment.assignment_members_eligible) > 0)
  }

  # Deploys all Eligible assignments on various scopes.
  schedule_type = "eligible"

  assignment_name          = each.key
  assignment_scope         = var.assignment_scope
  assignment_schedule      = each.value.assignment_eligible
  assignment_group_members = each.value.assignment_members_eligible

  assignment_scope_name      = data.external.role_management_policy_assignment[each.value.role_name_rbac].result.assignment_scope_name
  role_definition_name       = data.external.role_management_policy_assignment[each.value.role_name_rbac].result.role_definition_name
  role_definition_id         = data.external.role_management_policy_assignment[each.value.role_name_rbac].result.role_definition_id
  aad_group_owner_ids        = var.aad_group_owner_ids
  enable_manual_member_group = var.enable_manual_member_group

  depends_on = [
    time_sleep.wait_20_seconds_pim_assignments
  ]
}

module "pim_assignment_active" {
  source = "./pim_assignment_rbac"

  # Filter out assignments with active enabled.
  for_each = {
    for assignment_name, pim_assignment in local.pim_assignments :
    assignment_name => pim_assignment
    if lookup(pim_assignment, "assignment_active", null) != null && (var.enable_manual_member_group || length(pim_assignment.assignment_members_active) > 0)
  }

  # Deploys all Active assignments on various scopes.
  schedule_type = "active"

  assignment_name          = each.key
  assignment_scope         = var.assignment_scope
  assignment_schedule      = each.value.assignment_active
  assignment_group_members = each.value.assignment_members_active

  assignment_scope_name      = data.external.role_management_policy_assignment[each.value.role_name_rbac].result.assignment_scope_name
  role_definition_name       = data.external.role_management_policy_assignment[each.value.role_name_rbac].result.role_definition_name
  role_definition_id         = data.external.role_management_policy_assignment[each.value.role_name_rbac].result.role_definition_id
  aad_group_owner_ids        = var.aad_group_owner_ids
  enable_manual_member_group = var.enable_manual_member_group

  depends_on = [
    time_sleep.wait_20_seconds_pim_assignments
  ]
}
