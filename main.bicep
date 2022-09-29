targetScope = 'subscription'

param project string = 'contoso'
param environment string = 'dev'
param location string = deployment().location
param region string = 'weu'
param imageIdentifier string = 'Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest'
param productName string = 'ubuntu-lts'
param productVersion string = '2022.09.30'
param replicationRegions array = [
  'northeurope'
]

param deploymentName string = '${deployment().name}-${uniqueString(utcNow())}'

var resourceSuffix = '${project}-${environment}-${region}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${resourceSuffix}'
  location: location
}

module role 'role.bicep' = {
  name: '${deploymentName}-role'
  params: {
    resourceGroupId: resourceGroup.id
  }
}

module policy 'policy.bicep' = {
  scope: resourceGroup
  name: '${deploymentName}-policy'
}

module identity 'identity.bicep' = {
  scope: resourceGroup
  name: '${deploymentName}-identity'
  params: {
    resourceSuffix: resourceSuffix
    location: location
    roleId: role.outputs.id
  }
}

module network 'network.bicep' = {
  scope: resourceGroup
  name: '${deploymentName}-network'
  params: {
    principalId: identity.outputs.principalId
    resourceSuffix: resourceSuffix
    location: location
  }
}

module gallery 'gallery.bicep' = {
  scope: resourceGroup
  name: '${deploymentName}-gallery'
  params: {
    resourceSuffix: resourceSuffix
    location: location
    imageIdentifier: imageIdentifier
    identityId: identity.outputs.id
    subnetId: network.outputs.subnetId
    productName: productName
    productVersion: productVersion
    replicationRegions: replicationRegions
  }
}

output cmd string = 'az image builder run -n ${gallery.outputs.name} -g ${resourceGroup.name} --no-wait'
