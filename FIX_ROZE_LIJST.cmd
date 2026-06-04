@echo off
setlocal
cd /d "%~dp0"
echo === Roze/magenta achtergrond wegwerken (opnieuw verwerken) ===
echo.
call dart pub get
call dart run tool/plant_lijst_regen_batch.dart
echo.
echo Daarna START_APP.cmd (flutter clean + run)
pause
