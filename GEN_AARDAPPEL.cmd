@echo off
setlocal
cd /d "%~dp0"

echo === Aardappel opnieuw: hele plant in kaart (512x656) ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"

echo [1/2] Import via Dart...
call dart pub get
call dart run tool/install_aardappel.dart
if errorlevel 1 (
  echo Dart mislukt, probeer PowerShell met Bypass...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tool\install_aardappel.ps1"
)
if not exist "assets\images\vegetables\aardappel.png" (
  echo.
  echo MISLUKT: aardappel.png niet aangemaakt.
  pause
  exit /b 1
)

echo.
echo [2/2] Klaar. Start app:
echo   flutter clean
echo   flutter pub get
echo   flutter run
dir "assets\images\vegetables\aardappel.png"
pause
