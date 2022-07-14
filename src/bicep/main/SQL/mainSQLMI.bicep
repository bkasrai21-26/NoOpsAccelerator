///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Description : This is the "main" Azure SQL file that creates a 
// By default all Azure SQL options/features  are enabled. This can be changed by modifying mainSQLServerControls.json
//
// Dependency  
//   1. ../KeyVault/mainKeyVault.bicep (Optional if key vault already exists. In such case provide the name of key vault)
//   2. ../CommonEnvironment/mainCommonEnvironment.bicep (Called within this module)
//
// Steps to install Synapse Infrastructure
//
// ################################ Step-1 ################################
// Optional if key vault exists
//
// 1. cd <installDirectory/src/bicep/main/KeyVault
// 2. Edit mainKeyVaultRequiredParams.json  to update IP address/range
// 3. az deployment sub create --name keyvault --template-file  .\mainKeyVault.bicep --parameters p_nameIdentifier='mddsha1prodeastus'
//
// Note - Location is for config , deployment logging only
//
// ################################ Step-2 ################################
// Optional if landing zone  exists. Please update parameter values accordingly
// 1. cd to <install_directory>src\bicep\main\CommonEnvironment 
// 2. Edit mainSynapseRequiredParams.json  to update required parameters
// 3. az deployment sub create --name deploycommonenv --template-file  .\mainCommonEnvironment.bicep --parameters p_nameIdentifier='mdd5aprodeastus' '@mainCommonEnvironmentRequiredParams.json'
//
// Note - Location is for config , deployment logging only
//
//
// ################################ Step-3 ################################
// 1. cd to <install_directory>src\bicep\main\AzureSQL 
// 2. Edit mainSQLMIRequiredParams.json  to update required parameters
// 3. az deployment sub create  -- location eastus --name deployAzureSQL --template-file mainAzureSQL.bicep  --parameters p_nameIdentifier='mdd5aprodeastus' '@mainAzureSqlRequiredParams.json'
// 
// Note - Location is for config , deployment logging only
//
///////////////////////////////////////////////////////////////////////////////////////////////////////
targetScope='subscription'
///////////////////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-I : Controls SQL  features
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('add a private endpoint')
param c_privateEndpoint bool 

@description('Enables SQL defender for Sql server')
param c_enableSqlServerVulnerabiltyScan bool

@description('Enables SQL defender for SQL Pool. Enabled if enabled for Sql server')
param c_enableSqlDBVulnerabiltyScan bool

@description('Enable alert policy for Sql server')
param c_enableSqlserverAlertPolicy bool

@description('Enable alert policy for SQL')
param c_enableSqlDBAlertPolicy bool

@description('Enable Transpareant data encryption')
param c_enableSqlDBTDE bool

@description('Existing NSG and Route Table')
param c_existingNSGandRouting bool
///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-II: Parameters passed from datafactoryRequiredParams.json
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('username Azure object ID')
param p_objectId string

@description('List of email addresses to which scan notification is sent')
param p_vulnerabilityScanEmails array 

@description('List of email addresses to which alerts is sent')
param p_alertEmails array 


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-III : Subscription Id's
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('common environment parameters ')
param p_monitorLogSubscription string = subscription().subscriptionId

@description('common environment parameters ')
param p_auditLogSubscription string = subscription().subscriptionId

@description('common environment parameters ')
param p_keyVaultSubscription string = subscription().subscriptionId

@description('common environment parameters ')
param p_vnetSubscription string = subscription().subscriptionId


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-IV: Resource Group Names
///////////////////////////////////////////////////////////////////////////////////////////////////////


@description('common environment parameters ')
param p_monitorLogResourceGroup string = 'rg-${p_nameIdentifier}-monitor'

@description('common environment parameters ')
param p_auditLogResourceGroup string = 'rg-${p_nameIdentifier}-audit'

@description('common environment parameters ')
param p_keyVaultResourceGroup string = 'rg-${p_nameIdentifier}-keyVault'

@description('Common environment parameters. Name of Hub VNET')
param p_vnetHubResourceGroup string = 'rg-${p_nameIdentifier}-network'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-V: Remaining parameter declaration
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('common environment parameters ')
param p_nameIdentifier string

@description('location')
param p_location string = 'eastus'

