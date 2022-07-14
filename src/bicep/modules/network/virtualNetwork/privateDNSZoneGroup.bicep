/* ********************************************************************************** 
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* ********************************************************************************** 
 * Module: privateDNSZone.bicep
 * Scope: resourceGroup
 * The following are required parameters when calling this module 
 * p_privateDNSZoneName string - The name of the private dns zone
 * p_virtualNetworkName string - The virtual network to link to the private dns zone.
 * p_virtualNetworkResourceGroupName - the virtual network resource group to link to the private dns zone.

 * The following are optional parameters when calling this module
 * p_virtualNetworkSubscriptionId - the virtual network subscription (defaults to resourceGroup subscription)
 * p_tags object - Property to configure azure tags on the resource.
 *********************************************************************************  */

 targetScope = 'resourceGroup'

 /* **********************************************************************************
  * Section for Bicep parameters 
  * ********************************************************************************** */
 @description('Name for the DNS')
 param p_name string = 'default'

 @description('Id of  DNS Zone')
 param p_privateDnsZoneId string 

 @description('Name of DNS group')
 param p_dnsGroupName string 

 
 /* **********************************************************************************
  * Section for Bicep variables 
  * ********************************************************************************** */

 
 /* **********************************************************************************
  * Section for Bicep resources 
  * ********************************************************************************** */
  resource privateDNSZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-02-01' = {
    name: '${p_name}/${p_dnsGroupName}'
    properties: {
      privateDnsZoneConfigs:  [
        {
        name: 'dnsConfig-${p_name}'
        properties: {
          privateDnsZoneId: p_privateDnsZoneId
        }
      }
    ]
    }
  }
 /* **********************************************************************************
  * Section for Bicep outputs 
  * ********************************************************************************** */
 
