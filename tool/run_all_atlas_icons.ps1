# Genereert alle ontbrekende atlas-iconen (zelfde stijl als tomaat).
# Vereist: dart pub get + GEMINI_API_KEY of lib/config/local_gemini_key.dart
#
#   cd C:\Users\frede\tuinier_app
#   .\tool\run_all_atlas_icons.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

dart pub get
dart run tool/export_plant_catalog.dart --write-missing
dart run tool/generate_atlas_plant_icons.dart --missing --delay-ms 2800 2>&1 `
  | Tee-Object -FilePath "assets\images\vegetables\generate_log.txt"

Write-Host ""
Write-Host "Klaar. Hot restart in Flutter. Log: assets\images\vegetables\generate_log.txt"
