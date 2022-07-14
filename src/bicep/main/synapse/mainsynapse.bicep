///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021-2022 Microsoft Corporation. All rights reserved. This
// Software is licensed under the MIT License. See LICENSE in the project root
// for license information.
///////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Description : This main synapse file  creates synapse analytics. 
// By default all synpase options/features  are enabled. This can be changed by modifying mainSynapseControls.json
//
// Dependency  
//   1. ../KeyVault/mainKeyVault.bicep (Optional if key vault already exists. In such case provide the name of key vault)
//   2. ../CommonEnvironment/mainCommonEnvironment.bicep 
//
//
///////////////////////////////////////////////////////////////////////////////////////////////////////

targetScope = 'subscription'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-I : Controls Synapse features
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Enable to create spark pool')
param c_createSparkPool bool

@description('Enable to create dedicated SQL Pool')
param c_createSQLPool bool

@description('Create storage accoounts for datalake. See p_dataZonesMulti & p_dataLakeStorageAcctZones for more information')
param c_createDatalakeZones bool

@description('Create private link hub')
param c_privatelinkhub bool

@description('Enable to create private end points for Synapse')
param c_privateSynapseEndpoint bool 

@description('Create end point for key vault')
param c_createKeyVaultprivateEndpoint bool 

@description('Enable alert policy for workspace')
param c_enableWorkspaceAlertPolicy bool

@description('Allow Azure services to connect to Synapse')
param c_allowAzureServices bool

@description('Enables SQL defender for workspace')
param c_enableWorkspaceVulnerabiltyScan bool

@description('Enable auditing of  Synapse Workspace')
param c_enableWorkspaceAuditSettings bool

@description('Enable alert policy for SQL Pool. Enabled if enabled for workspace')
param c_enableSQLPoolAlertPolicy bool 

@description('Enables SQL defender for SQL Pool. Enabled if enabled for workspace')
param c_enableSQLPoolVulnerabiltyScan bool

@description('Enable auditing of SQL Pool. Enabled if enabled for workspace')
param c_enableSQLPoolAuditSettings bool

@description('Enable SQLpool Transparent data encryption')
param c_enableSQLPoolTDE bool

@description('Use existing private DNS zones in  or existing environment. Update p_blobDNSZoneId if set to true')
param c_useBlobPrivateDNSzoneInNetworkHub bool

@description('Create spoke hub jumphost when integrating with MLZ or existing environment')
param c_createWindowsJumpHost bool 

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-II: Parameters passed from mainSynapseRequiredParams.json
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('User who will be added as Synapse admin')
param p_loginName string 

@description('Object Id for the user who will be added as Synapse admin')
param p_objectId string 

@description('List of email addresses to which scan notification is sent')
param p_vulnerabilityScanEmails array 

@description('List of email addresses to which alerts is sent')
param p_alertEmails array 

@description('Starting IP range to whitelist IPs')
param p_startIpAddress string 

@description('Ending IP range to whitelist IP')
param p_endIpAddress string 

@description('IP Address or range to be white listed')
param p_sourceAddressPrefix string

@description('Environment type. Update appropriate values for Soverign cloud')
param p_azureSynapseEnv string 


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-III : Subscription Id's
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Subscription Id for hub vnet')
param p_vnetHubSubscription string = subscription().subscriptionId

@description('Subscription Id for spoke vnet')
param p_vnetDataSubscription string = subscription().subscriptionId

@description('Subscription Id for monitor Log Anlaytics')
param p_monitorLogSubscription string = subscription().subscriptionId

@description('Subscription Id for Keyvault')
param p_keyVaultSubscription string = subscription().subscriptionId

@description('Subscription Id for Audit')
param p_auditLogSubscription string = subscription().subscriptionId

@description('Subscription Id in which Synapse workspace will be created')
param p_synapaseSubscription string = subscription().subscriptionId

@description('Subscription Id in which datalake storage accounts will be created (if enabled)')
param p_datalakeSubscription string = subscription().subscriptionId


///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-IV: Resource Group Names
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Common environment parameters. Name of Hub VNET')
param p_vnetHubResourceGroup string = 'rg-${p_nameIdentifier}-network'
//param p_vnetHubResourceGroup string = 'mddsh2fmlz-rg-hub-mlz'

@description('Common environment parameters. Name of Hub VNET')
param p_vnetDataResourceGroup string = 'rg-${p_nameIdentifier}-network'
// param p_vnetDataResourceGroup string = 'rg-datasyn-workload-rg'

@description('Deriving Synapse resource name from identifier')
param p_synapseResourceGroupName  string = 'rg-${p_nameIdentifier}-synapse-ws'
// param p_synapseResourceGroupName string = 'rg-datasyn-workload-rg'

@description('Resource group for monitor log storage and analytics')
param p_monitorLogResourceGroup string = 'rg-${p_nameIdentifier}-monitor'
// param p_monitorLogResourceGroup string = 'mddsh2fmlz-rg-operations-mlz'

@description('Resource Id for blob DNS zone in Hub Network. Required when integrating with MLZ i.e when p_useBlobPrivateDNSzoneInNetworkHub == true')
param p_blobDNSZoneId string = '/subscriptions/${p_vnetHubSubscription}/resourceGroups/${p_vnetHubResourceGroup}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.${environment().suffixes.storage}'

@description('Resource group for Audit log')
param p_auditLogResourceGroup string = 'rg-${p_nameIdentifier}-audit'

@description('Resource group for Datalake')
param p_datalakeResourceGroupName string = 'rg-${p_nameIdentifier}-datalake'

@description('Resource group for keyvault')
param p_keyVaultResourceGroup string = 'rg-${p_nameIdentifier}-keyVault'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-V : Resource Location
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('Location of Synapse workspace')
param p_synapseResourceGroupLocation string = 'eastus'

