# PowerShellModules
PowerShell modules containing useful functions...

You can add these functions to a private gallery using [Azure DevOps Artifacts](https://docs.microsoft.com/en-us/azure/devops/artifacts/tutorials/private-powershell-library?view=azure-devops#connecting-to-the-feed-as-a-powershell-repo)


## Publish the module to AzDo Artifacts
```PowerShell
# Package the module
nuget pack {module name}.nuspec

# Add the package source - needs your Azure DevOps username and Personal Access Token
$source = "https://pkgs.dev.azure.com/{DevOpsOrg}/{DevOpsProject}/_packaging/{ArtifactsFeed}/nuget/v3/index.json"
$email = "user@domain"
$pat = ""
nuget sources add -Name 'PowerShellModule' -source $source -username $email -password $pat

# Publish the package to the artifacts feed
nuget push -Source "PowerShellModules" -apikey AzureDevOpsServices "{module name}.nupkg"

```

## Consume modules from AzDo Artifacts
```PowerShell
$securePat = $pat | ConvertTo-SecureString -AsPlainText -Force

$azureDevOpsCred = New-Object System.Management.Automation.PSCredential($email, $securePat)

$source = $source.Replace('v3/index.json','v2')

Register-PSRepository -Name "MyPSRepo" -sourceLocation $source -PublishLocation $source -InstallationPolicy Trusted -Credential $azureDevOpsCred

Register-PackageSource -Name "MyPSRepo" -Location $source -ProviderName NuGet

```

## Reference

Module principles
https://docs.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-module-manifest?view=powershell-7.1

https://en.wikipedia.org/wiki/Don%27t_repeat_yourself

https://en.wikipedia.org/wiki/Single-responsibility_principle
