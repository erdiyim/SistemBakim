# ================================================================
#
#   SistemBakim v5.0 — Windows Application Builder
#
#   Iki adet Windows uygulamasi (EXE) olusturur:
#
#     SistemBakim.exe       Grafik arayuz (GUI) pencere uygulamasi
#                           Konsol penceresi YOKTUR — tamamen gorsel
#                           Backend gomulu, tek dosya yeterli
#
#     SistemBakim_CLI.exe   Komut satiri (CLI) konsol uygulamasi
#                           Klasik metin tabanli menu
#
#   Kullanim    : PowerShell'de src/ klasorunde calistirin
#   Gereksinim  : PowerShell 5.1+, internet (ilk sefer ps2exe icin)
#   Cikti       : bin/ klasorune iki EXE
#
#   Klasor Yapisi:
#     SistemBakim/
#       src/        Build-EXE.ps1, SistemBakim_GUI.ps1, SistemBakim_v5.ps1
#       bin/        SistemBakim.exe, SistemBakim_CLI.exe
#       archive/    Eski yedek EXE dosyalari
#       tests/      Test scriptleri
#       docs/       Dokumantasyon
#
# ================================================================

$ErrorActionPreference = "Stop"

# ── Dosya Yollari ──────────────────────────────────────────────
$srcDir      = Split-Path $MyInvocation.MyCommand.Path
$rootDir     = Split-Path $srcDir
$binDir      = Join-Path $rootDir "bin"
$archiveDir  = Join-Path $rootDir "archive"
$v5File      = Join-Path $srcDir "SistemBakim_v5.ps1"
$guiFile     = Join-Path $srcDir "SistemBakim_GUI.ps1"
$outGUI      = Join-Path $binDir "SistemBakim.exe"
$outCLI      = Join-Path $binDir "SistemBakim_CLI.exe"
$mergedFile  = Join-Path $srcDir "_Merged_GUI_temp.ps1"
$icoFile     = Join-Path $srcDir "sistem.ico"
$versiyon    = "5.0.0.0"

# ── Cikti klasorlerini olustur ────────────────────────────────
if (-not (Test-Path $binDir))     { New-Item -ItemType Directory -Path $binDir     -Force | Out-Null }
if (-not (Test-Path $archiveDir)) { New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null }

# ── Banner ─────────────────────────────────────────────────────
Clear-Host
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host "    SistemBakim v5.0 — Windows Application Builder" -ForegroundColor Cyan
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Iki Windows uygulamasi olusturulacak:" -ForegroundColor Gray
Write-Host "    1) SistemBakim.exe      — GUI (pencere, konsol yok)" -ForegroundColor White
Write-Host "    2) SistemBakim_CLI.exe  — CLI (konsol menusu)" -ForegroundColor White
Write-Host ""

# ── Kaynak Dosya Kontrol ──────────────────────────────────────
$eksik = $false
foreach ($f in @($v5File, $guiFile)) {
    if (-not (Test-Path $f)) {
        Write-Host ("  HATA: " + (Split-Path $f -Leaf) + " bulunamadi!") -ForegroundColor Red
        $eksik = $true
    } else {
        Write-Host ("  Kaynak : " + (Split-Path $f -Leaf)) -ForegroundColor DarkGray
    }
}
if ($eksik) {
    Write-Host ""
    Write-Host "  Build-EXE.ps1, SistemBakim_v5.ps1 ve SistemBakim_GUI.ps1" -ForegroundColor Yellow
    Write-Host "  src/ klasorunde olmalidir." -ForegroundColor Yellow
    Read-Host "  Cikis icin Enter"
    exit 1
}
Write-Host ""

