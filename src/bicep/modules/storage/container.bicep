/* ********************************************************************************** 
 * Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
 * Software is licensed under the MIT License. See LICENSE in the project root
 * for license information.
 * ********************************************************************************** */
 /* ********************************************************************************** 
 * Module: container.bicep
 * Scope: subscription
 * The following are required parameters when calling this module 
 * p_storageName string - The name of the storage account.
 * p_containerName string - The name of the container to create.
 * 
 * The following are optional parameters when calling this module
 * p_tags object - Property to configure azure tags on the resource.
 *********************************************************************************  */
targetScope='resourceGroup'

/* ********************************************************************************** 
 * This module creates Azure Storage account with HNS enabled
 *
 * Assign appropriate values as needed. If needed override global parameters
 * ********************************************************************************** */

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */


@description('container name')
param p_containerName string
param o_storageAccountName string
param p_publicAccess string = 'None'


/* **********************************************************************************
 * Section for Bicep variables
 * ********************************************************************************** */
var v_containerName = toLower('${o_storageAccountName}/default/${p_containerName}')

/* **********************************************************************************
 * Section for Bicep resources
 * ********************************************************************************** */


 resource storageAccountContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: v_containerName
  properties: {
    publicAccess: p_publicAccess
    }
}

/* **********************************************************************************
 * Section for Bicep output
 * ********************************************************************************** */

output o_containerAcctName string = storageAccountContainer.name
