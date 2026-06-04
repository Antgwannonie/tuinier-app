# Aalbes: zelfde Zoeken-kaartformaat als aardappel (512 x 656, ratio 0.78).
$ErrorActionPreference = 'Stop'
$ratio = 0.78
$tw = 512
$th = [int][Math]::Round($tw / $ratio)

$root = Split-Path $PSScriptRoot -Parent
$sources = @(
    'C:\Users\frede\.cursor\projects\empty-window\assets\aalbes_kaart_bron.png',
    'C:\Users\frede\.cursor\projects\empty-window\assets\aalbes_lang_bron.png',
    (Join-Path $root 'assets\images\vegetables\aalbes_lang_bron.png'),
    'C:\Users\frede\.cursor\projects\empty-window\assets\aalbes_512x656_bron.png',
    'C:\Users\frede\.cursor\projects\empty-window\assets\aalbes_zoeken_kaart.png'
)
$srcPath = $null
foreach ($s in $sources) {
    if (Test-Path $s) { $srcPath = $s; break }
}
if (-not $srcPath) { Write-Error 'Geen aalbes-bron gevonden.' }

$destPath = Join-Path $root 'assets\images\vegetables\aalbes.png'
$destDir = Split-Path $destPath -Parent
if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Image]::FromFile($srcPath)
try {
    $scale = [Math]::Min($tw / $src.Width, $th / $src.Height) * 0.82
    $fw = [int]($src.Width * $scale)
    $fh = [int]($src.Height * $scale)
    $fx = [int](($tw - $fw) / 2)
    $fy = [int](($th - $fh) / 2)

    $out = New-Object System.Drawing.Bitmap $tw, $th
    $g = [System.Drawing.Graphics]::FromImage($out)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $sky = $src.GetPixel([int]($src.Width / 2), [int]([Math]::Min(8, $src.Height - 1)))
    $g.Clear([System.Drawing.Color]::FromArgb($sky.R, $sky.G, $sky.B))
    $g.DrawImage($src, $fx, $fy, $fw, $fh)
    $g.Dispose()
    $out.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $out.Dispose()
}
finally {
    $src.Dispose()
}

Write-Host "OK: $destPath (${tw}x${th}, Zoeken-kaart 0.78) van $srcPath"
