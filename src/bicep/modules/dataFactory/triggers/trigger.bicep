/* ********************************************************************************** 
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* ********************************************************************************** 
 * Module: trigger.bicep
 * The following are required parameters when calling this module 
 * p_dataFactoryName string - The name of the Azure DataFactory
 * p_trigger object - the pipeline specification (json object)
 *********************************************************************************  */
targetScope='resourceGroup'

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

@description('The name of the datafactory to deploy the trigger.')
param p_dataFactoryName string

@description('The json object definition of the trigger.')
param p_trigger object

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
   name: p_dataFactoryName
}

resource trigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  name: p_trigger.name
  parent: dataFactory
  properties: p_trigger.properties
  
}
