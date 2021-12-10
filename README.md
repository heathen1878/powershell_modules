# PowerShellModules
PowerShell modules containing useful functions...

You can add these functions to a private gallery using [Azure DevOps Artifacts](https://docs.microsoft.com/en-us/azure/devops/artifacts/tutorials/private-powershell-library?view=azure-devops#connecting-to-the-feed-as-a-powershell-repo)

```PowerShell

# Package the module
nuget pack {module name}.nuspec

# Add the package source - needs your Azure DevOps username and Personal Access Token
nuget sources add -Name 'PowerShellModule' -source "https://pkgs.dev.azure.com/{}DevOpsOrg/{DevOpsProject}/_packaging/{ArtifactsFeed}/nuget/v3/index.json" -username {user name} -password {PAT}

# Publish the package to the artifacts feed
nuget push -Source "PowerShellModules" -apikey AzureDevOpsServices "{module name}.nupkg"

```

Module principles
https://docs.microsoft.com/en-us/powershell/scripting/developer/module/how-to-write-a-powershell-module-manifest?view=powershell-7.1

https://en.wikipedia.org/wiki/Don%27t_repeat_yourself

https://en.wikipedia.org/wiki/Single-responsibility_principle
