///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module creates and stores key vault.
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

targetScope='resourceGroup'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('The name of the key vault to use.')
param p_keyVaultName string

@description('The name of the secret to create / update.')
param p_secretName string

@description('The secret (secure) value that you want to save to the key vault.')
param p_trimBase64 string = concat('12#',replace(replace(replace(base64(p_secretName),'-',''),'_',''),'=',''))
param p_secretValue string = take(concat(take(toUpper('${p_secretName}'),2), take(toLower('${p_secretName}'), 2), p_trimBase64), 14)

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////


resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
   name: p_keyVaultName
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: p_secretName
  parent: keyVault
  properties: {
    value: p_secretValue
    attributes: {
      enabled: true
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////

 @description('Resource Id of  Secret')
output o_resourceId string = secret.id

@description('Name for secret')
output o_secretName string = secret.name

@description('URI of secret without version')
output o_secretUri string = secret.properties.secretUri

@description('Version of URI')
output o_secretVersion string = replace(secret.properties.secretUriWithVersion, secret.properties.secretUri, '')

@description('URI of secret with version')
output o_secretUriWithVersion string = secret.properties.secretUriWithVersion
