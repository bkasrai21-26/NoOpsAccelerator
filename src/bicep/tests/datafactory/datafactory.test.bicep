/* ********************************************************************************** 
 *  This code creates several resource groups, a key vault a virtual network and several datafactories
 * 
 *  This code MUST be run at the group level to create a subscription. 
 *
 *  Dependencies: 
      - modules/resourceGroup/resourceGroup.bicep
      - modules/keyVault/keyvault.bicep
      - modules/network/virtualNetwork.bicep
      - modules/datafactory/datafactory.bicep
      - modules/privateEndPoint/privateEndPoint.bicep
      - modules/privateDNSZone/privateDNSZone.bicep
 * 
 * run this code by typing the following Azure CLI command: 
 * scode@mdd-dev:/workspaces/mdd$ az deployment sub create -f src/bicep/tests/datafactory.test.bicep -l eastus -c
 **********************************************************************************  */

targetScope = 'subscription'

@description('The location to deploy the resource group')
param p_location string

var resourceGroupName = 'factory-rg'

var dataFactoryName = 'test-mrp-adf'
var dataFactoryCMK = 'test-mrp-cmk-adf'
var dataFactoryEP = 'test-mrp-ep-adf'
var dataFactoryCMKEP = 'test-mrp-cmk-ep-adf'

var keyVaultName = 'test-mrp-kv'
var keyVaultResourceGroupName = 'vault-rg'

var virtualNetworkName = 'test-vnet'
var virtualNetworkResourceGroupName = 'network-rg'
var subnetName = '${virtualNetworkName}-pub'

// Looks like floats aren't supported.. :(
var globalParameters = {
  'source': {
    'type': 'string'
    'value': 'MDD'
  }
  'integer': {
    'type': 'int'
    'value': 43
  }
  /* 'float': {
    'type': 'float'
    'value': 3.141529
  }
  */
  'bool': {
    'type': 'bool'
    'value': false
  }
  'array': {
    'type': 'array'
    'value': [
      'one'
      'two'
      'three'
    ]
  }
  'object': {
    'type': 'object'
    'value': {
      'integer': 1
      'bool': true
      'array': [
        'one'
        'two'
        'three'
      ]
    }
  }
}

var tags = {
  'source': 'MDD'
}

module factoryrg '../../modules/resourceGroup/resourceGroup.bicep' = {
  name: 'deploy-factoryrg'
  scope: subscription()
  params: {
    p_name: resourceGroupName
    p_location: p_location
    p_tags: tags
  }
}

module vaultrg '../../modules/resourceGroup/resourceGroup.bicep' = {
  name: 'deploy-vaultrg'
  scope: subscription()
  params: {
    p_name: keyVaultResourceGroupName
    p_location: p_location
    p_tags: tags
  }
}

module networkrg '../../modules/resourceGroup/resourceGroup.bicep' = {
  name: 'deploy-networkrg'
  scope: subscription()
  params: {
    p_name: virtualNetworkResourceGroupName
    p_location: p_location
    p_tags: tags
  }
}

// TODO: lookup the created resource groups for automatic dependencies

// TODO: Add Network Module

module network '../../modules/network/virtualNetwork/virtualNetwork.bicep' = {
  name: 'deploy-network'
  dependsOn: [
    networkrg
  ]
  scope: resourceGroup(virtualNetworkResourceGroupName)
  params: {
    p_name: virtualNetworkName
    p_vnetAddressSpace: '10.0.0.0/24'
    p_location: p_location
    p_subnets: [
      {
        name: '${virtualNetworkName}-pvt'
        addressPrefix: '10.0.0.0/25'
        ruleset: []
        enableEndPoints: true
      }
      {
        name: '${virtualNetworkName}-pub'
        addressPrefix: '10.0.0.128/25'
        ruleset: []
        enableEndPoints: true
      }
    ]
  }
}

module keyVault '../../modules/keyVault/keyVault.bicep' = {
  name: 'deploy-keyvault'
  scope: resourceGroup(keyVaultResourceGroupName)
  dependsOn: [
    vaultrg
  ]
  params: {
    p_keyVaultName: keyVaultName
    p_keyVaultTenantId: subscription().tenantId
    p_bypass: 'AzureServices'
    p_defaultAction: 'Allow'
    p_sku: 'standard'
  }
}

module kvk '../../modules/keyVault/key//keys.bicep' = {
  name: 'deploy-keyvaultKey'
  scope: resourceGroup(keyVaultResourceGroupName)
  dependsOn: [
    vaultrg
  ]
  params: {
    p_keyVaultName: keyVaultName
    p_keyName: 'test-key'
    p_keySize: 2048
    p_keyType: 'RSA'
  }
}

module storageAccount '../../modules/storage/storageAccount.bicep' = {
  name: 'deploy-storage-account'
  scope: resourceGroup(resourceGroupName)
  params: {
    p_accessTier: 'Hot'
    p_isDatalake: true
    p_namePrefix: 'mddst001'
    p_sku: 'Standard_LRS'
    p_supportsHttpsTrafficOnly: true
    p_tags: {
      'test': 'true'
    }
  }
}

