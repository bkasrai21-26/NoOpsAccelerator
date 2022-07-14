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

var v_namePrefix = 'mdd'
var v_resourceGroupName = 'storage-test55'
var v_sku = 'Standard_LRS'
var v_accessTier = 'Hot'
var v_supportsHttpsTrafficOnly = true
var v_isDatalake = true
var v_container1 = 'container1'
var v_fileshareName = 'fileshare1'

module storagerg '../../modules/resourcegroup/resourceGroup.bicep' = {
   name: v_resourceGroupName
   scope: subscription()
   params: {
      p_name: v_resourceGroupName
       p_location: p_location
       p_tags: {
        'testgroup': 'true' 
      }
   }
}

module sa '../../modules/storage/storageAccount.bicep' = {
  name: 'storageAccount'
  scope: resourceGroup(v_resourceGroupName)
  dependsOn:[
    storagerg
  ]
  params: {
    p_namePrefix: v_namePrefix
    p_sku: v_sku
    p_accessTier: v_accessTier
    p_supportsHttpsTrafficOnly: v_supportsHttpsTrafficOnly
    p_isDatalake: v_isDatalake
  }
}

 module cn1 '../../modules/storage/container.bicep' = {
  name: 'container1'
   scope: resourceGroup(v_resourceGroupName)
   dependsOn: [
     sa
   ]
  params: {
    p_storageName: sa.outputs.o_storageAcctName
    p_containerName: v_container1
  }
}

module fs1 '../../modules/storage/fileshare.bicep' = {
  name: 'fileshare1'
  scope: resourceGroup(v_resourceGroupName)
  dependsOn: [
    sa
  ]
  params: {
    p_storageName: sa.outputs.o_storageAcctName
    p_fileshareName: v_fileshareName
  }
} 
