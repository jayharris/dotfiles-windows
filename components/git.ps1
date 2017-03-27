if (((which git) -ne $null) -and ((Get-Module Posh-Git) -ne $null)) {
  Import-Module Posh-Git
  Start-SshAgent -Quiet
}
