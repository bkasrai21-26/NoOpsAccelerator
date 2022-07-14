///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Module Description : 
// This module creates endpoints
//
// Assign appropriate values as needed. If needed override global parameters
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

targetScope='resourceGroup'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep parameters
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('The location to deploy the virtual network.')
param p_location string = resourceGroup().location

@description('The tags to associate to the virtual network.')
param p_tags object = {}

@description('Subnet in a virtual network resource')
param p_subnetId string 

param p_privateEndPointName string

param p_groupIds array = []

param p_resourceId string 

param p_sourceResourceId string = ''


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep variables
///////////////////////////////////////////////////////////////////////////////////////////////////////

// the unique MDD tag is determined to be - we can just embed int he reosurces and append it to any additional customer tags that are added.
var v_mddTag = {
  mdd: 'mdd1'
}

var v_tags = union(v_mddTag, p_tags)

var v_privateLinkConnectionName = '${p_privateEndPointName}-connection'


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep resources
///////////////////////////////////////////////////////////////////////////////////////////////////////

resource privateEndPoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: p_privateEndPointName
  location: p_location
  tags: v_tags
  properties: {
    subnet: {
      id: p_subnetId
    }
    privateLinkServiceConnections: [
      {
        id: p_sourceResourceId
        name: v_privateLinkConnectionName
        properties: {
          privateLinkServiceId: p_resourceId 
          groupIds: p_groupIds
          
        }
      }
    ]
  }
 
}


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section for Bicep output
///////////////////////////////////////////////////////////////////////////////////////////////////////

output o_privateEndpointName string = privateEndPoint.name
// output o_privateIPAddress string = privateEndPoint.properties.customDnsConfigs[0].ipAddresses[0]




///////////////////////////////////////////////////////////////////////////////////////////////////////
//  Appendix - Allowed values for private link and service names
/////////////////////////////////////////////////////////////////////////////////////////////////////// 

