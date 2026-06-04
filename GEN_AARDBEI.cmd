@echo off
setlocal
cd /d "%~dp0"

echo === Aardbei v2: 512 x 656 (0.78, portret — vervangt oude aardbei.png) ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"

echo Verwijder oude bestanden...
del /f "assets\images\vegetables\aardbei.png" 2>nul
del /f "assets\images\vegetables\aardbei_v2.png" 2>nul

echo Bron kopiëren...
copy /Y "C:\Users\frede\.cursor\projects\empty-window\assets\aardbei_kaart_bron.png" "assets\images\vegetables\aardbei_kaart_bron.png" >nul 2>&1

echo Import...
call dart pub get
call dart run tool/install_plant_card_icon.dart aardbei
if errorlevel 1 (
  echo Dart mislukt. Probeer:
  echo   C:\src\flutter\flutter\bin\dart.bat run tool/install_plant_card_icon.dart aardbei
  pause
  exit /b 1
)

if not exist "assets\images\vegetables\aardbei_v2.png" (
  echo MISLUKT: aardbei_v2.png niet gevonden.
  echo Bron: C:\Users\frede\.cursor\projects\empty-window\assets\aardbei_kaart_bron.png
  pause
  exit /b 1
)

echo.
echo OK. Daarna:
echo   flutter clean
echo   flutter pub get
echo   flutter run
echo In app: Aardbei -^> Foto in kaart aanpassen -^> Reset -^> Opslaan
echo.
dir "assets\images\vegetables\aardbei_v2.png"
pause
