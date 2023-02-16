function Set-Prompt {

    <#
   .SYNOPSIS
       Sets the prompt presented to a user which requires a Yes/Y or No/N response.

   .NOTES
       Version:        1.0.0.0
       Author:         Dom Clayton
       Creation Date:  02/02/2022
      

   .EXAMPLE
       Set-Prompt
   
   #>

   [CmdletBinding()]
   Param(
       [Parameter(Mandatory)]
       [string]
       $promptString
   )

   Do {
       Try {
           $responseOk = $true
           [string]$prompt = Read-Host $promptString
           If ([string]::IsNullOrEmpty($prompt)){
               $prompt = 'No'
           }
       }
       Catch {
           $responseOk = $false
       }
   } Until (($prompt.ToUpper() -eq 'Y' -or $prompt.ToUpper() -eq 'YES' -or $prompt.ToUpper() -eq 'N' -or $prompt.ToUpper() -eq 'NO') -and $responseOk)

   Return $prompt

}