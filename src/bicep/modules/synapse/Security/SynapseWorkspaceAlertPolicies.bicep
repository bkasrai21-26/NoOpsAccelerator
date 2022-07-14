///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module enables alerts for Synapse workspace
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Name of Synapse Workspace Name')
param p_workspaceName string

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

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01'  existing = {
  name: p_workspaceName
}

  resource synapseAlertPolicies 'Microsoft.Synapse/workspaces/securityAlertPolicies@2021-06-01' = {
    name: 'Default'
    parent: synapseWorkspace
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