@description('Location of datalake storage accounts')
param p_datalakeResourceGroupLocation string = 'eastus'

@description('Location of Audit  log Resource group')
param p_auditLogResourceGroupLocation string = 'eastus'

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-VI: Declare remaining parameters here if needed
///////////////////////////////////////////////////////////////////////////////////////////////////////

@description('consistant unique identifer across all resources parameters. Default behaviour is to pass value from command line ')
param p_nameIdentifier string 

@description('Virtual Network Name')
param p_hubVnetName string = 'vnet-${p_nameIdentifier}'
// param p_hubVnetName string = 'mddsh2fmlz-vnet-hub-mlz'

@description('Virtual Network Name')
param p_dataVnetName string = 'vnet-${p_nameIdentifier}'
// param p_dataVnetName string = 'rg-datasyn-workload-vnet'

// Use network interface 'nic-${p_nameIdentifier}-no-pip' if Public Ip is being created
@description('Name of Network Interface for Spoke or Data Hub')
param p_dataHubNetworkInterface string =  'nic-${p_nameIdentifier}-no-pip'

@description('Common environment parameters - Monitoring Log Analytics Workspace')
param p_monitorLogAnalyticsWorkspace string = 'la-${p_nameIdentifier}-monitor'
// param p_monitorLogAnalyticsWorkspace string = 'mddsh2fmlz-log-operations-mlz'

@description('Monitoring Log Analytics')
param p_monitorLogAnalyticsStorageAccount string = toLower(replace('samlamon${p_nameIdentifier}', '-', ''))
// param p_monitorLogAnalyticsStorageAccount string = 'mddsh2fmlzstopsyy2ed77a'

@description('Name of the KeyVault to hold Sql Admin password')
param p_keyVaultName string = 'kv-${p_nameIdentifier}'

@description('Audit Log Storage Account')
param p_auditLogStorageAccount string = 'samlaaud${p_nameIdentifier}'

@description('Enable to create zones in multiple storage accts or disable to create Zones in separate containers of single storage acct')
param p_dataZonesMulti bool = true

@description('Datalake zones. Add or remove zones as needed;Separate storage accounts will be created for each zone')
param p_dataLakeStorageAcctZones array = [
   'raw'
   'curated'
   'structured'
   'analytics'
]

@description('Storage property to enable or disable hierarchical  namespace')
param p_isHnsEnabled bool = true

@description('Storage property, Allow https traffic only to storage service if enabled')
param p_supportsHttpsTrafficOnly bool = false

@description('Storage Account for Synapse metadata')
param p_synapsePartialStorageAccountName string = 'metadata'

@description('Container for Synapse filesystem in p_synapsePartialStorageAccountName')
param p_SynapseContainerName string = 'synapseFileSystem'

@description('Value for "User" user type')
param p_userPrincipalType string = 'User'

@description('Value for "Principal"  user type')
param p_servicePrincipalType string = 'ServicePrincipal'

param p_tags object = {
   Application: 'Not-Defined'
   CostCenter: 'Not-Defined'
   CreationDate: 'dateTime'
}

@description('Storage Account for Storing vulnerabilty assessment scan results')
param p_synapseVulnerAssesPartialStorageAccountName string = 'vulnerasses'

@description('Container name for Storing vulnerabilty assessment scan results')
param p_synapseVulnerAssesContainerName string = 'vulnerasses'

@description('Id for Storage Blob Data Contibutor role')
param p_storageBlobDataContributorRoleId string = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

@description('Id for Contributor role')
param p_contributorRoleDefinitionId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

@description('Id for Owner role')
param p_ownerRoleDefinitionId string = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'


@description('UTC timestamp used for deployment and other purposes')
param p_utcNow string = utcNow()

@description('Endpoint types for Synapse')
param synapseEndPoint array = [
   'Sql'
   'SqlOnDemand'
   'Dev'
]

@description('Enable Public IP')
param p_AssociatepublicIp bool = true

@description('NSG name')
param p_networkSecurityGroup string = 'nsg-${p_nameIdentifier}'

@description('NSG Security rules')
param p_securityRules array = [
      {
      name: 'Default-allow-3389'
      properties: {
        priority: 110
        access: 'Allow'
        direction: 'Inbound'
        destinationPortRange: '3389'
        protocol: 'Tcp'
        sourcePortRange: '*'
        sourceAddressPrefix: p_sourceAddressPrefix
        destinationAddressPrefix: '*'
      }
    }
]

///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-VII: Variables 
///////////////////////////////////////////////////////////////////////////////////////////////////////





///////////////////////////////////////////////////////////////////////////////////////////////////////
// Section-VIII: Modules 
///////////////////////////////////////////////////////////////////////////////////////////////////////

//
// Retreiving existing common environment Infrastructure
//
resource existingHubVirtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
   name: p_hubVnetName
   scope: resourceGroup(p_vnetHubSubscription,p_vnetHubResourceGroup)
}

resource existingDataVirtualNetwork 'Microsoft.Network/virtualNetworks@2020-05-01' existing = {
   name: p_dataVnetName
   scope: resourceGroup(p_vnetDataSubscription,p_vnetDataResourceGroup)
}

resource existingDataHubNetworkInterface 'Microsoft.Network/networkInterfaces@2021-02-01' existing = {
   name: p_dataHubNetworkInterface
   scope: resourceGroup(p_vnetDataSubscription,p_vnetDataResourceGroup)
}

resource existingKeyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing  = {
   name: p_keyVaultName
   scope: resourceGroup(p_keyVaultSubscription, p_keyVaultResourceGroup)
}

 resource  existingLogAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
   name: p_monitorLogAnalyticsWorkspace
   scope: resourceGroup(p_monitorLogSubscription, p_monitorLogResourceGroup)
 }
  
resource existingLogAnalyticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
   name: p_monitorLogAnalyticsStorageAccount
   scope: resourceGroup(p_monitorLogSubscription, p_monitorLogResourceGroup)
}


 

