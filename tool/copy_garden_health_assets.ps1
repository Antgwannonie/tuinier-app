$src = "$env:USERPROFILE\.cursor\projects\empty-window\assets"
$dst = Join-Path $PSScriptRoot "..\assets\images\garden_health"
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Copy-Item "$src\garden_health_*.png" $dst -Force
Get-ChildItem $dst -Filter "garden_health_*.png" | Format-Table Name, Length
