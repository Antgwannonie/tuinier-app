$ErrorActionPreference = 'Stop'
$root = 'C:\Users\frede\tuinier_app'
$log = Join-Path $root '_aalbes_import_log.txt'
$bronEmpty = 'C:\Users\frede\.cursor\projects\empty-window\assets\aalbes_lang_bron.png'
$bronApp = Join-Path $root 'assets\images\vegetables\aalbes_lang_bron.png'
$outPng = Join-Path $root 'assets\images\vegetables\aalbes.png'
$dart = 'C:\src\flutter\flutter\bin\dart.bat'

function Log($msg) {
  $line = "$(Get-Date -Format o) $msg"
  Add-Content -LiteralPath $log -Value $line
  Write-Output $line
}

Set-Location $root
'' | Set-Content -LiteralPath $log

Log "bron empty-window exists: $(Test-Path -LiteralPath $bronEmpty)"
if (Test-Path -LiteralPath $bronEmpty) {
  Copy-Item -LiteralPath $bronEmpty -Destination $bronApp -Force
  Log "copied bron -> $bronApp ($((Get-Item $bronApp).Length) bytes)"
}

Log "dart exists: $(Test-Path -LiteralPath $dart)"
& $dart run tool/install_plant_card_icon.dart aalbes *>&1 | ForEach-Object { Log $_ }
Log "dart exit: $LASTEXITCODE"
Log "aalbes.png exists: $(Test-Path -LiteralPath $outPng)"
if (Test-Path -LiteralPath $outPng) {
  Log "aalbes.png size: $((Get-Item $outPng).Length) bytes"
}