// Implementing Synpase infrastructure
module synapseResourceGroup '../../modules/resourcegroup/resourceGroup.bicep' = if (c_createSparkPool) {
   name: take('deploySynapseRG-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: subscription(p_synapaseSubscription)
   params: {
      p_name: p_synapseResourceGroupName
      p_location: p_synapseResourceGroupLocation
      p_tags: p_tags
   }
   dependsOn: [
      existingDataVirtualNetwork
   ]
}

 // Auditing 
 module auditResourceGroup '../../modules/resourceGroup/resourceGroup.bicep' = {
   name: take('deployAuditRG-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: subscription(p_auditLogSubscription)
   params: {
     p_name: p_auditLogResourceGroup
     p_location: p_auditLogResourceGroupLocation
     p_tags: p_tags
   }
 }
 
 module auditLogStorageAccount '../../modules/storage/storageAccount.bicep' = {
   name: take('deployAuditStorageAcct-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_auditLogSubscription, p_auditLogResourceGroup)
   params: {
     p_manualStorageAcctName: p_auditLogStorageAccount
     p_supportsHttpsTrafficOnly: p_supportsHttpsTrafficOnly
     p_tags: p_tags
   }
   dependsOn: [
     auditResourceGroup
     ]
 }

module datalakeResourceGroup '../../modules/resourcegroup/resourceGroup.bicep' = if (c_createDatalakeZones) {
   name: take('deployDatalakeRG-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: subscription(p_datalakeSubscription)
   params: {
      p_name: p_datalakeResourceGroupName
      p_location: p_datalakeResourceGroupLocation
      p_tags: p_tags
   }
   dependsOn: [
      existingDataVirtualNetwork
   ]
}

module userManagedId '../../modules/identity/managedIdentity.bicep' =  {
   name: take('deployUsermanagedId-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup('${p_keyVaultResourceGroup}')
   params: {
          p_name: p_nameIdentifier
      }
   dependsOn: [
      existingKeyVault
      ]
} 

module KeyAccessPolicyForAdmin '../../modules/keyVault/accessPolicies/accessPolicy.bicep' = {
   name: take('deployKeyPolicy-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup('${p_keyVaultResourceGroup}')
   params: {
      p_objectId: p_objectId
      p_keyVaultName: existingKeyVault.name
   }
   dependsOn: [
      existingDataVirtualNetwork
   ]
}

module storeSecretSQLAdmin '../../modules/keyVault/secret/secrets.bicep' = {
   name: take('deployStoreSecretSQLAdmin-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup('${p_keyVaultResourceGroup}')
   params: {
      p_secretName: 'sqladmin'
      p_keyVaultName: existingKeyVault.name
   }
   dependsOn: [
      KeyAccessPolicyForAdmin
   ]
}

module createCMK '../../modules/keyVault/key/keys.bicep' = {
   name: take('deployCMK-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup('${p_keyVaultResourceGroup}')
   params: {
      p_keyName: 'key-cmk-${p_nameIdentifier}'
      p_keyVaultName: existingKeyVault.name
   }
   dependsOn: [
      existingDataVirtualNetwork
      storeSecretSQLAdmin
   ]
}

module synapseStorageAccount '../../modules/storage/storageAccount.bicep' = {
   name: take('deploySynpaseSA-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_isHnsEnabled: p_isHnsEnabled
      p_partialStorageAccountName: p_synapsePartialStorageAccountName
      p_tags: p_tags
   }
   dependsOn: [
      existingDataVirtualNetwork
      synapseResourceGroup
   ]
}

module synapseFileSystem '../../modules/storage/container.bicep' = {
   name: take('deploySynapseFS-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      o_storageAccountName: synapseStorageAccount.outputs.o_storageAcctName
      p_containerName: p_SynapseContainerName
   }
   dependsOn: [
      existingDataVirtualNetwork
      synapseStorageAccount
   ]
}

module blobPrivateDNSZone '../../modules/network/virtualNetwork/privateDNSZone.bicep' =  if (c_createDatalakeZones && c_useBlobPrivateDNSzoneInNetworkHub == false) {
   name: take('deployBlobPrivateDNSZone-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup('${p_vnetHubResourceGroup}')
   params: {
     p_name: 'privatelink.blob.${environment().suffixes.storage}'
     p_virtualNetworkId: existingHubVirtualNetwork.id
     p_virtualNetworkName: existingHubVirtualNetwork.name
     p_virtualNetworkResourceGroupName: p_vnetHubResourceGroup
     p_tags: p_tags
   }
   dependsOn: [
      existingDataVirtualNetwork
   ]
 }
 

module keyvaultPrivateDNSZone '../../modules/network/virtualNetwork/privateDNSZone.bicep' = if (c_privateSynapseEndpoint) {
   name: take('deployKeyVaultPrivateDNSZone-${p_nameIdentifier}-${p_utcNow}',64)
   scope: resourceGroup('${p_vnetHubResourceGroup}')
   params: {
     p_name: 'privatelink${environment().suffixes.keyvaultDns}'
     p_virtualNetworkId: existingHubVirtualNetwork.id
     p_virtualNetworkName: existingHubVirtualNetwork.name
     p_virtualNetworkResourceGroupName: p_vnetHubResourceGroup
     p_tags: p_tags
   }
   dependsOn: [
      existingHubVirtualNetwork
   ]
}

module KeyVaultEndpoint '../../modules/network/virtualNetwork/privateEndPoint.bicep' = if(c_createKeyVaultprivateEndpoint) {
   name: take('deployKeyVaultEndpoint-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_keyVaultResourceGroup)
   params: {
      p_privateEndPointName: 'ep-${p_nameIdentifier}-vault'
      p_groupIds: [
         'vault'
       ]
      p_subnetId:  existingDataVirtualNetwork.properties.subnets[0].id
      p_resourceId:  existingKeyVault.id
      p_tags: p_tags
    }
   dependsOn: [
      existingDataVirtualNetwork
   ]
}

module keyVaultPrivateDNSZoneGroup '../../modules/network/virtualNetwork/privateDNSZoneGroup.bicep'   = if(c_createKeyVaultprivateEndpoint) {
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

