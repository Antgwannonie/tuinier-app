@echo off
setlocal
cd /d "%~dp0"

echo ============================================================
echo  Lijsticonen herstellen (grijze verwerking is uit de code)
echo ============================================================
echo.
echo De app gebruikt nog de OUDE beschadigde *_lijst.png bestanden
echo totdat je ze hieronder opnieuw laadt.
echo.

if not exist "pubspec.yaml" (
  echo FOUT: start dit script in de map tuinier_app
  pause
  exit /b 1
)

echo --- Stap 1: oude PNG's uit git terugzetten (snelste fix) ---
set GIT_OK=0
if exist ".git" (
  git restore "assets/images/vegetables/" 2>nul
  if not errorlevel 1 set GIT_OK=1
  if %GIT_OK%==0 git checkout HEAD -- "assets/images/vegetables/" 2>nul
  if not errorlevel 1 set GIT_OK=1
)
if %GIT_OK%==1 (
  echo Git-restore uitgevoerd.
) else (
  echo Geen git of restore mislukt - ga door naar stap 2.
)
echo.

echo --- Stap 2: opnieuw verwerken vanuit bron-PNG's ---
echo Bronnen: empty-window\assets\*_lijst_icon_bron.png
echo ^(moeten zwarte achtergrond hebben, NIET de grijze *_lijst.png^)
echo.
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"
copy /Y "C:\Users\frede\.cursor\projects\empty-window\assets\*_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
call dart pub get
call dart run tool/install_all_lijst.dart
echo.

echo --- Stap 3: app-cache legen en opnieuw starten ---
echo Stop de app volledig, daarna in deze map:
echo   flutter clean
echo   flutter run
echo.
echo Hot reload is NIET genoeg voor nieuwe afbeeldingen.
echo.
pause
