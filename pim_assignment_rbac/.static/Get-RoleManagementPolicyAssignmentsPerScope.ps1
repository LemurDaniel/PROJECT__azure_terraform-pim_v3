

$base_url = "https://management.azure.com/{0}/providers/Microsoft.Authorization/roleManagementPolicyAssignments?api-version=2020-10-01"
$path = (Get-ChildItem -Recurse -Filter ".static" | Where-Object { $_.FullName.Contains("pim_assignment_rbac") }).FullName

$tenantId = "be0b9f44-0aee-447a-90b1-688ac0334c2c"

$scopes = Search-AzGraph -ManagementGroup $tenantId -Query "
   resourcecontainers 
   | where tenantId == '$tenantId'
   | where tolower(type) in ('microsoft.management/managementgroups')
   | where properties.details.managementGroupAncestorsChain[-1].name == '$tenantId' or 
      properties.managementGroupAncestorsChain[-1].name == '$tenantId'
   | extend resourceId = iff(['type'] == 'microsoft.management/managementgroups', strcat('/providers/microsoft.management/managementgroups/',name), strcat('/providers/Microsoft.Subscription/subscriptions/',subscriptionId))
   | extend fileName = iff(['type'] == 'microsoft.management/managementgroups', strcat('_managementgroups_',name), strcat('_subscriptions_',subscriptionId))
   | project resourceId, fileName
   "

for($i =0; $i -lt $scopes.Count; $i++){
   $resourceId = $($scopes[$i].resourceId)
   $fileName = "$($path)/$($scopes[$i].fileName.replace("/", "_")).json"
   Write-Host "Processing Item $i/$($scopes.Count) -- $resourceId".toLower()

   $url = [System.String]::format($base_url, $resourceId)
   $response = Invoke-AzRestMethod -Method GET -Uri $url

   $psObject = $($response.Content | ConvertFrom-Json).value
   $psObject | ForEach-Object { $_.properties.effectiveRules = @() } 
   $psObject | ConvertTo-Json -Depth 8 | Out-File -Path $fileName
}
