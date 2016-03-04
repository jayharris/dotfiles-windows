$myMachineName    = "CHOZO"

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

# HKUsers drive for Registry
if ((Get-PSDrive HKUsers -ErrorAction SilentlyContinue) -eq $null) { New-PSDrive -Name HKUSERS -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null }

###############################################################################
### Security and Identity                                                     #
###############################################################################

## Set DisplayName for my account
## Use only if you are not using a Microsoft Account
#$user = Get-WmiObject Win32_UserAccount | Where {$_.Caption -eq $myIdentity.Name}
#$user.FullName = "Jay Harris
#$user.Put() | Out-Null
#Remove-Variable user

# Set Computer Name
(Get-WmiObject Win32_ComputerSystem).Rename($myMachineName) | Out-Null

Remove-Variable myMachineName
Remove-Variable myPrincipal
Remove-Variable myIdentity

###############################################################################
### Devices, Power, and Startup                                               #
###############################################################################

# Sound: Disable Startup Sound
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableStartupSound" 1
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" "DisableStartupSound" 1

# Power: Disable Hibernation
powercfg /hibernate off

# Power: Set standby delay to 24 hours
powercfg /change /standby-timeout-ac 1440

# SSD: Disable SuperFetch
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnableSuperfetch" 0

# Network: Disable WiFi Sense
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" "AutoConnectAllowedOEM" 0

###############################################################################
### Explorer, Taskbar, and System Tray                                        #
###############################################################################

# Ensure necessary registry paths
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Type Folder | Out-Null}
if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState")) {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Type Folder | Out-Null}
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Type Folder | Out-Null}

# Explorer: Show hidden files by default: Show Files: 1, Hide Files: 2
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1

# Explorer: Show file extensions by default
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

# Explorer: Show path in title bar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" "FullPath" 1

# Explorer: Avoid creating Thumbs.db files on network volumes
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableThumbnailsOnNetworkFolders" 1

# Taskbar: Enable small icons
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarSmallIcons" 1

# Taskbar: Don't show Windows Store Apps on Taskbar
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "StoreAppsOnTaskbar" 0

# Taskbar: Disable Bing Search
# Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\ConnectedSearch" "ConnectedSearchUseWeb" 0 # For Windows 8.1
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0 # For Windows 10

# Taskbar: Disable Cortana
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0

# SysTray: Hide the Action Center, Network, and Volume icons
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAHealth" 1  # Action Center
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCANetwork" 1 # Network
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAVolume" 1  # Volume
#Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAPower" 1  # Power

# Taskbar: Show colors on Taskbar, Start, and SysTray: Disabled: 0, Taskbar, Start, & SysTray: 1, Taskbar Only: 2
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "ColorPrevalence" 1

# Titlebar: Disable theme colors on titlebar
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\DWM" "ColorPrevalence" 0

# Recycle Bin: Disable Delete Confirmation Dialog
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "ConfirmFileDelete" 0

###############################################################################
### Default Windows Applications                                              #
###############################################################################

# Uninstall 3D Builder
Get-AppxPackage "Microsoft.3DBuilder" | Remove-AppxPackage

# Uninstall Alarms and Clock
Get-AppxPackage "Microsoft.WindowsAlarms" | Remove-AppxPackage

# Uninstall Bing Finance
Get-AppxPackage "Microsoft.BingFinance" | Remove-AppxPackage

# Uninstall Bing News
Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage

# Uninstall Bing Sports
Get-AppxPackage "Microsoft.BingSports" | Remove-AppxPackage

# Uninstall Bing Weather
Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage

# Uninstall Calendar and Mail
Get-AppxPackage "Microsoft.WindowsCommunicationsApps" | Remove-AppxPackage

# Uninstall Candy Crush Soda Saga
Get-AppxPackage "king.com.CandyCrushSodaSaga" | Remove-AppxPackage

# Uninstall Get Office, and it's "Get Office365" notifications
Get-AppxPackage "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage

# Uninstall Get Started
Get-AppxPackage "Microsoft.GetStarted" | Remove-AppxPackage

# Uninstall Maps
Get-AppxPackage "Microsoft.WindowsMaps" | Remove-AppxPackage

# Uninstall Messaging
Get-AppxPackage "Microsoft.Messaging" | Remove-AppxPackage

# Uninstall OneNote
Get-AppxPackage "Microsoft.Office.OneNote" | Remove-AppxPackage

# Uninstall People
Get-AppxPackage "Microsoft.People" | Remove-AppxPackage

# Uninstall Photos
Get-AppxPackage "Microsoft.Windows.Photos" | Remove-AppxPackage

# Uninstall Skype
Get-AppxPackage "Microsoft.SkypeApp" | Remove-AppxPackage

# Uninstall Solitaire
Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage

# Uninstall Sway
Get-AppxPackage "Microsoft.Office.Sway" | Remove-AppxPackage

# Uninstall Twitter
Get-AppxPackage "*.Twitter" | Remove-AppxPackage

# Uninstall Voice Recorder
Get-AppxPackage "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage

# Uninstall Windows Phone Companion
Get-AppxPackage "Microsoft.WindowsPhone" | Remove-AppxPackage

# Uninstall XBox
Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage

# Uninstall Zune Music (Groove)
Get-AppxPackage "Microsoft.ZuneMusic" | Remove-AppxPackage

