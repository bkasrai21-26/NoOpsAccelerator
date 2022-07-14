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
 *  Dependencies: module firewall.bicep and SynapseWorkspace.bicep
 * 
 * run this code by typing the following Azure CLI command: 

 **********************************************************************************  */
 targetScope='subscription'

 param p_location string

var v_resourceGroupName = 'networkrg27'
var v_firewallRule = 'AllWindowsRule'
var v_startIpAddress = '0.0.0.0'
var v_endIpAddress = '255.255.255.255'
var v_firewallAzureResourceName = 'mdatadragonsyn27'
var v_firewallAzureResourcetype = 'SynapseWorkspace'

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
  dependsOn: [
    synapserg
  ]
  scope: resourceGroup(v_resourceGroupName)
  params: {
    p_workspaceName: v_firewallAzureResourceName
    p_sqlAdministratorLogin: 'testperson'
    p_sqlAdministratorLoginPassword: '!1ComplexandSecurePassword'
  }

}
// call module to create a firewall for SynapseWorkspace module
module firewall '../../modules/network/firewall.bicep' = {
  name: 'tstrule'
  dependsOn: [
    wsp
  ]
  scope: resourceGroup(v_resourceGroupName)
  params:{ 
    p_azureResourceName: v_firewallAzureResourceName
    p_azureResourceType: v_firewallAzureResourcetype
    p_firewallRule: v_firewallRule
    p_startIpAddress: v_startIpAddress
    p_endIpAddress: v_endIpAddress
  }
} 
