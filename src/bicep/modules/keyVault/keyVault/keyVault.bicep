///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module retrieves creates key vault.
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////
targetScope = 'resourceGroup'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////

 @description('The key vault name')
param p_keyVaultName string

@description('While list IP range. An IPv4 address range in CIDR notation or simple IP address')
param p_ipAddress string 

@description('The key vault tenant id')
param p_keyVaultTenantId string = subscription().tenantId

@description('Property to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param p_enabledForDeployment bool = true

@description('Property to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param p_enabledForTemplateDeployment bool = true

@description('Property to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param p_enabledForDiskEncryption bool = true

@description('Enable the key vault for RBAC.')
param p_enableRbacAuthorization bool = false

@description('Set the soft delete retention in days.')
param p_softDeleteRetentionInDays int = 90

@description('Enable protection against purge for the vault')
param p_enablePurgeProtection bool = true

@description('allow public Network Access')
param p_publicNetworkAccess string = 'Enabled'

@description('The key vault SKU to deploy.')
@allowed([
  'standard'
  'premium'
])
param p_sku string = 'standard'

@description('The default network action to apply to the key vault firewall')
@allowed([
  'Allow'
  'Deny'
])
param p_defaultAction string = 'Deny'

@description('Specifies traffic thats can bypass network rules. Allowed values are AzureServices or None')
@allowed([
  'AzureServices'
  'None'
])
param p_bypass string = 'AzureServices'

@description('Tag value')
param p_tags object = {
  MDDTagName: 'MDD1'
}



///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

var v_mddTag = {
  MDDTagName: 'MDD1'
}

var v_tags = union(v_mddTag, p_tags)

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: p_keyVaultName
  location: resourceGroup().location
  tags: v_tags
  properties: {
    accessPolicies: []
    enabledForDeployment: p_enabledForDeployment
    enabledForTemplateDeployment: p_enabledForTemplateDeployment
    enabledForDiskEncryption: p_enabledForDiskEncryption
    softDeleteRetentionInDays: p_softDeleteRetentionInDays
    enableRbacAuthorization: p_enableRbacAuthorization
    enablePurgeProtection: p_enablePurgeProtection
    publicNetworkAccess: p_publicNetworkAccess
    networkAcls: {
      defaultAction: p_defaultAction
      bypass: p_bypass
      ipRules: [
        {
          value: p_ipAddress
        }
      ] 
    }
    sku: {
      name: p_sku
      family: 'A'
    }
    tenantId: p_keyVaultTenantId
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////
 @description('Id of Key vault')
 output o_id string = keyVault.id

 @description('Name of the Key vault')
 output o_keyVaultName string = keyVault.name
 @description('Resource group of key vault')
 output o_keyVaultResourceGroup string = resourceGroup().name

 @description('URI of Key vault')
 output o_vaultUri string = keyVault.properties.vaultUri
 