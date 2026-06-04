@echo off
setlocal
cd /d "%~dp0"

echo === Aalbes: Zoeken-kaart 512 x 656 (ratio 0.78, zelfde als aardappel) ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"

echo [1/2] Import...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tool\install_aalbes.ps1"
if errorlevel 1 (
  echo PowerShell mislukt, probeer Dart...
  call dart pub get
  call dart run tool/install_plant_card_icon.dart aalbes
)
if not exist "assets\images\vegetables\aalbes.png" (
  echo.
  echo MISLUKT: aalbes.png is niet aangemaakt.
  echo Bron moet bestaan, bijv.:
  echo   C:\Users\frede\.cursor\projects\empty-window\assets\aalbes_kaart_bron.png
  echo Daarna opnieuw dit bestand dubbelklikken.
  pause
  exit /b 1
)

echo.
echo Klaar. Herstart de app volledig ^(geen hot reload^):
echo   flutter clean
echo   flutter pub get
echo   flutter run

echo.
echo [2/2] Start app: flutter run
dir "assets\images\vegetables\aalbes.png"
pause
