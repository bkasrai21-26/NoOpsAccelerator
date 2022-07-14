/* ********************************************************************************** 
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */
/* ********************************************************************************** 
 * Module: resourceGroup.bicep
 * Scope: subscription
 * The following are required parameters when calling this module 
 * p_name string - The name of the resource group.
 * p_location string - The location (azure region) to deploy the resource group to.
 * 
 * The following are optional parameters when calling this module
 * p_tags object - Property to configure azure tags on the resource.
 *********************************************************************************  */
targetScope = 'subscription'

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

@description('The resource group name.')
param p_name string
@description('The location to deploy the resource group.')
param p_location string

@description('The tags to associate with the resource group.')
param p_tags object

var v_mddTag = {
  MDDTagName: 'MDD1'
}

var v_tags = union(v_mddTag, p_tags)

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: p_name
  location: p_location  
  tags: v_tags 
}

/* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */
output o_id string = rg.id
output o_resourceGroup string = rg.name
