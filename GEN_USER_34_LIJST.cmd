@echo off
setlocal
cd /d "%~dp0"
echo === 34 lijsticonen: bron kopieren + nieuwe verwerking (magenta/wit-fix) ===
echo Eerst in Cursor: bron-PNG's laten maken (*_lijst_icon_bron.png in empty-window\assets)
echo.
set BRON=C:\Users\frede\.cursor\projects\empty-window\assets
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"
copy /Y "%BRON%\augurk_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\aalbes_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\appel_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\bloemkool_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\boerenkool_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\broccoli_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\chinese_kool_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\courgette_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\knoflook_hardnekkig_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\paksoi_jong_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\kardoen_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\kastanjechampignon_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\knoflook_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\knolvenkel_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\komkommer_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\lions_mane_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\meiraap_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\prei_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\raap_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\shimeji_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\limnanthes_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\spitskool_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\mais_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\venkel_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\lindebloesem_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\witte_biet_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\champignon_wit_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\zaadslurf_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\aardappel_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\aardbei_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\aardpeer_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\cucamelon_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
copy /Y "%BRON%\witte_asperge_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
call dart pub get
call dart run tool/plant_lijst_regen_batch.dart
echo.
echo Daarna: START_APP.cmd
pause
