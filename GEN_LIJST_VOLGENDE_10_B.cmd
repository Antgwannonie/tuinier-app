@echo off
setlocal
cd /d "%~dp0"
echo === Volgende 10 Zoeken-lijsticonen batch B (512x512) ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"
set BRON=C:\Users\frede\.cursor\projects\empty-window\assets
set IDS=braam broccoli bruine_boon cayenne_peper chilipeper chinese_kool courgette cucamelon doperwt dragon
for %%i in (%IDS%) do copy /Y "%BRON%\%%i_lijst_icon_bron.png" "assets\images\vegetables\%%i_lijst_icon_bron.png" >nul 2>&1
call dart pub get
for %%i in (%IDS%) do (
  echo.
  echo --- %%i ---
  call dart run tool/install_lijst_icon.dart %%i
  if errorlevel 1 pause & exit /b 1
)
echo.
echo Klaar.
dir /b assets\images\vegetables\*_lijst.png
echo flutter run
pause
