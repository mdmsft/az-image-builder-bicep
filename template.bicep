param location string = resourceGroup().location
param productName string = 'test'
param productVersion string = '1.0.0'
param imageIdentifier string = 'Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest'
param replicationRegions array = []
param identityId string
param subnetId string
param stagingResourceGroupId string
param buildTimeoutInMinutes int = 60
param vmSize string = 'Standard_D2_v5'
param proxyVmSize string = 'Standard_D16_v5'
param osDiskSizeGB int = 64
param galleryId string

var imageIdentifierComponents = split(imageIdentifier, ':')
var imagePublisher = imageIdentifierComponents[0]
var imageOffer = imageIdentifierComponents[1]
var imageSku = imageIdentifierComponents[2]
var imageVersion = imageIdentifierComponents[3]

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: uniqueString(productName, productVersion, imageIdentifier)
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: buildTimeoutInMinutes
    stagingResourceGroup: stagingResourceGroupId
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
        galleryImageId: '${galleryId}/versions/${productVersion}'
        storageAccountType: 'Standard_LRS'
        runOutputName: productVersion
        replicationRegions: replicationRegions
      }
    ]
  }
}