/*
 #########  Allowed values for End points  (groupIds in this context)
  'automation'
  'sqlServer'
  'synapseSql'
  'synapseDev'
  'synapseWeb'
  'storageAccountBlob'
  'storageAccountTable'
  'storageAccountQueue'
  'storageAccountFile'
  'storageAccountWeb'
  'storageAccountDFS'
  'cosmosDbSql'
  'cosmosDbMongo'
  'cosmosDbCassandra'
  'cosmosDbGremlin'
  'cosmosDbTable'
  'batch'
  'postgreSqlServer'
  'mySqlServer'
  'mariaDbServer'
  'keyVault'
  'kubernetes'
  'searchService'
  'containerRegistry'
  'appConfiguration'
  'azureBackup'
  'azureSiteRecovery'
  'azureEventHub'
  'azureServiceBus'
  'azureIOTHub'
  'azureRelay'
  'eventGrid'
  'webApps'
  'machineLearning'
  'machineLearningNotebook'
  'signalR'
  'monitor'
  'cognitiveServices'
  'azureFileSync'
  'dataFactory'
  'dataFactoryPortal'
  'redisCache'
  'redisEnterprise'
  'purview'
  'digitalTwins'

######## Allowed values for service names

    automation: 'privatelink.azure-automation.net'
    sqlServer: 'privatelink${environment().suffixes.sqlServerHostname}'
    synapseSql: 'privatelink.sql.azuresynapse.net'
    synapseDev: 'privatelink.dev.azuresynapse.net'
    synapseWeb: 'privatelink.azuresynapse.net'
    storageAccountBlob: 'privatelink.blob.${environment().suffixes.storage}'
    storageAccountTable: 'privatelink.table.${environment().suffixes.storage}'
    storageAccountQueue: 'privatelink.queue.${environment().suffixes.storage}'
    storageAccountFile: 'privatelink.file.${environment().suffixes.storage}'
    storageAccountWeb: 'privatelink.web.${environment().suffixes.storage}'
    storageAccountDFS: 'privatelink.dfs.${environment().suffixes.storage}'
    cosmosDbSql: 'privatelink.documents.azure.com'
    cosmosDbMongo: 'privatelink.mongo.cosmos.azure.com'
    cosmosDbCassandra: 'privatelink.cassandra.cosmos.azure.com'
    cosmosDbGremlin: 'privatelink.gremlin.cosmos.azure.com'
    cosmosDbTable: 'privatelink.table.cosmos.azure.com'
    batch: 'privatelink.${p_location}.batch.azure.com'
    postgreSqlServer: 'privatelink.postgres.database.azure.com'
    mySqlServer: 'privatelink.mysql.database.azure.com'
    mariaDbServer: 'privatelink.mariadb.database.azure.com'
    keyVault: 'privatelink.vaultcore.azure.net'
    kubernetes: 'privatelink.${p_location}.azmk8s.io'
    searchService: 'privatelink.search.windows.net'
    containerRegistry: 'privatelink.azurecr.io'
    appConfiguration: 'privatelink.azconfig.io'
    azureBackup: 'privatelink.${p_location}.backup.windowsazure.com'
    azureSiteRecovery: 'privatelink.siterecovery.windowsazure.com'
    azureEventHub: 'privatelink.servicebus.windows.net'
    azureServiceBus: 'privatelink.servicebus.windows.net'
    azureIOTHub: 'privatelink.azure-devices.net'
    azureRelay: 'privatelink.servicebus.windows.net'
    eventGrid: 'privatelink.eventgrid.azure.net'
    webApps: 'privatelink.azurewebsites.net'
    machineLearning: 'privatelink.api.azureml.ms'
    machineLearningNotebook: 'privatelink.notebooks.azure.net'
    signalR: 'privatelink.service.signalr.net'
    monitor: 'privatelink.monitor.azure.com'
    cognitiveServices: 'privatelink.cognitiveservices.azure.com'
    azureFileSync: 'privatelink.afs.azure.net'
    dataFactory: 'privatelink.datafactory.azure.net'
    dataFactoryPortal: 'privatelink.adf.azure.com'
    redisCache: 'privatelink.redis.cache.windows.net'
    redisEnterprise: 'privatelink.redisenterprise.cache.azure.net'
    purview: 'privatelink.purview.azure.com'
    digitalTwins: 'privatelink.digitaltwins.azure.net'
  }
  AzureUSGovernment: {
    automation: 'privatelink.azure-automation.us'
    sqlServer: 'privatelink.database.usgovcloudapi.net'
    synapseSql: 'privatelink.sql.azuresynapse.usgovcloudapi.net'
    synapseDev: 'privatelink.dev.azuresynapse.usgovcloudapi.net'
    synapseWeb: 'privatelink.azuresynapse.usgovcloudapi.net'
    storageAccountBlob: 'privatelink.blob.core.usgovcloudapi.net'
    storageAccountTable: 'privatelink.table.core.usgovcloudapi.net'
    storageAccountQueue: 'privatelink.queue.core.usgovcloudapi.net'
    storageAccountFile: 'privatelink.file.core.usgovcloudapi.net'
    storageAccountWeb: 'privatelink.web.core.usgovcloudapi.net'
    storageAccountDFS: 'privatelink.dfs.core.usgovcloudapi.net'
    cosmosDbSql: 'privatelink.documents.azure.us'
    cosmosDbMongo: 'privatelink.mongo.cosmos.azure.us'
    cosmosDbCassandra: 'privatelink.cassandra.cosmos.azure.us'
    cosmosDbGremlin: 'privatelink.gremlin.cosmos.azure.us'
    cosmosDbTable: 'privatelink.table.cosmos.azure.us'
    batch: 'privatelink.${p_location}.batch.usgovcloudapi.net'
    postgreSqlServer: 'privatelink.postgres.database.usgovcloudapi.net'
    mySqlServer: 'privatelink.mysql.database.usgovcloudapi.net'
    mariaDbServer: 'privatelink.mariadb.database.usgovcloudapi.net'
    keyVault: 'privatelink.vaultcore.usgovcloudapi.net'
    kubernetes: 'privatelink.${p_location}.azmk8s.io'
    searchService: 'privatelink.search.azure.us'
    containerRegistry: 'privatelink.azurecr.us'
    appConfiguration: 'privatelink.azconfig.azure.us'
    azureBackup: '	privatelink.ugv.backup.windowsazure.us'
    azureSiteRecovery: 'privatelink.siterecovery.windowsazure.us'
    azureEventHub: 'privatelink.servicebus.usgovcloudapi.net'
    azureServiceBus: 'privatelink.servicebus.usgovcloudapi.net'
    azureIOTHub: 'privatelink.azure-devices.us'
    azureRelay: 'privatelink.servicebus.usgovcloudapi.net'
    eventGrid: 'privatelink.eventgrid.azure.us'
    webApps: 'privatelink.azurewebsites.us'
    machineLearning: 'privatelink.api.ml.azure.us'
    machineLearningNotebook: 'privatelink.notebooks.usgovcloudapi.net'
    signalR: 'privatelink.signalr.azure.us'
    monitor: 'privatelink.monitor.azure.us'
    cognitiveServices: 'privatelink.cognitiveservices.azure.us'
    azureFileSync: 'privatelink.afs.azure.us'
    dataFactory: 'privatelink.datafactory.azure.us'
    dataFactoryPortal: 'privatelink.adf.azure.us'
    redisCache: 'privatelink.redis.cache.usgovcloudapi.net'
    redisEnterprise: 'privatelink.redisenterprise.cache.azure.us'
    purview: 'privatelink.purview.azure.us'
    digitalTwins: 'privatelink.digitaltwins.azure.us'
*/
