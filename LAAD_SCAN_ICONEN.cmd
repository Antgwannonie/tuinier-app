@echo off
cd /d "%~dp0"
echo Komkommer-achtergrond installeren...
python tool\embed_scan_hero_bg.py
if errorlevel 1 (
  echo.
  echo Mislukt. Controleer of dit bestand bestaat:
  echo   %USERPROFILE%\.cursor\projects\empty-window\assets\scan_hero_bg.png
  pause
  exit /b 1
)
echo.
echo Gelukt. Stop de app en run:
echo   flutter pub get
echo   flutter run
echo.
pause
