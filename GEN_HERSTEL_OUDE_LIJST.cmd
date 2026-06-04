@echo off
setlocal
cd /d "%~dp0"
echo === Oude lijsticonen herstellen (PNG's uit git) ===
echo Verwerking staat weer op de oude pipeline (zwarte achtergrond).
echo.

if not exist ".git" (
  echo FOUT: geen git-repo. Oude PNG's kun je alleen terugzetten via git of een backup.
  echo Zonder backup: oude bron opnieuw genereren en install_lijst_icon.dart draaien.
  pause
  exit /b 1
)

git restore "assets/images/vegetables/" 2>nul
if errorlevel 1 git checkout HEAD -- "assets/images/vegetables/" 2>nul

echo.
git status --short "assets/images/vegetables/"
echo.
echo Als hier geen gewijzigde *_lijst.png meer staan: herstel gelukt.
echo Start de app opnieuw: flutter run
pause
