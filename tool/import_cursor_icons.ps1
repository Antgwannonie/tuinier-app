# Importeert PNG's uit de Cursor-assetsmap naar de app (met verwerking).
param(
  [string]$Source = "C:\Users\frede\.cursor\projects\empty-window\assets"
)

Set-Location $PSScriptRoot\..
dart pub get
dart run tool/batch_import_atlas_icons.dart $Source
Write-Host "Klaar. Voer een hot restart uit in Flutter."
