///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module creates Azure Network Interface
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

targetScope='resourceGroup'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('location')
param p_location string = 'eastus'

@description('unique name identifier')
param p_nameIdentifier string = 'mddprodeastus'

@description('resource tags')
param p_tags object = {}

@description('Id of Subnet')
param p_subnetId string

@description('Id of network security group')
param p_networkSecurityGroupId string

@description('IP address allocation method')
param p_privateIPAddressAllocationMethod string = 'Dynamic'

@description('Indicates if the network interface is accelerated networking enabled')
param p_enableAcceleratedNetworking bool = false

@description('Indicates whether IP forwarding is enabled on this network interface')
param p_enableIPForwarding bool = false

@description('Associate public IP; If enabled pass public IP')
param p_AssociatepublicIp bool = false

@description('Public Ip address')
param p_publicIpId string =''

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
 
resource networkInterfacePublicIP 'Microsoft.Network/networkInterfaces@2021-02-01' = if (p_AssociatepublicIp == true) {
  name: 'nic-${p_nameIdentifier}-pip'
  location: p_location
  tags: v_tags
  properties: {
    enableAcceleratedNetworking: p_enableAcceleratedNetworking
    enableIPForwarding: p_enableIPForwarding
    ipConfigurations: [
      {
        name: take('${p_nameIdentifier}ipConfigpip',80)
        properties: {
          subnet: {
            id: p_subnetId
          }
          privateIPAllocationMethod: p_privateIPAddressAllocationMethod
          publicIPAddress: {
            id: p_publicIpId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: p_networkSecurityGroupId
    }
  }
}


resource networkInterfaceNoPublicIP 'Microsoft.Network/networkInterfaces@2021-02-01' = if (p_AssociatepublicIp == false) {
  name: 'nic-${p_nameIdentifier}-no-pip'
  location: p_location
  tags: v_tags
  properties: {
    enableAcceleratedNetworking: p_enableAcceleratedNetworking
    enableIPForwarding: p_enableIPForwarding
    ipConfigurations: [
      {
        name: take('${p_nameIdentifier}ipConfig',80)
        properties: {
          subnet: {
            id: p_subnetId
          }
          privateIPAllocationMethod: p_privateIPAddressAllocationMethod
        }
      }
    ]
    networkSecurityGroup: {
      id: p_networkSecurityGroupId
    }
  }
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////

 @description('Network interface Id')
output o_networkInterfaceId string = p_AssociatepublicIp ? networkInterfacePublicIP.id : networkInterfaceNoPublicIP.id

@description('Network interface name')
output o_networkInterfaceName string = p_AssociatepublicIp ? networkInterfacePublicIP.name : networkInterfaceNoPublicIP.name
