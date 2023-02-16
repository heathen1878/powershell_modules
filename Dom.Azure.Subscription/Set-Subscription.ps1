function Set-Subscription {

    <#
    .SYNOPSIS
        Logins into an Azure tenant if required and then connects to the subscription of your choice.

    .NOTES
        Version:        1.0.0.0
        Author:         Dom Clayton
        Creation Date:  30/09/2021
        Updated:        01/04/2022

    .EXAMPLE
        Set-Subscription
        Set-Subscription -verbose
        Set-Subscription -subscriptionId '00000000-0000-0000-0000-00000000'
    
    #>

    #Requires -Modules @{ModuleName="Az.Accounts"; ModuleVersion="2.5.2"}
    #Requires -Modules @{ModuleName="Microsoft.PowerShell.ConsoleGuiTools"; ModuleVersion="0.6.2"}
       
    # Gets access to cmdlet features
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string]
        $subscriptionId=$null
    )

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
    
    } Else {

        Connect-Az

    }

    # Check whether a subscription Id has been passed in using a parameter, if not prompt the user interactively.
    If ([string]::IsNullOrEmpty($subscriptionId)){

        Write-Host ('Your subscription is {0}' -f (Get-AzContext).Subscription.Name) -ForegroundColor Green

        Write-Verbose 'Prompt user whether they need to access a different subscription'
        $prompt = Set-Prompt -promptString 'Would you like to access to a different subscription? - Default ''No'''

        If ($prompt.ToUpper() -eq 'Y' -or $prompt.ToUpper() -eq 'YES'){

            Write-Verbose ('Getting a list of subscriptions')

            Switch ($OS){

                "Linux" {

                    $subscription = Get-AzSubscription -TenantId (Get-AzContext).Tenant.Id | Select-Object Name, SubscriptionId `
                    | Out-ConsoleGridView -Title "Select the subscription you want to deploy to" -OutputMode Single
                    
                }
                "Windows" {

                    $Subscription = Get-AzSubscription -TenantId (Get-AzContext).Tenant.Id | Select-Object Name, SubscriptionId `
                    | Out-GridView -Title "Select the subscription you want to deploy to" -PassThru

                }

            }

            # Check whether the user escaped of the selector view
            if ($null -eq $subscription){
            
                Write-Host ('Exiting...subscription still {0}' -f (Get-AzContext).Subscription.Name) -ForegroundColor Magenta
                Break

            } 

            $Sub = Set-AzContext -Tenant (Get-AzContext).Tenant.Id -SubscriptionId $Subscription.SubscriptionId
            Write-Host ('Setting context to: {0}' -f (Get-AzSubscription -SubscriptionId $Sub.Subscription).Name) -ForegroundColor Green
    
        } Else {

            # User has selected No
            Write-Host ('Still connected to {0}' -f (Get-AzContext).Subscription.Name) -ForegroundColor Green

        }

    } Else {
        
        # A subscription Id has been passed directly, so just set the context to that subscription
        Set-AzContext -Tenant (Get-AzContext).Tenant.Id -SubscriptionId $subscriptionId | Out-Null
        Write-Host ('Your subscription is {0}' -f (Get-AzContext).Subscription.Name) -ForegroundColor Green

    }

}