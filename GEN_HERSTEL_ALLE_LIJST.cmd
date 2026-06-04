@echo off
setlocal
cd /d "%~dp0"
echo === Alle lijsticonen herstellen (oude verwerking, geen grijs) ===
echo Dit overschrijft beschadigde *_lijst.png opnieuw vanuit de bron-PNG's.
echo.

if exist ".git" (
  echo Stap 1: Eerst proberen oude PNG's uit git...
  git restore "assets/images/vegetables/" 2>nul
  if not errorlevel 1 (
    echo Git-restore gedaan. Controleer de app; als alles goed is, hoef je stap 2 niet.
    echo.
    git status --short "assets/images/vegetables/" 2>nul
    echo.
    set /p DOOR="Toch alles opnieuw verwerken vanuit bron? (j/N): "
    if /i not "%DOOR%"=="j" goto end
  )
)

echo Stap 2: Opnieuw verwerken met OUDE pipeline (geen grijs)...
set BRON=C:\Users\frede\.cursor\projects\empty-window\assets
if not exist "assets\images\vegetables" mkdir "assets\images\vegetables"
copy /Y "%BRON%\*_lijst_icon_bron.png" "assets\images\vegetables\" >nul 2>&1
call dart pub get
call dart run tool/install_all_lijst.dart

:end
echo.
echo Klaar. flutter run
pause
