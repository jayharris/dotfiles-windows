# These components will be loaded when running Microsoft.Powershell (i.e. Not Visual Studio)

Push-Location (Join-Path (Split-Path -parent $profile) "components")

# From within the ./components directory...
. .\visualstudio.ps1
. .\console.ps1

Pop-Location