 module synapseWorkspace '../../modules/synapse/workspace/synapseWorkspace.bicep' = {
   name: take('deploySynapseWS-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_nameIdentifier: p_nameIdentifier
      o_accountUrl: synapseStorageAccount.outputs.o_accountUrl
      p_containerAcctName: p_SynapseContainerName
      p_keyUrl: createCMK.outputs.o_keyUriWithOutVersion
      p_workspaceKeyName: createCMK.outputs.o_keyName
      p_sqlAdministratorLogin: storeSecretSQLAdmin.outputs.o_secretName
      p_sqlAdministratorLoginPassword: existingKeyVault.getSecret(storeSecretSQLAdmin.outputs.o_secretName)
   }
   dependsOn: [
      existingDataVirtualNetwork
      synapseFileSystem
      KeyAccessPolicyForAdmin
      storeSecretSQLAdmin
   ]
}
module keyAccessPolicyForSysManagedIdentity '../../modules/keyVault/accessPolicies/accessPolicy.bicep' = {
   name: take('deployKeyPolicySysManagedId-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup('${p_keyVaultResourceGroup}')
   params: {
      p_objectId: synapseWorkspace.outputs.o_systemManagedIdentity
      p_keyVaultName: existingKeyVault.name
   }
   dependsOn: [
      existingDataVirtualNetwork
      synapseWorkspace
   ]
}

module roleAssignforUserManagedIdentity '../../modules/synapse/security/synapseRoleassignment.bicep' = {
   name: take('deployRoleAssigManagedIdentity-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_synapseWorkspaceName: synapseWorkspace.outputs.o_workspaceName
      p_roleDefinitionId: p_contributorRoleDefinitionId
      p_principalType: p_servicePrincipalType
      p_principalId: userManagedId.outputs.o_principalId   
   }
   dependsOn: [
      synapseWorkspace
   ]
}

module roleAssignforAdminUser '../../modules/synapse/security/synapseRoleassignment.bicep' = {
   name: take('deployRoleAssigManagedAdmin-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_synapseWorkspaceName: synapseWorkspace.outputs.o_workspaceName
      p_roleDefinitionId: p_ownerRoleDefinitionId
      p_principalType: p_userPrincipalType
      p_principalId: p_objectId
   }
   dependsOn: [
      synapseWorkspace
   ]
}

module activateWS '../../modules/synapse/workspace/SynapseWSActivation.bicep' = {
   name: take('deployActivateWS-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapaseSubscription ,p_synapseResourceGroupName)
   params: {
      p_workspaceName: synapseWorkspace.outputs.o_workspaceName
      p_workspaceKeyName: createCMK.outputs.o_keyName
      p_keyUrl: createCMK.outputs.o_keyUriWithOutVersion
      p_userAssignedIdentities: userManagedId.outputs.o_id
   }
   dependsOn: [
      keyAccessPolicyForSysManagedIdentity
      roleAssignforUserManagedIdentity
   ]
}

module synapseWSwait '../../modules/synapse/workspace/SynapseWSWait.bicep' = {
   name: take('deployWaitWS-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_workspaceName: synapseWorkspace.outputs.o_workspaceName
      p_userAssignedIdentities: userManagedId.outputs.o_id
   }
   dependsOn: [
      activateWS
   ]
}

module synapseSparkPool '../../modules/synapse/pools/sparkpool.bicep' = if (c_createSparkPool) {
   name: take('deploySynapseSparkpool-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_nameIdentifier: p_nameIdentifier
      o_workspaceName: synapseWorkspace.outputs.o_workspaceName
   }
   dependsOn: [
      synapseWSwait
   ]
}

module synapseSQLPool '../../modules/synapse/pools/sqlpool.bicep' = if (c_createSQLPool) {
   name: take('deploySynapseSQLPool-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_nameIdentifier: p_nameIdentifier
      o_workspaceName: synapseWorkspace.outputs.o_workspaceName
   }
   dependsOn: [
      synapseWSwait
   ]
}

module firewall '../../modules/synapse/security/synapsefirewall.bicep' =  {
   name: take('deploySynapseFirewall-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   dependsOn: [
      synapseSQLPool
   ]
   params: {
      o_workspaceName: synapseWorkspace.outputs.o_workspaceName
      p_nameIdentifier: p_nameIdentifier
      p_startIpAddress: p_startIpAddress
      p_endIpAddress: p_endIpAddress
   }
}

module firewallAllowAzureServices '../../modules/synapse/security/synapsefirewall.bicep' = if(c_allowAzureServices)  {
   name: take('deploySynapseFirewallAllowAzureServices-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   dependsOn: [
      synapseSQLPool
      firewall
   ]
   params: {
      o_workspaceName: synapseWorkspace.outputs.o_workspaceName
      p_nameIdentifier: p_nameIdentifier
      p_startIpAddress: '0.0.0.0'
      p_endIpAddress: '0.0.0.0'
   }
}

module roleAssignment '../../modules/identity/roleAssignment.bicep' = {
   name: take('deploySynapseRoleAssig-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup('${p_keyVaultResourceGroup}')
   params: {
      p_keyVaultName: existingKeyVault.name
      p_roleDefinitionId: p_storageBlobDataContributorRoleId
      p_principalType: p_userPrincipalType
      p_principalId: p_objectId   
   }
   dependsOn: [
      synapseSQLPool
      firewallAllowAzureServices
   ]
}

module synapseAdmin '../../modules/synapse/security/SynapseAdmin.bicep' = {
   name: take('deploySynapseAdmin-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_objectId: p_objectId
      p_loginName: p_loginName
      p_workspaceName: synapseWorkspace.outputs.o_workspaceName
   }
   dependsOn: [
      synapseSQLPool
      firewallAllowAzureServices
      roleAssignforAdminUser
   ]
}

// Implemnent Vulnerabilty Scan in separate storage account
module synapseVulnerabiltyAssesStorageAccount '../../modules/storage/storageAccount.bicep' = if(c_enableWorkspaceAlertPolicy || c_enableSQLPoolAlertPolicy || c_enableWorkspaceVulnerabiltyScan || c_enableSQLPoolVulnerabiltyScan)  {
   name: take('deploySynpaseVulneAssesSA-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_partialStorageAccountName: p_synapseVulnerAssesPartialStorageAccountName
      p_tags: p_tags
   }
   dependsOn: [
      existingDataVirtualNetwork
      synapseResourceGroup
   ]
}

module synapseVulnerabilityAssesContainer '../../modules/storage/container.bicep' = if(c_enableWorkspaceAlertPolicy || c_enableSQLPoolAlertPolicy || c_enableWorkspaceVulnerabiltyScan || c_enableSQLPoolVulnerabiltyScan)  {
   name: take('deploySynapseVulnerAssesContainer-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      o_storageAccountName: synapseVulnerabiltyAssesStorageAccount.outputs.o_storageAcctName
      p_containerName: p_synapseVulnerAssesContainerName
   }
   dependsOn: [
      synapseVulnerabiltyAssesStorageAccount
   ]
}

module synapseWorkspaceAlertPolicies '../../modules/synapse/security/SynapseWorkspaceAlertPolicies.bicep'  = if(c_enableWorkspaceAlertPolicy ) {
   name: take('deploySynapseWSAlertPolicies-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
       p_workspaceName: synapseWorkspace.outputs.o_workspaceName
       p_emailAddresses: p_alertEmails
       p_storageEndpoint: synapseVulnerabiltyAssesStorageAccount.outputs.o_primaryBlobEndPoint
       p_storageAccountAccessKey: synapseVulnerabiltyAssesStorageAccount.outputs.o_primaryKey
   }
   dependsOn: [
      synapseSQLPool
      synapseVulnerabiltyAssesStorageAccount
   ]
}

module synapseSQLPoolAlertPolicies '../../modules/synapse/security/SynapseSQLPoolAlertPolicies.bicep'  = if(c_enableSQLPoolAlertPolicy && c_enableWorkspaceAlertPolicy == false ) {
   name: take('deploySQLPoolAlertPolicies-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
       p_sqlPoolName: synapseSQLPool.outputs.o_sqlPoolName
       p_location: synapseSQLPool.outputs.o_sqlPoolLocation
       p_emailAddresses: p_alertEmails
       p_storageEndpoint: synapseVulnerabiltyAssesStorageAccount.outputs.o_primaryBlobEndPoint
       p_storageAccountAccessKey: synapseVulnerabiltyAssesStorageAccount.outputs.o_primaryKey
   }
   dependsOn: [
      synapseSQLPool
      synapseVulnerabiltyAssesStorageAccount
   ]
}

module synapseWorkspaceVulnerabilityAssesmentScan '../../modules/synapse/security/synapseWorkspaceVulnerabilityAsses.bicep'  = if(c_enableWorkspaceVulnerabiltyScan)  {
   name: take('deploySynapseWSVulnerAssesScan-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_vulnerabilityScanEmails: p_vulnerabilityScanEmails
      p_storageAccountAccessKey: synapseVulnerabiltyAssesStorageAccount.outputs.o_primaryKey
      p_storageContainerName: synapseVulnerabilityAssesContainer.outputs.o_containerAcctName
      p_storageBlobPrimaryEndpoint: synapseVulnerabiltyAssesStorageAccount.outputs.o_primaryBlobEndPoint
      p_workspaceName: synapseWorkspace.outputs.o_workspaceName
   }
   dependsOn: [
      synapseSQLPool
      synapseVulnerabiltyAssesStorageAccount
      synapseVulnerabilityAssesContainer
      synapseWorkspaceAlertPolicies
   ]
}

module synapseSQLPoolVulnerabilityAssesmentScan '../../modules/synapse/security/synapseSQLPoolVulnerabilityAsses.bicep'  = if(c_enableSQLPoolVulnerabiltyScan && c_enableWorkspaceVulnerabiltyScan == false)  {
   name: take('deploySQLPoolVulnerAssesScan-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_vulnerabilityScanEmails: p_vulnerabilityScanEmails
      p_storageAccountAccessKey: synapseVulnerabiltyAssesStorageAccount.outputs.o_primaryKey
      p_storageContainerName: synapseVulnerabilityAssesContainer.outputs.o_containerAcctName
      p_storageBlobPrimaryEndpoint: synapseVulnerabiltyAssesStorageAccount.outputs.o_primaryBlobEndPoint
      p_sqlPoolName: synapseSQLPool.outputs.o_sqlPoolName
      p_location: synapseSQLPool.outputs.o_sqlPoolLocation
   }
   dependsOn: [
      synapseSQLPool
      synapseVulnerabiltyAssesStorageAccount
      synapseVulnerabilityAssesContainer
      synapseWorkspaceAlertPolicies
   ]
}

module synapseWorkspaceAuditSettings'../../modules/synapse/security/synapseWorkspaceAuditSettings.bicep'  = if(c_enableWorkspaceAuditSettings){
   name: take('deploySynapseWSAuditSettings-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_storageAccountSubscriptionId: p_auditLogSubscription
      p_storageEndpoint: auditLogStorageAccount.outputs.o_primaryBlobEndPoint
      p_storageAccountAccessKey: auditLogStorageAccount.outputs.o_primaryKey
      p_workspaceName: synapseWorkspace.outputs.o_workspaceName
   }
   dependsOn: [
      existingLogAnalyticsWorkspace
      synapseSQLPool
      synapseVulnerabiltyAssesStorageAccount
   ]
}

module synapseSQLPoolAuditSettings'../../modules/synapse/security/synapseSQLPoolAuditSettings.bicep'  = if(c_enableSQLPoolAuditSettings && c_enableWorkspaceAuditSettings == false)  {
   name: take('deploySQLPoolAuditSettings-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_storageAccountSubscriptionId: p_monitorLogSubscription
      p_storageEndpoint:  auditLogStorageAccount.outputs.o_primaryBlobEndPoint
      p_storageAccountAccessKey: auditLogStorageAccount.outputs.o_primaryKey
      p_sqlPoolName: synapseSQLPool.outputs.o_sqlPoolName
      p_location: synapseSQLPool.outputs.o_sqlPoolLocation
   }
   dependsOn: [
      synapseSQLPool
      synapseVulnerabiltyAssesStorageAccount
   ]
}

module synapseWSlogAnalyticsDiag '../../modules/synapse/security/synpaseWSLogAnalyticsDiagnostic.bicep'  = {
   name: take('deployWSLogAnalytics-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_workspaceName: synapseWorkspace.outputs.o_workspaceName
      p_logAnalyticsWorkspaceId: existingLogAnalyticsWorkspace.id
      p_diagnosticStorageAccountid: existingLogAnalyticsStorageAccount.id 
   }
   dependsOn: [
      synapseSQLPool
      synapseSQLPoolAuditSettings
      ]
}

module synapsePrivateLinkHub'../../modules/synapse/workspace/synapsePrivateLinkHub.bicep'= if (c_privatelinkhub){
   name: take('deploySynapsePrivateLinkHub-${p_nameIdentifier}-${p_utcNow}',64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
     p_nameIdentifier: p_nameIdentifier
     p_tags: p_tags
   }
   dependsOn: [
      synapseSQLPool
      synapseResourceGroup
  ]
 }
 
