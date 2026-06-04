# Eenmalig: wijzigingen committen en naar GitHub pushen.
# Als PowerShell scripts blokkeert, gebruik in plaats daarvan:
#   scripts\commit-and-push.bat
# Of eenmalig:
#   powershell -ExecutionPolicy Bypass -File .\scripts\commit-and-push.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot\..

Write-Host "=== git status ===" -ForegroundColor Cyan
git status

if (-not (git remote)) {
  Write-Error "Geen git remote. Voeg origin toe: git remote add origin <url>"
}

$changes = git status --porcelain
if (-not $changes) {
  Write-Host "Geen wijzigingen om te committen." -ForegroundColor Yellow
  git push -u origin HEAD
  exit 0
}

# Geen secrets
git add -A
if (Test-Path .env) { git reset HEAD .env 2>$null }

git commit -m @"
History-herstel, plant-sheets en app-bar

- History blijft bij opnieuw in moestuin zetten (frisse kopie)
- Plant setup sheets en kleurenpalet
- Nieuwe moestuin-knop compact naast History
- Material border-fix op history-kaarten
"@

Write-Host "=== push ===" -ForegroundColor Cyan
git push -u origin HEAD

Write-Host "Klaar: https://github.com/Antgwannonie/tuinier-app" -ForegroundColor Green
