# These components will be loaded within a Visual Studio shell (e.g. Package Manager Console)

Push-Location (Join-Path (Split-Path -parent $profile) "components")

# From within the ./components directory...

Pop-Location