 module synapsePrivateLinkHubEndpoint '../../modules/network/virtualNetwork/privateEndPoint.bicep' = if(c_privatelinkhub) {
   name: take('deploySynapsePrivateLinkHubEndPoint-${p_nameIdentifier}-${p_utcNow}',64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
     p_privateEndPointName: 'ep-${p_nameIdentifier}-privatelink-web'
     p_groupIds: [
        'web'
      ]
     p_subnetId:  existingDataVirtualNetwork.properties.subnets[0].id
     p_resourceId: synapsePrivateLinkHub.outputs.o_synapsePrivateLinkHubId
     p_sourceResourceId: synapseWorkspace.outputs.o_workspaceId
     p_tags: p_tags
   }
   dependsOn: [
      synapsePrivateLinkHub
      synapseResourceGroup
      existingDataVirtualNetwork
  ]
 }
 
 module synapseLinkhubPrivateDNSZone '../../modules/network/virtualNetwork/privateDNSZone.bicep' = if (c_privateSynapseEndpoint  && c_privatelinkhub) {
   name: take('deployLinkhubPrivateDNSZone-${p_nameIdentifier}-${p_utcNow}',64)
   scope: resourceGroup('${p_vnetHubResourceGroup}')
   params: {
     p_name: 'privatelink.${p_azureSynapseEnv}'
     p_virtualNetworkId: existingDataVirtualNetwork.id
     p_virtualNetworkName: existingDataVirtualNetwork.name
     p_virtualNetworkResourceGroupName: p_vnetHubResourceGroup
     p_tags: p_tags
   }
   dependsOn: [
      synapsePrivateLinkHubEndpoint
      existingDataVirtualNetwork
      synapseResourceGroup
      datalakeResourceGroup
   ]
}

module synapseLinkhubPrivateDNSZoneGroup '../../modules/network/virtualNetwork/privateDNSZoneGroup.bicep'  = if(c_privateSynapseEndpoint) {
   name: take('deployLinkhubPrivateDNSZoneGroup-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
     p_name: synapsePrivateLinkHubEndpoint.outputs.o_privateEndpointName
     p_dnsGroupName: '${p_nameIdentifier}-linkhub-dnsGroup'
     p_privateDnsZoneId: synapseLinkhubPrivateDNSZone.outputs.o_pdnsId
   }
   dependsOn: [
     synapseLinkhubPrivateDNSZone
     synapseResourceGroup
   ]
 }

module synapseStoragePrivateEndpoint '../../modules/network/virtualNetwork/privateEndPoint.bicep' = if(c_privateSynapseEndpoint) {
   name: take('deploySynapsetorageFSEndPoint-${p_nameIdentifier}-${p_utcNow}',64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
     p_privateEndPointName: 'ep-${p_nameIdentifier}-synapsefs-blob'
     p_groupIds: [
        'blob'
      ]
     p_subnetId:  existingDataVirtualNetwork.properties.subnets[0].id
     p_resourceId:  synapseStorageAccount.outputs.o_id
     p_sourceResourceId: synapseWorkspace.outputs.o_workspaceId
     p_tags: p_tags
   }
   dependsOn: [
      synapseStorageAccount  
      synapseWSwait
      synapseResourceGroup
      existingDataVirtualNetwork
   ]
 }

