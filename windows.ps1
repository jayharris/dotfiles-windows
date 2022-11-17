# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);

   exit
}

###############################################################################
### Security and Identity                                                     #
###############################################################################
Write-Host "Configuring System..." -ForegroundColor "Yellow"

# Set Computer Name
(Get-WmiObject Win32_ComputerSystem).Rename("CHOZO") | Out-Null

## Set DisplayName for my account. Use only if you are not using a Microsoft Account
#$myIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
#$user = Get-WmiObject Win32_UserAccount | Where {$_.Caption -eq $myIdentity.Name}
#$user.FullName = "Jay Harris
#$user.Put() | Out-Null
#Remove-Variable user
#Remove-Variable myIdentity

# Enable Developer Mode: Enable: 1, Disable: 0
#Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" 1
# Bash on Windows
Enable-WindowsOptionalFeature -Online -All -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null

###############################################################################
### Privacy                                                                   #
###############################################################################
Write-Host "Configuring Privacy..." -ForegroundColor "Yellow"

# General: Don't let apps use advertising ID for experiences across apps: Allow: 1, Disallow: 0
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0
Remove-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Id" -ErrorAction SilentlyContinue

# General: Disable Application launch tracking: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start-TrackProgs" 0

# General: Disable SmartScreen Filter for Store Apps: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" "EnableWebContentEvaluation" 0

# General: Disable key logging & transmission to Microsoft: Enable: 1, Disable: 0
# Disabled when Telemetry is set to Basic
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Input")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Input" -Type Folder | Out-Null}
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Input\TIPC")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Input\TIPC" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Input\TIPC" "Enabled" 0

# General: Opt-out from websites from accessing language list: Opt-in: 0, Opt-out 1
Set-ItemProperty "HKCU:\Control Panel\International\User Profile" "HttpAcceptLanguageOptOut" 1

# General: Disable SmartGlass: Enable: 1, Disable: 0
#Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" "UserAuthPolicy" 0

# General: Disable SmartGlass over BlueTooth: Enable: 1, Disable: 0
#Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" "BluetoothPolicy" 0

# General: Disable suggested content in settings app: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338393Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338394Enabled" 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338396Enabled" 0

# General: Disable tips and suggestions for welcome and what's new: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-310093Enabled" 0

# General: Disable tips and suggestions when I use windows: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338389Enabled" 0

# Start Menu: Disable suggested content: Enable: 1, Disable: 0
#Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338388Enabled" 0

# Start Menu: Disable search entries: Enable: 0, Disable: 1
if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" 1

# Camera: Don't let apps use camera: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" "Value" "Deny"

# Microphone: Don't let apps use microphone: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" "Value" "Deny"

# Notifications: Don't let apps access notifications: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" "Value" "Deny"

# Speech, Inking, & Typing: Stop "Getting to know me"
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" 1
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" 1
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" "HarvestContacts" 0
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" 0
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings" -Type Folder | Out-Null}
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" "HasAccepted" 0

# Account Info: Don't let apps access name, picture, and other account info: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" "Value" "Deny"

# Contacts: Don't let apps access contacts: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" "Value" "Deny"

# Calendar: Don't let apps access calendar: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" "Value" "Deny"

# Call History: Don't let apps make phone calls: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" "Value" "Deny"

# Call History: Don't let apps access call history: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" "Value" "Deny"

# Diagnostics: Don't let apps access diagnostics of other apps: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" "Value" "Deny"

# Documents: Don't let apps access documents: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" "Value" "Deny"

# Downloads: Don't let apps access downloads: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder" "Value" "Deny"

# Email: Don't let apps read and send email: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" "Value" "Deny"

# File System: Don't let apps access the file system: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" "Value" "Deny"

# Location: Don't let apps access the location: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "Deny"

# Messaging: Don't let apps read or send messages (text or MMS): Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" "Value" "Deny"

# Music Library: Don't let apps access music library: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary" "Value" "Deny"

# Pictures: Don't let apps access pictures: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" "Value" "Deny"

# Radios: Don't let apps control radios (like Bluetooth): Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" "Value" "Deny"

# Screenshot: Don't let apps take screenshots: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic" "Value" "Deny"

# Screenshot Borders: Don't let apps access screenshot border settings: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder" "Value" "Deny"

# Tasks: Don't let apps access the tasks: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" "Value" "Deny"

# Other Devices: Don't let apps share and sync with non-explicitly-paired wireless devices over uPnP: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync" "Value" "Deny"

