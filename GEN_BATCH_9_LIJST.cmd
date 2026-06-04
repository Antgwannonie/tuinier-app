@echo off
setlocal
cd /d "%~dp0"
echo === 9 lijsticonen: kardoen t/m pastinaak ===
set BRON=C:\Users\frede\.cursor\projects\empty-window\assets
for %%i in (kardoen kamille jostabes paksoi radijs schorseneer snijbonen witlof pastinaak) do (
  copy /Y "%BRON%\%%i_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
)
call dart pub get
call dart run tool/plant_lijst_regen_batch_9.dart
echo.
echo Daarna START_APP.cmd
pause
