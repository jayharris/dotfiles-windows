git pull origin master
$profileDir = Split-Path -parent $profile
Copy-Item -Include *.ps1 -Exclude "bootstrap.ps1" ./ $profileDir
Copy-Item -Include ** ./home/ $home
Remove-Variable $profileDir