param()

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$setup = Join-Path $root "toolbox\MF_Toolbox_4.9.1.1_mf18\Setup.exe"

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

Write-Host "Canon MF Toolbox 4.9 setup will start."
Start-Process -FilePath $setup -WorkingDirectory (Split-Path $setup) -Wait

Write-Host ""
Write-Host "MF Toolbox setup closed. Test scanning with Canon MF4010 Series as the selected source."
