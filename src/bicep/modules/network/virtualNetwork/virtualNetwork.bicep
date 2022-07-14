/* **********************************************************************************
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* **********************************************************************************
* This resource creates Azure virtual network and related services
* Assign appropriate defaults as needed. If needed override global parameters
* ********************************************************************************** */


 targetScope='resourceGroup'

 /* **********************************************************************************
  * Section for Bicep parameters 
  * ********************************************************************************** */
 
 @description('The name of the virtual network.')
 param p_name string
 
 @description('The virtual network address space. For default subnets use a /24 class C network')
 param p_vnetAddressSpace string
 
 @description('The subnets to deploy to the virtual network')
 param p_subnetName string 
  
 @description('The location to deploy the virtual network')
param p_location string = resourceGroup().location

 @description('The tags to associate to the virtual network')
 param p_tags object = {}

 @description('Enable end point for Subnet; Disable for endpoint')
 param p_privateEndpointNetworkPolicies string = 'Disabled'

 @description('Network security group to associate with subnet')
 param p_networkSecurityGroupId string
 
  
 /* **********************************************************************************
  * Section for Bicep variables 
  * ********************************************************************************** */
 
 var v_mddTag = {
   MDDTagName: 'MDD1'
 }
 var v_tags = union(v_mddTag, p_tags)
 

 @description('Address space of subnet')
 var p_addressPrefix = '${substring(p_vnetAddressSpace, 0, lastIndexOf(p_vnetAddressSpace, '.')-1)}0.128/25'


 /* **********************************************************************************
  * Section for Bicep resources 
  * ********************************************************************************** */
  resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' = {
   name: p_name
   location: p_location
   tags: v_tags
   properties: {
     addressSpace: {
       addressPrefixes: [
         p_vnetAddressSpace
       ]
     }
     subnets: [
       {
       name: 'snet-${p_subnetName}'
       properties: {
         addressPrefix: p_addressPrefix
         networkSecurityGroup: {
           id: p_networkSecurityGroupId
         }
         privateEndpointNetworkPolicies: p_privateEndpointNetworkPolicies
       }
     }
    ]
   }
 }

 /* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */
output o_id string = virtualNetwork.id
output o_virtualNetworkName string = virtualNetwork.name
output o_virtualNetworkAddress string = virtualNetwork.properties.addressSpace. addressPrefixes[0]
output o_virtualNetworkResourceGroup string = resourceGroup().name
output o_vnetSubscriptionId string = subscription().subscriptionId
output o_subnetId string = virtualNetwork.properties.subnets[0].id
output o_subnetName string = virtualNetwork.properties.subnets[0].name
