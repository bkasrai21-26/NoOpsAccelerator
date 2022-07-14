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

@description('Resource  name to check')
param p_resourceName string

param p_resourceGroupName string = resourceGroup().name

param p_location string = resourceGroup().location

param utcValue string = utcNow()

param p_azCliVersion string = '2.27.0'

param p_timeout string = 'PT1M' 

param p_userAssignedIdentities string

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */


 resource resourceExists 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'resourceExists'
  location: p_location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      p_userAssignedIdentities : {   
      }
    }
  }
  
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: p_azCliVersion
    timeout: p_timeout
    arguments: '\'${p_resourceGroupName}\' \'${p_resourceName}\''
    scriptContent: 'az resource list --resource-group ${p_resourceGroupName} --name ${p_resourceName} --query [].type --output tsv'
    retentionInterval:  'P1D'
  }
 }

output resourceExists int = length(resourceExists.properties.scriptContent)


