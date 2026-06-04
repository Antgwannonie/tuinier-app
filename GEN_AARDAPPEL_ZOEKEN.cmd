@echo off
setlocal
cd /d "%~dp0"

echo === Aardappel Zoeken-icoon 152x152 (voor 76px thumbnail) ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"

copy /Y "C:\Users\frede\.cursor\projects\empty-window\assets\aardappel_zoeken_icon_bron.png" "assets\images\vegetables\aardappel_zoeken_icon_bron.png" >nul 2>&1

call dart pub get
call dart run tool/install_zoeken_thumbnail.dart aardappel
if errorlevel 1 pause & exit /b 1

dir "assets\images\vegetables\aardappel_zoeken.png"
echo.
echo flutter run
pause
