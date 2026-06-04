@echo off
setlocal
cd /d "%~dp0"
echo Map: %CD%
echo.
if not exist "pubspec.yaml" (
  echo FOUT: pubspec.yaml niet gevonden.
  pause
  exit /b 1
)
call flutter clean
call flutter run
pause
