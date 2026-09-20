# Resize batch-2 vegetable detail photos to max 820px wide.
$ErrorActionPreference = 'Stop'

$srcDir = 'C:\Users\frede\.cursor\projects\c-Users-frede-tuinier-app\assets'
$dstDir = 'C:\Users\frede\tuinier_app\assets\images\vegetables'
$maxWidth = 820

$ids = @(
  'jalapeno', 'kapucijner', 'knoflook', 'knoflook_hardnekkig', 'komatsuna',
  'koolraap', 'koolrabi', 'krulsla', 'lambsla', 'lollo_rossa',
  'mais', 'maiskolf', 'meloen', 'mini_wortel', 'mizuna',
  'mosterdgroen', 'okra', 'paksoi', 'paksoi_jong', 'palmekool',
  'pastinaak', 'patisson', 'peper', 'pepino', 'peterseliewortel',
  'pinda', 'pompoen', 'pompoen_butternut', 'pompoen_hokkaido', 'postelein'
)

Add-Type -AssemblyName System.Drawing

if (-not (Test-Path $dstDir)) {
  New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
}

$ok = 0
$fail = 0

foreach ($id in $ids) {
  $name = "${id}_detail_a.png"
  $src = Join-Path $srcDir $name
  $dst = Join-Path $dstDir $name

  try {
    if (-not (Test-Path $src)) {
      Write-Host "MISSING: $name"
      $fail++
      continue
    }

    $img = [System.Drawing.Image]::FromFile($src)
    try {
      $newW = [Math]::Min($maxWidth, $img.Width)
      $newH = [int][Math]::Round($img.Height * ($newW / $img.Width))

      $bmp = New-Object System.Drawing.Bitmap $newW, $newH
      try {
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        try {
          $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
          $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
          $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
          $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
          $g.DrawImage($img, 0, 0, $newW, $newH)
        } finally {
          $g.Dispose()
        }

        $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Host ("OK: {0} -> {1}x{2}" -f $name, $newW, $newH)
        $ok++
      } finally {
        $bmp.Dispose()
      }
    } finally {
      $img.Dispose()
    }

    Remove-Item -LiteralPath $src -Force
  } catch {
    Write-Host ("FAIL: {0} - {1}" -f $name, $_.Exception.Message)
    $fail++
  }
}

Write-Host ""
Write-Host "Done. ok=$ok fail=$fail"