# Videos: Don't let apps access videos: Allow, Deny
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" "Value" "Deny"

# Feedback: Windows should never ask for my feedback
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf" -Type Folder | Out-Null}
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Type Folder | Out-Null}
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" 0

# Feedback: Telemetry: Send Diagnostic and usage data: Basic: 1, Enhanced: 2, Full: 3
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "MaxTelemetryAllowed" 1

###############################################################################
### Devices, Power, and Startup                                               #
###############################################################################
Write-Host "Configuring Devices, Power, and Startup..." -ForegroundColor "Yellow"

# Sound: Disable Startup Sound: Enable: 0, Disable: 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableStartupSound" 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" "DisableStartupSound" 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\EditionOverrides" "UserSetting_DisableStartupSound" 1

# Power: Disable Hibernation
powercfg /hibernate off

# Power: Set standby delay to 24 hours
powercfg /change /standby-timeout-ac 1440

# SSD: Disable SuperFetch: Enable: 1, Disable: 0
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnableSuperfetch" 0

# Network: Disable WiFi Sense: Enable: 1, Disable: 0
#Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 0

###############################################################################
### Explorer, Taskbar, and System Tray                                        #
###############################################################################
Write-Host "Configuring Explorer, Taskbar, and System Tray..." -ForegroundColor "Yellow"

# Prerequisite: Ensure necessary registry paths
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Type Folder | Out-Null}
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState")) {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Type Folder | Out-Null}
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Type Folder | Out-Null}

# Explorer: Show hidden files by default: Show Files: 1, Hide Files: 2
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1

# Explorer: Show file extensions by default: Hide: 1, Show: 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

# Explorer: Show path in title bar: Hide: 0, Show: 1
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" "FullPath" 1

# Explorer: Disable creating Thumbs.db files on network volumes: Enable: 0, Disable: 1
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableThumbnailsOnNetworkFolders" 1

# Taskbar: Hide the Search, Task, Widget, and Chat buttons: Show: 1, Hide: 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0  # Search
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0 # Task
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0 # Widgets
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarMn" 0 # Chat

# Taskbar: Show colors on Taskbar, Start, and SysTray: Disabled: 0, Taskbar, Start, & SysTray: 1, Taskbar Only: 2
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "ColorPrevalence" 1

# Titlebar: Disable theme colors on titlebar: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\DWM" "ColorPrevalence" 0

# Recycle Bin: Disable Delete Confirmation Dialog: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "ConfirmFileDelete" 0

###############################################################################
### Default Windows Applications                                              #
###############################################################################
Write-Host "Configuring Default Windows Applications..." -ForegroundColor "Yellow"

# Uninstall 3D Builder
Get-AppxPackage "Microsoft.3DBuilder" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.3DBuilder" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Adobe Creative Cloud Express
Get-AppxPackage "AdobeSystemsIncorporated.AdobeCreativeCloudExpress" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "AdobeSystemsIncorporated.AdobeCreativeCloudExpress" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Alarms and Clock
Get-AppxPackage "Microsoft.WindowsAlarms" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.WindowsAlarms" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Amazon Prime Video
Get-AppxPackage "AmazonVideo.PrimeVideo" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "AmazonVideo.PrimeVideo" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Autodesk Sketchbook
Get-AppxPackage "*.AutodeskSketchBook" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "*.AutodeskSketchBook" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing Finance
Get-AppxPackage "Microsoft.BingFinance" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.BingFinance" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing News
Get-AppxPackage "Microsoft.BingNews" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.BingNews" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing Sports
Get-AppxPackage "Microsoft.BingSports" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.BingSports" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bing Weather
Get-AppxPackage "Microsoft.BingWeather" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.BingWeather" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Bubble Witch 3 Saga
Get-AppxPackage "king.com.BubbleWitch3Saga" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "king.com.BubbleWitch3Saga" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Calendar and Mail
Get-AppxPackage "Microsoft.WindowsCommunicationsApps" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.WindowsCommunicationsApps" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Candy Crush Soda Saga
Get-AppxPackage "king.com.CandyCrushSodaSaga" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "king.com.CandyCrushSodaSaga" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall ClipChamp Video Editor
Get-AppxPackage "Clipchamp.Clipchamp" -AllUsers | Remove-AppxPackage
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Clipchamp.Clipchamp" | Remove-AppxProvisionedPackage -Online

