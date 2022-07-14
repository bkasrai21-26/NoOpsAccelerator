/* ********************************************************************************** 
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */
/* ********************************************************************************** 
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */
/* ********************************************************************************** 
 * Module: accessPolicy.bicep
 * Scope: resourceGroup
 * The following are required parameters when calling this module 
 * p_keyVaultName string - The name of the key vault.
 * p_keyName string - the name of the key to create in the key vault.
 ** must assign some permission to keys / secrets / certificates so at least one of those optional parameters should be set
 * The following fields are optional parameters when calling this module.
 * p_keySize int - the key size of the key vault key (defaults to 2048)
 * p_keyType string - the type of key either ('RSA','RSA-HSM') (defaults to 'RSA')
 *********************************************************************************  */
targetScope = 'resourceGroup'

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

@description('The name of the key vault to use.')
param p_keyVaultName string

@description('The name of the key to provision / use in the key vault.')
param p_keyName string

@description('The key size (1024,2048,4096) to use')
param p_keySize int = 2048

@description('The key type - currently limited to RSA / RSA-HSM.')
@allowed([
  'RSA'
  'RSA-HSM'
])
param p_keyType string = 'RSA'

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */

resource key 'Microsoft.KeyVault/vaults/keys@2021-06-01-preview' = if(!empty(p_keyVaultName) && !empty(p_keyName)) {
  name: '${p_keyVaultName}/${p_keyName}'
  properties: {
      attributes: {
          enabled: true
      }
      keySize: p_keySize
      kty: p_keyType
    }
}

/* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */

output o_resourceId string = key.id
output o_keyName string = empty(p_keyName) ? '' : p_keyName
output o_keyVersion string = empty(p_keyName) ? '' : split(key.properties.keyUriWithVersion,'/')[5]
output o_keyUriWithVersion string = empty(p_keyName) ? '' : key.properties.keyUriWithVersion
output o_keyUriWithOutVersion string = take(replace(key.properties.keyUriWithVersion, split(key.properties.keyUriWithVersion,'/')[5],''), length(replace(key.properties.keyUriWithVersion, split(key.properties.keyUriWithVersion,'/')[5],'')) -1)
