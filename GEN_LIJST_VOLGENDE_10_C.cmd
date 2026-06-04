@echo off
setlocal
cd /d "%~dp0"
echo === Volgende 10 Zoeken-lijsticonen batch C (512x512, gedetailleerd) ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"
set BRON=C:\Users\frede\.cursor\projects\empty-window\assets
set IDS=druif duizendblad eikenbladsla facelia framboos goudsbloem habanero honingmeloen ijsbergsla jalapeno
for %%i in (%IDS%) do copy /Y "%BRON%\%%i_lijst_icon_bron.png" "assets\images\vegetables\%%i_lijst_icon_bron.png" >nul 2>&1
call dart pub get
for %%i in (%IDS%) do (
  echo.
  echo --- %%i ---
  call dart run tool/install_lijst_icon.dart %%i
  if errorlevel 1 pause & exit /b 1
)
echo.
echo Klaar. flutter run
pause
