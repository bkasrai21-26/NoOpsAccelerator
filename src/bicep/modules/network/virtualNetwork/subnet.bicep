
/* **********************************************************************************
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* **********************************************************************************
* This resource creates Subnet. Redeploy will fail due to bug.
* Assign appropriate defaults as needed. If needed override global parameters
* ********************************************************************************** */

 targetScope='resourceGroup'

 /* **********************************************************************************
  * Section for Bicep parameters 
  * ********************************************************************************** */

@description('Subnet address space')
param p_subnetAddressPrefix string = '10.1.1.0/24'

@description('Name of VNET this subnet is attached to')
param p_vnetName string ='vnet-testscotgr'

@description('Name of the subnet')
param p_subnetName string ='subnet-miV4'

@description('Enable or disable private endpoint network policy')
param p_privateEndpointNetworkPolicies string = 'Disabled'

@description('delegation Azure service name')
param p_delegationServiceName string = 'Microsoft.Sql/managedInstances'

@description('delegation name')
param p_delegationName string = 'delgSQLMI'

@description('network security group ID')
param p_networkSecurityGroupId string = ''

@description('routing table ID')
param p_routeTableId string = ''

/* **********************************************************************************
 * Section for Bicep variables 
 * ********************************************************************************** */

 var v_delegations = (p_delegationName != '') ? [
  {
    name: p_delegationName
    properties:{
      serviceName: p_delegationServiceName
    }
  }
  ]:[]

 var v_networkSecurityGroupId = (p_networkSecurityGroupId != '') ? {
    id: p_networkSecurityGroupId
 }:null

 var v_routeTableId = (p_routeTableId != '') ? {
  id: p_routeTableId
}:null

var v_properties = {
  addressPrefix: p_subnetAddressPrefix
    privateEndpointNetworkPolicies: p_privateEndpointNetworkPolicies
    delegations: v_delegations
    networkSecurityGroup: v_networkSecurityGroupId
    routeTable: v_routeTableId
    
}

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */
 resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: p_vnetName
}

 resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  name: p_subnetName
  parent:existingVirtualNetwork
  properties: v_properties
 }

/* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */

 output o_subnetId string = subnet.id
 output o_subnetName string = subnet.name
 output o_subnetAddressPrefix  string = subnet.properties.addressPrefix

