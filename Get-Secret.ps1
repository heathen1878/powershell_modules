function Get-Secret {
    
    <#
    .SYNOPSIS
        Checks the tenant and subscription, then attempts to retrieve a secret from a Key Vault in said tenant and subscription and output it to screen.

    .NOTES
        Version:        1.0.0.0
        Author:         Dom Clayton
        Creation Date:  02/02/2022
        

    .EXAMPLE
        Get-Secret -keyVault 'Key Vault Name' -secret 'Secret Name'
        Get-Secret -verbose

    #>

    #Requires -Modules @{ModuleName="Az.KeyVault"; ModuleVersion="4.2.0"}

    # Gets access to cmdlet features
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [string]
        $keyVault,
        [Parameter(Mandatory)]
        [string]
        $secret
    )

    # Dot source required functions - this would ideally use a private PowerShell Gallery e.g. DevOps Artifacts.
    . .\Functions\Set-Subscription.ps1
    . .\Functions\Set-Prompt.ps1
    . .\Functions\Get-SecretValue.ps1

    $kv = $null

    If (-not (Get-AzContext)){

        Write-Verbose 'Running Connect-AzAccount'
        Connect-AzAccount | Out-Null

    }

    # Iterate through all subscriptions
    Get-AzSubscription | ForEach-Object {

         # Set context to the next subscription
        Set-AzContext -Subscription $_.Id | Out-Null

        # Attempt to get the Key Vault resource information from the current subscription. If it doesn't exist, move onto the next subscription. 
        If (Get-AzResource -Name $keyVault) {

            Write-Verbose ('Key Vault {0} found in {1}' -f $keyVault, $_.Id)
            $kv = Get-AzResource -Name $keyVault


        } Else {

            Write-Verbose ('Key Vault {0} not found in {1}' -f $keyVault, $_.Id)

        }           

    }

    If (-not([string]::IsNullOrEmpty($kv))){

        Write-Verbose ('Key Vault {0} in subscription {1}' -f $keyVault, $kv.ResourceId.Split('/')[2])

        # Set the subscription context
        Set-Subscription -subscriptionId $kv.ResourceId.Split('/')[2]

        # Get the Key Vault Secret
        $secretData = Get-AzKeyVaultSecret -VaultName $keyVault -SecretName $secret
        $secretValue = Get-SecretValue -secret $secretData.secretValue

        Write-Output ('The content type is: {0} ' -f $secretData.ContentType)
        Write-Output ('The secret value is {0}' -f $secretValue)

    } Else {

        Write-Verbose ('Key Vault {0} not found in any subscriptions' -f $keyVault)

    }

    Write-Verbose 'Running Disconnect-AzAccount'
    Disconnect-AzAccount | Out-Null

}