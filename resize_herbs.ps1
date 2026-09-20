# Resize herb detail photos to max 820px wide.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$srcDir = 'C:\Users\frede\.cursor\projects\c-Users-frede-tuinier-app\assets'
$dstDir = 'C:\Users\frede\tuinier_app\assets\images\vegetables'
$maxW = 820

$ids = @(
  'anijs_kruid', 'basilicum', 'bieslook', 'bonenkruid', 'citroengras',
  'citroenmelisse', 'dille', 'dragon', 'estragon', 'kamille', 'kerrieblad',
  'kervel', 'koriander', 'majoraan', 'munt', 'oregano', 'pepermunt',
  'peterselie', 'rozemarijn', 'salie', 'tijm', 'tuinkruid'
)

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
    if (-not (Test-Path $src)) { throw "Missing source: $src" }
    $img = [System.Drawing.Image]::FromFile($src)
    try {
      if ($img.Width -gt $maxW) {
        $h = [int]($img.Height * $maxW / $img.Width)
        $bmp = New-Object System.Drawing.Bitmap $maxW, $h
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        try {
          $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
          $g.DrawImage($img, 0, 0, $maxW, $h)
        } finally {
          $g.Dispose()
        }
        $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmp.Dispose()
        Write-Host ("OK resize: {0} -> {1}x{2}" -f $name, $maxW, $h)
      } else {
        $img.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Host ("OK copy: {0} ({1}x{2})" -f $name, $img.Width, $img.Height)
      }
    } finally {
      $img.Dispose()
    }
    Remove-Item -LiteralPath $src -Force
    $ok++
  } catch {
    Write-Host ("FAIL: {0} - {1}" -f $name, $_.Exception.Message)
    $fail++
  }
}

Write-Host ("Done: {0} ok, {1} fail" -f $ok, $fail)
if ($fail -gt 0) { exit 1 }
