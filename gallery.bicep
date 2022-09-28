param resourceSuffix string
param location string = resourceGroup().location
param productName string
param productVersion string
param imageIdentifier string
param replicationRegions array
param identityId string
param buildTimeoutInMinutes int = 30
param vmSize string = 'Standard_D2_v5'
param proxyVmSize string = 'Standard_D16_v5'
param osDiskSizeGB int = 32
param subnetId string

var imageIdentifierComponents = split(imageIdentifier, ':')
var imagePublisher = imageIdentifierComponents[0]
var imageOffer = imageIdentifierComponents[1]
var imageSku = imageIdentifierComponents[2]
var imageVersion = imageIdentifierComponents[3]

resource gallery 'Microsoft.Compute/galleries@2022-01-03' = {
  name: 'gal${replace(resourceSuffix, '-', '')}'
  location: location

  resource image 'images' = {
    name: productName
    location: location
    properties: {
      identifier: {
        sku: imageSku
        offer: imageOffer
        publisher: imagePublisher
      }
      osState: 'Generalized'
      hyperVGeneration: 'V2'
      osType: 'Linux'
    }
  }
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: 'aib-${resourceSuffix}-${productName}-${productVersion}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: buildTimeoutInMinutes
    vmProfile: {
      vmSize: vmSize
      osDiskSizeGB: osDiskSizeGB
      vnetConfig: {
        proxyVmSize: proxyVmSize
        subnetId: subnetId
      }
    }
    source: {
      type: 'PlatformImage'
      publisher: imagePublisher
      offer: imageOffer
      sku: imageSku
      version: imageVersion
    }
    customize: [
      {
        type: 'Shell'
        name: 'Update'
        inline: [
          'sudo apt-get update'
          'sudo DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=a apt-get dist-upgrade -y'
        ]
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: '${gallery::image.id}/versions/${productVersion}'
        storageAccountType: 'Standard_LRS'
        runOutputName: productVersion
        replicationRegions: union([
          location
        ], replicationRegions)
      }
    ]
  }
}

output name string = imageTemplate.name