@description('Common environment parameters - Monitoring Log Analytics Workspace')
param p_monitorLogAnalyticsWorkspace string = 'la-${p_nameIdentifier}-monitor'

@description('Monitoring Log Analytics')
param p_monitorLogAnalyticsStorageAccount string = toLower(replace('samlamon${p_nameIdentifier}', '-', ''))

@description('Monitoring LA diagnostic Storage Account')
param p_monitorLogAnalyticsDiagStorageAccount string = toLower(replace('samlamon${p_nameIdentifier}', '-', ''))

@description('Audit Log Storage Account')
param p_auditLogStorageAccount string = 'samlaaud${p_nameIdentifier}'

@description('Virtual Network Name')
param p_vnetName string = 'vnet-${p_nameIdentifier}'

@description('The name of the subnet name to deploy')
param p_subnetName string = 'snet-sqlmi-${p_nameIdentifier}'

@description('The name of the subnet address prefix to deploy')
param p_subAddressPrefix string = '10.1.1.0/24'

@description('The name of the subnet address prefix to deploy')
param p_networkSecurityGroupName string = 'nsg-${p_sqlServerName}-MI'

@description('The name of the subnet address prefix to deploy')
param p_routeTableName string = 'udr-${p_sqlServerName}-MI'

@description('The name of the SQL Server to deploy')
param p_sqlServerName string = 'sqlmi-${p_nameIdentifier}'

@description('SQL Database name suffix')
param p_sqlDBName string = 'DB1'

@description('The name of the SQL Server resource group')
param p_sqlResourceGroup string = 'rg-${p_nameIdentifier}-mi'

@description('A tags object for associating additional tags to the azure sql .')
param p_tags object = {}

@description('Private endpoint Azure resource names')
param p_sqlServerEndPoint array = [
  'managedInstance'
]

@description('adds a time string for unique naming')
param p_utcNow string = utcNow()

// Must match key vault that will hold sqladmin password
@description('Name of the KeyVault')
param p_keyVaultName string = 'kv-${p_nameIdentifier}'

@description('Storage Account for Storing vulnerabilty assessment scan results')
param p_vulnerAssesPartialStorageAccountName string = 'vulnerasses'

@description('Container name for Storing vulnerabilty assessment scan results')
param p_vulnerAssesContainerName string = 'vulnerasses'

@description('SQL Server Logical Server SKU Name')
param p_SkuName string ='Standard'

@description('SQL Server Logical Server SKU Tier')
param p_SkuTier string ='Standard'

@description('Azure SQL DB setting IsLedgerOn.  This cannot be changed after creation of the database.')
param p_isLedgerOn bool = false

//////////////////////////////////////////////////////////////////////////////////// 
// Section for Bicep variables 
//////////////////////////////////////////////////////////////////////////////////// 

var v_mddTag = {
  MDDTagName: 'MDD1'
}
var v_tags = union(v_mddTag, p_tags)

//////////////////////////////////////////////////////////////////////////////////// 
// Section for Bicep resources 
//////////////////////////////////////////////////////////////////////////////////// 

// Retreiving existing common environment Infrastructure
//
resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
  name: p_vnetName
  scope: resourceGroup(p_vnetSubscription,p_vnetHubResourceGroup)
}

resource existingKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing  = {
  name: p_keyVaultName
  scope: resourceGroup(p_keyVaultSubscription, p_keyVaultResourceGroup)
}

resource  existingLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: p_monitorLogAnalyticsWorkspace
  scope: resourceGroup(p_monitorLogSubscription, p_monitorLogResourceGroup)
}
 
resource existingLogAnalyticsStorageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: p_monitorLogAnalyticsDiagStorageAccount
  scope: resourceGroup(p_monitorLogSubscription, p_monitorLogResourceGroup)
}

resource existingLogDiagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: p_monitorLogAnalyticsStorageAccount
  scope: resourceGroup(p_monitorLogSubscription, p_monitorLogResourceGroup)
}

