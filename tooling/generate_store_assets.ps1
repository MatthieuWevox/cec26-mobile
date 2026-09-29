param(
    [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$IncludeTablets
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$primary = [System.Drawing.ColorTranslator]::FromHtml('#272262')
$primaryDark = [System.Drawing.ColorTranslator]::FromHtml('#151234')
$accent = [System.Drawing.ColorTranslator]::FromHtml('#5CC7CF')
$surface = [System.Drawing.ColorTranslator]::FromHtml('#F5F7FA')
$surfaceAlt = [System.Drawing.ColorTranslator]::FromHtml('#E5F7F8')
$text = [System.Drawing.ColorTranslator]::FromHtml('#171827')
$muted = [System.Drawing.ColorTranslator]::FromHtml('#626A7D')
$white = [System.Drawing.Color]::White
$frame = [System.Drawing.ColorTranslator]::FromHtml('#10111A')
$frameEdge = [System.Drawing.ColorTranslator]::FromHtml('#444656')

function Set-GraphicsQuality([System.Drawing.Graphics]$Graphics) {
    $Graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $Graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $Graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $Graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
}

function New-RoundedPath([System.Drawing.RectangleF]$Rectangle, [float]$Radius) {
    $safeRadius = [Math]::Min($Radius, [Math]::Min($Rectangle.Width, $Rectangle.Height) / 2)
    $diameter = $safeRadius * 2
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $path.AddArc($Rectangle.X, $Rectangle.Y, $diameter, $diameter, 180, 90)
    $path.AddArc($Rectangle.Right - $diameter, $Rectangle.Y, $diameter, $diameter, 270, 90)
    $path.AddArc($Rectangle.Right - $diameter, $Rectangle.Bottom - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc($Rectangle.X, $Rectangle.Bottom - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function Fill-RoundedRectangle(
    [System.Drawing.Graphics]$Graphics,
    [System.Drawing.RectangleF]$Rectangle,
    [float]$Radius,
    [System.Drawing.Color]$Color
) {
    $path = New-RoundedPath $Rectangle $Radius
    $brush = [System.Drawing.SolidBrush]::new($Color)
    $Graphics.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
}

function Draw-RoundedRectangle(
    [System.Drawing.Graphics]$Graphics,
    [System.Drawing.RectangleF]$Rectangle,
    [float]$Radius,
    [System.Drawing.Color]$Color,
    [float]$Width
) {
    $path = New-RoundedPath $Rectangle $Radius
    $pen = [System.Drawing.Pen]::new($Color, $Width)
    $Graphics.DrawPath($pen, $path)
    $pen.Dispose()
    $path.Dispose()
}

function Fill-Rectangle(
    [System.Drawing.Graphics]$Graphics,
    [System.Drawing.Color]$Color,
    [float]$X,
    [float]$Y,
    [float]$Width,
    [float]$Height
) {
    $brush = [System.Drawing.SolidBrush]::new($Color)
    $Graphics.FillRectangle($brush, $X, $Y, $Width, $Height)
    $brush.Dispose()
}

function New-Canvas([int]$Width, [int]$Height, [System.Drawing.Color]$Background) {
    $bitmap = [System.Drawing.Bitmap]::new(
        $Width,
        $Height,
        [System.Drawing.Imaging.PixelFormat]::Format24bppRgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    Set-GraphicsQuality $graphics
    $graphics.Clear($Background)
    return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function New-AlphaCanvas([int]$Width, [int]$Height, [System.Drawing.Color]$Background) {
    $bitmap = [System.Drawing.Bitmap]::new(
        $Width,
        $Height,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    Set-GraphicsQuality $graphics
    $graphics.Clear($Background)
    return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function Draw-TextBlock(
    [System.Drawing.Graphics]$Graphics,
    [string]$Value,
    [System.Drawing.Font]$Font,
    [System.Drawing.Color]$Color,
    [System.Drawing.RectangleF]$Rectangle,
    [System.Drawing.StringAlignment]$Alignment = [System.Drawing.StringAlignment]::Near
) {
    $brush = [System.Drawing.SolidBrush]::new($Color)
    $format = [System.Drawing.StringFormat]::new()
    $format.Alignment = $Alignment
    $format.LineAlignment = [System.Drawing.StringAlignment]::Near
    $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
    $Graphics.DrawString($Value, $Font, $brush, $Rectangle, $format)
    $format.Dispose()
    $brush.Dispose()
}

function Draw-DeviceMockup {
    param(
        [System.Drawing.Graphics]$Graphics,
        [System.Drawing.Image]$Image,
        [float]$X,
        [float]$Y,
        [float]$Width,
        [float]$Height,
        [int]$CropTop = 63,
        [int]$CropBottom = 63,
        [float]$Angle = 0,
        [ValidateSet('android', 'iphone', 'tablet')]
        [string]$Kind = 'android'
    )

    $padding = [int][Math]::Max(14, $Width * 0.075)
    $shadowOffset = [int][Math]::Max(7, $Width * 0.025)
    $layerWidth = [int][Math]::Ceiling($Width + ($padding * 2) + $shadowOffset)
    $layerHeight = [int][Math]::Ceiling($Height + ($padding * 2) + ($shadowOffset * 2))
    $layer = [System.Drawing.Bitmap]::new(
        $layerWidth,
        $layerHeight,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $layerGraphics = [System.Drawing.Graphics]::FromImage($layer)
    Set-GraphicsQuality $layerGraphics
    $layerGraphics.Clear([System.Drawing.Color]::Transparent)

    $radius = if ($Kind -eq 'tablet') { $Width * 0.045 } else { $Width * 0.085 }
    $frameRectangle = [System.Drawing.RectangleF]::new($padding, $padding, $Width, $Height)
    $shadowRectangle = [System.Drawing.RectangleF]::new(
        $padding + $shadowOffset,
        $padding + ($shadowOffset * 2),
        $Width,
        $Height
    )
    Fill-RoundedRectangle $layerGraphics $shadowRectangle $radius ([System.Drawing.Color]::FromArgb(58, 18, 20, 34))
    Fill-RoundedRectangle $layerGraphics $frameRectangle $radius $frame
    Draw-RoundedRectangle $layerGraphics $frameRectangle $radius $frameEdge ([Math]::Max(1.5, $Width * 0.004))

    $sideInset = [float][Math]::Max(10, $Width * 0.025)
    $topInset = [float][Math]::Max(13, $Width * $(if ($Kind -eq 'tablet') { 0.025 } else { 0.038 }))
    $bottomInset = [float][Math]::Max(13, $Width * $(if ($Kind -eq 'tablet') { 0.025 } else { 0.035 }))
    $availableWidth = $Width - ($sideInset * 2)
    $availableHeight = $Height - $topInset - $bottomInset
    $sourceHeight = $Image.Height - $CropTop - $CropBottom
    $sourceRatio = $Image.Width / $sourceHeight
    $screenWidth = $availableWidth
    $screenHeight = $screenWidth / $sourceRatio
    if ($screenHeight -gt $availableHeight) {
        $screenHeight = $availableHeight
        $screenWidth = $screenHeight * $sourceRatio
    }
    $screenX = $padding + (($Width - $screenWidth) / 2)
    $screenY = $padding + $topInset + (($availableHeight - $screenHeight) / 2)
    $screenRectangle = [System.Drawing.RectangleF]::new($screenX, $screenY, $screenWidth, $screenHeight)
    $screenRadius = if ($Kind -eq 'tablet') { $radius * 0.62 } else { $radius * 0.72 }
    $screenPath = New-RoundedPath $screenRectangle $screenRadius
    $layerGraphics.SetClip($screenPath)
    $sourceRectangle = [System.Drawing.Rectangle]::new(0, $CropTop, $Image.Width, $sourceHeight)
    $layerGraphics.DrawImage(
        $Image,
        $screenRectangle,
        $sourceRectangle,
        [System.Drawing.GraphicsUnit]::Pixel
    )
    $layerGraphics.ResetClip()
    $screenPath.Dispose()

    if ($Kind -eq 'iphone') {
        $islandWidth = [float]($Width * 0.19)
        $islandHeight = [float]([Math]::Max(10, $Width * 0.026))
        $islandRectangle = [System.Drawing.RectangleF]::new(
            $padding + (($Width - $islandWidth) / 2),
            $padding + ($topInset * 0.28),
            $islandWidth,
            $islandHeight
        )
        Fill-RoundedRectangle $layerGraphics $islandRectangle ($islandHeight / 2) ([System.Drawing.Color]::FromArgb(255, 3, 3, 7))
    }
    elseif ($Kind -eq 'android') {
        $cameraSize = [float]([Math]::Max(8, $Width * 0.022))
        $cameraBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 3, 3, 7))
        $layerGraphics.FillEllipse(
            $cameraBrush,
            $padding + (($Width - $cameraSize) / 2),
            $padding + ($topInset * 0.32),
            $cameraSize,
            $cameraSize
        )
        $cameraBrush.Dispose()
    }
    else {
        $cameraSize = [float]([Math]::Max(7, $Width * 0.010))
        $cameraBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 3, 3, 7))
        $layerGraphics.FillEllipse(
            $cameraBrush,
            $padding + (($Width - $cameraSize) / 2),
            $padding + ($topInset * 0.45),
            $cameraSize,
            $cameraSize
        )
        $cameraBrush.Dispose()
    }

    $layerGraphics.Dispose()

    $state = $Graphics.Save()
    $centerX = $X + ($layerWidth / 2)
    $centerY = $Y + ($layerHeight / 2)
    $Graphics.TranslateTransform($centerX, $centerY)
    $Graphics.RotateTransform($Angle)
    $Graphics.TranslateTransform(-$centerX, -$centerY)
    $Graphics.DrawImage($layer, $X, $Y, $layerWidth, $layerHeight)
    $Graphics.Restore($state)
    $layer.Dispose()
}

function Draw-MarketingHeader {
    param(
        [System.Drawing.Graphics]$Graphics,
        [string]$Kicker,
        [string]$Counter,
        [string]$Title,
        [string]$Subtitle,
        [System.Drawing.Font]$KickerFont,
        [System.Drawing.Font]$TitleFont,
        [System.Drawing.Font]$BodyFont,
        [System.Drawing.Color]$PrimaryTextColor,
        [System.Drawing.Color]$SecondaryTextColor,
        [float]$CanvasWidth,
        [float]$Margin,
        [float]$KickerY,
        [float]$TitleY,
        [float]$TitleHeight,
        [float]$SubtitleY,
        [float]$SubtitleHeight
    )

    Fill-Rectangle $Graphics $accent $Margin ($KickerY - 24) 74 8
    Draw-TextBlock $Graphics $Kicker $KickerFont $PrimaryTextColor ([System.Drawing.RectangleF]::new($Margin, $KickerY, $CanvasWidth - ($Margin * 2), 46))
    Draw-TextBlock $Graphics $Counter $KickerFont $SecondaryTextColor ([System.Drawing.RectangleF]::new($Margin, $KickerY, $CanvasWidth - ($Margin * 2), 46)) ([System.Drawing.StringAlignment]::Far)
    Draw-TextBlock $Graphics $Title $TitleFont $PrimaryTextColor ([System.Drawing.RectangleF]::new($Margin, $TitleY, $CanvasWidth - ($Margin * 2), $TitleHeight))
    Draw-TextBlock $Graphics $Subtitle $BodyFont $SecondaryTextColor ([System.Drawing.RectangleF]::new($Margin, $SubtitleY, $CanvasWidth - ($Margin * 2), $SubtitleHeight))
}

$googleDirectory = Join-Path $ProjectRoot 'release_assets\google-play'
$appleDirectory = Join-Path $ProjectRoot 'release_assets\app-store'
$rawDirectory = Join-Path $ProjectRoot 'release_assets\screenshots\android'
$googleTabletDirectory = Join-Path $googleDirectory 'tablet'
New-Item -ItemType Directory -Force -Path $googleDirectory, $appleDirectory, $googleTabletDirectory | Out-Null

# Google requires a 32-bit PNG with alpha; Apple requires an opaque icon.
$logoSource = [System.Drawing.Image]::FromFile((Join-Path $ProjectRoot 'assets\logo_app.png'))
$googleIcon = New-AlphaCanvas 512 512 $primary
$googleIcon.Graphics.DrawImage($logoSource, 0, 0, 512, 512)
$googleIcon.Graphics.Dispose()
$googleIcon.Bitmap.Save((Join-Path $googleDirectory 'icon-512.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$googleIcon.Bitmap.Dispose()

$appleIcon = New-Canvas 1024 1024 $primary
$appleIcon.Graphics.DrawImage($logoSource, 0, 0, 1024, 1024)
$appleIcon.Graphics.Dispose()
$appleIcon.Bitmap.Save((Join-Path $appleDirectory 'app-icon-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$appleIcon.Bitmap.Dispose()
$logoSource.Dispose()

# Google Play feature graphic, 1024 x 500.
$featureCanvas = New-Canvas 1024 500 $primaryDark
$featureGraphics = $featureCanvas.Graphics
Fill-Rectangle $featureGraphics $accent 0 0 14 500
Fill-Rectangle $featureGraphics ([System.Drawing.ColorTranslator]::FromHtml('#202052')) 680 0 344 500
$whiteLogo = [System.Drawing.Image]::FromFile((Join-Path $ProjectRoot 'assets\logo_white_nobg.png'))
$featureGraphics.DrawImage($whiteLogo, 92, 46, 205, 112)
$whiteLogo.Dispose()
$featureTitleFont = [System.Drawing.Font]::new('Segoe UI', 36, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$featureBodyFont = [System.Drawing.Font]::new('Segoe UI', 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
Draw-TextBlock $featureGraphics 'Le Cotentin entreprend.' $featureTitleFont $white ([System.Drawing.RectangleF]::new(92, 205, 555, 56))
Draw-TextBlock $featureGraphics 'Actualités, rencontres et réseau professionnel.' $featureBodyFont ([System.Drawing.Color]::FromArgb(220, 255, 255, 255)) ([System.Drawing.RectangleF]::new(94, 282, 530, 70))
Draw-TextBlock $featureGraphics 'CEC 2026' $featureBodyFont $accent ([System.Drawing.RectangleF]::new(94, 405, 260, 40))
$featureNetwork = [System.Drawing.Image]::FromFile((Join-Path $rawDirectory '04-annuaire.png'))
$featureMeetings = [System.Drawing.Image]::FromFile((Join-Path $rawDirectory '03-reunions.png'))
Draw-DeviceMockup -Graphics $featureGraphics -Image $featureMeetings -X 660 -Y 34 -Width 205 -Height 350 -Angle -5 -Kind 'android'
Draw-DeviceMockup -Graphics $featureGraphics -Image $featureNetwork -X 790 -Y -30 -Width 235 -Height 400 -Angle 4 -Kind 'android'
$featureNetwork.Dispose()
$featureMeetings.Dispose()
$featureTitleFont.Dispose()
$featureBodyFont.Dispose()
$featureGraphics.Dispose()
$featureCanvas.Bitmap.Save((Join-Path $googleDirectory 'feature-graphic-1024x500.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$featureCanvas.Bitmap.Dispose()

$screens = @(
    @{
        Output = '01-actualites'
        Primary = '04-annuaire.png'
        Title = "Votre réseau, en un coup d'œil"
        Subtitle = 'Entreprises, membres et expertises du Cotentin.'
        Single = $true
    },
    @{
        Output = '02-reunions'
        Primary = '03-reunions.png'
        Title = 'Ne manquez aucun rendez-vous'
        Subtitle = 'Retrouvez les réunions à venir et les temps forts passés.'
        Single = $true
    },
    @{
        Output = '03-reunion-detail'
        Primary = '04-reunion-detail.png'
        Secondary = '03-reunions.png'
        Title = 'Chaque rencontre, dans le détail'
        Subtitle = "Date, heure, lieu et ordre du jour : tout est là."
    },
    @{
        Output = '04-annuaire'
        Primary = '06-membres.png'
        Secondary = '05-entreprise.png'
        Title = 'Les bonnes expertises, à portée de main'
        Subtitle = 'Découvrez les professionnels et leurs entreprises.'
    },
    @{
        Output = '05-connexion'
        Primary = '07-connexion.png'
        PrimaryCropTop = 100
        Title = 'Un espace membre, simplement'
        Subtitle = 'Recommandations, remerciements et profil réunis au même endroit.'
        Single = $true
    },
    @{
        Output = '06-informations'
        Primary = '08-informations.png'
        Secondary = 'moderation-report-sheet.png'
        Title = 'Des échanges plus sereins'
        Subtitle = 'Confidentialité, signalement, blocage et assistance accessibles.'
    }
)

$playKickerFont = [System.Drawing.Font]::new('Segoe UI', 21, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$playTitleFont = [System.Drawing.Font]::new('Segoe UI', 55, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$playBodyFont = [System.Drawing.Font]::new('Segoe UI', 29, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$appleKickerFont = [System.Drawing.Font]::new('Segoe UI', 28, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$appleTitleFont = [System.Drawing.Font]::new('Segoe UI', 74, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$appleBodyFont = [System.Drawing.Font]::new('Segoe UI', 39, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

for ($index = 0; $index -lt $screens.Count; $index++) {
    $screen = $screens[$index]
    $isDark = ($index % 2) -eq 0
    $background = if ($isDark) { $primaryDark } else { $surface }
    $primaryTextColor = if ($isDark) { $white } else { $text }
    $secondaryTextColor = if ($isDark) { [System.Drawing.Color]::FromArgb(220, 255, 255, 255) } else { $muted }
    $primaryImage = [System.Drawing.Image]::FromFile((Join-Path $rawDirectory $screen.Primary))
    $secondaryImage = if ($screen.ContainsKey('Secondary')) {
        [System.Drawing.Image]::FromFile((Join-Path $rawDirectory $screen.Secondary))
    }
    else {
        $null
    }
    $primaryCropTop = if ($screen.ContainsKey('PrimaryCropTop')) { $screen.PrimaryCropTop } else { 63 }
    $number = ($index + 1).ToString('00')

    # Google Play phone screenshot.
    $playCanvas = New-Canvas 1080 1920 $background
    if ($isDark) {
        Fill-Rectangle $playCanvas.Graphics $accent 760 0 320 16
    }
    else {
        Fill-Rectangle $playCanvas.Graphics $surfaceAlt 0 1430 1080 490
        Fill-Rectangle $playCanvas.Graphics $primary 1064 0 16 1920
    }
    Draw-MarketingHeader `
        -Graphics $playCanvas.Graphics `
        -Kicker 'CEC 2026' `
        -Counter "$number / 06" `
        -Title $screen.Title `
        -Subtitle $screen.Subtitle `
        -KickerFont $playKickerFont `
        -TitleFont $playTitleFont `
        -BodyFont $playBodyFont `
        -PrimaryTextColor $primaryTextColor `
        -SecondaryTextColor $secondaryTextColor `
        -CanvasWidth 1080 `
        -Margin 64 `
        -KickerY 62 `
        -TitleY 120 `
        -TitleHeight 142 `
        -SubtitleY 280 `
        -SubtitleHeight 88

    if ($screen.ContainsKey('Single')) {
        $angle = if (($index % 4) -eq 0) { -3.2 } else { 3.0 }
        Draw-DeviceMockup -Graphics $playCanvas.Graphics -Image $primaryImage -X 105 -Y 420 -Width 800 -Height 1340 -CropTop $primaryCropTop -Angle $angle -Kind 'android'
    }
    else {
        Draw-DeviceMockup -Graphics $playCanvas.Graphics -Image $secondaryImage -X 18 -Y 665 -Width 610 -Height 1025 -Angle -5.5 -Kind 'android'
        Draw-DeviceMockup -Graphics $playCanvas.Graphics -Image $primaryImage -X 455 -Y 855 -Width 505 -Height 850 -CropTop $primaryCropTop -Angle 5.0 -Kind 'android'
    }

    $playCanvas.Graphics.Dispose()
    $playCanvas.Bitmap.Save((Join-Path $googleDirectory "$($screen.Output)-1080x1920.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $playCanvas.Bitmap.Dispose()

    # App Store iPhone screenshot. The Flutter UI is identical; the device shell is iPhone-specific.
    $appleCanvas = New-Canvas 1290 2796 $background
    if ($isDark) {
        Fill-Rectangle $appleCanvas.Graphics $accent 900 0 390 20
    }
    else {
        Fill-Rectangle $appleCanvas.Graphics $surfaceAlt 0 2050 1290 746
        Fill-Rectangle $appleCanvas.Graphics $primary 1272 0 18 2796
    }
    Draw-MarketingHeader `
        -Graphics $appleCanvas.Graphics `
        -Kicker 'CEC 2026' `
        -Counter "$number / 06" `
        -Title $screen.Title `
        -Subtitle $screen.Subtitle `
        -KickerFont $appleKickerFont `
        -TitleFont $appleTitleFont `
        -BodyFont $appleBodyFont `
        -PrimaryTextColor $primaryTextColor `
        -SecondaryTextColor $secondaryTextColor `
        -CanvasWidth 1290 `
        -Margin 88 `
        -KickerY 88 `
        -TitleY 175 `
        -TitleHeight 220 `
        -SubtitleY 430 `
        -SubtitleHeight 130

    if ($screen.ContainsKey('Single')) {
        $angle = if (($index % 4) -eq 0) { -3.0 } else { 2.8 }
        Draw-DeviceMockup -Graphics $appleCanvas.Graphics -Image $primaryImage -X 126 -Y 650 -Width 930 -Height 1560 -CropTop $primaryCropTop -Angle $angle -Kind 'iphone'
    }
    else {
        Draw-DeviceMockup -Graphics $appleCanvas.Graphics -Image $secondaryImage -X 14 -Y 900 -Width 770 -Height 1290 -Angle -5.0 -Kind 'iphone'
        Draw-DeviceMockup -Graphics $appleCanvas.Graphics -Image $primaryImage -X 515 -Y 1200 -Width 655 -Height 1100 -CropTop $primaryCropTop -Angle 4.8 -Kind 'iphone'
    }

    $appleCanvas.Graphics.Dispose()
    $appleCanvas.Bitmap.Save((Join-Path $appleDirectory "$($screen.Output)-1290x2796.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $appleCanvas.Bitmap.Dispose()

    $primaryImage.Dispose()
    if ($null -ne $secondaryImage) {
        $secondaryImage.Dispose()
    }
}

$playKickerFont.Dispose()
$playTitleFont.Dispose()
$playBodyFont.Dispose()
$appleKickerFont.Dispose()
$appleTitleFont.Dispose()
$appleBodyFont.Dispose()

if (-not $IncludeTablets) {
    Write-Host "Phone store assets generated in $googleDirectory and $appleDirectory"
    return
}

$tabletScreens = @(
    @{ File = 'tablet-03-annuaire.png'; Output = '01-actualites'; Title = 'Tout le réseau sur grand écran'; Subtitle = 'Entreprises et expertises sont faciles à identifier.' },
    @{ File = 'tablet-02-reunions.png'; Output = '02-reunions'; Title = "L'agenda, pensé pour être parcouru"; Subtitle = 'Rendez-vous à venir et archives restent immédiatement accessibles.' },
    @{ File = 'tablet-04-membres.png'; Output = '03-annuaire'; Title = 'Les membres du Cotentin'; Subtitle = 'Retrouvez les personnes qui font vivre le réseau.' },
    @{ File = 'tablet-04-connexion.png'; Output = '04-connexion'; Title = 'Votre espace membre, partout'; Subtitle = 'Retrouvez vos échanges professionnels depuis votre tablette.'; CropTop = 100 }
)

$ipadKickerFont = [System.Drawing.Font]::new('Segoe UI', 31, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$ipadTitleFont = [System.Drawing.Font]::new('Segoe UI', 72, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$ipadBodyFont = [System.Drawing.Font]::new('Segoe UI', 39, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

for ($index = 0; $index -lt $tabletScreens.Count; $index++) {
    $screen = $tabletScreens[$index]
    $isDark = ($index % 2) -eq 0
    $background = if ($isDark) { $primaryDark } else { $surface }
    $primaryTextColor = if ($isDark) { $white } else { $text }
    $secondaryTextColor = if ($isDark) { [System.Drawing.Color]::FromArgb(220, 255, 255, 255) } else { $muted }
    $source = [System.Drawing.Image]::FromFile((Join-Path $rawDirectory $screen.File))
    $cropTop = if ($screen.ContainsKey('CropTop')) { $screen.CropTop } else { 50 }
    $number = ($index + 1).ToString('00')

    # Google asks large-screen screenshots to stay focused on the app UI itself.
    $tabletCanvas = New-Canvas 1600 2560 $surface
    $tabletCanvas.Graphics.DrawImage($source, 0, 0, 1600, 2560)
    $tabletCanvas.Graphics.Dispose()
    $tabletCanvas.Bitmap.Save((Join-Path $googleTabletDirectory "$($screen.Output)-1600x2560.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $tabletCanvas.Bitmap.Dispose()

    $ipadCanvas = New-Canvas 2048 2732 $background
    if ($isDark) {
        Fill-Rectangle $ipadCanvas.Graphics $accent 1450 0 598 20
    }
    else {
        Fill-Rectangle $ipadCanvas.Graphics $surfaceAlt 0 2110 2048 622
        Fill-Rectangle $ipadCanvas.Graphics $primary 2028 0 20 2732
    }
    Draw-MarketingHeader `
        -Graphics $ipadCanvas.Graphics `
        -Kicker 'CEC 2026 · IPAD' `
        -Counter "$number / 04" `
        -Title $screen.Title `
        -Subtitle $screen.Subtitle `
        -KickerFont $ipadKickerFont `
        -TitleFont $ipadTitleFont `
        -BodyFont $ipadBodyFont `
        -PrimaryTextColor $primaryTextColor `
        -SecondaryTextColor $secondaryTextColor `
        -CanvasWidth 2048 `
        -Margin 138 `
        -KickerY 70 `
        -TitleY 142 `
        -TitleHeight 118 `
        -SubtitleY 280 `
        -SubtitleHeight 78
    Draw-DeviceMockup -Graphics $ipadCanvas.Graphics -Image $source -X 72 -Y 390 -Width 1620 -Height 2160 -CropTop $cropTop -CropBottom 60 -Angle $(if ($isDark) { -0.8 } else { 0.8 }) -Kind 'tablet'
    $ipadCanvas.Graphics.Dispose()
    $ipadCanvas.Bitmap.Save((Join-Path $appleDirectory "ipad-$($screen.Output)-2048x2732.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $ipadCanvas.Bitmap.Dispose()

    $source.Dispose()
}

$ipadKickerFont.Dispose()
$ipadTitleFont.Dispose()
$ipadBodyFont.Dispose()

Write-Host "Premium store assets generated in $googleDirectory and $appleDirectory"
