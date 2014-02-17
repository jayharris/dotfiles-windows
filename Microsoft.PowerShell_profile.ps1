Push-Location (Split-Path -parent $profile)
"functions","aliases" | Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}

# Configure Git
if (Test-Path (Join-Path $env:LOCALAPPDATA "GitHub")) {
    Push-Location (Join-Path $env:LOCALAPPDATA "GitHub")
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
} else { Write-Verbose "GitHub for Windows has not been installed" }

if (Test-Path "extra.ps1") { & .\extra.ps1 }
Pop-Location