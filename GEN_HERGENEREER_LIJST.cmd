@echo off
setlocal
cd /d "%~dp0"
echo === Hergeneratie lijsticonen (512x512, gedetailleerd, geen tekst) ===
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"
set BRON=C:\Users\frede\.cursor\projects\empty-window\assets
set IDS=aalbes afrikaantje andijvie anijs_kruid appel aubergine augurk avocado basilicum bijenmengsel blauwe_bes bleekselderij basilicum_bloei look_bloei koriander_bloei munt_bloei salie_bloei tijm_bloei ui_bloei bloemkool boekweit boerenkool broccoli chinese_kool courgette dragon komkommerkruid komkommer lindenbloesem aardappel aardbei aardpeer artisjok blauwe_regen_bes bruine_boon cayenne_peper cucamelon doperwt
for %%i in (%IDS%) do copy /Y "%BRON%\%%i_lijst_icon_bron.png" "assets\images\vegetables\%%i_lijst_icon_bron.png" >nul 2>&1
call dart pub get
call dart run tool/install_hergen_lijst.dart
echo.
echo Klaar. flutter run
pause
