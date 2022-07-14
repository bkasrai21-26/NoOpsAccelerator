///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module set audit settings for SQL server
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Storage access key for storing vulnerability assessment scan results')
param p_storageAccountAccessKey string

@description('Storage endpoint for storing vulnerability assessment scan results')
param p_storageEndpoint string 

@description('Action groups and actions to audit. For complete list see https://docs.microsoft.com/en-us/azure/templates/microsoft.synapse/workspaces/auditingsettings?tabs=bicep#serverblobauditingpolicyproperties')
param p_auditActionsAndGroups array = [
  'BATCH_COMPLETED_GROUP'
  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
  'FAILED_DATABASE_AUTHENTICATION_GROUP'
]

@description('Specifies whether audit events are sent to Azure Monitor. Parameters "state" must be "Enabled" and "isAzureMonitorTargetEnabled" must be set to true.')
param p_isAzureMonitorTargetEnabled bool = false

@description('Specifies whether storageAccountAccessKey value is the storage secondary key')
param p_isStorageSecondaryKeyInUse bool = false

@description('Specifies the number of days to keep in the audit logs in the storage account')
param p_retentionDays int = 30

@description('Specifies the state of the policy. If state is Enabled, storageEndpoint or isAzureMonitorTargetEnabled are required')
param p_state string = 'Enabled'

@description('Specifies the blob storage subscription Id')
param p_storageAccountSubscriptionId string 

@description('Name of SQL server')
param p_sqlServerName string

@description('Amount of time in milliseconds that can elapse before audit actions are forced to be processed')
param p_queueDelayMs int = 1000

@description('Enable audit of Devops to Azure Monitors')
param p_isDevopsAuditEnabled bool = false

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

resource sqlServer 'Microsoft.Sql/managedInstances@2021-05-01-preview' existing = {
  name: p_sqlServerName
}

resource sqlAuditSettings 'Microsoft.Sql/managedInstances/auditingSettings@2021-05-01-preview' = {
    name: 'default'
    parent: sqlServer
    properties: {
      auditActionsAndGroups: p_auditActionsAndGroups
      isAzureMonitorTargetEnabled: p_isAzureMonitorTargetEnabled
      isStorageSecondaryKeyInUse: p_isStorageSecondaryKeyInUse
      isDevopsAuditEnabled: p_isDevopsAuditEnabled
      retentionDays: p_retentionDays
      queueDelayMs: p_queueDelayMs
      state: p_state
      storageAccountAccessKey: p_storageAccountAccessKey
      storageAccountSubscriptionId: p_storageAccountSubscriptionId
      storageEndpoint: p_storageEndpoint
    }
  }

/*   resource sqlDevOpsAuditSettings 'Microsoft.Sql/managedInstances/devOpsAuditingSettings@2021-05-01-preview' = {
    name:'default'
    parent: sqlServer
    properties: {
      isAzureMonitorTargetEnabled: p_isAzureMonitorTargetEnabled
      state: p_state
      storageAccountAccessKey: p_storageAccountAccessKey
      storageAccountSubscriptionId: p_storageAccountSubscriptionId
      storageEndpoint: p_storageEndpoint
    }
  }
 */

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep outout
///////////////////////////////////////////////////////////////////////////////////////////////////////
