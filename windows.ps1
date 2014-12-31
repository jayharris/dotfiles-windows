$machineName    = "CHOZO"

# Get the ID and security principal of the current user account
$myIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myPrincipal=new-object System.Security.Principal.WindowsPrincipal($myIdentity)

# Check to see if we are currently running "as Administrator"
if (!$myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);

   exit
}

## Set DisplayName for my account
## Useful for setting up Account information if you are not using a Microsoft Account
#$userFullName   = "Jay Harris"
#$user = Get-WmiObject Win32_UserAccount | Where {$_.Caption -eq $myIdentity.Name}
#$user.FullName = $userFullName
#$user.Put() | Out-Null
#Remove-Variable userFullName
#Remove-Variable user

# Set Computer Name
(Get-WmiObject Win32_ComputerSystem).Rename($machineName) | Out-Null

Remove-Variable machineName
Remove-Variable myPrincipal
Remove-Variable myIdentity


# Configure IIS
Write-Output "Configuring IIS. This may take a while..."
& dism.exe /Online /Enable-Feature /All `
    /FeatureName:NetFx3 `
    /FeatureName:IIS-WebServerRole `
    /FeatureName:IIS-WebServer `
    /FeatureName:IIS-CommonHttpFeatures `
    /FeatureName:IIS-HttpErrors `
    /FeatureName:IIS-ApplicationDevelopment `
    /FeatureName:IIS-NetFxExtensibility `
    /FeatureName:IIS-NetFxExtensibility45 `
    /FeatureName:IIS-HealthAndDiagnostics `
    /FeatureName:IIS-HttpLogging `
    /FeatureName:IIS-Security `
    /FeatureName:IIS-RequestFiltering `
    /FeatureName:IIS-Performance `
    /FeatureName:IIS-HttpCompressionDynamic `
    /FeatureName:IIS-WebServerManagementTools `
    /FeatureName:IIS-WindowsAuthentication `
    /FeatureName:IIS-StaticContent `
    /FeatureName:IIS-DefaultDocument `
    /FeatureName:IIS-DirectoryBrowsing `
    /FeatureName:IIS-WebSockets `
    /FeatureName:IIS-ASPNET `
    /FeatureName:IIS-ASPNET45 `
    /FeatureName:IIS-ISAPIExtensions `
    /FeatureName:IIS-ISAPIFilter `
    /FeatureName:IIS-BasicAuthentication `
    /FeatureName:IIS-HttpCompressionStatic `
    /FeatureName:IIS-ManagementConsole `
    /FeatureName:WCF-Services45 `
    /FeatureName:WCF-TCP-PortSharing45 `
    /FeatureName:NetFx4-AdvSrvs `
    /FeatureName:NetFx4Extended-ASPNET45 | Out-Null

# HKUsers drive for Registry
if ((Get-PSDrive HKUsers -ErrorAction SilentlyContinue) -eq $null) { New-PSDrive -Name HKUSERS -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null }

# Sound: Disable Startup Sound
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableStartupSound" 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" "DisableStartupSound" 1

# Power: Disable Hibernation
powercfg /hibernate off

# Power Set standby delay to 24 hours
powercfg /change /standby-timeout-ac 1440


### Explorer, Taskbar, and System Tray
### --------------------------
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {New-Item -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Type Folder | Out-Null}

# Explorer: Show hidden files by default (1: Show Files, 2: Hide Files)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1

# Explorer: show file extensions by default (0: Show Extensions, 1: Hide Extensions)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

# Explorer: show path in title bar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" "FullPath" 1

# Explorer: Avoid creating Thumbs.db files on network volumes
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableThumbnailsOnNetworkFolders" 1

# Taskbar: use small icons (0: Large Icons, 1: Small Icons)
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSmallIcons" 1

# Taskbar: Don't show Windows Store Apps on Taskbar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "StoreAppsOnTaskbar" 0

# SysTray: hide the Action Center, Network, and Volume icons
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAHealth" 1
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCANetwork" 1
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAVolume" 1
#Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAPower" 1

# Recycle Bin: Disable Delete Confirmation Dialog
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "ConfirmFileDelete" 0


### Charm Bar
### --------------------------

# Disable Bing Search
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ConnectedSearch" "ConnectedSearchUseWeb" 0


### SSD Specific Tweaks
### --------------------------

# Disable SuperFetch
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnableSuperfetch" 0


### Login Screen
### --------------------------

## Enable Custom Background on the Login / Lock Screen
## Background file: C:\Windows\System32\Oobe\info\backgrounds\backgroundDefault.jpg
## Alternate Sizes: ./background{width}x{Height}.jpg (./background1024x768.jpg)
## File Size Limit: 256Kb
# Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background" "OEMBackground" 1

## Win7: Change Shadows on Account Selection Screen (0 Light [Green], 1 Dark [Black], 2 None)
# Set-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" "ButtonSet" 1

## More Info: http://myitforum.com/myitforumwp/2012/12/19/corporate-identity-oem-branding-in-windows-8/


### Accessibility
### --------------------------

# Turn Off Windows Narrator
if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe")) {New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe" -Type Folder | Out-Null}
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe" "Debugger" "%1"


### Windows Update
### --------------------------

$AUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
# Windows Update: Auto-Download but not Install. 0=NotConfigured, 1=Disabled, 2=NotifyBeforeDownload, 3=NotifyBeforeInstall, 4=ScheduledInstall
$AUSettings.NotificationLevel = 3
# Windows Update: Include Recommended Updates
$AUSettings.IncludeRecommendedUpdates = $true
$AUSettings.Save | Out-Null
Remove-Variable AUSettings

if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate")) {New-Item -Path HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Type Folder | Out-Null}
# Windows Update: Don't automatically reboot after install
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" "NoAutoRebootWithLoggedOnUsers" 1d

# Windows Update: Opt-In to Microsoft Update
$MU = New-Object -ComObject Microsoft.Update.ServiceManager -Strict 
$MU.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"")
Remove-Variable MU


### Internet Explorer
### --------------------------

# Set home page to `about:blank` for faster loading
Set-ItemProperty "HKCU:\Software\Microsoft\Internet Explorer\Main" "Start Page" "about:blank"


echo "Done. Note that some of these changes require a logout/restart to take effect."