# Uninstall Zune Video
Get-AppxPackage "Microsoft.ZuneVideo" | Remove-AppxPackage

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

# Turn Off Windows Narrator
if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe")) {New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe" -Type Folder | Out-Null}
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe" "Debugger" "%1"

# Disable "Window Snap" Automatic Window Arrangement
Set-ItemProperty "HKCU:\Control Panel\Desktop" "WindowArrangementActive" 0

# Disable automatic fill to space on Window Snap
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapFill" 0

# Disable showing what can be snapped next to a window
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapAssist" 0

# Disable automatic resize of adjacent windows on snap
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "JointResize" 0

# Disable auto-correct
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\TabletTip\1.7" "EnableAutocorrection" 0

###############################################################################
### Windows Update                                                            #
###############################################################################

# Ensure Windows Update registry paths
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Type Folder | Out-Null}
if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Type Folder | Out-Null}

# Enable Automatic Updates
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoUpdate" 0

# Disable automatic reboot after install
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" "NoAutoRebootWithLoggedOnUsers" 1
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "NoAutoRebootWithLoggedOnUsers" 1

# Configure to Auto-Download but not Install: NotConfigured: 0, Disabled: 1, NotifyBeforeDownload: 2, NotifyBeforeInstall: 3, ScheduledInstall: 4
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "AUOptions" 3

# Include Recommended Updates
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" "IncludeRecommendedUpdates" 1

# Opt-In to Microsoft Update
$MU = New-Object -ComObject Microsoft.Update.ServiceManager -Strict
$MU.AddService2("7971f918-a847-4430-9279-4a52d1efe18d",7,"") | Out-Null
Remove-Variable MU

###############################################################################
### Internet Explorer                                                         #
###############################################################################

# Set home page to `about:blank` for faster loading
Set-ItemProperty "HKCU:\Software\Microsoft\Internet Explorer\Main" "Start Page" "about:blank"

# Disable 'Default Browser' check: "yes" or "no"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main" "Check_Associations" "no"

# Disable Password Caching [Disable Remember Password]
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" "DisablePasswordCaching" 1


###############################################################################
### Disk Cleanup (CleanMgr.exe)                                               #
###############################################################################

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

# Make 'Source Code Pro' an available Console font
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont' 000 'Source Code Pro'

# Create custom path for PSReadLine Settings
if (!(Test-Path "HKCU:\Console\PSReadLine")) {New-Item -Path "HKCU:\Console\PSReadLine" -Type Folder | Out-Null}

# PSReadLine: Normal syntax color. vim Normal group. (Default: Foreground)
Set-ItemProperty "HKCU:\Console\PSReadLine" "NormalForeground" 0xF

# PSReadLine: Comment Token syntax color. vim Comment group. (Default: 0x2)
Set-ItemProperty "HKCU:\Console\PSReadLine" "CommentForeground" 0x7

# PSReadLine: Keyword Token syntax color. vim Statement group. (Default: 0xA)
Set-ItemProperty "HKCU:\Console\PSReadLine" "KeywordForeground" 0x1

# PSReadLine: String Token syntax color. vim String [or Constant] group. (Default: 0x3)
Set-ItemProperty "HKCU:\Console\PSReadLine" "StringForeground"  0xA

# PSReadLine: Operator Token syntax color. vim Operator [or Statement] group. (Default: 0x8)
Set-ItemProperty "HKCU:\Console\PSReadLine" "OperatorForeground" 0xB

# PSReadLine: Variable Token syntax color. vim Identifier group. (Default: 0xA)
Set-ItemProperty "HKCU:\Console\PSReadLine" "VariableForeground" 0xB

# PSReadLine: Command Token syntax color. vim Function [or Identifier] group. (Default: 0xE)
Set-ItemProperty "HKCU:\Console\PSReadLine" "CommandForeground" 0x1

# PSReadLine: Parameter Token syntax color. vim Normal group. (Default: 0x8)
Set-ItemProperty "HKCU:\Console\PSReadLine" "ParameterForeground" 0xF

# PSReadLine: Type Token syntax color. vim Type group. (Default: 0x7)
Set-ItemProperty "HKCU:\Console\PSReadLine" "TypeForeground" 0xE

# PSReadLine: Number Token syntax color. vim Number [or Constant] group. (Default: 0xF)
Set-ItemProperty "HKCU:\Console\PSReadLine" "NumberForeground" 0xC

# PSReadLine: Member Token syntax color. vim Function [or Identifier] group. (Default: 0x7)
Set-ItemProperty "HKCU:\Console\PSReadLine" "MemberForeground" 0xE

# PSReadLine: Emphasis syntax color. vim Search group. (Default: 0xB)
Set-ItemProperty "HKCU:\Console\PSReadLine" "EmphasisForeground" 0xD

# PSReadLine: Error syntax color. vim Error group. (Default: 0xC)
Set-ItemProperty "HKCU:\Console\PSReadLine" "ErrorForeground" 0x4

@(`
"HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe",`
"HKCU:\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe",`
"HKCU:\Console\Windows PowerShell (x86)",`
"HKCU:\Console\Windows PowerShell"`,
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

# Remove property overrides from PowerShell shortcuts
Reset-AllPowerShellShortcuts

echo "Done. Note that some of these changes require a logout/restart to take effect."
