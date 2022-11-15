
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


  management_policy_assignments_base_url = "https://management.azure.com/{0}/providers/Microsoft.Authorization/roleManagementPolicyAssignments?api-version=2020-10-01"
  pim_current_scope_resource_id          = local.pim_provdiers_for_scopes[local.pim_current_scope_type]

}

data "azurerm_client_config" "current" {}
data "external" "role_management_policy_assignment" {

  for_each = toset(values(var.pim_assignments)[*].role_name_rbac)

  program = ["pwsh", "-NoProfile", "-file", "${path.module}/.scripts/Get-RoleManagementPolicyAssignment.ps1",
    "-base_url", "https://management.azure.com/{0}/providers/Microsoft.Authorization/roleManagementPolicyAssignments?api-version=2020-10-01",
    "-toplevel_scope", "${local.pim_current_scope_resource_id}",
    "-role_name", "${each.value}",
    "-tenant_id", "${data.azurerm_client_config.current.tenant_id}"
  ]

}