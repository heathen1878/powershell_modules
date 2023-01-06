function Connect-Az {

    <#
    .SYNOPSIS
        Logins into an Azure tenant if required and returns a PS Azure Tenant

    .NOTES
        Version:        1.0.0.0
        Author:         Dom Clayton
        Creation Date:  07/02/2022

    .EXAMPLE
        Connect-Az
        Connect-Az -verbose
    
    #>

    #Requires -Modules @{ModuleName="Az.Accounts"; ModuleVersion="2.5.2"}

    # Gets access to cmdlet features
    [CmdletBinding()]
    Param
    ()

    # Check whether PowerShell is connected to a tenant
    If (Get-AzContext){
        # Output the tenant Name
        Write-Output ('Connected to {0}' -f $(Get-AzTenant -TenantId (Get-AzContext).Tenant.Id).Name)

        Write-Verbose 'Asking user whether they want to switch tenant'
        $prompt = Set-Prompt -promptString 'Would you like to access another AAD tenant? - Default ''N'''

        If ($prompt.ToUpper() -eq 'Y' -or $prompt.ToUpper() -eq 'YES'){

            Write-Verbose "Getting a list of tenant Id's you have access to"
            $TenantId = (Get-AzTenant) `
            | Out-GridView -Title "Select the AAD tenant to log into" -PassThru

            Write-Verbose 'Running Connect-AzAccount with -TenantId - required for MFA'
            Connect-AzAccount -TenantId $TenantId.Id | Out-Null
            # Output the tenant Name
            Write-Output ('Connected to {0}' -f $(Get-AzTenant -TenantId (Get-AzContext).Tenant.Id).Name)

        } Else {

            $TenantId = (Get-AzTenant)

        }

    }

    Return $TenantId

}