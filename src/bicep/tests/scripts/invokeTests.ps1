try {
    if (Get-Module Pester) {
        Import-Module -Name Pester -ErrorAction Stop
    }
    else {
        Install-Module Pester -Force
    }


    Invoke-Pester -EnableExit -OutputFile ./test-results.xml -OutputFormat NUnitXml
}
catch {
    Write-Error $_
    exit 1
}