// Auditing 
module auditResourceGroup '../../modules/resourceGroup/resourceGroup.bicep' = {
  name: take('deployAuditRG-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: subscription(p_auditLogSubscription)
  params: {
    p_name: p_auditLogResourceGroup
    p_location: p_location
    p_tags: p_tags
  }
}

module auditLogStorageAccount '../../modules/storage/storageAccount.bicep' = {
  name: take('deployAuditStorageAcct-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_auditLogSubscription, p_auditLogResourceGroup)
  params: {
    p_manualStorageAcctName: p_auditLogStorageAccount
    p_tags: p_tags
  }
  dependsOn: [
    auditResourceGroup
  ]
  }

 module resourceGroupSQLMI '../../modules/resourceGroup/resourceGroup.bicep' = {
  name: 'deployResourceGroup-${p_nameIdentifier}-MI'
  scope: subscription()
  params: {
    p_name: p_sqlResourceGroup
    p_location: p_location
    p_tags: v_tags
  }
}

module storeSecretSqlAdmin '../../modules/keyVault/secret/secrets.bicep' = {
  name: take('DeployStoreSecretSqlAdmin-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup('rg-${p_nameIdentifier}-keyVault')
  params: {
     p_secretName: 'ASCIIAdminMI'
     p_keyVaultName: existingKeyVault.name
  }
  dependsOn: [
     existingKeyVault
  ]
}

module keyVaultKeySQLServer '../../modules/keyVault/key/keys.bicep' = {
  name: 'deployKey-${p_sqlServerName}-mi'
  scope: resourceGroup(p_keyVaultSubscription, p_keyVaultResourceGroup)
  params: {
    p_keyVaultName: existingKeyVault.name
    p_keyName: 'kv-${p_sqlServerName}-MI'
    p_keySize: 2048
    p_keyType: 'RSA'
  }
  dependsOn: [
    existingKeyVault
 ]
}

// Using resource instead of modules because of error or bug. 
// Using for output returns following error - 
//      Function "getSecret" is not valid at this location. 
//      It can only be used when directly assigning to a module parameter with a secure decorator.bicep(BCP180)
//
resource getKeyVaultinfo 'Microsoft.KeyVault/vaults@2019-09-01'  existing = {
  name: p_keyVaultName
  scope: resourceGroup('${p_keyVaultResourceGroup}')
}

module keyAccessPolicyForDeploymentUser '../../modules/keyVault/accessPolicies/accessPolicy.bicep' = {
  name: take('deployKeyPolicyDeploymentUser-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup('${p_keyVaultResourceGroup}')
  params: {
     p_objectId: p_objectId
     p_keyVaultName: existingKeyVault.name
  }
  dependsOn: [
     existingKeyVault
  ]
}

  resource networkSecurityGroupEx 'Microsoft.Network/networkSecurityGroups@2021-03-01' existing = {
    name: p_networkSecurityGroupName
    scope: resourceGroup(p_vnetSubscription,p_vnetHubResourceGroup) 
  }

  module networkSecurityGroup '../../modules/network/virtualNetwork/networkSecurityGroup.bicep' = {
    name: take('deployNSG-${p_nameIdentifier}-${p_utcNow}', 64)
    scope: resourceGroup(p_vnetSubscription,p_vnetHubResourceGroup) 
    params: {
      p_networkSecurityGroup: p_networkSecurityGroupName
      p_location: p_location
      p_tags: p_tags
      p_securityRules: c_existingNSGandRouting ? networkSecurityGroupEx.properties.securityRules : []
    }
    dependsOn: [
      existingVirtualNetwork
      networkSecurityGroupEx
    ]
  }

  resource routingTableEx 'Microsoft.Network/routeTables@2020-11-01' existing = {
    name: 'udr-${p_sqlServerName}-MI'
    scope: resourceGroup(p_vnetSubscription,p_vnetHubResourceGroup) 
  }

  module routingTable '../../modules/network/virtualNetwork/routingTable.bicep' = {
    name: take('deployRouteTable-${p_nameIdentifier}-${p_utcNow}', 64)
    scope: resourceGroup(p_vnetSubscription,p_vnetHubResourceGroup) 
    params: {
      p_routingTableName: p_routeTableName
      p_location: p_location
      p_routes: c_existingNSGandRouting ? routingTableEx.properties.routes : []
      p_tags: p_tags
    }
    dependsOn: [
      existingVirtualNetwork
      routingTableEx
    ]
  }

