///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// This template deploys a common data infrastructure environment
// 
// Run mainKeyVault.bicep or provide existing Key vault details before running this code
// This code MUST be run at the management group level to create a subscription.
// By default all resources are created in the same subscription.  Make changes if needed.
//
// Before you run - 
//    Update p_vnetAddressSpace, p_sourceIPAddress and p_objectId. 
//    Make changes as needed for other parameters
// 

// Dependency  
//   1. ../KeyVault/mainKeyVault.bicep (Optional if key vault already exists. In such case provide the name of key vault)
//  
//
// How to execute ?
//
//-----Step-1-------- (Optional, Skip if key vault already exists)
// 1. cd <installDirectory/src/bicep/main/KeyVault
// 2. Edit mainKeyVaultRequiredParams.json  to update IP address/range
// 3. az deployment sub create --location eastus --name keyvault --template-file  .\mainKeyVault.bicep --parameters p_nameIdentifier='mddsha16prodeastus' '@mainKeyVaultRequiredParams.json'
// Note - Location is for config , deployment logging only
//
//
// 1. cd <installDirectory/src/bicep/main/CommonEnvironment
// 2. az deployment sub create --location eastus  --name deploycommonenv --template-file  .\mainCommonEnvironment.bicep --parameters p_nameIdentifier='mddprodeastus'
// Note - Location is for config , deployment logging only
//
///////////////////////////////////////////////////////////////////////////////////////////

targetScope = 'subscription'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-I : Control common environment options
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Enable to create Log analyticsa for Monitoring')
param c_createLogAnalytics bool

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-II: Parameters passed from mainSynapseRequiredParams.json
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Virtual Network Name')
param p_vnetAddressSpace string

@description('IP address or CIDR range to be white listed')
param p_sourceAddressPrefix string

@description('Object Id/Principal Id of User')
param p_objectId string 

@description('Location of deployment')
param p_location string

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-IV: Resource Group Names
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Resource group for monitor log storage and analytics')
param p_monitorLogResourceGroup string = 'rg-${p_nameIdentifier}-monitor'

@description('common environment parameters ')
param p_keyVaultResourceGroup string = 'rg-${p_nameIdentifier}-keyVault'

@description('common environment parameters ')
param p_vnetResourceGroup string = 'rg-${p_nameIdentifier}-network'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-III : Subscription Id's
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Consistent unique identifer across all resources parameters, Passed via command line')
param p_nameIdentifier string

@description('subscription where the monitor Log resource group is located')
param p_monitorLogSubscription string = subscription().subscriptionId

@description('common environment parameters ')
param p_keyVaultSubscription string = subscription().subscriptionId

@description('common environment parameters ')
param p_vnetSubscription string = subscription().subscriptionId

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-VI: Declare remaining parameters here if needed
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('key vault used by solution')
param p_keyVaultName string = 'kv-${p_nameIdentifier}'

@description('Monitoring Log Analytics')
param p_monitorLogAnalyticsStorageAccount string = toLower(replace('samlamon${p_nameIdentifier}', '-', ''))

@description('Monitoring Log Analytics Workspace')
param p_monitorLogAnalyticsWorkspace string = 'la-${p_nameIdentifier}-monitor'

@description('Virtual Network Name')
param p_vnetName string = 'vnet-${p_nameIdentifier}'

@description('resource tags')
param p_tags object = {}

@description('Role Id of contributor role')
param p_roleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Timestamp used for deployment')
param p_utcNow string = utcNow()

@description('Type of principal - User or Service principal or group')
param p_principalType string = 'User'

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


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep Modules
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Retrieving information about existing Keyvault
module keyVault '../../modules/keyVault/keyVault/keyVaultExists.bicep' = {
  name: take('deployKeyvaultExist-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_keyVaultSubscription, p_keyVaultResourceGroup)
  params: {
    p_keyVaultName: p_keyVaultName
  }
  dependsOn: []
}

// Assign role to access Key vault
module roleAssignment '../../modules/identity/roleAssignment.bicep' = {
  name: take('deployRoleAssign-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_keyVaultSubscription, p_keyVaultResourceGroup)
  params: {
    p_keyVaultName: keyVault.outputs.o_keyVaultName
    p_roleDefinitionId: p_roleDefinitionId
    p_principalType: p_principalType
    p_principalId: p_objectId
  }
  dependsOn: [
    keyVault
  ]
}

// Monitoring 
module monitorLogResourceGroup '../../modules/resourceGroup/resourceGroup.bicep' = if (c_createLogAnalytics) {
  name: take('deployMonitorRG-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: subscription(p_monitorLogSubscription)
  params: {
    p_name: p_monitorLogResourceGroup
    p_location: p_location
    p_tags: p_tags
  }
  dependsOn: []
}

module monitorLogAnalyticsWorkspace '../../modules/logAnalytics/logAnalyticsWorkspace.bicep' = if (c_createLogAnalytics) {
  name: take('deployLA-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_monitorLogSubscription, p_monitorLogResourceGroup)
  params: {
    p_logAnalyticsWorkspaceName: p_monitorLogAnalyticsWorkspace
    p_location: p_location
    p_tags: p_tags
  }
  dependsOn: [
    monitorLogResourceGroup
  ]
}

module monitorLogAnalyticsStorageAccount '../../modules/storage/storageAccount.bicep' = if (c_createLogAnalytics) {
  name: take('deployLAStorageAcct-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_monitorLogSubscription, p_monitorLogResourceGroup)
  params: {
    p_manualStorageAcctName: p_monitorLogAnalyticsStorageAccount
    p_supportsHttpsTrafficOnly: true
  }
  dependsOn: [
    monitorLogResourceGroup
  ]
}

module monitorLogAnalyticsDiag '../../modules/logAnalytics/logAnalyticsDiagnostic.bicep' = if (c_createLogAnalytics) {
  name: take('deployLADiag-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_monitorLogSubscription, p_monitorLogResourceGroup)
  params: {
    p_logAnalyticsWorkspaceName: monitorLogAnalyticsWorkspace.outputs.o_logAnalyticsWorkspaceName
    p_diagnosticStorageAccountName: monitorLogAnalyticsStorageAccount.outputs.o_storageAcctName
  }
  dependsOn: [
    monitorLogResourceGroup
  ]
}

// VNET 
module resourceGroupNetworking '../../modules/resourceGroup/resourceGroup.bicep' = {
  name: take('deployVnetRG-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: subscription(p_vnetSubscription)
  params: {
    p_name: p_vnetResourceGroup
    p_location: p_location
    p_tags: p_tags
  }
}

module networkSecurityGroup '../../modules/network/virtualNetwork/networkSecurityGroup.bicep' = {
  name: take('deployNSG-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_vnetResourceGroup)
  params: {
    p_networkSecurityGroup: p_networkSecurityGroup
    p_location: p_location
    p_tags: p_tags
    p_securityRules: p_securityRules
  }
  dependsOn: [
    resourceGroupNetworking
  ]
}

module vnet '../../modules/network/virtualNetwork/virtualNetwork.bicep' = {
  name: take('deployVnet-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_vnetSubscription, p_vnetResourceGroup)
  params: {
    p_name: p_vnetName
    p_vnetAddressSpace: p_vnetAddressSpace
    p_subnetName: 'snet-1-${p_nameIdentifier}'
    p_networkSecurityGroupId: networkSecurityGroup.outputs.o_networkSecurityGroupId
    p_location: p_location
  }
  dependsOn: [
    resourceGroupNetworking
    networkSecurityGroup
  ]
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep Outputs
///////////////////////////////////////////////////////////////////////////////////////////////////////

