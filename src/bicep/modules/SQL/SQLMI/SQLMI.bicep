///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module creates SQL MI. A wait time is introduced so that activate workspace succeeds. 
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
param p_sqlAdministratorLoginPassword string = newGuid()

@description('The Azure region where all resources in this example should be created')
param p_location string = resourceGroup().location

@description('The name of the SQL logical server.')
param p_sqlServerName string

@allowed([
  'GeneralPurpose'
  'BusinessCritical'
])
@description('SKU Edition (GeneralPurpose, BusinessCritical)')
param p_skuEdition string = 'GeneralPurpose'

@allowed([
  'GP_Gen4'
  'GP_Gen5'
  'BC_Gen4'
  'BC_Gen5'
])
@description('SKU NAME (GP_Gen4, GP_Gen5, BC_Gen4, BC_GEN5)')
param p_skuName string = 'GP_Gen5'

@description('Amount of Storage in GB for this instance. Minimum value: 32. Maximum value: 8192. Increments of 32 GB allowed only.')
param p_storageSizeInGB int = 32

@allowed([
  4
  8
  16
  24
  32
  40
  64
  80
])
@description('The number of vCores. Allowed values: 4, 8, 16, 24, 32, 40, 64, 80.')
param p_vCores int = 8

@allowed([
  'BasePrice'
  'LicenseIncluded'
])
@description('Type of license: BasePrice (BYOL) or LicenceIncluded')
param p_licenseType string = 'LicenseIncluded'

@description('SQL Collation')
param p_collation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Id of the timezone. Allowed values are timezones supported by Windows. List of Ids can also be obtained by executing [System.TimeZoneInfo]::GetSystemTimeZones() in PowerShell.')
param p_timeZoneId string = 'Eastern Standard Time'

@allowed([
  'Gen4'
  'Gen5'
])
@description('Hardware family (Gen4, Gen5)')
param p_hardwareFamily string = 'Gen5'

@allowed([
  'Proxy'
  'Redirect'
  'Default'
])
@description('Connection type used for connecting to the instance. - Proxy, Redirect, Default')
param p_proxyOverride string = 'Proxy'

@description('Whether or not public endpoint access is allowed for this server')
param p_publicNetworkAccess string = 'Enabled'

@description('Whether or not to restrict outbound network access')
param p_restrictOutboundNetworkAccess string = 'Enabled'

@description('The subnet Id value')
param p_subnetId string = ''

@description('The name of the key URI for CMK')
param p_keyId string = ''

@description('enable CMK')
param p_enableCMK bool = false

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

var v_properties =  p_enableCMK ? {
  administratorLogin: p_sqlAdministratorLogin
  administratorLoginPassword: p_sqlAdministratorLoginPassword
  publicNetworkAccess: p_publicNetworkAccess
  restrictOutboundNetworkAccess: p_restrictOutboundNetworkAccess
  licenseType: p_licenseType
  vCores: p_vCores
  storageSizeInGB: p_storageSizeInGB
  collation: p_collation
  publicDataEndpointEnabled: false
  deployInExistingSubnet:true
  proxyOverride: p_proxyOverride
  timezoneId: p_timeZoneId
  subnetId:p_subnetId
  keyId: p_keyId
}:{
  administratorLogin: p_sqlAdministratorLogin
  administratorLoginPassword: p_sqlAdministratorLoginPassword
  publicNetworkAccess: p_publicNetworkAccess
  restrictOutboundNetworkAccess: p_restrictOutboundNetworkAccess
  licenseType: p_licenseType
  vCores: p_vCores
  storageSizeInGB: p_storageSizeInGB
  collation: p_collation
  publicDataEndpointEnabled: false
  deployInExistingSubnet:true
  proxyOverride: p_proxyOverride
  timezoneId: p_timeZoneId
  subnetId:p_subnetId
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

resource sqlServerName 'Microsoft.Sql/managedInstances@2021-05-01-preview' = {
  name: p_sqlServerName
  location: p_location
  sku: {
    name: p_skuName
    tier: p_skuEdition
    family: p_hardwareFamily
  }
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
