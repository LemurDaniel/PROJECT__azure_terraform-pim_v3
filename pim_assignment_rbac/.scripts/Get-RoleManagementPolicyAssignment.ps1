

param(
  [Parameter(Mandatory = $true)]
  [System.String]
  $base_url,

  [Parameter(Mandatory = $true)]
  [System.String]
  $toplevel_scope,

  [Parameter(Mandatory = $true)]
  [System.String]
  $role_name,

  [Parameter(Mandatory = $true)]
  [System.String]
  $tenant_id
)

$toplevel_scope_sub_guid = $toplevel_scope
$toplevel_scope_sub_name = $toplevel_scope

if ($toplevel_scope.Contains('/providers/Microsoft.Subscription')) {
  $splitted_scope = $toplevel_scope -split '/'

  $azAccountSubdata = (az account list | ConvertFrom-Json) | Where-Object { $_.homeTenantId -eq $tenant_id }
  if (!([System.Guid]::TryParse($splitted_scope[4], [System.Management.Automation.PSReference][System.Guid]::Empty))) {
    $splitted_scope[4] = ($azAccountSubdata | Where-Object { $_.name -eq $splitted_scope[4] })[0].id
    $toplevel_scope_sub_guid = ($splitted_scope -join '/')
  }
  else {
    $splitted_scope[4] = ($azAccountSubdata | Where-Object { $_.id -eq $splitted_scope[4] })[0].name
    $toplevel_scope_sub_name = ($splitted_scope -join '/')
  }
}

$url = [System.String]::format($base_url, $toplevel_scope_sub_guid)
$response = az rest --method GET --url $url
$responseConvertedObject = $($response | ConvertFrom-Json).value

# Parse Result Object
$MapOfRoleManagementPolicyAssigments_PerRoleDisplayName = [System.Collections.Hashtable]::new()
foreach ($roleManagementPolicyAssignment in $responseConvertedObject) {
    
  $roleManagementPolicyAssignment.properties.effectiveRules = @()
  $rbacDisplayName = $roleManagementPolicyAssignment.properties.policyAssignmentProperties.roleDefinition.displayName
  $assignment_scope_name = ($toplevel_scope_sub_name -split '/')[-1]

  # Apparantly external data sources can only handle one layer of depth with no nested objects.
  $MapOfRoleManagementPolicyAssigments_PerRoleDisplayName.add($rbacDisplayName , [PSCustomObject]@{

      scope                                  = $roleManagementPolicyAssignment.properties.scope
      policy_guid                            = ($roleManagementPolicyAssignment.properties.policyId -split '/')[-1]
      role_definition_id                     = $roleManagementPolicyAssignment.properties.roleDefinitionId
      role_definition_name                   = $rbacDisplayName

      assignment_scope_name                  = $assignment_scope_name
      role_management_policy_assignment_name = $roleManagementPolicyAssignment.name
      role_management_policy_assignment_id   = $roleManagementPolicyAssignment.id

    })

}
  
# Can't return map of object for external data-source, only map of string values.
return $MapOfRoleManagementPolicyAssigments_PerRoleDisplayName[$role_name] | ConvertTo-Json -Compress