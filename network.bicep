param resourceSuffix string
param location string = resourceGroup().location
param addressPrefix string = '192.168.255.0/24'
param principalId string

var subnetName = 'default'

resource network 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: 'vnet-${resourceSuffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: addressPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }

  resource subnet 'subnets' existing = {
    name: subnetName
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-01-01' = {
  name: 'nsg-${resourceSuffix}'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowLoadBalancerInbound'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '60000-60001'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

var networkContributor = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7')

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(principalId, networkContributor, network.id)
  scope: network
  properties: {
    principalId: principalId
    roleDefinitionId: networkContributor
  }
}

output subnetId string = network::subnet.id
