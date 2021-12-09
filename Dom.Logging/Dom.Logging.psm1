Function Write-ToLog {

    [CmdletBinding()]
	Param
	(
        [parameter(Mandatory)]
	    [string]$LogFile,  
	    [parameter(Mandatory)]
        [string]$LogContent
	)
	
	If (Test-Path $sLogFile) {
	
		# Append to the file
		Add-Content -Path $sLogFile -Value $sLogContent
		
	}
	Else {
	
		# Create the file
		New-Item -ItemType File -Path $sLogFile
		Add-Content -Path $sLogFile -Value $sLogContent
		
	}
}