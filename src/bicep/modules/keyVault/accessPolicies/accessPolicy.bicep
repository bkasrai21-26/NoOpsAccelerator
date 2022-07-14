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
 * p_principalId string - the principal Id from AAD to add to the key vault
 ** must assign some permission to keys / secrets / certificates so at least one of those optional parameters should be set
 * The following fields are optional parameters when calling this module.
 * p_applicationId string - the name of the application assignment for the key vault ACL (defaults to '' if '' not used)
 * p_keys array - the list of permissions assignments to the key vault keys to assign to the principal id (defaults to [])
 * p_secrets array - the list of permission assignments to the key vault secrets to assign to principal id (defaults to [])
 * p_certificates array - the list of permission assignments to the key vault certificates to assign to principal id (defaults to [])
 *********************************************************************************  */
targetScope = 'resourceGroup'

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

 @description('The name of the key vault to use.')
param p_keyVaultName string

@description('The application identifier to add to access the key vault. This is optional but will allow for providing access to a user only while in a specific application context.')
param p_applicationId string = ''

@description('The principal identifier to add to access the key vault')
param p_objectId string

@description('The set of permissions to enable for hte principal to the keys stored in the key vault.')
@allowed([
  'backup'
  'create'
  'decrypt'
  'delete'
  'encrypt'
  'get'
  'import'
  'list'
  'purge'
  'recover'
  'release'
  'restore'
  'sign'
  'unwrapKey'
  'update'
  'verify'
  'wrapKey'
  'all'
])
param p_keys array = [
  'all'
]

@description('The set of permissions to enable for hte principal to the secrets stored in the key vault.')
@allowed([
  'all'
  'backup'
  'delete'
  'get'
  'list'
  'purge'
  'recover'
  'restore'
  'set'
])
param p_secrets array = [
  'all'
]

@description('The set of permissions to enable for hte principal to the certificates stored in the key vault.')
@allowed([
  'all'
  'backup'
  'create'
  'delete'
  'deleteissuers'
  'get'
  'getissuers'
  'import'
  'list'
  'listissuers' 
  'managecontacts' 
  'manageissuers' 
  'purge'
  'recover' 
  'restore'
  'setissuers'
  'update'
])
param p_certificates array = [
  'all'
]

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */


resource accessControl 'Microsoft.KeyVault/vaults/accessPolicies@2021-06-01-preview' = {
  name: '${p_keyVaultName}/add'
   properties: {
    accessPolicies: [
      {
        applicationId: p_applicationId == '' ? null : p_applicationId
        objectId: p_objectId
        permissions: {
          keys: p_keys
          secrets: p_secrets
          certificates: p_certificates
        }
        tenantId: subscription().tenantId
      }
    ]
  }
}


output o_resourceId string = accessControl.id
