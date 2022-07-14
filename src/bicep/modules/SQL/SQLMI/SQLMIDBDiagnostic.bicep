/* **********************************************************************************
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* **********************************************************************************
* This resource configure logAnlytics with sql server diagnostic settings
* ********************************************************************************** */

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */
@description('LogAnalytics workspace Id')
param p_logAnalyticsWorkspaceId string

@description('The name of the SQL logical server.')
param p_sqlServerName string 
@description('sql resource name')
param p_sqlDB string 

@description('log analytics resource name')
param p_logAnalyticsResourceGroupName string 

@description('diagnostics storage name')
param p_diagnosticStorageAccountName string 

/* **********************************************************************************
 * Section for Bicep variable 
 * ********************************************************************************** */

var v_metrics = [
]

var v_logs = [
  {
    enabled: true
    category: 'SQLInsights'
  }
  {
    enabled: true
    category: 'QueryStoreRuntimeStatistics'
  }
  {
    enabled: true
    category: 'QueryStoreWaitStatistics'
  }
  {
    enabled: true
    category: 'Errors'
  }
]

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */

resource sqlServer 'Microsoft.Sql/managedInstances@2021-05-01-preview' existing = {
  name: p_sqlServerName
 }

 resource sqlDB 'Microsoft.Sql/managedInstances/databases@2021-05-01-preview' existing = {
  name: p_sqlDB
  parent:sqlServer
 }

 resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
   name: p_diagnosticStorageAccountName
   scope:resourceGroup(p_logAnalyticsResourceGroupName)
 } 
 
 //// Setting for data factory to collect its own diagnostics to itself and to storage
 resource logAnalyticsDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
   name: 'deploy-${p_sqlDB}-diag'
   dependsOn: [
    sqlDB
  ]
  scope: sqlDB
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

