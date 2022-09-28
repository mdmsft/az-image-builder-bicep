param resourceSuffix string
param location string = resourceGroup().location
param roleId string

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'id-${resourceSuffix}'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(identity.id, roleId, resourceGroup().id)
  scope: resourceGroup()
  properties: {
    principalId: identity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
  }
}

output id string = identity.id
output principalId string = identity.properties.principalId
