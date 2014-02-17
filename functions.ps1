# Basic commands
function which($name) { Get-Command $name -ErrorAction SilentlyContinue | Select-Object Definition }
function touch($file) { "" | Out-File $file -Encoding ASCII }

# Common Editing needs
function Edit-Hosts { Start-Process -FilePath notepad -ArgumentList "$env:windir\system32\drivers\etc\hosts" -verb "runAs" }
function Edit-Profile { Start-Process -FilePath notepad -ArgumentList $profile }

# Sudo
function sudo() {
    if ($args.Length -eq 1) {
        start-process $args[0] -verb "runAs"
    }
    if ($args.Length -gt 1) {
        start-process $args[0] -ArgumentList $args[1..$args.Length] -verb "runAs"
    }
}

# Reload the $env object from the registry
function Refresh-Environment {
    $locations = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
                 'HKCU:\Environment'

    $locations | ForEach-Object {
        $k = Get-Item $_
        $k.GetValueNames() | ForEach-Object {
            $name  = $_
            $value = $k.GetValue($_)
            Set-Item -Path Env:\$name -Value $value
        }
    }
}

# Set a permanent Environment variable, and reload it into $env
function Set-Environment([String]$variable, [String]$value) {
  [System.Environment]::SetEnvironmentVariable("$variable", "$value")
}

function Unzip-File {
    <#
    .SYNOPSIS
       Extracts the contents of a zip file.

    .DESCRIPTION
       Extracts the contents of a zip file specified via the -File parameter to the
    location specified via the -Destination parameter.

    .PARAMETER File
        The zip file to extract. This can be an absolute or relative path.

    .PARAMETER Destination
        The destination folder to extract the contents of the zip file to.

    .PARAMETER ForceCOM
        Switch parameter to force the use of COM for the extraction even if the .NET Framework 4.5 is present.

    .EXAMPLE
       Unzip-File -File C:\zipfiles\AdventureWorks2012_Database.zip -Destination C:\databases\

    .EXAMPLE
       Unzip-File -File C:\zipfiles\AdventureWorks2012_Database.zip -Destination C:\databases\ -ForceCOM

    .EXAMPLE
       'C:\zipfiles\AdventureWorks2012_Database.zip' | Unzip-File

    .EXAMPLE
        Get-ChildItem -Path C:\zipfiles | ForEach-Object {$_.fullname | Unzip-File -Destination C:\databases}

    .INPUTS
       String

    .OUTPUTS
       None

    .NOTES
       Inspired by:  Mike F Robbins, @mikefrobbins

       This function first checks to see if the .NET Framework 4.5 is installed and uses it for the unzipping process, otherwise COM is used.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$File,

        [ValidateNotNullOrEmpty()]
        [string]$Destination = (Get-Location).Path
    )

    $filePath = Resolve-Path $File
    $destinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination)

    If (($PSVersionTable.PSVersion.Major -ge 3) -and
       ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full" -ErrorAction SilentlyContinue).Version -like "4.5*" -or
       (Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" -ErrorAction SilentlyContinue).Version -like "4.5*")) {

        try {
            [System.Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem") | Out-Null
            [System.IO.Compression.ZipFile]::ExtractToDirectory("$filePath", "$destinationPath")
        } catch {
            Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
        }
    } else {
        try {
            $shell = New-Object -ComObject Shell.Application
            $shell.Namespace($destinationPath).copyhere(($shell.NameSpace($filePath)).items())
        } catch {
            Write-Warning -Message "Unexpected Error. Error details: $_.Exception.Message"
        }
    }
}

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
} else { Write-Verbose "Visual Studio has not been installed" }