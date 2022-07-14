///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Description : This is the "main" data facture file that creates a 
// By default all data factory options/features  are enabled. This can be changed by modifying mainDataFactoryControls.json
//
// Dependency  
//   1. ../KeyVault/mainKeyVault.bicep (Optional if key vault already exists. In such case provide the name of key vault)
//   2. ../CommonEnvironment/mainCommonEnvironment.bicep 
//
// Steps to install Data factory Infrastructure
//
// ################################ Step-1 ################################
// Optional if key vault exists
//
// 1. cd <installDirectory/src/bicep/main/KeyVault
// 2. Edit mainKeyVaultRequiredParams.json  to update IP address/range
// 3. az deployment sub create --location eastus --name keyvault --template-file  .\mainKeyVault.bicep --parameters p_nameIdentifier='mddsh1prodeastus'
//
// Note - Location is for config , deployment logging only
//
// ################################ Step-2 ################################
// 
// 1. cd to <install_directory>src\bicep\main\CommonEnvironment 
// 2. Edit mainCommonEnvironmentRequiredParams.json  to update required parameters
// 3. az deployment sub create --location eastus --name deploycommonenv --template-file  .\mainCommonEnvironment.bicep --parameters p_nameIdentifier='mddsh1prodeastus' '@mainCommonEnvironmentRequiredParams.json'
//
// Note - Location is for config , deployment logging only
//
// ################################ Step-3 ################################
// 1. cd to <install_directory>src\bicep\main\synapse 
// 2. Edit maindatafactoryRequiredParams.json  to update required parameters
// 3. az deployment sub create  --location eastus --name deployDataFactory --template-file maindatafactory.bicep  --parameters p_nameIdentifier='mddsh1prodeastus''@mainDataFactoryControls.json'
//
// Note - Location is for config , deployment logging only
//
///////////////////////////////////////////////////////////////////////////////////////////////////////
targetScope='subscription'


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-I : Controls Data factory features
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Implement private endpoints')
param c_enablePrivateEndpoint bool 

@description('Implement encryption with CMK')
param c_enableCMK bool 

@description('Enable Virtual Network Manager')
param c_enableVnetManager bool = true

@description('Create windows jump host')
param c_createWindowsJumpHost bool

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-II: Parameters passed from datafactoryRequiredParams.json
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('username Azure object ID')
param p_objectId string

@description('Ip address/range to be whitelisted')
param p_sourceAddressPrefix string 

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-III : Subscription Id's
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Subscription Id for hub vnet')
param p_vnetHubSubscription string = subscription().subscriptionId

@description('Subscription Id for spoke vnet')
param p_vnetDataSubscription string = subscription().subscriptionId

@description('common environment parameters ')
param p_monitorLogSubscription string = subscription().subscriptionId

@description('common environment parameters ')
param p_keyVaultSubscription string = subscription().subscriptionId

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-IV: Resource Group Names
///////////////////////////////////////////////////////////////////////////////////////////////////////


@description('Monitor Log Analytics resource group')
// param p_monitorLogResourceGroup string = 'rg-${p_nameIdentifier}-monitor'
param p_monitorLogResourceGroup string = 'df01mlz-rg-operations-mlz'

@description('Hub vnet resource group name')
// param p_vnetHubResourceGroup string = 'rg-${p_nameIdentifier}-network'
param p_vnetHubResourceGroup string = 'df01mlz-rg-hub-mlz'

@description('Spoke or Datafactory vnet resource group name')
// param p_vnetDataFactoryResourceGroup string = 'rg-${p_nameIdentifier}-network'
param p_vnetDataFactoryResourceGroup string =  'rg-df-workload-rg'

@description('The name of the datafactory resource group')
//param p_dataFactoryResourceGroup string = 'rg-${p_nameIdentifier}-datafactory'
param p_dataFactoryResourceGroup string = 'rg-df-workload-rg'

