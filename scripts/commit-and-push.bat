@echo off
cd /d "%~dp0.."
echo === git status ===
git status
if errorlevel 1 goto :fail

git diff --quiet && git diff --cached --quiet
if not errorlevel 1 (
  echo Geen wijzigingen om te committen.
  git push -u origin main
  if errorlevel 1 goto :fail
  goto :done
)

git add -A
if exist .env git reset HEAD .env 2>nul

git commit -m "History-herstel, plant-sheets en app-bar" -m "History blijft bij opnieuw in moestuin zetten, plant setup UI en kleuren, nieuwe moestuin-knop naast History, Material border-fix."
if errorlevel 1 goto :fail

echo === push ===
git push -u origin main
if errorlevel 1 goto :fail

:done
echo.
echo Klaar: https://github.com/Antgwannonie/tuinier-app
pause
exit /b 0

:fail
echo.
echo Er ging iets mis. Controleer of git geinstalleerd is en of je bent ingelogd op GitHub.
pause
exit /b 1
