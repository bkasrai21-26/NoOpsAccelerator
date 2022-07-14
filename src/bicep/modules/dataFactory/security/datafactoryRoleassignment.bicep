/* ********************************************************************************** 
* Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
* Software is licensed under the MIT License. See LICENSE in the project root
* for license information.
* ********************************************************************************** */
/* ********************************************************************************** 
 * Module: roleAssignment.bicep
 * Scope: resourceGroup

 *********************************************************************************  */
targetScope='resourceGroup'

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

 @description('Target Resource Id')
 param p_principalId string

 @description('Role Definition Id')
 param p_roleDefinitionId string
 
 @allowed([
   'User'
   'Group'
   'ServicePrincipal'
   'ForeignGroup'
 ])
 @description('The resource definition Id')
 param p_principalType string 


 @description('role description')
 param p_description string = ''

param p_datafactoryName string
 

@description('This is the built-in Contributor role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor')
resource p_roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: p_roleDefinitionId
}

/* **********************************************************************************
 * Section for Bicep resources 
 * ********************************************************************************** */

 
resource datafactoryExists 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: p_datafactoryName
  }

  resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(resourceGroup().id, p_principalId, p_roleDefinition.id)
  scope: datafactoryExists
    properties: {
    roleDefinitionId: p_roleDefinition.id
    principalId: p_principalId
    principalType: p_principalType
    description: p_description
  }
} 



/* **********************************************************************************
 * Section for Bicep outputs 
 * ********************************************************************************** */


