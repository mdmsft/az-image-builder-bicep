targetScope = 'subscription'

param resourceGroupId string

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid('Image Builder')
  scope: subscription()
  properties: {
    roleName: 'Image Builder'
    description: 'Azure Image Builder Role'
    permissions: [
      {
        actions: [
          'Microsoft.Compute/galleries/read'
          'Microsoft.Compute/galleries/images/read'
          'Microsoft.Compute/galleries/images/versions/read'
          'Microsoft.Compute/galleries/images/versions/write'
          'Microsoft.Compute/images/write'
          'Microsoft.Compute/images/read'
          'Microsoft.Compute/images/delete'
        ]
      }
    ]
    assignableScopes: [
      resourceGroupId
    ]
  }
}

output id string = last(split(roleDefinition.id, '/'))
