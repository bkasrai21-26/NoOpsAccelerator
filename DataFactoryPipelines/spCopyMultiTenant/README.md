# Copy Sharepoint Online Files to Azue Data Lake

## Overview

This ADF pipeline can copy Sharepoint Online files in one AAD tenant to Azure Data Lake residing in the same AAD tenant (same-tenant) or a different AAD tenant (multi-tenant).  For the multi-tenant scenario, it uses a multi-tenant enabled service principal to retrieve files from Sharepoint Online and write to Azure Data Lake. 

## Pre-requisites

1. A Multi-tenant Service Principal is created in the AAD tenant where Azure Data Lake account resides with the following permissions.  After permissions are added, the admin must provide consent for them to be effective.
  - Application permissions
    - Microsoft Graph
      - Sites.Read.All
      - Files.Read.All

2. Register the Multi-tenant Service Principal in the second tenant where Sharepoint Online resides by using the following link.  After permissions are added, the Admin must provide consent for them to be effective.  The Admin can find the client id under the "Enterprise applications" blade of the AAD to perform this action.

https://login.microsoftonline.com/{tenant-id}/adminconsent?client_id={client-id}

3. Azure Key Vault exists with a secret entry for the service principal created in step 1. 

## How To Deploy

### 1. Import the Pipeline Definition into your ADF workspace.
### 2. Create a linked service to Azure Key Vault instance.

Ensure that the ADF system assigned identity has "Key Vault Reader" permission for the client secret.  Web Activity uses this permission to retrieve the client secret.  
### 3. In the "Get Request Header" and "Get Request Header for Storage Account" web activity, change the service princpal secret to use the Azure key vault configured in step 2. 
### 4. Input Pipeline Parameters

- clientId - service pricipal id
- spTenantId - AAD tenant id of the Sharepoint Online tenant
- spTenantName - AAD tenant name (ex. contoso.onmicrosoft.com, contoso is the tenant name)
- spDriveName - Sharepoint drive name (ex. Documents)
- adlsAccountName - Azure data lake account name
- fileSystem - ADLS filesystem name
- adlsTenantId - AAD tenant id of the Azure Data Lake (For multi-tenant scenario, this value should be different from spTenantId.  For single-tenant scenario, it should be the same)
