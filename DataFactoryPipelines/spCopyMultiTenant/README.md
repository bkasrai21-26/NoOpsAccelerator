# Copy Sharepoint Online Files in one AAD tenant to an Azure Data Lake in another AAD tenant

## Overview

This ADF pipeline copies Sharepoint Online files in one AAD tenant to Azure Data Lake account residing in another AAD tenant.  It uses a multi-tenant enabled service principal to retrieve files from Sharepoint Online and write to Azure Data Lake. 

## Pre-requisites

1. A Multi-tenant Service Principal is created with the following permissions.  After permissions are added, the admin must consent for them to be effective.
  - Application permissions
    - Microsoft Graph
      - Directory.Read.All
      - Files.Read.All
    - Sharepoint
      - AllSites.Read
  - Delegated Permissions
    - Azure Data Lake
      - user_impersonation

2. Register the Multi-tenant Service Principal in the second tenant by using the following link.

https://login.microsoftonline.com/{tenant-id}/adminconsent?client_id={client-id}

3. Azure Key Vault exists with a secret entry for the service principal created in step 1. 

## How To Deploy

### 1. Import the Pipeline Definition into your ADF workspace.
### 2. Create a linked service to Azure Key Vault instance.
### 3. In the "Get Request Header" and "Get Request Header for Storage Account" web activity, change the service princpal secret to use the Azure key vault configured in step 2. 
### 4. Input Pipeline Parameters

- clientId - service pricipal id
- clientSecret - service principal secret
- spTenantId - AAD tenant id
- spTenantName - AAD tenant name (ex. contoso.onmicrosoft.com, contoso is the tenant name)
- spDriveName - Sharepoint drive name (ex. Documents)
- adlsAccountName - Azure data lake account name
- fileSystem - ADLS filesystem name


https://login.microsoftonline.com/{tenant-id}/adminconsent?client_id={client-id}
