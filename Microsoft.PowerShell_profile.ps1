"functions","aliases","extras" | Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {. "./$_.ps1"}

# Configure Git
if (Test-Path (Resolve-Path "$env:LOCALAPPDATA\GitHub\")) {
    Push-Location (Resolve-Path "$env:LOCALAPPDATA\GitHub\")
    . ".\shell.ps1"
    Push-Location $env:github_posh_git
    Import-Module .\posh-git
    Pop-Location

    function global:prompt {
        $realLASTEXITCODE = $LASTEXITCODE

        # Reset color, which can be messed up by Enable-GitColors
        $Host.UI.RawUI.ForegroundColor = $GitPromptSettings.DefaultForegroundColor

        Write-Host($pwd.ProviderPath) -nonewline

        Write-VcsStatus

        $global:LASTEXITCODE = $realLASTEXITCODE
        return "> "
    }

    Enable-GitColors
    Start-SshAgent -Quiet
    Pop-Location
} else { Write-Output "GitHub for Windows has not been installed" }

# Configure Visual Studio, using the most recent version installed
if (Test-Path hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7) {
    $vsRegistry = Get-Item hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7
    $vsinstall = $vsRegistry.property | Sort-Object -Descending | Select-Object -first 1 | ForEach-Object -process {$vsRegistry.GetValue($_)}

    if ((Test-Path $vsinstall) -eq 0) {
        Write-Error "Unable to find Visual Studio installation"
    }

    if (($env:Path).Split(";").Contains($vsinstall)) {
        $env:Path += (";"+$vsinstall)
    }

    function Start-VisualStudio ([string] $solutionFile) {
        $devenv = Resolve-Path "$vsInstall\Common7\IDE\devenv.exe"
        if ($solutionFile) {
            if (Test-Path ($solutionFile)) {
                start-process $devenv -ArgumentList $solutionFile
            }
        } else {
            start-process $devenv
        }
    }
    Set-Alias -name vs -Value Start-VisualStudio

    function Start-VisualStudioAsAdmin ([string] $solutionFile) {
        $devenv = Resolve-Path "$vsInstall\Common7\IDE\devenv.exe"
        if ($solutionFile) {
            if (Test-Path ($solutionFile)) {
                start-process $devenv -ArgumentList $solutionFile -verb "runAs"
            }
        } else {
            start-process $devenv -verb "runAs"
        }
    }
    Set-Alias -name vsadmin -Value Start-VisualStudioAsAdmin
} else { Write-Output "Visual Studio has not been installed" }



