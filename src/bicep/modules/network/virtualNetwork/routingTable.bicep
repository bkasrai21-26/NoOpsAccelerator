
/* **********************************************************************************
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* **********************************************************************************
* This resource creates Subnet. Redeploy will fail due to bug.
* Assign appropriate defaults as needed. If needed override global parameters
* ********************************************************************************** */

targetScope='resourceGroup'

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

@description('location')
param p_location string = resourceGroup().location

@description('routing table name')
param p_routingTableName string = 'routingTable-mi-scotgr'

@description('A tags object for associating additional tags to the azure sql .')
param p_tags object = {}

param p_routes array = []

resource routingTable 'Microsoft.Network/routeTables@2020-11-01' = {
  name: p_routingTableName
  location: p_location
  tags: p_tags
  properties: {
    routes: p_routes
  }
}

output p_routingTableId string = routingTable.id
