param()

$ErrorActionPreference = "Stop"
$root = Resolve-Path (Join-Path $PSScriptRoot "..")

$expectedHashes = @{
    "installers\MF4010_MFDrivers_W64_uk_EN.exe" = "C5E0C5800DE336A886D3A00666C6FE63349F806C56D4C5760C7CCFC2914A89AA"
    "installers\ToolBox4911mf18WinEN.exe"       = "D4C4C8BEE96308A5F572CB46061C97CE2DCA5209ABC569B81241C36DC4FBE37F"
    "optional\NetworkUSBScanPatchEN.exe"        = "4D55A4A3E3F5A130BC7A9CCFC5F72F91EDF71646E99EFE25E959FC74157E973F"
}

$signedFiles = @(
    "installers\MF4010_MFDrivers_W64_uk_EN.exe",
    "installers\ToolBox4911mf18WinEN.exe",
    "optional\NetworkUSBScanPatchEN.exe",
    "drivers\MF4010_MF4018_MFDrivers_x64\x64\Setup.exe",
    "drivers\MF4010_MF4018_MFDrivers_x64\x64\Driver\CNLB0K.CAT",
    "drivers\MF4010_MF4018_MFDrivers_x64\x64\Driver\MF31SCN.CAT",
    "toolbox\MF_Toolbox_4.9.1.1_mf18\Setup.exe"
)

function Get-KitPath([string]$relativePath) {
    return Join-Path $root $relativePath
}

$failed = $false

Write-Host "Checking SHA256 hashes..."
foreach ($item in $expectedHashes.GetEnumerator()) {
    $path = Get-KitPath $item.Key
    if (-not (Test-Path $path)) {
        Write-Host "MISSING  $($item.Key)" -ForegroundColor Red
        $failed = $true
        continue
    }
    $actual = (Get-FileHash $path -Algorithm SHA256).Hash.ToUpperInvariant()
    if ($actual -eq $item.Value) {
        Write-Host "OK       $($item.Key)"
    } else {
        Write-Host "BAD HASH $($item.Key)" -ForegroundColor Red
        Write-Host "Expected $($item.Value)"
        Write-Host "Actual   $actual"
        $failed = $true
    }
}

Write-Host ""
Write-Host "Checking Authenticode signatures..."
foreach ($relative in $signedFiles) {
    $path = Get-KitPath $relative
    if (-not (Test-Path $path)) {
        Write-Host "MISSING  $relative" -ForegroundColor Red
        $failed = $true
        continue
    }
    $sig = Get-AuthenticodeSignature $path
    if ($sig.Status -eq "Valid") {
        Write-Host "OK       $relative"
    } else {
        Write-Host "SIGN WARN $relative : $($sig.Status) - $($sig.StatusMessage)" -ForegroundColor Yellow
        $failed = $true
    }
}

Write-Host ""
Write-Host "Checking expected INF/model markers..."
$printerInf = Get-KitPath "drivers\MF4010_MF4018_MFDrivers_x64\x64\Driver\CNLB0KA64.INF"
$scannerInf = Get-KitPath "drivers\MF4010_MF4018_MFDrivers_x64\x64\Driver\MF31SCN.INF"
$toolboxCfg = Get-KitPath "toolbox\MF_Toolbox_4.9.1.1_mf18\Setup\TBOXCFG.ini"

$checks = @(
    @{ Path = $printerInf; Pattern = "Canon MF4010 Series UFRII LT" },
    @{ Path = $printerInf; Pattern = "USBPRINT\CanonMF4010_Series58E4" },
    @{ Path = $scannerInf; Pattern = "USB\VID_04A9&PID_26B4&MI_00" },
    @{ Path = $scannerInf; Pattern = "WIA Canon MF4010 Series" },
    @{ Path = $toolboxCfg; Pattern = "Canon MF4010 Series" }
)

foreach ($check in $checks) {
    $text = Get-Content $check.Path -Raw
    if ($text.Contains($check.Pattern)) {
        Write-Host "OK       $($check.Pattern)"
    } else {
        Write-Host "MISSING  $($check.Pattern)" -ForegroundColor Red
        $failed = $true
    }
}

$unsignedHelper = Get-KitPath "toolbox\MF_Toolbox_4.9.1.1_mf18\Setup\TBOXCFG.EXE"
if (Test-Path $unsignedHelper) {
    $sig = Get-AuthenticodeSignature $unsignedHelper
    Write-Host ""
    Write-Host "Note: TBOXCFG.EXE signature status is $($sig.Status). This helper is inside Canon's signed MF Toolbox package."
}

if ($failed) {
    Write-Host ""
    Write-Host "Verification finished with warnings/errors." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Verification OK."
