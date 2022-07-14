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

@description('LogAnalytics workspace Name')
param p_logAnalyticsWorkspaceName string

param p_location string

param p_tags object = {}

param p_logRetentionInDays int = 30

param p_skuName string = 'PerGB2018'

param p_workspaceCappingDailyQuotaGb int = -1

@description('Whether or not to deploy Sentinel solution to workspace.')
param p_deploySentinel bool = false

// Solutions to add to workspace
var v_solutions = [
  {
    deploy: true
    name: 'AzureActivity'
    product: 'OMSGallery/AzureActivity'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  {
    deploy: p_deploySentinel
    name: 'SecurityInsights'
    product: 'OMSGallery/SecurityInsights'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  {
    deploy: true
    name: 'VMInsights'
    product: 'OMSGallery/VMInsights'
    publisher: 'Microsoft'
    promotionCode: '' 
  }
  {
    deploy: true
    name: 'Security'
    product: 'OMSGallery/Security'
    publisher: 'Microsoft'
    promotionCode: ''
  }
  {
    deploy: true
    name: 'ServiceMap'
    publisher: 'Microsoft'
    product: 'OMSGallery/ServiceMap'
    promotionCode: ''
  }
  {
    deploy: true
    name: 'ContainerInsights'
    publisher: 'Microsoft'
    product: 'OMSGallery/ContainerInsights'
    promotionCode: ''
  }
  {
    deploy: true
    name: 'KeyVaultAnalytics'
    publisher: 'Microsoft'
    product: 'OMSGallery/KeyVaultAnalytics'
    promotionCode: ''
  }
]

@description('Enable lock to prevent accidental deletion')
param p_enableDeleteLock bool = true

var lockName = '${logAnalyticsWorkspace.name}-lock'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: p_logAnalyticsWorkspaceName
  location: p_location
  tags: p_tags
  properties: {
    retentionInDays: p_logRetentionInDays
    sku:{
      name: p_skuName
    }
    workspaceCapping: {
      dailyQuotaGb: p_workspaceCappingDailyQuotaGb
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource logAnalyticsSolutions 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = [for solution in v_solutions: if(solution.deploy) {
  name: '${solution.name}(${logAnalyticsWorkspace.name})'
  location: p_location
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: '${solution.name}(${logAnalyticsWorkspace.name})'
    product: solution.product
    publisher: solution.publisher
    promotionCode: solution.promotionCode
  }
}]

resource lock 'Microsoft.Authorization/locks@2016-09-01' = if (p_enableDeleteLock) {
  scope: logAnalyticsWorkspace
  name: lockName
  properties: {
    level: 'CanNotDelete'
  }
}

/* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */
output o_logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
output o_logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
output o_logAnalyticsResourceGroup string = resourceGroup().name

