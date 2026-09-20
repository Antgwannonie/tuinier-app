@echo off
set SRC=%USERPROFILE%\.cursor\projects\empty-window\assets
set DEST=%~dp0assets\images\moestuin_place
if not exist "%DEST%" mkdir "%DEST%"
copy /Y "%SRC%\place_outdoor.png" "%DEST%\"
copy /Y "%SRC%\place_balcony.png" "%DEST%\"
copy /Y "%SRC%\place_greenhouse.png" "%DEST%\"
copy /Y "%SRC%\place_indoor.png" "%DEST%\"
copy /Y "%SRC%\place_pot.png" "%DEST%\"
echo Iconen gekopieerd naar %DEST%
dir "%DEST%\place_*.png"
