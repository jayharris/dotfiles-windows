Push-Location (Split-Path -parent $profile)
"functions","aliases","extra" | Where-Object {Test-Path "$_.ps1"} | ForEach-Object -process {Invoke-Expression ". .\$_.ps1"}
Pop-Location

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
}

# Configure Visual Studio
if (Test-Path hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7 -or Test-Path hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VS7) {
    $vsRegistry = Get-Item hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7 -ErrorAction SilentlyContinue
    if ($vsRegistry -eq $null) { $vsRegistry = Get-Item hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VS7 }
    $vsVersion  = $vsRegistry.property | Sort-Object -Descending | Select-Object -first 1
    $vsinstall  = ForEach-Object -process {$vsRegistry.GetValue($vsVersion)}

    if ((Test-Path $vsinstall) -eq 0) {Write-Error "Unable to find Visual Studio installation"}

    $env:VisualStudioVersion = $vsVersion
    $env:Framework40Version  = "v4.0"
    $env:VSINSTALLDIR = $vsinstall
    $env:DevEnvDir    =  Join-Path ${vsinstall} "Common7\IDE\"
    if (!($env:Path).Split(";").Contains($vsinstall)) { Append-EnvPath $vsinstall }
    $vsCommonToolsVersion = $vsVersion.replace(".","")
    Invoke-Expression "`$env:VS${vsCommonToolsVersion}COMN = Join-Path `"$vsinstall`" `"Common7\Tools`""

    Append-EnvPathIfExists (Join-Path $vsinstall "Common7\Tools")
    Append-EnvPathIfExists (Join-Path $vsinstall "Team Tools\Performance Tools")
    Append-EnvPathIfExists (Join-Path $vsinstall "VSTSDB\Deploy")
    Append-EnvPathIfExists (Join-Path $vsinstall "CommonExtensions\Microsoft\TestWindow")
    Append-EnvPathIfExists (Join-Path $env:ProgramFiles "MSBuild\$vsVersion\bin")
    Append-EnvPathIfExists (Join-Path ${env:ProgramFiles(x86)} "MSBuild\$vsVersion\bin")
    Append-EnvPathIfExists (Join-Path $env:ProgramFiles "Microsoft SDKs\TypeScript")
    Append-EnvPathIfExists (Join-Path ${env:ProgramFiles(x86)} "Microsoft SDKs\TypeScript")
    Append-EnvPathIfExists (Join-Path $env:ProgramFiles "HTML Help Workshop")
    Append-EnvPathIfExists (Join-Path ${env:ProgramFiles(x86)} "HTML Help Workshop")


    if (Test-Path hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VC7 -or Test-Path hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7) {
        $vcRegistry = Get-Item hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VC7 -ErrorAction SilentlyContinue
        if ($vcRegistry -eq $null) { $vcRegistry = Get-Item hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7 }
        $env:VCINSTALLDIR   = $vsRegistry.GetValue($vsVersion)
        $env:FrameworkDir32 = $vsRegistry.GetValue("FrameworkDir32")
        $env:FrameworkDir64 = $vsRegistry.GetValue("FrameworkDir64")
        $env:FrameworkDir   = $env:FrameworkDir32
        $env:FrameworkVersion32 = $vsRegistry.GetValue("FrameworkVer32")
        $env:FrameworkVersion64 = $vsRegistry.GetValue("FrameworkVer64")
        $env:FrameworkVersion   = $env:FrameworkVersion32

        Append-EnvPathIfExists (Join-Path $env:FrameworkDir $env:Framework40Version)
        Append-EnvPathIfExists (Join-Path $env:FrameworkDir $env:FrameworkVersion)
        Append-EnvPathIfExists (Join-Path $env:VCINSTALLDIR "VCPackages")
        Append-EnvPathIfExists (Join-Path $env:VCINSTALLDIR "bin")

        if (Test-Path (Join-Path $env:VCINSTALLDIR "ATLMFC\INCLUDE")) { $env:INCLUDE = $env:INCLUDE + ";" + Join-Path $env:VCINSTALLDIR "ATLMFC\LIB" }
        if (Test-Path (Join-Path $env:VCINSTALLDIR "INCLUDE")) { $env:INCLUDE = $env:INCLUDE + ";" + Join-Path $env:VCINSTALLDIR "LIB" }

        if (Test-Path (Join-Path $env:VCINSTALLDIR "ATLMFC\LIB")) {
            $env:LIB = $env:LIB + ";" + Join-Path $env:VCINSTALLDIR "ATLMFC\LIB"
            $env:LIBPATH = $env:LIBPATH + ";" + Join-Path $env:VCINSTALLDIR "ATLMFC\LIB"
        }
        if (Test-Path (Join-Path $env:VCINSTALLDIR "LIB")) {
            $env:LIB = $env:LIB + ";" + Join-Path $env:VCINSTALLDIR "LIB"
            $env:LIBPATH = $env:LIBPATH + ";" + Join-Path $env:VCINSTALLDIR "LIB"
        }

        if (Test-Path (Join-Path $env:FrameworkDir $env:Framework40Version)) { $env:LIBPATH = $env:LIBPATH + ";" + Join-Path $env:FrameworkDir $env:Framework40Version }
        if (Test-Path (Join-Path $env:FrameworkDir $env:FrameworkVersion)) { $env:LIBPATH = $env:LIBPATH + ";" + Join-Path $env:FrameworkDir $env:FrameworkVersion }
    }

    if (Test-Path "hklm:\SOFTWARE\Microsoft\VisualStudio\$vsVersion\Setup\F#" -or Test-Path "hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\$vsVersion\Setup\F#") {
        $fsRegistry = Get-Item "hklm:\SOFTWARE\Microsoft\VisualStudio\$vsVersion\Setup\F#" -ErrorAction SilentlyContinue
        if ($fsRegistry -eq $null) { $fsRegistry = Get-Item "hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\$vsVersion\Setup\F#" }
        $env:FSHARPINSTALLDIR = $fsRegistry.GetValue("ProductDir")
        Append-EnvPathIfExists $env:FSHARPINSTALLDIR
    }
}