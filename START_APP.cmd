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
echo Start app (zonder flutter clean — assets blijven gebundeld).
echo Voor schone rebuild: flutter clean ^&^& flutter pub get ^&^& flutter run
echo.
call flutter pub get
call flutter run
pause
