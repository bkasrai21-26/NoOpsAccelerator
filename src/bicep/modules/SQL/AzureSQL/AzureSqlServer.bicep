///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module creates Synapse Workspace. A wait time is introduced so that activate workspace succeeds. 
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////
@description('Synapse sql admin user')
param p_sqlAdministratorLogin string = 'sqladmin'

@description('Synapse sql admin password  - Temp  will implememt key vault')
@secure()
param p_sqlAdministratorLoginPassword string

@description('The Azure region where all resources in this example should be created')
param p_location string = resourceGroup().location

@description('The name of the SQL logical server.')
param p_sqlServerName string

@description('Whether or not public endpoint access is allowed for this server')
param p_publicNetworkAccess string = 'Disabled'

@description('Whether or not public endpoint access is allowed for this server')
param p_restrictOutboundNetworkAccess string = 'Disabled'

@description('The name of the key URI for CMK')
param p_keyId string = ''

param p_enableCMK bool = false

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

var v_properties =  p_enableCMK ? {
  administratorLogin: p_sqlAdministratorLogin
  administratorLoginPassword: p_sqlAdministratorLoginPassword
  publicNetworkAccess: p_publicNetworkAccess
  restrictOutboundNetworkAccess: p_restrictOutboundNetworkAccess
  keyId: p_keyId
}:{
  administratorLogin: p_sqlAdministratorLogin
  administratorLoginPassword: p_sqlAdministratorLoginPassword
  publicNetworkAccess: p_publicNetworkAccess
  restrictOutboundNetworkAccess: p_restrictOutboundNetworkAccess
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

resource sqlServerName 'Microsoft.Sql/servers@2021-05-01-preview' = {
  name: p_sqlServerName
  location: p_location
  properties: v_properties
  identity:{
    type: 'SystemAssigned'
    } 
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////

output o_id string = sqlServerName.id
output o_name string = sqlServerName.name
output o_principalId string = sqlServerName.identity.principalId
