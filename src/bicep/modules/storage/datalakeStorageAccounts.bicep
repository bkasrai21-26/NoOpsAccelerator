/* ********************************************************************************** 
 * Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
 * Software is licensed under the MIT License. See LICENSE in the project root
 * for license information.
 * ********************************************************************************** */

/* ********************************************************************************** 
 * This module creates Azure Storage account with HNS enabled
 *
 * Assign appropriate values as needed. If needed override global parameters
 * ********************************************************************************** */

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

@description('SKU for Storage Account. Accepted values- Premium_LRS, Premium_ZRS, Standard_GRS, Standard_GZRS, Standard_LRS, Standard_RAGRS, Standard_RAGZRS, Standard_ZRS')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_LRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Standard_ZRS'
])
param p_sku string = 'Standard_LRS'

@description('Access tier used for billing StandardBlob accounts.Cannot be set for StandardLRS, StandardGRS, StandardRAGRS, or PremiumLRS account types. Accepted values - Cool, Hot')
@allowed([
  'Hot'
  'Cool'
])
param p_accessTier string = 'Hot'

@description('Allow https traffic only to storage service if set to true. The default value is true')
param p_supportsHttpsTrafficOnly bool = false

@description('Allow the blob service to exhibit filesystem semantics. This property can be enabled only when storage account kind is StorageV2. Accepted values - false, true')
param p_isHnsEnabled bool = false

@description('tags')
param p_tags object = {}

@description('Minimum supported TLS version for the storage account')
param p_minimumTlsVersion string = 'TLS1_2'

@description('TBD')
param p_allowSharedKeyAccess bool = true

@description('TBD')
param p_allowBlobPublicAccess bool = true

@description('Provide value if you need the storage account name prefixed with predefined names concatenated with randomly generated name for uniqueness. Example - analytics35jrgtgfdguire')
param p_partialStorageAccountName string = ''

@description('Name identifier to derive names')
param p_nameIdentifier string = ''

/* **********************************************************************************
 * Section for Bicep variables
 * ********************************************************************************** */

var v_storageAccountName = take(toLower(replace('${p_partialStorageAccountName}${p_nameIdentifier}', '-', '')),24)
var v_location = resourceGroup().location

// the unique MDD tag is determined to be - we can just embed int he reosurces and append it to any additional customer tags that are added.
var v_mddTag = {
  mdd: 'mdd1'
}
var v_tags = union(v_mddTag, p_tags)

/* **********************************************************************************
 * Section for Bicep resources
 * ********************************************************************************** */

resource resStorageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: v_storageAccountName
  sku: {
    name: p_sku
  }
  kind: 'StorageV2'
  location: v_location
  tags: v_tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    accessTier: p_accessTier
    supportsHttpsTrafficOnly: p_supportsHttpsTrafficOnly
    isHnsEnabled: p_isHnsEnabled
    allowBlobPublicAccess: p_allowBlobPublicAccess
    minimumTlsVersion: p_minimumTlsVersion
    allowSharedKeyAccess: p_allowSharedKeyAccess
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
    }
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}




///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////

output o_storageAcctName string = resStorageaccount.name
output o_accountUrl string = resStorageaccount.properties.primaryEndpoints.dfs
output o_id string = resStorageaccount.id
output o_primaryBlobEndPoint string = resStorageaccount.properties.primaryEndpoints.blob
output o_primaryKey string = listKeys(resStorageaccount.name,resStorageaccount.apiVersion).keys[0].value
