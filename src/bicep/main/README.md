# Installation instruction for main deployment scripts 

#Dependency  
  1. ../KeyVault/mainKeyVault.bicep (Optional if key vault already exists. In such case provide the name of key vault)   2. ../CommonEnvironment/mainCommonEnvironment.bicep (Called within this module)

#Steps to install Synapse Infrastructure

################################ Step-1 ################################
Optional if key vault exists
 1. cd <installDirectory/src/bicep/main/KeyVault
 2. Edit mainKeyVaultRequiredParams.json  to update IP address/range
 3. az deployment sub create --name keyvault --template-file  .\mainKeyVault.bicep --parameters p_nameIdentifier='mddsha1prodeastus'

 Note - Location is for config , deployment logging only

################################ Step-2 ################################
Optional if landing zone  exists. Please update parameter values accordingly
1. cd to <install_directory>src\bicep\main\CommonEnvironment 
2. Edit mainCommonEnvironmentRequiredParams.json  to update required parameters
3. az deployment sub create --name deploycommonenv --template-file  .\mainCommonEnvironment.bicep --parameters p_nameIdentifier='mdd5aprodeastus' '@mainCommonEnvironmentRequiredParams.json'

Note - Location is for config , deployment logging only

################################ Step-3 ################################
1. cd to <install_directory>src\bicep\main\[DataPlatform Azure Resource] 
2. Edit main[DataPlatform Azure Resource]RequiredParams.json  to update required parameters
3. az deployment sub create  -- location eastus --name deploy[DataPlatform Azure Resource]  --template-file [DataPlatform Azure Resource].bicep  --parameters p_nameIdentifier='mdd5aprodeastus' '@mai[DataPlatform Azure Resource]RequiredParams.json'
 
// Note - Location is for config , deployment logging only

