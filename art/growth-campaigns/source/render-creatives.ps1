param([string]$Root = (Split-Path -Parent $PSScriptRoot))

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Drawing.Common

function Convert-Color([string]$Hex) {
    return [Drawing.ColorTranslator]::FromHtml($Hex)
}

function Draw-Text($Canvas, [string]$Text, [string]$Font, [int]$Size, [string]$Color, [int]$X, [int]$Y) {
    $type = [Drawing.Font]::new($Font, $Size, [Drawing.FontStyle]::Bold, [Drawing.GraphicsUnit]::Pixel)
    $ink = [Drawing.SolidBrush]::new((Convert-Color $Color))
    try {
        $Canvas.DrawString($Text, $type, $ink, [single]$X, [single]$Y, [Drawing.StringFormat]::GenericTypographic)
    } finally { $ink.Dispose(); $type.Dispose() }
}

function New-Artboard([int]$Width, [int]$Height) {
    $bitmap = [Drawing.Bitmap]::new($Width, $Height, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $canvas = [Drawing.Graphics]::FromImage($bitmap)
    $canvas.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $canvas.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $canvas.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    return @{ Bitmap = $bitmap; Canvas = $canvas }
}

function Draw-Mark($Canvas, [int]$X, [int]$Y, [int]$Size, [string]$Accent, [string]$Dark) {
    $state = $Canvas.Save()
    $scale = $Size / 100.0
    $Canvas.TranslateTransform($X, $Y)
    $Canvas.ScaleTransform($scale, $scale)
    $accentBrush = [Drawing.SolidBrush]::new((Convert-Color $Accent))
    $darkBrush = [Drawing.SolidBrush]::new((Convert-Color $Dark))
    try {
        $Canvas.FillPolygon($accentBrush, [Drawing.Point[]]@(
            [Drawing.Point]::new(9,0),[Drawing.Point]::new(79,0),[Drawing.Point]::new(100,20),
            [Drawing.Point]::new(100,74),[Drawing.Point]::new(74,100),[Drawing.Point]::new(0,100),[Drawing.Point]::new(0,9)))
        $Canvas.FillPolygon($darkBrush, [Drawing.Point[]]@(
            [Drawing.Point]::new(15,22),[Drawing.Point]::new(69,22),[Drawing.Point]::new(83,35),
            [Drawing.Point]::new(83,64),[Drawing.Point]::new(68,78),[Drawing.Point]::new(15,78)))
        $Canvas.FillPolygon($accentBrush, [Drawing.Point[]]@(
            [Drawing.Point]::new(31,37),[Drawing.Point]::new(43,37),[Drawing.Point]::new(59,51),
            [Drawing.Point]::new(43,65),[Drawing.Point]::new(31,65),[Drawing.Point]::new(47,51)))
        $Canvas.FillRectangle($accentBrush, 64, 59, 8, 6)
    } finally { $accentBrush.Dispose(); $darkBrush.Dispose(); $Canvas.Restore($state) }
}

function Save-Artboard($Artboard, [string]$Path) {
    $Artboard.Canvas.Dispose()
    $Artboard.Bitmap.Save($Path, [Drawing.Imaging.ImageFormat]::Png)
    $Artboard.Bitmap.Dispose()
}

$campaigns = @(
    @{Key='factory'; Label='FACTORY TYCOON'; Accent='#FFCA63'; A=@('BUILD A','SCRAP FACTORY'); B=@('GROW YOUR','SCRAP FACTORY')},
    @{Key='defense'; Label='ZOMBIE DEFENSE'; Accent='#82F7E1'; A=@('DEFEND YOUR','FACTORY'); B=@('HOLD THE','FACTORY LINE')},
    @{Key='pets'; Label='POWER PETS'; Accent='#EBADFF'; A=@('HATCH YOUR','FIRST PET'); B=@('MEET YOUR','POWER PET')}
)

foreach ($item in $campaigns) {
    $path = Join-Path $Root $item.Key
    New-Item -ItemType Directory -Force -Path $path | Out-Null
    $plate = [Drawing.Image]::FromFile((Join-Path $PSScriptRoot ($item.Key + '-plate.png')))
    try {
        foreach ($variant in 'A','B') {
            $art = New-Artboard 1920 1080
            $g = $art.Canvas
            $g.Clear((Convert-Color '#080F1F'))
            $g.DrawImage($plate, [Drawing.Rectangle]::new(0,0,1920,1080))
            $gradient = [Drawing.Drawing2D.LinearGradientBrush]::new([Drawing.Rectangle]::new(0,0,1080,1080),
                [Drawing.Color]::FromArgb(240,8,15,31),[Drawing.Color]::FromArgb(0,8,15,31),0)
            $g.FillRectangle($gradient,0,0,1080,1080)
            $gradient.Dispose()
            Draw-Mark $g 100 118 55 $item.Accent '#122035'
            Draw-Text $g 'DEADZONE DOMINION' 'Bahnschrift SemiBold Condensed' 36 '#FFFFFF' 170 123
            Draw-Text $g $item.Label 'Bahnschrift SemiBold Condensed' 35 $item.Accent 94 360
            Draw-Text $g $item[$variant][0] 'Bahnschrift Condensed' 120 '#FFFFFF' 90 430
            Draw-Text $g $item[$variant][1] 'Bahnschrift Condensed' 120 $item.Accent 90 565
            Save-Artboard $art (Join-Path $path ($item.Key + '-' + $variant.ToLower() + '-1920x1080.png'))
        }
    } finally { $plate.Dispose() }
}

$brand = Join-Path $Root 'brand'
New-Item -ItemType Directory -Force -Path $brand | Out-Null
$compact = New-Artboard 512 512
Draw-Mark $compact.Canvas 40 40 432 '#FFCA63' '#18233B'
Save-Artboard $compact (Join-Path $brand 'deadzone-mark-transparent-512.png')
foreach ($bg in 'dark','light') {
    $board = New-Artboard 1360 300
    $typeColor = if ($bg -eq 'dark') { '#FFFFFF' } else { '#18233B' }
    Draw-Mark $board.Canvas 45 48 204 '#FFCA63' '#18233B'
    Draw-Text $board.Canvas 'DEADZONE DOMINION' 'Bahnschrift SemiBold Condensed' 111 $typeColor 285 84
    Draw-Text $board.Canvas 'POWERS TYCOON' 'Bahnschrift SemiBold Condensed' 40 $typeColor 294 198
    Save-Artboard $board (Join-Path $brand ('deadzone-wordmark-for-' + $bg + '-background.png'))
}

$proof = New-Artboard 558 290
$proof.Canvas.Clear((Convert-Color '#172237'))
for ($index=0; $index -lt $campaigns.Count; $index++) {
    $item = $campaigns[$index]
    $x = 27 + $index * 176
    Draw-Text $proof.Canvas $item.Key.ToUpper() 'Bahnschrift SemiBold Condensed' 17 '#FFFFFF' $x 24
    for ($version=0; $version -lt 2; $version++) {
        $variant = @('a','b')[$version]
        $file = Join-Path (Join-Path $Root $item.Key) ($item.Key + '-' + $variant + '-1920x1080.png')
        $image = [Drawing.Image]::FromFile($file)
        $proof.Canvas.DrawImage($image,[Drawing.Rectangle]::new($x,55 + 106 * $version,160,90))
        $image.Dispose()
    }
}
Save-Artboard $proof (Join-Path $Root 'small-tile-proof.png')
