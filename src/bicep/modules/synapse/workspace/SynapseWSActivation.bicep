///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module activates Synapse Workspace using AZ cli command. AZ cli is introduce because of bug in Bicep activate command
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////
@description('Subscription Id')
param p_subscription  string= subscription().subscriptionId

@description('Name of the Synapse workspace')
param p_workspaceName string

@description('Name of the Synapse workspace key')
param p_workspaceKeyName string

@description('URL for Keyvault to retrieve username and passwords ')
param p_keyUrl string

@description('Name of resource group where the workspace will be created')
param p_resourceGroupName string = resourceGroup().name
 
@description('Location of Synapse workspace resource group')
param p_location string = resourceGroup().location

@description('UTC time')
param utcValue string = utcNow()
 
@description('AZ Cli version for AZ commands')
param p_azCliVersion string = '2.30.0'
 
@description('Timeout for the deployment scripts')
param p_deployScriptTimeout string = 'PT10M' 

@description('Id of user assigned identity to execute deployment script')
param p_userAssignedIdentities string
  


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

 
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////
 
// Activate workspace with CMK & System managed Identity 
resource synapseWSactivation 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'synapseWSactivation'
  location: p_location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${p_userAssignedIdentities}' : {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: p_azCliVersion
    timeout: p_deployScriptTimeout
    scriptContent: 'az synapse workspace activate --subscription ${p_subscription} --workspace-name ${p_workspaceName} --resource-group ${p_resourceGroupName}  --name ${p_workspaceKeyName} --key-identifier ${p_keyUrl}'
    retentionInterval:  'P1D'
    }
 }

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Output Section
///////////////////////////////////////////////////////////////////////////////////////////////////////

