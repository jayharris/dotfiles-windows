if ((which cinst) -eq $null) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}
Refresh-Environment

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
cinst winmerge
