@echo off
setlocal
cd /d "%~dp0"

echo === Atlas-iconen importeren ===
if not exist "assets\images\incoming" mkdir "assets\images\incoming"

echo Kopieren van Cursor-assets...
copy /Y "C:\Users\frede\.cursor\projects\empty-window\assets\*.png" "assets\images\incoming\" >nul 2>&1
if errorlevel 1 (
  xcopy /Y /I "C:\Users\frede\.cursor\projects\empty-window\assets\*.png" "assets\images\incoming\" >nul 2>&1
)

echo Dart import...
call dart pub get
call dart run tool/batch_import_atlas_icons.dart
call dart run tool/reprocess_atlas_icons.dart

echo.
echo Iconen in vegetables:
dir /b "assets\images\vegetables\*.png"
echo.
echo Klaar. Stop de app en start opnieuw met: flutter run
pause
