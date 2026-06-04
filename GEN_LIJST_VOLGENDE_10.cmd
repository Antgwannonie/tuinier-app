@echo off
setlocal
cd /d "%~dp0"
echo === Volgende 10 Zoeken-lijsticonen (512x512) ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"
set BRON=C:\Users\frede\.cursor\projects\empty-window\assets
set IDS=basilicum_bloei koriander_bloei munt_bloei salie_bloei tijm_bloei ui_bloei bloemkool boerenkool boekweit bosui
for %%i in (%IDS%) do copy /Y "%BRON%\%%i_lijst_icon_bron.png" "assets\images\vegetables\%%i_lijst_icon_bron.png" >nul 2>&1
call dart pub get
for %%i in (%IDS%) do (
  echo.
  echo --- %%i ---
  call dart run tool/install_lijst_icon.dart %%i
  if errorlevel 1 pause & exit /b 1
)
echo.
echo Klaar. Bestanden:
dir /b assets\images\vegetables\*_lijst.png | findstr /i "basilicum_bloei koriander_bloei munt_bloei salie_bloei tijm_bloei ui_bloei bloemkool boerenkool boekweit bosui"
echo flutter run
pause