module rawContainer '../../modules/storage/container.bicep' = {
  name: 'deploy-raw-container'
  dependsOn: [
    storageAccount
  ]
  scope: resourceGroup(resourceGroupName)
  params: {
    p_storageName: storageAccount.outputs.o_storageAcctName
    p_containerName: 'raw'
  }
}

module processedContainer '../../modules/storage/container.bicep' = {
  name: 'deploy-processed-container'
  dependsOn: [
    storageAccount
  ]
  scope: resourceGroup(resourceGroupName)
  params: {
    p_storageName: storageAccount.outputs.o_storageAcctName
    p_containerName: 'processed'
  }
}

//load data from json file(s) to prime / create pipelines.
//load pipeline / dataset / linked services / triggers from json files

var pipeline = json(loadTextContent('copy_pipeline.json'))
var dataset = json(loadTextContent('bin_ds.json'))
var linkedService =  json(replace(loadTextContent('dfs_ls.json'), '$storageAccountBaseUrl', storageAccount.outputs.o_accountUrl))
var trigger =  json(replace(loadTextContent('raw_trigger.json'), '$storageAccountResourceId', storageAccount.outputs.o_id))


var pipelines = array(pipeline)
var datasets = array(dataset)
var linkedServices = array(linkedService)
var triggers = array(trigger)

module datafactory '../../modules/dataFactory/dataFactory.bicep' = {
  name: 'deploy-datafactory-plain'
  dependsOn: [
    keyVault
    factoryrg
  ]
  scope: resourceGroup(resourceGroupName)
  params: {
    p_name: dataFactoryName
    p_location: p_location
    p_globalParameters: globalParameters
    p_tags: {
      cmk: 'false'
      ep: 'false'
    }
    p_network: {}
    p_dnsZone: {}
    p_keyVault: {}

    p_pipelines: pipelines
    p_datasets: datasets
    p_linkedServices: linkedServices
    p_triggers: triggers
  }
}

module datafactoryCMK '../../modules/dataFactory/dataFactory.bicep' = {
  name: 'deploy-datafactory-cmk'
  dependsOn: [
    keyVault
    factoryrg
    datafactory
  ]
  scope: resourceGroup(resourceGroupName)
  params: {
    p_name: dataFactoryCMK
    p_location: p_location
    p_keyVault: {
      keyVaultName: keyVaultName
      keyVaultResourceGroupName: keyVaultResourceGroupName
      keyVaultSubscriptionId: subscription().subscriptionId
      keyVaultKeyName: '${dataFactoryCMK}-key'
      keyType: 'RSA'
    }
    p_tags: {
      cmk: 'true'
      ep: 'false'
    }
  }
}

module datafactoryEP '../../modules/dataFactory/dataFactory.bicep' = {
  name: 'deploy-datafactory-EP'
  dependsOn: [
    keyVault
    factoryrg
    networkrg
    datafactoryCMK
  ]
  scope: resourceGroup(resourceGroupName)
  params: {
    p_name: dataFactoryEP
    p_location: p_location

    p_network: {
      virtualNetworkName: virtualNetworkName
      virtualNetworkResourceGroupName: virtualNetworkResourceGroupName
      virtualNetworkSubscriptionId: subscription().subscriptionId
      subnetName: subnetName
    }
    p_dnsZone: {
      virtualNetworkName: virtualNetworkName
      virtualNetworkResourceGroupName: virtualNetworkResourceGroupName
      virtualNetworkSubscriptionId: subscription().subscriptionId
    }
    p_tags: {
      cmk: 'false'
      ep: 'true'
    }
  }
}

module datafactoryCMKEP '../../modules/dataFactory/dataFactory.bicep' = {
  name: 'deploy-datafactory-cmk-ep'
  dependsOn: [
    keyVault
    factoryrg
    networkrg
    datafactoryEP
  ]
  scope: resourceGroup(resourceGroupName)
  params: {
    p_name: dataFactoryCMKEP
    p_location: p_location
    p_keyVault: {
      keyVaultName: keyVaultName
      keyVaultResourceGroupName: keyVaultResourceGroupName
      keyVaultSubscriptionId: subscription().subscriptionId
      keyVaultKeyName: '${dataFactoryCMKEP}-key'
    }
    p_network: {
      virtualNetworkName: virtualNetworkName
      virtualNetworkResourceGroupName: virtualNetworkResourceGroupName
      virtualNetworkSubscriptionId: subscription().subscriptionId
      subnetName: subnetName
    }
    p_dnsZone: {
      virtualNetworkName: virtualNetworkName
      virtualNetworkResourceGroupName: virtualNetworkResourceGroupName
      virtualNetworkSubscriptionId: subscription().subscriptionId
    }
    p_tags: {
      cmk: 'true'
      ep: 'true'
    }
  }
}

var v_env = environment().name

output o_env string = v_env
