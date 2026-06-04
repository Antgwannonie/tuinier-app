@echo off
setlocal
cd /d "%~dp0"
echo Scan lijsticonen op avocado-achtige fouten...
echo.
call dart pub get
call dart run tool/detect_beschadigde_lijst.dart
echo.
pause