# ── ps2exe Modul Kontrolu ─────────────────────────────────────
$modulVar = Get-Module -ListAvailable -Name ps2exe -ErrorAction SilentlyContinue
if (-not $modulVar) {
    Write-Host "  ps2exe modulu bulunamadi, kuruluyor..." -ForegroundColor Yellow
    try {
        Install-Module -Name ps2exe -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
        Write-Host "  ps2exe basariyla kuruldu." -ForegroundColor Green
    } catch {
        Write-Host "  HATA: ps2exe kurulamadi: $_" -ForegroundColor Red
        Write-Host "  Manuel: Install-Module ps2exe -Scope CurrentUser -Force" -ForegroundColor Yellow
        Read-Host "  Cikis icin Enter"
        exit 1
    }
    Write-Host ""
}
Import-Module ps2exe -Force -ErrorAction Stop


# ════════════════════════════════════════════════════════════════
#   ADIM 1 / 5 :  Backend Sikistirma (GZip + Base64)
# ════════════════════════════════════════════════════════════════
Write-Host "  [1/5]  Backend sikistiriliyor..." -ForegroundColor Cyan

$v5Bytes   = [System.IO.File]::ReadAllBytes($v5File)
$memStream = [System.IO.MemoryStream]::new()
$gzStream  = [System.IO.Compression.GZipStream]::new(
                 $memStream, [System.IO.Compression.CompressionMode]::Compress)
$gzStream.Write($v5Bytes, 0, $v5Bytes.Length)
$gzStream.Close()
$compBytes = $memStream.ToArray()
$v5B64     = [Convert]::ToBase64String($compBytes)
$memStream.Dispose()

$orijKB = [Math]::Round($v5Bytes.Length / 1KB, 0)
$sikKB  = [Math]::Round($compBytes.Length / 1KB, 0)
$kazanc = [Math]::Round(100 - ($compBytes.Length / $v5Bytes.Length * 100), 0)
Write-Host ("         Orijinal    : {0} KB" -f $orijKB) -ForegroundColor DarkGray
Write-Host ("         Sikistirilmis: {0} KB  (-%{1})" -f $sikKB, $kazanc) -ForegroundColor DarkGray


# ════════════════════════════════════════════════════════════════
#   ADIM 2 / 5 :  GUI Scriptini Isle
#   STA/Admin bloklarini kaldir (ps2exe halleder)
#   $BACKEND yolunu temp extraction ile degistir
# ════════════════════════════════════════════════════════════════
Write-Host "  [2/5]  GUI scripti isleniyor..." -ForegroundColor Cyan

$guiLines  = [System.IO.File]::ReadAllLines($guiFile, [System.Text.Encoding]::UTF8)
$processed = [System.Collections.Generic.List[string]]::new()
$blokAtla  = $false

for ($i = 0; $i -lt $guiLines.Count; $i++) {
    $line = $guiLines[$i]

    # ── STA ve Admin kontrol bloklarini atla ──
    # ps2exe -STA ve -requireAdmin parametreleri bunlari yonetiyor
    if ($line -match '^\s*#\s*STA kontrolu' -or $line -match '^\s*#\s*Yonetici kontrolu') {
        $blokAtla = $true
        continue
    }
    if ($blokAtla) {
        if ($line -match '^\s*\}\s*$') { $blokAtla = $false }
        continue
    }

    # ── $KLASOR / $script:KLASOR / $global:KLASOR satirini degistir (ps2exe uyumlu) ──
    if ($line -match '^\s*\$(script:|global:)?KLASOR\s*=') {
        $processed.Add('$global:KLASOR = Split-Path ([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName)')
        continue
    }

    # ── $BACKEND / $script:BACKEND / $global:BACKEND satirini degistir (temp dosyaya yonlendir) ──
    if ($line -match '^\s*\$(script:|global:)?BACKEND\s*=') {
        $processed.Add('$global:BACKEND = Join-Path $env:TEMP "SistemBakim_v5_runtime.ps1"')
        continue
    }

    # ── Modul sayisi duzelt ──
    if ($line -match '40 modul') {
        $line = $line -replace '40 modul', '69 modul'
    }

    $processed.Add($line)
}

