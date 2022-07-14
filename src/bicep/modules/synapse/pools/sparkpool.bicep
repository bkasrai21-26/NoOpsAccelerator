/* **********************************************************************************
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* **********************************************************************************
--------------------------------------------------------------
#
# This resource creates Synapse spark pool with autoscaling turned on.
# 
# Assign appropriate defaults as needed. If needed override global parameters
#
* ********************************************************************************** */

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */


@description('Prefix for  Synapse Workspace Name.')
param o_workspaceName string 

@description('Prefix for  resource name')
param p_nameIdentifier string


@description('This parameter will determine the node size')
@allowed([
  'Small'
  'Medium'
  'Large'
])
param p_sparkNodeSize string 			= 'Small'

@description('minimum node size')
param p_minNodeCount int 			= 3

@description('maximum node size')
param p_maxNodeCount int 			= 10

@description('spark version')
param p_sparkVersion string 			= '3.1'

@description('Number of minutes of idle time before the Spark Pool is automatically paused')
param p_delayInMinutes int 			= 15

@description(' ')
param p_nodeSizeFamily string 			= 'MemoryOptimized'

@description(' ')
param p_autoScale bool 				= true

@description(' ')
param p_autopauseEnabled bool			= true

/* **********************************************************************************
 * Section for Bicep variables
 * ********************************************************************************** */

var v_location 					= resourceGroup().location
var v_sparkPoolName 				= take(toLower('synsparkpool${p_nameIdentifier}'),15)

/* **********************************************************************************
 * Section for Bicep resources
 * ********************************************************************************** */



 resource workspaceName_sparkPoolName 'Microsoft.Synapse/workspaces/bigDataPools@2019-06-01-preview' =  {
  name						: '${o_workspaceName}/${v_sparkPoolName}'
  location					: v_location
  properties					: {
    nodeSizeFamily				: p_nodeSizeFamily 
    nodeSize					: p_sparkNodeSize
    autoScale					: {
      enabled					: p_autoScale 
      minNodeCount				: p_minNodeCount
      maxNodeCount				: p_maxNodeCount
    }
    autoPause					: {
      enabled					: p_autopauseEnabled
      delayInMinutes				: p_delayInMinutes
    }
    sparkVersion				: p_sparkVersion
  }
}

 