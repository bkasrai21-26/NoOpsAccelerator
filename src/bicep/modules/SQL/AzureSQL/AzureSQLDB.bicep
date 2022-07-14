///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module creates an Azure SQL DB and uses the logical server created in AzureSqlServer.bicep 
// A wait time is introduced so that activate workspace succeeds. 
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('The Azure region where all resources in this example should be created')
param p_location string = resourceGroup().location
@description('A list of tags to apply to the resources')
param tags object = {}

@description('The name of the SQL logical server.')
param p_sqlServerName string

@description('The name of the SQL Database.')
param p_sqlDBName string

@description('The value for IsLedgerOn.  This cannot change after the database has been created')
param p_isLedgerOn bool

@description('The name of the SKU Name.')
param p_SkuName string

@description('The name of the SKU Tier.')
param p_SkuTier string
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

//placeholder 

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

resource sqlServer 'Microsoft.Sql/servers@2021-05-01-preview' existing = {
  name: p_sqlServerName
 }

resource sqlDB 'Microsoft.Sql/servers/databases@2021-05-01-preview' = {
  parent: sqlServer
  name: p_sqlDBName
  location: p_location
  tags: tags
  sku: {
    name: p_SkuName
    tier: p_SkuTier
  }
  properties: {
    isLedgerOn: p_isLedgerOn
  }
}

// Outputs: database URL, username & password
//placeholder
output o_id string = sqlDB.id
output o_name string = sqlDB.name
