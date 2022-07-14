/* ********************************************************************************** 
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* ********************************************************************************** 
 * Module: dataFactory.bicep
 * Scope: resourceGroup
 *
 *********************************************************************************  */
targetScope='resourceGroup'

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

param c_enableVnetManager bool = true

param c_enableCMK bool

param p_location string

param p_datafactoryName string

@description('networking object used by solution')
param p_keyKeyVault object = {
  keyVaultUri: ''
  keyName: ''
  keyVersion: ''
}

param p_managedIdentityId string = ''
 
@description('A tags object for associating additional tags to the data factory.')
param p_tags object = {}

/* **********************************************************************************
 * Section for Bicep variables 
 * ********************************************************************************** */

var v_mddTag = {
  MDDTagName: 'MDD1'
}
var v_tags = union(v_mddTag, p_tags)

var v_encryption = c_enableCMK ? {
  identity: {
      userAssignedIdentity: p_managedIdentityId
  }
  vaultBaseUrl: c_enableCMK ? p_keyKeyVault.keyVaultUri : ''
  keyName: c_enableCMK ? p_keyKeyVault.keyName : ''
  keyVersion: c_enableCMK ?  p_keyKeyVault.keyVersion : ''
  }: {}

/* **********************************************************************************
* Section for Bicep resources 
* ********************************************************************************** */

resource datafactory 'Microsoft.DataFactory/factories@2018-06-01' = { 
  name: p_datafactoryName
  location: p_location
  tags: v_tags
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${p_managedIdentityId}': {
        }
      }
}
  properties: {
    publicNetworkAccess: 'Disabled'
    encryption: v_encryption
  }
}

resource datafactoryManagedVirtualNetwork 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = if (c_enableVnetManager == true) {
  parent: datafactory
  name: 'default'
  properties: {}
}

resource datafactoryManagedIntegrationRuntime001 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = if (c_enableVnetManager == true) {
  parent: datafactory
  name: 'AutoResolveIntegrationRuntime'
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      type: 'ManagedVirtualNetworkReference'
      referenceName: datafactoryManagedVirtualNetwork.name
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
  }
}
/* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */

output o_id string = datafactory.id
output o_name string = datafactory.name
output o_systemManagedIdentity string = datafactory.identity.principalId
output o_identity object= datafactory.identity
