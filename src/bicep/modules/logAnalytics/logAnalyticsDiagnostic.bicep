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
@description('LogAnalytics workspace name')
param p_logAnalyticsWorkspaceName string

@description('LogAnalytics storage name')
param p_diagnosticStorageAccountName string



/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */
 
 resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
   name: p_logAnalyticsWorkspaceName
 }
 
 resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
   name: p_diagnosticStorageAccountName
 } 
 
 //// Setting log analytics to collect its own diagnostics to itself and to storage
 resource logAnalyticsDiagnostics 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
   name: 'enable-log-analytics-diagnostics'  
   scope: logAnalyticsWorkspace
   properties: {
     workspaceId: logAnalyticsWorkspace.id
     storageAccountId: stg.id
     logs: [
       {
         category: 'Audit'
         enabled: true
       }
     ]
     metrics: [
       {
         category: 'AllMetrics'
         enabled: true
       }
     ]
   }
 }

/* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */

 output o_workspaceId string = logAnalyticsWorkspace.id

