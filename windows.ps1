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

# Update Chrome & Canary's DevTools to a custom stylesheet
# Uses: https://github.com/mauricecruz/chrome-devtools-zerodarkmatrix-theme
# Canary
Invoke-WebRequest "https://raw.github.com/mauricecruz/chrome-devtools-zerodarkmatrix-theme/master/Custom.css" -OutFile "$env:Home\AppData\Local\Google\Chrome SxS\User Data\Default\User StyleSheets\Custom.css"
# Chrome
Invoke-WebRequest "https://raw.github.com/mauricecruz/chrome-devtools-zerodarkmatrix-theme/master/Custom-Stable.css" -OutFile "$env:Home\AppData\Local\Google\Chrome\User Data\Default\User StyleSheets\Custom.css"

# Set DisplayName for my account
$user = Get-WmiObject Win32_UserAccount | Where {$_.Caption -eq $myWindowsID.Name}
$user.FullName = "Jay Harris"
$user.Put()

# Set Computer Name
(Get-WmiObject Win32_ComputerSystem).Rename("CHOZO")

# Configure IIS
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
New-PSDrive -Name HKUSERS -PSProvider Registry -Root Registry::HKEY_USERS | Out-Null

# Set Windows Update to auto-download but not auto-install. Don't automatically reboot
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate", "AUOptions", 3
Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate", "NoAutoRebootWithLoggedOnUsers", 1



