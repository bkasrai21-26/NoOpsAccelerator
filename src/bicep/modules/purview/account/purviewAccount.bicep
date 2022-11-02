///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module creates Purview Account.
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Prefix for resource name')
param p_nameIdentifier string

@description('Location of Purview Account resource group')
param p_location string = resourceGroup().location

@description('Enable or Disable public network access to workspace')
param p_publicNetworkAccess string = 'Enabled'

@description('Identity type. Accepted values are None, SystemAssigned, UserAssigned, SystemAssigned,UserAssigned')
param p_identityType string = 'SystemAssigned'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

 @description('Derived name for Synapse workspace')
var v_purviewAccountName = replace(toLower('purview${p_nameIdentifier}'), '-', '')

@description('Managed Purview resource group name')
var v_managedResourceGroupName = 'rg-${p_nameIdentifier}-managed'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////
 
resource purview 'Microsoft.Purview/accounts@2021-12-01' = {
  name: v_purviewAccountName
  location: p_location
  sku: {
    name: 'Standard'
    capacity: 1
  }
  identity: {
    type: p_identityType
  }
  properties: {
    managedResourceGroupName: v_managedResourceGroupName
    publicNetworkAccess: p_publicNetworkAccess
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////
@description('Purview Account name')
output o_purviewAccountName string = purview.name
@description('Principal Id for System managed Identity')
output o_systemManagedIdentity string = purview.identity.principalId
