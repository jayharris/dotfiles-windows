# Configure Visual Studio
if ((Test-Path "hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7") -or (Test-Path "hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VS7")) {
    # Add a folder to $env:Path
    function Append-EnvPath([String]$path) { $env:PATH = $env:PATH + ";$path" }
    function Append-EnvPathIfExists([String]$path) { if (Test-Path $path) { Append-EnvPath $path } }

    $vsRegistry = Get-Item "hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VS7" -ErrorAction SilentlyContinue
    if ($vsRegistry -eq $null) { $vsRegistry = Get-Item "hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VS7" }
    $vsVersion  = $vsRegistry.property | Sort-Object {[int]$_} -Descending | Select-Object -first 1
    $vsinstall  = ForEach-Object -process {$vsRegistry.GetValue($vsVersion)}
    Remove-Variable vsRegistry

    if ((Test-Path $vsinstall) -eq 0) {Write-Error "Unable to find Visual Studio installation"}

    $env:VisualStudioVersion = $vsVersion
    $env:Framework40Version  = "v4.0"
    $env:VSINSTALLDIR = $vsinstall
    $env:DevEnvDir    =  Join-Path $vsinstall "Common7\IDE\"
    if (!($env:Path).Split(";").Contains($vsinstall)) { Append-EnvPath $vsinstall }
    $vsCommonToolsVersion = $vsVersion.replace(".","")
    Invoke-Expression "`$env:VS${vsCommonToolsVersion}COMN = Join-Path `"$vsinstall`" `"Common7\Tools`""
    Invoke-Expression "`$env:VS${vsCommonToolsVersion}COMNTOOLS = Join-Path `"$vsinstall`" `"Common7\Tools`""
    Remove-Variable vsCommonToolsVersion
    Remove-Variable vsinstall

    $env:GYP_MSVS_VERSION = @{
                              "9.0"="2008";
                              "10.0"="2010";
                              "11.0"="2012";
                              "12.0"="2013";
                              "14.0"="2015";
                              "15.0"="2017";
                             }.Get_Item($vsVersion)

    Append-EnvPathIfExists (Join-Path $env:VSINSTALLDIR "Common7\Tools")
    Append-EnvPathIfExists (Join-Path $env:VSINSTALLDIR "Team Tools\Performance Tools")
    Append-EnvPathIfExists (Join-Path $env:VSINSTALLDIR "VSTSDB\Deploy")
    Append-EnvPathIfExists (Join-Path $env:VSINSTALLDIR "CommonExtensions\Microsoft\TestWindow")
    Append-EnvPathIfExists (Join-Path $env:ProgramFiles "MSBuild\$vsVersion\bin")
    Append-EnvPathIfExists (Join-Path ${env:ProgramFiles(x86)} "MSBuild\$vsVersion\bin")
    Append-EnvPathIfExists (Join-Path $env:ProgramFiles "Microsoft SDKs\TypeScript")
    Append-EnvPathIfExists (Join-Path ${env:ProgramFiles(x86)} "Microsoft SDKs\TypeScript")
    Append-EnvPathIfExists (Join-Path $env:ProgramFiles "HTML Help Workshop")
    Append-EnvPathIfExists (Join-Path ${env:ProgramFiles(x86)} "HTML Help Workshop")

    Remove-Variable vsVersion

    if ((Test-Path "hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VC7") -or (Test-Path "hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7")) {
        $vcRegistry = Get-Item "hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7" -ErrorAction SilentlyContinue
        if ($vcRegistry -eq $null) { $vcRegistry = Get-Item "hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VC7" }
        $env:VCINSTALLDIR   = $vcRegistry.GetValue($env:VisualStudioVersion)
        $env:FrameworkDir32 = $vcRegistry.GetValue("FrameworkDir32")
        $env:FrameworkDir64 = $vcRegistry.GetValue("FrameworkDir64")
        $env:FrameworkDir   = $env:FrameworkDir32
        $env:FrameworkVersion32 = $vcRegistry.GetValue("FrameworkVer32")
        $env:FrameworkVersion64 = $vcRegistry.GetValue("FrameworkVer64")
        $env:FrameworkVersion   = $env:FrameworkVersion32
        Remove-Variable vcRegistry

        Append-EnvPathIfExists (Join-Path $env:FrameworkDir $env:Framework40Version)
        Append-EnvPathIfExists (Join-Path $env:FrameworkDir $env:FrameworkVersion)
        Append-EnvPathIfExists (Join-Path $env:VCINSTALLDIR "VCPackages")
        Append-EnvPathIfExists (Join-Path $env:VCINSTALLDIR "bin")

        if (Test-Path (Join-Path $env:VCINSTALLDIR "ATLMFC\INCLUDE")) { $env:INCLUDE = $env:INCLUDE + ";" + $(Join-Path $env:VCINSTALLDIR "ATLMFC\LIB") }
        if (Test-Path (Join-Path $env:VCINSTALLDIR "INCLUDE")) { $env:INCLUDE = $env:INCLUDE + ";" + $(Join-Path $env:VCINSTALLDIR "LIB") }

        if (Test-Path (Join-Path $env:VCINSTALLDIR "ATLMFC\LIB")) {
            $env:LIB = $env:LIB + ";" + $(Join-Path $env:VCINSTALLDIR "ATLMFC\LIB")
            $env:LIBPATH = $env:LIBPATH + ";" + $(Join-Path $env:VCINSTALLDIR "ATLMFC\LIB")
        }
        if (Test-Path (Join-Path $env:VCINSTALLDIR "LIB")) {
            $env:LIB = $env:LIB + ";" + $(Join-Path $env:VCINSTALLDIR "LIB")
            $env:LIBPATH = $env:LIBPATH + ";" + $(Join-Path $env:VCINSTALLDIR "LIB")
        }

        if (Test-Path (Join-Path $env:FrameworkDir $env:Framework40Version)) { $env:LIBPATH = $env:LIBPATH + ";" + $(Join-Path $env:FrameworkDir $env:Framework40Version) }
        if (Test-Path (Join-Path $env:FrameworkDir $env:FrameworkVersion)) { $env:LIBPATH = $env:LIBPATH + ";" + $(Join-Path $env:FrameworkDir $env:FrameworkVersion) }
    }

    if ((Test-Path "hklm:\SOFTWARE\Microsoft\VisualStudio\SxS\VC7") -or (Test-Path "hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7")) {
        $msBuildToolsRegistryPath = "hklm:\SOFTWARE\Wow6432Node\Microsoft\MSBuild\ToolsVersions"
        if (${Test-Path $msBuildToolsRegistertPath} -eq $false) { $msBuildToolsRegistryPath = "hklm:\SOFTWARE\Microsoft\MSBuild\ToolsVersions" }

        $msBuildVersion = Get-ChildItem $msBuildToolsRegistryPath | Sort-Object {[float] (Split-Path -Leaf $_.Name)} -Descending | Select-Object @{N='Name';e={Split-Path -Leaf $_.Name}} -First 1 | Select -ExpandProperty "Name"
        $msBuildRegistry = Get-Item (Join-Path $msBuildToolsRegistryPath $msBuildVersion)
        $msBuildToolsRoot = $msBuildRegistry.GetValue("MSBuildToolsRoot")

        $msBuildRegistry.property | where {$_ -like "VCTargetsPath*"} | ForEach-Object {
            $vcTargetsPathValue = $msBuildRegistry.GetValue($_)
            $vcTargetsPath = $vcTargetsPathValue.Substring($vcTargetsPathValue.IndexOf("`$(MSBuildExtensionsPath32)")+26).TrimEnd("')")
            Invoke-Expression "`$env:${_} = Join-Path `"$msBuildToolsRoot`" `"$vcTargetsPath`""
            Remove-Variable vcTargetsPath
            Remove-Variable vcTargetsPathValue
        }

        Remove-Variable msBuildVersion
        Remove-Variable msBuildToolsRoot
        Remove-Variable msBuildRegistry
        Remove-Variable msBuildToolsRegistryPath
    }

    if ((Test-Path "hklm:\SOFTWARE\Microsoft\VisualStudio\$vsVersion\Setup\F#") -or (Test-Path "hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\$vsVersion\Setup\F#")) {
        $fsRegistry = Get-Item "hklm:\SOFTWARE\Wow6432Node\Microsoft\VisualStudio\$vsVersion\Setup\F#" -ErrorAction SilentlyContinue
        if ($fsRegistry -eq $null) { $fsRegistry = Get-Item "hklm:\SOFTWARE\Microsoft\VisualStudio\$vsVersion\Setup\F#" }
        $env:FSHARPINSTALLDIR = $fsRegistry.GetValue("ProductDir")
        Append-EnvPathIfExists $env:FSHARPINSTALLDIR
        Remove-Variable fsRegistry
    }


    # Configure Visual Studio functions
    function Start-VisualStudio ([string] $solutionFile) {
        $devenv = Join-Path $env:DevEnvDir "devenv.exe"
        if (($solutionFile -eq $null) -or ($solutionFile -eq "")) {
            $solutionFile = (Get-ChildItem -Filter "*.sln" | Select-Object -First 1).Name
        }
        if (($solutionFile -ne $null) -and ($solutionFile -ne "") -and (Test-Path $solutionFile)) {
            Start-Process $devenv -ArgumentList $solutionFile
        } else {
            Start-Process $devenv
        }
    }
    Set-Alias -name vs -Value Start-VisualStudio

    function Start-VisualStudioAsAdmin ([string] $solutionFile) {
        $devenv = Join-Path $env:DevEnvDir "devenv.exe"
        if (($solutionFile -eq $null) -or ($solutionFile -eq "")) {
            $solutionFile = (Get-ChildItem -Filter "*.sln" | Select-Object -First 1).Name
        }
        if (($solutionFile -ne $null) -and ($solutionFile -ne "") -and (Test-Path $solutionFile)) {
            Start-Process $devenv -ArgumentList $solutionFile -Verb "runAs"
        } else {
            Start-Process $devenv -Verb "runAs"
        }
    }
    Set-Alias -name vsadmin -Value Start-VisualStudioAsAdmin

    function Install-VSExtension($url) {
        $vsixInstaller = Join-Path $env:DevEnvDir "VSIXInstaller.exe"
        Write-Output "Downloading ${url}"
        $extensionFile = (curlex $url)
        Write-Output "Installing $($extensionFile.Name)"
        $result = Start-Process -FilePath `"$vsixInstaller`" -ArgumentList "/q $($extensionFile.FullName)" -Wait -PassThru;
    }
}
