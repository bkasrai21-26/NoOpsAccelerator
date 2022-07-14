///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module enables alert policies  for SQL database
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

@description('Specifies the number of days to keep in the audit logs in the storage account')
param p_retentionDays int = 30

@description('Enables alert to be sent to account administrators.')
param p_emailAccountAdmins bool = true

@description('List of email addresses for alerts')
param p_emailAddresses array 

@description('Specifies the state of the policy')
param p_state string = 'Enabled'

@description('Specifies an array of alerts that are disabled. Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action')
param p_disabledAlerts array = []

@description('Name of SQL server')
param p_sqlServerName string

@description('SQL database name')
param p_sqlDBName string

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

resource sqlServerName 'Microsoft.Sql/managedInstances@2021-05-01-preview' existing = {
  name: p_sqlServerName
}

resource sqlDB 'Microsoft.Sql/managedInstances/databases@2021-05-01-preview' existing = {
  parent: sqlServerName
  name: p_sqlDBName
 }

  resource synapseSQLPoolAlertPolicies  'Microsoft.Sql/managedInstances/databases/securityAlertPolicies@2021-05-01-preview' = {
    name: 'default'
    parent: sqlDB
    properties: {
      disabledAlerts: p_disabledAlerts
      emailAccountAdmins: p_emailAccountAdmins
      emailAddresses: p_emailAddresses
      retentionDays: p_retentionDays
      state: p_state
      storageAccountAccessKey: p_storageAccountAccessKey
      storageEndpoint: p_storageEndpoint
    }
  }

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep outout
///////////////////////////////////////////////////////////////////////////////////////////////////////
