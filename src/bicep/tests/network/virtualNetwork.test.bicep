/* **********************************************************************************
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* ********************************************************************************** 
 *  This test a VNET modlue that creates VNET with Subnet and corresponding NSG
 * 
 *  This code MUST be run at the group
 *
 *  Dependencies: module VNET.bicep
 * 
 * run this code by typing the following Azure CLI command: 

 **********************************************************************************  */
targetScope='subscription'

param p_location string

var v_resourceGroupName = 'networkrg55'
var v_namePrefix = 'missiondatadragon55'
var v_vnetAddressSpace = '10.0.0.0/16'
var v_publicAddressPrefix = '10.0.1.0/26'
var v_privateAddressPrefix = '10.0.2.0/26'
var v_azureTag = 'mdd' 
var v_uniqueTag = 'mdd1'

module networkrg '../../modules/resourcegroup/resourceGroup.bicep' = {
   name: v_resourceGroupName
    scope: subscription()
    params: {
       p_name: v_resourceGroupName
        p_location: p_location
         p_tags: {
           'test': 'true'
         }
    }
}

// call module to create a network module
module network '../../modules/network/virtualNetwork/virtualNetwork.bicep' = {
  name: 'deploy-network-${v_namePrefix}'
  dependsOn: [
    networkrg
  ]
  scope: resourceGroup(v_resourceGroupName)
  params:{ 
    p_name: v_namePrefix
    p_vnetAddressSpace: v_vnetAddressSpace
    p_location: p_location
     p_subnets: [
       {
         name: '${v_namePrefix}-pub'
         addressPrefix: v_publicAddressPrefix
         ruleset: []
         enableEndPoints: true
       }
       {
        name: '${v_namePrefix}-pvt'
        addressPrefix: v_privateAddressPrefix
        ruleset: []
        enableEndPoints: false
      }
     ]
     p_tags: {
       '${v_azureTag}': v_uniqueTag
     }
  } 
}



