# Resize fruit/berry detail photos to max 820px wide.
$ErrorActionPreference = 'Stop'

$srcDir = 'C:\Users\frede\.cursor\projects\c-Users-frede-tuinier-app\assets'
$dstDir = 'C:\Users\frede\tuinier_app\assets\images\vegetables'
$maxWidth = 820

$ids = @(
  'zure_kers', 'blauwe_bes', 'braam', 'framboos', 'framboos_zomer',
  'jostabes', 'rode_bes', 'rode_bes_grootvrucht', 'veenbes', 'vlierbes',
  'zwarte_bes', 'kruisbess', 'duindoorn', 'braam_zonder_doorn', 'blauwe_regen_bes'
)

Add-Type -AssemblyName System.Drawing

if (-not (Test-Path $dstDir)) {
  New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
}

$ok = 0
$fail = 0

foreach ($id in $ids) {
  $src = Join-Path $srcDir "${id}_detail_a.png"
  $dst = Join-Path $dstDir "${id}_detail_a.png"
  if (-not (Test-Path $src)) {
    Write-Host "FAIL missing source: $id"
    $fail++
    continue
  }
  try {
    $img = [System.Drawing.Image]::FromFile($src)
    try {
      $newW = [Math]::Min($maxWidth, $img.Width)
      $newH = [int][Math]::Round($img.Height * ($newW / $img.Width))
      $bmp = New-Object System.Drawing.Bitmap $newW, $newH
      $g = [System.Drawing.Graphics]::FromImage($bmp)
      $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $g.DrawImage($img, 0, 0, $newW, $newH)
      $g.Dispose()
      $img.Dispose()
      $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
      $bmp.Dispose()
      Write-Host "OK $id -> ${newW}x${newH}"
      $ok++
    } catch {
      if ($img) { $img.Dispose() }
      throw
    }
  } catch {
    Write-Host "FAIL $id : $_"
    $fail++
  }
}

Write-Host "Done: ok=$ok fail=$fail"
