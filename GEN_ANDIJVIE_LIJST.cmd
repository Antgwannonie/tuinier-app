@echo off
setlocal
cd /d "%~dp0"
echo === Andijvie lijst-icoon 512x512 (zelfde als aalbes) ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"
copy /Y "C:\Users\frede\.cursor\projects\empty-window\assets\andijvie_lijst_icon_bron.png" "assets\images\vegetables\andijvie_lijst_icon_bron.png" >nul 2>&1
call dart pub get
call dart run tool/install_lijst_icon.dart andijvie
if errorlevel 1 pause & exit /b 1
dir "assets\images\vegetables\andijvie_lijst.png"
echo flutter run
pause
