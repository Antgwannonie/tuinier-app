@echo off
setlocal
cd /d "%~dp0"
echo === Laatste 14 Zoeken-lijsticonen batch V — afronding (512x512, gedetailleerd) ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"
set BRON=C:\Users\frede\.cursor\projects\empty-window\assets
set IDS=scheve_ui knoflook_hardnekkig bloemkool_paars spruitkool_rood paksoi_jong courgette_geel patisson_geel maiskolf pompoen_hokkaido pompoen_butternut aardbei_everbearer framboos_zomer braam_zonder_doorn rode_bes_grootvrucht
for %%i in (%IDS%) do copy /Y "%BRON%\%%i_lijst_icon_bron.png" "assets\images\vegetables\%%i_lijst_icon_bron.png" >nul 2>&1
call dart pub get
for %%i in (%IDS%) do (
  echo.
  echo --- %%i ---
  call dart run tool/install_lijst_icon.dart %%i
  if errorlevel 1 pause & exit /b 1
)
echo.
echo Klaar — alle 243 planten hebben nu een lijsticoon. flutter run
pause
