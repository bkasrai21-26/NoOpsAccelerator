///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// This template deploys Keyvault. Unless needed do not re-run this modules as access policies are revoked causing errors
// 
// run this code by typing the following Azure CLI command: 
// 1. cd <installDirectory/src/bicep/main/KeyVault
// 2. Edit mainKeyVaultRequiredParams.json  to update IP address/range
// 3. az deployment sub create --location eastus --name keyvault --template-file  .\mainKeyVault.bicep --parameters p_nameIdentifier='mddsha16prodeastus' '@mainKeyVaultRequiredParams.json'
// Note - Location is for config , deployment logging only
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

targetScope = 'subscription'

///////////////////////////////////////////////////////////////////////////////////////////////////////
//  
//  Section for common environment parameters:
//  These parameters need be present and consistant on all main deployment
//
///////////////////////////////////////////////////////////////////////////////////////////////////////
 
 @description('Consistant unique identifer across all resources parameters, Passed via command line')
 param p_nameIdentifier string 

@description('common environment parameters ')
param p_keyVaultResourceGroup string = 'rg-${p_nameIdentifier}-keyVault'

@description('common environment parameters ')
param p_keyVaultSubscription string = subscription().subscriptionId

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('location of deployment')
param p_location string = 'eastus'

@description('key vault used by solution')
param p_keyVaultName string = 'kv-${p_nameIdentifier}'

@description('IP address to implement firewall for keyvault')
param p_ipAddress string

@description('resource tags')
param p_tags object = {}

@description('Timestamp used for deployment and other purpose')
param p_utcNow string = utcNow()

@description('allow public Network Access')
param c_publicNetworkAccess string

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep Modules
///////////////////////////////////////////////////////////////////////////////////////////////////////

module keyVaultResourceGroup '../../modules/resourceGroup/resourceGroup.bicep' = {
  name: take('DeployKeyvaultRG-${p_nameIdentifier}-${p_utcNow}',64)
  scope: subscription(p_keyVaultSubscription)
  params: {
    p_name: p_keyVaultResourceGroup
    p_location: p_location
    p_tags: p_tags
  }
}
module keyVault '../../modules/keyVault/keyVault/keyVault.bicep' = {
  name: take('DeployKeyvault-${p_nameIdentifier}-${p_utcNow}',64)
  scope: resourceGroup(p_keyVaultSubscription, p_keyVaultResourceGroup)
  params: { 
    p_keyVaultName: p_keyVaultName
    p_ipAddress: p_ipAddress
    p_publicNetworkAccess: c_publicNetworkAccess
    p_tags: p_tags
  }
  dependsOn: [
    keyVaultResourceGroup
 ]
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep Ouputs
///////////////////////////////////////////////////////////////////////////////////////////////////////
