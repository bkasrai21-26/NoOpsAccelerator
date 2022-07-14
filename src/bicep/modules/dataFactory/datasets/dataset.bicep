/* ********************************************************************************** 
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* ********************************************************************************** 
 * Module: dataset.bicep
 * The following are required parameters when calling this module 
 * p_dataFactoryName string - The name of the Azure DataFactory
 * p_dataset object - the dataset specification (json object)
 *********************************************************************************  */

targetScope='resourceGroup'

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

 @description('The name of the datafactory to deploy the trigger.')
param p_dataFactoryName string

@description('The json object definition of the dataset.')
param p_dataSet object


/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */

 resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
   name: p_dataFactoryName
}

resource dataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: p_dataSet.name
  parent: dataFactory
  properties: p_dataSet.properties
}

