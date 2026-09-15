param()

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$uninstaller = Join-Path $root "drivers\MF4010_MF4018_MFDrivers_x64\x64\misc\DelDrv.exe"

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList @(
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`""
    )
    exit
}

Write-Host "Canon driver removal utility will start."
Write-Host "Disconnect the USB cable before removing drivers."
Read-Host "Press Enter to continue"

Start-Process -FilePath $uninstaller -WorkingDirectory (Split-Path $uninstaller) -Wait

Write-Host ""
Write-Host "Removal utility closed. Restart Windows, then remove remaining device entries if Windows still shows them."