@description('Keyvault resource group name')
param p_keyVaultResourceGroup string = 'rg-${p_nameIdentifier}-keyVault'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-V: Remaining parameter declaration
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Unique name identifer for resources. Default behaviour is to pass value from command line ')
param p_nameIdentifier string 

@description('Virtual Network Name')
// param p_hubVnetName string = 'vnet-${p_nameIdentifier}'
param p_hubVnetName string = 'df01mlz-vnet-hub-mlz'

@description('Virtual Network Name')
// param p_dataVnetName string = 'vnet-${p_nameIdentifier}'
param p_dataVnetName string = 'rg-df-workload-vnet'

@description('Common environment parameters - Monitoring Log Analytics Workspace')
// param p_monitorLogAnalyticsWorkspace string = 'la-${p_nameIdentifier}-monitor'
param p_monitorLogAnalyticsWorkspace string = 'df01mlz-log-operations-mlz'

@description('Monitoring Log Analytics')
// param p_monitorLogAnalyticsStorageAccount string = toLower(replace('samlamon${p_nameIdentifier}', '-', ''))
param p_monitorLogAnalyticsStorageAccount string = 'df01mlzstopswetqjwiga3g'

@description('The name of the subnet name to deploy')
// param p_subnetName string = 'snet-${p_nameIdentifier}'
param p_subnetName  string = 'rg-df-workload-subnet'

@description('location')
param p_location string = 'eastus'

@description('Name of the KeyVault to hold Sql Admin password')
param p_keyVaultName string = 'kv-${p_nameIdentifier}'

@description('The name of the datafactory to deploy')
param p_dataFactoryName string = 'df-${p_nameIdentifier}'

@description('A tags object for associating additional tags to the data factory.')
param p_tags object = {}

@description('Private endpoint Azure resource names')
param p_dataFactoryEndPoint array = [
  'dataFactory'
  'portal'
]

@description('ID for Conributor role')
param p_contributorRoleId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Value for "Principal"  user type')
param p_servicePrincipalType string = 'ServicePrincipal'

@description('adds a time string for unique naming')
param p_utcNow string = utcNow()

@description('Create Public IP for windows')
param p_AssociatepublicIp bool = true

@description('NSG name')
param p_networkSecurityGroup string = 'nsg-${p_nameIdentifier}'

@description('NSG Security rules')
param p_securityRules array = [
      {
      name: 'Default-allow-3389'
      properties: {
        priority: 110
        access: 'Allow'
        direction: 'Inbound'
        destinationPortRange: '3389'
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: p_sourceAddressPrefix
        destinationAddressPrefix: '*'
      }
    }
]

//////////////////////////////////////////////////////////////////////////////////// 
// Section-VI: Bicep variables 
//////////////////////////////////////////////////////////////////////////////////// 
var v_mddTag = {
  MDDTagName: 'MDD1'
}
var v_tags = union(v_mddTag, p_tags)

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-VII: Modules 
///////////////////////////////////////////////////////////////////////////////////////////////////////

//
// Retreiving existing common environment Infrastructure
//
resource existingHubVirtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: p_hubVnetName
  scope: resourceGroup(p_vnetHubSubscription,p_vnetHubResourceGroup)
}

resource existingDataVirtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: p_dataVnetName
  scope: resourceGroup(p_vnetDataSubscription,p_vnetDataFactoryResourceGroup)
}

resource existingKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing  = {
   name: p_keyVaultName
   scope: resourceGroup(p_keyVaultSubscription, p_keyVaultResourceGroup)
}
  
 resource  existingLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: p_monitorLogAnalyticsWorkspace
  scope: resourceGroup(p_monitorLogSubscription, p_monitorLogResourceGroup)
}
 
resource existingLogAnalyticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: p_monitorLogAnalyticsStorageAccount
  scope: resourceGroup(p_monitorLogSubscription, p_monitorLogResourceGroup)
}

module resourceGroupDatafactory '../../modules/resourceGroup/resourceGroup.bicep' = {
  name: 'deploy-${p_nameIdentifier}'
  scope: subscription()
  params: {
    p_name: p_dataFactoryResourceGroup
    p_location: p_location
    p_tags: v_tags
  }
}

