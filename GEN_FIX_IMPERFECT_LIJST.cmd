@echo off
setlocal
cd /d "%~dp0"
echo === Imperfecte lijsticonen opnieuw verwerken ===
set BRON=C:\Users\frede\.cursor\projects\empty-window\assets
copy /Y "%BRON%\bosui_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\lente_ui_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\cosmos_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\honingmeloen_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\raap_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\meiraap_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\koolrabi_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
call dart pub get
call dart run tool/plant_lijst_fix_imperfect.dart
echo.
echo Daarna START_APP.cmd
pause
