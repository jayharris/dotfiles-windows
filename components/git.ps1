if (((Get-Command git -ErrorAction SilentlyContinue) -ne $null) -and ((Get-Module -ListAvailable Posh-Git -ErrorAction SilentlyContinue) -ne $null)) {
  Import-Module Posh-Git
  Start-SshAgent -Quiet
}
