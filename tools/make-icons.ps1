# Builds every icon from design/logo-source.png: the in-app logo, web/PWA icons, and the
# Android launcher icons (written to android/res, copied into the APK by build-apk.ps1).
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$repo = Split-Path $PSScriptRoot -Parent
$src = [System.Drawing.Image]::FromFile("$repo\design\logo-source.png")
$crop = [int]($src.Width * 0.047)                 # trims the dark margin around the gold frame
$logoRect = New-Object System.Drawing.Rectangle $crop, $crop, ($src.Width - 2 * $crop), ($src.Height - 2 * $crop)
$felt = [System.Drawing.ColorTranslator]::FromHtml('#082116')

function Save-Icon($path, $size, $scale, $bg, $round) {
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'HighQuality'; $g.PixelOffsetMode = 'HighQuality'
  if ($bg) { $g.Clear($bg) } else { $g.Clear([System.Drawing.Color]::Transparent) }
  $d = [int]($size * $scale); $o = [int](($size - $d) / 2)
  if ($round) {                                   # clip to a rounded square so corners stay clean
    $r = [int]($d * 0.19); $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.AddArc($o, $o, 2 * $r, 2 * $r, 180, 90); $p.AddArc($o + $d - 2 * $r, $o, 2 * $r, 2 * $r, 270, 90)
    $p.AddArc($o + $d - 2 * $r, $o + $d - 2 * $r, 2 * $r, 2 * $r, 0, 90); $p.AddArc($o, $o + $d - 2 * $r, 2 * $r, 2 * $r, 90, 90)
    $p.CloseFigure(); $g.SetClip($p)
  }
  $g.DrawImage($src, (New-Object System.Drawing.Rectangle $o, $o, $d, $d), $logoRect, [System.Drawing.GraphicsUnit]::Pixel)
  New-Item -ItemType Directory -Force (Split-Path $path) | Out-Null
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose()
}

Save-Icon "$repo\kachuful-logo.png" 512 1 $null $false
Save-Icon "$repo\icon-192.png" 192 1 $null $true
Save-Icon "$repo\icon-512.png" 512 1 $null $true
Save-Icon "$repo\icon-maskable-512.png" 512 0.78 $felt $true

# Android: legacy square/round icons plus adaptive foreground (logo inside the 108dp safe zone)
$dens = @{ mdpi = 48; hdpi = 72; xhdpi = 96; xxhdpi = 144; xxxhdpi = 192 }
foreach ($k in $dens.Keys) {
  $s = $dens[$k]; $dir = "$repo\android\res\mipmap-$k"
  Save-Icon "$dir\ic_launcher.png" $s 1 $null $true
  Save-Icon "$dir\ic_launcher_round.png" $s 0.86 $felt $true
  Save-Icon "$dir\ic_launcher_foreground.png" ([int]($s * 2.25)) 0.66 $null $true
}
$src.Dispose()
"Icons written."
