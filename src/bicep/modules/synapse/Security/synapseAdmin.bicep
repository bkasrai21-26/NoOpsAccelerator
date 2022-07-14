/* **********************************************************************************
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* **********************************************************************************
--------------------------------------------------------------
#
# This resource creates Synapse spark pool with autoscaling turned on.
# 
# Assign appropriate defaults as needed. If needed override global parameters
#
* ********************************************************************************** */

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

@description('Prefix for  Synapse Workspace Name.')
param p_workspaceName string

@description('Role for Synapse AAD user')
param p_administratorType string = 'Synapse Administrator'

@description('Object Id for Synaspe AAD user')
param p_objectId string

@description('Email Address of Synapse AAD user')
param p_loginName string

/* **********************************************************************************
 * Section for Bicep variables
 * ********************************************************************************** */

var v_tenantId = subscription().tenantId

/* **********************************************************************************
 * Section for Bicep resources
 * ********************************************************************************** */

 resource synapseWorkspace 'Microsoft.Synapse/workspaces@2021-06-01'  existing = {
  name: p_workspaceName
  }
resource synapseAdmin 'Microsoft.Synapse/workspaces/administrators@2021-06-01' = {
  name: 'activeDirectory'
  parent: synapseWorkspace
  properties: {
    administratorType: p_administratorType
    login: p_loginName
    sid: p_objectId
    tenantId: v_tenantId
  }
}
