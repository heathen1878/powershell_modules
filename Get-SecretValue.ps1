function Get-SecretValue {

    <#
    .SYNOPSIS
        Converts a secure string to a readable value.

    .NOTES
        Version:        1.0.0.0
        Author:         Dom Clayton
        Creation Date:  02/02/2022

    .EXAMPLE
        Get-SecretValue -secret 'Secret Name'

    #>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory)]
        [securestring]
        $secret
    )

    $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)

    Try {

        $secretValue = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)

    }
    Finally {

        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)

    }

    Return $secretValue

}