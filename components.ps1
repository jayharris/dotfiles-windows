Push-Location (Join-Path (Split-Path -parent $profile) "components")

# From within the ./components directory...
. .\coreaudio.ps1

Pop-Location