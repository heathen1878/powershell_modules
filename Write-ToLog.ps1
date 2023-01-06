function Write-ToLog {

    [CmdletBinding()]
	Param
	(
        [parameter(Mandatory)]
	    [string]$logFile,  
	    [parameter(Mandatory)]
        [string]$logContent
	)
	
	If (Test-Path $logFile) {
	
		# Append to the file
		Add-Content -Path $logFile -Value $logContent
		
	}
	Else {
	
		# Create the file
		New-Item -ItemType File -Path $logFile
		Add-Content -Path $logFile -Value $logContent
		
	}
    
}