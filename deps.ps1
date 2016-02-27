# Update Help for Modules
Update-Help -Force

### Package Providers
Get-PackageProvider NuGet -Force
# Chocolatey Provider is not ready yet. Use normal Chocolatey
#Get-PackageProvider Chocolatey -Force
#Set-PackageSource -Name chocolatey -Trusted

### Chocolatey
if ((which cinst) -eq $null) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
    Refresh-Environment
    choco feature enable -n=allowGlobalConfirmation
}

#cinst curl #`curl` comes with GH4W
cinst GitHubForWindows
cinst GoogleChrome
cinst GoogleChrome.Canary
cinst hg
cinst Fiddler4
cinst Firefox
cinst nodejs.install
cinst nuget.commandline
cinst Opera
cinst ruby
cinst vim
cinst webpi
cinst wget
cinst wput
#cinst wincommandpaste # Copy/Paste is supported natively in Win10
cinst winmerge


### Completing PoshGit installation if installing GH4W
if (((choco list -lr | where {$_ -like "githubforwindows*"}) -ne $null) -and ((which git) -eq $null)) {
    Write-Host ""
    Write-Host "You have installed GitHubForWindows but `git` was not found."
    Write-Host "In case GitHubForWindows is newly installed, execution has been"
    Write-Host "paused while you complete the installation."
    Write-Host ""
    Read-Host -Prompt "When installation has completed, press Enter to continue" | Out-Null
    Push-Location (Join-Path $env:LocalAppData "GitHub")
        Write-Host ""
        Write-Host "Relaunching GitHubForWindows to begin tooling installation."
        Write-Host "Once launched, close GitHubForWindows to proceed."
        Start-Process .\GitHub.appref-ms -Wait
        Write-Host ""
        Write-Host "Launching GitHubForWindows Shell to complete tooling installation."
        Start-Process .\GitHub.appref-ms -ArgumentList "--open-shell"
        Read-Host -Prompt "After launching, close the GH4W shell and press Enter to proceed" | Out-Null
        Refresh-Environment
        . (Join-Path (Split-Path -parent $PROFILE) "profile.ps1")
    Pop-Location
} else {
    Refresh-Environment
}


### Web Platform Installer
if (which webpicmd) {
    webpicmd /Install /AcceptEula /Products:"StaticContent,DefaultDocument,DirectoryBrowse,RequestFiltering,HTTPErrors,HTTPLogging,ISAPIExtensions,ISAPIFilters,UrlRewrite2"
    webpicmd /Install /AcceptEula /Products:"BasicAuthentication,WindowsAuthentication"
    webpicmd /Install /AcceptEula /Products:"StaticContentCompression,DynamicContentCompression"
    webpicmd /Install /AcceptEula /Products:"IISManagementConsole"
    webpicmd /Install /AcceptEula /Products:"WebSockets"
    webpicmd /Install /AcceptEula /Products:"NetFx3,NetFx4,NETFramework452,NetFx4Extended-ASPNET45,NETExtensibility,NetFxExtensibility45,ASPNET,ASPNET45"
    webpicmd /Install /AcceptEula /Products:"Python279"
}


### Node Packages
if (which npm) {
    npm install -g azure-cli
    npm install -g bower
    npm install -g coffee-script
    npm install -g conventional-changelog
    npm install -g grunt
    npm install -g gulp
    npm install -g less
    npm install -g lineman
    npm install -g mocha
    npm install -g node-inspector
    npm install -g sass
    npm install -g yo
}


### Janus for vim
if ((which vim) -and (which rake)) {
    curl.exe -L https://bit.ly/janus-bootstrap | bash
}


### Visual Studio Plugins
if (which Install-VSExtension) {
    ### Visual Studio 2015
    # VsVim
    Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/59ca71b3-a4a3-46ca-8fe1-0e90e3f79329/file/6390/57/VsVim.vsix
    # Productivity Power Tools 2015
    Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/34ebc6a2-2777-421d-8914-e29c1dfa7f5d/file/169971/1/ProPowerTools.vsix

    ### Visual Studio 2013
    # VsVim
    # Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/59ca71b3-a4a3-46ca-8fe1-0e90e3f79329/file/6390/57/VsVim.vsix
    # Productivity Power Tools 2013
    # Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/dbcb8670-889e-4a54-a226-a48a15e4cace/file/117115/4/ProPowerTools.vsix
    # Web Essentials 2013
    # Install-VSExtension https://visualstudiogallery.msdn.microsoft.com/56633663-6799-41d7-9df7-0f2a504ca361/file/105627/47/WebEssentials2013.vsix
}
