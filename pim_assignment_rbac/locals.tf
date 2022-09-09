
locals {


  # The current deployment scope of pim: Managment Group, Subscription, Resource Group or Resource
  pim_possible_scopes_checks = {
    management_group = can(regex("^/managementgroups/[^/]+$", lower(var.assignment_scope)))
    subscription     = can(regex("^/subscriptions/[^/]+$", lower(var.assignment_scope)))
    resource_group   = can(regex("^/subscriptions/[^/]+/resourcegroups/[^/]+$", lower(var.assignment_scope)))
    resources        = can(regex("^/subscriptions/[^/]+/resourcegroups/[^/]+/providers/[^/]+/[^/]+/[^/]+$", lower(var.assignment_scope)))
  }

  /*
  Scopes for testing regex:
  /providers/microsoft.management/managementgroups/{management-group-name}
  /subscription/{subscription-id}"
  /subscription/{subscription-id}/resourcegroups/{resource-group-name}
  /subscription/{subscription-id}/resourcegroups/{resource-group-name}/providers/{resource-provider}/{resource-type}/{resource-name}"
  */

  # Toplevel provider for current scope.
  pim_provdiers_for_scopes = {
    management_group = format("/providers/Microsoft.Management%s", var.assignment_scope)
    subscription     = format("/providers/Microsoft.Subscription%s", var.assignment_scope)
    resource_group   = format("/providers/Microsoft.Subscription%s", var.assignment_scope)
    resources        = format("/providers/Microsoft.Subscription%s", var.assignment_scope)
  }


  pim_current_scope_type = matchkeys(
    keys(local.pim_possible_scopes_checks),
    values(local.pim_possible_scopes_checks),
    [true] # Matchkeys whose regex is true. Only one regex should evaluate to true.
  )[0]


  pim_current_scope_resource_id = local.pim_provdiers_for_scopes[local.pim_current_scope_type]

  # Hardcode the result from API-Call as JSON-File? Not possible/impractical for every Scope.
  #management_policy_assignments_url = format("https://management.azure.com/%s/providers/Microsoft.Authorization/roleManagementPolicyAssignments?$filter=name+eq+'5ac2d408-a58d-408c-aa3b-615f29fb3047_12338af0-0e69-4776-bea7-57ae8d297424'&api-version=2020-10-01", local.pim_current_scope_resource_id)
  management_policy_assignments_url = format("https://management.azure.com/%s/providers/Microsoft.Authorization/roleManagementPolicyAssignments?api-version=2020-10-01", local.pim_current_scope_resource_id)
  temporary_response_file_name      = "${path.module}/.static/${replace(lower(var.assignment_scope), "/", "_")}.json"
}

/*

  List all assignments on the current scope since:
    1. Current API can't get a assignment or management policy on current scope for certain role
    2. Current API doesn't allow creation of a complete new role_management_policy

*/

/*
resource "null_resource" "management_policy_assignments_by_scope" {

  triggers = {
    test             = 1
    assignment_scope = jsonencode(var.assignment_scope)
    pim_assignments  = jsonencode(var.pim_assignments) # Call for each pim assignment config, to reduce API-Calls?

  }
  provisioner "local-exec" {
    command = "az rest --method GET --url ${local.management_policy_assignments_url} > ${local.temporary_response_file_name}"
  }

}
data "local_file" "management_policy_assignments_by_scope" {
  filename = local.temporary_response_file_name

  depends_on = [
    #null_resource.management_policy_assignments_by_scope
  ]
}
*/

locals {
  mgm_assig_by_role = {
    for management_policy_assignments in jsondecode(file(local.temporary_response_file_name))[*] :
    "${management_policy_assignments.properties.policyAssignmentProperties.roleDefinition.displayName}" => {
      id             = management_policy_assignments.id
      type           = management_policy_assignments.type
      name           = management_policy_assignments.name

      policy_guid    = split("/", management_policy_assignments.properties.policyAssignmentProperties.policy.id)[length(split("/", management_policy_assignments.properties.policyAssignmentProperties.policy.id)) - 1]
      
      role_definition  = management_policy_assignments.properties.policyAssignmentProperties.roleDefinition
      assignment_scope_name = lookup(management_policy_assignments.properties.policyAssignmentProperties.scope, "displayName", split("/", var.assignment_scope)[length(split("/", var.assignment_scope))-1])

      current_effective_rules = {
        for effective_rule in management_policy_assignments.properties.effectiveRules :
        effective_rule.id => effective_rule
      }
    }
  }

  # management_policy_rules_default = jsondecode(file(abspath("${path.module}/.role_management_policy_default.json")))
}
