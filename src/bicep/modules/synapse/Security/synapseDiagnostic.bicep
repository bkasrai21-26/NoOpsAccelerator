/* **********************************************************************************
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* **********************************************************************************
* This resource creates Azure virtual network and related services
* Assign appropriate defaults as needed. If needed override global parameters
* ********************************************************************************** */

/* ********************************************************************************** 
 * Module: logAnalytics.bicep
 * Scope: resourceGroup

 *********************************************************************************  */

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */
@description('LogAnalytics workspace Id')
param p_logAnalyticsWorkspaceId string

@description('Synapse Analytics workspace name')
param p_synapseWorkspaceName string

@description('log analytics resource name')
param p_logAnalyticsResourceGroupName string

@description('diagnostics storage name')
param p_diagnosticStorageAccountName string

/* **********************************************************************************
 * Section for Bicep variables 
 * ********************************************************************************** */
var v_logs = [
  {
    enabled: true
    category: 'BuiltinSqlReqsEnded'
  }
  {
    enabled: true
    category: 'SynapseRbacOperations'
  }
  {
    enabled: true
    category: 'GatewayApiRequests'
  }
  {
    enabled: true
    category: 'IntegrationPipelineRuns'
  }
  {
    enabled: true
    category: 'IntegrationActivityRuns'
  }
  {
    enabled: true
    category: 'IntegrationTriggerRuns'
  }
]

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-04-01-preview' existing = {
  name: p_synapseWorkspaceName
}

resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: p_diagnosticStorageAccountName
  scope: resourceGroup(p_logAnalyticsResourceGroupName)
}

//// Setting log analytics to collect its own diagnostics to itself and to storage
resource logAnalyticsDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: p_synapseWorkspaceName
  dependsOn: [
    synapseWorkspace
  ]
  scope: synapseWorkspace
  properties: {
    workspaceId: p_logAnalyticsWorkspaceId
    storageAccountId: stg.id

    logs: [for log in v_logs: {
      category: log.category
      enabled: log.enabled
    }]
  }
}

/* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */

output o_workspaceId string = p_logAnalyticsWorkspaceId
