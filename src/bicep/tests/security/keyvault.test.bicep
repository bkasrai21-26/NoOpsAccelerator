/* ********************************************************************************** 
 *  This code creates a resource group   and a KeyVault with secrets
 * 
 *  This code MUST be run at the group level to create a subscription. 
 *
 *  Dependencies: module createKV.bicep
 * 
 * run this code by typing the following Azure CLI command: 
 * vscode@mdd-dev:/workspaces/mdd$ az deployment sub create -f src/bicep/tests/security/keyvault.test.bicep -l eastus -c
 **********************************************************************************  */
targetScope = 'subscription'

var v_resourceGroupName = 'mlz-slvor34cjpm5w-identity'
var v_keyVaultName = toLower('keyvaultmddtomlz1')
var v_mddTag = 'mdd1'
var v_uniqueTag = 'whatEverYouWant'
var v_secretName = 'TuesdaySecured'
var v_secretValue = 'TuesdaySecret' 

@description('The location to deploy the resource group')
param p_location string

// call module to create a resource group
module createResGroup '../../modules/resourcegroup/resourceGroup.bicep' = {
   name: v_resourceGroupName
    params: {
    p_name: v_resourceGroupName
    p_location: p_location
    p_tags: {}
   }
}

// call module to create a KeyVault
module createKV '../../modules/keyVault/keyvault.bicep' = {
  name: v_keyVaultName
  scope: resourceGroup(v_resourceGroupName)
  dependsOn:[
    createResGroup
  ]
  params:{ 
    p_keyVaultName: v_keyVaultName
    p_keyVaultTenantId: subscription().tenantId
    p_bypass: 'AzureServices'
    p_defaultAction: 'Allow'
    p_sku: 'standard'
    p_tags: {
      '${v_mddTag}': v_uniqueTag
    }
  } 
}

// call module to create a secret
module createSecret '../../modules/keyVault/secret/secrets.bicep' = {
  name: v_secretName
  scope: resourceGroup(v_resourceGroupName)
  dependsOn:[
    createKV
  ]
  params:{
     p_keyVaultName: v_keyVaultName
      p_secretName: v_secretName
      p_secretValue: v_secretValue
  }
}

