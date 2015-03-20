## v1.3-beta

- Separated Components into All, Shell, and Visual Studio specific instances.

## v1.2
Released 28-February-2014

- Extracted GitHubForWindows and VisualStudio configurations to separate components
- Fixed issue with VSIX Installer when the installer was not in `$env:PATH`
- Fixed issue where `bootstrap.ps1` was not copying Component files.

## v1.1
Released 18-February-2014

#### Added core functionality:

- Visual Studio environment variables, providing functionality very similar to `Visual Studio Command Prompt`. This functionality is only enabled if Visual Studio is installed, and will use the most recent version of VS.
- Component / Submodule support, beginning with Audio

#### New functions and aliases, including:

- `emptytrash` and `Empty-RecycleBin` to clear all Recycle Bins for the user.
- `fs` and `Get-DiskUsage` to show the disk use for a file or directory.
- `lsd` to display only the directories under the current folder.
- `mkd` to create a new directory and then cd into it.
- `mute`, `unmute`, and `Set-SoundVolume` for system audio.
- `reload` and `Reload-PowerShell` to reload PowerShell in a new window, loading all new settings and scripts.


## v1.0
Released 17-February-2014

Initial release
