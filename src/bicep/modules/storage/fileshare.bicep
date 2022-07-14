/* ********************************************************************************** 
 * Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
 * Software is licensed under the MIT License. See LICENSE in the project root
 * for license information.
 * ********************************************************************************** */

/* ********************************************************************************** 
 * This module creates Azure Storage account with HNS enabled
 *
 * Assign appropriate values as needed. If needed override global parameters
 * ********************************************************************************** */

/* **********************************************************************************
 * Section for Bicep parameters 
 * ********************************************************************************** */

@description('storage account.')
param p_storageName string

@description('fileshare name')
param p_fileshareName string

/* **********************************************************************************
 * Section for Bicep variables
 * ********************************************************************************** */

var v_fileshareLocation = '${p_storageName}/default/${p_fileshareName}'

/* **********************************************************************************
 * Section for Bicep resources
 * ********************************************************************************** */

 resource fs 'Microsoft.Storage/storageAccounts/fileServices/shares@2020-08-01-preview' = {
  name: v_fileshareLocation
}

/* **********************************************************************************
 * Section for Bicep output
 * ********************************************************************************** */

output o_fileShareName string = fs.name
