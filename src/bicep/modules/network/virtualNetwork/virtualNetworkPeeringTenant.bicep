/* **********************************************************************************
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* ********************************************************************************** 
 * Module: virtualNetworkPeeringTenant.bicep
 * Scope: tenant
 * The following are required parameters when calling this module 
 
 * p_virtualNetworkName string - Property to set the name of the spoke virtual network.
 * p_virtualNetworkResourceGroupName - Property to set the resource group name of the spoke virtual network.
 * p_virtualNetworkSubscriptionId - Property to set the subscription Id of the spoke virtual network.

 * p_remoteVirtualNetworkName string -  Property to identify the virtual network name of the remote network.
 * p_remoteVirtualNetworkResourceGroupName string - Property to identify the virtual network resource group name of the remote network.
 * p_remoteVirtualNetworkSubscriptionId string -  Property to identify the virtual network subscription ID of the remote network.
 
 *********************************************************************************  */
targetScope='tenant'

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

@description('The virtual network to peer.')
param p_virtualNetworkName string
@description('The virtual network resource group name.')
param p_virtualNetworkResourceGroupName string
@description('The virtual network subscription Id.')
param p_virtualNetworkSubscriptionId string

@description('The remote virtual network to peer.')
param p_remoteVirtualNetworkName string
@description('The remote virtual network resource group name.')
param p_remoteVirtualNetworkResourceGroupName string
@description('The remote virtual network subscription Id.')
param p_remoteVirtualNetworkSubscriptionId string

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */

resource spokeResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: p_virtualNetworkResourceGroupName
  scope: subscription(p_virtualNetworkSubscriptionId)
}

module spokeToHubPeer 'virtualNetworkPeering.bicep' = {
  name: 'spoke-to-hub-peering'
  scope: spokeResourceGroup
    params: {
      p_virtualNetworkName: p_virtualNetworkName
      p_remoteVirtualNetworkName: p_remoteVirtualNetworkName
      p_remoteVirtualNetworkResourceGroupName: p_remoteVirtualNetworkResourceGroupName
      p_remoteVirtualNetworkSubscriptionId: p_remoteVirtualNetworkSubscriptionId
      p_allowForwardedTraffic: true
      p_allowGatewayTransit: false
      p_allowVirtualNetworkAccess: true
      p_useRemoteGateways: true
    }
}

resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
    name: p_remoteVirtualNetworkResourceGroupName
    scope: subscription(p_remoteVirtualNetworkSubscriptionId)
}

module hubToSpokePeer 'virtualNetworkPeering.bicep' = {
  name: 'hub-to-spoke-peering'
  scope: spokeResourceGroup
    params: {
      p_virtualNetworkName: p_virtualNetworkName
      p_remoteVirtualNetworkName: p_remoteVirtualNetworkName
      p_remoteVirtualNetworkResourceGroupName: p_remoteVirtualNetworkResourceGroupName
      p_remoteVirtualNetworkSubscriptionId: p_remoteVirtualNetworkSubscriptionId
      p_allowForwardedTraffic: true
      p_allowGatewayTransit: true
      p_allowVirtualNetworkAccess: true
      p_useRemoteGateways: false
    }
}
