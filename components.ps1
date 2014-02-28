Push-Location (Join-Path (Split-Path -parent $profile) "components")

# From within the ./components directory...
. .\coreaudio.ps1
. .\githubforwindows.ps1
. .\visualstudio.ps1

Pop-Location