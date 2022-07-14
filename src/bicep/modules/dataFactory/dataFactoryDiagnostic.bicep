/* **********************************************************************************
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* **********************************************************************************
* This resource configure logAnlytics with data factory diagnostic settings
* ********************************************************************************** */

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */
@description('LogAnalytics workspace Id')
param p_logAnalyticsWorkspaceId string

@description('DataFactory resource name')
param p_dataFactory string

@description('log analytics resource name')
param p_logAnalyticsResourceGroupName string 

@description('diagnostics storage name')
param p_diagnosticStorageAccountName string

/* **********************************************************************************
 * Section for Bicep variable 
 * ********************************************************************************** */

var v_metrics = [
  {
    enabled: true
    category: 'AllMetrics'
  }
]

var v_logs = [
  {
    enabled: true
    category: 'ActivityRuns'
  }
  {
    enabled: true
    category: 'PipelineRuns'
  }
  {
    enabled: true
    category: 'TriggerRuns'
  }
  {
    enabled: true
    category: 'SandboxPipelineRuns'
  }
  {
    enabled: true
    category: 'SandboxActivityRuns'
  }
  {
    enabled: true
    category: 'SSISPackageEventMessages'
  }
  {
    enabled: true
    category: 'SSISPackageExecutableStatistics'
  }
  {
    enabled: true
    category: 'SSISPackageEventMessageContext'
  }
  {
    enabled: true
    category: 'SSISPackageExecutionComponentPhases'
  }
  {
    enabled: true
    category: 'SSISPackageExecutionDataStatistics'
  }
  {
    enabled: true
    category: 'SSISIntegrationRuntimeLogs'
  }
]

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */

 resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01'  existing = {
  name: p_dataFactory
 }

 resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
   name: p_diagnosticStorageAccountName
   scope:resourceGroup(p_logAnalyticsResourceGroupName)
 } 
 
 //// Setting for data factory to collect its own diagnostics to itself and to storage
 resource logAnalyticsDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
   name: 'deploy-${p_dataFactory}-diag'
   dependsOn: [
    dataFactory
  ]
  scope: dataFactory
   properties: {
     workspaceId: p_logAnalyticsWorkspaceId
     storageAccountId: stg.id
     metrics: [for metric in v_metrics:{
         category: metric.category
         enabled: metric.enabled
       }]
      logs: [for log in v_logs:{
      category: log.category
      enabled: log.enabled
    }]
   }
 }

/* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */

 output o_workspaceId string = p_logAnalyticsWorkspaceId