Write-Host ("         {0} satir okundu, {1} satir cikti" -f $guiLines.Count, $processed.Count) -ForegroundColor DarkGray


# ════════════════════════════════════════════════════════════════
#   ADIM 3 / 5 :  Birlesik Script Olustur
#   Backend (v5.ps1) GZip+Base64 olarak gomulu
#   Calistirildiginda temp dosyaya cikarilir
# ════════════════════════════════════════════════════════════════
Write-Host "  [3/5]  Birlesik script olusturuluyor..." -ForegroundColor Cyan

$sb = [System.Text.StringBuilder]::new(512KB)

# ── Dosya Baslik ──
[void]$sb.AppendLine("# ================================================================")
[void]$sb.AppendLine("#   SistemBakim v5.0 - Merged Windows Application")
[void]$sb.AppendLine("#   Build-EXE.ps1 tarafindan otomatik olusturuldu")
[void]$sb.AppendLine(("#   Tarih: " + (Get-Date -Format "yyyy-MM-dd HH:mm")))
[void]$sb.AppendLine("#   ELLE DUZENLENMEYIN - degisiklikleri kaynak .ps1'lerde yapin")
[void]$sb.AppendLine("# ================================================================")
[void]$sb.AppendLine("")

# ── Gomulu Backend: Base64 + GZip ──
[void]$sb.AppendLine("# ── GOMULU BACKEND ─────────────────────────────────────────────")
[void]$sb.AppendLine("# SistemBakim_v5.ps1 icerigi GZip ile sikistirilip Base64 olarak")
[void]$sb.AppendLine("# gomulmustur. Calistirildiginda %TEMP% klasorune cikarilir.")
[void]$sb.AppendLine("")
[void]$sb.AppendLine('$__B64 = @' + "'")

# Base64 stringi 120 karakter satirlara bol (okunabilirlik)
for ($pos = 0; $pos -lt $v5B64.Length; $pos += 120) {
    $kalan = $v5B64.Length - $pos
    $uzunluk = if ($kalan -lt 120) { $kalan } else { 120 }
    [void]$sb.AppendLine($v5B64.Substring($pos, $uzunluk))
}
[void]$sb.AppendLine("'@")
[void]$sb.AppendLine("")

# ── Extraction Kodu ──
[void]$sb.AppendLine('$__bytes  = [Convert]::FromBase64String($__B64)')
[void]$sb.AppendLine('$__ms     = [System.IO.MemoryStream]::new($__bytes)')
[void]$sb.AppendLine('$__gz     = [System.IO.Compression.GZipStream]::new($__ms, [System.IO.Compression.CompressionMode]::Decompress)')
[void]$sb.AppendLine('$__reader = [System.IO.StreamReader]::new($__gz, [System.Text.Encoding]::UTF8)')
[void]$sb.AppendLine('$__content = $__reader.ReadToEnd()')
[void]$sb.AppendLine('$__reader.Close(); $__ms.Dispose()')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('$__tempPath = Join-Path $env:TEMP "SistemBakim_v5_runtime.ps1"')
[void]$sb.AppendLine('[System.IO.File]::WriteAllText($__tempPath, $__content, (New-Object System.Text.UTF8Encoding $true))')
[void]$sb.AppendLine('Remove-Variable __B64, __bytes, __ms, __gz, __reader, __content -ErrorAction SilentlyContinue')
[void]$sb.AppendLine('')

# ── Islenmis GUI Kodu ──
[void]$sb.AppendLine("# ── GUI KODU ───────────────────────────────────────────────────")
foreach ($line in $processed) {
    [void]$sb.AppendLine($line)
}

# ── Cleanup: ShowDialog'dan sonra temp dosyayi sil ──
[void]$sb.AppendLine("")
[void]$sb.AppendLine("# ── CLEANUP ────────────────────────────────────────────────────")
[void]$sb.AppendLine('$__cleanPath = Join-Path $env:TEMP "SistemBakim_v5_runtime.ps1"')
[void]$sb.AppendLine('if (Test-Path $__cleanPath) { Remove-Item $__cleanPath -Force -ErrorAction SilentlyContinue }')

