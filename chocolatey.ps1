if ((which cinst) -eq $null) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

cinst curl
#cinst dropbox
#cinst evernote
#cinst filezilla
cinst githubforwindows
cinst googlechrome
cinst googlechrome.Canary
cinst hg
cinst fiddler
cinst firefox
cinst nodejs.install
cinst opera
#cinst putty
#cinst ruby
#cinst skype
#cinst sublimetext2
#cinst virtualclonedrive
#cinst vlc
#cinst wget
#cinst wput
cinst wincommandpaste
cinst winmerge
