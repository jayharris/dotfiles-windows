# Easier Navigation: .., ..., ...., ....., and ~
${function:~} = { Set-Location ~ }
# PoSh won't allow ${function:..} because of an invalid path error, so...
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }
${function:......} = { Set-Location ..\..\..\..\.. }

# Navigation Shortcuts
${function:drop} = { Set-Location ~\Documents\Dropbox }
${function:dt} = { Set-Location ~\Desktop }
${function:docs} = { Set-Location ~\Documents }
${function:dl} = { Set-Location ~\Downloads }

# List all files, including dot files
${function:la} = { ls -Force @args }

# List only directories
${function:lsd} = { ls -Directory @args }

# Create a new directory and enter it
Set-Alias mkd CreateAndSet-Directory

# Determine size of a file or total size of a directory
Set-Alias fs Get-DiskUsage

# Gzip-enabled `curl`
${function:gurl} = { curl --compressed @args }

# Empty the Recycle Bin on all drives
Set-Alias emptytrash Empty-RecycleBin

# Reload the shell
Set-Alias reload Reload-Powershell

# http://xkcd.com/530/
Set-Alias mute Set-SoundMute
Set-Alias unmute Set-SoundUnmute