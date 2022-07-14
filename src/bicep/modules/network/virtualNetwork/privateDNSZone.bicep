///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module creates private DNS zones
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////


 targetScope = 'resourceGroup'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Name of private DNS Zone')
param p_name string

@description('The virtual network id to associate to the private dns zone.')
param p_virtualNetworkId string
 
@description('The virtual network name to associate to the private dns zone.')
param p_virtualNetworkName string 
 
@description('The virutal network subscription id to associate the private dns zone.')
param p_virtualNetworkSubscriptionId string = subscription().subscriptionId
 
@description('The tags to associate to the private DNS Zone.')
param p_tags object

@description('DNS zone location')
param p_pdnsz_location string = 'global'
 
@description('Enable Dynamic registration')
param p_registrationEnabled bool = false

@description('Resource group name for virtual network')
param p_virtualNetworkResourceGroupName string 

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

var v_mddTag = {
   MDDTagName: 'MDD1'
}
var v_tags = union(v_mddTag, p_tags)
 
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

resource virtualNetworkResourceGroup 'Microsoft.Resources/resourceGroups@2021-01-01' existing = {
   name: p_virtualNetworkResourceGroupName
   scope: subscription(p_virtualNetworkSubscriptionId)
 }
 
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
   name: p_virtualNetworkName
   scope: virtualNetworkResourceGroup
 }
 
resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
   name: p_name
   location: p_pdnsz_location
   tags: v_tags
 
resource virtualNetworkLink 'virtualNetworkLinks' = {
     name: '${uniqueString(privateDNSZone.name)}'
     location: p_pdnsz_location 
     tags: v_tags
     properties: {
       registrationEnabled: p_registrationEnabled
       virtualNetwork: {
         id: p_virtualNetworkId 
       }
     }
   }
 }
 

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////

  output o_pdnsId string = privateDNSZone.id
 output o_pdnsName string = privateDNSZone.name
 