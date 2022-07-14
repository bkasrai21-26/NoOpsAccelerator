///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module creates Azure Public IP Address
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

targetScope='resourceGroup'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('unique name identifier')
param p_nameIdentifier string 
 
@description('The location to deploy the virtual network.')
param p_location string = resourceGroup().location

@description('The tags to associate to the virtual network.')
param p_tags object = {}

@description('SKU for the Public IP used to access the Virtual Machine.')
@allowed([
  'Basic'
  'Standard'
])
param p_publicIpSku string = 'Basic'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param p_publicIPAllocationMethod string = 'Dynamic'

@description('List of availability zones denoting the IP allocated for the resource needs to come from')
param p_availabilityZones array = []

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

var v_mddTag = {
 MDDTagName: 'MDD1'
}
var v_tags = union(v_mddTag, p_tags)

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
var p_dnsLabelPrefix = toLower('${p_nameIdentifier}-${uniqueString(resourceGroup().id, p_nameIdentifier)}')

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

resource pip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: 'pip-${p_nameIdentifier}'
  location: p_location
  tags: v_tags
  zones: p_availabilityZones
  sku: {
    name: p_publicIpSku
  }
  properties: {
    publicIPAllocationMethod: p_publicIPAllocationMethod
    dnsSettings: {
      domainNameLabel: p_dnsLabelPrefix
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep Output
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Public IP address')
output o_publicIpId string = pip.id
