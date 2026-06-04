@echo off
setlocal
cd /d "%~dp0"

echo === Aardappel icoon in app zetten ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"

echo [1/2] Dart import (512x826 Zoeken-kaartformaat)...
call dart pub get
call dart run tool/install_aardappel.dart
if errorlevel 1 (
  echo.
  echo Import mislukt. Kopieer handmatig:
  echo   C:\Users\frede\.cursor\projects\empty-window\assets\aardappel_moestuin_v2.png
  echo naar:
  echo   %CD%\assets\images\vegetables\aardappel.png
  pause
  exit /b 1
)

echo.
echo [2/2] Klaar! Start de app:
echo   flutter run
echo.
dir "assets\images\vegetables\aardappel.png"
pause
