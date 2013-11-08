git pull origin master
$profileDir = Split-Path -parent $profile
Copy-Item -Path ./*.ps1 -Destination $profileDir -Exclude "bootstrap.ps1"
Copy-Item -Path ./home/** -Destination $home -Include **
Remove-Variable profileDir