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
function Set-Environment {
  param(
    [Parameter(Mandatory = $true)]
    [string]
    $Variable,

    [Parameter(Mandatory = $true)]
    [string]
    $Value,

    [Parameter(Mandatory = $true)]
    $Target
  )

  [Environment]::SetEnvironmentVariable($Variable, $Value, $Target)
  Refresh-Environment
}