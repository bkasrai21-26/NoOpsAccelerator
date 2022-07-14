///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module implements diagnostic settings for Synapse
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////


@description('Resource of Log Analytics') 
param p_logAnalyticsWorkspaceId string
   
 @description('Resource Id of storage account') 
param p_diagnosticStorageAccountid string
   
@description('Name of Synapse Workspace Name')
param p_workspaceName string

@description('Specifies the retention policy for the log')
param p_logDays int = 30

@description('Enable retention policy for log')
param p_logRetEnabled bool = true

@description('Log category for Synapse')
var p_logCategory = [
  {
  category: 'SynapseRbacOperations'
  enabled: true 
  }
  {
  category: 'GatewayApiRequests'
  enabled: true 
  }
  {
  category: 'BuiltinSqlReqsEnded'
  enabled: true 
  }
  {
  category: 'IntegrationPipelineRuns'
  enabled: true 
  }
  {
  category: 'IntegrationActivityRuns'
  enabled: true 
  }
  {
  category: 'IntegrationTriggerRuns'
  enabled: true 
  }
]

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

 resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01'  existing = {
  name: p_workspaceName
  
}

  //// Collecting diagnostics to log analytics  and storage
 resource synpaseLogAnalyticsDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' =  {
   name: 'synapseLogdiagnostics'  
   scope: synapseWorkspace
   properties: {
     workspaceId: p_logAnalyticsWorkspaceId
     storageAccountId: p_diagnosticStorageAccountid
     logs: [ for log in p_logCategory:  {
         category: log.category
         enabled: log.enabled
         retentionPolicy: {
          days: p_logDays
          enabled: p_logRetEnabled
        }
       }]
   }
 }

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////



