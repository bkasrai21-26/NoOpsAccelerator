try {
    if (Get-Module Pester) {
        Import-Module -Name Pester -ErrorAction Stop
    }
    else {
        Install-Module Pester -Force
    }
    
    Get-Module Az.Resources

    $scriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
    $testPath = Split-Path -Parent -Path $scriptPath

    $context = Get-AzContext
    $location = "usgovarizona"
    if ($context.Environment.Name -eq "AzureCloud") {
        $location = "eastus"
    }

    ##$whatIfIssues = @()

    ##$resourceIds = @() ## capture the resource Ids - we can provision and validate for testing purposes with next step
    $files = Get-ChildItem -Path $testPath -Filter "*.test.bicep" -Recurse
    $testCases = @()

    $files | ForEach-Object { $testCases += @{ 
                                                name = "$($_.BaseName.replace('.','-'))" 
                                                filePath = $_.FullName
                                                location = $location
                                            }
                            }

    
    Describe "Testing WhatIf Deployment" {
        It "Succeeded status returned by <name>" -TestCases $testCases {
            Param($name, $filePath,$location)

            ##$results = Get-AzDeploymentWhatIfResult -Name "$($name)" -TemplateFile "$($filePath)" -Location $location -TemplateParameterObject @{ p_location = $location } -ResultFormat ResourceIdOnly -Verbose
            $results = Get-AzSubscriptionDeploymentWhatIfResult -Name "$($name)" -TemplateFile "$($filePath)" -Location "$($location)" -TemplateParameterObject @{ p_location = $location } -ResultFormat ResourceIdOnly -Verbose
            ##New-AzSubscriptionDeployment -Name "$($name)" -TemplateFile "$($filePath)" -Location $location -TemplateParameterObject @{ p_location = $location } -WhatIf -WhatIfResultFormat ResourceIdOnly -DeploymentDebugLogLevel All -Confirm:$false -

              
            $results.Status | Should -Be "Succeeded"
        }
    }
    
       
}
catch { 
    Write-Error $_
    exit 1
}