 module synapseFSPrivateDNSZoneGroup '../../modules/network/virtualNetwork/privateDNSZoneGroup.bicep'  = if(c_privateSynapseEndpoint) {
   name: take('deployFSPrivateDNSZoneGroup-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
     p_name: synapseStoragePrivateEndpoint.outputs.o_privateEndpointName
     p_dnsGroupName: '${p_nameIdentifier}-synapseFS-dnsGroup'
     p_privateDnsZoneId: c_useBlobPrivateDNSzoneInNetworkHub ? p_blobDNSZoneId : blobPrivateDNSZone.outputs.o_pdnsId 
   }
   dependsOn: [
     //blobPrivateDNSZone
     synapseStoragePrivateEndpoint
     synapseResourceGroup
   ]
 }

// Implement private end points for Synapse  SQL/Dev/FileSystem end points
module synapsePrivateEndpoint '../../modules/network/virtualNetwork/privateEndPoint.bicep' = [ for i in synapseEndPoint: if (c_privateSynapseEndpoint) {
   name: take('deploySynapse${i}EndPoint-${p_nameIdentifier}-${p_utcNow}',64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
     p_privateEndPointName: 'ep-${p_nameIdentifier}-${i}'
     p_groupIds: [
        '${i}'
      ]
     p_subnetId:  existingDataVirtualNetwork.properties.subnets[0].id
     p_resourceId: synapseWorkspace.outputs.o_workspaceId
     p_tags: p_tags
   }
   dependsOn: [
      synapseAdmin
      synapseResourceGroup
      existingDataVirtualNetwork
  ]
 }]