# Uninstall Cortana
Get-AppxPackage "Microsoft.549981C3F5F10" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.549981C3F5F10" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Disney+
Get-AppxPackage "Disney.37853FC22B2CE" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Disney.37853FC22B2CE" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Disney Magic Kingdoms
Get-AppxPackage "*.DisneyMagicKingdoms" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "*.DisneyMagicKingdoms" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Dolby
Get-AppxPackage "DolbyLaboratories.DolbyAccess" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "DolbyLaboratories.DolbyAccess" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Facebook
Get-AppxPackage "Facebook.Facebook*" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Facebook.Facebook*" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Get Office, and it's "Get Office365" notifications
Get-AppxPackage "Microsoft.MicrosoftOfficeHub" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.MicrosoftOfficeHub" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Instagram
Get-AppxPackage "Facebook.Instagram*" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Facebook.Instagram*" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Maps
Get-AppxPackage "Microsoft.WindowsMaps" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.WindowsMaps" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall March of Empires
Get-AppxPackage "*.MarchofEmpires" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "*.MarchofEmpires" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Messaging
Get-AppxPackage "Microsoft.Messaging" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.Messaging" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Mobile Plans
Get-AppxPackage "Microsoft.OneConnect" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.OneConnect" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall OneNote
Get-AppxPackage "Microsoft.Office.OneNote" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.Office.OneNote" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Paint
Get-AppxPackage "Microsoft.Paint" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.Paint" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall People
Get-AppxPackage "Microsoft.People" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.People" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Photos
Get-AppxPackage "Microsoft.Windows.Photos" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.Windows.Photos" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Print3D
Get-AppxPackage "Microsoft.Print3D" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.Print3D" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Skype
Get-AppxPackage "Microsoft.SkypeApp" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.SkypeApp" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall SlingTV
Get-AppxPackage "*.SlingTV" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "*.SlingTV" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Solitaire
Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Spotify
Get-AppxPackage "SpotifyAB.SpotifyMusic" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "SpotifyAB.SpotifyMusic" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall StickyNotes
Get-AppxPackage "Microsoft.MicrosoftStickyNotes" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.MicrosoftStickyNotes" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Sway
Get-AppxPackage "Microsoft.Office.Sway" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.Office.Sway" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall TikTok
Get-AppxPackage "*.TikTok" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "*.TikTok" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Microsoft ToDos
Get-AppxPackage "Microsoft.ToDos" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.ToDos" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Twitter
Get-AppxPackage "*.Twitter" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "*.Twitter" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Voice Recorder
Get-AppxPackage "Microsoft.WindowsSoundRecorder" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.WindowsSoundRecorder" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall XBox
Get-AppxPackage "Microsoft.XboxGamingOverlay" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppxPackage "Microsoft.GamingApp" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.XboxGamingOverlay" | Remove-AppxProvisionedPackage -Online -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.GamingApp" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Your Phone
Get-AppxPackage "Microsoft.YourPhone" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.YourPhone" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Zune Music (Groove)
Get-AppxPackage "Microsoft.ZuneMusic" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.ZuneMusic" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Zune Video
Get-AppxPackage "Microsoft.ZuneVideo" -AllUsers | Remove-AppxPackage -AllUsers
Get-AppXProvisionedPackage -Online | Where DisplayName -like "Microsoft.ZuneVideo" | Remove-AppxProvisionedPackage -Online -AllUsers

# Uninstall Windows Media Player
Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null

# Prevent "Suggested Applications" from returning
#Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1 -Force
#Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableCloudOptimizedContent" 1 -Force
#Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableConsumerAccountStateContent" 1 -Force


###############################################################################
### Lock Screen                                                               #
###############################################################################

## Enable Custom Background on the Login / Lock Screen
## Background file: C:\someDirectory\someImage.jpg
## File Size Limit: 256Kb
# Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Personalization" "LockScreenImage" "C:\someDirectory\someImage.jpg"

###############################################################################
### Accessibility and Ease of Use                                             #
###############################################################################
Write-Host "Configuring Accessibility..." -ForegroundColor "Yellow"

# Turn Off Windows Narrator Hotkey: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Narrator\NoRoam" "WinEnterLaunchEnabled" 0

# Disable "Window Snap" Automatic Window Arrangement: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\Control Panel\Desktop" "WindowArrangementActive" 0

# Disable automatic fill to space on Window Snap: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapFill" 0

# Disable showing what can be snapped next to a window: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapAssist" 0

