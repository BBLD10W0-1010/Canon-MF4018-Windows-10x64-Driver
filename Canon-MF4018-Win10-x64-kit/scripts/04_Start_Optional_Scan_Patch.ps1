param()

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$patch = Join-Path $root "optional\NetworkUSBScanPatchEN.exe"

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

Write-Host "This is the optional Canon Network/USB Scan Patch."
Write-Host "Use it after MFDrivers + MF Toolbox are installed and Windows has been restarted, only if USB scanning does not work."
Read-Host "Press Enter to continue"

Start-Process -FilePath $patch -WorkingDirectory (Split-Path $patch) -Wait

Write-Host ""
Write-Host "Patch setup closed. Restart Windows if prompted. Use Restart, not Shut down."
