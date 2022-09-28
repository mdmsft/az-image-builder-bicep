resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: guid('VM Image Builder templates should use private link')
  properties: {
    displayName: 'VM Image Builder templates should use private link'
    policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', '2154edb9-244f-4741-9970-660785bccdaa')
  }
}
