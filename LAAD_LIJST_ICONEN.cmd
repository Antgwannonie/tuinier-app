@echo off
setlocal
cd /d "%~dp0"

echo === Zoeken-lijsticonen laden (512x512, transparant) ===
echo Map: %CD%
echo.

if not exist "pubspec.yaml" (
  echo FOUT: pubspec.yaml niet gevonden. Start dit script vanuit tuinier_app.
  pause
  exit /b 1
)

if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"

echo Kopieren bronbestanden...
copy /Y "C:\Users\frede\.cursor\projects\empty-window\assets\*_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1

echo.
call dart pub get
call dart run tool/install_all_lijst.dart
echo.
echo Controleren wat nog ontbreekt...
call dart run tool/list_missing_lijst.dart
echo.
echo Start daarna de app opnieuw:
echo   flutter run
echo.
pause