# Disable automatic resize of adjacent windows on snap: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "JointResize" 0

# Disable auto-correct: Enable: 1, Disable: 0
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\TabletTip\1.7" "EnableAutocorrection" 0

###############################################################################
### Windows Update & Application Updates                                      #
###############################################################################
Write-Host "Configuring Windows Update..." -ForegroundColor "Yellow"

# Disable automatic reboot after install: Enable: 1, Disable: 0
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" "IsExpedited" 0

# Disable restart required notifications: Enable: 1, Disable: 0
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" "RestartNotificationsAllowed2" 0

# Disable updates over metered connections: Enable: 1, Disable: 0
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" "AllowAutoWindowsUpdateDownloadOverMeteredNetwork" 0

# Opt-In to Microsoft Update
$MU = New-Object -ComObject Microsoft.Update.ServiceManager -Strict
$MU.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"") | Out-Null
Remove-Variable MU

###############################################################################
### Windows Defender                                                          #
###############################################################################
Write-Host "Configuring Windows Defender..." -ForegroundColor "Yellow"

# Disable Cloud-Based Protection: Enabled Advanced: 2, Enabled Basic: 1, Disabled: 0
Set-MpPreference -MAPSReporting 0

# Disable automatic sample submission: Prompt: 0, Auto Send Safe: 1, Never: 2, Auto Send All: 3
Set-MpPreference -SubmitSamplesConsent 2

###############################################################################
### Internet Explorer                                                         #
###############################################################################
#Write-Host "Configuring Internet Explorer..." -ForegroundColor "Yellow"

# Set home page to `about:blank` for faster loading
#Set-ItemProperty "HKCU:\Software\Microsoft\Internet Explorer\Main" "Start Page" "about:blank"

# Disable 'Default Browser' check: "yes" or "no"
#Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main" "Check_Associations" "no"

# Disable Password Caching [Disable Remember Password]
#Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" "DisablePasswordCaching" 1


###############################################################################
### Disk Cleanup (CleanMgr.exe)                                               #
###############################################################################
Write-Host "Configuring Disk Cleanup..." -ForegroundColor "Yellow"

$diskCleanupRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\"

