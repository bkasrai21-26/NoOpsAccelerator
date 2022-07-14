///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module introduces wait for Synapse operation to prevent failures of preceding Synapse operations
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////

 
@description('Name of the Synapse workspace')
param p_workspaceName string
 
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

@description('Timeout for az synapse wait command')
param p_azTmeout int =  60

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep Resources
///////////////////////////////////////////////////////////////////////////////////////////////////////


// Wait for Synapse workspace to be available
 
resource resourceExists 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'resourceExists'
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
  scriptContent: 'az synapse workspace wait --workspace-name ${p_workspaceName} --resource-group ${p_resourceGroupName} --exists --timeout ${p_azTmeout}'
  retentionInterval:  'P1D'
 }
}

 ///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////


