/* ********************************************************************************** 
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */

/* ********************************************************************************** 
 * Module: pipeline.bicep
 * The following are required parameters when calling this module 
 * p_dataFactoryName string - The name of the Azure DataFactory
 * p_pipeline object - the pipeline specification (json object)
 *********************************************************************************  */
targetScope='resourceGroup'

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

@description('The name of the datafactory to deploy the trigger.')
param p_dataFactoryName string

@description('The json object definition of the pipeline.')
param p_pipeline object

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
   name: p_dataFactoryName
}

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
   name: p_pipeline.name
   parent: dataFactory
   properties: p_pipeline.properties
}
