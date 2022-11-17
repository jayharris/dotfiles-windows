# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);

   exit
}


### Update Help for Modules
Write-Host "Updating Help..." -ForegroundColor "Yellow"
Update-Help -Force


### Package Providers
Write-Host "Installing Package Providers..." -ForegroundColor "Yellow"
Get-PackageProvider NuGet -Force | Out-Null


### Install PowerShell Modules
Write-Host "Installing PowerShell Modules..." -ForegroundColor "Yellow"
Install-Module Posh-Git -Scope CurrentUser -Force
Install-Module PSWindowsUpdate -Scope CurrentUser -Force


# system and cli
winget install Microsoft.WebPICmd                        --silent --accept-package-agreements
winget install Git.Git                                   --silent --accept-package-agreements --override "/VerySilent /NoRestart /o:PathOption=CmdTools /Components=""icons,assoc,assoc_sh,gitlfs"""
winget install OpenJS.NodeJS                             --silent --accept-package-agreements
winget install Python.Python.3                           --silent --accept-package-agreements
winget install RubyInstallerTeam.Ruby                    --silent --accept-package-agreements

# browsers
winget install Google.Chrome                             --silent --accept-package-agreements
winget install Mozilla.Firefox                           --silent --accept-package-agreements
winget install Opera.Opera                               --silent --accept-package-agreements

# dev tools and frameworks
winget install Microsoft.PowerShell                      --silent --accept-package-agreements
winget install Microsoft.SQLServer.2019.Developer        --silent --accept-package-agreements
winget install Microsoft.SQLServerManagementStudio       --silent --accept-package-agreements
winget install Microsoft.VisualStudio.2022.Professional  --silent --accept-package-agreements --override "--wait --quiet --norestart --nocache --addProductLang En-us --add Microsoft.VisualStudio.Workload.Azure --add Microsoft.VisualStudio.Workload.NetWeb"
winget install JetBrains.dotUltimate                     --silent --accept-package-agreements --override "/SpecificProductNames=ReSharper;dotTrace;dotCover /Silent=True /VsVersion=17.0"
winget install Vim.Vim                                   --silent --accept-package-agreements
winget install WinMerge.WinMerge                         --silent --accept-package-agreements
winget install Microsoft.AzureCLI                        --silent --accept-package-agreements
winget install Microsoft.AzureStorageExplorer            --silent --accept-package-agreements
winget install Microsoft.AzureStorageEmulator            --silent --accept-package-agreements
#winget install Microsoft.ServiceFabricRuntime            --silent --accept-package-agreements
#winget install Microsoft.ServiceFabricExplorer           --silent --accept-package-agreements

Refresh-Environment

gem pristine --all --env-shebang

### Node Packages
Write-Host "Installing Node Packages..." -ForegroundColor "Yellow"
if (which npm) {
    npm update npm
    npm install -g yo
}

### Janus for vim
Write-Host "Installing Janus..." -ForegroundColor "Yellow"
if ((which curl) -and (which vim) -and (which rake) -and (which bash)) {
    curl.exe -L https://bit.ly/janus-bootstrap | bash

    cd ~/.vim/
    git submodule update --remote
}

