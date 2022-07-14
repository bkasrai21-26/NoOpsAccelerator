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

 var v_resourceGroupName = 'mdddragonsyncrg1234'
 var v_workspaceName = 'mdatadragonsyn1234'
 var v_sqlAdministratorLogin = 'whowasit1'
 var v_sqlAdministratorLoginPassword = 'NotEnough$321' 

 var v_minNodeCount = 3
 var v_maxNodeCount = 10
 var v_delayInMinutes = 15
 var v_sparkVersion = '3.1' 
 var v_sparkPoolName = 'spksync'
 var v_sparkNodeSize = 'Medium'
 var v_sqlPoolName = 'sqlsync'
 var v_sqlSKU = 'DW100c'

module synapserg '../../modules/resourcegroup/resourceGroup.bicep' = {
   name: v_resourceGroupName
    params: {
       p_name: v_resourceGroupName
        p_location: p_location
         p_tags: {
           'test': 'true'
         }
    }
}

module wsp '../../modules/synapse/workspace/synapseworkspace.bicep' = {
  name: 'synapseworkspace'
  scope: resourceGroup(v_resourceGroupName)
  dependsOn: [
    synapserg
  ]
  params: {
    p_workspaceName: v_workspaceName
    p_sqlAdministratorLogin: v_sqlAdministratorLogin
    p_sqlAdministratorLoginPassword: v_sqlAdministratorLoginPassword
  }

}

module spn '../../modules/synapse/pools/sparkpool.bicep' =  {
  name:'spn'
  scope: resourceGroup(v_resourceGroupName)
  dependsOn: [
    wsp
  ]
  params: {
    p_workspaceName: v_workspaceName
    p_sparkPoolName: v_sparkPoolName
    p_sparkNodeSize: v_sparkNodeSize
    p_minNodeCount: v_minNodeCount
    p_maxNodeCount: v_maxNodeCount
    p_delayInMinutes: v_delayInMinutes
    p_sparkVersion: v_sparkVersion
  }
}

module sqlp '../../modules/synapse/pools/sqlpool.bicep' =  {
  name:'sqlp'
  scope: resourceGroup(v_resourceGroupName)
  dependsOn: [
    wsp
  ]
  params: {
    p_workspaceName: v_workspaceName
    p_sqlPoolName: v_sqlPoolName
    p_SKU: v_sqlSKU
  }
}

module roleAssignment '../../modules/identity/roleAssignment.bicep' = {
  name:'roleAdmin'
  scope: resourceGroup(v_resourceGroupName)
  dependsOn: [
    wsp
  ]
  params: {
    p_azureResourcId: wsp.outputs.o_workspaceId
    p_roleDefinitionId:  'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
  }

}