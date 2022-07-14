/* ********************************************************************************** 
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */
/* ********************************************************************************** 
 * Module: managedIdentity.bicep
 * Scope: resourceGroup
 * The following are required parameters when calling this module 
 * p_name string - The name of the user assigned managed identity.
 * p_location string - The location to use to provision the managed identity (defaults to resourceGroup().location) 
 * p_tags object - an object to handle tagging datafactory and other resources
   {
    tagName: 'tagValue'
   }
 *********************************************************************************  */
targetScope='resourceGroup'

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

@description('The name of the user assigned managed identity.')
param p_name string

@description('The location of the user assigned managed identity')
param p_location string = resourceGroup().location


@description('The tags to associated with the keyvault.')
param p_tags object = {
  MDDTagName: 'MDD1'
}


var v_mddTag = {
  MDDTagName: 'MDD1'
}

var v_tags = union(v_mddTag, p_tags)

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'id-${p_name}'
  location: p_location
  tags: v_tags
}

/* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */

output o_id string = identity.id
output o_principalId string = identity.properties.principalId
output o_clientId string = identity.properties.clientId
output o_name string = identity.name
