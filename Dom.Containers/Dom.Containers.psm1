function Get-AvailableAzDoAgent {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $azdo_service_account_url,
        [Parameter(Mandatory)]
        [string]
        $azdo_personal_access_token,
        [Parameter(Mandatory=$false)]
        [string]
        $pool_name="Platform"

    )

    #requires -Modules @{ModuleName="VSTeam"; ModuleVersion="7.1.2"}
    #requires -Modules @{ModuleName="Az.ContainerInstance"; ModuleVersion="3.1.0"}

    # Connect to DevOps
    Set-VSTeamAccount -Account $azdo_service_account_url -PersonalAccessToken $azdo_personal_access_token

    # Get the agents in the Platform Pool and determine whether any are free
    # Check whether the pool has at least one agent
    If ((Get-VSTeamPool -Id (Get-VSTeamPool | Where-Object {$_.Name -eq $pool_name}).Id).Count -gt 0) { 
        # Check whether any agents are free
        Get-VSTeamAgent -PoolId (Get-VSTeamPool | Where-Object {$_.Name -eq $pool_name}).Id | 
        ForEach-Object {
            $Agent = $_.AgentId
            $Pool = $_.PoolId
            $status = Get-VSTeamJobRequest -PoolId $Pool -AgentID $Agent
            If ($null -eq $status){
                Write-Host ("Agent Id {0} free, no need to start an additional instance" -f $Agent) -ForegroundColor Green
            } Else {

                # Start an agent instance
                Get-AzContainerGroup | Where-Object {$_.Tag["usage"] -eq "DevOpsAgent"} | ForEach-Object {
                    Get-AzContainerGroup -Name $_.Name -ResourceGroupName $_.resourcegroupname | Where-Object {$_.InstanceViewState -ne "Running"}
                } | Select-Object -First 1 | ForEach-Object {
                    # Start container
                    Write-Host ("Starting {0}" -f $_.Name) -ForegroundColor Green
                    Start-AzContainerGroup -Name $_.Name -ResourceGroupName $_.ResourceGroupName
                }
            }
        }
    } Else {

        # Count must be zero
        Write-Host ("No agents running, start one") -ForegroundColor Yellow
        Get-AzContainerGroup | Where-Object {$_.Tag["usage"] -eq "DevOpsAgent"} | ForEach-Object {
            Get-AzContainerGroup -Name $_.Name -ResourceGroupName $_.resourcegroupname | Where-Object {$_.InstanceViewState -ne "Running"}
        } | Select-Object -First 1 | ForEach-Object {
            # Start container
            Write-Host ("Starting {0}" -f $_.Name) -ForegroundColor Green
            Start-AzContainerGroup -Name $_.Name -ResourceGroupName $_.ResourceGroupName
        }

    }

}