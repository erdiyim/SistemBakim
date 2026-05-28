# ================================================================
#  SistemBakim v5.0.0 - Release Pipeline
#  Uctan uca: Kaynak > EXE > Setup.exe
#
#  Kullanim: PowerShell -ExecutionPolicy Bypass -File Release-Pipeline.ps1
#  NOT: Yonetici olarak calistirin (Inno Setup kurulumu icin gerekebilir)
# ================================================================

$ErrorActionPreference = "Stop"
$root = Split-Path $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "  ========================================================" -ForegroundColor Cyan
Write-Host "    SistemBakim v5.0.0 - Release Pipeline" -ForegroundColor Cyan
Write-Host "    Kaynak > EXE > Setup.exe" -ForegroundColor Cyan
Write-Host "  ========================================================" -ForegroundColor Cyan
Write-Host ""

# ----------------------------------------------------------------
#  ADIM 0: On kosullar
# ----------------------------------------------------------------
Write-Host "  [0/3] On kosullar kontrol ediliyor..." -ForegroundColor Yellow

# ps2exe modulu
if (-not (Get-Module -ListAvailable ps2exe)) {
    Write-Host "        ps2exe kurulu degil - kuruluyor..." -ForegroundColor DarkGray
    Install-Module ps2exe -Scope CurrentUser -Force
}
Write-Host "        ps2exe: OK" -ForegroundColor Green

# Inno Setup ISCC.exe
$isccPaths = @(
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe",
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe"
)
$iscc = $null
foreach ($p in $isccPaths) {
    if (Test-Path $p) { $iscc = $p; break }
}

if (-not $iscc) {
    Write-Host "        Inno Setup 6 bulunamadi - winget ile kuruluyor..." -ForegroundColor DarkGray
    try {
        winget install JRSoftware.InnoSetup --silent --accept-package-agreements --accept-source-agreements
        Start-Sleep -Seconds 5
        foreach ($p in $isccPaths) {
            if (Test-Path $p) { $iscc = $p; break }
        }
    }
    catch {
        Write-Host "        winget basarisiz, chocolatey deneniyor..." -ForegroundColor DarkGray
        choco install innosetup -y --no-progress
        Start-Sleep -Seconds 5
        foreach ($p in $isccPaths) {
            if (Test-Path $p) { $iscc = $p; break }
        }
    }

    if (-not $iscc) {
        Write-Host ""
        Write-Host "  HATA: Inno Setup 6 kurulamadi!" -ForegroundColor Red
        Write-Host "  Manuel kurulum: https://jrsoftware.org/isdl.php" -ForegroundColor Yellow
        Write-Host "  Kurduktan sonra bu scripti tekrar calistirin." -ForegroundColor Yellow
        exit 1
    }
}
Write-Host "        ISCC.exe: $iscc" -ForegroundColor Green

# Kaynak dosyalar
$guiSrc  = Join-Path $root "src\SistemBakim_GUI.ps1"
$backSrc = Join-Path $root "src\SistemBakim_v5.ps1"
$icoFile = Join-Path $root "src\sistem.ico"
$issFile = Join-Path $root "installer\SistemBakim_Setup.iss"

foreach ($f in @($guiSrc, $backSrc, $icoFile, $issFile)) {
    if (-not (Test-Path $f)) {
        Write-Host "  HATA: Dosya bulunamadi - $f" -ForegroundColor Red
        exit 1
    }
}
Write-Host "        Kaynak dosyalar: OK" -ForegroundColor Green
Write-Host ""

# ----------------------------------------------------------------
#  ADIM 1: PowerShell > EXE (Build-EXE.ps1)
# ----------------------------------------------------------------
Write-Host "  [1/3] PowerShell kaynak > EXE derleniyor..." -ForegroundColor Yellow

$buildScript = Join-Path $root "src\Build-EXE.ps1"
if (-not (Test-Path $buildScript)) {
    Write-Host "  HATA: Build-EXE.ps1 bulunamadi!" -ForegroundColor Red
    exit 1
}

& PowerShell -NoProfile -ExecutionPolicy Bypass -File $buildScript

# Sonuc kontrolu
$guiExe = Join-Path $root "bin\SistemBakim.exe"
$cliExe = Join-Path $root "bin\SistemBakim_CLI.exe"

if (-not (Test-Path $guiExe)) {
    Write-Host "  HATA: SistemBakim.exe olusturulamadi!" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $cliExe)) {
    Write-Host "  HATA: SistemBakim_CLI.exe olusturulamadi!" -ForegroundColor Red
    exit 1
}

$guiKB = [Math]::Round((Get-Item $guiExe).Length / 1KB)
$cliKB = [Math]::Round((Get-Item $cliExe).Length / 1KB)
Write-Host "        SistemBakim.exe     : $guiKB KB" -ForegroundColor Green
Write-Host "        SistemBakim_CLI.exe : $cliKB KB" -ForegroundColor Green
Write-Host ""

# ----------------------------------------------------------------
#  ADIM 2: EXE > Setup.exe (Inno Setup)
# ----------------------------------------------------------------
Write-Host "  [2/3] Inno Setup ile kurulum paketi olusturuluyor..." -ForegroundColor Yellow

$outputDir = Join-Path $root "installer\output"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# ISCC.exe calistir
& $iscc $issFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "  HATA: Inno Setup derleme basarisiz! (exit code: $LASTEXITCODE)" -ForegroundColor Red
    exit 1
}

$setupExe = Join-Path $outputDir "SistemBakim_v5.0.0_Setup.exe"
if (-not (Test-Path $setupExe)) {
    Write-Host "  HATA: Setup EXE olusturulamadi!" -ForegroundColor Red
    exit 1
}

$setupMB = [Math]::Round((Get-Item $setupExe).Length / 1MB, 2)
Write-Host "        SistemBakim_v5.0.0_Setup.exe : $setupMB MB" -ForegroundColor Green
Write-Host ""

# ----------------------------------------------------------------
#  ADIM 3: Ozet
# ----------------------------------------------------------------
Write-Host "  [3/3] Release paketi hazir!" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ========================================================" -ForegroundColor Green
Write-Host "    RELEASE HAZIR" -ForegroundColor Green
Write-Host "  ========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "    Setup EXE : $setupExe" -ForegroundColor White
Write-Host "    Boyut     : $setupMB MB" -ForegroundColor White
Write-Host ""
Write-Host "    Sonraki adim:" -ForegroundColor Yellow
Write-Host "    GitHub Releases > v5.0.0 > Attach binaries >" -ForegroundColor Yellow
Write-Host "    Bu dosyayi surukle-birak > Publish release" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ========================================================" -ForegroundColor Green
Write-Host ""

# Setup dosyasini Explorer'da goster
$explorerArg = "/select,`"$setupExe`""
Start-Process explorer.exe -ArgumentList $explorerArg
