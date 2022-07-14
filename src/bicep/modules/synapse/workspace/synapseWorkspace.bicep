///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module creates Synapse Workspace. A wait time is introduced so that activate workspace succeeds. 
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Prefix for  resource name')
param p_nameIdentifier string

@description('Synapse sql admin user')

param p_sqlAdministratorLogin string = 'sqladmin'

@description('Synapse sql admin password  - Temp  will implememt key vault')
@secure()
param p_sqlAdministratorLoginPassword string

@description('Setting this to "default" will ensure that all compute for this workspace is in a virtual network managed on behalf of the user')
param p_managedVirtualNetwork string = 'default'

@description(' ')
param p_preventDataExfiltration bool = true

@description('Name of the storage account  for Synapse filesystem')
param p_containerAcctName string

@description('URL of storage account for Synapse filesystem')
param o_accountUrl string

@description('URL for Keyvault to retrieve username and passwords ')
param p_keyUrl string

@description('Name of the Synapse workspace key')
param p_workspaceKeyName string

@description('Enable use of system assigned identity for key encryption')
param p_useSystemAssignedIdentity bool = true

@description('Location of Synapse workspace resource group')
param p_location string = resourceGroup().location

@description('Enable or Disable public network access to workspace')
param p_publicNetworkAccess string = 'Enabled'

@description('Identity type. Accepted values are None, SystemAssigned, UserAssigned, SystemAssigned,UserAssigned')
param p_identityType string = 'SystemAssigned'


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

 @description('Derived name for Synapse workspace')
var v_synapseWorkspaceName = replace(toLower('syn${p_nameIdentifier}'), '-', '')

@description('Managed Snapse resource group name')
var v_managedResourceGroupName = 'rg-${p_nameIdentifier}-managed'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////
 
// Create a Synapse Analytics workspace
resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01' =  {
  name: v_synapseWorkspaceName
  location: p_location
  identity: {
    type: p_identityType
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: o_accountUrl
      filesystem: p_containerAcctName
    }
    publicNetworkAccess: p_publicNetworkAccess
    sqlAdministratorLogin: p_sqlAdministratorLogin
    sqlAdministratorLoginPassword: p_sqlAdministratorLoginPassword
    managedResourceGroupName: v_managedResourceGroupName
    managedVirtualNetwork: p_managedVirtualNetwork
    managedVirtualNetworkSettings: {
      preventDataExfiltration: p_preventDataExfiltration
    }
    encryption: {
      cmk: {
        kekIdentity: {
          useSystemAssignedIdentity: p_useSystemAssignedIdentity
        }
        key: {
          keyVaultUrl: p_keyUrl
          name: p_workspaceKeyName
        }
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////
@description('Synapse workspace name')
output o_workspaceName string = synapseWorkspace.name
@description('Synapse workspace Id')
output o_workspaceId string = synapseWorkspace.id
@description('Principal Id for System managed Identity')
output o_systemManagedIdentity string = synapseWorkspace.identity.principalId
