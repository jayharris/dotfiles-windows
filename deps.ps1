# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);

   exit
}

# system and cli
winget install Microsoft.WebPICmd                        --silent --accept-package-agreements --accept-source-agreements
winget install Git.Git                                   --silent --accept-package-agreements --accept-source-agreements --override "/VerySilent /NoRestart /o:PathOption=CmdTools /Components=""icons,assoc,assoc_sh,gitlfs"""
winget install OpenJS.NodeJS                             --silent --accept-package-agreements --accept-source-agreements
winget install Python.Python.3.12                        --silent --accept-package-agreements --accept-source-agreements
winget install RubyInstallerTeam.Ruby.3.2                --silent --accept-package-agreements --accept-source-agreements

# browsers
winget install Google.Chrome                             --silent --accept-package-agreements --accept-source-agreements
winget install Mozilla.Firefox                           --silent --accept-package-agreements --accept-source-agreements
#winget install Opera.Opera                               --silent --accept-package-agreements --accept-source-agreements

# dev tools and frameworks
winget install Microsoft.PowerShell                      --silent --accept-package-agreements --accept-source-agreements
#winget install Microsoft.SQLServer.2019.Developer        --silent --accept-package-agreements --accept-source-agreements
winget install Microsoft.SQLServerManagementStudio       --silent --accept-package-agreements --accept-source-agreements
#winget install Microsoft.VisualStudio.2022.Professional  --silent --accept-package-agreements --accept-source-agreements --override "--wait --quiet --norestart --nocache --addProductLang En-us --add Microsoft.VisualStudio.Workload.Azure --add Microsoft.VisualStudio.Workload.NetWeb"
#winget install JetBrains.dotUltimate                     --silent --accept-package-agreements --accept-source-agreements --override "/SpecificProductNames=ReSharper;dotTrace;dotCover /Silent=True /VsVersion=17.0"
winget install Vim.Vim                                   --silent --accept-package-agreements --accept-source-agreements
#winget install WinMerge.WinMerge                         --silent --accept-package-agreements --accept-source-agreements
winget install Microsoft.AzureCLI                        --silent --accept-package-agreements --accept-source-agreements
winget install Microsoft.Azure.StorageExplorer            --silent --accept-package-agreements --accept-source-agreements
#winget install Microsoft.Azure.StorageEmulator            --silent --accept-package-agreements --accept-source-agreements
#winget install Microsoft.ServiceFabricRuntime            --silent --accept-package-agreements --accept-source-agreements

Refresh-Environment

gem pristine --all --env-shebang
Get-ChildItem 'C:\Program Files\Vim\' -Filter "vim*" -ErrorAction SilentlyContinue | Select-Object -First 1 | ForEach-Object {Append-EnvPath $_.FullName}

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