# Cleanup Files by Group: 0=Disabled, 2=Enabled
Set-ItemProperty $(Join-Path $diskCleanupRegPath "BranchCache"                                  ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Downloaded Program Files"                     ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Internet Cache Files"                         ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Offline Pages Files"                          ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Old ChkDsk Files"                             ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Previous Installations"                       ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Recycle Bin"                                  ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "RetailDemo Offline Content"                   ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Service Pack Cleanup"                         ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Setup Log Files"                              ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "System error memory dump files"               ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "System error minidump files"                  ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Temporary Files"                              ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Temporary Setup Files"                        ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Thumbnail Cache"                              ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Update Cleanup"                               ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Upgrade Discarded Files"                      ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "User file versions"                           ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Defender"                             ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Error Reporting Archive Files"        ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Error Reporting Queue Files"          ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Error Reporting System Archive Files" ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Error Reporting System Queue Files"   ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Error Reporting Temp Files"           ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows ESD installation files"               ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Upgrade Log Files"                    ) "StateFlags6174" 0   -ErrorAction SilentlyContinue

Remove-Variable diskCleanupRegPath

###############################################################################
### PowerShell Console                                                        #
###############################################################################
Write-Host "Configuring Console..." -ForegroundColor "Yellow"

# Make 'Source Code Pro' an available Console font
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont' 000 'Source Code Pro'

@(`
"HKCU:\Console\%SystemRoot%_System32_bash.exe",`
"HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe",`
"HKCU:\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe",`
"HKCU:\Console\Windows PowerShell (x86)",`
"HKCU:\Console\Windows PowerShell",`
"HKCU:\Console"`
) | ForEach {
    If (!(Test-Path $_)) {
        New-Item -path $_ -ItemType Folder | Out-Null
    }

# Dimensions of window, in characters: 8-byte; 4b height, 4b width. Max: 0x7FFF7FFF (32767h x 32767w)
Set-ItemProperty $_ "WindowSize"           0x002D0078 # 45h x 120w
# Dimensions of screen buffer in memory, in characters: 8-byte; 4b height, 4b width. Max: 0x7FFF7FFF (32767h x 32767w)
Set-ItemProperty $_ "ScreenBufferSize"     0x0BB80078 # 3000h x 120w
# Percentage of Character Space for Cursor: 25: Small, 50: Medium, 100: Large
Set-ItemProperty $_ "CursorSize"           100
# Name of display font
Set-ItemProperty $_ "FaceName"             "Source Code Pro"
# Font Family: Raster: 0, TrueType: 54
Set-ItemProperty $_ "FontFamily"           54
# Dimensions of font character in pixels, not Points: 8-byte; 4b height, 4b width. 0: Auto
Set-ItemProperty $_ "FontSize"             0x00110000 # 17px height x auto width
# Boldness of font: Raster=(Normal: 0, Bold: 1), TrueType=(100-900, Normal: 400)
Set-ItemProperty $_ "FontWeight"           400
# Number of commands in history buffer
Set-ItemProperty $_ "HistoryBufferSize"    50
# Discard duplicate commands
Set-ItemProperty $_ "HistoryNoDup"         1
# Typing Mode: Overtype: 0, Insert: 1
Set-ItemProperty $_ "InsertMode"           1
# Enable Copy/Paste using Mouse
Set-ItemProperty $_ "QuickEdit"            1
# Background and Foreground Colors for Window: 2-byte; 1b background, 1b foreground; Color: 0-F
Set-ItemProperty $_ "ScreenColors"         0x0F
# Background and Foreground Colors for Popup Window: 2-byte; 1b background, 1b foreground; Color: 0-F
Set-ItemProperty $_ "PopupColors"          0xF0
# Adjust opacity between 30% and 100%: 0x4C to 0xFF -or- 76 to 255
Set-ItemProperty $_ "WindowAlpha"          0xF2

# The 16 colors in the Console color well (Persisted values are in BGR).
# Theme: Jellybeans
Set-ItemProperty $_ "ColorTable00"         $(Convert-ConsoleColor "#151515") # Black (0)
Set-ItemProperty $_ "ColorTable01"         $(Convert-ConsoleColor "#8197bf") # DarkBlue (1)
Set-ItemProperty $_ "ColorTable02"         $(Convert-ConsoleColor "#437019") # DarkGreen (2)
Set-ItemProperty $_ "ColorTable03"         $(Convert-ConsoleColor "#556779") # DarkCyan (3)
Set-ItemProperty $_ "ColorTable04"         $(Convert-ConsoleColor "#902020") # DarkRed (4)
Set-ItemProperty $_ "ColorTable05"         $(Convert-ConsoleColor "#540063") # DarkMagenta (5)
Set-ItemProperty $_ "ColorTable06"         $(Convert-ConsoleColor "#dad085") # DarkYellow (6)
Set-ItemProperty $_ "ColorTable07"         $(Convert-ConsoleColor "#888888") # Gray (7)
Set-ItemProperty $_ "ColorTable08"         $(Convert-ConsoleColor "#606060") # DarkGray (8)
Set-ItemProperty $_ "ColorTable09"         $(Convert-ConsoleColor "#7697d6") # Blue (9)
Set-ItemProperty $_ "ColorTable10"         $(Convert-ConsoleColor "#99ad6a") # Green (A)
Set-ItemProperty $_ "ColorTable11"         $(Convert-ConsoleColor "#c6b6ee") # Cyan (B)
Set-ItemProperty $_ "ColorTable12"         $(Convert-ConsoleColor "#cf6a4c") # Red (C)
Set-ItemProperty $_ "ColorTable13"         $(Convert-ConsoleColor "#f0a0c0") # Magenta (D)
Set-ItemProperty $_ "ColorTable14"         $(Convert-ConsoleColor "#fad07a") # Yellow (E)
Set-ItemProperty $_ "ColorTable15"         $(Convert-ConsoleColor "#e8e8d3") # White (F)
}

# Customizing PoSh syntax
# Theme: Jellybeans
Set-PSReadlineOption -Colors @{
    "Default"   = "#e8e8d3"
    "Comment"   = "#888888"
    "Keyword"   = "#8197bf"
    "String"    = "#99ad6a"
    "Operator"  = "#c6b6ee"
    "Variable"  = "#c6b6ee"
    "Command"   = "#8197bf"
    "Parameter" = "#e8e8d3"
    "Type"      = "#fad07a"
    "Number"    = "#cf6a4c"
    "Member"    = "#fad07a"
    "Emphasis"  = "#f0a0c0"
    "Error"     = "#902020"
}

# Remove property overrides from PowerShell and Bash shortcuts
Reset-AllPowerShellShortcuts
Reset-AllBashShortcuts

echo "Done. Note that some of these changes require a logout/restart to take effect."
