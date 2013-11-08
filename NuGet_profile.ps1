function Reinstall-Package {
  param(
    [Parameter(Mandatory = $true)]
    [string]
    $Id,

    [Parameter(Mandatory = $true)]
    [string]
    $Version,

    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]
    $ProjectName,

    [switch]
    $Force
  )

  if (-not $ProjectName) {
    $ProjectName = (get-project).ProjectName
  }

  Uninstall-Package -ProjectName $ProjectName -Id $Id -Force:$Force
  Install-Package -ProjectName $ProjectName -Id $Id -Version $Version
}

# Wire StudioShell Functions if Exists
if ((Get-Module -ListAvailable StudioShell) -ne $null) {
  Import-Module StudioShell

  function Reset-MultiMonitor {
    invoke-item DTE:\WindowConfigurations\MultiMonitor
  }
  function Reset-SingleMonitor {
    invoke-item DTE:\WindowConfigurations\SingleMonitor
  }

  $localMonitors = get-wmiobject -namespace root\WMI -computername localhost -Query "Select * from WmiMonitorID"
  if ($localMonitors.length -gt 1) {
    reset-multimonitor
  } else {
    reset-singlemonitor
  }
  Remove-Variable $localMonitors
}

