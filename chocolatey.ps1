if ((which cinst) -eq $null) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

cinst curl
cinst Dropbox
cinst githubforwindows
cinst GoogleChrome
cinst GoogleChrome.Canary
cinst Hg
cinst Fiddler
cinst Firefox
cinst Opera
cinst SublimeText2
# RSAT Package is not compatible w/ Win8.1 Enterprise, yet
#cinst RSAT.FeaturePack
cinst wincommandpaste
cinst winmerge

# Workaround for RSAT
#Invoke-WebRequest "http://download.microsoft.com/download/1/8/E/18EA4843-C596-4542-9236-DE46F780806E/Windows8.1-KB2693643-x64.msu" -OutFile "$env:Temp\Windows8.1-KB2693643-x64.msu"
#& wusa.exe "$env:Temp\Windows8.1-KB2693643-x64.msu" /quiet /norestart | Out-Null