module keyVaultKeyDataFactory '../../modules/keyVault/key/keys.bicep' = {
  name: 'deploy-kv-${p_dataFactoryName}'
  scope: resourceGroup(p_keyVaultSubscription, p_keyVaultResourceGroup)
  params: {
    p_keyVaultName: existingKeyVault.name
    p_keyName: 'kv-${p_dataFactoryName}'
    p_keySize: 2048
    p_keyType: 'RSA'
  }
 }

module userManagedId '../../modules/identity/managedIdentity.bicep' =  {
  name: take('DeployUsermanagedId-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup('rg-${p_nameIdentifier}-keyVault')
  params: {
         p_name: p_nameIdentifier
     }
  dependsOn: [
    existingDataVirtualNetwork
    existingKeyVault
    ]
  }  
  
module dataFactory '../../modules/datafactory/datafactory.bicep' = {
  name: 'deploy-dfmod-${p_nameIdentifier}'
  scope: resourceGroup(p_dataFactoryResourceGroup)
  dependsOn: [
    resourceGroupDatafactory
    keyVaultKeyDataFactory
    userManagedId
  ]
  params: {
    p_location: p_location
    p_datafactoryName: p_dataFactoryName
    c_enableCMK: c_enableCMK
    c_enableVnetManager: c_enableVnetManager
    p_managedIdentityId:userManagedId.outputs.o_id
    p_keyKeyVault:{
      keyVaultUri: existingKeyVault.properties.vaultUri
      keyName: keyVaultKeyDataFactory.outputs.o_keyName
      keyVersion: keyVaultKeyDataFactory.outputs.o_keyVersion
      }
  }
}

module dataFactoryDiagSettings '../../modules/datafactory/dataFactoryDiagnostic.bicep' = {
  name: 'deploy-moddiag-${p_nameIdentifier}'
  scope: resourceGroup(p_dataFactoryResourceGroup)
  dependsOn: [
    dataFactory
  ]
  params: {
    p_logAnalyticsWorkspaceId: existingLogAnalyticsWorkspace.id
    p_dataFactory: p_dataFactoryName
    p_logAnalyticsResourceGroupName: p_monitorLogResourceGroup
    p_diagnosticStorageAccountName: existingLogAnalyticsStorageAccount.name
    }
  }

