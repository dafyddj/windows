$ProgressPreference='SilentlyContinue'

$cleanup_types = `
"Active Setup Temp Folders",`
"BranchCache",`
"Downloaded Program Files",`
"GameNewsFiles",`
"GameStatisticsFiles",`
"GameUpdateFiles",`
"Internet Cache Files",`
"Memory Dump Files",`
"Offline Pages Files",`
"Old ChkDsk Files",`
"Previous Installations",`
"Recycle Bin",`
"Service Pack Cleanup",`
"Setup Log Files",`
"System error memory dump files",`
"System error minidump files",`
"Temporary Files",`
"Temporary Setup Files",`
"Temporary Sync Files",`
"Thumbnail Cache",`
"Update Cleanup",`
"Upgrade Discarded Files",`
"User file versions",`
"Windows Defender",`
"Windows Error Reporting Archive Files",`
"Windows Error Reporting Queue Files",`
"Windows Error Reporting System Archive Files",`
"Windows Error Reporting System Queue Files",`
"Windows ESD installation files",`
"Windows Upgrade Log Files"


$cleanup_dirs = @(
    "C:\\Recovery"
    "$env:localappdata\\Nuget"
    "$env:localappdata\\temp\\*"
    "$env:windir\\logs"
    "$env:windir\\winsxs\\manifestcache"
)

$regKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
$state = "StateFlags0100"

if ([Environment]::OSVersion.Version -le (New-Object "Version" 10,0)) {
  foreach ($cleanup in $cleanup_types) {
    New-ItemProperty -Path "$regKey\$cleanup" -Name $state -Value 2 -PropertyType DWord -Force | Out-Null
  }
  if (Test-Path "$env:SystemRoot\SYSTEM32\cleanmgr.exe") {
    Start-Process -Wait cleanmgr -ArgumentList "/sagerun:100"
  }
} else {
  $cleanup_dirs | % {
    if(Test-Path $_) {
      Write-Host "Removing $_"
      try {
        Takeown /d Y /R /f $_
        Icacls $_ /GRANT:r administrators:F /T /c /q  2>&1 | Out-Null
        Remove-Item $_ -Recurse -Force | Out-Null
      } catch { $global:error.RemoveAt(0) }
    }
  }
}

Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
