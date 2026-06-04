@echo off
setlocal
cd /d "%~dp0"
echo === Aubergine lijst-icoon 512x512 (zelfde als aalbes) ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"
copy /Y "C:\Users\frede\.cursor\projects\empty-window\assets\aubergine_lijst_icon_bron.png" "assets\images\vegetables\aubergine_lijst_icon_bron.png" >nul 2>&1
call dart pub get
call dart run tool/install_lijst_icon.dart aubergine
if errorlevel 1 pause & exit /b 1
dir "assets\images\vegetables\aubergine_lijst.png"
echo flutter run
pause
