param()

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$setup = Join-Path $root "drivers\MF4010_MF4018_MFDrivers_x64\x64\Setup.exe"

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

if (-not [Environment]::Is64BitOperatingSystem) {
    throw "This kit is for 64-bit Windows only."
}

Write-Host "Canon MF4010/MF4018 MFDrivers setup will start."
Write-Host "Recommended: disconnect the USB cable now. Connect and power on the MFP only when the Canon wizard asks."
Read-Host "Press Enter to continue"

Start-Process -FilePath $setup -WorkingDirectory (Split-Path $setup) -Wait

Write-Host ""
Write-Host "Driver setup closed. Restart Windows before installing MF Toolbox."
