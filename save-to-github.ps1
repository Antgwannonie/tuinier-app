# Slaat de huidige Tuinier-app op GitHub (zonder API-sleutel).
# Uitvoeren: dubbelklik save-to-github.bat

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

$remoteUrl = "https://github.com/Antgwannonie/tuinier-app.git"
$tagName = "v0.2-ai-moestuin"
$commitMessage = "Bewaar app-versie: AI plant scan, kalender, meldingen en instellingen"

Write-Host "Tuinier - opslaan naar GitHub..." -ForegroundColor Cyan

if (-not (Test-Path .git)) {
    git init
    Write-Host "Git-repository aangemaakt." -ForegroundColor Green
}

$ignoreLine = "lib/config/local_gemini_key.dart"
if (-not (Test-Path .gitignore)) {
    New-Item -Path .gitignore -ItemType File -Force | Out-Null
}
$gitignoreRaw = Get-Content .gitignore -Raw -ErrorAction SilentlyContinue
if ($null -eq $gitignoreRaw -or $gitignoreRaw -notmatch [regex]::Escape($ignoreLine)) {
    Add-Content .gitignore "`n$ignoreLine"
}

$remotes = @(git remote 2>$null)
if ($remotes -notcontains "origin") {
    git remote add origin $remoteUrl
    Write-Host "Remote origin toegevoegd." -ForegroundColor Green
}

git add -A
# Alleen unstagen als de sleutel per ongeluk wél getrackt was (normaal staat hij in .gitignore).
$keyTracked = git ls-files lib/config/local_gemini_key.dart 2>$null
if ($keyTracked) {
    git reset HEAD lib/config/local_gemini_key.dart 2>$null
    Write-Host "API-sleutel niet meegestuurd (veilig)." -ForegroundColor Yellow
}

$status = git status --porcelain
if (-not $status) {
    Write-Host "Geen wijzigingen om te committen." -ForegroundColor Yellow
} else {
    git commit -m $commitMessage
    $hash = git rev-parse --short HEAD
    Write-Host "Commit gemaakt: $hash" -ForegroundColor Green
}

git tag -f $tagName 2>$null
Write-Host "Tag: $tagName" -ForegroundColor Green

Write-Host "Pushen naar GitHub..." -ForegroundColor Cyan
git push -u origin HEAD
git push origin $tagName --force

Write-Host ""
Write-Host "Klaar. Repo: $remoteUrl" -ForegroundColor Green
Write-Host ('Later terug: git checkout ' + $tagName) -ForegroundColor Cyan