  module subnet '../../modules/network/virtualNetwork/subnet.bicep' ={
    name: take('deploysubnet-${p_nameIdentifier}-${p_utcNow}', 64)
    scope: resourceGroup(p_vnetSubscription,p_vnetHubResourceGroup) 
    params: {
      p_vnetName: existingVirtualNetwork.name
      p_subnetName: p_subnetName
      p_subnetAddressPrefix: p_subAddressPrefix
      p_delegationName:'delegation-${p_sqlServerName}'
      p_delegationServiceName:'Microsoft.Sql/managedInstances'
      p_networkSecurityGroupId: networkSecurityGroup.outputs.o_networkSecurityGroupId 
      p_routeTableId: routingTable.outputs.p_routingTableId
     }
    dependsOn: [
      existingVirtualNetwork
      networkSecurityGroup
      routingTable
    ]
  }

module sqlMI '../../modules/sql/SQLMI/SQLMI.bicep' = {
  name: 'deploy-MI-${p_nameIdentifier}-srv'
  scope: resourceGroup(p_sqlResourceGroup)
  params: {
    p_location: p_location
    p_sqlServerName: p_sqlServerName
    p_sqlAdministratorLogin: storeSecretSqlAdmin.outputs.o_secretName
    p_sqlAdministratorLoginPassword: getKeyVaultinfo.getSecret(storeSecretSqlAdmin.outputs.o_secretName)
    p_enableCMK: false
    p_subnetId: subnet.outputs.o_subnetId
  }
  dependsOn: [
    resourceGroupSQLMI
    keyVaultKeySQLServer
    networkSecurityGroup
  ]
}

module keyAccessPolicyForSysManagedIdentity '../../modules/keyVault/accessPolicies/accessPolicy.bicep' = {
  name: take('deployKeyPolicySysManagedId-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup('${p_keyVaultResourceGroup}')
  params: {
     p_objectId: sqlMI.outputs.o_principalId
     p_keyVaultName: existingKeyVault.name
  }
  dependsOn: [
     existingKeyVault
     sqlMI
  ]
}

module sqlDB '../../modules/sql/sqlmi/sqlmiDB.bicep' = {
  name: 'deploySQLMIdb-${p_sqlServerName}DB1'
  scope: resourceGroup(p_sqlResourceGroup)
  dependsOn: [
    sqlMI
  ]
  params: {
    p_location: p_location
    p_sqlDBName: p_sqlDBName
    p_sqlServerName: p_sqlServerName
    p_SkuName: p_SkuName
    p_SkuTier: p_SkuTier
    p_isLedgerOn: p_isLedgerOn
  }
}

module sqlDiagSettings '../../modules/sql/sqlmi/sqlmiDBDiagnostic.bicep' = {
  name: 'deploy-moddiag-${p_nameIdentifier}'
  scope: resourceGroup(p_sqlResourceGroup)
  params: {
    p_logAnalyticsWorkspaceId: existingLogAnalyticsWorkspace.id
    p_sqlServerName: p_sqlServerName
    p_sqlDB: sqlDB.outputs.o_name
    p_logAnalyticsResourceGroupName: p_monitorLogResourceGroup
    p_diagnosticStorageAccountName: p_monitorLogAnalyticsDiagStorageAccount
    }
  dependsOn: [
      sqlDB
    ]
}

// Implement private end points for SQL Server end points
module sqlServerPrivateEndpoint '../../modules/network/virtualNetwork/privateEndPoint.bicep' = [ for i in p_sqlServerEndPoint: if (c_privateEndpoint) {
  name: take('deployDF${i}EndPoint-${p_nameIdentifier}-${p_utcNow}',64)
  scope: resourceGroup(p_sqlResourceGroup)
  params: {
    p_privateEndPointName: 'ep-privatelink.${i}.${environment().suffixes.storage}'
    p_groupIds: [
       '${i}'
     ]
    p_subnetId:  existingVirtualNetwork.properties.subnets[0].id
    p_resourceId: sqlMI.outputs.o_id
    p_tags: v_tags
  }
  dependsOn: [
    sqlMI
 ]
}]

module sqlServerPrivateDNSZone '../../modules/network/virtualNetwork/privateDNSZone.bicep' = [ for i in p_sqlServerEndPoint: if (c_privateEndpoint) {
  name: take('deploy${i}PrivateDNSZone-${p_nameIdentifier}-${p_utcNow}',64)
  scope: resourceGroup(p_vnetHubResourceGroup)
  params: {
    p_name: 'privatelink.${i}.${environment().suffixes.storage}'
    p_virtualNetworkId: existingVirtualNetwork.id
    p_virtualNetworkName: existingVirtualNetwork.name
    p_virtualNetworkResourceGroupName: p_vnetHubResourceGroup
    p_tags: p_tags
  }
  dependsOn: [
    sqlServerPrivateEndpoint
  ]
}]

module sqlServerPrivateDNSZoneGroup '../../modules/network/virtualNetwork/privateDNSZoneGroup.bicep' =  [for (name, i) in p_sqlServerEndPoint: if (c_privateEndpoint) {
  name: take('deploy${name}PrivateDNSZoneGroup-${p_nameIdentifier}-${p_utcNow}',64)
  scope: resourceGroup(p_sqlResourceGroup)
  params: {
    p_name: 'ep-privatelink.${name}.${environment().suffixes.storage}'
    p_dnsGroupName: 'dnsGroup-ep-privatelink.${name}.${environment().suffixes.storage}'
    p_privateDnsZoneId: sqlServerPrivateDNSZone[i].outputs.o_pdnsId
  }
  dependsOn: [
    sqlServerPrivateEndpoint
  ]
}]

module vulnerabiltyAssesStorageAccount '../../modules/storage/storageAccount.bicep' = if (c_enableSqlServerVulnerabiltyScan || c_enableSqlDBVulnerabiltyScan || c_enableSqlDBAlertPolicy || c_enableSqlserverAlertPolicy ) {   
  name: take('deployVulneAssesSA-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_sqlResourceGroup)
  params: {
     p_partialStorageAccountName: p_vulnerAssesPartialStorageAccountName
     p_tags: p_tags
  }
  dependsOn: [
    sqlMI
  ]
}

module vulnerabilityAssesContainer '../../modules/storage/container.bicep' = if (c_enableSqlServerVulnerabiltyScan || c_enableSqlDBVulnerabiltyScan || c_enableSqlDBAlertPolicy || c_enableSqlserverAlertPolicy ) {   
  name: take('deployVulnerAssesContainer-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_sqlResourceGroup)
  params: {
     o_storageAccountName: vulnerabiltyAssesStorageAccount.outputs.o_storageAcctName
     p_containerName: p_vulnerAssesContainerName
  }
  dependsOn: [
     sqlMI
  ]
}

module sqlServerVulnerabilityAssesmentScan '../../modules/SQL/sqlmi/SQLMIVulnerabilityAsses.bicep'  = if(c_enableSqlServerVulnerabiltyScan) {
  name: take('deploySqlServerVulnerAssesScan-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_sqlResourceGroup)
  params: {
     p_vulnerabilityScanEmails: p_vulnerabilityScanEmails
     p_storageAccountAccessKey: vulnerabiltyAssesStorageAccount.outputs.o_primaryKey
     p_storageContainerName: vulnerabilityAssesContainer.outputs.o_containerAcctName
     p_storageBlobPrimaryEndpoint: vulnerabiltyAssesStorageAccount.outputs.o_primaryBlobEndPoint
     p_sqlServerName: sqlMI.outputs.o_name
  }
  dependsOn: [
      sqlMI
  ]
}

module sqlDBVulnerabilityAssesmentScan '../../modules/SQL/sqlmi/SQLMIDBVulnerabilityAsses.bicep'  = if(c_enableSqlServerVulnerabiltyScan && c_enableSqlServerVulnerabiltyScan == false) {
  name: take('deploySQLDBVulnerAssesScan-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_sqlResourceGroup)
  params: {
     p_vulnerabilityScanEmails: p_vulnerabilityScanEmails
     p_storageAccountAccessKey: vulnerabiltyAssesStorageAccount.outputs.o_primaryKey
     p_storageContainerName: vulnerabilityAssesContainer.outputs.o_containerAcctName
     p_storageBlobPrimaryEndpoint: vulnerabiltyAssesStorageAccount.outputs.o_primaryBlobEndPoint
     p_sqlServerName: sqlMI.outputs.o_name
     p_sqlDBName: sqlDB.outputs.o_name
  }
  dependsOn: [
      sqlMI
      sqlDB
  ]
}

module sqlServerAlertPolicies '../../modules/SQL/sqlmi/SQLMIAlertPolicies.bicep'  = if (c_enableSqlserverAlertPolicy ) {
  name: take('deploySqlServerAlertPolicies-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_sqlResourceGroup)
  params: {
      p_sqlServerName: sqlMI.outputs.o_name
      p_emailAddresses: p_alertEmails
      p_storageEndpoint: vulnerabiltyAssesStorageAccount.outputs.o_primaryBlobEndPoint
      p_storageAccountAccessKey: vulnerabiltyAssesStorageAccount.outputs.o_primaryKey
  }
  dependsOn: [
    sqlMI
  ]
}

module sqlDBAlertPolicies '../../modules/SQL/sqlmi/SQLMIDBAlertPolicies.bicep'  = if (c_enableSqlserverAlertPolicy ) {
  name: take('deploySqlDBAlertPolicies-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_sqlResourceGroup)
  params: {
      p_sqlServerName: sqlMI.outputs.o_name
      p_sqlDBName: sqlDB.outputs.o_name
      p_emailAddresses: p_alertEmails
      p_storageEndpoint: vulnerabiltyAssesStorageAccount.outputs.o_primaryBlobEndPoint
      p_storageAccountAccessKey: vulnerabiltyAssesStorageAccount.outputs.o_primaryKey
  }
  dependsOn: [
    sqlMI
  ]
}

module synapseSQLPoolTDE'../../modules/SQL/sqlmi/SQLMIDBTDE.bicep'  = if(c_enableSqlDBTDE) {
  name: take('deploySqlDBTDE-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup(p_sqlResourceGroup)
  params: {
      p_sqlDBName: sqlDB.outputs.o_name
      p_sqlServerName: sqlMI.outputs.o_name
  }
  dependsOn: [
    sqlDB
    sqlMI
  ]
}

module KeyVaultEndpoint '../../modules/network/virtualNetwork/privateEndPoint.bicep' =  if (c_privateEndpoint) {
  name: take('deployKeyVaultEndpoint-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup('${p_keyVaultResourceGroup}')
  params: {
     p_privateEndPointName: 'ep-${p_nameIdentifier}-vault'
     p_groupIds: [
        'vault'
      ]
     p_subnetId:  existingVirtualNetwork.properties.subnets[0].id
     p_resourceId: existingKeyVault.id
     p_tags: p_tags
   }
  dependsOn: [
     existingKeyVault
     sqlMI
  ]
}

module keyvaultPrivateDNSZone '../../modules/network/virtualNetwork/privateDNSZone.bicep' = if (c_privateEndpoint) {
  name: take('deployKeyVaultPrivateDNSZone-${p_nameIdentifier}-${p_utcNow}',64)
  scope: resourceGroup('${p_vnetHubResourceGroup}')
  params: {
    p_name: 'privatelink${environment().suffixes.keyvaultDns}'
    p_virtualNetworkId: existingVirtualNetwork.id
    p_virtualNetworkName: existingVirtualNetwork.name
    p_virtualNetworkResourceGroupName: p_vnetHubResourceGroup
    p_tags: p_tags
  }
  dependsOn: [
     existingKeyVault
     KeyVaultEndpoint
  ]
}
module keyVaultPrivateDNSZoneGroup '../../modules/network/virtualNetwork/privateDNSZoneGroup.bicep' = if (c_privateEndpoint) {
  name: take('deployKVPrivateDNSZoneGroupZone-${p_nameIdentifier}-${p_utcNow}', 64)
  scope: resourceGroup('${p_keyVaultResourceGroup}')
  params: {
    p_name: KeyVaultEndpoint.outputs.o_privateEndpointName
    p_dnsGroupName: '${p_nameIdentifier}-kv-dnsGroup'
    p_privateDnsZoneId: keyvaultPrivateDNSZone.outputs.o_pdnsId
  }
  dependsOn: [
     keyvaultPrivateDNSZone
     KeyVaultEndpoint
  ]
}

//////////////////////////////////////////////////////////////////////////////////// 
// Section for Bicep outputs 
//////////////////////////////////////////////////////////////////////////////////// 

