///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module creates Windows VM
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////
 

 @description('unique name identifier')
 param p_nameIdentifier string 
 
 @description('resource tags')
 param p_tags object = {}
 
 @description('Name of Interface')
 param p_networkInterfaceName string
 
 @description('VM instance type')
 param p_size string ='Standard_D8s_v3'

 @description('Admin User, retrieved from Keyvault')
 param p_adminUsername string = 'winadmin'
 
 @description('Admin password, retrieved from Keyvault')
 @secure()
 param p_adminPassword string = 'mypassword@123'
 
 @description('Publisher of the image used to create the virtual machines')
 param p_publisher string ='MicrosoftWindowsDesktop'
 
 @description('Offer of the image used to create the virtual machines')
 param p_offer string = 'Windows-10'
 
 @description('SKU of the image used to create the virtual machines')
 param p_sku string ='20h2-pro-g2'
 
 @description('Version of the image used to create the virtual machines')
 param p_version string ='latest'
 
 @description('Source of OS')
 param p_createOption string = 'FromImage'
 
 @description('Storage Account which should back this the Internal OS Disk')
 param p_storageAccountType string = 'Standard_LRS'

 @description('Id of Network interface Id')
 param p_networkInterfaceId string
 
  
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

 
 var v_uniqueComputername = take(toLower(replace('${p_nameIdentifier}${uniqueString(resourceGroup().id)}', '-', '')),15)
 var v_location = resourceGroup().location
 
 // the unique MDD tag is determined to be - we can just embed int he reosurces and append it to any additional customer tags that are added.
 var v_mddTag = {
   mdd: 'mdd1'
 }
 var v_tags = union(v_mddTag, p_tags)
 
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

  resource networkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' existing = {
    name: p_networkInterfaceName
  }

 resource windowsVirtualMachine 'Microsoft.Compute/virtualMachines@2021-04-01' = {
   name: v_uniqueComputername
   location: v_location
   tags: v_tags
   properties: {
     hardwareProfile: {
       vmSize: p_size 
     }
     osProfile: {
       computerName: v_uniqueComputername
       adminUsername: p_adminUsername
       adminPassword: p_adminPassword
     }
     storageProfile: {
       imageReference: {
         publisher: p_publisher
         offer: p_offer
         sku: p_sku
         version: p_version 
       }
       osDisk: {
         createOption: p_createOption
         managedDisk: {
           storageAccountType: p_storageAccountType          
         }
       }
     }
     networkProfile: {
       networkInterfaces: [
         { 
           id: p_networkInterfaceId
         }
       ]
     }
   }
 }
 

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////
