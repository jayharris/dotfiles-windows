# Easier Navigation: .., ..., ...., ....., and ~
${function:~} = { Set-Location ~ }
${function:..} = { Set-Location .. }
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }

# Navigation Shortcuts
${function:dt} = { Set-Location ~\Desktop }
${function:docs} = { Set-Location ~\Documents }
${function:dl} = { Set-Location ~\Downloads }

# dir aliases
${function:la} = { Get-ChildItem -Force }
