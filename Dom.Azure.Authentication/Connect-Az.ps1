function Connect-Az {

    <#
    .SYNOPSIS
        Logins into your users default tenant, if you're already logged in it prompts whether it should display alternative tenants you have access to.

    .NOTES
        Version:        1.0.0.0
        Author:         Dom Clayton
        Creation Date:  07/02/2022
        Updated:        31/03/2022

        Windows PowerShell presents an interactive login prompt whereas PowerShell Core opens a browser to login.

        Requires Microsoft PowerShell Console Gui Tools - https://devblogs.microsoft.com/powershell/introducing-consoleguitools-preview/

    .EXAMPLE
        Connect-Az
        Connect-Az -Verbose
    
    #>

    #Requires -Modules @{ModuleName="Az.Accounts"; ModuleVersion="2.5.2"}
    #Requires -Modules @{ModuleName="Microsoft.PowerShell.ConsoleGuiTools"; ModuleVersion="0.6.2"}

    # Gets access to cmdlet features such as verbose
    [CmdletBinding()]
    Param
    ()

    # Detect OS
    switch ($PSVersionTable.Os){

        {$_ -match "Linux"}{

            # Work with Linux
            Write-Verbose ('Detected function is running in Linux')
            $OS = "Linux"

        }
        {$_ -match "Windows"}{

            # Work with Windows
            Write-Verbose ('Detected function is running in Windows')
            $OS = "Windows"

        }

    }
    
    # Check whether PowerShell is connected to a tenant
    If (Get-AzContext){
    # Output the tenant Name
    Write-Host ('Connected to {0}' -f $(Get-AzTenant -TenantId (Get-AzContext).Tenant.Id).Name) -ForegroundColor Green

    Write-Verbose 'Asking user whether they want to switch tenant'
    $prompt = Set-Prompt -promptString 'Would you like to access another AAD tenant? - Default ''No'''

    If ($prompt.ToUpper() -eq 'Y' -or $prompt.ToUpper() -eq 'YES'){

        Write-Verbose "Getting a list of tenant Id's you have access to"

        switch ($OS) {

            "Linux" {

                $TenantId = (Get-AzTenant) | Out-ConsoleGridView -Title "Select the AAD tenant to log into" -OutputMode Single

                # Check whether the user escaped of the selector view
                if ($null -eq $TenantId){
                    
                    Break

                }

                Write-Verbose 'Running Connect-AzAccount with -TenantId - required for MFA'
                wslview  https://microsoft.com/devicelogin
                Connect-AzAccount -TenantId $TenantId.Id -UseDeviceAuthentication | Out-Null

            }
            "Windows" {

                $TenantId = (Get-AzTenant) | Out-GridView -Title "Select the AAD tenant to log into" -PassThru

                # Check whether the user escaped of the selector view
                if ($null -eq $TenantId){

                    Break

                }

                Write-Verbose 'Running Connect-AzAccount with -TenantId - required for MFA'
                Connect-AzAccount -TenantId $TenantId.Id | Out-Null

            }

        }

    }

    } Else {

        # No tenant connection
        # Connecting using interactive auth.
        Write-Verbose 'Running Connect-AzAccount'
        switch ($OS) {

            "Linux" {

                # Start the browser in Windows - only works in WSL
                wslview  https://microsoft.com/devicelogin

                Connect-AzAccount -UseDeviceAuthentication | Out-Null
                Write-Verbose "Getting a list of tenant Id's you have access to"
                $TenantId = (Get-AzTenant) | Out-ConsoleGridView -Title "Select the AAD tenant to log into" -OutputMode Single

                # Check whether the user escaped of the selector view
                if ($null -eq $TenantId){

                    Break

                }

                Write-Verbose 'Running Connect-AzAccount with -TenantId - required for MFA'
                
                # Start the browser in Windows - only works in WSL
                wslview  https://microsoft.com/devicelogin
                Connect-AzAccount -TenantId $TenantId.Id -UseDeviceAuthentication | Out-Null

            }
            "Windows" {

                Connect-AzAccount | Out-Null
                Write-Verbose "Getting a list of tenant Id's you have access to"
                $TenantId = (Get-AzTenant) `
                | Out-GridView -Title "Select the AAD tenant to log into" -PassThru

                # Check whether the user escaped of the selector view
                if ($null -eq $TenantId){

                    Break

                }

                Write-Verbose 'Running Connect-AzAccount with -TenantId - required for MFA'
                Connect-AzAccount -TenantId $TenantId.Id | Out-Null
                
            }

        }

    }   

    # Output the tenant Name
    Write-Host ('Connected to {0}' -f $(Get-AzTenant -TenantId (Get-AzContext).Tenant.Id).Name) -ForegroundColor Green

}
