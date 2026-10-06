// Image Template do Azure VM Image Builder para Ubuntu 24.04 LTS.
// Reaproveita a identidade, a rede e a galeria do laboratório rg-aib-lab-wus2-001.

@description('Região do Image Template. Precisa ser a mesma da Image Definition.')
param location string = resourceGroup().location

@description('Nome do Image Template.')
param templateName string = 'aib-ubuntu2404-gha'

@description('Versão que será publicada na galeria, no formato Major.Minor.Patch.')
param imageVersion string

@description('Managed Identity usada pelo Image Builder durante o build.')
param buildIdentityName string = 'id-aib-lab-wus2-001'

param galleryName string = 'gal_aib_lab_wus2_001'
param imageDefinitionName string = 'imgdef-ubuntu2404'
param vnetName string = 'vnet-aib-lab-wus2-001'
param buildSubnetName string = 'snet-aib-build-wus2-001'
param aciSubnetName string = 'snet-aib-aci-wus2-001'

@description('Commit que originou o build. Vai para as tags da versão.')
param gitSha string = 'manual'

@description('Número do run do GitHub Actions. Vai para as tags da versão.')
param runNumber string = '0'

var buildIdentityId = resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', buildIdentityName)
var galleryImageId = resourceId('Microsoft.Compute/galleries/images', galleryName, imageDefinitionName)
var buildSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, buildSubnetName)
var aciSubnetId = resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, aciSubnetName)

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2024-02-01' = {
  name: templateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${buildIdentityId}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: 120
    source: {
      type: 'PlatformImage'
      publisher: 'Canonical'
      offer: 'ubuntu-24_04-lts'
      sku: 'server'
      version: 'latest'
    }
    customize: [
      {
        type: 'Shell'
        name: 'UpdatePackages'
        inline: [
          'sudo apt-get update -y'
          'sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y'
        ]
      }
      {
        type: 'Shell'
        name: 'InstallBasicPackages'
        inline: [
          'sudo DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget vim net-tools htop unzip ca-certificates gnupg lsb-release'
        ]
      }
      {
        type: 'Shell'
        name: 'ConfigureTimezone'
        inline: [
          'sudo timedatectl set-timezone America/Sao_Paulo'
        ]
      }
      {
        type: 'Shell'
        name: 'CreateBuildInfo'
        inline: [
          'sudo mkdir -p /opt/buildinfo'
          'echo "Imagem base Ubuntu 24.04 versao ${imageVersion}, commit ${gitSha}, run ${runNumber}" | sudo tee /opt/buildinfo/image-info.txt'
          'date | sudo tee -a /opt/buildinfo/image-info.txt'
        ]
      }
      {
        type: 'Shell'
        name: 'ValidateAzureLinuxAgent'
        inline: [
          'systemctl status walinuxagent --no-pager || true'
        ]
      }
      {
        type: 'Shell'
        name: 'CleanUp'
        inline: [
          'sudo apt-get autoremove -y'
          'sudo apt-get clean'
          'sudo rm -rf /var/lib/apt/lists/*'
        ]
      }
    ]
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: '${galleryImageId}/versions/${imageVersion}'
        runOutputName: 'runoutput-ubuntu2404-gha'
        artifactTags: {
          source: 'azure-image-builder'
          os: 'ubuntu-24.04'
          environment: 'lab'
          pipeline: 'github-actions'
          gitSha: gitSha
          runNumber: runNumber
        }
        targetRegions: [
          {
            name: location
            replicaCount: 1
            storageAccountType: 'Standard_LRS'
          }
        ]
        excludeFromLatest: true
      }
    ]
    vmProfile: {
      vmSize: 'Standard_D2ds_v5'
      osDiskSizeGB: 64
      vnetConfig: {
        subnetId: buildSubnetId
        containerInstanceSubnetId: aciSubnetId
      }
    }
  }
}

output templateId string = imageTemplate.id
output publishedVersion string = imageVersion
