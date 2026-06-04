# Aardbei: 512×656 (0.78), zelfde als aalbes — via Dart (portret-crop).
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$dart = 'C:\src\flutter\flutter\bin\dart.bat'
if (-not (Test-Path $dart)) {
    Write-Error 'dart.bat niet gevonden. Run: dart run tool/install_plant_card_icon.dart aardbei'
}
Set-Location $root
& $dart run tool/install_plant_card_icon.dart aardbei
if (-not (Test-Path (Join-Path $root 'assets\images\vegetables\aardbei_v2.png'))) {
    Write-Error 'aardbei_v2.png niet aangemaakt.'
}