 module synapsePrivateDNSZone '../../modules/network/virtualNetwork/privateDNSZone.bicep' = [ for i in synapseEndPoint: if (c_privateSynapseEndpoint) {
   name: take('deploy${i}-SynapsePrivateDNSZone-${p_nameIdentifier}-${p_utcNow}',64)
   scope: resourceGroup('${p_vnetHubResourceGroup}')
   params: {
     p_name:  'privatelink.${i}.${p_azureSynapseEnv}'
     p_virtualNetworkId: existingDataVirtualNetwork.id
     p_virtualNetworkName: existingDataVirtualNetwork.name
     p_virtualNetworkResourceGroupName: p_vnetHubResourceGroup
     p_tags: p_tags
   }
   dependsOn: [
      existingDataVirtualNetwork
      synapseResourceGroup
   ]
 }]

module synapsePrivateDNSZoneGroup '../../modules/network/virtualNetwork/privateDNSZoneGroup.bicep'  = [ for (name, i) in synapseEndPoint: if (c_privateSynapseEndpoint) {
   name: take('deploySynapsePrivateDNSZoneGroup-${name}-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
     p_name: 'ep-${p_nameIdentifier}-${name}'
     p_dnsGroupName: '${p_nameIdentifier}-synapse-dnsGroup'
     p_privateDnsZoneId: synapsePrivateDNSZone[i].outputs.o_pdnsId
   }
   dependsOn: [
      synapsePrivateDNSZone
      synapsePrivateEndpoint
      synapseResourceGroup
   ]
 }]

