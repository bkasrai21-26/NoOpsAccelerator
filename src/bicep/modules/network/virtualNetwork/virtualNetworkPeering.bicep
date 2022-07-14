/* **********************************************************************************
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* ********************************************************************************** 
 * Module: virtualNetworkPeering.bicep
 * Scope: resourceGroup
 * The following are required parameters when calling this module 
 * p_virtualNetworkName string - Property to set the name of the virtual network to add the peering to. This should be in the same resource group specified by the scope.
 * p_remoteVirtualNetworkName string -  Property to identify the virtual network name of the remote network.
 * p_remoteVirtualNetworkResourceGroupName string - Property to identify the virtual network resource group name of the remote network.
 * p_remoteVirtualNetworkSubscriptionId string -  Property to identify the virtual network subscription ID of the remote network.
 * p_allowForwardedTraffic bool - Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network.
 * p_allowGatewayTransit bool -If gateway links can be used in remote virtual networking to link to this virtual network 
 * p_allowVirtualNetworkAccess bool - Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space.	
 * p_useRemoteGateways bool - If remote gateways can be used on this virtual network. If the flag is set to true, and allowGatewayTransit on remote peering is also true, virtual network will use gateways of remote virtual network for transit. Only one peering can have this flag set to true. This flag cannot be set if virtual network already has a gateway.
 *********************************************************************************  */
targetScope = 'resourceGroup' 

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

@description('the virtual network name to peer to a remote virtual network.')
param p_virtualNetworkName string
//param p_virtualNetworkResourceGroupName string
//param p_virtualNewtorkSubscriptionId string = subscription().subscriptionId

@description('The remote virtual network to peer.')
param p_remoteVirtualNetworkName string
@description('The remote virtual network resource group name to peer.')
param p_remoteVirtualNetworkResourceGroupName string
@description('The remote virtual network subscription id to peer.')
param p_remoteVirtualNetworkSubscriptionId string = subscription().subscriptionId

@description('Should we allow forwarded traffic from this virtual network.')
param p_allowForwardedTraffic bool = true
@description('Should we allow gateway transit to the remote virtual network.')
param p_allowGatewayTransit bool = true
@description('Should the remote virtual network have access to the virtual network.')
param p_allowVirtualNetworkAccess bool = true
@description('Should we use  gateways on the remote virtual network.')
param p_useRemoteGateways bool = false

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: p_virtualNetworkName
}

resource remoteVirtualNetworkResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: p_remoteVirtualNetworkResourceGroupName
  scope: subscription(p_remoteVirtualNetworkSubscriptionId)
}

resource remoteVirtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: p_remoteVirtualNetworkName
  scope: remoteVirtualNetworkResourceGroup
}

resource virtualNetworkPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: '${p_virtualNetworkName}-to-${p_remoteVirtualNetworkName}'
  parent: virtualNetwork
  properties: {
    allowForwardedTraffic: p_allowForwardedTraffic
    allowGatewayTransit: p_allowGatewayTransit
    allowVirtualNetworkAccess: p_allowVirtualNetworkAccess
    remoteVirtualNetwork: {
      id: remoteVirtualNetwork.id
    }
    useRemoteGateways: p_useRemoteGateways
  }
}

/* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */
