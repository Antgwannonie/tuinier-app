@echo off
setlocal
cd /d "%~dp0"
echo Map: %CD%
echo.
if not exist "pubspec.yaml" (
  echo FOUT: start dit script vanuit tuinier_app.
  pause
  exit /b 1
)
copy /Y "C:\Users\frede\.cursor\projects\empty-window\assets\avocado_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
call dart pub get
call dart run tool/install_lijst_icon.dart avocado
dir "assets\images\vegetables\avocado_lijst.png"
echo.
echo Daarna: dubbelklik START_APP.cmd of:
echo   cd /d C:\Users\frede\tuinier_app
echo   flutter run
pause