# ── Dosyaya Yaz (UTF-8 BOM) ──
[System.IO.File]::WriteAllText(
    $mergedFile,
    $sb.ToString(),
    (New-Object System.Text.UTF8Encoding $true)
)

$mergedKB = [Math]::Round((Get-Item $mergedFile).Length / 1KB, 0)
Write-Host ("         Birlesik script: {0} KB" -f $mergedKB) -ForegroundColor DarkGray


# ════════════════════════════════════════════════════════════════
#   ADIM 4 / 5 :  GUI EXE Derleme
#   -noConsole  : Siyah konsol penceresi gosterme (pencere uygulamasi)
#   -STA        : WPF icin Single Thread Apartment
#   -requireAdmin: Otomatik yonetici yetkisi iste (UAC)
# ════════════════════════════════════════════════════════════════
Write-Host "  [4/5]  GUI EXE derleniyor..." -ForegroundColor Cyan

# Mevcut EXE'leri archive/ klasorune yedekle
foreach ($exeYol in @($outGUI, $outCLI)) {
    if (Test-Path $exeYol) {
        $exeAd   = [System.IO.Path]::GetFileNameWithoutExtension($exeYol)
        $yedekAd = "{0}_yedek_{1}.exe" -f $exeAd, (Get-Date -Format "yyyyMMdd_HHmm")
        $yedekYol = Join-Path $archiveDir $yedekAd
        Move-Item -Path $exeYol -Destination $yedekYol -Force
        Write-Host ("         Yedeklendi: archive\" + $yedekAd) -ForegroundColor DarkGray
    }
}

try {
    $ps2exeParams = @{
        inputFile    = $mergedFile
        outputFile   = $outGUI
        noConsole    = $true
        STA          = $true
        requireAdmin = $true
        title        = "Sistem Bakim Araci"
        description  = "Windows Performans, Temizlik ve Oyun Optimizasyon Araci - 69 Modul"
        company      = "Erdi"
        product      = "SistemBakim"
        version      = $versiyon
        copyright    = "2025 Erdi"
    }
    if (Test-Path $icoFile) { $ps2exeParams["iconFile"] = $icoFile }
    Invoke-ps2exe @ps2exeParams

    if (Test-Path $outGUI) {
        $guiMB = [Math]::Round((Get-Item $outGUI).Length / 1MB, 2)
        Write-Host ("         TAMAM — SistemBakim.exe ({0} MB)" -f $guiMB) -ForegroundColor Green
    } else {
        Write-Host "         UYARI: EXE dosyasi olusturulamadi" -ForegroundColor Yellow
    }
} catch {
    Write-Host ("         HATA: " + $_.Exception.Message) -ForegroundColor Red
}


# ════════════════════════════════════════════════════════════════
#   ADIM 5 / 5 :  CLI EXE Derleme
#   Konsol uygulamasi — klasik metin tabanli menu
# ════════════════════════════════════════════════════════════════
Write-Host "  [5/5]  CLI EXE derleniyor..." -ForegroundColor Cyan

try {
    $ps2exeParamsCLI = @{
        inputFile    = $v5File
        outputFile   = $outCLI
        requireAdmin = $true
        title        = "Sistem Bakim Araci - CLI"
        description  = "Windows Performans, Temizlik ve Oyun Optimizasyon Araci - 69 Modul - Konsol"
        company      = "Erdi"
        product      = "SistemBakim CLI"
        version      = $versiyon
        copyright    = "2025 Erdi"
    }
    if (Test-Path $icoFile) { $ps2exeParamsCLI["iconFile"] = $icoFile }
    Invoke-ps2exe @ps2exeParamsCLI

    if (Test-Path $outCLI) {
        $cliMB = [Math]::Round((Get-Item $outCLI).Length / 1MB, 2)
        Write-Host ("         TAMAM — SistemBakim_CLI.exe ({0} MB)" -f $cliMB) -ForegroundColor Green
    } else {
        Write-Host "         UYARI: EXE dosyasi olusturulamadi" -ForegroundColor Yellow
    }
} catch {
    Write-Host ("         HATA: " + $_.Exception.Message) -ForegroundColor Red
}

# ── Temp birlesik dosyayi sil ──
Remove-Item $mergedFile -Force -ErrorAction SilentlyContinue


# ════════════════════════════════════════════════════════════════
#   SONUC RAPORU
# ════════════════════════════════════════════════════════════════
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host "    BUILD TAMAMLANDI" -ForegroundColor Green
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""

if (Test-Path $outGUI) {
    $boyMB = [Math]::Round((Get-Item $outGUI).Length / 1MB, 2)
    $boyKB = [Math]::Round((Get-Item $outGUI).Length / 1KB, 0)
    $boyStr = if ($boyMB -ge 1) { "$boyMB MB" } else { "$boyKB KB" }
    Write-Host "  GUI UYGULAMA — bin\SistemBakim.exe" -ForegroundColor Cyan
    Write-Host ("    Boyut    : " + $boyStr) -ForegroundColor White
    Write-Host ("    Versiyon : " + $versiyon) -ForegroundColor White
    Write-Host "    Tip      : Windows pencere uygulamasi" -ForegroundColor Gray
    Write-Host "    Konsol   : YOK (siyah pencere gormezsiniz)" -ForegroundColor Gray
    Write-Host "    Modul    : 69 modul GOMULU" -ForegroundColor Gray
    Write-Host "    Kullanim : Cift tikla > UAC onayla > GUI acilir" -ForegroundColor Gray
    Write-Host "    Bagimlilik: YOK — tek EXE dosyasi yeterli" -ForegroundColor Gray
    Write-Host ""
}

if (Test-Path $outCLI) {
    $boyMB = [Math]::Round((Get-Item $outCLI).Length / 1MB, 2)
    $boyKB = [Math]::Round((Get-Item $outCLI).Length / 1KB, 0)
    $boyStr = if ($boyMB -ge 1) { "$boyMB MB" } else { "$boyKB KB" }
    Write-Host "  CLI UYGULAMA — bin\SistemBakim_CLI.exe" -ForegroundColor Cyan
    Write-Host ("    Boyut    : " + $boyStr) -ForegroundColor White
    Write-Host ("    Versiyon : " + $versiyon) -ForegroundColor White
    Write-Host "    Tip      : Konsol uygulamasi" -ForegroundColor Gray
    Write-Host "    Kullanim : Cift tikla > UAC onayla > menu acilir" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "  KLASOR YAPISI:" -ForegroundColor Yellow
Write-Host "    src/       Kaynak kodlar (.ps1)" -ForegroundColor Gray
Write-Host "    bin/       Calistirilabilir EXE dosyalari" -ForegroundColor Gray
Write-Host "    archive/   Eski EXE yedekleri" -ForegroundColor Gray
Write-Host ""
Write-Host "  DAGITIM:" -ForegroundColor Yellow
Write-Host "    bin\ klasorundeki EXE dosyasini kopyalayin, paylassin." -ForegroundColor Gray
Write-Host "    Kullanicinin PowerShell bilgisi gerekmez." -ForegroundColor Gray
Write-Host "    Tek dosya yeterli — ek script/DLL gerekmez." -ForegroundColor Gray
Write-Host ""
Write-Host "  NOT:" -ForegroundColor Yellow
Write-Host "    Ilk calistirmada Windows SmartScreen uyarisi verebilir." -ForegroundColor Gray
Write-Host "    'Daha fazla bilgi' > 'Yine de calistir' tiklayin." -ForegroundColor Gray
Write-Host ""
Read-Host "  Cikis icin Enter"
