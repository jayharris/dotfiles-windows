$profileDir = Split-Path -parent $profile
if (![System.IO.Directory]::Exists($profileDir)) {[System.IO.Directory]::CreateDirectory($profileDir)}
Copy-Item -Path ./*.ps1 -Destination $profileDir -Exclude "bootstrap.ps1"
Copy-Item -Path ./homeFiles/** -Destination $home -Include **
Remove-Variable profileDir