 module synapseSQLPoolTDE'../../modules/synapse/security/SynapseSQLPoolTDE.bicep'  = if(c_enableSQLPoolTDE) {
   name: take('deploySQLPoolTDE-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
      p_sqlPoolName: synapseSQLPool.outputs.o_sqlPoolName
      p_location: synapseSQLPool.outputs.o_sqlPoolLocation
   }
   dependsOn: [
      synapseSQLPoolAuditSettings
      synapseWorkspaceAuditSettings
      synapseSQLPoolAlertPolicies
      synapseWorkspaceAlertPolicies
      synapseSQLPoolVulnerabilityAssesmentScan
      synapseWorkspaceVulnerabilityAssesmentScan
      synapseResourceGroup
   ]
}

// Multiple storage Accounts for datalake as defined in p_dataLakeStorageAcctZones
module multiDatalakeStorageAccount '../../modules/storage/datalakeStorageAccounts.bicep' = [for i in p_dataLakeStorageAcctZones: if (c_createDatalakeZones && p_dataZonesMulti ) {
   name: take('deployMdatalakeSA${i}-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_datalakeResourceGroupName)
   params: {
      p_isHnsEnabled: p_isHnsEnabled
      p_supportsHttpsTrafficOnly: p_supportsHttpsTrafficOnly
      p_partialStorageAccountName: '${i}'
      p_tags: p_tags
      p_nameIdentifier: p_nameIdentifier
   }
   dependsOn: [
      datalakeResourceGroup
   ]
}]


module multiDatalakeStorageEndpoint '../../modules/network/virtualNetwork/privateEndPoint.bicep' =  [for (name,i) in p_dataLakeStorageAcctZones: if (c_createDatalakeZones && p_dataZonesMulti ) {
   name: take('deployMDatalake${name}EndPoint-${p_nameIdentifier}-${p_utcNow}',64)
   scope: resourceGroup(p_datalakeResourceGroupName)
   params: {
     p_privateEndPointName: 'ep-${name}-${p_nameIdentifier}-blob'
     p_groupIds: [
        'blob'
      ]
     p_subnetId:  existingDataVirtualNetwork.properties.subnets[0].id
     p_resourceId: multiDatalakeStorageAccount[i].outputs.o_id
     p_tags: p_tags
   }
   dependsOn: [
      synapseAdmin
      datalakeResourceGroup
      multiDatalakeStorageAccount
  ]
}]

module blobPrivateDNSZoneGroup '../../modules/network/virtualNetwork/privateDNSZoneGroup.bicep'  = [for i in p_dataLakeStorageAcctZones: if (c_createDatalakeZones && p_dataZonesMulti ) {
   name: take('deployPrivateDNSZoneGroup--${i}-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_datalakeResourceGroupName)
   params: {
     p_name: 'ep-${i}-${p_nameIdentifier}-blob'
     p_dnsGroupName: '${p_nameIdentifier}-blob-dnsGroup'
     p_privateDnsZoneId: c_useBlobPrivateDNSzoneInNetworkHub ? p_blobDNSZoneId : blobPrivateDNSZone.outputs.o_pdnsId 
   }
   dependsOn: [
     //blobPrivateDNSZone
     multiDatalakeStorageEndpoint
     datalakeResourceGroup
   ]
 }]
 
// Single storage Accounts for datalake with  countainers  as defined in p_dataLakeStorageAcctZones
module singleDatalakeStorageAccount '../../modules/storage/datalakeStorageAccounts.bicep' = if (c_createDatalakeZones && p_dataZonesMulti ) {
   name: take('deploySdatalakeSA-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_datalakeResourceGroupName)
   params: {
      p_isHnsEnabled: p_isHnsEnabled
      p_supportsHttpsTrafficOnly: p_supportsHttpsTrafficOnly
      p_partialStorageAccountName: 'datalake'
      p_tags: p_tags
      p_nameIdentifier: p_nameIdentifier
   }
   dependsOn: [
      datalakeResourceGroup 
      existingDataVirtualNetwork
   ]
}

module singleDatalakeSAContainer '../../modules/storage/container.bicep' = [for i in p_dataLakeStorageAcctZones: if (c_createDatalakeZones && p_dataZonesMulti ) {
   name: take('deploySDatalakeCont${i}-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_datalakeResourceGroupName)
   params: {
      o_storageAccountName: singleDatalakeStorageAccount.outputs.o_storageAcctName
      p_containerName: '${i}'
   }
   dependsOn: [
      singleDatalakeStorageAccount
      datalakeResourceGroup
   ]
}]

module singleDatalakeStorageEndpoint '../../modules/network/virtualNetwork/privateEndPoint.bicep' =   if (c_createDatalakeZones && p_dataZonesMulti ) {
   name: take('deploySDatalakeEP-${p_nameIdentifier}-${p_utcNow}',64)
   scope: resourceGroup(p_datalakeResourceGroupName)
   params: {
     p_privateEndPointName: 'ep-${singleDatalakeStorageAccount.outputs.o_storageAcctName}-blob'
     p_groupIds: [
        'blob'
      ]
     p_subnetId:  existingDataVirtualNetwork.properties.subnets[0].id
     p_resourceId: singleDatalakeStorageAccount.outputs.o_id
     p_tags: p_tags
   }
   dependsOn: [
      singleDatalakeStorageAccount
      datalakeResourceGroup
  ]
 }

 module sBlobPrivateDNSZoneGroup '../../modules/network/virtualNetwork/privateDNSZoneGroup.bicep'  = if (c_createDatalakeZones && p_dataZonesMulti ) {
   name: take('deploySBlobPrivateDNSZoneGroupZone-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_datalakeResourceGroupName)
   params: {
     p_name: singleDatalakeStorageEndpoint.outputs.o_privateEndpointName
     p_dnsGroupName: '${p_nameIdentifier}-blob-dnsGroup'
     p_privateDnsZoneId: c_useBlobPrivateDNSzoneInNetworkHub ? p_blobDNSZoneId : blobPrivateDNSZone.outputs.o_pdnsId 
   }
   dependsOn: [
     //blobPrivateDNSZone
     singleDatalakeStorageEndpoint
     datalakeResourceGroup
   ]
 }

 // Creating Windows Jump host for MLZ integration
 module jumphostNetworkSecurityGroup '../../modules/network/virtualNetwork/networkSecurityGroup.bicep' = if (c_createWindowsJumpHost) {
   name: take('deployNSG-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
     p_networkSecurityGroup: p_networkSecurityGroup
     p_location: p_synapseResourceGroupLocation
     p_tags: p_tags
     p_securityRules: p_securityRules
   }
   dependsOn: [
     existingDataVirtualNetwork
   ]
 }
 module publicIp '../../modules/network/virtualNetwork/publicIpAddress.bicep' = if (c_createWindowsJumpHost) {
   name: take('deployPip-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
     p_nameIdentifier: p_nameIdentifier
   }
   dependsOn: [
     existingDataHubNetworkInterface
   ]
 }
 
 // Uncommment  p_publicIpId if c_createPublicIp  is true
 module networkInterface '../../modules/network/virtualNetwork/networkInterface.bicep' = if (c_createWindowsJumpHost ) {
   name: take('deployNetworkIntPip-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
     p_networkSecurityGroupId: jumphostNetworkSecurityGroup.outputs.o_networkSecurityGroupId
     p_subnetId: existingDataVirtualNetwork.properties.subnets[0].id
     p_location: p_synapseResourceGroupLocation
     p_AssociatepublicIp: p_AssociatepublicIp
     p_publicIpId: publicIp.outputs.o_publicIpId
   }
   dependsOn: [
     existingDataHubNetworkInterface
     jumphostNetworkSecurityGroup
   ]
 }
 
 module storeSecretWinAdmin '../../modules/keyVault/secret/secrets.bicep' = if (c_createWindowsJumpHost) {
   name: take('deployStoreSecretWinAdmin-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup('${p_keyVaultResourceGroup}')
   params: {
      p_secretName: 'winadmin'
      p_keyVaultName: existingKeyVault.name
   }
   dependsOn: [
     existingKeyVault
   ]
 }

 
 module windowsJumpHost '../../modules/virtualmachines/windows/windowsVM.bicep' = if (c_createWindowsJumpHost) {
   name: take('deployJumpHost-${p_nameIdentifier}-${p_utcNow}', 64)
   scope: resourceGroup(p_synapseResourceGroupName)
   params: {
     p_nameIdentifier: p_nameIdentifier
     p_networkInterfaceId: networkInterface.outputs.o_networkInterfaceId
     p_networkInterfaceName: networkInterface.outputs.o_networkInterfaceName
     p_adminUsername: storeSecretWinAdmin.outputs.o_secretName
     p_adminPassword: existingKeyVault.getSecret(storeSecretWinAdmin.outputs.o_secretName)
   }
   dependsOn: [
     existingKeyVault
     existingDataVirtualNetwork
     storeSecretWinAdmin
     networkInterface
   ]
 }
