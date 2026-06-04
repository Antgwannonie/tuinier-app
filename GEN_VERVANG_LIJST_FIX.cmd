@echo off
setlocal
cd /d "%~dp0"
echo === Lijsticonen opnieuw (fix donker fruit + hergen-batch) ===
echo Verwerking gebruikt nu alleen bijna-zwarte achtergrond, niet donkere schil.
echo.

set BRON=C:\Users\frede\.cursor\projects\empty-window\assets
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"
copy /Y "%BRON%\*_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1

call dart pub get
call dart run tool/install_lijst_icon.dart avocado
call dart run tool/install_lijst_icon.dart appel
call dart run tool/install_hergen_lijst.dart
call dart run tool/install_all_lijst.dart

echo.
echo Klaar. Stop de app en start opnieuw:
echo   flutter clean
echo   flutter run
pause
