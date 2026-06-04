@echo off
setlocal
cd /d "%~dp0"

echo === Atlas reset: verwijder alle plant-PNG's ===
del /Q "assets\images\vegetables\*.png" 2>nul
del /Q "assets\images\incoming\*.png" 2>nul

echo Atlas-PNG's verwijderd. App gebruikt weer emoji-iconen.
echo Start de app opnieuw: flutter run
pause