  module roleAssignforUserManagedIdentity '../../modules/datafactory/security/datafactoryRoleassignment.bicep' = {
    name: take('deployRoleAssigManagedIdentity-${p_nameIdentifier}-${p_utcNow}', 64)
    scope: resourceGroup(p_dataFactoryResourceGroup)
    params: {
       p_datafactoryName: dataFactory.outputs.o_name
       p_roleDefinitionId: p_contributorRoleId
       p_principalType: p_servicePrincipalType
       p_principalId: userManagedId.outputs.o_principalId   
    }
    dependsOn: [
       dataFactory
    ]
 }

module keyAccessPolicyForAdmin '../../modules/keyVault/accessPolicies/accessPolicy.bicep' = {
  name: take('DeployKeyPolicy-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup('rg-${p_nameIdentifier}-keyVault')
  params: {
     p_objectId: userManagedId.outputs.o_principalId
     p_keyVaultName: existingKeyVault.name
  }
  dependsOn: [
     existingKeyVault
     userManagedId
  ]
}

module roleAssignforUserManagedIdentityKeyVault '../../modules/keyvault/keyvault/Roleassignment.bicep' = {
  name: take('deployRoleAssigMIKeyVault-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_keyVaultResourceGroup)
  params: {
     p_keyVaultName: existingKeyVault.name
     p_roleDefinitionId: p_contributorRoleId
     p_principalType: p_servicePrincipalType
     p_principalId: userManagedId.outputs.o_principalId
  }
  dependsOn: [
    existingKeyVault
    userManagedId
 ]
}

module keyAccessPolicyForSysManagedIdentity '../../modules/keyVault/accessPolicies/accessPolicy.bicep' = {
  name: take('deployKeyPolicySysManagedId-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup('${p_keyVaultResourceGroup}')
  params: {
     p_objectId: p_objectId
     p_keyVaultName: existingKeyVault.name
  }
  dependsOn: [
     existingKeyVault
     dataFactory
  ]
}

// Implement private end points for DataFactory end points
module dataFactoryPrivateEndpoint '../../modules/network/virtualNetwork/privateEndPoint.bicep' = [ for i in p_dataFactoryEndPoint: if (c_enablePrivateEndpoint) {
  name: take('deployDF${i}EndPoint-${p_nameIdentifier}-${p_utcNow}',64)
  scope: resourceGroup(p_dataFactoryResourceGroup)
  params: {
    p_privateEndPointName: 'ep-privatelink.${i}.${environment().suffixes.storage}'
    p_groupIds: [
       '${i}'
     ]
    p_subnetId:  existingDataVirtualNetwork.properties.subnets[0].id
    p_resourceId: dataFactory.outputs.o_id
    p_tags: v_tags
  }
  dependsOn: [
    dataFactory
 ]
}]

module dataFactoryPrivateDNSZone '../../modules/network/virtualNetwork/privateDNSZone.bicep' = [ for i in p_dataFactoryEndPoint: if (c_enablePrivateEndpoint) {
  name: take('deploy${i}PrivateDNSZone-${p_nameIdentifier}-${p_utcNow}',64)
  scope: resourceGroup(p_vnetHubResourceGroup)
  params: {
    p_name: 'privatelink.${i}.${environment().suffixes.storage}'
    p_virtualNetworkId: existingHubVirtualNetwork.id
    p_virtualNetworkName: existingHubVirtualNetwork.name
    p_virtualNetworkResourceGroupName: p_vnetHubResourceGroup
    p_tags: p_tags
  }
  dependsOn: [
    dataFactoryPrivateEndpoint
    existingHubVirtualNetwork
  ]
}]

module dataFactoryPrivateDNSZoneGroup '../../modules/network/virtualNetwork/privateDNSZoneGroup.bicep' =  [for (name, i) in p_dataFactoryEndPoint: if (c_enablePrivateEndpoint) {
  name: take('deploy${name}PrivateDNSZoneGroup-${p_nameIdentifier}-${p_utcNow}',64)
  scope: resourceGroup(p_dataFactoryResourceGroup)
  params: {
    p_name: 'ep-privatelink.${name}.${environment().suffixes.storage}'
    p_dnsGroupName: 'dnsGroup-ep-privatelink.${name}.${environment().suffixes.storage}'
    p_privateDnsZoneId: dataFactoryPrivateDNSZone[i].outputs.o_pdnsId
  }
  dependsOn: [
    dataFactoryPrivateEndpoint
  ]
}]

module KeyVaultEndpoint '../../modules/network/virtualNetwork/privateEndPoint.bicep' =  if (c_enablePrivateEndpoint) {
  name: take('deployKeyVaultEndpoint-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup('${p_keyVaultResourceGroup}')
  params: {
     p_privateEndPointName: 'ep-${p_nameIdentifier}-vault'
     p_groupIds: [
        'vault'
      ]
     p_subnetId:  existingDataVirtualNetwork.properties.subnets[0].id
     p_resourceId: existingKeyVault.id
     p_tags: p_tags
   }
  dependsOn: [
     existingKeyVault
     dataFactory
  ]
}

module keyvaultPrivateDNSZone '../../modules/network/virtualNetwork/privateDNSZone.bicep' = if (c_enablePrivateEndpoint) {
  name: take('deployKeyVaultPrivateDNSZone-${p_nameIdentifier}-${p_utcNow}',64)
  scope: resourceGroup('${p_vnetHubResourceGroup}')
  params: {
    p_name: 'privatelink${environment().suffixes.keyvaultDns}'
    p_virtualNetworkId: existingHubVirtualNetwork.id
    p_virtualNetworkName: existingHubVirtualNetwork.name
    p_virtualNetworkResourceGroupName: p_vnetHubResourceGroup
    p_tags: p_tags
  }
  dependsOn: [
     existingKeyVault
     existingHubVirtualNetwork
     KeyVaultEndpoint
  ]
}
module keyVaultPrivateDNSZoneGroup '../../modules/network/virtualNetwork/privateDNSZoneGroup.bicep' = if (c_enablePrivateEndpoint) {
  name: take('deployKVPrivateDNSZoneGroupZone-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup('${p_keyVaultResourceGroup}')
  params: {
    p_name: KeyVaultEndpoint.outputs.o_privateEndpointName
    p_dnsGroupName: '${p_nameIdentifier}-kv-dnsGroup'
    p_privateDnsZoneId: keyvaultPrivateDNSZone.outputs.o_pdnsId
  }
  dependsOn: [
     keyvaultPrivateDNSZone
     KeyVaultEndpoint
  ]
}


 // Creating Windows Jump host for MLZ integration
 module jumphostNetworkSecurityGroup '../../modules/network/virtualNetwork/networkSecurityGroup.bicep' = if (c_createWindowsJumpHost) {
  name: take('deployNSG-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_dataFactoryResourceGroup)
  params: {
    p_networkSecurityGroup: p_networkSecurityGroup
    p_location: p_location
    p_securityRules: p_securityRules
    p_tags: p_tags
    
  }
  dependsOn: [
    existingDataVirtualNetwork
  ]
}
module publicIp '../../modules/network/virtualNetwork/publicIpAddress.bicep' = if (c_createWindowsJumpHost) {
  name: take('deployPip-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_dataFactoryResourceGroup)
  params: {
    p_nameIdentifier: p_nameIdentifier
  }
  dependsOn: [
    existingDataVirtualNetwork
  ]
}

// Uncommment  p_publicIpId if c_createPublicIp  is true
module networkInterface '../../modules/network/virtualNetwork/networkInterface.bicep' = if (c_createWindowsJumpHost ) {
  name: take('deployNetworkIntPip-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_dataFactoryResourceGroup)
  params: {
    p_networkSecurityGroupId: jumphostNetworkSecurityGroup.outputs.o_networkSecurityGroupId
    p_subnetId: existingDataVirtualNetwork.properties.subnets[0].id
    p_location: p_location
    p_AssociatepublicIp: p_AssociatepublicIp
    p_publicIpId: publicIp.outputs.o_publicIpId
  }
  dependsOn: [
    existingDataVirtualNetwork
    jumphostNetworkSecurityGroup
  ]
}

module storeSecretWinAdmin '../../modules/keyVault/secret/secrets.bicep' = if (c_createWindowsJumpHost) {
  name: take('deployStoreSecretWinAdmin-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup('${p_keyVaultResourceGroup}')
  params: {
     p_secretName: 'winadmin'
     p_keyVaultName: existingKeyVault.name
  }
  dependsOn: [
    existingKeyVault
  ]
}


module windowsJumpHost '../../modules/virtualmachines/windows/windowsVM.bicep' = if (c_createWindowsJumpHost) {
  name: take('deployJumpHost-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_dataFactoryResourceGroup)
  params: {
    p_nameIdentifier: p_nameIdentifier
    p_networkInterfaceId: networkInterface.outputs.o_networkInterfaceId
    p_networkInterfaceName: networkInterface.outputs.o_networkInterfaceName
    p_adminUsername: storeSecretWinAdmin.outputs.o_secretName
    p_adminPassword: existingKeyVault.getSecret(storeSecretWinAdmin.outputs.o_secretName)
  }
  dependsOn: [
    existingKeyVault
    existingDataVirtualNetwork
    storeSecretWinAdmin
    networkInterface
  ]
}


//////////////////////////////////////////////////////////////////////////////////// 
// Section for Bicep outputs 
//////////////////////////////////////////////////////////////////////////////////// 
