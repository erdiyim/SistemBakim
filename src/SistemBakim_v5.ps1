# ================================================================
#
#   ███████╗██╗███████╗████████╗███████╗███╗   ███╗
#   ██╔════╝██║██╔════╝╚══██╔══╝██╔════╝████╗ ████║
#   ███████╗██║███████╗   ██║   █████╗  ██╔████╔██║
#   ╚════██║██║╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
#   ███████║██║███████║   ██║   ███████╗██║ ╚═╝ ██║
#   ╚══════╝╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝
#
#   B A K I M   A R A C I   v5.0
#   Windows Performans · Alan · Saglik · Guvenlik · Gelistirici
#
#   Yazar   : Erdi (araç fikri) + Claude / Anthropic (kod)
#   Surum   : 5.0  —  "Devrim Sürümü"
#   Lisans  : Kisisel ve ticari olmayan kullanim serbesttir.
#   GitHub  : github.com/[kullanicin]
#
#   Gereksinim : PowerShell 5.1+  |  Yönetici yetkisi önerilir
#   Test       : Windows 10 / 11
#
# ================================================================
#
#   MODÜLLER
#   ─────────────────────────────────────────────────────────────
#   TEMIZLIK  1  Disk Analizi (buyuk/bos/Windows.old/hiberfil)
#             2  Yinelenen Dosyalar (MD5 hash)
#             3  Kapsamli Temizlik (19 konum)
#             4  SMART Disk Sagligi
#             5  Crash Dump & WER Temizligi
#             6  Shadow Copy & Restore Yonetimi
#             7  Windows Log Temizligi
#             8  Downloads Analizi
#   SAGLIK    9  Sistem Tarama (SFC/DISM/ChkDsk)
#            10  Olay Gunlugu Analizi (BSOD dahil)
#            11  Servis Kontrolu (20 servis)
#   PERFORMANS 12 Baslangic Analizi
#            13  Kaynak Durumu (RAM/CPU/GPU)
#            14  Guc Plani Optimizasyonu
#   AG       15  Ag Tanilamasi (DNS/ping/Winsock)
#   GUVENLIK 16  Guvenlik Kontrolu (FW/AV/Driver)
#            17  Gelismis Guvenlik (Hosts/Port/RDP/BitLocker)
#   GELISTIRICI 18 Gelistirici Araclari (node/git/Docker/WSL)
#   DONANIM  19  Donanim Raporu (BIOS/USB/Guc/Thermal)
#   RAPOR    20  HTML Dashboard Olustur
#   SKOR     21  Sistem Saglik Skoru (100 puan)
#   OTOMASYON 22 Haftalık Bakimi Zamanla
#   PROFIL   23  Hazir Profil (Oyun/Haftalık/Hizli)
#   GENEL    24  Geri Yukleme Noktasi
#            25  TAM BAKIM (tum moduller)
#   OYUN     26  FPS ve Oyun Optimizasyonu (GameDVR/MMCSS/Nagle/HAGS/Fare/GPU)
#            27  RAM Optimizasyonu (Standby + Working Set, before/after)
#            28  Surec Temizleyici (arka plan oyun dusmani islemi kapat)
#   SISTEM   29  Bloatware Kaldirici (Xbox/Cortana/Eglence/Servis uygulamalari)
#   YENI     41  Format Sonrasi Sihirbaz (tek tikla tum optimizasyonlar)
#            42  Windows Performans Tweakleri (transparency/anim/telemetri)
#            43  Sanal Bellek Optimize (pagefile RAM ayari)
#            44  Donanim Skoru & Oneri (PC siniflandir ve oner)
#   GPU      45  GPU Optimize (NVIDIA registry/servis/shader + AMD tweakler)
#   DEFENDER 46  Defender Oyun Istisnalari (oyun klasorlerini tara)
#   MONITOR  47  Monitor Hz & Cozunurluk (yenileme hizi, DPI)
#   HYPERV   48  Hyper-V / VBS / HVCI Kapat (oyun performansi)
#   BROWSER  49  Tarayici Temizleyici (Chrome/Edge/Firefox/Opera/Brave)
#   OEM      50  OEM Bloatware Tespiti (HP/Dell/Lenovo/Asus/Acer/MSI)
#   BOOT     51  Boot Suresi Analizi (baslangic hizi ve iyilestirme)
#   CTXMENU  52  Sag Tik Menu Temizle (Win11 klasik menu, shell ext)
#   DNS      53  DNS Benchmark (12 sunucu test et, en hizliyi uygula)
#             0  Cikis
# ================================================================

#region ── YÖNETİCİ OTO-YÜKSELTMESİ ────────────────────────

$_yonetici = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $_yonetici.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arguman = if ($PSCommandPath) {
        "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    } else {
        "-NoProfile -ExecutionPolicy Bypass"
    }
    Start-Process -FilePath "PowerShell.exe" -ArgumentList $arguman -Verb RunAs
    exit
}

#endregion

#region ── GENEL KURULUM ─────────────────────────────────────

Set-StrictMode -Version Latest
$ErrorActionPreference = "SilentlyContinue"

$SURUM        = "5.0"
$GITHUB_REPO  = "erdi/SistemBakim"   # GitHub kullanici/repo — yayinda guncelle
$LOG_KLASOR   = "$env:USERPROFILE\Desktop\BakimRaporlari"
$LOG_DOSYA    = Join-Path $LOG_KLASOR ("Bakim_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmm"))
$HTML_RAPOR   = Join-Path $LOG_KLASOR ("Rapor_{0}.html" -f (Get-Date -Format "yyyyMMdd_HHmm"))
$SKOR_DOSYA   = Join-Path $LOG_KLASOR "skor_gecmis.json"
$BUYUK_ESIK   = 100MB
$DUP_MIN      = 5MB
$BOX_EN       = 64

# Global skor bileşenleri (HTML raporu için biriktirilir)
$global:SkorBilesenleri = @{}
$global:RaporVerisi     = @{}
$global:BaslangicZamani = Get-Date
$global:UpdateJob           = $null
$global:SonCalistirilanlar  = [System.Collections.Generic.List[string]]::new()

if (-not (Test-Path $LOG_KLASOR)) { New-Item -ItemType Directory -Path $LOG_KLASOR | Out-Null }

# Arka planda surum kontrolu baslatiliyor (non-blocking)
$global:UpdateJob = Start-Job -ScriptBlock {
    param($repo, $surum)
    try {
        $wr = [System.Net.WebRequest]::Create("https://api.github.com/repos/$repo/releases/latest")
        $wr.Method  = "GET"
        $wr.Timeout = 6000
        $wr.Headers.Add("User-Agent", "SistemBakim/$surum")
        $resp   = $wr.GetResponse()
        $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $json   = $reader.ReadToEnd() | ConvertFrom-Json
        $reader.Close(); $resp.Close()
        $enYeni = $json.tag_name -replace "^v", ""
        if ([System.Version]$enYeni -gt [System.Version]$surum) { return $enYeni }
    } catch {}
    return $null
} -ArgumentList $GITHUB_REPO, $SURUM

#endregion

#region ── YARDIMCI FONKSİYONLAR ────────────────────────────

# GUI modunda Read-Host cagrilari sureci kilitler (gomulu terminal input alamaz).
# Bu wrapper menu secimlerinde '1' (varsayilan eylem) dondurur.
# '1' degerı E/H kontrollerinde [Ee] ile eslesmedigi icin tehlikeli islemler GUVENLE atlanir.
if ($env:SISTEMBAK_GUI -eq '1') {
    function Read-Host {
        param([Parameter(Position=0)][string]$Prompt)
        Write-Host "[GUI Otomatik]" -ForegroundColor DarkGray
        return '1'
    }
}

function Yaz {
    param([string]$Metin, [ConsoleColor]$Renk = [ConsoleColor]::White, [switch]$YeniSatir = $true)
    if ($YeniSatir) { Write-Host $Metin -ForegroundColor $Renk }
    else            { Write-Host $Metin -ForegroundColor $Renk -NoNewline }
    Add-Content -Path $LOG_DOSYA -Value ("[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"), $Metin)
}

function Baslik {
    param([string]$Metin, [string]$Num = "")
    $cizgi = "─" * $BOX_EN
    Write-Host ""
    Write-Host $cizgi -ForegroundColor DarkCyan
    Write-Host ("  [{0}]  {1}" -f $Num, $Metin.ToUpper()) -ForegroundColor Cyan
    Write-Host $cizgi -ForegroundColor DarkCyan
    Add-Content -Path $LOG_DOSYA -Value ("`n=== [{0}] {1} ===" -f $Num, $Metin)
}

function Durum {
    param([string]$Etiket, [string]$Deger, [ConsoleColor]$Renk = "Green")
    $bosluk = " " * ([Math]::Max(1, 40 - $Etiket.Length))
    Write-Host ("  {0}{1}" -f $Etiket, $bosluk) -NoNewline -ForegroundColor Gray
    Write-Host $Deger -ForegroundColor $Renk
    Add-Content -Path $LOG_DOSYA -Value ("  {0,-40} {1}" -f $Etiket, $Deger)
}

function BoyutFormatla {
    param([long]$Bayt)
    if     ($Bayt -ge 1GB) { "{0:N2} GB" -f ($Bayt / 1GB) }
    elseif ($Bayt -ge 1MB) { "{0:N1} MB" -f ($Bayt / 1MB) }
    elseif ($Bayt -ge 1KB) { "{0:N0} KB" -f ($Bayt / 1KB) }
    else                   { "{0} B"     -f $Bayt }
}

function Onay {
    param([string]$Soru)
    if ($env:SISTEMBAK_GUI -eq '1') {
        Write-Host ("  ? {0} [Otomatik: Evet]" -f $Soru) -ForegroundColor Green
        return $true
    }
    Write-Host ("  ? {0} [E/H]: " -f $Soru) -ForegroundColor Yellow -NoNewline
    $c = Read-Host; return ($c -match "^[Ee]$")
}

function IlerlemeGoster {
    param([string]$Islem, [int]$Yuzde)
    $dolu  = [int]([Math]::Round($Yuzde / 5))
    $bos   = 20 - $dolu
    $cubuk = "[" + ("=" * $dolu) + (" " * $bos) + "]"
    Write-Host ("`r  {0} {1,-32} %{2,3}  " -f $cubuk, $Islem, $Yuzde) -NoNewline -ForegroundColor Cyan
    if ($Yuzde -eq 100) { Write-Host "" }
}

function YoneticiKontrol {
    $k = [Security.Principal.WindowsIdentity]::GetCurrent()
    ([Security.Principal.WindowsPrincipal]$k).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function SkorKaydet {
    param([string]$Kategori, [int]$Puan, [int]$MaxPuan = 100)
    $global:SkorBilesenleri[$Kategori] = @{ Puan=$Puan; Max=$MaxPuan }
}

function RaporVeriEkle {
    param([string]$Anahtar, $Deger)
    $global:RaporVerisi[$Anahtar] = $Deger
}

#endregion

#region ── BANNER & ANA MENÜ ────────────────────────────────

function AnlikDurumGoster {
    # CPU kullanimi
    $cpuYuz = 0
    try {
        $cpuYuz = [int]((Get-CimInstance Win32_Processor -ErrorAction Stop |
                  Measure-Object -Property LoadPercentage -Average).Average)
    } catch {}

    # RAM kullanimi
    $ramTopGB = 0.0; $ramKulGB = 0.0; $ramYuz = 0
    try {
        $os2 = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $ramTopGB = [Math]::Round($os2.TotalVisibleMemorySize / 1048576, 1)
        $ramKulGB = [Math]::Round(($os2.TotalVisibleMemorySize - $os2.FreePhysicalMemory) / 1048576, 1)
        if ($ramTopGB -gt 0) { $ramYuz = [int](($ramKulGB / $ramTopGB) * 100) }
    } catch {}

    # Disk C:\
    $diskKulGB = 0; $diskTopGB = 0; $diskYuz = 0
    try {
        $cDisk = Get-PSDrive C -ErrorAction Stop
        $diskKulGB = [int][Math]::Round($cDisk.Used / 1GB, 0)
        $diskTopGB = [int][Math]::Round(($cDisk.Used + $cDisk.Free) / 1GB, 0)
        if (($cDisk.Used + $cDisk.Free) -gt 0) {
            $diskYuz = [int](($cDisk.Used / ($cDisk.Used + $cDisk.Free)) * 100)
        }
    } catch {}

    # Hizli skor (0-100)
    $hSkor = 100
    if     ($cpuYuz  -ge 90) { $hSkor -= 25 } elseif ($cpuYuz  -ge 70) { $hSkor -= 12 } elseif ($cpuYuz  -ge 50) { $hSkor -= 5 }
    if     ($ramYuz  -ge 90) { $hSkor -= 25 } elseif ($ramYuz  -ge 75) { $hSkor -= 12 } elseif ($ramYuz  -ge 60) { $hSkor -= 5 }
    if     ($diskYuz -ge 90) { $hSkor -= 20 } elseif ($diskYuz -ge 80) { $hSkor -= 10 } elseif ($diskYuz -ge 70) { $hSkor -= 5 }
    if ($hSkor -lt 0) { $hSkor = 0 }

    # Renk kodlari
    $cpuRenk  = if ($cpuYuz  -le 50) { "Green"  } elseif ($cpuYuz  -le 80) { "Yellow" } else { "Red" }
    $ramRenk  = if ($ramYuz  -le 60) { "Green"  } elseif ($ramYuz  -le 80) { "Yellow" } else { "Red" }
    $diskRenk = if ($diskYuz -le 70) { "Green"  } elseif ($diskYuz -le 85) { "Yellow" } else { "Red" }
    $hSkorRenk = if ($hSkor  -ge 80) { "Green"  } elseif ($hSkor   -ge 60) { "Yellow" } else { "Red" }

    $hSkorYorum = if     ($hSkor -ge 90) { "MUKEMMEL" } `
                  elseif ($hSkor -ge 80) { "IYI"      } `
                  elseif ($hSkor -ge 60) { "ORTA"     } `
                  else                   { "DIKKAT"   }

    # ASCII ilerleme cubugu (20 karakter)
    $cpuBol  = [int]($cpuYuz  / 5); if ($cpuBol  -gt 20) { $cpuBol  = 20 }
    $ramBol  = [int]($ramYuz  / 5); if ($ramBol  -gt 20) { $ramBol  = 20 }
    $diskBol = [int]($diskYuz / 5); if ($diskBol -gt 20) { $diskBol = 20 }

    $cpuBar  = "[" + ("=" * $cpuBol)  + (" " * (20 - $cpuBol))  + "]"
    $ramBar  = "[" + ("=" * $ramBol)  + (" " * (20 - $ramBol))  + "]"
    $diskBar = "[" + ("=" * $diskBol) + (" " * (20 - $diskBol)) + "]"

    $ramKulStr  = $ramKulGB.ToString("0.0")
    $ramTopStr  = $ramTopGB.ToString("0.0")
    $diskSatir  = "C:\  " + $diskKulGB + " / " + $diskTopGB + " GB  (" + $diskYuz + "%)"
    $ramSatir   = $ramKulStr + " / " + $ramTopStr + " GB  (" + $ramYuz + "%)"

    Write-Host ""
    Write-Host "  -- Anlik Sistem Durumu ----------------------" -ForegroundColor DarkGray
    Write-Host ("  CPU    " + $cpuBar  + "  " + $cpuYuz + "%")   -ForegroundColor $cpuRenk
    Write-Host ("  RAM    " + $ramBar  + "  " + $ramSatir)        -ForegroundColor $ramRenk
    Write-Host ("  Disk   " + $diskBar + "  " + $diskSatir)       -ForegroundColor $diskRenk
    Write-Host ""
    Write-Host ("  Hizli Skor: " + $hSkor + "/100  [" + $hSkorYorum + "]") -ForegroundColor $hSkorRenk

    if ($global:SonCalistirilanlar -and $global:SonCalistirilanlar.Count -gt 0) {
        Write-Host "  Son: " -ForegroundColor DarkGray -NoNewline
        Write-Host ($global:SonCalistirilanlar[0]) -ForegroundColor DarkGray
    }
    Write-Host "  ---------------------------------------------" -ForegroundColor DarkGray
}

function BannerGoster {
    Clear-Host
    Write-Host @"

  ╔══════════════════════════════════════════════════════════════╗
  ║                                                              ║
  ║    S I S T E M   B A K I M   A R A C I   v$SURUM              ║
  ║    Temizlik · Saglik · Guvenlik · Gelistirici · Donanim      ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    $yon = YoneticiKontrol
    Durum "Yetki"         $(if ($yon) {"Yonetici [AKTIF]"} else {"Normal [KISITLI]"}) $(if ($yon) {"Green"} else {"Red"})
    Durum "Bilgisayar"    $env:COMPUTERNAME
    Durum "Kullanici"     $env:USERNAME
    Durum "Log Klasoru"   $LOG_KLASOR
    Durum "Tarih / Saat"  (Get-Date -Format "dd.MM.yyyy  HH:mm")

    # Surum guncelleme bildirimi (arka plan job tamamlandiysa goster)
    if ($global:UpdateJob -and $global:UpdateJob.State -eq "Completed") {
        $yeniSurum = $global:UpdateJob | Receive-Job -ErrorAction SilentlyContinue
        $global:UpdateJob | Remove-Job -Force -ErrorAction SilentlyContinue
        $global:UpdateJob = $null
        if ($yeniSurum) {
            Write-Host ""
            Write-Host ("  ** Yeni surum mevcut: v{0}  (mevcut: v{1})" -f $yeniSurum, $SURUM) -ForegroundColor Yellow
            Write-Host ("  ** github.com/{0}/releases" -f $GITHUB_REPO) -ForegroundColor Yellow
        }
    }

    AnlikDurumGoster
    Write-Host ""
}

function MenuGoster {
    Write-Host @"
  +--------------------------------------------------------------+
  |  TEMIZLIK                           PERFORMANS               |
  |   1  Disk Analizi       8  Downloads Analizi                 |
  |   2  Yinelenen Dosya    9  Sistem Tarama (SFC)               |
  |   3  Kapsamli Temizlik 10  Olay Gunlugu                      |
  |   4  SMART Disk Sagligi 11  Servis Kontrolu                  |
  |   5  Crash Dump        12  Baslangic Analizi                 |
  |   6  Shadow & Restore  13  Kaynak Durumu                     |
  |   7  Log Temizle       14  Guc Plani                         |
  +--------------------------------------------------------------+
  |  AG & GUVENLIK                      GELISTIRICI & DONANIM    |
  |  15  Ag Tanilamasi     17  Gelismis Guvenlik                 |
  |  16  Guvenlik Kontrol  18  Gelistirici Araclari              |
  |                        19  Donanim Raporu                    |
  +--------------------------------------------------------------+
  |  AKILLI ARACLAR                                              |
  |  20  HTML Dashboard    23  Hazir Profil Sec                  |
  |  21  Saglik Skoru      24  Geri Yukleme Noktasi              |
  |  22  Haftalik Zamanla  25  TAM BAKIM                         |
  +--------------------------------------------------------------+
  |  OYUN & FPS                                                  |
  |  26  FPS Optimizasyonu   (GameDVR/MMCSS/HAGS/GPU/Timer/+)   |
  |  27  RAM Optimizasyonu   (Standby + WorkingSet temizle)      |
  |  28  Surec Temizleyici   (arka plan killer, oyun oncesi)     |
  |  29  Bloatware Kaldir    (Xbox/Cortana/Eglence/Win11/+)     |
  |  37  DirectX/GPU Tani    38  Oyun Modu Toggle                |
  +--------------------------------------------------------------+
  |  BAKIM & SURUCU                     NETWORK & HIZ            |
  |  30  Surucu Kontrolu   33  WinSxS Temizligi                 |
  |  31  Windows Update    34  Pil Sagligi                       |
  |  32  Disk Optimize     35  Internet Hiz Testi                |
  |                        36  Bant Genisligi Optimize           |
  +--------------------------------------------------------------+
  |  GUVENLIK                           YENI MODULLER            |
  |  39  Hesap Guvenlik     41  Format Sonrasi Sihirbaz          |
  |  40  Suphe Baslangic    42  Windows Performans Tweaks        |
  |                         43  Sanal Bellek (Pagefile) Opt.     |
  |                         44  Donanim Skoru & Oneri            |
  |                         45  GPU Optimize (NVIDIA/AMD)        |
  |                         46  Defender Oyun Istisnalari        |
  |                         47  Monitor Hz & Cozunurluk          |
  |                         48  Hyper-V/VBS Kapat (FPS+)         |
  |                         49  Tarayici Temizleyici             |
  |                         50  OEM Bloatware Tespiti            |
  |                         51  Boot Suresi Analizi              |
  |                         52  Sag Tik Menu Temizle             |
  |                         53  DNS Benchmark                    |
  +--------------------------------------------------------------+
  |  FAZ 1 - YENI                                                |
  |  55  Bos Klasor Bulucu   57  USB Cihaz Gecmisi               |
  |  56  Dosya Kirpici       58  Hosts Dosyasi Editoru           |
  |                          59  Zamanlama Gorevi Temizle         |
  +--------------------------------------------------------------+
  |  FAZ 2 - GIZLILIK & PERFORMANS                               |
  |  60  Gizlilik Kalkani    62  Baglam Menusu Yoneticisi        |
  |  61  Turbo Boost Modu    63  Baslangic Gecikme Yoneticisi    |
  +--------------------------------------------------------------+
  |  FAZ 3 - AGIR TOPLAR                                         |
  |  64  Registry Temizleyici  66  Yazilim Guncelleyici          |
  |  65  Program Kaldirici     67  Sistem Geri Yukleme Yonetici  |
  +--------------------------------------------------------------+
  |  FAZ 4 - PREMIUM                                             |
  |  68  Hizmet Konfiguratoru  69  Ag Monitoru                   |
  +--------------------------------------------------------------+
  |   0  Cikis    |  ? = Gecmis    |  Modul adi yaz = Ara        |
  +--------------------------------------------------------------+
"@ -ForegroundColor DarkCyan
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
}

#endregion

#region ── MODUL 1: DİSK ANALİZİ ────────────────────────────

function DiskAnalizi {
    Baslik "Disk Analizi" "1"
    $toplamDisk = @()

    Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        $kul = $_.Used; $bos = $_.Free; $top = $kul + $bos
        if ($top -eq 0) { return }
        $y   = [int](($kul / $top) * 100)
        $bar = "[" + ("█" * [int]($y/5)) + ("░" * (20-[int]($y/5))) + "]"
        $renk = if ($y -gt 85){"Red"} elseif ($y -gt 60){"Yellow"} else {"Green"}
        Write-Host ("  {0}:  {1}  {2}/{3}  (%{4} dolu)" -f $_.Name,$bar,(BoyutFormatla $kul),(BoyutFormatla $top),$y) -ForegroundColor $renk
        Add-Content $LOG_DOSYA ("  Surucu {0}: %{1}" -f $_.Name,$y)
        $toplamDisk += @{ Surucu=$_.Name; Yuzde=$y; Toplam=$top; Kullanan=$kul }
    }
    RaporVeriEkle "diskler" $toplamDisk

    $cDisk = $toplamDisk | Where-Object { $_.Surucu -eq "C" } | Select-Object -First 1
    if ($cDisk) {
        $diskSkor = if ($cDisk.Yuzde -lt 60) {30} elseif ($cDisk.Yuzde -lt 80) {20} else {10}
        SkorKaydet "Disk Dolulugu" $diskSkor 30
    }

    Write-Host ""
    if (Test-Path "C:\Windows.old") {
        $boy = (Get-ChildItem "C:\Windows.old" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        Durum "  Windows.old" (BoyutFormatla $boy) Red
        if (Onay "Windows.old silinsin mi?") {
            takeown /f "C:\Windows.old" /r /d y | Out-Null
            icacls "C:\Windows.old" /grant administrators:F /t | Out-Null
            Remove-Item "C:\Windows.old" -Recurse -Force -ErrorAction SilentlyContinue
            Yaz "  Windows.old silindi." Green
        }
    }

    if (Test-Path "C:\hiberfil.sys") {
        $boy = (Get-Item "C:\hiberfil.sys" -Force -ErrorAction SilentlyContinue).Length
        Durum "  Hiberfil.sys" (BoyutFormatla $boy) Yellow
        if (Onay "Hazirda bekleme kapatilsin mi?") { powercfg -h off | Out-Null; Yaz "  Kapatildi." Green }
    }

    Write-Host ""; Yaz "  En buyuk 25 dosya taranıyor..." Gray
    $hedef = "C:\Users\$env:USERNAME"
    $liste = Get-ChildItem -Path $hedef -Recurse -File -ErrorAction SilentlyContinue |
             Where-Object { $_.Length -ge $BUYUK_ESIK } | Sort-Object Length -Descending | Select-Object -First 25
    if ($liste) {
        Write-Host ("  {0,-12}  {1}" -f "Boyut","Yol") -ForegroundColor DarkGray
        $liste | ForEach-Object {
            $r = if ($_.Length -ge 1GB){"Red"} elseif ($_.Length -ge 500MB){"Yellow"} else {"White"}
            Write-Host ("  {0,-12}  {1}" -f (BoyutFormatla $_.Length),$_.FullName) -ForegroundColor $r
        }
    }

    Write-Host ""; Yaz "  Bos klasorler aranıyor..." Gray
    $boslar = Get-ChildItem -Path $hedef -Recurse -Directory -ErrorAction SilentlyContinue |
              Where-Object { -not (Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue) }
    if ($boslar) {
        Yaz ("  {0} bos klasor bulundu." -f $boslar.Count) Yellow
        $boslar | ForEach-Object { Yaz ("    - {0}" -f $_.FullName) DarkGray }
        if (Onay "Bos klasorler silinsin mi?") {
            $boslar | Sort-Object FullName -Descending | ForEach-Object {
                Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                Yaz ("    Silindi: {0}" -f $_.FullName) DarkGray
            }
            Yaz "  Temizlendi." Green
        }
    } else { Yaz "  Bos klasor yok." Green }
}

#endregion

#region ── MODUL 2: DUPLICATE ───────────────────────────────

function DuplicateBul {
    Baslik "Yinelenen Dosya Bulucu (MD5)" "2"
    Yaz "  NOT: Buyuk klasorlerde 5-10 dk surebilir." Yellow
    $hedef    = "C:\Users\$env:USERNAME"
    $dosyalar = Get-ChildItem -Path $hedef -Recurse -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Length -ge $DUP_MIN }
    Yaz ("  {0} dosya taranıyor..." -f $dosyalar.Count) Gray
    $hashMap = @{}; $i = 0
    foreach ($d in $dosyalar) {
        $i++
        if ($i % 50 -eq 0) { IlerlemeGoster "Hash" ([int]($i/$dosyalar.Count*100)) }
        try {
            $h = (Get-FileHash $d.FullName -Algorithm MD5 -ErrorAction Stop).Hash
            if (-not $hashMap.ContainsKey($h)) { $hashMap[$h] = @() }
            $hashMap[$h] += $d
        } catch {}
    }
    IlerlemeGoster "Hash" 100
    $duplar = $hashMap.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }
    if (-not $duplar) { Yaz "  Yinelenen dosya yok. Temiz!" Green; SkorKaydet "Duplicate" 10 10; return }
    $topIsraf = 0L; $gNo = 0
    foreach ($g in $duplar) {
        $gNo++
        $liste  = $g.Value | Sort-Object FullName
        $israf  = $liste[0].Length * ($liste.Count - 1)
        $topIsraf += $israf
        Write-Host ("  ── Grup {0}  [{1} kopya / {2} israf]" -f $gNo,$liste.Count,(BoyutFormatla $israf)) -ForegroundColor Yellow
        $liste | ForEach-Object { Write-Host ("     {0,-12}  {1}" -f (BoyutFormatla $_.Length),$_.FullName) -ForegroundColor Gray }
    }
    Write-Host ("  {0} grup / {1} kazanilabilir" -f $gNo,(BoyutFormatla $topIsraf)) -ForegroundColor Cyan
    RaporVeriEkle "duplicate_israf" (BoyutFormatla $topIsraf)
    Yaz "  Hangi kopyayi silecegini elle karar ver." Yellow
}

#endregion

#region ── MODUL 3: KAPSAMLI TEMİZLİK ───────────────────────

function KapsamliTemizlik {
    Baslik "Kapsamli Temizlik (19 Konum)" "3"
    $topKazan = 0L
    $hedefler = [ordered]@{
        "Kullanici Temp"         = $env:TEMP
        "Windows Temp"           = "C:\Windows\Temp"
        "Prefetch"               = "C:\Windows\Prefetch"
        "IE / Edge Cache"        = "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
        "Windows Update Cache"   = "C:\Windows\SoftwareDistribution\Download"
        "Thumbnail Cache"        = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer"
        "Windows Error Reports"  = "$env:LOCALAPPDATA\Microsoft\Windows\WER"
        "DirectX Shader Cache"   = "$env:LOCALAPPDATA\D3DSCache"
        "Teams Cache"            = "$env:APPDATA\Microsoft\Teams\Cache"
        "Teams Blobs"            = "$env:APPDATA\Microsoft\Teams\blob_storage"
        "Discord Cache"          = "$env:APPDATA\discord\Cache"
        "Chrome Cache"           = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"
        "Chrome Code Cache"      = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache"
        "Edge Cache"             = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache"
        "Firefox Cache"          = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"
        "Spotify Cache"          = "$env:LOCALAPPDATA\Spotify\Data"
        "Steam HTML Cache"       = "$env:LOCALAPPDATA\Steam\htmlcache"
        "VS Code Logs"           = "$env:APPDATA\Code\logs"
        "VS Code CrashReports"   = "$env:APPDATA\Code\CrashReports"
    }
    $i = 0; $topAtlanan = 0
    foreach ($k in $hedefler.GetEnumerator()) {
        $i++; IlerlemeGoster $k.Key ([int]($i/$hedefler.Count*100))
        if (-not (Test-Path $k.Value)) { continue }
        $once = (Get-ChildItem $k.Value -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        $dosyalar = Get-ChildItem $k.Value -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { -not $_.PSIsContainer }
        foreach ($d in $dosyalar) {
            try {
                Remove-Item $d.FullName -Force -ErrorAction Stop
            } catch {
                $topAtlanan++  # Kilitli veya erisim engelli dosya
            }
        }
        $sonra = (Get-ChildItem $k.Value -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        $kaz   = [Math]::Max(0, $once - $sonra); $topKazan += $kaz
        if ($kaz -gt 0) { Durum $k.Key (BoyutFormatla $kaz) }
    }
    if ($topAtlanan -gt 0) { Yaz ("  {0} kilitli/erisim engelli dosya atlandi." -f $topAtlanan) DarkGray }
    Start-Process wsreset.exe -WindowStyle Hidden; Start-Sleep 3
    $icon = "$env:LOCALAPPDATA\IconCache.db"
    if (Test-Path $icon) { attrib -h $icon | Out-Null; Remove-Item $icon -Force -ErrorAction SilentlyContinue }
    ipconfig /flushdns | Out-Null
    if (Onay "Geri Donusum Kutusu bosaltilsin mi?") {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue; Yaz "  Geri Donusum Kutusu bosaltildi." Green
    }
    Write-Host ""; Write-Host ("  Toplam kazanilan: ") -NoNewline -ForegroundColor Gray
    Write-Host (BoyutFormatla $topKazan) -ForegroundColor Green
    RaporVeriEkle "temizlik_kazanim" (BoyutFormatla $topKazan)
    Add-Content $LOG_DOSYA ("Kapsamli Temizlik: {0}" -f (BoyutFormatla $topKazan))
}

#endregion

#region ── MODUL 4: SMART ───────────────────────────────────

function SmartDiskSagligi {
    Baslik "S.M.A.R.T. Disk Sagligi" "4"
    $diskler = Get-PhysicalDisk -ErrorAction SilentlyContinue
    if (-not $diskler) { Yaz "  Disk bilgisi alinamadi." Yellow; return }
    $diskSagligi = "Saglikli"; $smartSkor = 20
    foreach ($disk in $diskler) {
        Write-Host ("  ── {0}" -f $disk.FriendlyName) -ForegroundColor Cyan
        $sR = if ($disk.HealthStatus -eq "Healthy"){"Green"} elseif ($disk.HealthStatus -eq "Warning"){"Yellow"} else {"Red"}
        Durum "  Saglik"  $disk.HealthStatus  $sR
        Durum "  Durum"   $disk.OperationalStatus $(if ($disk.OperationalStatus -eq "OK"){"Green"} else {"Red"})
        Durum "  Tip"     $disk.MediaType
        Durum "  Boyut"   (BoyutFormatla $disk.Size)
        $g = $disk | Get-StorageReliabilityCounter -ErrorAction SilentlyContinue
        if ($g) {
            if ($g.Temperature) {
                $tR = if ($g.Temperature -gt 55){"Red"} elseif ($g.Temperature -gt 45){"Yellow"} else {"Green"}
                Durum "  Sicaklik" ("{0}°C" -f $g.Temperature) $tR
                if ($g.Temperature -gt 55) { $diskSagligi = "Kritik Sicaklik"; $smartSkor = 5 }
            }
            if ($g.Wear)              { Durum "  Asinma" ("%{0}" -f $g.Wear) $(if ($g.Wear -gt 80){"Red"} elseif ($g.Wear -gt 50){"Yellow"} else {"Green"}) }
            if ($g.ReadErrorsTotal)   { Durum "  Okuma Hatasi"  $g.ReadErrorsTotal  $(if ($g.ReadErrorsTotal  -gt 0){"Red"} else {"Green"}) }
            if ($g.WriteErrorsTotal)  { Durum "  Yazma Hatasi"  $g.WriteErrorsTotal $(if ($g.WriteErrorsTotal -gt 0){"Red"} else {"Green"}) }
            if ($g.PowerOnHours)      { Durum "  Acik Saat"     ("{0:N0} saat / {1:N0} gun" -f $g.PowerOnHours,($g.PowerOnHours/24)) }
        }
        if ($disk.MediaType -match "SSD|Solid") {
            $trim = fsutil behavior query DisableDeleteNotify 2>&1
            $ta   = $trim -match "= 0"
            Durum "  TRIM" $(if ($ta){"Aktif"} else {"KAPALI!"}) $(if ($ta){"Green"} else {"Red"})
            if (-not $ta -and (YoneticiKontrol) -and (Onay "TRIM aktif edilsin mi?")) {
                fsutil behavior set DisableDeleteNotify 0 | Out-Null; Yaz "  TRIM aktif edildi." Green
            }
        }
        if ($disk.HealthStatus -ne "Healthy") { $diskSagligi = "Sorunlu"; $smartSkor = 0 }
        Write-Host ""
    }
    SkorKaydet "SMART" $smartSkor 20
    RaporVeriEkle "smart_durum" $diskSagligi
    if ($diskSagligi -ne "Saglikli") { Yaz ("  !! Sorunlu disk tespit edildi — YEDEKLEME YAPIN!") Red }
    else { Yaz "  Tum diskler saglikli." Green }
}

#endregion

#region ── MODUL 5: CRASH DUMP ───────────────────────────────

function CrashDumpTemizle {
    Baslik "Crash Dump & Hata Raporu Temizligi" "5"
    $topKazan = 0L
    $hedefler = [ordered]@{
        "Minidump"               = "C:\Windows\Minidump"
        "MEMORY.DMP"             = "C:\Windows\MEMORY.DMP"
        "WER Arsivi (Sistem)"    = "C:\ProgramData\Microsoft\Windows\WER\ReportArchive"
        "WER Arsivi (Kullanici)" = "$env:LOCALAPPDATA\Microsoft\Windows\WER\ReportArchive"
        "WER Kuyrugu"            = "C:\ProgramData\Microsoft\Windows\WER\ReportQueue"
        "LiveKernelReports"      = "C:\Windows\LiveKernelReports"
        "Crash Dumps (Kullanici)"= "$env:LOCALAPPDATA\CrashDumps"
    }
    $bulunanlar = @()
    foreach ($h in $hedefler.GetEnumerator()) {
        if (-not (Test-Path $h.Value)) { continue }
        $item = Get-Item $h.Value -Force -ErrorAction SilentlyContinue
        $boy  = if ($item.PSIsContainer) { (Get-ChildItem $h.Value -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum }
                else { $item.Length }
        if ($boy -gt 0) { $bulunanlar += [PSCustomObject]@{ Ad=$h.Key; Yol=$h.Value; Boyut=$boy; Klasor=$item.PSIsContainer } }
    }
    if (-not $bulunanlar) { Yaz "  Crash dump yok. Temiz!" Green; return }
    $bulunanlar | ForEach-Object { Durum $_.Ad (BoyutFormatla $_.Boyut) Yellow }
    $topBoyut = ($bulunanlar | Measure-Object Boyut -Sum).Sum
    Write-Host ("  Toplam: {0}" -f (BoyutFormatla $topBoyut)) -ForegroundColor Yellow
    if (Onay "Tumu silinsin mi?") {
        foreach ($b in $bulunanlar) {
            if ($b.Klasor) { Get-ChildItem $b.Yol -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | Remove-Item -Force -ErrorAction SilentlyContinue }
            else { Remove-Item $b.Yol -Force -ErrorAction SilentlyContinue }
            $topKazan += $b.Boyut
        }
        Write-Host ("  Kazanilan: {0}" -f (BoyutFormatla $topKazan)) -ForegroundColor Green
    }
}

#endregion

#region ── MODUL 6: SHADOW & RESTORE ────────────────────────

function ShadowVeRestore {
    Baslik "Shadow Copy & Restore Point Yonetimi" "6"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    Write-Host "  ── Geri Yukleme Noktalari" -ForegroundColor Cyan
    $noktalar = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
    if ($noktalar) {
        Yaz ("  {0} adet nokta bulundu:" -f $noktalar.Count) Gray
        $noktalar | ForEach-Object {
            $yas  = ((Get-Date) - $_.CreationTime).Days
            $renk = if ($yas -gt 60){"DarkGray"} elseif ($yas -gt 30){"Yellow"} else {"White"}
            Write-Host ("    [{0}]  {1,-38}  {2}g" -f $_.CreationTime.ToString("dd.MM.yy"),$_.Description.Substring(0,[Math]::Min(36,$_.Description.Length)),$yas) -ForegroundColor $renk
        }
        if ($noktalar.Count -gt 3 -and (Onay ("En yeni 3 nokta disindakileri sil? ({0} adet)" -f ($noktalar.Count-3)))) {
            $silinecekler = $noktalar | Sort-Object CreationTime | Select-Object -First ($noktalar.Count - 3)
            $silinecekler | ForEach-Object {
                try { $null = [System.Management.ManagementClass]::new("\\.\root\default:SystemRestore").Delete("SequenceNumber=$($_.SequenceNumber)") } catch {}
                Yaz ("  Silindi: {0}" -f $_.Description) DarkGray
            }
        }
    }

    Write-Host ""; Write-Host "  ── Volume Shadow Copies" -ForegroundColor Cyan
    $shadows = vssadmin list shadows 2>&1 | Out-String
    $sayac   = ([regex]::Matches($shadows,"Shadow Copy ID")).Count
    if ($sayac -gt 0) {
        Yaz ("  {0} shadow copy bulundu." -f $sayac) Yellow
        $shadows -split "`n" | Where-Object { $_ -match "Creation|Volume|Shadow Copy ID" } |
            ForEach-Object { Write-Host ("  {0}" -f $_.Trim()) -ForegroundColor DarkGray }
        if (Onay "Tum shadow copy'ler silinsin mi?") {
            vssadmin delete shadows /all /quiet | Out-Null
            Yaz "  Shadow copy'ler silindi." Green
        }
    } else { Yaz "  Shadow copy yok." Green }
}

#endregion

#region ── MODUL 7: WINDOWS LOG TEMİZLİĞİ ───────────────────

function WindowsLogTemizle {
    Baslik "Windows Log Dosyalari Temizligi" "7"
    $topKazan = 0L
    $hedefler = [ordered]@{
        "CBS Log (SFC/DISM)"        = "C:\Windows\Logs\CBS"
        "DISM Loglari"              = "C:\Windows\Logs\DISM"
        "Setup Panther"             = "C:\Windows\Panther"
        "WU DataStore Logs"         = "C:\Windows\SoftwareDistribution\DataStore\Logs"
        "Delivery Optimization"     = "C:\Windows\SoftwareDistribution\DeliveryOptimization"
        "NetSetup.log"              = "C:\Windows\debug\NetSetup.log"
    }
    foreach ($h in $hedefler.GetEnumerator()) {
        if (-not (Test-Path $h.Value)) { continue }
        $item = Get-Item $h.Value -ErrorAction SilentlyContinue
        $boy  = if ($item.PSIsContainer) { (Get-ChildItem $h.Value -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum }
                else { $item.Length }
        if ($boy -lt 1MB) { continue }
        Durum $h.Key (BoyutFormatla $boy) Yellow
    }
    if (Onay "Guvenli log dosyalari silinsin mi?") {
        foreach ($h in $hedefler.GetEnumerator()) {
            if (-not (Test-Path $h.Value)) { continue }
            $item = Get-Item $h.Value -ErrorAction SilentlyContinue
            $onceBoy = if ($item.PSIsContainer) { (Get-ChildItem $h.Value -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum } else { $item.Length }
            if ($item.PSIsContainer) {
                Get-ChildItem $h.Value -Recurse -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
                    Remove-Item -Force -ErrorAction SilentlyContinue
            } else { Clear-Content $h.Value -ErrorAction SilentlyContinue }
            $sonraBoy = if ($item.PSIsContainer) { (Get-ChildItem $h.Value -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum } else { (Get-Item $h.Value -ErrorAction SilentlyContinue).Length }
            $kaz = [Math]::Max(0, $onceBoy - $sonraBoy); $topKazan += $kaz
            if ($kaz -gt 0) { Yaz ("  Temizlendi: {0} ({1})" -f $h.Key, (BoyutFormatla $kaz)) DarkGray }
        }
    }
    if (Onay "Tum Windows olay gunlukleri temizlensin mi?") {
        Get-EventLog -List -ErrorAction SilentlyContinue | ForEach-Object {
            try { Clear-EventLog -LogName $_.Log -ErrorAction Stop; Yaz ("  Temizlendi: {0}" -f $_.Log) DarkGray } catch {}
        }
    }
    Write-Host ("  Kazanilan: {0}" -f (BoyutFormatla $topKazan)) -ForegroundColor Green
}

#endregion

#region ── MODUL 8: DOWNLOADS ANALİZİ ───────────────────────

function DownloadsAnalizi {
    Baslik "Downloads Klasoru Analizi" "8"
    $dwn = "$env:USERPROFILE\Downloads"
    if (-not (Test-Path $dwn)) { Yaz "  Downloads bulunamadi." Yellow; return }
    $dosyalar    = Get-ChildItem -Path $dwn -Recurse -File -ErrorAction SilentlyContinue
    if (-not $dosyalar) { Yaz "  Downloads bos." Green; return }
    $topBoyut    = ($dosyalar | Measure-Object Length -Sum).Sum
    Durum "  Toplam Dosya"  ("{0} adet" -f $dosyalar.Count)
    Durum "  Toplam Boyut"  (BoyutFormatla $topBoyut) $(if ($topBoyut -gt 5GB){"Red"} elseif ($topBoyut -gt 1GB){"Yellow"} else {"Green"})
    $bugun = Get-Date
    Write-Host ""; Write-Host "  ── Yasa Gore" -ForegroundColor Cyan
    @{ "Son 7 gun"=7; "7-30 gun"=30; "30-90 gun"=90; "90-365 gun"=365; "1 yildan eski"=9999 }.GetEnumerator() | ForEach-Object {
        $label = $_.Key; $maxGun = $_.Value
        $minGun = switch ($label) { "Son 7 gun"{0} "7-30 gun"{7} "30-90 gun"{30} "90-365 gun"{90} default{365} }
        $grup = $dosyalar | Where-Object {
            $g = [int](($bugun - $_.LastWriteTime).TotalDays)
            $g -ge $minGun -and ($maxGun -eq 9999 -or $g -lt $maxGun)
        }
        if ($grup) {
            $boy  = ($grup | Measure-Object Length -Sum).Sum
            $renk = if ($label -match "eski|90-365"){"Red"} elseif ($label -match "30-90"){"Yellow"} else {"Green"}
            Durum ("  {0}" -f $label) ("{0} dosya / {1}" -f @($grup).Count,(BoyutFormatla $boy)) $renk
        }
    }
    Write-Host ""; Write-Host "  ── En Buyuk 10" -ForegroundColor Cyan
    $dosyalar | Sort-Object Length -Descending | Select-Object -First 10 | ForEach-Object {
        $yas  = [int](($bugun - $_.LastWriteTime).TotalDays)
        $renk = if ($_.Length -ge 1GB){"Red"} elseif ($_.Length -ge 200MB){"Yellow"} else {"White"}
        Write-Host ("  {0,-12}  {1,-40}  {2}g" -f (BoyutFormatla $_.Length),$_.Name.Substring(0,[Math]::Min(38,$_.Name.Length)),$yas) -ForegroundColor $renk
    }
    $eskiler = $dosyalar | Where-Object { ($bugun - $_.LastWriteTime).TotalDays -gt 90 -and $_.Extension -match "^\.exe$|^\.msi$|^\.iso$|^\.zip$|^\.7z$|^\.rar$" }
    if ($eskiler -and (Onay ("90+ gun eski kurulum dosyalari silinsin mi? ({0} adet)" -f @($eskiler).Count))) {
        $eskiler | ForEach-Object { Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue }
        $sil = ($eskiler | Measure-Object Length -Sum).Sum
        Write-Host ("  Kazanilan: {0}" -f (BoyutFormatla $sil)) -ForegroundColor Green
    }
}

#endregion

#region ── MODUL 9: SİSTEM TARAMA ───────────────────────────

function SistemTara {
    Baslik "Sistem Tarama ve Onarim (SFC/DISM/ChkDsk)" "9"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }
    Yaz "  [1/3] SFC taranıyor (5-15 dk)..." Yellow
    sfc /scannow 2>&1 | Out-Null
    $cbs  = "C:\Windows\Logs\CBS\CBS.log"
    $sfcS = "Kontrol tamamlandi"
    if (Test-Path $cbs) {
        $ic = Get-Content $cbs -Tail 300 -ErrorAction SilentlyContinue | Out-String
        if     ($ic -match "no integrity violations") { $sfcS = "Temiz" }
        elseif ($ic -match "successfully repaired")   { $sfcS = "Onarildi" }
        elseif ($ic -match "cannot repair")           { $sfcS = "Bozuk dosya var — DISM onarimi onerilir" }
    }
    Durum "SFC" $sfcS $(if ($sfcS -match "Temiz|Onarildi"){"Green"} else {"Yellow"})
    Yaz "  [2/3] DISM kontrol ediliyor..." Yellow
    $dism = DISM /Online /Cleanup-Image /ScanHealth 2>&1 | Out-String
    $dismS = if ($dism -match "no component store corruption"){"Temiz"} else {"Sorun var"}
    Durum "DISM" $dismS $(if ($dismS -eq "Temiz"){"Green"} else {"Red"})
    if ($dismS -ne "Temiz" -and (Onay "DISM onarimi baslatilsin mi?")) {
        DISM /Online /Cleanup-Image /RestoreHealth | Out-Null; Yaz "  DISM onarimi tamamlandi." Green
    }
    DISM /Online /Cleanup-Image /StartComponentCleanup 2>&1 | Out-Null
    Yaz "  DISM WinSxS temizlendi." Green
    Yaz "  [3/3] Disk hatası kontrolu..." Yellow
    $chk = chkdsk C: 2>&1 | Out-String
    $hataSay = ([regex]::Matches($chk,"error|bad sector|corrupt")).Count
    Durum "ChkDsk Hata" $hataSay $(if ($hataSay -eq 0){"Green"} else {"Red"})
    $sfcSkor = if ($sfcS -eq "Temiz") {15} elseif ($sfcS -eq "Onarildi") {10} else {5}
    SkorKaydet "Sistem Dosyalari" $sfcSkor 15
    RaporVeriEkle "sfc_sonuc" $sfcS
}

#endregion

#region ── MODUL 10: OLAY GÜNLÜĞÜ ───────────────────────────

function OlayGunlugu {
    Baslik "Olay Gunlugu Analizi (Son 7 Gun)" "10"
    $bas  = (Get-Date).AddDays(-7)
    $bsod = 0
    @("System","Application","Security") | ForEach-Object {
        Write-Host ("  ── {0}" -f $_) -ForegroundColor Cyan
        $kritik = Get-EventLog -LogName $_ -EntryType Error,Warning -After $bas -Newest 100 -ErrorAction SilentlyContinue
        if (-not $kritik) { Yaz "  Kritik olay yok." Green; return }
        $kritik | Group-Object Source | Sort-Object Count -Descending | Select-Object -First 6 | ForEach-Object {
            $renk = if ($_.Count -gt 10){"Red"} elseif ($_.Count -gt 3){"Yellow"} else {"Gray"}
            Write-Host ("    {0,-40} {1,3} olay" -f $_.Name,$_.Count) -ForegroundColor $renk
        }
        Write-Host ""
    }
    $bsodOlay = Get-EventLog -LogName System -Source "BugCheck" -After $bas -ErrorAction SilentlyContinue
    $bsod     = if ($bsodOlay) { @($bsodOlay).Count } else { 0 }
    if ($bsod -gt 0) { Yaz ("  !! {0} BSOD tespit edildi!" -f $bsod) Red }
    else             { Yaz "  Son 7 gunde BSOD yok." Green }
    $bsodSkor = if ($bsod -eq 0){10} elseif ($bsod -lt 3){5} else {0}
    SkorKaydet "BSOD" $bsodSkor 10
    RaporVeriEkle "bsod_sayisi" $bsod
}

#endregion

#region ── MODUL 11: SERVİS ─────────────────────────────────

function ServisKontrol {
    Baslik "Kritik Servis Kontrolu (20 Servis)" "11"
    $servisler = @(
        @{Ad="wuauserv";     Tanim="Windows Update";         K=$true }
        @{Ad="Winmgmt";      Tanim="WMI";                    K=$true }
        @{Ad="EventLog";     Tanim="Olay Gunlugu";           K=$true }
        @{Ad="Dnscache";     Tanim="DNS Client";             K=$true }
        @{Ad="RpcSs";        Tanim="RPC";                    K=$true }
        @{Ad="PlugPlay";     Tanim="Plug and Play";          K=$true }
        @{Ad="LanmanServer"; Tanim="Dosya Paylasimi";        K=$false}
        @{Ad="Schedule";     Tanim="Gorev Zamanlayici";      K=$true }
        @{Ad="BITS";         Tanim="BITS";                   K=$false}
        @{Ad="Spooler";      Tanim="Yazici Biriktirici";     K=$false}
        @{Ad="AudioSrv";     Tanim="Windows Audio";          K=$false}
        @{Ad="Themes";       Tanim="Temalar";                K=$false}
        @{Ad="WSearch";      Tanim="Windows Search";         K=$false}
        @{Ad="SysMain";      Tanim="Superfetch";             K=$false}
        @{Ad="wscsvc";       Tanim="Guvenlik Merkezi";       K=$true }
        @{Ad="MpsSvc";       Tanim="Windows Firewall";       K=$true }
        @{Ad="WinDefend";    Tanim="Windows Defender";       K=$true }
        @{Ad="CryptSvc";     Tanim="Kriptografi";            K=$true }
        @{Ad="Dhcp";         Tanim="DHCP Client";            K=$true }
        @{Ad="TrkWks";       Tanim="Baglanti Izleme";        K=$false}
    )
    $sorunlu = @(); $kritikSorun = 0
    $servisler | ForEach-Object {
        $s = Get-Service -Name $_.Ad -ErrorAction SilentlyContinue
        if ($null -eq $s) { return }
        $renk = if ($s.Status -eq "Running"){"Green"} elseif ($_.K){"Red"} else {"Yellow"}
        Durum (("{0} {1}" -f $(if($_.K){"[K]"} else {"   "}),$_.Tanim)) $s.Status $renk
        if ($s.Status -ne "Running") { $sorunlu += $_; if ($_.K) { $kritikSorun++ } }
    }
    if ($sorunlu.Count -gt 0 -and (Onay ("{0} servis calismıyor, baslatilsin mi?" -f $sorunlu.Count))) {
        $sorunlu | ForEach-Object {
            try { Start-Service -Name $_.Ad -ErrorAction Stop; Yaz ("  Baslatildi: {0}" -f $_.Tanim) Green }
            catch { Yaz ("  Baslatılamadi: {0}" -f $_.Tanim) Red }
        }
    } elseif ($sorunlu.Count -eq 0) { Yaz "  Tum servisler calisıyor." Green }
    $servisSkor = [Math]::Max(0, 10 - ($kritikSorun * 3))
    SkorKaydet "Servisler" $servisSkor 10
}

#endregion

#region ── MODUL 12-14: PERFORMANS ──────────────────────────

function BaslangicAnalizi {
    Baslik "Baslangic Programlari" "12"
    $yollar = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
    )
    $programlar = @()
    foreach ($y in $yollar) {
        if (-not (Test-Path $y)) { continue }
        $kayit = Get-ItemProperty $y -ErrorAction SilentlyContinue
        $kayit.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | ForEach-Object {
            $programlar += [PSCustomObject]@{ Ad=$_.Name; Yol=$_.Value; Kaynak=$y -replace "HKLM","Sistem" -replace "HKCU","Kullanici" }
        }
    }
    $sf = [System.Environment]::GetFolderPath("Startup")
    Get-ChildItem $sf -ErrorAction SilentlyContinue | ForEach-Object {
        $programlar += [PSCustomObject]@{ Ad=$_.Name; Yol=$_.FullName; Kaynak="Klasor" }
    }
    Yaz ("  {0} baslangic programi:" -f $programlar.Count) Cyan
    $programlar | Sort-Object Ad | ForEach-Object {
        Write-Host ("  {0,-38} {1}" -f $_.Ad.Substring(0,[Math]::Min(36,$_.Ad.Length)),$_.Kaynak) -ForegroundColor Gray
    }
    $say  = $programlar.Count
    $yorum = if ($say -gt 20){"Cok fazla — boot yavaslıyor!"} elseif ($say -gt 10){"Orta — gereksizleri devre disi birak"} else {"Makul seviye"}
    $renk  = if ($say -gt 20){"Red"} elseif ($say -gt 10){"Yellow"} else {"Green"}
    Write-Host ""; Durum "  Degerlendirme" $yorum $renk
    $startSkor = if ($say -le 10){10} elseif ($say -le 20){6} else {3}
    SkorKaydet "Baslangic" $startSkor 10
    RaporVeriEkle "startup_sayisi" $say
}

function KaynakDurumu {
    Baslik "Sistem Kaynak Durumu" "13"
    $os  = Get-CimInstance Win32_OperatingSystem
    $top = $os.TotalVisibleMemorySize * 1KB
    $bos = $os.FreePhysicalMemory * 1KB
    $kul = $top - $bos
    $yuz = [int](($kul/$top)*100)
    $bar = "[" + ("█" * [int]($yuz/5)) + ("░" * (20-[int]($yuz/5))) + "]"
    Write-Host "  ── RAM" -ForegroundColor Cyan
    Durum "  Toplam"   (BoyutFormatla $top)
    Durum "  Kullanim" ("{0} {1} %{2}" -f (BoyutFormatla $kul),$bar,$yuz) $(if ($yuz -gt 85){"Red"} elseif ($yuz -gt 65){"Yellow"} else {"Green"})
    Get-CimInstance Win32_PhysicalMemory -ErrorAction SilentlyContinue | ForEach-Object {
        Durum ("  Slot [{0}]" -f $_.DeviceLocator) ("{0} / {1} MHz / {2}" -f (BoyutFormatla $_.Capacity),$_.Speed,$_.Manufacturer)
    }
    Write-Host ""; Write-Host "  ── CPU" -ForegroundColor Cyan
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    Durum "  Model"    $cpu.Name.Trim()
    Durum "  Cekirdek" ("{0} fiziksel / {1} mantiksal" -f $cpu.NumberOfCores,$cpu.NumberOfLogicalProcessors)
    Durum "  Hiz"      ("{0} MHz" -f $cpu.CurrentClockSpeed)
    Write-Host ""; Write-Host "  ── GPU" -ForegroundColor Cyan
    Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | ForEach-Object {
        Durum ("  {0}" -f $_.Name) ("{0}" -f $_.DriverVersion)
        if ($_.AdapterRAM) { Durum "  VRAM" (BoyutFormatla $_.AdapterRAM) }
    }
    Write-Host ""; Write-Host "  ── Disk" -ForegroundColor Cyan
    Get-PhysicalDisk -ErrorAction SilentlyContinue | ForEach-Object {
        Durum ("  {0}" -f $_.FriendlyName) ("{0} [{1}] {2}" -f (BoyutFormatla $_.Size),$_.MediaType,$_.OperationalStatus) $(if($_.OperationalStatus -eq "OK"){"Green"} else {"Red"})
    }
    $uptime = (Get-Date) - $os.LastBootUpTime
    Write-Host ""
    Durum "  Sistem Acik" ("{0}g {1}s {2}dk" -f $uptime.Days,$uptime.Hours,$uptime.Minutes) $(if($uptime.Days -gt 7){"Yellow"} else {"Green"})
    if ($uptime.Days -gt 7) { Yaz "  Tavsiye: 7+ gun — yeniden baslatma onerilir." Yellow }
    RaporVeriEkle "ram_yuzde" $yuz
    RaporVeriEkle "uptime_gun" $uptime.Days
}

function GucPlani {
    Baslik "Guc Plani Optimizasyonu" "14"
    $mevcut = powercfg /getactivescheme 2>&1
    Yaz ("  Mevcut plan: {0}" -f $mevcut) Gray
    Write-Host ""; Write-Host "    [1] Yuksek Performans"; Write-Host "    [2] Son Teknoloji Performans"
    Write-Host "    [3] Dengeli";           Write-Host "    [0] Degistirme"
    Write-Host "  Secim: " -NoNewline -ForegroundColor Yellow; $sec = Read-Host
    switch ($sec) {
        "1" { powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c; Yaz "  Yuksek Performans aktif." Green }
        "2" { powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null | Out-Null; powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61; Yaz "  Son Teknoloji Performans aktif." Green }
        "3" { powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e; Yaz "  Dengeli aktif." Green }
        default { Yaz "  Degisiklik yok." Gray }
    }
}

#endregion

#region ── MODUL 15-16: AG & GÜVENLİK ───────────────────────

function AgTanilamasi {
    Baslik "Ag Tanilamasi" "15"
    Write-Host "  ── Adaptorler" -ForegroundColor Cyan
    Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object { Durum ("  {0}" -f $_.Name) ("{0} [{1}]" -f $_.LinkSpeed,$_.InterfaceDescription) }
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -ne "Loopback Pseudo-Interface 1" } | ForEach-Object { Durum ("  IP: {0}" -f $_.InterfaceAlias) $_.IPAddress }
    $gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Select-Object -First 1).NextHop
    if ($gw) { Durum "  Gateway" $gw }
    if (Onay "DNS temizlensin mi?") { ipconfig /flushdns | Out-Null; Yaz "  DNS temizlendi." Green }
    Write-Host ""; Write-Host "  ── Ping / Gecikme" -ForegroundColor Cyan
    $pingOrt = 0; $pingSay = 0
    @{"Google DNS"="8.8.8.8";"Cloudflare"="1.1.1.1";"OpenDNS"="208.67.222.222";"google.com"="google.com";"Yandex DNS"="77.88.8.8"}.GetEnumerator() | ForEach-Object {
        $ms = (Measure-Command { Test-Connection $_.Value -Count 2 -ErrorAction SilentlyContinue }).TotalMilliseconds / 2
        $renk = if ($ms -lt 30){"Green"} elseif ($ms -lt 80){"Yellow"} else {"Red"}
        Durum ("  {0}" -f $_.Key) ("{0:N0} ms" -f $ms) $renk
        $pingOrt += $ms; $pingSay++
    }
    $agSkor = if (($pingOrt/$pingSay) -lt 40){10} elseif (($pingOrt/$pingSay) -lt 80){7} else {4}
    SkorKaydet "Ag Gecikmesi" $agSkor 10
    if (Onay "Winsock sifirlansin mi?") { netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; Yaz "  Winsock sifirlandi (yeniden baslat)." Yellow }
}

function GuvenlikKontrol {
    Baslik "Guvenlik Kontrolu" "16"
    $guvenlikSkor = 0
    Write-Host "  ── Guvenlik Duvari" -ForegroundColor Cyan
    try {
        $fw = Get-NetFirewallProfile
        $fw | ForEach-Object {
            $etkin = $_.Enabled
            Durum ("  {0} Profili" -f $_.Name) $(if($etkin){"Acik"} else {"KAPALI!"}) $(if($etkin){"Green"} else {"Red"})
        }
        if (($fw | Where-Object { -not $_.Enabled }).Count -eq 0) { $guvenlikSkor += 5 }
    } catch {}
    Write-Host ""; Write-Host "  ── Defender" -ForegroundColor Cyan
    try {
        $av = Get-MpComputerStatus
        Durum "  Gercek Zamanli" $(if($av.RealTimeProtectionEnabled){"Acik"} else {"KAPALI"}) $(if($av.RealTimeProtectionEnabled){"Green"} else {"Red"})
        Durum "  Imza Tarihi"    $av.AntivirusSignatureLastUpdated.ToString("dd.MM.yyyy")
        $yas = ((Get-Date)-$av.AntivirusSignatureLastUpdated).Days
        if ($yas -le 3 -and $av.RealTimeProtectionEnabled) { $guvenlikSkor += 5 }
        if ($yas -gt 3) { Yaz ("  !! {0} gundur guncellenmemis!" -f $yas) Red }
    } catch {}
    Write-Host ""; Write-Host "  ── Suruculer" -ForegroundColor Cyan
    $sorunlu = Get-WmiObject Win32_PnPEntity -ErrorAction SilentlyContinue | Where-Object { $_.ConfigManagerErrorCode -ne 0 }
    if ($sorunlu) { $sorunlu | ForEach-Object { Durum ("  [{0}] {1}" -f $_.ConfigManagerErrorCode,$_.Name.Substring(0,[Math]::Min(40,$_.Name.Length))) "Sorun" Red } }
    else          { Yaz "  Tum suruculer saglikli." Green; $guvenlikSkor += 5 }
    try {
        $wu  = New-Object -ComObject Microsoft.Update.Session
        $res = $wu.CreateUpdateSearcher().Search("IsInstalled=0 and Type='Software'")
        Durum "  Bekleyen Guncelleme" ("{0} adet" -f $res.Updates.Count) $(if($res.Updates.Count -eq 0){"Green"} elseif($res.Updates.Count -lt 5){"Yellow"} else {"Red"})
    } catch {}
    SkorKaydet "Guvenlik" $guvenlikSkor 15
    RaporVeriEkle "guvenlik_skor" $guvenlikSkor
}

#endregion

#region ── MODUL 17: GELİŞMİŞ GÜVENLİK ─────────────────────

function GelismisGuvenlik {
    Baslik "Gelismis Guvenlik Analizi" "17"
    if (-not (YoneticiKontrol)) { Yaz "  Bazi kontroller Yonetici yetkisi gerektirir." Yellow }

    # Hosts dosyası tarama
    Write-Host "  ── Hosts Dosyasi Tarama" -ForegroundColor Cyan
    $hostsYol  = "C:\Windows\System32\drivers\etc\hosts"
    $hostsIc   = Get-Content $hostsYol -ErrorAction SilentlyContinue
    $suspHosts = $hostsIc | Where-Object { $_ -notmatch "^#|^\s*$|127\.0\.0\.1\s+localhost|::1\s+localhost" }
    if ($suspHosts) {
        Yaz ("  {0} adet standart disi giris bulundu:" -f @($suspHosts).Count) Yellow
        $suspHosts | ForEach-Object { Write-Host ("    {0}" -f $_) -ForegroundColor Red }
        Add-Content $LOG_DOSYA ("  [Hosts] Suphe: {0}" -f ($suspHosts -join " | "))
    } else { Yaz "  Hosts dosyasi temiz." Green }

    # Açık portlar
    Write-Host ""; Write-Host "  ── Acik Port Taramasi" -ForegroundColor Cyan
    $tehlikeliPortlar = @(135,139,445,1433,3306,3389,5900,22,23,21,25)
    $baglantilar = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue
    $riskli = $baglantilar | Where-Object { $_.LocalPort -in $tehlikeliPortlar }
    if ($riskli) {
        Yaz ("  {0} riskli port acik:" -f @($riskli).Count) Yellow
        $riskli | ForEach-Object {
            $serv = (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name
            $portAdi = switch ($_.LocalPort) {
                3389 {"RDP"}; 445 {"SMB"}; 1433 {"SQL Server"}; 3306 {"MySQL"}
                5900 {"VNC"}; 23 {"Telnet"}; 21 {"FTP"}; 25 {"SMTP"}
                default {"Port $($_.LocalPort)"}
            }
            Durum ("  {0}" -f $portAdi) ("Port {0} — Proses: {1}" -f $_.LocalPort,$serv) Yellow
        }
    } else { Yaz "  Riskli port bulunamadi." Green }

    # Tüm açık portlar
    Write-Host ""; Write-Host "  ── Tum Dinleme Portlari" -ForegroundColor Cyan
    $baglantilar | Sort-Object LocalPort | Select-Object -First 20 | ForEach-Object {
        $serv = (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name
        Write-Host ("    Port {0,-6}  {1}" -f $_.LocalPort,$serv) -ForegroundColor DarkGray
    }

    # RDP durumu
    Write-Host ""; Write-Host "  ── RDP Durumu" -ForegroundColor Cyan
    $rdp = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -ErrorAction SilentlyContinue).fDenyTSConnections
    Durum "  Uzak Masaustu (RDP)" $(if ($rdp -eq 0){"ACIK — Guvenlik riski olabilir"} else {"Kapali"}) $(if ($rdp -eq 0){"Yellow"} else {"Green"})

    # Paylaşılan klasörler
    Write-Host ""; Write-Host "  ── Paylasilan Klasorler" -ForegroundColor Cyan
    $paylasimlar = Get-SmbShare -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "^IPC\$|^print\$" }
    if ($paylasimlar) {
        $paylasimlar | ForEach-Object { Durum ("  {0}" -f $_.Name) $_.Path Yellow }
    } else { Yaz "  Paylasilan klasor yok." Green }

    # BitLocker
    Write-Host ""; Write-Host "  ── BitLocker Durumu" -ForegroundColor Cyan
    try {
        $bl = manage-bde -status C: 2>&1 | Out-String
        if     ($bl -match "Protection On")  { Yaz "  C: Surucusu: BitLocker AKTIF — sifreli." Green }
        elseif ($bl -match "Protection Off") { Yaz "  C: Surucusu: BitLocker KAPALI — sifreli degil." Yellow }
        else                                  { Yaz "  BitLocker durumu alinamadi." Gray }
    } catch { Yaz "  BitLocker bilgisi alinamadi." Gray }

    # Otomatik oturum açma kontrolü
    Write-Host ""; Write-Host "  ── Otomatik Oturum Acma" -ForegroundColor Cyan
    $autoLogon = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -ErrorAction SilentlyContinue).AutoAdminLogon
    if ($autoLogon -eq "1") { Yaz "  UYARI: Otomatik oturum acma aktif — guvenlik riski!" Red }
    else                    { Yaz "  Otomatik oturum acma devre disi." Green }

    # Şüpheli zamanlanmış görevler
    Write-Host ""; Write-Host "  ── Suphe Uyandiran Zamanlanmis Gorevler" -ForegroundColor Cyan
    $gorevler = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
        $_.TaskPath -notmatch "\\Microsoft\\" -and $_.State -eq "Ready"
    }
    $supheliGorevler = @()
    foreach ($g in $gorevler) {
        $eylem = ($g.Actions | Where-Object { $_.Execute } | Select-Object -First 1).Execute
        if ($eylem -match "temp|appdata\\local\\temp|%temp%|\.vbs|\.ps1|cmd\.exe /c") {
            $supheliGorevler += $g
        }
    }
    if ($supheliGorevler) {
        Yaz ("  {0} suphe uyandiran gorev:" -f $supheliGorevler.Count) Red
        $supheliGorevler | ForEach-Object { Write-Host ("    {0}{1}" -f $_.TaskPath,$_.TaskName) -ForegroundColor Red }
    } else { Yaz "  Suphe uyandiran zamanlanmis gorev yok." Green }

    # Kayıt defteri orphan anahtarları (temel tarama)
    Write-Host ""; Write-Host "  ── Kayit Defteri Artik Anahtarlar (Temel)" -ForegroundColor Cyan
    $uninstallYol = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    $orphan = Get-ChildItem $uninstallYol -ErrorAction SilentlyContinue | ForEach-Object {
        $prop = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
        if ($prop.InstallLocation -and -not (Test-Path $prop.InstallLocation)) {
            [PSCustomObject]@{ Ad=$prop.DisplayName; Yol=$prop.InstallLocation }
        }
    } | Where-Object { $_ -ne $null }
    if ($orphan) {
        Yaz ("  {0} artik kayit bulundu (kurulum klasoru silindi ama kayit kaliyor):" -f @($orphan).Count) Yellow
        $orphan | Where-Object { $_.Ad } | Select-Object -First 10 | ForEach-Object {
            Write-Host ("    {0}" -f $_.Ad) -ForegroundColor DarkGray
        }
        Yaz "  Temizlemek icin: Uninstall araclarini kullanin (Revo Uninstaller vb.)" Gray
    } else { Yaz "  Kayit defteri temiz gorunuyor." Green }
}

#endregion

#region ── MODUL 18: GELİŞTİRİCİ ARAÇLARI ──────────────────

function GelistiriciAraclari {
    Baslik "Gelistirici Araclari Temizligi" "18"
    $topKazan = 0L
    $hedef    = "C:\Users\$env:USERNAME"

    # node_modules
    Write-Host "  ── node_modules Tarayici" -ForegroundColor Cyan
    Yaz "  Taranıyor (bu biraz uzun surebilir)..." Gray
    $nodeModules = Get-ChildItem -Path $hedef -Recurse -Directory -Filter "node_modules" -ErrorAction SilentlyContinue |
                   Where-Object { $_.FullName -notmatch "node_modules\\node_modules" }
    if ($nodeModules) {
        $toplam = 0L
        $nodeModules | ForEach-Object {
            $boy = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            $toplam += $boy
            Write-Host ("    {0,-12}  {1}" -f (BoyutFormatla $boy),$_.FullName) -ForegroundColor Yellow
        }
        Write-Host ("  Toplam node_modules: {0}" -f (BoyutFormatla $toplam)) -ForegroundColor Cyan
        if (Onay "Tum node_modules klasorleri silinsin mi? (npm install ile geri yuklenir)") {
            $nodeModules | ForEach-Object {
                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
                Yaz ("  Silindi: {0}" -f $_.FullName) DarkGray
            }
            $topKazan += $toplam; Yaz "  node_modules temizlendi." Green
        }
    } else { Yaz "  node_modules bulunamadi." Green }

    # bin / obj klasörleri
    Write-Host ""; Write-Host "  ── Visual Studio bin/obj Klasorleri" -ForegroundColor Cyan
    $binObj = @()
    @("bin","obj") | ForEach-Object {
        $klasorAdi = $_
        Get-ChildItem -Path $hedef -Recurse -Directory -Filter $klasorAdi -ErrorAction SilentlyContinue |
            Where-Object { Test-Path (Join-Path (Split-Path $_.FullName) "*.csproj") -ErrorAction SilentlyContinue } |
            ForEach-Object { $binObj += $_ }
    }
    if ($binObj) {
        $toplam = 0L
        $binObj | ForEach-Object {
            $boy = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            $toplam += $boy
            Write-Host ("    {0,-12}  {1}" -f (BoyutFormatla $boy),$_.FullName) -ForegroundColor Yellow
        }
        Write-Host ("  Toplam bin/obj: {0}" -f (BoyutFormatla $toplam)) -ForegroundColor Cyan
        if (Onay "bin/obj klasorleri silinsin mi? (dotnet build ile geri yuklenir)") {
            $binObj | ForEach-Object {
                Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
            }
            $topKazan += $toplam; Yaz "  bin/obj temizlendi." Green
        }
    } else { Yaz "  bin/obj bulunamadi." Green }

    # NuGet cache
    Write-Host ""; Write-Host "  ── NuGet Paket Cache" -ForegroundColor Cyan
    $nugetCache = "$env:USERPROFILE\.nuget\packages"
    if (Test-Path $nugetCache) {
        $boy = (Get-ChildItem $nugetCache -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        Durum "  NuGet Cache" (BoyutFormatla $boy) Yellow
        if ($boy -gt 500MB -and (Onay "NuGet cache temizlensin mi?")) {
            Remove-Item "$nugetCache\*" -Recurse -Force -ErrorAction SilentlyContinue
            $topKazan += $boy; Yaz "  NuGet cache temizlendi." Green
        }
    }

    # pip cache
    Write-Host ""; Write-Host "  ── Python pip Cache" -ForegroundColor Cyan
    $pipCache = "$env:LOCALAPPDATA\pip\Cache"
    if (Test-Path $pipCache) {
        $boy = (Get-ChildItem $pipCache -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
        Durum "  pip Cache" (BoyutFormatla $boy) Yellow
        if (Onay "pip cache temizlensin mi?") {
            Remove-Item "$pipCache\*" -Recurse -Force -ErrorAction SilentlyContinue
            $topKazan += $boy; Yaz "  pip cache temizlendi." Green
        }
    }

    # .git repo analizi
    Write-Host ""; Write-Host "  ── Git Repo Boyut Analizi" -ForegroundColor Cyan
    $gitRepos = Get-ChildItem -Path $hedef -Recurse -Directory -Filter ".git" -ErrorAction SilentlyContinue |
                Where-Object { $_.FullName -notmatch "\.git\\.git" }
    if ($gitRepos) {
        $gitRepos | ForEach-Object {
            $repoKok = Split-Path $_.FullName
            $boy     = (Get-ChildItem $repoKok -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            Write-Host ("    {0,-12}  {1}" -f (BoyutFormatla $boy),$repoKok) -ForegroundColor Gray
        }
        Yaz "  Temizlemek icin: git gc --aggressive --prune=now" Gray
    } else { Yaz "  Git repo bulunamadi." Gray }

    # WSL disk optimizasyonu
    Write-Host ""; Write-Host "  ── WSL2 Disk Optimizasyonu" -ForegroundColor Cyan
    $wslDisk = @(
        "$env:USERPROFILE\AppData\Local\Packages\CanonicalGroupLimited.Ubuntu*\LocalState\ext4.vhdx"
        "$env:USERPROFILE\AppData\Local\Packages\*Ubuntu*\LocalState\ext4.vhdx"
    ) | ForEach-Object { Get-Item $_ -ErrorAction SilentlyContinue } | Select-Object -First 1

    if ($wslDisk) {
        $boy = $wslDisk.Length
        Durum "  WSL vhdx boyutu" (BoyutFormatla $boy) $(if ($boy -gt 10GB){"Yellow"} else {"Green"})
        if ($boy -gt 5GB -and (Onay "WSL2 diski optimize edilsin mi? (WSL kapatilacak)")) {
            wsl --shutdown 2>$null | Out-Null
            Start-Sleep 2
            $diskpartScript = "select vdisk file=`"$($wslDisk.FullName)`"`nattach vdisk readonly`ncompact vdisk`ndetach vdisk`nexit"
            $tmpScript = "$env:TEMP\wsl_compact.txt"
            $diskpartScript | Out-File $tmpScript -Encoding ascii
            diskpart /s $tmpScript | Out-Null
            Remove-Item $tmpScript -Force -ErrorAction SilentlyContinue
            Yaz "  WSL2 diski optimize edildi." Green
        }
    } else { Yaz "  WSL2 kurulu degil veya vhdx bulunamadi." Gray }

    # Docker temizliği
    Write-Host ""; Write-Host "  ── Docker Temizligi" -ForegroundColor Cyan
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if ($docker) {
        $images = docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" 2>$null
        if ($images) {
            Yaz "  Docker image'lari:" Gray
            $images | Select-Object -First 10 | ForEach-Object { Write-Host ("    {0}" -f $_) -ForegroundColor DarkGray }
            if (Onay "Kullanilmayan Docker image/container/volume silinsin mi? (docker system prune)") {
                docker system prune -f 2>&1 | ForEach-Object { Yaz ("  {0}" -f $_) DarkGray }
                Yaz "  Docker temizlendi." Green
            }
        }
    } else { Yaz "  Docker yuklu degil." Gray }

    Write-Host ""
    Write-Host ("  Toplam gelistirici temizlik kazanimi: {0}" -f (BoyutFormatla $topKazan)) -ForegroundColor Green
    Add-Content $LOG_DOSYA ("Gelistirici temizlik: {0}" -f (BoyutFormatla $topKazan))
}

#endregion

#region ── MODUL 19: DONANIM RAPORU ─────────────────────────

function DonanımRaporu {
    Baslik "Donanim Raporu" "19"

    # BIOS / Firmware
    Write-Host "  ── BIOS / Firmware" -ForegroundColor Cyan
    $bios = Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue
    $mb   = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue
    if ($bios) {
        Durum "  BIOS Surum"     $bios.SMBIOSBIOSVersion
        Durum "  BIOS Tarihi"    $bios.ReleaseDate.ToString("dd.MM.yyyy")
        Durum "  Uretici"        $bios.Manufacturer
    }
    if ($mb) { Durum "  Anakart" ("{0} {1}" -f $mb.Manufacturer,$mb.Product) }

    # Güç tüketimi raporu
    Write-Host ""; Write-Host "  ── Guc ve Pil Raporu" -ForegroundColor Cyan
    $pil = Get-WmiObject Win32_Battery -ErrorAction SilentlyContinue
    if ($pil) {
        Durum "  Pil Durumu"   $pil.Status
        Durum "  Sarj Seviyesi" ("%{0}" -f $pil.EstimatedChargeRemaining) $(if ($pil.EstimatedChargeRemaining -lt 20){"Red"} elseif ($pil.EstimatedChargeRemaining -lt 50){"Yellow"} else {"Green"})
        if (YoneticiKontrol) {
            $enerjiRapor = "$env:TEMP\energy_report.html"
            powercfg /energy /output $enerjiRapor /duration 10 2>$null | Out-Null
            if (Test-Path $enerjiRapor) {
                Yaz "  Guc raporu olusturuldu." Green
                Copy-Item $enerjiRapor "$LOG_KLASOR\EnerjiRaporu.html" -ErrorAction SilentlyContinue
                Durum "  Rapor Yolu" "$LOG_KLASOR\EnerjiRaporu.html" Cyan
            }
        }
    } else { Yaz "  Pil bulunamadi (masaustu sistem)." Gray }

    # USB cihaz geçmişi
    Write-Host ""; Write-Host "  ── USB Cihaz Gecmisi" -ForegroundColor Cyan
    $usbKayitlar = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\*\*" -ErrorAction SilentlyContinue |
                   Where-Object { $_.FriendlyName } |
                   Select-Object FriendlyName, Mfg -Unique |
                   Sort-Object FriendlyName |
                   Select-Object -First 20
    if ($usbKayitlar) {
        Yaz ("  {0} adet kayitli USB cihaz:" -f @($usbKayitlar).Count) Gray
        $usbKayitlar | ForEach-Object {
            Write-Host ("    {0}" -f $_.FriendlyName) -ForegroundColor DarkGray
        }
    }

    # Termal throttling tespiti
    Write-Host ""; Write-Host "  ── Termal & Performans Analizi" -ForegroundColor Cyan
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    if ($cpu.CurrentClockSpeed -lt ($cpu.MaxClockSpeed * 0.7)) {
        Yaz ("  !! CPU mevcut hız: {0} MHz / Maksimum: {1} MHz — Termal throttling olabilir!" -f $cpu.CurrentClockSpeed,$cpu.MaxClockSpeed) Red
    } else {
        Durum "  CPU Hiz Durumu" ("{0}/{1} MHz — Normal" -f $cpu.CurrentClockSpeed,$cpu.MaxClockSpeed) Green
    }

    # Sistem tipi bilgisi
    Write-Host ""; Write-Host "  ── Sistem Ozeti" -ForegroundColor Cyan
    $cs = Get-CimInstance Win32_ComputerSystem
    Durum "  Sistem Tipi"   $cs.SystemType
    Durum "  Uretici"       $cs.Manufacturer
    Durum "  Model"         $cs.Model
    Durum "  Windows Surumu" (Get-CimInstance Win32_OperatingSystem).Caption
    $winAktif = (Get-WmiObject SoftwareLicensingProduct -ErrorAction SilentlyContinue | Where-Object { $_.PartialProductKey -and $_.LicenseStatus -eq 1 }).Count -gt 0
    Durum "  Lisans Durumu"  $(if ($winAktif){"Aktif / Orijinal"} else {"Kontrol Gerekiyor"}) $(if ($winAktif){"Green"} else {"Yellow"})
}

#endregion

#region ── MODUL 20: HTML DASHBOARD ─────────────────────────

function HtmlDashboard {
    Baslik "HTML Dashboard Olusturuluyor" "20"
    Yaz "  Tum veriler toplanıyor..." Gray

    $os      = Get-CimInstance Win32_OperatingSystem
    $cpu     = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name.Trim()
    $ramTop  = $os.TotalVisibleMemorySize * 1KB
    $ramBos  = $os.FreePhysicalMemory * 1KB
    $ramYuz  = [int](( ($ramTop-$ramBos) / $ramTop) * 100)
    $cDisk   = Get-PSDrive -Name C -ErrorAction SilentlyContinue
    $cYuz    = if ($cDisk) { [int](($cDisk.Used/($cDisk.Used+$cDisk.Free))*100) } else { 0 }
    $uptime  = (Get-Date) - $os.LastBootUpTime
    $sure    = [int]((Get-Date) - $global:BaslangicZamani).TotalMinutes
    $topSkor = 0; $topMax = 0
    $global:SkorBilesenleri.GetEnumerator() | ForEach-Object { $topSkor += $_.Value.Puan; $topMax += $_.Value.Max }
    $genelSkor = if ($topMax -gt 0) { [int](($topSkor/$topMax)*100) } else { 0 }
    $skorRenk  = if ($genelSkor -ge 80){"#4caf50"} elseif ($genelSkor -ge 60){"#EF9F27"} else {"#E24B4A"}

    $skorDetay = ($global:SkorBilesenleri.GetEnumerator() | ForEach-Object {
        $p   = $_.Value.Puan
        $m   = $_.Value.Max
        $yuz = if ($m -gt 0){[int](($p/$m)*100)} else {0}
        $r   = if ($yuz -ge 80){"#4caf50"} elseif ($yuz -ge 50){"#EF9F27"} else {"#E24B4A"}
        "<tr><td style='padding:6px 12px;font-size:13px;'>$($_.Key)</td><td style='padding:6px 12px;'><span style='background:$r;color:#fff;padding:2px 10px;border-radius:99px;font-size:12px;'>$p/$m</span></td></tr>"
    }) -join ""

    $html = @"
<!DOCTYPE html>
<html lang="tr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Sistem Bakim Raporu — $($env:COMPUTERNAME) — $(Get-Date -Format "dd.MM.yyyy HH:mm")</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#f5f5f7;color:#1d1d1f;min-height:100vh;padding:2rem}
  .container{max-width:900px;margin:0 auto}
  h1{font-size:28px;font-weight:600;margin-bottom:4px}
  .sub{font-size:14px;color:#6e6e73;margin-bottom:2rem}
  .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px;margin-bottom:2rem}
  .card{background:#fff;border-radius:14px;padding:20px 22px;border:0.5px solid #e0e0e0}
  .card-lbl{font-size:12px;color:#6e6e73;margin-bottom:6px}
  .card-val{font-size:26px;font-weight:600}
  .card-sub{font-size:12px;color:#6e6e73;margin-top:4px}
  .skor-circle{width:120px;height:120px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:36px;font-weight:700;color:#fff;margin:0 auto 16px;background:conic-gradient($skorRenk ${genelSkor}%, #e0e0e0 0)}
  .bar-wrap{background:#e0e0e0;border-radius:99px;height:8px;margin-top:8px;overflow:hidden}
  .bar-fill{height:100%;border-radius:99px;transition:width 1s}
  .sec-title{font-size:16px;font-weight:600;margin:2rem 0 1rem}
  table{width:100%;border-collapse:collapse;background:#fff;border-radius:14px;overflow:hidden;border:0.5px solid #e0e0e0}
  th{background:#f5f5f7;padding:10px 12px;font-size:12px;color:#6e6e73;text-align:left;font-weight:500}
  tr:not(:last-child) td{border-bottom:0.5px solid #e0e0e0}
  .tag{display:inline-block;padding:2px 10px;border-radius:99px;font-size:11px;font-weight:500}
  .tag-ok{background:#eaf3de;color:#3B6D11}
  .tag-warn{background:#faeeda;color:#854F0B}
  .tag-err{background:#fcebeb;color:#A32D2D}
  footer{margin-top:3rem;text-align:center;font-size:12px;color:#6e6e73}
</style>
</head>
<body>
<div class="container">
  <h1>Sistem Bakim Raporu</h1>
  <div class="sub">$($env:COMPUTERNAME) · $($env:USERNAME) · $(Get-Date -Format "dd MMMM yyyy, HH:mm") · Sure: $sure dakika</div>

  <div class="grid">
    <div class="card">
      <div class="card-lbl">Genel Saglik Skoru</div>
      <div class="card-val" style="color:$skorRenk">$genelSkor / 100</div>
      <div class="bar-wrap"><div class="bar-fill" style="width:${genelSkor}%;background:$skorRenk"></div></div>
    </div>
    <div class="card">
      <div class="card-lbl">C: Disk Dolulugu</div>
      <div class="card-val" style="color:$(if($cYuz-gt 85){'#E24B4A'} elseif($cYuz-gt 60){'#EF9F27'} else{'#4caf50'})">%$cYuz</div>
      <div class="bar-wrap"><div class="bar-fill" style="width:${cYuz}%;background:$(if($cYuz-gt 85){'#E24B4A'} elseif($cYuz-gt 60){'#EF9F27'} else{'#4caf50'})"></div></div>
    </div>
    <div class="card">
      <div class="card-lbl">RAM Kullanimi</div>
      <div class="card-val" style="color:$(if($ramYuz-gt 85){'#E24B4A'} elseif($ramYuz-gt 65){'#EF9F27'} else{'#4caf50'})">%$ramYuz</div>
      <div class="bar-wrap"><div class="bar-fill" style="width:${ramYuz}%;background:$(if($ramYuz-gt 85){'#E24B4A'} elseif($ramYuz-gt 65){'#EF9F27'} else{'#4caf50'})"></div></div>
    </div>
    <div class="card">
      <div class="card-lbl">Sistem Acik Sure</div>
      <div class="card-val">$($uptime.Days)g $($uptime.Hours)s</div>
      <div class="card-sub">$(if($uptime.Days -gt 7){'Yeniden baslat onerilir'} else{'Normal'})</div>
    </div>
  </div>

  <div class="sec-title">Skor Dagilimi</div>
  <table>
    <tr><th>Kategori</th><th>Puan</th></tr>
    $skorDetay
  </table>

  <div class="sec-title">Sistem Bilgisi</div>
  <table>
    <tr><th>Bilesken</th><th>Deger</th></tr>
    <tr><td style='padding:8px 12px;font-size:13px;'>Islemci</td><td style='padding:8px 12px;font-size:13px;'>$cpu</td></tr>
    <tr><td style='padding:8px 12px;font-size:13px;'>RAM</td><td style='padding:8px 12px;font-size:13px;'>$(BoyutFormatla $ramTop)</td></tr>
    <tr><td style='padding:8px 12px;font-size:13px;'>Isletim Sistemi</td><td style='padding:8px 12px;font-size:13px;'>$($os.Caption)</td></tr>
    <tr><td style='padding:8px 12px;font-size:13px;'>Bilgisayar Adi</td><td style='padding:8px 12px;font-size:13px;'>$($env:COMPUTERNAME)</td></tr>
    <tr><td style='padding:8px 12px;font-size:13px;'>Bakim Tarihi</td><td style='padding:8px 12px;font-size:13px;'>$(Get-Date -Format "dd.MM.yyyy HH:mm")</td></tr>
  </table>

  <footer>SistemBakim v$SURUM &nbsp;·&nbsp; Tüm haklar saklıdır &nbsp;·&nbsp; $($env:COMPUTERNAME)</footer>
</div>
</body>
</html>
"@

    $html | Out-File -FilePath $HTML_RAPOR -Encoding UTF8 -Force
    Yaz ""
    Write-Host ("  HTML Rapor olusturuldu: {0}" -f $HTML_RAPOR) -ForegroundColor Green
    if (Onay "Rapor tarayicide acilsin mi?") {
        Start-Process $HTML_RAPOR
    }
}

#endregion

#region ── MODUL 21: SAĞLIK SKORU ───────────────────────────

function SaglikSkoru {
    Baslik "Sistem Saglik Skoru (100 Puan)" "21"

    if ($global:SkorBilesenleri.Count -eq 0) {
        Yaz "  Henuz hicbir modul calistirilmadi." Yellow
        Yaz "  Once en az su modulleri calistir: 4, 9, 11, 16" Gray
        return
    }

    $topSkor = 0; $topMax = 0
    $global:SkorBilesenleri.GetEnumerator() | ForEach-Object { $topSkor += $_.Value.Puan; $topMax += $_.Value.Max }
    $genelSkor = if ($topMax -gt 0) { [int](($topSkor/$topMax)*100) } else { 0 }

    Write-Host ""
    $skBar = "[" + ("█" * [int]($genelSkor/5)) + ("░" * (20-[int]($genelSkor/5))) + "]"
    $skRenk = if ($genelSkor -ge 80){"Green"} elseif ($genelSkor -ge 60){"Yellow"} else {"Red"}
    Write-Host ("  {0}  {1}/100" -f $skBar,$genelSkor) -ForegroundColor $skRenk

    $yorumMetin = if     ($genelSkor -ge 90) { "MUKKEMMEL — Sisteminiz cok iyi durumda." }
                  elseif ($genelSkor -ge 80) { "IYI — Kucuk iyilestirmeler yapilabilir." }
                  elseif ($genelSkor -ge 60) { "ORTA — Birkac onemli sorun giderilmeli." }
                  elseif ($genelSkor -ge 40) { "KOTU — Dikkat gerektiren sorunlar var." }
                  else                        { "KRITIK — Hemen mudahale gerekli!" }

    Write-Host ""
    Write-Host ("  {0}" -f $yorumMetin) -ForegroundColor $skRenk
    Write-Host ""
    Write-Host "  Puan Dagilimi:" -ForegroundColor DarkGray
    $global:SkorBilesenleri.GetEnumerator() | ForEach-Object {
        $p   = $_.Value.Puan; $m = $_.Value.Max
        $yuz = if ($m -gt 0) { [int](($p/$m)*100) } else { 0 }
        $r   = if ($yuz -ge 80){"Green"} elseif ($yuz -ge 50){"Yellow"} else {"Red"}
        $bar = "[" + ("█" * [int]($yuz/10)) + ("░" * (10-[int]($yuz/10))) + "]"
        Write-Host ("    {0,-25} {1} {2}/{3}" -f $_.Key,$bar,$p,$m) -ForegroundColor $r
        Add-Content $LOG_DOSYA ("  [Skor] {0}: {1}/{2}" -f $_.Key,$p,$m)
    }

    # Geçmişe kaydet
    $gecmis = @()
    if (Test-Path $SKOR_DOSYA) {
        try { $gecmis = Get-Content $SKOR_DOSYA | ConvertFrom-Json } catch {}
    }
    $yeniKayit = [PSCustomObject]@{ Tarih=(Get-Date -Format "dd.MM.yyyy HH:mm"); Skor=$genelSkor }
    $gecmis   += $yeniKayit
    $gecmis    = $gecmis | Select-Object -Last 20
    $gecmis | ConvertTo-Json | Out-File $SKOR_DOSYA -Encoding UTF8

    # Geçmiş trend
    if (@($gecmis).Count -gt 1) {
        Write-Host ""; Write-Host "  Son Skor Gecmisi:" -ForegroundColor DarkGray
        $gecmis | Select-Object -Last 5 | ForEach-Object {
            $r = if ($_.Skor -ge 80){"Green"} elseif ($_.Skor -ge 60){"Yellow"} else {"Red"}
            Write-Host ("    [{0}]  {1}/100" -f $_.Tarih,$_.Skor) -ForegroundColor $r
        }
    }

    Add-Content $LOG_DOSYA ("GENEL SKOR: {0}/100 — {1}" -f $genelSkor,$yorumMetin)
}

#endregion

#region ── MODUL 22: OTOMASYON ──────────────────────────────

function OtomasyonAyarla {
    Baslik "Haftalik Otomatik Bakim Zamanlayici" "22"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    $scriptYolu = $PSCommandPath
    if (-not $scriptYolu) { $scriptYolu = "$env:USERPROFILE\Desktop\SistemBakim_v5.ps1" }

    Write-Host "  Bu modul haftalik sessiz bir bakim gorevi kurar:" -ForegroundColor Gray
    Write-Host "  - Her Pazar sabahi 03:00'da calisir"
    Write-Host "  - Kapsamli temp temizligi yapar"
    Write-Host "  - Servisleri kontrol eder"
    Write-Host "  - Log dosyasina kaydeder"
    Write-Host ""

    if (-not (Onay "Haftalik bakim gorevi kurulsun mu?")) { return }

    # Sessiz temizlik script'i oluştur
    $sessizScript = @"
# SistemBakim — Sessiz Haftalik Bakim
Set-StrictMode -Version Latest; `$ErrorActionPreference = "SilentlyContinue"
`$LOG = "`$env:USERPROFILE\Desktop\BakimRaporlari\OtoBakim_`$(Get-Date -Format 'yyyyMMdd').log"
Add-Content `$LOG "OTO-BAKIM BASLADI: `$(Get-Date)"
# Temp temizlik
@("`$env:TEMP","C:\Windows\Temp","C:\Windows\Prefetch") | ForEach-Object { if(Test-Path `$_){Get-ChildItem `$_ -Recurse -Force -ErrorAction SilentlyContinue | Where-Object{-not `$_.PSIsContainer} | Remove-Item -Force -ErrorAction SilentlyContinue} }
# DNS flush
ipconfig /flushdns | Out-Null
# Servis kontrol
@("wuauserv","BITS","WinDefend") | ForEach-Object { `$s=Get-Service -Name `$_ -ErrorAction SilentlyContinue; if(`$s -and `$s.Status -ne "Running"){Start-Service `$_ -ErrorAction SilentlyContinue} }
Add-Content `$LOG "OTO-BAKIM TAMAMLANDI: `$(Get-Date)"
"@

    $sessizYol = "$env:USERPROFILE\Desktop\BakimRaporlari\oto_bakim.ps1"
    $sessizScript | Out-File $sessizYol -Encoding UTF8 -Force

    # Task Scheduler görevi
    $eylem  = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$sessizYol`""
    $tetik  = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "03:00"
    $ayarlar = New-ScheduledTaskSettingsSet -RunOnlyIfIdle -WakeToRun -AllowStartIfOnBatteries

    try {
        Register-ScheduledTask -TaskName "SistemBakim_Haftalik" -Action $eylem -Trigger $tetik -Settings $ayarlar -RunLevel Highest -Force -ErrorAction Stop | Out-Null
        Yaz "  Gorev kuruldu: Her Pazar 03:00 — 'SistemBakim_Haftalik'" Green
        Yaz ("  Sessiz script: {0}" -f $sessizYol) Cyan
    } catch {
        Yaz ("  Gorev kurulamadi: {0}" -f $_) Red
    }

    # Mevcut görevleri listele
    Write-Host ""; Write-Host "  Mevcut bakim gorevleri:" -ForegroundColor DarkGray
    Get-ScheduledTask -TaskName "SistemBakim*" -ErrorAction SilentlyContinue | ForEach-Object {
        Durum ("  {0}" -f $_.TaskName) $_.State
    }
}

#endregion

#region ── MODUL 23: PROFİL SİSTEMİ ────────────────────────

function ProfilSec {
    Baslik "Hazir Profil Sistemi" "23"
    Write-Host @"

  ┌──────────────────────────────────────────────────────────────┐
  │                                                              │
  │  [1]  OYUN ONCESI HAZIRLIK  (~5 dk)                         │
  │       Temp temizle, guc plani max, DNS temizle,             │
  │       startup kontrol, servisleri duzelt                    │
  │                                                              │
  │  [2]  HAFTALIK BAKIM  (~15 dk)                              │
  │       Kapsamli temizlik, disk analizi, servis               │
  │       kontrolu, guvenlik kontrol, skor guncelle             │
  │                                                              │
  │  [3]  HIZLI TEMIZLIK  (~2 dk)                               │
  │       Sadece temp ve DNS — hizlica yer ac                   │
  │                                                              │
  │  [4]  GELISTIRICI BAKIM  (~10 dk)                           │
  │       node_modules, bin/obj, NuGet, pip,                    │
  │       git, Docker, WSL temizligi                            │
  │                                                              │
  │  [5]  GUVENLIK TARAMASI  (~8 dk)                            │
  │       Hosts tarama, port analizi, Defender,                 │
  │       zamanlanmis gorev tarama, BitLocker                   │
  │                                                              │
  │  [6]  OYUN SONU / NORMAL MODA DON  (~1 dk)                 │
  │       FPS tweakler geri al, dengeli guc plani,              │
  │       servisler normale don                                  │
  │                                                              │
  │  [7]  FORMAT SONRASI  (~5-10 dk)                            │
  │       Yeni format atilmis PC'yi tek tikla optimize et       │
  │       Bloatware sil + tweak + DNS + FPS + RAM + pagefile    │
  │                                                              │
  │   0   Ana menu                                              │
  └──────────────────────────────────────────────────────────────┘
"@ -ForegroundColor DarkCyan
    Write-Host "  Profil secin: " -ForegroundColor Yellow -NoNewline
    $sec = Read-Host

    switch ($sec) {
        "1" {
            Yaz "  [OYUN ONCESI] Baslıyor..." Cyan
            GeriYuklemeNoktasi
            KapsamliTemizlik
            GucPlani
            FpsOyunOptimizasyonu -OtomatikUygula
            RamOptimizasyonu -OtomatikUygula
            SurecTemizleyici -OtomatikUygula
            ServisKontrol
            BaslangicAnalizi
            Yaz "  Oyun oncesi hazirlik tamamlandi. Iyi oyunlar!" Green
        }
        "2" {
            Yaz "  [HAFTALIK BAKIM] Baslıyor..." Cyan
            GeriYuklemeNoktasi
            KapsamliTemizlik
            DiskAnalizi
            ServisKontrol
            GuvenlikKontrol
            OlayGunlugu
            SaglikSkoru
            HtmlDashboard
        }
        "3" {
            Yaz "  [HIZLI TEMIZLIK] Baslıyor..." Cyan
            @($env:TEMP,"C:\Windows\Temp","C:\Windows\Prefetch") | ForEach-Object {
                if (Test-Path $_) {
                    Get-ChildItem $_ -Recurse -Force -ErrorAction SilentlyContinue |
                        Where-Object { -not $_.PSIsContainer } | Remove-Item -Force -ErrorAction SilentlyContinue
                }
            }
            ipconfig /flushdns | Out-Null
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Yaz "  Hizli temizlik tamamlandi." Green
        }
        "4" {
            Yaz "  [GELISTIRICI BAKIM] Baslıyor..." Cyan
            GelistiriciAraclari
        }
        "5" {
            Yaz "  [GUVENLIK TARAMASI] Baslıyor..." Cyan
            GuvenlikKontrol
            GelismisGuvenlik
        }
        "6" {
            Yaz "  [OYUN SONU] Normal moda donuluyor..." Cyan
            Write-Host ""

            Write-Host "  -- FPS tweakler geri aliniyor..." -ForegroundColor Gray
            FpsOyunOptimizasyonu -OtomatikGeriAl

            Write-Host "  -- Dengeli guc plani yukleniyor..." -ForegroundColor Gray
            powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null
            Yaz "    Dengeli plan aktif." Green

            Write-Host "  -- Servisler kontrol ediliyor..." -ForegroundColor Gray
            $servisler = @("SysMain","WSearch","wuauserv","wscsvc")
            foreach ($svc in $servisler) {
                $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
                if ($s -and $s.Status -ne "Running") {
                    Start-Service -Name $svc -ErrorAction SilentlyContinue
                    Yaz ("    {0} yeniden baslatildi." -f $svc) Green
                }
            }

            Write-Host ""
            Write-Host ("  " + ("=" * 50)) -ForegroundColor Cyan
            Yaz "  Normal moda basariyla donuldu." Cyan
            Yaz "  Oturum kapanip acilirsa tum degisiklikler tam gercerli olur." DarkGray
            Write-Host ("  " + ("=" * 50)) -ForegroundColor Cyan
        }
        "7" {
            Yaz "  [FORMAT SONRASI] Sihirbaz baslatiliyor..." Cyan
            FormatSonrasiSihirbaz
        }
        default { return }
    }
}

#endregion

#region ── MODUL 24: GERİ YÜKLEME ───────────────────────────

function GeriYuklemeNoktasi {
    Baslik "Geri Yukleme Noktasi" "24"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }
    $etiket = "SistemBakim_v{0}_{1}" -f $SURUM,(Get-Date -Format "ddMMyyyy_HHmm")
    try {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop
        Checkpoint-Computer -Description $etiket -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
        Durum "Olusturuldu" $etiket Green
    } catch { Yaz ("  Hata: {0}" -f $_) Red }
    $noktalar = Get-ComputerRestorePoint | Select-Object -Last 5
    if ($noktalar) {
        Write-Host ""; Yaz "  Son 5 nokta:" Gray
        $noktalar | ForEach-Object { Yaz ("    [{0}]  {1}" -f $_.CreationTime.ToString("dd.MM.yyyy HH:mm"),$_.Description) DarkGray }
    }
}

#endregion

#region ── MODUL 25: TAM BAKIM ──────────────────────────────

function TamBakim {
    Baslik "TAM BAKIM — TUM MODULLER" "25"
    Write-Host "  Toplam sure tahmini: 45-90 dakika" -ForegroundColor Yellow
    if (-not (Onay "Tum moduller sirayla calistirilsin mi?")) { return }

    $adimlari = @(
        @{Ad="Geri Yukleme Noktasi"; Fn={GeriYuklemeNoktasi}}
        @{Ad="Kapsamli Temizlik";    Fn={KapsamliTemizlik}}
        @{Ad="Disk Analizi";         Fn={DiskAnalizi}}
        @{Ad="Crash Dump Temizle";   Fn={CrashDumpTemizle}}
        @{Ad="Windows Log Temizle";  Fn={WindowsLogTemizle}}
        @{Ad="Shadow & Restore";     Fn={ShadowVeRestore}}
        @{Ad="Downloads Analizi";    Fn={DownloadsAnalizi}}
        @{Ad="SMART Disk Sagligi";   Fn={SmartDiskSagligi}}
        @{Ad="Sistem Tarama";        Fn={SistemTara}}
        @{Ad="Olay Gunlugu";         Fn={OlayGunlugu}}
        @{Ad="Servis Kontrolu";      Fn={ServisKontrol}}
        @{Ad="Baslangic Analizi";    Fn={BaslangicAnalizi}}
        @{Ad="Kaynak Durumu";        Fn={KaynakDurumu}}
        @{Ad="Ag Tanilamasi";        Fn={AgTanilamasi}}
        @{Ad="Guvenlik Kontrolu";    Fn={GuvenlikKontrol}}
        @{Ad="Gelismis Guvenlik";    Fn={GelismisGuvenlik}}
        @{Ad="Gelistirici Araclari"; Fn={GelistiriciAraclari}}
        @{Ad="Donanim Raporu";       Fn={DonanımRaporu}}
    )

    $toplam = $adimlari.Count; $i = 0
    foreach ($adim in $adimlari) {
        $i++
        Write-Host ("  [{0}/{1}] {2}..." -f $i,$toplam,$adim.Ad) -ForegroundColor Cyan
        & $adim.Fn
    }

    SaglikSkoru
    HtmlDashboard

    Write-Host ""
    Write-Host ("  " + ("═" * 62)) -ForegroundColor Green
    Write-Host "  TAM BAKIM v$SURUM TAMAMLANDI" -ForegroundColor Green
    Write-Host ("  Log    : {0}" -f $LOG_DOSYA) -ForegroundColor Cyan
    Write-Host ("  Rapor  : {0}" -f $HTML_RAPOR) -ForegroundColor Cyan
    Write-Host ("  Sure   : {0} dakika" -f [int]((Get-Date)-$global:BaslangicZamani).TotalMinutes)
    Write-Host ("  " + ("═" * 62)) -ForegroundColor Green
    Add-Content $LOG_DOSYA ("TAM BAKIM TAMAMLANDI: {0}" -f (Get-Date -Format "HH:mm:ss"))
}

#endregion

#region ── MODUL 26: FPS & OYUN OPTİMİZASYONU ──────────────

function FpsOyunOptimizasyonu {
    param([switch]$OtomatikUygula, [switch]$OtomatikGeriAl)

    Baslik "FPS ve Oyun Optimizasyonu" "26"

    if (-not (YoneticiKontrol)) {
        Yaz "  Bu modul icin Yonetici yetkisi gereklidir!" Red
        return
    }

    Write-Host ""
    Write-Host "  Asagidaki optimizasyonlar uygulanir / geri alinir:" -ForegroundColor Cyan
    Write-Host "  ---------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "   Game DVR ve Xbox Yakalama        devre disi / aktif" -ForegroundColor Gray
    Write-Host "   MMCSS Oyun Zamanlama Onceligi    yuksek / normal" -ForegroundColor Gray
    Write-Host "   Ag Kanal Siniri (Throttling)     kaldirilir / eklenir" -ForegroundColor Gray
    Write-Host "   Nagle Algoritmasi (TCP Delay)    devre disi / aktif" -ForegroundColor Gray
    Write-Host "   GPU Hizlandirmali Zamanlama       aktif / varsayilan" -ForegroundColor Gray
    Write-Host "   Gorsel Efektler                  en iyi performans / dengeli" -ForegroundColor Gray
    Write-Host "   Fare 1:1 Ham Giris               aktif / varsayilan" -ForegroundColor Gray
    Write-Host "   Guc Plani                        Ultimate / Dengeli" -ForegroundColor Gray
    Write-Host "   Arka Plan Uygulamalari           kapat / ac" -ForegroundColor Gray
    Write-Host "   Fullscreen Optimizations         devre disi / aktif" -ForegroundColor Gray
    Write-Host "   Seffaflik ve Animasyonlar        kapat / ac" -ForegroundColor Gray
    Write-Host "   Timer Resolution                 optimize / varsayilan" -ForegroundColor Gray
    Write-Host "  ---------------------------------------------------------" -ForegroundColor DarkGray
    if ($OtomatikUygula -or $env:SISTEMBAK_GUI -eq '1') {
        $sec = "1"
    } elseif ($OtomatikGeriAl) {
        $sec = "2"
    } else {
        Write-Host ""
        Write-Host "  [1]  Optimizasyonlari UYGULA  (FPS artisi, oyun onceligi)" -ForegroundColor Green
        Write-Host "  [2]  Optimizasyonlari GERI AL (Windows varsayilanlari)" -ForegroundColor Yellow
        Write-Host "  [0]  Ana menu"
        Write-Host ""
        Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
        $sec = Read-Host
        if ($sec -eq "0" -or ($sec -ne "1" -and $sec -ne "2")) { return }
    }
    $geriAl = ($sec -eq "2")

    Write-Host ""
    if ($geriAl) { Yaz "  Geri alma islemi basliyor..." Yellow }
    else         { Yaz "  FPS optimizasyonlari uygulanıyor..." Cyan }

    # --- 1. Game DVR / Xbox Game Bar ---
    Write-Host "  -- [1/11] Game DVR ve Xbox Yakalama" -ForegroundColor Cyan
    $gameDvrYol = "HKCU:\System\GameConfigStore"
    if (-not (Test-Path $gameDvrYol)) { New-Item -Path $gameDvrYol -Force | Out-Null }

    if ($geriAl) {
        Set-ItemProperty -Path $gameDvrYol -Name "GameDVR_Enabled"                        -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $gameDvrYol -Name "GameDVR_FSEBehaviorMode"                -Value 0 -Type DWord -Force
        Set-ItemProperty -Path $gameDvrYol -Name "GameDVR_HonorUserFSEBehaviorMode"       -Value 0 -Type DWord -Force
        Set-ItemProperty -Path $gameDvrYol -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 0 -Type DWord -Force
        $gameDvrYol2 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
        if (Test-Path $gameDvrYol2) { Set-ItemProperty -Path $gameDvrYol2 -Name "AppCaptureEnabled" -Value 1 -Type DWord -Force }
        Yaz "    Geri alindi." Gray
    } else {
        Set-ItemProperty -Path $gameDvrYol -Name "GameDVR_Enabled"                        -Value 0 -Type DWord -Force
        Set-ItemProperty -Path $gameDvrYol -Name "GameDVR_FSEBehaviorMode"                -Value 2 -Type DWord -Force
        Set-ItemProperty -Path $gameDvrYol -Name "GameDVR_HonorUserFSEBehaviorMode"       -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $gameDvrYol -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Type DWord -Force
        $gameDvrYol2 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
        if (-not (Test-Path $gameDvrYol2)) { New-Item -Path $gameDvrYol2 -Force | Out-Null }
        Set-ItemProperty -Path $gameDvrYol2 -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force
        Yaz "    Devre disi birakildi." Green
    }

    # --- 2. MMCSS Oyun Onceligi + Ag Throttling ---
    Write-Host "  -- [2/11] MMCSS Oyun Onceligi ve Ag Throttling" -ForegroundColor Cyan
    $mmcssYol = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    $oyunYol  = "$mmcssYol\Tasks\Games"
    if (-not (Test-Path $oyunYol)) { New-Item -Path $oyunYol -Force | Out-Null }

    if ($geriAl) {
        Set-ItemProperty -Path $mmcssYol -Name "SystemResponsiveness"  -Value 20         -Type DWord  -Force
        Set-ItemProperty -Path $mmcssYol -Name "NetworkThrottlingIndex" -Value 10         -Type DWord  -Force
        Set-ItemProperty -Path $oyunYol  -Name "GPU Priority"           -Value 2          -Type DWord  -Force
        Set-ItemProperty -Path $oyunYol  -Name "Priority"               -Value 2          -Type DWord  -Force
        Set-ItemProperty -Path $oyunYol  -Name "Scheduling Category"    -Value "Medium"   -Type String -Force
        Set-ItemProperty -Path $oyunYol  -Name "SFIO Priority"          -Value "Normal"   -Type String -Force
        Yaz "    Geri alindi." Gray
    } else {
        Set-ItemProperty -Path $mmcssYol -Name "SystemResponsiveness"  -Value 0           -Type DWord  -Force
        Set-ItemProperty -Path $mmcssYol -Name "NetworkThrottlingIndex" -Value 4294967295  -Type DWord  -Force
        Set-ItemProperty -Path $oyunYol  -Name "Affinity"               -Value 0           -Type DWord  -Force
        Set-ItemProperty -Path $oyunYol  -Name "Background Only"        -Value "False"     -Type String -Force
        Set-ItemProperty -Path $oyunYol  -Name "Clock Rate"             -Value 10000       -Type DWord  -Force
        Set-ItemProperty -Path $oyunYol  -Name "GPU Priority"           -Value 8           -Type DWord  -Force
        Set-ItemProperty -Path $oyunYol  -Name "Priority"               -Value 6           -Type DWord  -Force
        Set-ItemProperty -Path $oyunYol  -Name "Scheduling Category"    -Value "High"      -Type String -Force
        Set-ItemProperty -Path $oyunYol  -Name "SFIO Priority"          -Value "High"      -Type String -Force
        Yaz "    Oyun onceligi arttirildi, ag siniri kaldirildi." Green
    }

    # --- 3. Nagle Algoritmasi + TCP ---
    Write-Host "  -- [3/11] Nagle Algoritmasi ve TCP Optimizasyonu" -ForegroundColor Cyan
    $tcpIf   = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
    $tcpDeger = if ($geriAl) { 0 } else { 1 }
    $nagleSay = 0
    Get-ChildItem $tcpIf -ErrorAction SilentlyContinue | ForEach-Object {
        $dhcpIp = (Get-ItemProperty $_.PSPath -Name "DhcpIPAddress" -ErrorAction SilentlyContinue)."DhcpIPAddress"
        $statIp = (Get-ItemProperty $_.PSPath -Name "IPAddress"     -ErrorAction SilentlyContinue)."IPAddress"
        $herhangiIp = ($dhcpIp -and $dhcpIp -ne "0.0.0.0") -or ($statIp -and $statIp -ne "0.0.0.0")
        if ($herhangiIp) {
            Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value $tcpDeger -Type DWord -Force
            Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay"      -Value $tcpDeger -Type DWord -Force
            $nagleSay++
        }
    }
    netsh int tcp set global ecncapability=disabled  | Out-Null
    netsh int tcp set global timestamps=disabled     | Out-Null
    netsh int tcp set global rss=enabled             | Out-Null
    if ($nagleSay -gt 0) {
        if ($geriAl) { Yaz ("    {0} adaptorde Nagle geri alindi." -f $nagleSay) Gray }
        else         { Yaz ("    {0} adaptorde Nagle devre disi, TCP optimize edildi." -f $nagleSay) Green }
    } else { Yaz "    Aktif ag adaptoru bulunamadi, TCP genel ayarlar uygulandı." Yellow }

    # --- 4. GPU Hizlandirmali Zamanlama (HAGS) ---
    Write-Host "  -- [4/11] GPU Hizlandirmali Zamanlama (HAGS)" -ForegroundColor Cyan
    $hagsYol = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    $hagsVal = if ($geriAl) { 1 } else { 2 }
    try {
        Set-ItemProperty -Path $hagsYol -Name "HwSchMode" -Value $hagsVal -Type DWord -Force
        if ($geriAl) { Yaz "    HAGS geri alindi (varsayilan)." Gray }
        else         { Yaz "    HAGS aktif edildi (Windows 11 + destekli GPU gerektirir)." Green }
    } catch { Yaz "    HAGS ayarlanamadi." Yellow }

    # --- 5. Gorsel Efektler ---
    Write-Host "  -- [5/11] Gorsel Efektler" -ForegroundColor Cyan
    $vfxYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $vfxYol)) { New-Item -Path $vfxYol -Force | Out-Null }
    $vfxVal = if ($geriAl) { 0 } else { 2 }
    Set-ItemProperty -Path $vfxYol -Name "VisualFXSetting" -Value $vfxVal -Type DWord -Force
    if ($geriAl) { Yaz "    Gorsel efektler: Windows secsin (geri alindi)." Gray }
    else         { Yaz "    Gorsel efektler: En iyi performans secildi." Green }

    # --- 6. Fare 1:1 Ham Girdi (Pointer Precision) ---
    Write-Host "  -- [6/11] Fare Ham Giris (Pointer Precision)" -ForegroundColor Cyan
    $fareYol = "HKCU:\Control Panel\Mouse"
    if ($geriAl) {
        Set-ItemProperty -Path $fareYol -Name "MouseSpeed"      -Value "1"  -Force
        Set-ItemProperty -Path $fareYol -Name "MouseThreshold1" -Value "6"  -Force
        Set-ItemProperty -Path $fareYol -Name "MouseThreshold2" -Value "10" -Force
        Yaz "    Fare: Varsayilan (geri alindi)." Gray
    } else {
        Set-ItemProperty -Path $fareYol -Name "MouseSpeed"      -Value "0" -Force
        Set-ItemProperty -Path $fareYol -Name "MouseThreshold1" -Value "0" -Force
        Set-ItemProperty -Path $fareYol -Name "MouseThreshold2" -Value "0" -Force
        Yaz "    Fare: 1:1 ham giris aktif (pointer precision kapali)." Green
    }

    # --- 7. Guc Plani (sadece uygulama modunda) ---
    Write-Host "  -- [7/11] Guc Plani" -ForegroundColor Cyan
    if (-not $geriAl) {
        # Ultimate Performance planini dene, yoksa High Performance
        $ultimate = "e9a42b02-d5df-448d-aa00-03f14749eb61"
        powercfg /duplicatescheme $ultimate 2>&1 | Out-Null
        $sonuc = powercfg /setactive $ultimate 2>&1
        if ($LASTEXITCODE -ne 0) {
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
            Yaz "    Yuksek Performans plani aktif edildi." Green
        } else {
            Yaz "    Ultimate Performance plani aktif edildi!" Green
        }
        # CPU parking devre disi
        powercfg /setacvalueindex scheme_current sub_processor CPMINCORES 100 2>&1 | Out-Null
        powercfg /setactive scheme_current 2>&1 | Out-Null
    } else {
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e | Out-Null
        Yaz "    Dengeli plan geri yuklendi." Gray
    }

    # --- 8. Arka Plan Uygulamalari ---
    Write-Host "  -- [8/11] Arka Plan Uygulamalari" -ForegroundColor Cyan
    $bgYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (-not (Test-Path $bgYol)) { New-Item -Path $bgYol -Force | Out-Null }
    Set-ItemProperty -Path $bgYol -Name "GlobalUserDisabled" -Value $(if ($geriAl) {0} else {1}) -Type DWord -Force
    if ($geriAl) { Yaz "    Arka plan uygulamalari geri acildi." Gray }
    else         { Yaz "    Arka plan uygulamalari kapatildi." Green }

    # --- 9. Fullscreen Optimizations ---
    Write-Host "  -- [9/11] Fullscreen Optimizations" -ForegroundColor Cyan
    $fsoYol = "HKCU:\System\GameConfigStore"
    if (-not (Test-Path $fsoYol)) { New-Item -Path $fsoYol -Force | Out-Null }
    Set-ItemProperty -Path $fsoYol -Name "GameDVR_FSEBehaviorMode" -Value $(if ($geriAl) {0} else {2}) -Type DWord -Force
    Set-ItemProperty -Path $fsoYol -Name "GameDVR_HonorUserFSEBehaviorMode" -Value $(if ($geriAl) {0} else {1}) -Type DWord -Force
    Set-ItemProperty -Path $fsoYol -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value $(if ($geriAl) {0} else {1}) -Type DWord -Force
    if ($geriAl) { Yaz "    FSO geri acildi." Gray }
    else         { Yaz "    Fullscreen Optimizations devre disi birakildi." Green }

    # --- 10. Seffaflik ve Animasyonlar ---
    Write-Host "  -- [10/11] Seffaflik ve Animasyonlar" -ForegroundColor Cyan
    $transpYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (-not (Test-Path $transpYol)) { New-Item -Path $transpYol -Force | Out-Null }
    Set-ItemProperty -Path $transpYol -Name "EnableTransparency" -Value $(if ($geriAl) {1} else {0}) -Type DWord -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value $(if ($geriAl) {"400"} else {"0"}) -Force
    if ($geriAl) { Yaz "    Seffaflik ve animasyonlar geri acildi." Gray }
    else         { Yaz "    Seffaflik ve animasyonlar kapatildi." Green }

    # --- 11. Timer Resolution (oyun icin onemli) ---
    Write-Host "  -- [11/11] Timer Resolution" -ForegroundColor Cyan
    $timerYol = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
    if (-not (Test-Path $timerYol)) { New-Item -Path $timerYol -Force | Out-Null }
    if ($geriAl) {
        Remove-ItemProperty -Path $timerYol -Name "GlobalTimerResolutionRequests" -ErrorAction SilentlyContinue
        Yaz "    Timer resolution varsayilana alindi." Gray
    } else {
        Set-ItemProperty -Path $timerYol -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        Yaz "    Timer resolution optimize edildi (0.5ms hedef)." Green
    }

    # --- [+] GPU Marka Tespiti + Ozel Tweakler ---
    Write-Host "  -- [+] GPU Marka Tespiti ve Ozel Tweakler" -ForegroundColor Cyan
    $gpu = Get-WmiObject Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($gpu) {
        Durum "    GPU" $gpu.Name
        $vramMB = [int]($gpu.AdapterRAM / 1MB)
        if ($vramMB -gt 0) { Durum "    VRAM" ("{0} MB" -f $vramMB) }

        # NVIDIA ozel
        if ($gpu.Name -match "NVIDIA") {
            if ($geriAl) {
                "NvTelemetryContainer","NvContainerLocalSystem" | ForEach-Object {
                    $svc = Get-Service -Name $_ -ErrorAction SilentlyContinue
                    if ($svc) { Set-Service -Name $_ -StartupType Automatic -ErrorAction SilentlyContinue }
                }
                Yaz "    NVIDIA: Servisler varsayilana alindi." Gray
            } else {
                $nvTweak = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
                Get-ChildItem $nvTweak -ErrorAction SilentlyContinue | ForEach-Object {
                    $desc = (Get-ItemProperty $_.PSPath -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
                    if ($desc -match "NVIDIA") {
                        Set-ItemProperty -Path $_.PSPath -Name "PreferSystemMemoryContiguous" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
                        Set-ItemProperty -Path $_.PSPath -Name "EnableMsHybrid" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                    }
                }
                "NvTelemetryContainer","NvContainerLocalSystem" | ForEach-Object {
                    $svc = Get-Service -Name $_ -ErrorAction SilentlyContinue
                    if ($svc) { Set-Service -Name $_ -StartupType Manual -ErrorAction SilentlyContinue }
                }
                Yaz "    NVIDIA: Telemetri servisleri pasif, bellek tercihi optimize edildi." Green
            }
        }
        # AMD / Radeon ozel
        elseif ($gpu.Name -match "AMD|Radeon|ATI") {
            if ($geriAl) {
                $amdYol = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
                Get-ChildItem $amdYol -ErrorAction SilentlyContinue | ForEach-Object {
                    $desc = (Get-ItemProperty $_.PSPath -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
                    if ($desc -match "AMD|Radeon|ATI") {
                        Remove-ItemProperty -Path $_.PSPath -Name "KMD_EnableComputePreemption" -ErrorAction SilentlyContinue
                        Remove-ItemProperty -Path $_.PSPath -Name "PP_GPUPowerDownEnabled" -ErrorAction SilentlyContinue
                    }
                }
                Yaz "    AMD: Tweakler geri alindi." Gray
            } else {
                $amdYol = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
                Get-ChildItem $amdYol -ErrorAction SilentlyContinue | ForEach-Object {
                    $desc = (Get-ItemProperty $_.PSPath -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
                    if ($desc -match "AMD|Radeon|ATI") {
                        Set-ItemProperty -Path $_.PSPath -Name "KMD_EnableComputePreemption" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                        Set-ItemProperty -Path $_.PSPath -Name "PP_GPUPowerDownEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                    }
                }
                Yaz "    AMD: Compute preemption ve guc tasarrufu devre disi." Green
            }
        } else {
            Yaz "    GPU markasi taninamadi, genel ayarlar uygulandı." Yellow
        }
    } else {
        Yaz "    GPU bilgisi alinamadi." Yellow
    }

    Write-Host ""
    Write-Host ("  " + ("=" * 56)) -ForegroundColor $(if ($geriAl){"Yellow"} else {"Green"})
    if ($geriAl) {
        Yaz "  Tum FPS optimizasyonlari GERI ALINDI." Yellow
        Yaz "  Bazi degisiklikler yeniden baslatmadan sonra tam gercerlidir." DarkGray
    } else {
        Yaz "  FPS ve Oyun Optimizasyonu TAMAMLANDI!" Green
        Yaz "  Onerilir: Yeniden baslat - Nagle ve HAGS tam gercerlilik icin." DarkGray
        Yaz "  Geri almak icin bu modulu [2] secimiyle tekrar calistir." DarkGray
    }
    Write-Host ("  " + ("=" * 56)) -ForegroundColor $(if ($geriAl){"Yellow"} else {"Green"})
    RaporVeriEkle "fps_optimizasyon" $(if ($geriAl) {"Geri alindi"} else {"Uygulandi"})
}

#endregion

#region -- MODUL 27: RAM OPTİMİZASYONU --

function RamOptimizasyonu {
    param([switch]$OtomatikUygula)

    Baslik "RAM Optimizasyonu" "27"

    if (-not (YoneticiKontrol)) {
        Yaz "  Bu modul icin Yonetici yetkisi gereklidir!" Red
        return
    }

    $os        = Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue
    $toplamMB  = [int]($os.TotalVisibleMemorySize / 1024)
    $bosMB     = [int]($os.FreePhysicalMemory / 1024)
    $kullMB    = $toplamMB - $bosMB
    $kullPct   = if ($toplamMB -gt 0) { [int]($kullMB / $toplamMB * 100) } else { 0 }
    $renkKull  = if ($kullPct -gt 85){"Red"} elseif ($kullPct -gt 65){"Yellow"} else {"Green"}

    $toplamGB   = [Math]::Round($toplamMB / 1024, 1)
    $toplamStr  = $toplamMB.ToString() + ' MB  (' + $toplamGB.ToString() + ' GB)'
    $kullStr    = $kullMB.ToString() + ' MB  (%' + $kullPct.ToString() + ')'
    $bosStr     = $bosMB.ToString() + ' MB'
    Write-Host "  Mevcut RAM durumu:" -ForegroundColor Cyan
    Durum "  Toplam"     $toplamStr
    Durum "  Kullanulan" $kullStr    $renkKull
    Durum "  Bos"        $bosStr     Green
    Write-Host ""

    if ($OtomatikUygula -or $env:SISTEMBAK_GUI -eq '1') {
        $sec = "3"
    } else {
        Write-Host "  [1]  Calisma Kumu Temizle   (sureclerin gereksiz bellegi bosaltilir)" -ForegroundColor Green
        Write-Host "  [2]  Standby Listesi Temizle (sistem on-bellegi temizlenir, Admin)" -ForegroundColor Green
        Write-Host "  [3]  Ikisini de Yap          (onerilen - maksimum etki)" -ForegroundColor Cyan
        Write-Host "  [0]  Geri"
        Write-Host ""
        Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
        $sec = Read-Host
        if ($sec -eq "0" -or $sec -notin @("1","2","3")) { return }
    }

    # -- Calisma Kumu (Working Set Trim) --
    if ($sec -eq "1" -or $sec -eq "3") {
        Write-Host "  Calisma kumleri temizleniyor..." -ForegroundColor Gray
        $sayac = 0
        Get-Process -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                $ws = $_.MinWorkingSet
                $_.MinWorkingSet = $ws
                $sayac++
            } catch {}
        }
        Yaz ("  {0} surec icin calisma kumu daraltildi." -f $sayac) Green
    }

    # -- Standby List Temizle (NtSetSystemInformation) --
    if ($sec -eq "2" -or $sec -eq "3") {
        Write-Host "  Standby listesi temizleniyor..." -ForegroundColor Gray
        try {
            if (-not ([System.Management.Automation.PSTypeName]"WinMemHelper").Type) {
                $csLines = [System.Collections.Generic.List[string]]::new()
                $csLines.Add('using System;')
                $csLines.Add('using System.Runtime.InteropServices;')
                $csLines.Add('public class WinMemHelper {')
                $csLines.Add('    [DllImport("ntdll.dll")]')
                $csLines.Add('    public static extern uint NtSetSystemInformation(int cls, IntPtr buf, int len);')
                $csLines.Add('    public static void TemizleStandby() {')
                $csLines.Add('        IntPtr p = Marshal.AllocHGlobal(4);')
                $csLines.Add('        Marshal.WriteInt32(p, 4);')
                $csLines.Add('        NtSetSystemInformation(80, p, 4);')
                $csLines.Add('        Marshal.FreeHGlobal(p);')
                $csLines.Add('    }')
                $csLines.Add('}')
                $src = [string]::Join([System.Environment]::NewLine, $csLines)
                Add-Type -TypeDefinition $src -ErrorAction Stop
            }
            [WinMemHelper]::TemizleStandby()
            Yaz "  Standby listesi temizlendi." Green
        } catch {
            Yaz ("  Standby temizlenemedi: {0}" -f $_.Exception.Message) Yellow
        }
    }

    # -- Sonrasi karsilastirma --
    Start-Sleep -Milliseconds 800
    $os2      = Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue
    $bosMB2   = [int]($os2.FreePhysicalMemory / 1024)
    $kullMB2  = $toplamMB - $bosMB2
    $kullPct2 = if ($toplamMB -gt 0) { [int]($kullMB2 / $toplamMB * 100) } else { 0 }
    $kazanc   = $bosMB2 - $bosMB

    Write-Host ""
    Write-Host "  Sonuc:" -ForegroundColor Cyan
    Durum "  Kullanulan (sonra)" ("{0} MB  (%{1})" -f $kullMB2, $kullPct2) $(if ($kullPct2 -gt 85){"Red"} elseif ($kullPct2 -gt 65){"Yellow"} else {"Green"})
    Durum "  Bos (sonra)"       ("{0} MB" -f $bosMB2) Green

    Write-Host ""
    if ($kazanc -gt 0) {
        Write-Host ("  + {0} MB serbest birakildi!" -f $kazanc) -ForegroundColor Green
    } elseif ($kazanc -eq 0) {
        Yaz "  RAM kullanimi degismedi (zaten optimize)." Gray
    } else {
        Yaz ("  RAM farki: {0} MB (sistem islemleri artti)." -f $kazanc) Yellow
    }

    RaporVeriEkle "ram_once_mb"  $kullMB
    RaporVeriEkle "ram_sonra_mb" $kullMB2
}

#endregion

#region -- MODUL 28: SUREC TEMİZLEYİCİ --

function SurecTemizleyici {
    param([switch]$OtomatikUygula)

    Baslik "Oyun Oncesi Surec Temizleyici" "28"

    $hedefler = [ordered]@{
        "Xbox Game Bar / GameBarFT" = @("GameBar","GameBarFTServer")
        "OneDrive"                  = @("OneDrive")
        "Microsoft Teams"           = @("Teams","ms-teams")
        "Discord"                   = @("Discord","DiscordPTB","DiscordCanary")
        "Spotify"                   = @("Spotify")
        "Adobe Update"              = @("AdobeUpdateService","ARMDeltaARM","Adobe Desktop Service")
        "Office Background"         = @("MSOSYNC","OfficeClickToRun","msoia")
        "Google Update"             = @("GoogleUpdate","GoogleCrashHandler","GoogleCrashHandler64")
        "Epic Games Launcher"       = @("EpicGamesLauncher","EpicWebHelper")
        "EA Desktop"                = @("EADesktop","EABackgroundService","EAConnect_microsoft")
        "Skype"                     = @("Skype","SkypeApp")
        "Windows Update Tetikleyici"= @("wuauclt","UsoClient")
        "Battle.net Agent"          = @("Battle.net","Agent")
        "Ubisoft Connect"           = @("upc","UbisoftGameLauncher")
        "Steam Web Helper"          = @("steamwebhelper")
    }

    Write-Host "  Arka plan islemi taranıyor..." -ForegroundColor Gray
    $bulunanlar = [ordered]@{}

    foreach ($grup in $hedefler.GetEnumerator()) {
        $aktifProc = @()
        foreach ($isim in $grup.Value) {
            $p = Get-Process -Name $isim -ErrorAction SilentlyContinue
            if ($p) { $aktifProc += $p }
        }
        if ($aktifProc.Count -gt 0) {
            $ramMB = [int](($aktifProc | Measure-Object WorkingSet64 -Sum).Sum / 1MB)
            $bulunanlar[$grup.Key] = @{ Isimler = $grup.Value; RAM = $ramMB }
        }
    }

    Write-Host ""
    if ($bulunanlar.Count -eq 0) {
        Yaz "  Arka planda gereksiz islem bulunamadi. Hazirsiniz!" Green
        return
    }

    $toplamRam = ($bulunanlar.Values | ForEach-Object { $_.RAM } | Measure-Object -Sum).Sum
    Write-Host ("  {0} aktif islem bulundu  (~{1} MB RAM)" -f $bulunanlar.Count, $toplamRam) -ForegroundColor Yellow
    Write-Host ""

    $i = 0
    $liste = @()
    foreach ($k in $bulunanlar.Keys) {
        $i++
        Write-Host ("  [{0,2}]  {1,-35} {2} MB" -f $i, $k, $bulunanlar[$k].RAM) -ForegroundColor Gray
        $liste += $k
    }

    Write-Host ""
    if ($OtomatikUygula -or $env:SISTEMBAK_GUI -eq '1') {
        $secim = "hepsi"
    } else {
        Write-Host "  [T]  Tamamini kapat    [S]  Sectiklerimi kapat    [0]  Cik" -ForegroundColor DarkGray
        Write-Host "  Secim (ornek S icin: 1,3,5 ya da T): " -ForegroundColor Yellow -NoNewline
        $secim = (Read-Host).Trim()
        if ($secim -eq "0") { return }
    }

    $kapatilacaklar = @()
    if ($secim -match "^[Tt]$" -or $secim -eq "hepsi") {
        $kapatilacaklar = $liste
    } elseif ($secim -match "^[Ss]$") {
        Write-Host "  Numaralari girin (ornek: 1,3,5): " -ForegroundColor Yellow -NoNewline
        $numaraGirdisi = Read-Host
        $numaraGirdisi -split "," | ForEach-Object {
            $n = $_.Trim()
            if ($n -match "^\d+$") {
                $idx = [int]$n - 1
                if ($idx -ge 0 -and $idx -lt $liste.Count) { $kapatilacaklar += $liste[$idx] }
            }
        }
    } else {
        $secim -split "," | ForEach-Object {
            $n = $_.Trim()
            if ($n -match "^\d+$") {
                $idx = [int]$n - 1
                if ($idx -ge 0 -and $idx -lt $liste.Count) { $kapatilacaklar += $liste[$idx] }
            }
        }
    }

    if ($kapatilacaklar.Count -eq 0) { Yaz "  Hicbir islem secilmedi." Yellow; return }

    Write-Host ""
    $kurtarilanRam = 0
    foreach ($ad in $kapatilacaklar) {
        $info = $bulunanlar[$ad]
        foreach ($isim in $info.Isimler) {
            Stop-Process -Name $isim -Force -ErrorAction SilentlyContinue
        }
        $kurtarilanRam += $info.RAM
        Yaz ("  [KAPATILDI]  {0}  (~{1} MB)" -f $ad, $info.RAM) Green
    }

    Write-Host ""
    Write-Host ("  Toplam ~{0} MB RAM serbest birakildi." -f $kurtarilanRam) -ForegroundColor Green
    Yaz "  Oyun baslatilabilir!" Cyan
    RaporVeriEkle "surec_kurtarilan_mb" $kurtarilanRam
}

#endregion

#region -- MODUL 29: BLOATWARE KALDIRICI --

function BloatwareKaldirici {
    Baslik "Bloatware Kaldirici" "29"

    if (-not (YoneticiKontrol)) {
        Yaz "  Bu modul icin Yonetici yetkisi gereklidir!" Red
        return
    }

    # Hedef uygulama listesi: Gorunen Ad => Paket Adi
    $hedefler = [ordered]@{
        # Xbox / Oyun
        "Xbox Game Bar"           = "Microsoft.XboxGamingOverlay"
        "Xbox Identity Provider"  = "Microsoft.XboxIdentityProvider"
        "Xbox TCUI"               = "Microsoft.Xbox.TCUI"
        "Xbox Uygulama"           = "Microsoft.GamingApp"
        # Microsoft Servisler
        "Cortana"                 = "Microsoft.549981C3F5F10"
        "Haber"                   = "Microsoft.BingNews"
        "Hava Durumu"             = "Microsoft.BingWeather"
        "Feedback Hub"            = "Microsoft.WindowsFeedbackHub"
        "Yardim Al"               = "Microsoft.GetHelp"
        # Eglence
        "Solitaire Collection"    = "Microsoft.MicrosoftSolitaireCollection"
        "Film ve TV"              = "Microsoft.ZuneVideo"
        "Groove Music"            = "Microsoft.ZuneMusic"
        # Iletisim
        "Mail ve Takvim"          = "microsoft.windowscommunicationsapps"
        "Kisiler"                 = "Microsoft.People"
        "Skype"                   = "Microsoft.SkypeApp"
        "Teams Kisisel"           = "MicrosoftTeams"
        "Office Hub"              = "Microsoft.MicrosoftOfficeHub"
        # Diger
        "3D Viewer"               = "Microsoft.Microsoft3DViewer"
        "Mixed Reality Portal"    = "Microsoft.MixedReality.Portal"
        "Haritalar"               = "Microsoft.WindowsMaps"
        "Telefon Baglantisi"      = "Microsoft.YourPhone"
        "Power Automate"          = "Microsoft.PowerAutomateDesktop"
        "Quick Assist"            = "MicrosoftCorporationII.QuickAssist"
        "Paint 3D"                = "Microsoft.MSPaint"
        "OneNote"                 = "Microsoft.Office.OneNote"
        "Microsoft To Do"         = "Microsoft.Todos"
        # Win11 yeni bloatware
        "Clipchamp"               = "Clipchamp.Clipchamp"
        "Dev Home"                = "Microsoft.Windows.DevHome"
        "Family Safety"           = "MicrosoftCorporationII.MicrosoftFamily"
        "Yapilacaklar"            = "Microsoft.Todos"
        "Sticky Notes"            = "Microsoft.MicrosoftStickyNotes"
        "Alarms"                  = "Microsoft.WindowsAlarms"
        "Sound Recorder"          = "Microsoft.WindowsSoundRecorder"
        "Bing Finance"            = "Microsoft.BingFinance"
        "Bing Translate"          = "Microsoft.BingTranslator"
    }

    # Sadece yuklü olanlari bul
    Write-Host "  Yuklü uygulamalar taranıyor..." -ForegroundColor Gray
    $bulunanlar = [ordered]@{}
    foreach ($item in $hedefler.GetEnumerator()) {
        $pkg = Get-AppxPackage -Name ($item.Value + "*") -ErrorAction SilentlyContinue |
               Select-Object -First 1
        if ($pkg) { $bulunanlar[$item.Key] = $pkg }
    }

    if ($bulunanlar.Count -eq 0) {
        Yaz "  Kaldirilabilecek bloatware bulunamadi." Green
        return
    }

    Write-Host ""
    Write-Host ("  {0} uygulama bulundu:" -f $bulunanlar.Count) -ForegroundColor Yellow
    Write-Host ""

    $i = 0
    $liste = @()
    # Kategori renkleri
    $xbox    = @("Xbox Game Bar","Xbox Identity Provider","Xbox TCUI","Xbox Uygulama")
    $servis  = @("Cortana","Haber","Hava Durumu","Feedback Hub","Yardim Al")
    $egl     = @("Solitaire Collection","Film ve TV","Groove Music")

    foreach ($k in $bulunanlar.Keys) {
        $i++
        $renk = if ($xbox    -contains $k) { "Magenta" }
                elseif ($servis -contains $k) { "DarkCyan" }
                elseif ($egl    -contains $k) { "DarkYellow" }
                else { "Gray" }
        Write-Host ("  [{0,2}]  {1}" -f $i, $k) -ForegroundColor $renk
        $liste += $k
    }

    Write-Host ""
    Write-Host "  Renk: Magenta=Xbox  DarkCyan=MS Servis  Yellow=Eglence  Gray=Diger" -ForegroundColor DarkGray
    Write-Host ""
    if ($env:SISTEMBAK_GUI -eq '1') {
        $secim = "T"
    } else {
        Write-Host "  [T]  Tamamini kaldir" -ForegroundColor Red
        Write-Host "  [S]  Secip kaldir  (ornek: 1,3,5)" -ForegroundColor Yellow
        Write-Host "  [0]  Geri" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
        $secim = (Read-Host).Trim()
        if ($secim -eq "0") { return }
    }

    $kaldirilacaklar = @()
    if ($secim -match "^[Tt]$") {
        $kaldirilacaklar = $liste
    } elseif ($secim -match "^[Ss]$") {
        Write-Host "  Numaralari girin (ornek: 1,3,5): " -ForegroundColor Yellow -NoNewline
        $secim = Read-Host
        $secim -split "," | ForEach-Object {
            $n = $_.Trim()
            if ($n -match "^\d+$") {
                $idx = [int]$n - 1
                if ($idx -ge 0 -and $idx -lt $liste.Count) { $kaldirilacaklar += $liste[$idx] }
            }
        }
    } else {
        $secim -split "," | ForEach-Object {
            $n = $_.Trim()
            if ($n -match "^\d+$") {
                $idx = [int]$n - 1
                if ($idx -ge 0 -and $idx -lt $liste.Count) { $kaldirilacaklar += $liste[$idx] }
            }
        }
    }

    if ($kaldirilacaklar.Count -eq 0) { Yaz "  Hicbir uygulama secilmedi." Yellow; return }

    Write-Host ""
    Yaz "  Uygulamalar kaldiriliyor..." Cyan
    Yaz "  Not: Microsoft Store'dan yeniden yuklenebilir." DarkGray
    Write-Host ""

    $basarili = 0; $hatali = 0
    foreach ($ad in $kaldirilacaklar) {
        $pkg = $bulunanlar[$ad]
        try {
            # Tum kullanicilar icin kaldir (Admin gerekli)
            Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop
            Yaz ("  [KALDIRILDI]  {0}" -f $ad) Green
            $basarili++
        } catch {
            # Sistem uygulamalari -AllUsers'i desteklemeyebilir, normal dene
            try {
                Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
                Yaz ("  [KALDIRILDI]  {0}" -f $ad) Green
                $basarili++
            } catch {
                $hataMsg = ($_.Exception.Message -replace "[\r\n]"," ")
                $hataKisa = if ($hataMsg.Length -gt 60) { $hataMsg.Substring(0,60) } else { $hataMsg }
                Yaz ("  [ATLANDI]     " + $ad + "  (" + $hataKisa + ")") Yellow
                $hatali++
            }
        }
    }

    $renkSon  = if ($hatali -eq 0) { "Green" } else { "Yellow" }
    $sinir    = "  " + ("=" * 50)
    Write-Host ""
    Write-Host $sinir -ForegroundColor $renkSon
    Durum "  Kaldirilan" ($basarili.ToString() + " uygulama") Green
    if ($hatali -gt 0) {
        Durum "  Atlanamadi" ($hatali.ToString() + "  (sistem korumali veya baska kullanici aktif)") Yellow
    }
    Write-Host $sinir -ForegroundColor $renkSon
    RaporVeriEkle "bloatware_kaldirilan" $basarili
}

#endregion

#region ── MODUL 30-40: YENI MODULLER ───────────────────────

function SurucuKontrol {
    Baslik "Surucu (Driver) Kontrolu" "30"
    Yaz "  Surucular taranıyor..." Gray

    $tumSurucular = @(Get-WmiObject Win32_PnPSignedDriver -ErrorAction SilentlyContinue |
                      Where-Object { $_.DriverName -and $_.DeviceName })
    $imzasiz = @($tumSurucular | Where-Object { $_.IsSigned -eq $false })

    Write-Host ""
    Write-Host ("  Toplam surucu   : " + $tumSurucular.Count) -ForegroundColor Gray
    Write-Host ("  Imzasiz surucu  : " + $imzasiz.Count) -ForegroundColor $(if ($imzasiz.Count -gt 0) {"Red"} else {"Green"})

    if ($imzasiz.Count -gt 0) {
        Write-Host ""
        Write-Host "  IMZASIZ SURUCULAR:" -ForegroundColor Red
        $imzasiz | Select-Object -First 10 | ForEach-Object {
            Write-Host ("    " + $_.DeviceName + "  --  v" + $_.DriverVersion) -ForegroundColor Yellow
        }
    } else {
        Write-Host ""
        Yaz "  Tum surucular imzali ve temiz." Green
    }

    $sorunlu = @(Get-WmiObject Win32_PnPEntity -ErrorAction SilentlyContinue |
                 Where-Object { $_.ConfigManagerErrorCode -ne 0 })
    if ($sorunlu.Count -gt 0) {
        Write-Host ""
        Write-Host ("  SORUNLU AYGITLAR (" + $sorunlu.Count + "):") -ForegroundColor Red
        $sorunlu | Select-Object -First 8 | ForEach-Object {
            Write-Host ("    " + $_.Name) -ForegroundColor Yellow
        }
    } else {
        Yaz "  Aygit Yoneticisinde sorunlu aygit yok." Green
    }

    Write-Host ""
    Write-Host "  1  >  Windows Update ile surucu guncelle" -ForegroundColor Gray
    Write-Host "  2  >  Aygit Yoneticisini ac" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $s = Read-Host
    switch ($s.Trim()) {
        "1" { Start-Process "ms-settings:windowsupdate" -ErrorAction SilentlyContinue }
        "2" { Start-Process "devmgmt.msc" -ErrorAction SilentlyContinue }
    }
}

function WindowsUpdateYonetici {
    Baslik "Windows Update Yoneticisi" "31"
    Yaz "  Bekleyen guncellemeler sorgulanıyor..." Gray
    Write-Host ""

    $bekleyen = -1
    $updateListesi = @()
    try {
        $sess    = New-Object -ComObject Microsoft.Update.Session -ErrorAction Stop
        $searcher = $sess.CreateUpdateSearcher()
        $sonuc   = $searcher.Search("IsInstalled=0 and Type='Software'")
        $bekleyen = $sonuc.Updates.Count
        for ($i = 0; $i -lt [Math]::Min($bekleyen, 15); $i++) {
            $u  = $sonuc.Updates.Item($i)
            $kb = if ($u.KBArticleIDs.Count -gt 0) { " (KB" + $u.KBArticleIDs.Item(0) + ")" } else { "" }
            $updateListesi += ("    " + ($i+1) + ".  " + $u.Title.Substring(0,[Math]::Min($u.Title.Length,60)) + $kb)
        }
    } catch {
        $bekleyen = -1
    }

    if ($bekleyen -eq -1) {
        Yaz "  Windows Update COM servisi yanitlamadi. Ayarlardan kontrol edin." Yellow
    } elseif ($bekleyen -eq 0) {
        Yaz "  Sistem guncel! Bekleyen guncelleme yok." Green
    } else {
        Write-Host ("  " + $bekleyen + " bekleyen guncelleme bulundu:") -ForegroundColor Yellow
        Write-Host ""
        $updateListesi | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
        if ($bekleyen -gt 15) { Yaz ("  ... ve " + ($bekleyen - 15) + " guncelleme daha.") DarkGray }
    }

    Write-Host ""
    Write-Host "  1  >  Windows Update sayfasini ac" -ForegroundColor Gray
    Write-Host "  2  >  Guncelleme kontrol baslat (arka plan)" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $s = Read-Host
    switch ($s.Trim()) {
        "1" { Start-Process "ms-settings:windowsupdate" -ErrorAction SilentlyContinue }
        "2" {
            Yaz "  Guncelleme taramasi baslıyor..." Cyan
            Start-Process "wuauclt.exe" -ArgumentList "/detectnow" -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            Start-Process "ms-settings:windowsupdate" -ErrorAction SilentlyContinue
        }
    }
}

function DiskOptimize {
    Baslik "Disk Optimize (Defrag / TRIM)" "32"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    Write-Host "  Diskler:" -ForegroundColor Gray
    $fizikselDiskler = Get-PhysicalDisk -ErrorAction SilentlyContinue
    if ($fizikselDiskler) {
        $fizikselDiskler | ForEach-Object {
            $tip = switch ($_.MediaType) {
                "SSD"     { "[SSD - TRIM]"   }
                "HDD"     { "[HDD - Defrag]" }
                default   { "[?]"            }
            }
            Write-Host ("    " + $_.FriendlyName + "  " + $tip) -ForegroundColor Cyan
        }
    }

    Write-Host ""
    Write-Host "  Optimizasyon uygulanacak birimler:" -ForegroundColor Gray
    $birimler = @(Get-Volume -ErrorAction SilentlyContinue |
                  Where-Object { $_.DriveLetter -and $_.DriveType -eq "Fixed" })
    $birimler | ForEach-Object {
        Write-Host ("    " + $_.DriveLetter + ":\  " + $_.FileSystemType) -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "  1  >  Tum sabit birimleri optimize et" -ForegroundColor Cyan
    Write-Host "  2  >  Sadece C:\ optimize et" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $s = Read-Host
    switch ($s.Trim()) {
        "1" {
            $birimler | ForEach-Object {
                $harf = $_.DriveLetter
                Yaz ("  " + $harf + ":\ optimize ediliyor...") Cyan
                Optimize-Volume -DriveLetter $harf -ErrorAction SilentlyContinue | Out-Null
            }
            Yaz "  Tum birimler optimize edildi!" Green
        }
        "2" {
            Yaz "  C:\ optimize ediliyor..." Cyan
            Optimize-Volume -DriveLetter C -ErrorAction SilentlyContinue | Out-Null
            Yaz "  C:\ optimize edildi!" Green
        }
    }
}

function WinSxSTemizle {
    Baslik "WinSxS / Component Store Temizligi" "33"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    Yaz "  WinSxS klasor boyutu olculuyor..." Gray
    $winsxsYol = Join-Path $env:SystemRoot "WinSxS"
    $boyut = (Get-ChildItem $winsxsYol -Recurse -ErrorAction SilentlyContinue |
              Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    Write-Host ("  Mevcut WinSxS boyutu: " + (BoyutFormatla $boyut)) -ForegroundColor Cyan

    Write-Host ""
    Write-Host "  1  >  Standart temizlik  (guvenli, geri alinabilir, 5-15 dk)" -ForegroundColor Green
    Write-Host "  2  >  Derin temizlik     (geri ALINAMAZ, max tasarruf, 10-30 dk)" -ForegroundColor Red
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $s = Read-Host
    switch ($s.Trim()) {
        "1" {
            Yaz "  Standart DISM temizligi calistiriliyor (5-15 dk surebilir)..." Cyan
            $dismSonuc = & dism /online /Cleanup-Image /StartComponentCleanup 2>&1
            $dismSonuc | ForEach-Object { Write-Host ("    {0}" -f $_) -ForegroundColor DarkGray }
            if ($LASTEXITCODE -eq 0) { Yaz "  Tamamlandi!" Green }
            else { Yaz ("  DISM cikis kodu: {0}" -f $LASTEXITCODE) Yellow }
        }
        "2" {
            Write-Host "  UYARI: Bu islem GERI ALINAMAZ! Emin misiniz? (E/H): " -ForegroundColor Red -NoNewline
            $onay = Read-Host
            if ($onay -match "^[Ee]") {
                Yaz "  Derin temizlik calistiriliyor (10-30 dk surebilir)..." Red
                $dismSonuc = & dism /online /Cleanup-Image /StartComponentCleanup /ResetBase 2>&1
                $dismSonuc | ForEach-Object { Write-Host ("    {0}" -f $_) -ForegroundColor DarkGray }
                if ($LASTEXITCODE -eq 0) { Yaz "  Tamamlandi!" Green }
                else { Yaz ("  DISM cikis kodu: {0}" -f $LASTEXITCODE) Yellow }
            } else {
                Yaz "  Iptal edildi." Yellow
            }
        }
    }
}

function PilSagligi {
    Baslik "Pil Sagligi Raporu" "34"

    $pil = Get-WmiObject Win32_Battery -ErrorAction SilentlyContinue
    if (-not $pil) {
        Yaz "  Pil bulunamadi. Bu modul dizustu bilgisayarlar icindir." Yellow
        return
    }

    Write-Host ("  Pil Adi     : " + $pil.Name) -ForegroundColor Cyan
    $sarjYuz  = $pil.EstimatedChargeRemaining
    $sarjRenk = if ($sarjYuz -ge 50) { "Green" } elseif ($sarjYuz -ge 20) { "Yellow" } else { "Red" }
    $sarjBol  = [int]($sarjYuz / 5); if ($sarjBol -gt 20) { $sarjBol = 20 }
    $sarjBar  = "[" + ("=" * $sarjBol) + (" " * (20 - $sarjBol)) + "]"
    Write-Host ("  Sarj Durumu : " + $sarjBar + "  " + $sarjYuz + "%") -ForegroundColor $sarjRenk

    $durumKod = $pil.BatteryStatus
    $durumMetin = switch ($durumKod) {
        1 { "Disarjlanıyor" }
        2 { "AC + Sarj Oluyor" }
        3 { "Tam Dolu (AC)" }
        default { "Durum kodu: $durumKod" }
    }
    Write-Host ("  Durum       : " + $durumMetin) -ForegroundColor Gray

    Write-Host ""
    Yaz "  Ayrintili HTML rapor olusturuluyor..." Gray
    $raporYolu = Join-Path $env:TEMP "battery_report.html"
    & powercfg /batteryreport /output $raporYolu /duration 14 2>&1 | Out-Null

    if (Test-Path $raporYolu) {
        Write-Host ("  Rapor olusturuldu: " + $raporYolu) -ForegroundColor Green
        Write-Host ""
        Write-Host "  1  >  Raporu tarayicida ac" -ForegroundColor Gray
        Write-Host "  0  >  Geri" -ForegroundColor Gray
        Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
        $s = Read-Host
        if ($s.Trim() -eq "1") { Start-Process $raporYolu -ErrorAction SilentlyContinue }
    } else {
        Yaz "  Rapor olusturulamadi. Yonetici yetkisi gerekebilir." Red
    }
}

function InternetHiziTesti {
    Baslik "Internet Hiz Testi" "35"

    # Speedtest CLI var mi?
    $stExe = Get-Command "speedtest" -ErrorAction SilentlyContinue
    if (-not $stExe) { $stExe = Get-Command "speedtest.exe" -ErrorAction SilentlyContinue }

    if ($stExe) {
        Yaz "  Speedtest CLI bulundu. Test basliyor..." Green
        Write-Host ""
        & speedtest --format=human-readable
    } else {
        # Cloudflare 10 MB indirme testi
        Yaz "  Indirme hizi test ediliyor (10 MB Cloudflare)..." Cyan
        $testUrl = "https://speed.cloudflare.com/__down?bytes=10000000"
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $wc = New-Object System.Net.WebClient
            $wc.Headers.Add("User-Agent", "SistemBakim/" + $SURUM)
            $veri = $wc.DownloadData($testUrl)
            $sw.Stop()
            $sn   = $sw.Elapsed.TotalSeconds
            $mbps = [Math]::Round(($veri.Length * 8.0 / 1000000) / $sn, 1)
            $mbStr = $mbps.ToString("0.0")
            Write-Host ""
            Write-Host ("  Indirme Hizi  : " + $mbStr + " Mbps") -ForegroundColor Green
            Write-Host ("  Indirilen     : " + [Math]::Round($veri.Length / 1MB, 1) + " MB") -ForegroundColor Gray
            Write-Host ("  Sure          : " + [Math]::Round($sn, 2) + " sn") -ForegroundColor Gray
        } catch {
            Yaz ("  Indirme testi basarisiz: " + $_) Red
        }

        Write-Host ""
        Write-Host "  Ping Testi:" -ForegroundColor Gray
        $hedefler = @("8.8.8.8", "1.1.1.1", "cloudflare.com")
        foreach ($h in $hedefler) {
            $p = Test-Connection $h -Count 3 -ErrorAction SilentlyContinue
            if ($p) {
                $ort  = [int]($p | Measure-Object -Property ResponseTime -Average).Average
                $renk = if ($ort -le 30) { "Green" } elseif ($ort -le 80) { "Yellow" } else { "Red" }
                Write-Host ("    " + $h.PadRight(20) + $ort + " ms") -ForegroundColor $renk
            } else {
                Write-Host ("    " + $h.PadRight(20) + "Erisim yok") -ForegroundColor Red
            }
        }

        Write-Host ""
        Yaz "  Not: Tam test icin  winget install Ookla.Speedtest.CLI  kullanin." DarkGray
    }
}

function BantGenisligiOptimize {
    Baslik "Bant Genisligi Optimizasyonu" "36"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    $qosYol   = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
    $doYol    = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"

    $qosDeger = if (Test-Path $qosYol) { (Get-ItemProperty $qosYol -ErrorAction SilentlyContinue).NonBestEffortLimit } else { $null }
    $doMod    = if (Test-Path $doYol)  { (Get-ItemProperty $doYol  -ErrorAction SilentlyContinue).DODownloadMode  } else { $null }

    Write-Host ""
    Write-Host "  Mevcut Ayarlar:" -ForegroundColor Gray

    $qosMesg = if ($qosDeger -eq 0) { "Devre disi (iyi)" } elseif ($null -eq $qosDeger) { "Windows varsayilan" } else { $qosDeger.ToString() + "%" }
    $qosRenk = if ($qosDeger -eq 0) { "Green" } else { "Yellow" }
    Write-Host ("  QoS Rezervasyon      : " + $qosMesg) -ForegroundColor $qosRenk

    $doMesg  = switch ($doMod) { 0 {"Kapali (iyi)"}; 1 {"Yerel AG (iyi)"}; 3 {"AG+Internet (bant yer)"}; default {"Bilinmiyor"} }
    $doRenk  = if ($doMod -eq 0 -or $doMod -eq 1) { "Green" } else { "Yellow" }
    Write-Host ("  Windows Update P2P   : " + $doMesg) -ForegroundColor $doRenk

    Write-Host ""
    Write-Host "  1  >  Tam optimizasyon (QoS kapat + P2P yerel + TCP normal)" -ForegroundColor Cyan
    Write-Host "  2  >  Sadece QoS rezervasyonu kaldir" -ForegroundColor Gray
    Write-Host "  3  >  Sadece Update P2P'yi yerel AG'a sinirla" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $s = Read-Host

    $yapilan = @()
    if ($s -eq "1" -or $s -eq "2") {
        if (-not (Test-Path $qosYol)) { New-Item -Path $qosYol -Force | Out-Null }
        Set-ItemProperty -Path $qosYol -Name "NonBestEffortLimit" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        $yapilan += "QoS bant rezervasyonu kaldirıldi (0%)"
    }
    if ($s -eq "1" -or $s -eq "3") {
        if (Test-Path $doYol) {
            Set-ItemProperty -Path $doYol -Name "DODownloadMode" -Value 1 -Type DWord -ErrorAction SilentlyContinue
            $yapilan += "Windows Update P2P sadece yerel AG ile sinirlandirildi"
        }
    }
    if ($s -eq "1") {
        & netsh int tcp set global autotuninglevel=normal 2>&1 | Out-Null
        & netsh int tcp set global chimney=disabled 2>&1 | Out-Null
        $yapilan += "TCP Auto-Tuning normalize edildi"
    }

    if ($yapilan.Count -gt 0) {
        Write-Host ""
        Yaz "  Uygulanan degisiklikler:" Green
        $yapilan | ForEach-Object { Yaz ("    + " + $_) Cyan }
    }
}

function DirectXGPUTani {
    Baslik "DirectX ve GPU Tanisi" "37"

    Write-Host "  GPU Bilgisi:" -ForegroundColor Cyan
    Write-Host ""
    $gpuSayac = 0
    Get-WmiObject Win32_VideoController -ErrorAction SilentlyContinue | ForEach-Object {
        $gpuSayac++
        $vramGB = if ($_.AdapterRAM -gt 0) { [Math]::Round($_.AdapterRAM / 1GB, 1).ToString("0.0") + " GB" } else { "Bilinmiyor" }
        Write-Host ("  GPU " + $gpuSayac + ":") -ForegroundColor Yellow
        Write-Host ("    Ad       : " + $_.Name) -ForegroundColor White
        Write-Host ("    VRAM     : " + $vramGB) -ForegroundColor Gray
        Write-Host ("    Surucu   : " + $_.DriverVersion) -ForegroundColor Gray
        $cozStr = if ($_.CurrentHorizontalResolution) { $_.CurrentHorizontalResolution.ToString() + "x" + $_.CurrentVerticalResolution.ToString() } else { "Bilinmiyor" }
        $hzStr  = if ($_.CurrentRefreshRate)          { $_.CurrentRefreshRate.ToString() + " Hz" } else { "Bilinmiyor" }
        Write-Host ("    Cozunurluk: " + $cozStr + "  " + $hzStr) -ForegroundColor Gray
        Write-Host ""
    }

    Write-Host "  DirectX Bilgisi:" -ForegroundColor Cyan
    $dxReg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\DirectX" -ErrorAction SilentlyContinue
    if ($dxReg -and $dxReg.Version) {
        Write-Host ("    Surum    : " + $dxReg.Version) -ForegroundColor White
    }
    $build = [System.Environment]::OSVersion.Version.Build
    $dxDest = if ($build -ge 22000) { "DirectX 12 Ultimate" } elseif ($build -ge 17763) { "DirectX 12" } else { "DirectX 11" }
    Write-Host ("    Destekli : " + $dxDest) -ForegroundColor Green

    Write-Host ""
    Write-Host "  1  >  Tam DXDiag raporu olustur (Not Defteri'nde acar, ~20 sn)" -ForegroundColor Gray
    Write-Host "  2  >  Aygit Yoneticisi > Display Adapters" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $s = Read-Host
    switch ($s.Trim()) {
        "1" {
            $dxOut = Join-Path $env:TEMP "dxdiag_rapor.txt"
            Yaz "  DXDiag calistiriliyor (~20 sn bekleniyor)..." Cyan
            $proc = Start-Process "dxdiag" -ArgumentList ("/t " + $dxOut) -PassThru -ErrorAction SilentlyContinue
            if ($proc) {
                $proc.WaitForExit(30000) | Out-Null
                if (Test-Path $dxOut) { Start-Process notepad $dxOut -ErrorAction SilentlyContinue }
                else { Yaz "  Rapor olusturulamadi." Red }
            }
        }
        "2" { Start-Process "devmgmt.msc" -ErrorAction SilentlyContinue }
    }
}

function OyunModuYonetici {
    Baslik "Oyun Modu Yoneticisi" "38"

    $gbYol  = "HKCU:\Software\Microsoft\GameBar"
    $dvYol  = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
    $gcYol  = "HKCU:\System\GameConfigStore"

    $gameMode = (Get-ItemProperty $gbYol  -ErrorAction SilentlyContinue).AllowAutoGameMode
    $dvr      = (Get-ItemProperty $dvYol  -ErrorAction SilentlyContinue).AppCaptureEnabled
    $dvrGc    = (Get-ItemProperty $gcYol  -ErrorAction SilentlyContinue).GameDVR_Enabled

    $gmDurum  = if ($gameMode -eq 1) { "AKTIF  (iyi)" } else { "KAPALI" }
    $gmRenk   = if ($gameMode -eq 1) { "Green" } else { "Yellow" }
    $dvrDurum = if ($dvr -eq 0 -or $dvrGc -eq 0) { "KAPALI (iyi)" } else { "AKTIF  (CPU/GPU yer yer)" }
    $dvrRenk  = if ($dvr -eq 0 -or $dvrGc -eq 0) { "Green" } else { "Yellow" }

    Write-Host ""
    Write-Host ("  Oyun Modu (Game Mode) : " + $gmDurum)  -ForegroundColor $gmRenk
    Write-Host ("  Xbox DVR / Kayit      : " + $dvrDurum) -ForegroundColor $dvrRenk

    Write-Host ""
    Write-Host "  1  >  Oyun Modunu AC   + DVR'i KAPAT  (tavsiye edilen)" -ForegroundColor Green
    Write-Host "  2  >  Oyun Modunu KAPAT + DVR'i AC" -ForegroundColor Yellow
    Write-Host "  3  >  Sadece Oyun Modunu AC" -ForegroundColor Gray
    Write-Host "  4  >  Sadece Oyun Modunu KAPAT" -ForegroundColor Gray
    Write-Host "  5  >  Oyun ayarlari panelini ac" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $s = Read-Host

    switch ($s.Trim()) {
        "1" {
            if (-not (Test-Path $gbYol)) { New-Item $gbYol -Force | Out-Null }
            Set-ItemProperty $gbYol "AllowAutoGameMode" 1 -Type DWord -ErrorAction SilentlyContinue
            if (-not (Test-Path $dvYol)) { New-Item $dvYol -Force | Out-Null }
            Set-ItemProperty $dvYol "AppCaptureEnabled" 0 -Type DWord -ErrorAction SilentlyContinue
            if (-not (Test-Path $gcYol)) { New-Item $gcYol -Force | Out-Null }
            Set-ItemProperty $gcYol "GameDVR_Enabled" 0 -Type DWord -ErrorAction SilentlyContinue
            Yaz "  Oyun Modu AKTIF, DVR KAPALI — Oyun performansi optimize!" Green
        }
        "2" {
            if (-not (Test-Path $gbYol)) { New-Item $gbYol -Force | Out-Null }
            Set-ItemProperty $gbYol "AllowAutoGameMode" 0 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty $dvYol "AppCaptureEnabled" 1 -Type DWord -ErrorAction SilentlyContinue
            Set-ItemProperty $gcYol "GameDVR_Enabled" 1 -Type DWord -ErrorAction SilentlyContinue
            Yaz "  Oyun Modu KAPALI, DVR AKTIF." Yellow
        }
        "3" {
            if (-not (Test-Path $gbYol)) { New-Item $gbYol -Force | Out-Null }
            Set-ItemProperty $gbYol "AllowAutoGameMode" 1 -Type DWord -ErrorAction SilentlyContinue
            Yaz "  Oyun Modu AKTIF!" Green
        }
        "4" {
            if (-not (Test-Path $gbYol)) { New-Item $gbYol -Force | Out-Null }
            Set-ItemProperty $gbYol "AllowAutoGameMode" 0 -Type DWord -ErrorAction SilentlyContinue
            Yaz "  Oyun Modu KAPALI." Yellow
        }
        "5" { Start-Process "ms-settings:gaming-gamebar" -ErrorAction SilentlyContinue }
    }
}

function HesapGuvenlikDenetimi {
    Baslik "Hesap ve Sifre Guvenlik Denetimi" "39"

    Write-Host "  Yerel Kullanici Hesaplari:" -ForegroundColor Cyan
    Write-Host ""

    $uyariSayisi = 0
    Get-LocalUser -ErrorAction SilentlyContinue | ForEach-Object {
        $durum    = if ($_.Enabled) { "AKTIF " } else { "KAPALI" }
        $dRenk    = if ($_.Enabled) { "White" } else { "DarkGray" }
        $sonGiris = if ($_.LastLogon) { $_.LastLogon.ToString("dd.MM.yyyy HH:mm") } else { "Hic girilmemis" }
        Write-Host ("  " + $_.Name.PadRight(22) + $durum + "  Son giris: " + $sonGiris) -ForegroundColor $dRenk
        if ($_.PasswordNeverExpires -and $_.Enabled) {
            Write-Host "    ^ Sifre suresi BITMEZ — guvenlik riski" -ForegroundColor Yellow
            $uyariSayisi++
        }
        if ($_.PasswordRequired -eq $false -and $_.Enabled) {
            Write-Host "    ^ SIFRE YOK! Ciddi guvenlik acigi!" -ForegroundColor Red
            $uyariSayisi++
        }
    }

    Write-Host ""
    Write-Host "  Yonetici Grubu Uyeleri:" -ForegroundColor Cyan
    Get-LocalGroupMember -Group "Administrators" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host ("    " + $_.Name) -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "  Sifre Politikasi:" -ForegroundColor Cyan
    $netAcc = & net accounts 2>&1
    $netAcc | Where-Object { $_ -match ":" } | Select-Object -First 8 | ForEach-Object {
        Write-Host ("    " + $_) -ForegroundColor Gray
    }

    Write-Host ""
    if ($uyariSayisi -gt 0) {
        Write-Host ("  " + $uyariSayisi + " guvenlik uyarisi bulundu!") -ForegroundColor Red
    } else {
        Yaz "  Hesap guvenlik durumu iyi." Green
    }
    SkorKaydet "HesapGuvenlik" (if ($uyariSayisi -eq 0) { 10 } elseif ($uyariSayisi -le 2) { 5 } else { 0 }) 10
}

function SuphesizBaslangic {
    Baslik "Suphe Uyandiran Baslangic Programlari" "40"
    Yaz "  Kayit defteri baslangic konumlari taranıyor..." Gray

    $ogeler = [System.Collections.Generic.List[PSObject]]::new()
    $regYollar = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    )

    foreach ($yol in $regYollar) {
        if (Test-Path $yol) {
            $ozellikler = Get-ItemProperty $yol -ErrorAction SilentlyContinue
            if ($ozellikler) {
                $ozellikler | Get-Member -MemberType NoteProperty |
                Where-Object { $_.Name -notmatch "^PS" } | ForEach-Object {
                    $ad  = $_.Name
                    $cmd = $ozellikler.$ad
                    $ogeler.Add([PSCustomObject]@{ Ad=$ad; Komut=$cmd; Kaynak=$yol })
                }
            }
        }
    }

    Write-Host ""
    Write-Host ("  Toplam baslangic ogesi: " + $ogeler.Count) -ForegroundColor Gray
    Write-Host ""

    $supheli = 0
    foreach ($oge in $ogeler) {
        $exeYol = $null
        if ($oge.Komut -match '"([^"]+\.exe)"') { $exeYol = $Matches[1] }
        elseif ($oge.Komut -match '([^\s"]+\.exe)') { $exeYol = $Matches[1] }

        $imzali = $true
        if ($exeYol -and (Test-Path $exeYol)) {
            $sig = Get-AuthenticodeSignature $exeYol -ErrorAction SilentlyContinue
            $imzali = ($sig -and $sig.Status -eq "Valid")
        } elseif ($exeYol -and -not (Test-Path $exeYol)) {
            $imzali = $false
        }

        $etiket = if (-not $exeYol)   { " [YOL YOK?]  " } `
                  elseif (-not $imzali) { " [IMZASIZ!]  " } `
                  else                   { " [OK]        " }
        $renk   = if (-not $exeYol -or -not $imzali) { if (-not $imzali -and $exeYol) { "Red" } else { "Yellow" } } else { "Green" }

        if (-not $imzali -or -not $exeYol) { $supheli++ }

        Write-Host ("  " + $oge.Ad.PadRight(28) + $etiket) -ForegroundColor $renk
        $cmdKisa = if ($oge.Komut.Length -gt 72) { $oge.Komut.Substring(0,72) + "..." } else { $oge.Komut }
        Write-Host ("    " + $cmdKisa) -ForegroundColor DarkGray
    }

    Write-Host ""
    if ($supheli -gt 0) {
        Write-Host ("  " + $supheli + " suphe uyandiran baslangic ogesi bulundu!") -ForegroundColor Red
        Yaz "  Yonetmek icin: Gorev Yoneticisi > Baslangic sekmesi" Yellow
    } else {
        Yaz "  Tum baslangic ogeleri temiz ve imzali." Green
    }
    SkorKaydet "BaslangicGuvenlik" (if ($supheli -eq 0) { 10 } elseif ($supheli -le 2) { 5 } else { 0 }) 10
}

#endregion

#region ── MODUL 41-44: YENI PERFORMANS MODULLERI ──────────────

function FormatSonrasiSihirbaz {
    Baslik "Format Sonrasi Sihirbaz" "41"

    if (-not (YoneticiKontrol)) {
        Yaz "  Bu modul icin Yonetici yetkisi gereklidir!" Red
        return
    }

    Write-Host ""
    Write-Host "  ============================================================" -ForegroundColor Cyan
    Write-Host "  FORMAT SONRASI SIHIRBAZ" -ForegroundColor Cyan
    Write-Host "  ============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Bu sihirbaz yeni formatlanan bilgisayarini tek tikla optimize eder." -ForegroundColor White
    Write-Host "  Uygulanacak islemler:" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   [1]  Geri yukleme noktasi olustur              (guvenlik)" -ForegroundColor DarkGray
    Write-Host "   [2]  Bloatware uygulamalarini kaldir            (Xbox, Cortana, vb.)" -ForegroundColor DarkGray
    Write-Host "   [3]  Windows performans tweakleri               (animasyon, efekt kapat)" -ForegroundColor DarkGray
    Write-Host "   [4]  Guc planini Yuksek Performans'a ayarla    (max CPU)" -ForegroundColor DarkGray
    Write-Host "   [5]  Arka plan uygulamalarini kapat            (RAM tasarrufu)" -ForegroundColor DarkGray
    Write-Host "   [6]  Telemetri ve veri toplamayı azalt         (gizlilik + performans)" -ForegroundColor DarkGray
    Write-Host "   [7]  DNS optimize et (Cloudflare 1.1.1.1)     (hizli internet)" -ForegroundColor DarkGray
    Write-Host "   [8]  FPS ve oyun optimizasyonlari              (GameDVR, MMCSS, Nagle)" -ForegroundColor DarkGray
    Write-Host "   [9]  RAM optimize et                           (bellek bosalt)" -ForegroundColor DarkGray
    Write-Host "  [10]  Sanal bellek (pagefile) optimize et       (kasma onle)" -ForegroundColor DarkGray
    Write-Host "  [11]  Gereksiz servisleri durdur                (kaynak tasarrufu)" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Tahmini sure: 5-10 dakika" -ForegroundColor Yellow
    Write-Host ""
    if ($env:SISTEMBAK_GUI -eq '1') {
        $sec = "T"
    } else {
        Write-Host "  [T]  TAMAMINI UYGULA (onerilen)" -ForegroundColor Green
        Write-Host "  [S]  Secmeli uygula (numaralar gir: 1,3,5)" -ForegroundColor Yellow
        Write-Host "  [0]  Geri" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
        $sec = (Read-Host).Trim()
        if ($sec -eq "0") { return }
    }

    $adimlar = @(1,2,3,4,5,6,7,8,9,10,11)
    if ($sec -notmatch "^[Tt]$") {
        $adimlar = @()
        $sec -split "," | ForEach-Object {
            $n = $_.Trim()
            if ($n -match "^\d+$" -and [int]$n -ge 1 -and [int]$n -le 11) {
                $adimlar += [int]$n
            }
        }
        if ($adimlar.Count -eq 0) { Yaz "  Gecersiz secim." Yellow; return }
    }

    $toplam = $adimlar.Count
    $simdiki = 0
    $baslangicSure = Get-Date

    # --- 1. Geri Yukleme Noktasi ---
    if ($adimlar -contains 1) {
        $simdiki++
        Write-Host ""
        Write-Host ("  [{0}/{1}] Geri yukleme noktasi olusturuluyor..." -f $simdiki, $toplam) -ForegroundColor Cyan
        try {
            Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop
            $etiket = "SistemBakim_FormatSonrasi_{0}" -f (Get-Date -Format "ddMMyyyy_HHmm")
            Checkpoint-Computer -Description $etiket -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
            Yaz ("    Olusturuldu: " + $etiket) Green
        } catch {
            Yaz ("    Atlandi: " + $_.Exception.Message) Yellow
        }
    }

    # --- 2. Bloatware Kaldir ---
    if ($adimlar -contains 2) {
        $simdiki++
        Write-Host ""
        Write-Host ("  [{0}/{1}] Bloatware uygulamalari kaldiriliyor..." -f $simdiki, $toplam) -ForegroundColor Cyan
        $bloatPaketleri = @(
            "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider",
            "Microsoft.Xbox.TCUI", "Microsoft.GamingApp",
            "Microsoft.549981C3F5F10", "Microsoft.BingNews",
            "Microsoft.BingWeather", "Microsoft.WindowsFeedbackHub",
            "Microsoft.GetHelp", "Microsoft.MicrosoftSolitaireCollection",
            "Microsoft.ZuneVideo", "Microsoft.ZuneMusic",
            "microsoft.windowscommunicationsapps", "Microsoft.People",
            "Microsoft.SkypeApp", "MicrosoftTeams",
            "Microsoft.MicrosoftOfficeHub", "Microsoft.Microsoft3DViewer",
            "Microsoft.MixedReality.Portal", "Microsoft.WindowsMaps",
            "Microsoft.YourPhone", "Microsoft.PowerAutomateDesktop",
            "MicrosoftCorporationII.QuickAssist", "Microsoft.MSPaint",
            "Microsoft.Todos", "Clipchamp.Clipchamp",
            "Microsoft.Windows.DevHome", "Microsoft.MicrosoftStickyNotes",
            "Microsoft.WindowsAlarms", "Microsoft.549981C3F5F10",
            "Microsoft.BingFinance", "Microsoft.BingTranslator",
            "MicrosoftCorporationII.MicrosoftFamily",
            "Microsoft.WindowsSoundRecorder"
        )
        $kaldirildi = 0
        foreach ($paket in $bloatPaketleri) {
            $pkg = Get-AppxPackage -Name ($paket + "*") -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($pkg) {
                try {
                    Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
                    $kaldirildi++
                } catch {
                    try { Remove-AppxPackage -Package $pkg.PackageFullName -AllUsers -ErrorAction Stop; $kaldirildi++ } catch {}
                }
            }
        }
        Yaz ("    " + $kaldirildi + " uygulama kaldirildi.") Green
    }

    # --- 3. Windows Performans Tweaks ---
    if ($adimlar -contains 3) {
        $simdiki++
        Write-Host ""
        Write-Host ("  [{0}/{1}] Windows performans tweakleri uygulanıyor..." -f $simdiki, $toplam) -ForegroundColor Cyan
        WindowsPerformansTweaks -OtomatikUygula
    }

    # --- 4. Guc Plani ---
    if ($adimlar -contains 4) {
        $simdiki++
        Write-Host ""
        Write-Host ("  [{0}/{1}] Guc plani ayarlanıyor..." -f $simdiki, $toplam) -ForegroundColor Cyan
        # Ultimate Performance planini aktif et (varsa) yoksa High Performance
        $ultimate = "e9a42b02-d5df-448d-aa00-03f14749eb61"
        $highPerf = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        # Once Ultimate Performance planini ekle (Win10 1803+)
        powercfg /duplicatescheme $ultimate 2>&1 | Out-Null
        $sonuc = powercfg /setactive $ultimate 2>&1
        if ($LASTEXITCODE -ne 0) {
            powercfg /setactive $highPerf 2>&1 | Out-Null
            Yaz "    Yuksek Performans plani aktif." Green
        } else {
            Yaz "    Ultimate Performance plani aktif!" Green
        }
        # CPU parking devre disi (tum cekirdekler aktif)
        powercfg /setacvalueindex scheme_current sub_processor CPMINCORES 100 2>&1 | Out-Null
        powercfg /setactive scheme_current 2>&1 | Out-Null
    }

    # --- 5. Arka Plan Uygulamalari Kapat ---
    if ($adimlar -contains 5) {
        $simdiki++
        Write-Host ""
        Write-Host ("  [{0}/{1}] Arka plan uygulamalari kapatılıyor..." -f $simdiki, $toplam) -ForegroundColor Cyan
        $bgYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
        if (-not (Test-Path $bgYol)) { New-Item -Path $bgYol -Force | Out-Null }
        Set-ItemProperty -Path $bgYol -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force
        # Ek: Privacy ayarlari
        $privYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"
        if (-not (Test-Path $privYol)) { New-Item -Path $privYol -Force | Out-Null }
        Set-ItemProperty -Path $privYol -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord -Force
        Yaz "    Arka plan uygulamalari devre disi." Green
    }

    # --- 6. Telemetri Azalt ---
    if ($adimlar -contains 6) {
        $simdiki++
        Write-Host ""
        Write-Host ("  [{0}/{1}] Telemetri ve veri toplama azaltılıyor..." -f $simdiki, $toplam) -ForegroundColor Cyan
        # DiagTrack servisi
        Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
        # dmwappushservice
        Stop-Service -Name "dmwappushservice" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "dmwappushservice" -StartupType Disabled -ErrorAction SilentlyContinue
        # Telemetri seviyesi: Security (0) veya Basic (1)
        $telYol = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        if (-not (Test-Path $telYol)) { New-Item -Path $telYol -Force | Out-Null }
        Set-ItemProperty -Path $telYol -Name "AllowTelemetry" -Value 0 -Type DWord -Force
        # Reklam kimligi kapat
        $advYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        if (-not (Test-Path $advYol)) { New-Item -Path $advYol -Force | Out-Null }
        Set-ItemProperty -Path $advYol -Name "Enabled" -Value 0 -Type DWord -Force
        # WiFi Sense kapat
        $wifiYol = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
        if (Test-Path $wifiYol) {
            Set-ItemProperty -Path $wifiYol -Name "AutoConnectAllowedOEM" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        }
        Yaz "    Telemetri, reklam kimligi, WiFi Sense kapatildi." Green
    }

    # --- 7. DNS Optimize ---
    if ($adimlar -contains 7) {
        $simdiki++
        Write-Host ""
        Write-Host ("  [{0}/{1}] DNS optimize ediliyor (Cloudflare)..." -f $simdiki, $toplam) -ForegroundColor Cyan
        $adapters = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Up" }
        foreach ($adapter in $adapters) {
            try {
                Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses @("1.1.1.1","1.0.0.1","2606:4700:4700::1111","2606:4700:4700::1001") -ErrorAction Stop
                Yaz ("    " + $adapter.Name + ": DNS -> 1.1.1.1 / 1.0.0.1") Green
            } catch {
                Yaz ("    " + $adapter.Name + ": DNS ayarlanamadi.") Yellow
            }
        }
        ipconfig /flushdns 2>&1 | Out-Null
        Yaz "    DNS onbellegi temizlendi." Green
    }

    # --- 8. FPS Optimizasyonlari ---
    if ($adimlar -contains 8) {
        $simdiki++
        Write-Host ""
        Write-Host ("  [{0}/{1}] FPS ve oyun optimizasyonlari uygulanıyor..." -f $simdiki, $toplam) -ForegroundColor Cyan
        FpsOyunOptimizasyonu -OtomatikUygula
    }

    # --- 9. RAM Optimize ---
    if ($adimlar -contains 9) {
        $simdiki++
        Write-Host ""
        Write-Host ("  [{0}/{1}] RAM optimize ediliyor..." -f $simdiki, $toplam) -ForegroundColor Cyan
        RamOptimizasyonu -OtomatikUygula
    }

    # --- 10. Pagefile Optimize ---
    if ($adimlar -contains 10) {
        $simdiki++
        Write-Host ""
        Write-Host ("  [{0}/{1}] Sanal bellek (pagefile) optimize ediliyor..." -f $simdiki, $toplam) -ForegroundColor Cyan
        SanalBellekOptimize -OtomatikUygula
    }

    # --- 11. Gereksiz Servisleri Durdur ---
    if ($adimlar -contains 11) {
        $simdiki++
        Write-Host ""
        Write-Host ("  [{0}/{1}] Gereksiz servisler durduruluyor..." -f $simdiki, $toplam) -ForegroundColor Cyan
        $kapServisler = @(
            @{Ad="SysMain";       Aciklama="Superfetch (SSD icin gereksiz)"}
            @{Ad="WSearch";       Aciklama="Windows Search Indexer"}
            @{Ad="DiagTrack";     Aciklama="Telemetri Takip"}
            @{Ad="MapsBroker";    Aciklama="Haritalar Indir Yoneticisi"}
            @{Ad="lfsvc";         Aciklama="Konum Servisi"}
            @{Ad="RetailDemo";    Aciklama="Magaza Demo Servisi"}
            @{Ad="wisvc";         Aciklama="Windows Insider Servisi"}
            @{Ad="TabletInputService"; Aciklama="Tablet Klavye Servisi"}
            @{Ad="PhoneSvc";      Aciklama="Telefon Servisi"}
            @{Ad="WMPNetworkSvc"; Aciklama="Media Player Ag Servisi"}
            @{Ad="Fax";           Aciklama="Faks Servisi"}
        )
        $durdurulan = 0
        foreach ($svc in $kapServisler) {
            $servis = Get-Service -Name $svc.Ad -ErrorAction SilentlyContinue
            if ($servis -and $servis.Status -eq "Running") {
                Stop-Service -Name $svc.Ad -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svc.Ad -StartupType Manual -ErrorAction SilentlyContinue
                $durdurulan++
                Yaz ("    Durduruldu: " + $svc.Ad + " (" + $svc.Aciklama + ")") Green
            }
        }
        if ($durdurulan -eq 0) { Yaz "    Gereksiz calisan servis yok." Green }
    }

    # --- SONUC ---
    $gecenSure = [int]((Get-Date) - $baslangicSure).TotalSeconds
    Write-Host ""
    Write-Host ("  " + ("=" * 60)) -ForegroundColor Green
    Write-Host "  FORMAT SONRASI SIHIRBAZ TAMAMLANDI!" -ForegroundColor Green
    Write-Host ("  Uygulanan adim  : " + $toplam) -ForegroundColor Cyan
    Write-Host ("  Gecen sure      : " + $gecenSure + " saniye") -ForegroundColor Cyan
    Write-Host "" -ForegroundColor Cyan
    Write-Host "  Bilgisayariniz artik maksimum performansa hazir!" -ForegroundColor Green
    Write-Host "  ONEMLI: Bazi degisiklikler icin yeniden baslatma gerekebilir." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Onerilir:" -ForegroundColor DarkGray
    Write-Host "    - Bilgisayari yeniden baslatin" -ForegroundColor DarkGray
    Write-Host "    - Ardindan [44] Donanim Skoru & Oneri modulunu calistirin" -ForegroundColor DarkGray
    Write-Host ("  " + ("=" * 60)) -ForegroundColor Green
    RaporVeriEkle "format_sonrasi" "Tamamlandi"
}

function WindowsPerformansTweaks {
    param([switch]$OtomatikUygula, [switch]$OtomatikGeriAl)

    if (-not $OtomatikUygula) { Baslik "Windows Performans Tweakleri" "42" }

    if (-not (YoneticiKontrol)) {
        Yaz "  Bu modul icin Yonetici yetkisi gereklidir!" Red
        return
    }

    if ($env:SISTEMBAK_GUI -eq '1' -and -not $OtomatikGeriAl) { $OtomatikUygula = $true }
    if (-not $OtomatikUygula -and -not $OtomatikGeriAl) {
        Write-Host ""
        Write-Host "  Bu modul Windows'un gizli performans ayarlarini optimize eder:" -ForegroundColor Cyan
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host "   1. Seffaflik (Transparency) efektlerini kapat" -ForegroundColor Gray
        Write-Host "   2. Animasyonlari kapat (pencere acma/kapama)" -ForegroundColor Gray
        Write-Host "   3. Windows Search Indexer'i durdur" -ForegroundColor Gray
        Write-Host "   4. Tips & Suggestions bildirimlerini kapat" -ForegroundColor Gray
        Write-Host "   5. Arka plan uygulamalarini kapat" -ForegroundColor Gray
        Write-Host "   6. Delivery Optimization (P2P Update) kapat" -ForegroundColor Gray
        Write-Host "   7. Telemetri servislerini durdur" -ForegroundColor Gray
        Write-Host "   8. Storage Sense (otomatik temizlik) aktif et" -ForegroundColor Gray
        Write-Host "   9. Fullscreen Optimizations devre disi" -ForegroundColor Gray
        Write-Host "  10. Cortana devre disi" -ForegroundColor Gray
        Write-Host "  11. Clipboard bulut senkronizasyonunu kapat" -ForegroundColor Gray
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  [1]  Tum tweakleri UYGULA  (onerilen)" -ForegroundColor Green
        Write-Host "  [2]  Tum tweakleri GERI AL (Windows varsayilanlari)" -ForegroundColor Yellow
        Write-Host "  [0]  Geri" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
        $sec = Read-Host
        if ($sec -eq "0") { return }
        if ($sec -eq "2") { $OtomatikGeriAl = $true }
    }

    $geriAl = $OtomatikGeriAl.IsPresent

    # 1. Seffaflik (Transparency)
    Write-Host "  -- [1/11] Seffaflik Efektleri" -ForegroundColor Cyan
    $transpYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (-not (Test-Path $transpYol)) { New-Item -Path $transpYol -Force | Out-Null }
    Set-ItemProperty -Path $transpYol -Name "EnableTransparency" -Value $(if ($geriAl) {1} else {0}) -Type DWord -Force
    if ($geriAl) { Yaz "    Seffaflik geri acildi." Gray } else { Yaz "    Seffaflik kapatildi." Green }

    # 2. Animasyonlar
    Write-Host "  -- [2/11] Animasyonlar" -ForegroundColor Cyan
    $animYol = "HKCU:\Control Panel\Desktop\WindowMetrics"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value $(if ($geriAl) {"400"} else {"0"}) -Force
    # SystemPropertiesPerformance yerine registry ile
    $vfxYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (-not (Test-Path $vfxYol)) { New-Item -Path $vfxYol -Force | Out-Null }
    Set-ItemProperty -Path $vfxYol -Name "VisualFXSetting" -Value $(if ($geriAl) {0} else {2}) -Type DWord -Force
    # Tek tek animasyonlar
    $advYol = "HKCU:\Control Panel\Desktop"
    Set-ItemProperty -Path $advYol -Name "UserPreferencesMask" -Value $(
        if ($geriAl) { [byte[]](0x9E,0x1E,0x07,0x80,0x12,0x00,0x00,0x00) }
        else          { [byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00) }
    ) -Type Binary -Force
    if ($geriAl) { Yaz "    Animasyonlar geri acildi." Gray } else { Yaz "    Animasyonlar kapatildi." Green }

    # 3. Windows Search Indexer
    Write-Host "  -- [3/11] Windows Search Indexer" -ForegroundColor Cyan
    if ($geriAl) {
        Set-Service -Name "WSearch" -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name "WSearch" -ErrorAction SilentlyContinue
        Yaz "    Search Indexer geri baslatildi." Gray
    } else {
        Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "WSearch" -StartupType Manual -ErrorAction SilentlyContinue
        Yaz "    Search Indexer durduruldu." Green
    }

    # 4. Tips & Suggestions
    Write-Host "  -- [4/11] Tips ve Suggestions" -ForegroundColor Cyan
    $tipsYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    if (-not (Test-Path $tipsYol)) { New-Item -Path $tipsYol -Force | Out-Null }
    $tipsVal = if ($geriAl) { 1 } else { 0 }
    Set-ItemProperty -Path $tipsYol -Name "SoftLandingEnabled" -Value $tipsVal -Type DWord -Force
    Set-ItemProperty -Path $tipsYol -Name "SubscribedContent-338389Enabled" -Value $tipsVal -Type DWord -Force
    Set-ItemProperty -Path $tipsYol -Name "SubscribedContent-310093Enabled" -Value $tipsVal -Type DWord -Force
    Set-ItemProperty -Path $tipsYol -Name "SubscribedContent-338388Enabled" -Value $tipsVal -Type DWord -Force
    Set-ItemProperty -Path $tipsYol -Name "SystemPaneSuggestionsEnabled" -Value $tipsVal -Type DWord -Force
    Set-ItemProperty -Path $tipsYol -Name "RotatingLockScreenOverlayEnabled" -Value $tipsVal -Type DWord -Force
    Set-ItemProperty -Path $tipsYol -Name "RotatingLockScreenEnabled" -Value $tipsVal -Type DWord -Force
    if ($geriAl) { Yaz "    Tips/Suggestions geri acildi." Gray } else { Yaz "    Tips, Suggestions, Spotlight kapatildi." Green }

    # 5. Arka Plan Uygulamalari
    Write-Host "  -- [5/11] Arka Plan Uygulamalari" -ForegroundColor Cyan
    $bgYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (-not (Test-Path $bgYol)) { New-Item -Path $bgYol -Force | Out-Null }
    Set-ItemProperty -Path $bgYol -Name "GlobalUserDisabled" -Value $(if ($geriAl) {0} else {1}) -Type DWord -Force
    if ($geriAl) { Yaz "    Arka plan uygulamalari geri acildi." Gray } else { Yaz "    Arka plan uygulamalari kapatildi." Green }

    # 6. Delivery Optimization
    Write-Host "  -- [6/11] Delivery Optimization (P2P Update)" -ForegroundColor Cyan
    $doYol = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
    if (Test-Path $doYol) {
        Set-ItemProperty -Path $doYol -Name "DODownloadMode" -Value $(if ($geriAl) {3} else {0}) -Type DWord -Force -ErrorAction SilentlyContinue
    }
    $doPol = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
    if (-not (Test-Path $doPol)) { New-Item -Path $doPol -Force | Out-Null }
    Set-ItemProperty -Path $doPol -Name "DODownloadMode" -Value $(if ($geriAl) {3} else {0}) -Type DWord -Force
    if ($geriAl) { Yaz "    Delivery Optimization geri acildi." Gray } else { Yaz "    P2P guncelleme paylaşimi kapatildi." Green }

    # 7. Telemetri
    Write-Host "  -- [7/11] Telemetri Servisleri" -ForegroundColor Cyan
    $telServisler = @("DiagTrack","dmwappushservice","diagnosticshub.standardcollector.service")
    foreach ($ts in $telServisler) {
        $svc = Get-Service -Name $ts -ErrorAction SilentlyContinue
        if ($svc) {
            if ($geriAl) {
                Set-Service -Name $ts -StartupType Automatic -ErrorAction SilentlyContinue
                Start-Service -Name $ts -ErrorAction SilentlyContinue
            } else {
                Stop-Service -Name $ts -Force -ErrorAction SilentlyContinue
                Set-Service -Name $ts -StartupType Disabled -ErrorAction SilentlyContinue
            }
        }
    }
    $telRegYol = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (-not (Test-Path $telRegYol)) { New-Item -Path $telRegYol -Force | Out-Null }
    Set-ItemProperty -Path $telRegYol -Name "AllowTelemetry" -Value $(if ($geriAl) {3} else {0}) -Type DWord -Force
    if ($geriAl) { Yaz "    Telemetri servisleri geri acildi." Gray } else { Yaz "    Telemetri servisleri devre disi." Green }

    # 8. Storage Sense
    Write-Host "  -- [8/11] Storage Sense" -ForegroundColor Cyan
    $ssYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy"
    if (-not (Test-Path $ssYol)) { New-Item -Path $ssYol -Force | Out-Null }
    Set-ItemProperty -Path $ssYol -Name "01" -Value $(if ($geriAl) {0} else {1}) -Type DWord -Force
    Set-ItemProperty -Path $ssYol -Name "04" -Value 1 -Type DWord -Force    # Temp temizle
    Set-ItemProperty -Path $ssYol -Name "08" -Value 1 -Type DWord -Force    # Cop kutusunu temizle
    Set-ItemProperty -Path $ssYol -Name "32" -Value 0 -Type DWord -Force    # 30 gunluk cycle
    Set-ItemProperty -Path $ssYol -Name "256" -Value 14 -Type DWord -Force  # 14 gun sonra temizle
    if ($geriAl) { Yaz "    Storage Sense kapatildi." Gray } else { Yaz "    Storage Sense aktif (oto-temizlik)." Green }

    # 9. Fullscreen Optimizations
    Write-Host "  -- [9/11] Fullscreen Optimizations" -ForegroundColor Cyan
    $fsoYol = "HKCU:\System\GameConfigStore"
    if (-not (Test-Path $fsoYol)) { New-Item -Path $fsoYol -Force | Out-Null }
    Set-ItemProperty -Path $fsoYol -Name "GameDVR_FSEBehaviorMode" -Value $(if ($geriAl) {0} else {2}) -Type DWord -Force
    Set-ItemProperty -Path $fsoYol -Name "GameDVR_HonorUserFSEBehaviorMode" -Value $(if ($geriAl) {0} else {1}) -Type DWord -Force
    Set-ItemProperty -Path $fsoYol -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value $(if ($geriAl) {0} else {1}) -Type DWord -Force
    if ($geriAl) { Yaz "    FSO geri acildi." Gray } else { Yaz "    Fullscreen Optimizations devre disi." Green }

    # 10. Cortana
    Write-Host "  -- [10/11] Cortana" -ForegroundColor Cyan
    $cortYol = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    if (-not (Test-Path $cortYol)) { New-Item -Path $cortYol -Force | Out-Null }
    Set-ItemProperty -Path $cortYol -Name "AllowCortana" -Value $(if ($geriAl) {1} else {0}) -Type DWord -Force
    Set-ItemProperty -Path $cortYol -Name "AllowSearchToUseLocation" -Value $(if ($geriAl) {1} else {0}) -Type DWord -Force
    Set-ItemProperty -Path $cortYol -Name "ConnectedSearchUseWeb" -Value $(if ($geriAl) {1} else {0}) -Type DWord -Force
    if ($geriAl) { Yaz "    Cortana geri acildi." Gray } else { Yaz "    Cortana ve web araması kapatildi." Green }

    # 11. Clipboard Sync
    Write-Host "  -- [11/11] Clipboard Bulut Senkronizasyonu" -ForegroundColor Cyan
    $clipYol = "HKCU:\Software\Microsoft\Clipboard"
    if (-not (Test-Path $clipYol)) { New-Item -Path $clipYol -Force | Out-Null }
    Set-ItemProperty -Path $clipYol -Name "EnableClipboardHistory" -Value $(if ($geriAl) {1} else {0}) -Type DWord -Force
    Set-ItemProperty -Path $clipYol -Name "CloudClipboardAutomaticUpload" -Value $(if ($geriAl) {1} else {0}) -Type DWord -Force
    if ($geriAl) { Yaz "    Clipboard sync geri acildi." Gray } else { Yaz "    Clipboard cloud sync kapatildi." Green }

    Write-Host ""
    Write-Host ("  " + ("=" * 56)) -ForegroundColor $(if ($geriAl){"Yellow"} else {"Green"})
    if ($geriAl) {
        Yaz "  Tum Windows tweakleri GERI ALINDI." Yellow
    } else {
        Yaz "  11 Windows performans tweaki UYGULANDI!" Green
        Yaz "  Bazi degisiklikler oturum kapatip acinca tam gercerli olur." DarkGray
    }
    Write-Host ("  " + ("=" * 56)) -ForegroundColor $(if ($geriAl){"Yellow"} else {"Green"})
    RaporVeriEkle "windows_tweaks" $(if ($geriAl) {"Geri alindi"} else {"Uygulandi"})
}

function SanalBellekOptimize {
    param([switch]$OtomatikUygula)

    if (-not $OtomatikUygula) { Baslik "Sanal Bellek (Pagefile) Optimize" "43" }

    if (-not (YoneticiKontrol)) {
        Yaz "  Bu modul icin Yonetici yetkisi gereklidir!" Red
        return
    }

    # RAM miktarini al
    $os = Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue
    $ramMB = [int]($os.TotalVisibleMemorySize / 1024)
    $ramGB = [Math]::Round($ramMB / 1024, 1)

    # Mevcut pagefile ayarini oku
    $pagefile = Get-WmiObject Win32_PageFileSetting -ErrorAction SilentlyContinue
    $mevcutDurum = "Otomatik (Windows yonetiyor)"
    $mevcutMin = 0; $mevcutMax = 0
    if ($pagefile) {
        $mevcutMin = $pagefile.InitialSize
        $mevcutMax = $pagefile.MaximumSize
        if ($mevcutMin -eq 0 -and $mevcutMax -eq 0) {
            $mevcutDurum = "Otomatik (Windows yonetiyor)"
        } else {
            $mevcutDurum = ($mevcutMin.ToString() + " MB - " + $mevcutMax.ToString() + " MB")
        }
    }

    # Disk tipini tespit et (SSD mi HDD mi)
    $ssdMi = $false
    try {
        $fizikDisk = Get-PhysicalDisk -ErrorAction SilentlyContinue | Where-Object { $_.DeviceID -eq 0 } | Select-Object -First 1
        if ($fizikDisk -and $fizikDisk.MediaType -eq "SSD") { $ssdMi = $true }
    } catch {}

    # Onerilen pagefile boyutu hesapla
    # Dusuk RAM: 1.5x - 2x RAM
    # Orta RAM: 1x - 1.5x RAM
    # Yuksek RAM: 0.5x - 1x RAM (max 8GB pagefile)
    if ($ramGB -le 4) {
        $oneMin = [int]($ramMB * 1.5)
        $oneMax = [int]($ramMB * 3)
        $oneriMetin = "Dusuk RAM (" + $ramGB.ToString() + " GB): Buyuk pagefile oneriliyor"
    } elseif ($ramGB -le 8) {
        $oneMin = [int]($ramMB * 1.0)
        $oneMax = [int]($ramMB * 2)
        $oneriMetin = "Orta RAM (" + $ramGB.ToString() + " GB): Orta pagefile oneriliyor"
    } elseif ($ramGB -le 16) {
        $oneMin = [int]($ramMB * 0.5)
        $oneMax = $ramMB
        $oneriMetin = "Iyi RAM (" + $ramGB.ToString() + " GB): Kucuk pagefile yeterli"
    } else {
        $oneMin = 4096
        $oneMax = 8192
        $oneriMetin = "Yuksek RAM (" + $ramGB.ToString() + " GB): Sabit 4-8 GB pagefile"
    }
    # Max cap: 16 GB
    if ($oneMax -gt 16384) { $oneMax = 16384 }

    if (-not $OtomatikUygula) {
        Write-Host ""
        Write-Host "  Sistem Bilgileri:" -ForegroundColor Cyan
        Durum "  Fiziksel RAM"   ($ramGB.ToString() + " GB  (" + $ramMB.ToString() + " MB)")
        Durum "  Disk Tipi"      $(if ($ssdMi) {"SSD (hizli erisim)"} else {"HDD (yavas)"})
        Durum "  Mevcut Pagefile" $mevcutDurum $(if ($mevcutMin -eq 0) {"Yellow"} else {"Gray"})
        Write-Host ""
        Write-Host ("  " + $oneriMetin) -ForegroundColor Yellow
        Write-Host ("  Onerilen: " + $oneMin + " MB - " + $oneMax + " MB") -ForegroundColor Green
        Write-Host ""
        Write-Host "  [1]  Onerilen boyutu uygula" -ForegroundColor Green
        Write-Host "  [2]  Manuel boyut gir (MB cinsinden)" -ForegroundColor Gray
        Write-Host "  [3]  Otomatik yonetime birak (Windows)" -ForegroundColor Gray
        Write-Host "  [0]  Geri" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
        $sec = Read-Host
    } else {
        $sec = "1"
    }

    switch ($sec) {
        "1" {
            try {
                # Otomatik yonetimi kapat
                $cs = Get-WmiObject Win32_ComputerSystem -ErrorAction Stop
                if ($cs.AutomaticManagedPagefile) {
                    $cs.AutomaticManagedPagefile = $false
                    $cs.Put() | Out-Null
                }
                # Mevcut pagefile'i sil ve yeniden olustur
                $mevcutPF = Get-WmiObject Win32_PageFileSetting -ErrorAction SilentlyContinue
                if ($mevcutPF) { $mevcutPF.Delete() }
                # Yeni pagefile olustur
                $pfYeni = ([WMIClass]"root\cimv2:Win32_PageFileSetting").CreateInstance()
                $pfYeni.Name        = "C:\pagefile.sys"
                $pfYeni.InitialSize = $oneMin
                $pfYeni.MaximumSize = $oneMax
                $pfYeni.Put() | Out-Null
                Yaz ("  Pagefile ayarlandi: " + $oneMin + " MB - " + $oneMax + " MB") Green
                Yaz "  Yeniden baslatma gerekli!" Yellow
            } catch {
                Yaz ("  Pagefile ayarlanamadi: " + $_.Exception.Message) Red
            }
        }
        "2" {
            Write-Host "  Min boyut (MB): " -ForegroundColor Yellow -NoNewline
            $manMin = [int](Read-Host)
            Write-Host "  Max boyut (MB): " -ForegroundColor Yellow -NoNewline
            $manMax = [int](Read-Host)
            if ($manMin -gt 0 -and $manMax -ge $manMin) {
                try {
                    $cs = Get-WmiObject Win32_ComputerSystem -ErrorAction Stop
                    if ($cs.AutomaticManagedPagefile) {
                        $cs.AutomaticManagedPagefile = $false
                        $cs.Put() | Out-Null
                    }
                    $mevcutPF = Get-WmiObject Win32_PageFileSetting -ErrorAction SilentlyContinue
                    if ($mevcutPF) { $mevcutPF.Delete() }
                    $pfYeni = ([WMIClass]"root\cimv2:Win32_PageFileSetting").CreateInstance()
                    $pfYeni.Name        = "C:\pagefile.sys"
                    $pfYeni.InitialSize = $manMin
                    $pfYeni.MaximumSize = $manMax
                    $pfYeni.Put() | Out-Null
                    Yaz ("  Pagefile ayarlandi: " + $manMin + " MB - " + $manMax + " MB") Green
                    Yaz "  Yeniden baslatma gerekli!" Yellow
                } catch {
                    Yaz ("  Pagefile ayarlanamadi: " + $_.Exception.Message) Red
                }
            } else {
                Yaz "  Gecersiz boyut." Red
            }
        }
        "3" {
            try {
                $cs = Get-WmiObject Win32_ComputerSystem -ErrorAction Stop
                $cs.AutomaticManagedPagefile = $true
                $cs.Put() | Out-Null
                Yaz "  Pagefile otomatik yonetime birakildi." Green
            } catch {
                Yaz ("  Hata: " + $_.Exception.Message) Red
            }
        }
    }
    RaporVeriEkle "pagefile_optimize" "Tamamlandi"
}

function DonanımSkoruVeOneri {
    Baslik "Donanim Skoru ve Oneri Sistemi" "44"

    Write-Host ""
    Write-Host "  Donanim analiz ediliyor..." -ForegroundColor Cyan
    Write-Host ""

    $toplamPuan = 0
    $maxPuan = 100

    # ── CPU ──
    $cpu = Get-WmiObject Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
    $cpuAd = if ($cpu) { $cpu.Name.Trim() } else { "Bilinmiyor" }
    $cpuCekirdek = if ($cpu) { $cpu.NumberOfCores } else { 0 }
    $cpuThread   = if ($cpu) { $cpu.NumberOfLogicalProcessors } else { 0 }
    $cpuMHz      = if ($cpu) { $cpu.MaxClockSpeed } else { 0 }
    $cpuGHz      = [Math]::Round($cpuMHz / 1000, 1)

    $cpuPuan = 0
    if ($cpuCekirdek -ge 8 -and $cpuMHz -ge 3500) { $cpuPuan = 25 }
    elseif ($cpuCekirdek -ge 6 -and $cpuMHz -ge 3000) { $cpuPuan = 20 }
    elseif ($cpuCekirdek -ge 4 -and $cpuMHz -ge 2500) { $cpuPuan = 15 }
    elseif ($cpuCekirdek -ge 2 -and $cpuMHz -ge 2000) { $cpuPuan = 10 }
    else { $cpuPuan = 5 }
    $toplamPuan += $cpuPuan

    Write-Host "  CPU:" -ForegroundColor Yellow
    Durum "    Model"       $cpuAd
    Durum "    Cekirdek"    ($cpuCekirdek.ToString() + "C / " + $cpuThread.ToString() + "T")
    Durum "    Hiz"         ($cpuGHz.ToString() + " GHz")
    Durum "    Puan"        ($cpuPuan.ToString() + " / 25") $(if ($cpuPuan -ge 20) {"Green"} elseif ($cpuPuan -ge 15) {"Yellow"} else {"Red"})

    # ── RAM ──
    $os = Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue
    $ramGB = if ($os) { [Math]::Round($os.TotalVisibleMemorySize / 1048576, 1) } else { 0 }

    $ramPuan = 0
    if     ($ramGB -ge 32) { $ramPuan = 25 }
    elseif ($ramGB -ge 16) { $ramPuan = 20 }
    elseif ($ramGB -ge 8)  { $ramPuan = 15 }
    elseif ($ramGB -ge 4)  { $ramPuan = 8 }
    else                   { $ramPuan = 3 }
    $toplamPuan += $ramPuan

    Write-Host ""
    Write-Host "  RAM:" -ForegroundColor Yellow
    Durum "    Toplam"    ($ramGB.ToString() + " GB")
    Durum "    Puan"      ($ramPuan.ToString() + " / 25") $(if ($ramPuan -ge 20) {"Green"} elseif ($ramPuan -ge 15) {"Yellow"} else {"Red"})

    # ── GPU ──
    $gpu = Get-WmiObject Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1
    $gpuAd = if ($gpu) { $gpu.Name } else { "Bilinmiyor" }
    $gpuVRAM = if ($gpu -and $gpu.AdapterRAM -gt 0) { [int]($gpu.AdapterRAM / 1MB) } else { 0 }
    $gpuVRAMGB = [Math]::Round($gpuVRAM / 1024, 1)

    $gpuPuan = 0
    if ($gpuVRAM -ge 8192)   { $gpuPuan = 25 }
    elseif ($gpuVRAM -ge 4096) { $gpuPuan = 20 }
    elseif ($gpuVRAM -ge 2048) { $gpuPuan = 15 }
    elseif ($gpuVRAM -ge 1024) { $gpuPuan = 8 }
    else {
        # Entegre GPU kontrolu
        if ($gpuAd -match "Intel|UHD|HD Graphics|Vega") { $gpuPuan = 5 }
        else { $gpuPuan = 3 }
    }
    $toplamPuan += $gpuPuan

    Write-Host ""
    Write-Host "  GPU:" -ForegroundColor Yellow
    Durum "    Model"     $gpuAd
    Durum "    VRAM"      $(if ($gpuVRAM -gt 0) {$gpuVRAMGB.ToString() + " GB"} else {"Entegre / Bilinmiyor"})
    Durum "    Puan"      ($gpuPuan.ToString() + " / 25") $(if ($gpuPuan -ge 20) {"Green"} elseif ($gpuPuan -ge 15) {"Yellow"} else {"Red"})

    # ── DISK ──
    $ssdMi = $false
    $diskBoyutGB = 0
    try {
        $fizikDisk = Get-PhysicalDisk -ErrorAction SilentlyContinue | Where-Object { $_.DeviceID -eq "0" } | Select-Object -First 1
        if ($fizikDisk) {
            $ssdMi = ($fizikDisk.MediaType -eq "SSD")
            $diskBoyutGB = [int]($fizikDisk.Size / 1GB)
        }
    } catch {}

    $diskPuan = 0
    if ($ssdMi) {
        if ($diskBoyutGB -ge 512) { $diskPuan = 25 } else { $diskPuan = 20 }
    } else {
        if ($diskBoyutGB -ge 1000) { $diskPuan = 12 } else { $diskPuan = 8 }
    }
    $toplamPuan += $diskPuan

    Write-Host ""
    Write-Host "  Disk:" -ForegroundColor Yellow
    Durum "    Tip"       $(if ($ssdMi) {"SSD"} else {"HDD"})
    Durum "    Boyut"     ($diskBoyutGB.ToString() + " GB")
    Durum "    Puan"      ($diskPuan.ToString() + " / 25") $(if ($diskPuan -ge 20) {"Green"} elseif ($diskPuan -ge 15) {"Yellow"} else {"Red"})

    # ── SINIFLANDIRMA ──
    $sinif = "BILINMIYOR"
    $sinifRenk = "White"
    if     ($toplamPuan -ge 85) { $sinif = "YUKSEK PERFORMANS"; $sinifRenk = "Green" }
    elseif ($toplamPuan -ge 65) { $sinif = "ORTA SEVIYE";       $sinifRenk = "Cyan" }
    elseif ($toplamPuan -ge 45) { $sinif = "DUSUK-ORTA";        $sinifRenk = "Yellow" }
    else                        { $sinif = "DUSUK DONANIM";     $sinifRenk = "Red" }

    Write-Host ""
    Write-Host ("  " + ("=" * 56)) -ForegroundColor $sinifRenk
    Write-Host ("  DONANIM SKORU: " + $toplamPuan + " / " + $maxPuan + "  [" + $sinif + "]") -ForegroundColor $sinifRenk
    Write-Host ("  " + ("=" * 56)) -ForegroundColor $sinifRenk

    # ── ONERILER ──
    Write-Host ""
    Write-Host "  ONERILER:" -ForegroundColor Cyan
    Write-Host ""

    $oneriler = @()

    if ($toplamPuan -lt 45) {
        Write-Host "  >> DUSUK DONANIM TESPIT EDILDI" -ForegroundColor Red
        Write-Host "     Asagidaki modulleri MUTLAKA calistirin:" -ForegroundColor Red
        Write-Host ""
        $oneriler += @{No="41"; Ad="Format Sonrasi Sihirbaz"; Sebep="Tek tikla tum optimizasyonlar"}
        $oneriler += @{No="42"; Ad="Windows Performans Tweaks"; Sebep="Animasyon/efekt kapat = +15 FPS"}
        $oneriler += @{No="43"; Ad="Sanal Bellek Optimize"; Sebep=$ramGB.ToString() + " GB RAM icin kritik"}
        $oneriler += @{No="26"; Ad="FPS Optimizasyonu"; Sebep="GameDVR/MMCSS/Nagle = +10-25 FPS"}
        $oneriler += @{No="27"; Ad="RAM Optimizasyonu"; Sebep="Bellek bosalt = daha az kasma"}
        $oneriler += @{No="28"; Ad="Surec Temizleyici"; Sebep="Arka plan uygulamalari kapat"}
        $oneriler += @{No="29"; Ad="Bloatware Kaldir"; Sebep="Gereksiz uygulamalari sil"}
        $oneriler += @{No="32"; Ad="Disk Optimize"; Sebep=$(if ($ssdMi) {"SSD TRIM"} else {"HDD Defrag = disk hizi"})}
    }
    elseif ($toplamPuan -lt 65) {
        Write-Host "  >> DUSUK-ORTA DONANIM" -ForegroundColor Yellow
        Write-Host "     Performans artisi icin:" -ForegroundColor Yellow
        Write-Host ""
        $oneriler += @{No="42"; Ad="Windows Performans Tweaks"; Sebep="Gereksiz efektleri kapat"}
        $oneriler += @{No="26"; Ad="FPS Optimizasyonu"; Sebep="Oyun ayarlarini optimize et"}
        $oneriler += @{No="28"; Ad="Surec Temizleyici"; Sebep="Oyun oncesi arka plan temizle"}
        $oneriler += @{No="43"; Ad="Sanal Bellek Optimize"; Sebep="Pagefile ayarini duzelt"}
        if (-not $ssdMi) { $oneriler += @{No="32"; Ad="Disk Optimize"; Sebep="HDD defrag gerekli"} }
    }
    else {
        Write-Host "  >> ORTA / IYI DONANIM" -ForegroundColor Green
        Write-Host "     Ince ayar icin:" -ForegroundColor Green
        Write-Host ""
        $oneriler += @{No="26"; Ad="FPS Optimizasyonu"; Sebep="Ekstra FPS icin ince ayar"}
        $oneriler += @{No="38"; Ad="Oyun Modu Toggle"; Sebep="Game Mode + DVR ayarla"}
    }

    if ($gpuPuan -le 8) {
        $oneriler += @{No="37"; Ad="DirectX/GPU Tani"; Sebep="GPU surucunu kontrol et"}
        $oneriler += @{No="30"; Ad="Surucu Kontrolu"; Sebep="Guncel driver onemli"}
    }

    foreach ($on in $oneriler) {
        Write-Host ("    [" + $on.No + "]  " + $on.Ad) -ForegroundColor White
        Write-Host ("         " + $on.Sebep) -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "  Bir modulu hemen calistirmak icin numarasini girin (0 = cik): " -ForegroundColor Yellow -NoNewline
    $secim = (Read-Host).Trim()
    if ($secim -match "^\d+$" -and $secim -ne "0") {
        # Ana'daki switch ile ayni modulleri calistir
        switch ($secim) {
            "26" { FpsOyunOptimizasyonu }
            "27" { RamOptimizasyonu }
            "28" { SurecTemizleyici }
            "29" { BloatwareKaldirici }
            "30" { SurucuKontrol }
            "32" { DiskOptimize }
            "37" { DirectXGPUTani }
            "38" { OyunModuYonetici }
            "41" { FormatSonrasiSihirbaz }
            "42" { WindowsPerformansTweaks }
            "43" { SanalBellekOptimize }
            default { Yaz "  Bu modulu ana menudan calistirin." Gray }
        }
    }

    SkorKaydet "DonanımSkoru" $toplamPuan $maxPuan
    RaporVeriEkle "donanim_sinif" $sinif
    RaporVeriEkle "donanim_skor" $toplamPuan
}

function GPUOptimize {
    Baslik "GPU Surucu Optimizasyonu (NVIDIA / AMD)" "45"

    if (-not (YoneticiKontrol)) {
        Yaz "  Bu modul icin Yonetici yetkisi gereklidir!" Red
        return
    }

    # GPU tespit
    $gpuListesi = @(Get-WmiObject Win32_VideoController -ErrorAction SilentlyContinue |
                     Where-Object { $_.Name -and $_.Name -notmatch "Microsoft Basic" })

    if ($gpuListesi.Count -eq 0) {
        Yaz "  GPU tespit edilemedi." Red
        return
    }

    Write-Host ""
    Write-Host "  TESPIT EDILEN GPU'LAR:" -ForegroundColor Cyan
    foreach ($g in $gpuListesi) {
        $vram = if ($g.AdapterRAM -gt 0) { [Math]::Round($g.AdapterRAM / 1GB, 1).ToString() + " GB" } else { "?" }
        Write-Host ("    " + $g.Name + "  [VRAM: " + $vram + "]  Surucu: " + $g.DriverVersion) -ForegroundColor White
    }
    Write-Host ""

    $birincilGPU = $gpuListesi | Select-Object -First 1
    $nvidia = $birincilGPU.Name -match "NVIDIA"
    $amd    = $birincilGPU.Name -match "AMD|Radeon|ATI"
    $intel  = $birincilGPU.Name -match "Intel|UHD|HD Graphics|Iris"

    if ($nvidia) {
        GPUOptimize_NVIDIA
    } elseif ($amd) {
        GPUOptimize_AMD
    } elseif ($intel) {
        Yaz "  Intel entegre GPU tespit edildi." Yellow
        Yaz "  Entegre GPU icin yapilabilecek registry tweakleri sinirlidir." DarkGray
        Yaz "  Intel Graphics Command Center'dan ayar yapmaniz oneriliyor." DarkGray
        Write-Host ""
        Write-Host "  1  >  Intel Graphics ayarlarini ac" -ForegroundColor Gray
        Write-Host "  0  >  Geri" -ForegroundColor Gray
        Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
        $s = Read-Host
        if ($s.Trim() -eq "1") {
            Start-Process "ms-settings:display-advancedgraphics" -ErrorAction SilentlyContinue
        }
    } else {
        Yaz "  GPU markasi taninamadi. Genel ayarlar uygulanabilir." Yellow
    }
}

function GPUOptimize_NVIDIA {
    Write-Host "  ============================================================" -ForegroundColor Green
    Write-Host "  NVIDIA GPU OPTIMIZASYONU" -ForegroundColor Green
    Write-Host "  ============================================================" -ForegroundColor Green
    Write-Host ""

    # --- NVIDIA Servis ve Telemetri ---
    Write-Host "  [A] NVIDIA SERVIS ve TELEMETRI" -ForegroundColor Cyan
    Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray

    $nvServisler = @(
        @{Ad="NvTelemetryContainer";     Aciklama="NVIDIA Telemetri (veri toplama)";        Onerilen="Disabled"}
        @{Ad="NvContainerLocalSystem";   Aciklama="NVIDIA Container (arka plan)";           Onerilen="Manual"}
        @{Ad="NvContainerNetworkService";Aciklama="NVIDIA Network Container";               Onerilen="Manual"}
        @{Ad="NVDisplay.ContainerLocalSystem"; Aciklama="NVIDIA Display Container";         Onerilen="Automatic"}
    )

    foreach ($ns in $nvServisler) {
        $svc = Get-Service -Name $ns.Ad -ErrorAction SilentlyContinue
        if ($svc) {
            $durumRenk = if ($svc.Status -eq "Running") { "Yellow" } else { "Green" }
            $durumStr  = if ($svc.Status -eq "Running") { "CALISIYOR" } else { "DURMUS" }
            Write-Host ("    " + $ns.Ad.PadRight(35) + $durumStr.PadRight(12) + "(" + $ns.Aciklama + ")") -ForegroundColor $durumRenk
        }
    }

    Write-Host ""

    # --- Registry Tweaks ---
    Write-Host "  [B] REGISTRY GPU TWEAKLERI" -ForegroundColor Cyan
    Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray

    $gpuClassYol = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
    $nvGpuYollar = @()
    Get-ChildItem $gpuClassYol -ErrorAction SilentlyContinue | ForEach-Object {
        $desc = (Get-ItemProperty $_.PSPath -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
        if ($desc -match "NVIDIA") { $nvGpuYollar += $_.PSPath }
    }

    $mevcutTweakler = @{}
    if ($nvGpuYollar.Count -gt 0) {
        $yol = $nvGpuYollar[0]
        $mevcutTweakler["PreferSystemMemoryContiguous"] = (Get-ItemProperty $yol -Name "PreferSystemMemoryContiguous" -ErrorAction SilentlyContinue).PreferSystemMemoryContiguous
        $mevcutTweakler["EnableMsHybrid"]               = (Get-ItemProperty $yol -Name "EnableMsHybrid" -ErrorAction SilentlyContinue).EnableMsHybrid
        $mevcutTweakler["RMHdcpKeyglobZero"]            = (Get-ItemProperty $yol -Name "RMHdcpKeyglobZero" -ErrorAction SilentlyContinue).RMHdcpKeyglobZero
    }

    # Shader Cache kontrolu
    $shaderCacheYol = Join-Path $env:LOCALAPPDATA "NVIDIA\DXCache"
    $shaderCacheBoyut = 0
    if (Test-Path $shaderCacheYol) {
        $shaderCacheBoyut = (Get-ChildItem $shaderCacheYol -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    }
    $scBoyutStr = if ($shaderCacheBoyut -gt 0) { [Math]::Round($shaderCacheBoyut / 1MB, 1).ToString() + " MB" } else { "Bos" }

    Write-Host ("    Shader Cache boyutu: " + $scBoyutStr) -ForegroundColor Gray
    Write-Host ""

    # --- NVIDIA Control Panel Rehber ---
    Write-Host "  [C] NVIDIA DENETIM MASASI - ONERILEN AYARLAR" -ForegroundColor Cyan
    Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  3D Ayarlari Yonetimi > Genel Ayarlar:" -ForegroundColor White
    Write-Host ""

    $ayarlar = @(
        @{Ad="Goruntu Keskinlestirme";                 Deger="Keskinlestir: %17, Film Grenini Yoksay: %17"; Renk="Cyan"}
        @{Ad="Arkaplan Uyg. Maks Kare Hizi";           Deger="20 FPS  (oyun minimize = GPU bossa)"; Renk="Yellow"}
        @{Ad="Baglanti optimizasyonu (Threaded Opt)";   Deger="ACIK  (Otomatik degil)"; Renk="Yellow"}
        @{Ad="CUDA GPU'lar";                            Deger="Tumu"; Renk="Green"}
        @{Ad="Doku Suzme - Kalite";                     Deger="Yuksek performans"; Renk="Green"}
        @{Ad="Doku Suzme - Esyonsuz ornek opt.";        Deger="Acik"; Renk="Green"}
        @{Ad="Doku Suzme - Negatif LOD tercihi";        Deger="Izin Ver"; Renk="Green"}
        @{Ad="Doku Suzme - Trilineer opt.";             Deger="Acik"; Renk="Green"}
        @{Ad="Dusey senkronizasyon (V-Sync)";           Deger="KAPALI  (FPS siniri kaldirir)"; Renk="Green"}
        @{Ad="Dusuk Gecikme Orani Modu";                Deger="ULTRA  (input lag minimuma iner)"; Renk="Green"}
        @{Ad="Esyonsuz suzme (Anisotropic)";            Deger="Kapali veya 2x (hafif kalite artisi)"; Renk="Green"}
        @{Ad="Golgelendirici Onbellek Boyutu";          Deger="SINIRSIZ"; Renk="Green"}
        @{Ad="Guc yonetimi modu";                       Deger="MAKSIMUM PERFORMANSI TERCIH ET"; Renk="Green"}
        @{Ad="Kenar Yumusatma (tum AA)";                Deger="KAPALI / YOK"; Renk="Green"}
        @{Ad="Maksimum Kare Hizi";                      Deger="Kapali (sinir yok)"; Renk="Green"}
        @{Ad="OpenGL GDI uyumlulugu";                   Deger="Performansi tercih et"; Renk="Green"}
        @{Ad="Ortam Kapatma (Ambient Occlusion)";       Deger="KAPALI"; Renk="Green"}
        @{Ad="Triple Buffering";                        Deger="KAPALI  (V-Sync kapaliyken gereksiz)"; Renk="Green"}
        @{Ad="Uclu ara bellekleme";                     Deger="KAPALI"; Renk="Green"}
    )

    foreach ($a in $ayarlar) {
        $simge = if ($a.Renk -eq "Green") { "[OK]" } elseif ($a.Renk -eq "Yellow") { "[!!]" } else { "[>>]" }
        Write-Host ("    " + $simge + "  " + $a.Ad.PadRight(42) + $a.Deger) -ForegroundColor $a.Renk
    }

    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ISLEMLER:" -ForegroundColor Cyan
    Write-Host "  [1]  Registry tweakleri uygula (GPU guc + telemetri + shader)" -ForegroundColor Green
    Write-Host "  [2]  NVIDIA Denetim Masasini ac (3D ayarlari elle yap)" -ForegroundColor Cyan
    Write-Host "  [3]  Shader Cache temizle (" + $scBoyutStr + ")" -ForegroundColor Gray
    Write-Host "  [4]  NVIDIA servislerini optimize et (telemetri kapat)" -ForegroundColor Gray
    Write-Host "  [5]  HEPSINI YAP (1+3+4 birden)" -ForegroundColor Yellow
    Write-Host "  [0]  Geri" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
    $sec = (Read-Host).Trim()
    if ($sec -eq "0") { return }

    # --- 1. Registry Tweaks ---
    if ($sec -eq "1" -or $sec -eq "5") {
        Write-Host ""
        Write-Host "  Registry GPU tweakleri uygulanıyor..." -ForegroundColor Cyan

        foreach ($yol in $nvGpuYollar) {
            # NVIDIA P-State limitleme kaldır (GPU tam hız)
            Set-ItemProperty -Path $yol -Name "DisableDynamicPstate"            -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            # Bellek tercihi optimize
            Set-ItemProperty -Path $yol -Name "PreferSystemMemoryContiguous"    -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            # MSHybrid devre disi (laptop icin - dGPU tercih et)
            Set-ItemProperty -Path $yol -Name "EnableMsHybrid"                  -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            # GPU performans modunu zorla
            Set-ItemProperty -Path $yol -Name "PerfLevelSrc"                    -Value 0x2222 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $yol -Name "PowerMizerEnable"                -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $yol -Name "PowerMizerLevel"                 -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $yol -Name "PowerMizerLevelAC"               -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        }

        # NVIDIA global profil ayarlari (performans onceligi)
        $nvGlobalYol = "HKCU:\SOFTWARE\NVIDIA Corporation\Global\NVTweak"
        if (-not (Test-Path $nvGlobalYol)) { New-Item -Path $nvGlobalYol -Force | Out-Null }
        Set-ItemProperty -Path $nvGlobalYol -Name "Gestalt" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        Yaz "    GPU registry tweakleri uygulandi." Green
        Yaz "    - P-State limitleme kaldirildi (GPU tam hiz)" Green
        Yaz "    - Bellek tercihi optimize edildi" Green
        Yaz "    - PowerMizer performans moduna ayarlandi" Green
        Yaz "    - dGPU onceligi ayarlandi (laptop)" Green
    }

    # --- 2. NVIDIA Panel Ac ---
    if ($sec -eq "2") {
        Write-Host ""
        Yaz "  NVIDIA Denetim Masasi aciliyor..." Cyan
        # nvcplui.exe veya control panel
        $nvcpl = "C:\Windows\System32\nvcplui.exe"
        if (Test-Path $nvcpl) {
            Start-Process $nvcpl -ErrorAction SilentlyContinue
        } else {
            Start-Process "control" -ArgumentList "desk.cpl,,3" -ErrorAction SilentlyContinue
        }
        Yaz "  Yukaridaki onerilen ayarlari elle uygulayin." Yellow
    }

    # --- 3. Shader Cache Temizle ---
    if ($sec -eq "3" -or $sec -eq "5") {
        Write-Host ""
        Write-Host "  Shader Cache temizleniyor..." -ForegroundColor Cyan
        $cacheKonumlar = @(
            (Join-Path $env:LOCALAPPDATA "NVIDIA\DXCache"),
            (Join-Path $env:LOCALAPPDATA "NVIDIA\GLCache"),
            (Join-Path $env:LOCALAPPDATA "NVIDIA\OptmusCache"),
            (Join-Path $env:TEMP "NVIDIA Corporation\NV_Cache"),
            "C:\ProgramData\NVIDIA Corporation\NV_Cache"
        )
        $temizlenen = 0
        foreach ($konum in $cacheKonumlar) {
            if (Test-Path $konum) {
                $boyut = (Get-ChildItem $konum -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
                Get-ChildItem $konum -Recurse -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
                if ($boyut -gt 0) {
                    $temizlenen += $boyut
                    Yaz ("    Temizlendi: " + $konum + "  (" + [Math]::Round($boyut / 1MB, 1).ToString() + " MB)") Green
                }
            }
        }
        if ($temizlenen -gt 0) {
            Yaz ("    Toplam " + [Math]::Round($temizlenen / 1MB, 1).ToString() + " MB shader cache temizlendi.") Green
            Yaz "    Not: Oyunlar ilk acilisinda shader yeniden derlenecek (bir kere kasabilir)." DarkGray
        } else {
            Yaz "    Shader cache zaten temiz." Gray
        }
    }

    # --- 4. Servis Optimizasyonu ---
    if ($sec -eq "4" -or $sec -eq "5") {
        Write-Host ""
        Write-Host "  NVIDIA servisleri optimize ediliyor..." -ForegroundColor Cyan
        $kapServisler = @(
            @{Ad="NvTelemetryContainer";      Aciklama="Telemetri (veri toplama)"}
            @{Ad="NvContainerNetworkService";  Aciklama="Network Container (gereksiz)"}
        )
        $manuelServisler = @(
            @{Ad="NvContainerLocalSystem";     Aciklama="Local Container (gerektiginde calisir)"}
        )

        foreach ($ks in $kapServisler) {
            $svc = Get-Service -Name $ks.Ad -ErrorAction SilentlyContinue
            if ($svc) {
                Stop-Service -Name $ks.Ad -Force -ErrorAction SilentlyContinue
                Set-Service -Name $ks.Ad -StartupType Disabled -ErrorAction SilentlyContinue
                Yaz ("    [KAPALI]   " + $ks.Ad + " (" + $ks.Aciklama + ")") Green
            }
        }
        foreach ($ms in $manuelServisler) {
            $svc = Get-Service -Name $ms.Ad -ErrorAction SilentlyContinue
            if ($svc) {
                Set-Service -Name $ms.Ad -StartupType Manual -ErrorAction SilentlyContinue
                Yaz ("    [MANUEL]   " + $ms.Ad + " (" + $ms.Aciklama + ")") Cyan
            }
        }

        # NVIDIA zamanlanmis gorevlerini devre disi birak
        $nvGorevler = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match "NvTm|NvNode|NVIDIA" -and $_.State -ne "Disabled" }
        if ($nvGorevler) {
            foreach ($g in $nvGorevler) {
                Disable-ScheduledTask -TaskName $g.TaskName -ErrorAction SilentlyContinue | Out-Null
                Yaz ("    [KAPATILDI] Gorev: " + $g.TaskName) Green
            }
        }
    }

    Write-Host ""
    Write-Host ("  " + ("=" * 56)) -ForegroundColor Green
    Yaz "  GPU optimizasyonu tamamlandi!" Green
    Yaz "  Not: Bazi degisiklikler yeniden baslatma gerektirir." DarkGray
    Yaz "  NVIDIA Denetim Masasindaki 3D ayarlarini da kontrol edin." DarkGray
    Write-Host ("  " + ("=" * 56)) -ForegroundColor Green
    RaporVeriEkle "gpu_optimize" "NVIDIA optimizasyonu uygulandi"
}

function GPUOptimize_AMD {
    Write-Host "  ============================================================" -ForegroundColor Red
    Write-Host "  AMD / RADEON GPU OPTIMIZASYONU" -ForegroundColor Red
    Write-Host "  ============================================================" -ForegroundColor Red
    Write-Host ""

    # --- Registry Tweaks ---
    Write-Host "  [A] AMD REGISTRY TWEAKLERI" -ForegroundColor Cyan
    Write-Host "  ----------------------------------------------------------------" -ForegroundColor DarkGray

    $gpuClassYol = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}"
    $amdGpuYollar = @()
    Get-ChildItem $gpuClassYol -ErrorAction SilentlyContinue | ForEach-Object {
        $desc = (Get-ItemProperty $_.PSPath -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
        if ($desc -match "AMD|Radeon|ATI") { $amdGpuYollar += $_.PSPath }
    }

    Write-Host ""
    Write-Host "  AMD RADEON AYARLARI - ONERILEN:" -ForegroundColor White
    Write-Host ""

    $amdAyarlar = @(
        @{Ad="Radeon Anti-Lag";              Deger="ACIK  (input lag azaltir)"; Renk="Green"}
        @{Ad="Radeon Boost";                 Deger="ACIK  (hareket halinde FPS artisi)"; Renk="Green"}
        @{Ad="Radeon Image Sharpening";      Deger="ACIK  (%80 keskinlik)"; Renk="Cyan"}
        @{Ad="Dikey Yenileme Bekleme";       Deger="KAPALI (V-Sync off)"; Renk="Green"}
        @{Ad="Doku Filtreleme Kalitesi";     Deger="Performans"; Renk="Green"}
        @{Ad="Yuzey Formati Optimizasyonu";  Deger="ACIK"; Renk="Green"}
        @{Ad="Tessellation Modu";            Deger="Uygulama Ayarlarini Gecersiz Kil > Kapali"; Renk="Green"}
        @{Ad="OpenGL Triple Buffering";      Deger="KAPALI"; Renk="Green"}
        @{Ad="Kare Hizi Hedef Kontrolu";     Deger="KAPALI (sinir yok)"; Renk="Green"}
        @{Ad="GPU Is Yuku";                  Deger="Grafik"; Renk="Green"}
    )

    foreach ($a in $amdAyarlar) {
        Write-Host ("    [>>]  " + $a.Ad.PadRight(38) + $a.Deger) -ForegroundColor $a.Renk
    }

    Write-Host ""
    Write-Host "  ISLEMLER:" -ForegroundColor Cyan
    Write-Host "  [1]  Registry tweakleri uygula (GPU guc + preemption kapat)" -ForegroundColor Green
    Write-Host "  [2]  AMD Radeon Settings ac" -ForegroundColor Cyan
    Write-Host "  [3]  Shader Cache temizle" -ForegroundColor Gray
    Write-Host "  [4]  HEPSINI YAP" -ForegroundColor Yellow
    Write-Host "  [0]  Geri" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
    $sec = (Read-Host).Trim()
    if ($sec -eq "0") { return }

    if ($sec -eq "1" -or $sec -eq "4") {
        Write-Host ""
        Write-Host "  AMD registry tweakleri uygulanıyor..." -ForegroundColor Cyan
        foreach ($yol in $amdGpuYollar) {
            Set-ItemProperty -Path $yol -Name "KMD_EnableComputePreemption" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $yol -Name "PP_GPUPowerDownEnabled"      -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $yol -Name "DisableDMACopy"              -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $yol -Name "DisableBlockWrite"           -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $yol -Name "StutterMode"                 -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $yol -Name "EnableUlps"                  -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
        }
        Yaz "    Compute preemption devre disi" Green
        Yaz "    GPU guc tasarrufu devre disi" Green
        Yaz "    ULPS (Ultra Low Power State) devre disi" Green
        Yaz "    Stutter Mode devre disi" Green
    }

    if ($sec -eq "2") {
        Yaz "  AMD Radeon Settings aciliyor..." Cyan
        Start-Process "AMDRadeonSoftware://AdvancedGraphics" -ErrorAction SilentlyContinue
        if ($LASTEXITCODE -ne 0) {
            Start-Process "C:\Program Files\AMD\CNext\CNext\RadeonSoftware.exe" -ErrorAction SilentlyContinue
        }
    }

    if ($sec -eq "3" -or $sec -eq "4") {
        Write-Host ""
        Write-Host "  AMD Shader Cache temizleniyor..." -ForegroundColor Cyan
        $amdCacheYollar = @(
            (Join-Path $env:LOCALAPPDATA "AMD\DxCache"),
            (Join-Path $env:LOCALAPPDATA "AMD\GLCache"),
            (Join-Path $env:LOCALAPPDATA "AMD\VkCache")
        )
        foreach ($konum in $amdCacheYollar) {
            if (Test-Path $konum) {
                $boyut = (Get-ChildItem $konum -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
                Get-ChildItem $konum -Recurse -File -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
                if ($boyut -gt 0) {
                    Yaz ("    Temizlendi: " + $konum + "  (" + [Math]::Round($boyut / 1MB, 1).ToString() + " MB)") Green
                }
            }
        }
    }

    Write-Host ""
    Yaz "  AMD GPU optimizasyonu tamamlandi!" Green
    Yaz "  AMD Radeon Settings'den onerilen ayarlari kontrol edin." DarkGray
    RaporVeriEkle "gpu_optimize" "AMD optimizasyonu uygulandi"
}

function DefenderOyunIstisna {
    Baslik "Windows Defender Oyun Klasor Istisnalari" "46"

    if (-not (YoneticiKontrol)) {
        Yaz "  Bu modul icin Yonetici yetkisi gereklidir!" Red
        return
    }

    Write-Host ""
    Write-Host "  Windows Defender dosya taramasi oyunlarda FPS dusurur." -ForegroundColor Cyan
    Write-Host "  Oyun klasorlerini istisna listesine ekleyerek bunu onleyebilirsiniz." -ForegroundColor Cyan
    Write-Host ""

    # Mevcut istisnalar
    $mevcutIstisnalar = @()
    try {
        $pref = Get-MpPreference -ErrorAction Stop
        $mevcutIstisnalar = @($pref.ExclusionPath)
    } catch {
        Yaz "  Defender tercihleri okunamadi." Yellow
    }

    if ($mevcutIstisnalar.Count -gt 0) {
        Write-Host "  Mevcut istisna klasorleri:" -ForegroundColor Gray
        $mevcutIstisnalar | ForEach-Object {
            if ($_) { Write-Host ("    + " + $_) -ForegroundColor DarkGray }
        }
        Write-Host ""
    }

    # Populer oyun klasorlerini tara
    $oyunKlasorleri = @()
    $taraYollar = @(
        "C:\Program Files (x86)\Steam\steamapps\common",
        "C:\Program Files\Steam\steamapps\common",
        "D:\Steam\steamapps\common",
        "D:\SteamLibrary\steamapps\common",
        "E:\Steam\steamapps\common",
        "E:\SteamLibrary\steamapps\common",
        "C:\Program Files\Epic Games",
        "C:\Program Files (x86)\Epic Games",
        "D:\Epic Games",
        "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\games",
        "C:\Program Files\Riot Games",
        "C:\Program Files (x86)\Riot Games",
        "C:\Program Files (x86)\Origin Games",
        "C:\Program Files\EA Games",
        "C:\Program Files (x86)\EA Games",
        "C:\Riot Games",
        "D:\Riot Games",
        "C:\Program Files\Rockstar Games",
        "C:\Program Files\Battle.net",
        "C:\Program Files (x86)\Battle.net"
    )

    foreach ($yol in $taraYollar) {
        if (Test-Path $yol) {
            $oyunKlasorleri += $yol
        }
    }

    # Kullanicinin kendi oyun klasorleri
    $userGameYollar = @(
        (Join-Path $env:USERPROFILE "Games"),
        (Join-Path $env:USERPROFILE "Desktop\Games"),
        "D:\Games",
        "E:\Games"
    )
    foreach ($yol in $userGameYollar) {
        if (Test-Path $yol) { $oyunKlasorleri += $yol }
    }

    if ($oyunKlasorleri.Count -gt 0) {
        Write-Host ("  " + $oyunKlasorleri.Count + " oyun klasoru bulundu:") -ForegroundColor Yellow
        Write-Host ""
        $i = 0
        foreach ($k in $oyunKlasorleri) {
            $i++
            $zatenVar = $mevcutIstisnalar -contains $k
            $durum = if ($zatenVar) { " [ZATEN ISTISNA]" } else { "" }
            $renk  = if ($zatenVar) { "DarkGray" } else { "White" }
            Write-Host ("    [{0,2}]  {1}{2}" -f $i, $k, $durum) -ForegroundColor $renk
        }
    } else {
        Yaz "  Bilinen konumlarda oyun klasoru bulunamadi." Yellow
    }

    Write-Host ""
    Write-Host "  [T]  Tum bulunan klasorleri istisna olarak ekle" -ForegroundColor Green
    Write-Host "  [M]  Manuel klasor yolu gir" -ForegroundColor Gray
    Write-Host "  [S]  Istisnalari temizle (tum ozel istisnalar kaldir)" -ForegroundColor Red
    Write-Host "  [0]  Geri" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
    $sec = (Read-Host).Trim()

    switch ($sec) {
        "T" {
            $eklenen = 0
            foreach ($k in $oyunKlasorleri) {
                if ($mevcutIstisnalar -notcontains $k) {
                    try {
                        Add-MpPreference -ExclusionPath $k -ErrorAction Stop
                        Yaz ("    [+]  " + $k) Green
                        $eklenen++
                    } catch {
                        Yaz ("    [!]  " + $k + "  (eklenemedi)") Yellow
                    }
                }
            }
            if ($eklenen -gt 0) { Yaz ("  " + $eklenen + " klasor istisna listesine eklendi.") Green }
            else { Yaz "  Tum klasorler zaten istisna listesinde." Gray }
        }
        "M" {
            Write-Host "  Klasor yolu girin: " -ForegroundColor Yellow -NoNewline
            $yol = (Read-Host).Trim()
            if (Test-Path $yol) {
                try {
                    Add-MpPreference -ExclusionPath $yol -ErrorAction Stop
                    Yaz ("  [+]  " + $yol + " eklendi.") Green
                } catch { Yaz "  Eklenemedi." Red }
            } else { Yaz "  Klasor bulunamadi." Red }
        }
        "S" {
            if (Onay "Tum ozel istisna yollari kaldirilsin mi?") {
                foreach ($p in $mevcutIstisnalar) {
                    if ($p) { Remove-MpPreference -ExclusionPath $p -ErrorAction SilentlyContinue }
                }
                Yaz "  Tum istisnalar kaldirildi." Green
            }
        }
    }
    RaporVeriEkle "defender_istisna" "Guncellendi"
}

function MonitorOptimize {
    Baslik "Monitor Yenileme Hizi ve Cozunurluk" "47"

    Write-Host ""
    Write-Host "  Bagli Monitorler:" -ForegroundColor Cyan
    Write-Host ""

    $monitorSayac = 0
    Get-WmiObject Win32_VideoController -ErrorAction SilentlyContinue | ForEach-Object {
        $monitorSayac++
        $coz   = if ($_.CurrentHorizontalResolution) { $_.CurrentHorizontalResolution.ToString() + "x" + $_.CurrentVerticalResolution.ToString() } else { "?" }
        $hz    = if ($_.CurrentRefreshRate) { $_.CurrentRefreshRate.ToString() + " Hz" } else { "?" }
        $hzVal = $_.CurrentRefreshRate

        $hzRenk = if ($hzVal -ge 144) { "Green" } elseif ($hzVal -ge 75) { "Yellow" } else { "Red" }

        Write-Host ("  Monitor " + $monitorSayac + ":") -ForegroundColor Yellow
        Write-Host ("    GPU         : " + $_.Name) -ForegroundColor Gray
        Write-Host ("    Cozunurluk  : " + $coz) -ForegroundColor White
        Write-Host ("    Yenileme Hz : " + $hz) -ForegroundColor $hzRenk

        if ($hzVal -lt 60) {
            Yaz "    UYARI: 60 Hz altinda! Monitor ayarlarinizi kontrol edin." Red
        } elseif ($hzVal -eq 60 -and $_.CurrentHorizontalResolution -ge 1920) {
            Yaz "    IPUCU: Monitorunuz daha yuksek Hz destekleyebilir. Ekran ayarlarindan kontrol edin." Yellow
        }
        Write-Host ""
    }

    # Windows ekran olceklendirme bilgisi
    $olcekYol = "HKCU:\Control Panel\Desktop\WindowMetrics"
    $dpi = (Get-ItemProperty $olcekYol -ErrorAction SilentlyContinue).AppliedDPI
    if ($dpi) {
        $olcekYuzde = [int]($dpi / 96 * 100)
        Write-Host ("  Ekran Olceklendirme: %" + $olcekYuzde) -ForegroundColor $(if ($olcekYuzde -gt 100) {"Yellow"} else {"Green"})
        if ($olcekYuzde -gt 100) {
            Yaz "  IPUCU: Oyunlarda %100 olcek kullanin, daha fazla FPS alirsiniz." Yellow
        }
    }

    Write-Host ""
    Write-Host "  1  >  Ekran Ayarlari'ni ac (Hz degistir)" -ForegroundColor Gray
    Write-Host "  2  >  Gelismis Ekran Ayarlari'ni ac" -ForegroundColor Gray
    Write-Host "  3  >  Ekran olceklendirmeyi %100'e ayarla (oyun icin)" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $s = Read-Host
    switch ($s.Trim()) {
        "1" { Start-Process "ms-settings:display" -ErrorAction SilentlyContinue }
        "2" { Start-Process "ms-settings:display-advancedgraphics" -ErrorAction SilentlyContinue }
        "3" {
            # DPI %100 (96 DPI)
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "LogPixels" -Value 96 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Win8DpiScaling" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            Yaz "  Olceklendirme %100 ayarlandi. Oturum kapatip acinca aktif olur." Green
        }
    }
    RaporVeriEkle "monitor_hz" $(if ($monitorSayac -gt 0) { "Kontrol edildi" } else { "Monitor bulunamadi" })
}

#endregion

#region ── MODUL 48: HYPER-V / VBS KAPAT ─────────────────────

function HyperVVBSKapat {
    Baslik "Hyper-V / VBS / HVCI Kapat (Oyun Performansi)" "48"

    Write-Host ""
    Write-Host "  Bu modul, Windows sanallastirma katmanlarini devre disi birakir." -ForegroundColor Cyan
    Write-Host "  Hyper-V ve VBS, oyunlarda %5-15 FPS kaybi yaratir cunku:" -ForegroundColor Cyan
    Write-Host "    - GPU ve CPU kaynaklari sanallastirma katmaninda tuketilir" -ForegroundColor Gray
    Write-Host "    - Bellek erisimi sanal katmandan gecer (ekstra latency)" -ForegroundColor Gray
    Write-Host "    - Bazi anti-cheat sistemleri VBS ile cakisir" -ForegroundColor Gray
    Write-Host ""

    # ── Mevcut durum tespiti ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  MEVCUT DURUM" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    # 1) Hyper-V durumu
    $hyperVDurum = "Bilinmiyor"
    $hyperVRenk  = "Gray"
    try {
        $hvFeature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -ErrorAction SilentlyContinue
        if ($hvFeature -and $hvFeature.State -eq "Enabled") {
            $hyperVDurum = "AKTIF (Feature Yuklu)"
            $hyperVRenk  = "Red"
        } elseif ($hvFeature -and $hvFeature.State -eq "Disabled") {
            $hyperVDurum = "KAPALI"
            $hyperVRenk  = "Green"
        } else {
            # Feature yoksa (Home edition vb.)
            $hyperVDurum = "Yuklu Degil"
            $hyperVRenk  = "Green"
        }
    } catch {
        $hyperVDurum = "Kontrol edilemedi"
        $hyperVRenk  = "DarkGray"
    }

    # bcdedit hypervisorlaunchtype kontrolu
    $hvLaunch = "Bilinmiyor"
    $hvLaunchRenk = "Gray"
    try {
        $bcdOut = & bcdedit /enum "{current}" 2>$null | Out-String
        if ($bcdOut -match "hypervisorlaunchtype\s+(\w+)") {
            $hvType = $Matches[1].ToLower()
            if ($hvType -eq "auto") {
                $hvLaunch = "AUTO (Aktif)"
                $hvLaunchRenk = "Red"
            } elseif ($hvType -eq "off") {
                $hvLaunch = "OFF (Kapali)"
                $hvLaunchRenk = "Green"
            } else {
                $hvLaunch = $hvType.ToUpper()
                $hvLaunchRenk = "Yellow"
            }
        } else {
            $hvLaunch = "Ayar yok (varsayilan)"
            $hvLaunchRenk = "Yellow"
        }
    } catch {
        $hvLaunch = "Okunamadi"
    }

    # 2) VBS (Virtualization Based Security)
    $vbsDurum = "Bilinmiyor"
    $vbsRenk  = "Gray"
    try {
        $dgPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
        $dgVal  = Get-ItemProperty -Path $dgPath -Name "EnableVirtualizationBasedSecurity" -ErrorAction SilentlyContinue
        if ($dgVal -and $dgVal.EnableVirtualizationBasedSecurity -eq 1) {
            $vbsDurum = "AKTIF (Registry)"
            $vbsRenk  = "Red"
        } elseif ($dgVal -and $dgVal.EnableVirtualizationBasedSecurity -eq 0) {
            $vbsDurum = "KAPALI (Registry)"
            $vbsRenk  = "Green"
        } else {
            $vbsDurum = "Ayar yok (varsayilan)"
            $vbsRenk  = "Yellow"
        }
    } catch {}

    # WMI ile gercek calisma durumu
    $vbsCalisma = "Bilinmiyor"
    $vbsCalismaRenk = "Gray"
    try {
        $dg = Get-CimInstance -ClassName Win32_DeviceGuard -Namespace "root\Microsoft\Windows\DeviceGuard" -ErrorAction SilentlyContinue
        if ($dg) {
            $vbsStatus = $dg.VirtualizationBasedSecurityStatus
            if ($vbsStatus -eq 2) {
                $vbsCalisma = "CALISIYOR"
                $vbsCalismaRenk = "Red"
            } elseif ($vbsStatus -eq 1) {
                $vbsCalisma = "AKTIF ama calismiyor"
                $vbsCalismaRenk = "Yellow"
            } else {
                $vbsCalisma = "CALISMIYOR"
                $vbsCalismaRenk = "Green"
            }
        }
    } catch {}

    # 3) HVCI (Memory Integrity / Hypervisor-enforced Code Integrity)
    $hvciDurum = "Bilinmiyor"
    $hvciRenk  = "Gray"
    try {
        $hvciPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
        $hvciVal  = Get-ItemProperty -Path $hvciPath -Name "Enabled" -ErrorAction SilentlyContinue
        if ($hvciVal -and $hvciVal.Enabled -eq 1) {
            $hvciDurum = "AKTIF"
            $hvciRenk  = "Red"
        } elseif ($hvciVal -and $hvciVal.Enabled -eq 0) {
            $hvciDurum = "KAPALI"
            $hvciRenk  = "Green"
        } else {
            $hvciDurum = "Ayar yok"
            $hvciRenk  = "Yellow"
        }
    } catch {}

    # Windows Security - Memory Integrity (WDAC policy path)
    try {
        $memIntPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
        if (-not (Test-Path $memIntPath)) {
            $hvciDurum = "Anahtar yok (muhtemelen kapali)"
            $hvciRenk  = "Green"
        }
    } catch {}

    # 4) Credential Guard
    $credGuardDurum = "Bilinmiyor"
    $credGuardRenk  = "Gray"
    try {
        $cgPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard"
        if (Test-Path $cgPath) {
            $cgVal = Get-ItemProperty -Path $cgPath -Name "Enabled" -ErrorAction SilentlyContinue
            if ($cgVal -and $cgVal.Enabled -eq 1) {
                $credGuardDurum = "AKTIF"
                $credGuardRenk  = "Red"
            } elseif ($cgVal -and $cgVal.Enabled -eq 0) {
                $credGuardDurum = "KAPALI"
                $credGuardRenk  = "Green"
            } else {
                $credGuardDurum = "Ayar yok"
                $credGuardRenk  = "Yellow"
            }
        } else {
            $credGuardDurum = "Yapilandirilmamis"
            $credGuardRenk  = "Green"
        }
    } catch {}

    # Durum tablosu goster
    Write-Host ("  {0,-30} {1}" -f "Hyper-V Feature:", $hyperVDurum) -ForegroundColor $hyperVRenk
    Write-Host ("  {0,-30} {1}" -f "Hypervisor Launch:", $hvLaunch) -ForegroundColor $hvLaunchRenk
    Write-Host ("  {0,-30} {1}" -f "VBS (Registry):", $vbsDurum) -ForegroundColor $vbsRenk
    Write-Host ("  {0,-30} {1}" -f "VBS (Gercek Durum):", $vbsCalisma) -ForegroundColor $vbsCalismaRenk
    Write-Host ("  {0,-30} {1}" -f "HVCI (Memory Integrity):", $hvciDurum) -ForegroundColor $hvciRenk
    Write-Host ("  {0,-30} {1}" -f "Credential Guard:", $credGuardDurum) -ForegroundColor $credGuardRenk
    Write-Host ""

    # Aktif olanlari say
    $aktifSayisi = 0
    if ($hyperVRenk -eq "Red") { $aktifSayisi++ }
    if ($hvLaunchRenk -eq "Red") { $aktifSayisi++ }
    if ($vbsRenk -eq "Red" -or $vbsCalismaRenk -eq "Red") { $aktifSayisi++ }
    if ($hvciRenk -eq "Red") { $aktifSayisi++ }
    if ($credGuardRenk -eq "Red") { $aktifSayisi++ }

    if ($aktifSayisi -eq 0) {
        Yaz "  Tum sanallastirma katmanlari zaten kapali. Ekstra bir islem gerekmez!" Green
        Write-Host ""
    } else {
        Yaz ("  " + $aktifSayisi.ToString() + " adet aktif sanallastirma ozelligi tespit edildi.") Yellow
        Yaz "  Bunlari kapatarak oyunlarda %5-15 FPS kazanimi saglayabilirsiniz." Yellow
        Write-Host ""
    }

    # ── Menu ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  ISLEMLER" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  1  >  TUMU KAPAT (Hyper-V + VBS + HVCI + Credential Guard)" -ForegroundColor Cyan
    Write-Host "  2  >  Sadece VBS + HVCI Kapat (Hyper-V'ye dokunma)" -ForegroundColor Gray
    Write-Host "  3  >  TUMU AC (geri yukle)" -ForegroundColor Gray
    Write-Host "  4  >  Detayli bilgi goster" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $secim = Read-Host

    switch ($secim.Trim()) {
        "1" {
            Write-Host ""
            Yaz "  Tum sanallastirma katmanlari kapatiliyor..." Yellow
            Write-Host ""

            $degisiklik = 0

            # 1) Hyper-V Feature kapat
            try {
                $hvf = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -ErrorAction SilentlyContinue
                if ($hvf -and $hvf.State -eq "Enabled") {
                    Yaz "  [1/6] Hyper-V Feature devre disi birakiliyor..." Yellow
                    Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -ErrorAction SilentlyContinue | Out-Null
                    Yaz "  [1/6] Hyper-V Feature kapatildi." Green
                    $degisiklik++
                } else {
                    Yaz "  [1/6] Hyper-V Feature zaten kapali veya yuklu degil." DarkGray
                }
            } catch {
                Yaz "  [1/6] Hyper-V Feature kapatilamadi (Home edition olabilir)." DarkGray
            }

            # 2) Hypervisor launch type off
            try {
                Yaz "  [2/6] Hypervisor launch type kapatiliyor..." Yellow
                & bcdedit /set hypervisorlaunchtype off 2>$null | Out-Null
                Yaz "  [2/6] Hypervisor launch = OFF." Green
                $degisiklik++
            } catch {
                Yaz "  [2/6] bcdedit hatasi." Red
            }

            # 3) VBS kapat
            $dgPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
            if (-not (Test-Path $dgPath)) { New-Item -Path $dgPath -Force | Out-Null }
            Set-ItemProperty -Path $dgPath -Name "EnableVirtualizationBasedSecurity" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $dgPath -Name "RequirePlatformSecurityFeatures" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Yaz "  [3/6] VBS (Virtualization Based Security) kapatildi." Green
            $degisiklik++

            # 4) HVCI kapat (Memory Integrity)
            $hvciPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
            if (-not (Test-Path $hvciPath)) { New-Item -Path $hvciPath -Force | Out-Null }
            Set-ItemProperty -Path $hvciPath -Name "Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Yaz "  [4/6] HVCI (Memory Integrity) kapatildi." Green
            $degisiklik++

            # 5) Credential Guard kapat
            $cgPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\CredentialGuard"
            if (Test-Path $cgPath) {
                Set-ItemProperty -Path $cgPath -Name "Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                Yaz "  [5/6] Credential Guard kapatildi." Green
                $degisiklik++
            } else {
                Yaz "  [5/6] Credential Guard zaten yapilandirilmamis." DarkGray
            }

            # 6) UEFI lock kaldır (varsa)
            try {
                $lockPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
                $lockVal = Get-ItemProperty -Path $lockPath -Name "Locked" -ErrorAction SilentlyContinue
                if ($lockVal -and $lockVal.Locked -eq 1) {
                    Set-ItemProperty -Path $lockPath -Name "Locked" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                    Yaz "  [6/6] UEFI kilidi kaldirildi." Green
                    $degisiklik++
                } else {
                    Yaz "  [6/6] UEFI kilidi zaten yok." DarkGray
                }
            } catch {
                Yaz "  [6/6] UEFI kilidi kontrol edilemedi." DarkGray
            }

            Write-Host ""
            Yaz ("  Toplam " + $degisiklik.ToString() + " degisiklik uygulandi.") Green
            Write-Host ""
            Yaz "  ONEMLI: Degisikliklerin aktif olmasi icin bilgisayari" Yellow
            Yaz "  yeniden baslatmaniz gerekiyor!" Yellow
            Write-Host ""
            Write-Host "  Simdi yeniden baslatmak ister misiniz? (E/H): " -ForegroundColor Cyan -NoNewline
            $restart = Read-Host
            if ($restart.Trim().ToUpper() -eq "E") {
                Yaz "  10 saniye icinde yeniden baslatiliyor..." Red
                shutdown /r /t 10 /c "SistemBakim: Hyper-V/VBS kapatildi, yeniden baslatiliyor"
            }

            Add-Content $LOG_DOSYA "  Hyper-V/VBS/HVCI kapatildi ($degisiklik degisiklik)"
        }

        "2" {
            Write-Host ""
            Yaz "  VBS ve HVCI kapatiliyor (Hyper-V'ye dokunulmuyor)..." Yellow
            Write-Host ""

            # VBS kapat
            $dgPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
            if (-not (Test-Path $dgPath)) { New-Item -Path $dgPath -Force | Out-Null }
            Set-ItemProperty -Path $dgPath -Name "EnableVirtualizationBasedSecurity" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $dgPath -Name "RequirePlatformSecurityFeatures" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Yaz "  VBS kapatildi." Green

            # HVCI kapat
            $hvciPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
            if (-not (Test-Path $hvciPath)) { New-Item -Path $hvciPath -Force | Out-Null }
            Set-ItemProperty -Path $hvciPath -Name "Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
            Yaz "  HVCI (Memory Integrity) kapatildi." Green

            Write-Host ""
            Yaz "  ONEMLI: Yeniden baslatma gerekli!" Yellow
            Write-Host "  Simdi yeniden baslatmak ister misiniz? (E/H): " -ForegroundColor Cyan -NoNewline
            $restart = Read-Host
            if ($restart.Trim().ToUpper() -eq "E") {
                shutdown /r /t 10 /c "SistemBakim: VBS/HVCI kapatildi"
            }

            Add-Content $LOG_DOSYA "  VBS + HVCI kapatildi (Hyper-V dokunulmadi)"
        }

        "3" {
            Write-Host ""
            Yaz "  Tum sanallastirma katmanlari geri yukleniyor..." Yellow
            Write-Host ""

            # Hyper-V ac
            try {
                $hvf = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -ErrorAction SilentlyContinue
                if ($hvf -and $hvf.State -eq "Disabled") {
                    Yaz "  Hyper-V Feature etkinlestiriliyor..." Yellow
                    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -ErrorAction SilentlyContinue | Out-Null
                    Yaz "  Hyper-V Feature etkinlestirildi." Green
                } else {
                    Yaz "  Hyper-V zaten aktif veya bu surumde yok." DarkGray
                }
            } catch {
                Yaz "  Hyper-V etkinlestirilemedi." DarkGray
            }

            # Hypervisor launch auto
            & bcdedit /set hypervisorlaunchtype auto 2>$null | Out-Null
            Yaz "  Hypervisor launch = AUTO." Green

            # VBS ac
            $dgPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
            if (-not (Test-Path $dgPath)) { New-Item -Path $dgPath -Force | Out-Null }
            Set-ItemProperty -Path $dgPath -Name "EnableVirtualizationBasedSecurity" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            Yaz "  VBS etkinlestirildi." Green

            # HVCI ac
            $hvciPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
            if (-not (Test-Path $hvciPath)) { New-Item -Path $hvciPath -Force | Out-Null }
            Set-ItemProperty -Path $hvciPath -Name "Enabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            Yaz "  HVCI (Memory Integrity) etkinlestirildi." Green

            Write-Host ""
            Yaz "  Geri yukleme tamamlandi. Yeniden baslatma gerekli!" Yellow
            Write-Host "  Simdi yeniden baslatmak ister misiniz? (E/H): " -ForegroundColor Cyan -NoNewline
            $restart = Read-Host
            if ($restart.Trim().ToUpper() -eq "E") {
                shutdown /r /t 10 /c "SistemBakim: VBS/HVCI etkinlestirildi"
            }

            Add-Content $LOG_DOSYA "  Hyper-V/VBS/HVCI geri yuklendi"
        }

        "4" {
            Write-Host ""
            Write-Host "  ================================================" -ForegroundColor DarkCyan
            Write-Host "  DETAYLI BILGI: Sanallastirma ve Oyun Performansi" -ForegroundColor Yellow
            Write-Host "  ================================================" -ForegroundColor DarkCyan
            Write-Host ""
            Write-Host "  HYPER-V:" -ForegroundColor Cyan
            Write-Host "    Windows'un yerlesik sanal makine platformudur." -ForegroundColor Gray
            Write-Host "    WSL2, Docker, Android subsystem gibi araclar kullanir." -ForegroundColor Gray
            Write-Host "    Oyunlarda dogrudan performans kaybina neden olur." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  VBS (Virtualization Based Security):" -ForegroundColor Cyan
            Write-Host "    Windows 11'de varsayilan olarak acik gelir." -ForegroundColor Gray
            Write-Host "    Guvenlik amacli sanal ortam olusturur." -ForegroundColor Gray
            Write-Host "    Her bellek erisimi ekstra katmandan gecer = latency artisi." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  HVCI (Memory Integrity):" -ForegroundColor Cyan
            Write-Host "    Cekirdek modu kod butunlugunu sanal ortamda dogrular." -ForegroundColor Gray
            Write-Host "    Bazi eski suruculerle uyumsuzluk yaratabilir." -ForegroundColor Gray
            Write-Host "    Windows Guvenlik > Cihaz Guvenligi > Cekirdek yalitimi" -ForegroundColor Gray
            Write-Host "    altinda 'Bellek butunlugu' olarak gorulur." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  CREDENTIAL GUARD:" -ForegroundColor Cyan
            Write-Host "    Kimlik bilgilerini sanal ortamda korur." -ForegroundColor Gray
            Write-Host "    Genellikle Enterprise/Pro surumlerinde bulunur." -ForegroundColor Gray
            Write-Host ""
            Write-Host "  PERFORMANS ETKISI:" -ForegroundColor Yellow
            Write-Host "    - Dusuk GPU: %3-8 FPS kaybi" -ForegroundColor Gray
            Write-Host "    - Orta GPU:  %5-12 FPS kaybi" -ForegroundColor Gray
            Write-Host "    - Yuksek GPU: %2-5 FPS kaybi (CPU darbogazinda daha fazla)" -ForegroundColor Gray
            Write-Host "    - CPU-bagli oyunlarda (Valorant, CS2): %10-15 kayip" -ForegroundColor Gray
            Write-Host ""
            Write-Host "  UYARI:" -ForegroundColor Red
            Write-Host "    - WSL2 kullaniyorsaniz Hyper-V'yi kapatmayin" -ForegroundColor Gray
            Write-Host "    - Docker Desktop Hyper-V gerektirir" -ForegroundColor Gray
            Write-Host "    - Android Subsystem (WSA) Hyper-V gerektirir" -ForegroundColor Gray
            Write-Host "    - Sadece VBS/HVCI kapatmak genellikle yeterlidir" -ForegroundColor Gray
            Write-Host ""
            Write-Host "  [Devam icin bir tusa basin...]" -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }

    RaporVeriEkle "hyperv_vbs" @{
        HyperV=$hyperVDurum; HVLaunch=$hvLaunch; VBS=$vbsDurum
        VBSCalisma=$vbsCalisma; HVCI=$hvciDurum; CredGuard=$credGuardDurum
    }
}

#endregion

#region ── MODUL 49: TARAYICI TEMIZLEYICI ────────────────────

function TarayiciTemizleyici {
    Baslik "Tarayici Temizleyici (Chrome/Edge/Firefox/Opera/Brave)" "49"

    Write-Host ""
    Write-Host "  Tarayici cache, gecmis, cerez ve oturum verilerini temizler." -ForegroundColor Cyan
    Write-Host "  Gigabyte'larca gereksiz veri birikmis olabilir!" -ForegroundColor Cyan
    Write-Host ""

    # ── Tarayici profil yollari tanimla ──
    $localApp  = $env:LOCALAPPDATA
    $roamApp   = $env:APPDATA

    $tarayicilar = @(
        @{
            Ad       = "Google Chrome"
            Kisa     = "Chrome"
            ProfilYol = "$localApp\Google\Chrome\User Data"
            Profiller = @("Default","Profile 1","Profile 2","Profile 3","Profile 4","Profile 5")
            Klasorler = @(
                @{ Ad="Cache";        Yol="Cache\Cache_Data";       Tip="Cache" },
                @{ Ad="Code Cache";   Yol="Code Cache";             Tip="Cache" },
                @{ Ad="GPUCache";     Yol="GPUCache";               Tip="Cache" },
                @{ Ad="Service Worker"; Yol="Service Worker\CacheStorage"; Tip="Cache" },
                @{ Ad="Gecmis";       Yol="History";                Tip="Gecmis" },
                @{ Ad="Cerezler";     Yol="Cookies";                Tip="Cerez" },
                @{ Ad="Oturum";       Yol="Sessions";               Tip="Oturum" },
                @{ Ad="Favicons";     Yol="Favicons";               Tip="Diger" },
                @{ Ad="Top Sites";    Yol="Top Sites";              Tip="Diger" },
                @{ Ad="Visited Links"; Yol="Visited Links";         Tip="Gecmis" }
            )
        },
        @{
            Ad       = "Microsoft Edge"
            Kisa     = "Edge"
            ProfilYol = "$localApp\Microsoft\Edge\User Data"
            Profiller = @("Default","Profile 1","Profile 2","Profile 3")
            Klasorler = @(
                @{ Ad="Cache";        Yol="Cache\Cache_Data";       Tip="Cache" },
                @{ Ad="Code Cache";   Yol="Code Cache";             Tip="Cache" },
                @{ Ad="GPUCache";     Yol="GPUCache";               Tip="Cache" },
                @{ Ad="Service Worker"; Yol="Service Worker\CacheStorage"; Tip="Cache" },
                @{ Ad="Gecmis";       Yol="History";                Tip="Gecmis" },
                @{ Ad="Cerezler";     Yol="Cookies";                Tip="Cerez" },
                @{ Ad="Oturum";       Yol="Sessions";               Tip="Oturum" }
            )
        },
        @{
            Ad       = "Mozilla Firefox"
            Kisa     = "Firefox"
            ProfilYol = "$roamApp\Mozilla\Firefox\Profiles"
            Profiller = @()  # Firefox profil adlari dinamik (xxxxxxxx.default-release)
            Klasorler = @(
                @{ Ad="Cache2";       Yol="cache2\entries";          Tip="Cache" },
                @{ Ad="StartupCache"; Yol="startupCache";            Tip="Cache" },
                @{ Ad="OfflineCache"; Yol="OfflineCache";            Tip="Cache" },
                @{ Ad="Gecmis";       Yol="places.sqlite";           Tip="Gecmis" },
                @{ Ad="Cerezler";     Yol="cookies.sqlite";          Tip="Cerez" },
                @{ Ad="Oturum";       Yol="sessionstore-backups";    Tip="Oturum" },
                @{ Ad="Thumbnails";   Yol="thumbnails";              Tip="Diger" }
            )
        },
        @{
            Ad       = "Opera"
            Kisa     = "Opera"
            ProfilYol = "$roamApp\Opera Software\Opera Stable"
            Profiller = @("")  # Opera tek profil
            Klasorler = @(
                @{ Ad="Cache";        Yol="Cache\Cache_Data";       Tip="Cache" },
                @{ Ad="Code Cache";   Yol="Code Cache";             Tip="Cache" },
                @{ Ad="GPUCache";     Yol="GPUCache";               Tip="Cache" },
                @{ Ad="Gecmis";       Yol="History";                Tip="Gecmis" },
                @{ Ad="Cerezler";     Yol="Cookies";                Tip="Cerez" }
            )
        },
        @{
            Ad       = "Opera GX"
            Kisa     = "OperaGX"
            ProfilYol = "$roamApp\Opera Software\Opera GX Stable"
            Profiller = @("")
            Klasorler = @(
                @{ Ad="Cache";        Yol="Cache\Cache_Data";       Tip="Cache" },
                @{ Ad="Code Cache";   Yol="Code Cache";             Tip="Cache" },
                @{ Ad="GPUCache";     Yol="GPUCache";               Tip="Cache" },
                @{ Ad="Gecmis";       Yol="History";                Tip="Gecmis" },
                @{ Ad="Cerezler";     Yol="Cookies";                Tip="Cerez" }
            )
        },
        @{
            Ad       = "Brave"
            Kisa     = "Brave"
            ProfilYol = "$localApp\BraveSoftware\Brave-Browser\User Data"
            Profiller = @("Default","Profile 1","Profile 2")
            Klasorler = @(
                @{ Ad="Cache";        Yol="Cache\Cache_Data";       Tip="Cache" },
                @{ Ad="Code Cache";   Yol="Code Cache";             Tip="Cache" },
                @{ Ad="GPUCache";     Yol="GPUCache";               Tip="Cache" },
                @{ Ad="Service Worker"; Yol="Service Worker\CacheStorage"; Tip="Cache" },
                @{ Ad="Gecmis";       Yol="History";                Tip="Gecmis" },
                @{ Ad="Cerezler";     Yol="Cookies";                Tip="Cerez" }
            )
        },
        @{
            Ad       = "Vivaldi"
            Kisa     = "Vivaldi"
            ProfilYol = "$localApp\Vivaldi\User Data"
            Profiller = @("Default","Profile 1","Profile 2")
            Klasorler = @(
                @{ Ad="Cache";        Yol="Cache\Cache_Data";       Tip="Cache" },
                @{ Ad="Code Cache";   Yol="Code Cache";             Tip="Cache" },
                @{ Ad="GPUCache";     Yol="GPUCache";               Tip="Cache" },
                @{ Ad="Gecmis";       Yol="History";                Tip="Gecmis" },
                @{ Ad="Cerezler";     Yol="Cookies";                Tip="Cerez" }
            )
        }
    )

    # ── Tarayicilari tara ve boyut hesapla ──
    $sonuclar = @()
    $toplamBoyut = 0

    foreach ($tarayici in $tarayicilar) {
        $tYol = $tarayici.ProfilYol
        if (-not (Test-Path $tYol)) { continue }

        # Firefox icin dinamik profil tespiti
        $profilListesi = $tarayici.Profiller
        if ($tarayici.Kisa -eq "Firefox") {
            $profilListesi = @(Get-ChildItem -Path $tYol -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.Name })
            if ($profilListesi.Count -eq 0) { continue }
        }

        $tBoyut = 0
        $detaylar = @()

        foreach ($profil in $profilListesi) {
            # Profil klasor yolu
            if ($tarayici.Kisa -eq "Opera" -or $tarayici.Kisa -eq "OperaGX") {
                $pYol = $tYol
            } else {
                $pYol = Join-Path $tYol $profil
            }
            if (-not (Test-Path $pYol)) { continue }

            foreach ($kl in $tarayici.Klasorler) {
                $tamYol = Join-Path $pYol $kl.Yol
                if (Test-Path $tamYol) {
                    $item = Get-Item $tamYol -Force -ErrorAction SilentlyContinue
                    $boyut = 0
                    if ($item.PSIsContainer) {
                        $boyut = (Get-ChildItem -Path $tamYol -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
                    } else {
                        $boyut = $item.Length
                    }
                    if ($boyut -gt 0) {
                        $tBoyut += $boyut
                        $detaylar += @{ Ad=$kl.Ad; Boyut=$boyut; Tip=$kl.Tip; Yol=$tamYol; Profil=$profil }
                    }
                }
            }
        }

        if ($tBoyut -gt 0) {
            $sonuclar += @{
                Tarayici  = $tarayici.Ad
                Kisa      = $tarayici.Kisa
                Boyut     = $tBoyut
                Detaylar  = $detaylar
                ProfilYol = $tYol
            }
            $toplamBoyut += $tBoyut
        }
    }

    # ── Sonuclari goster ──
    if ($sonuclar.Count -eq 0) {
        Yaz "  Hicbir tarayici verisi bulunamadi." Yellow
        RaporVeriEkle "tarayici_temizlik" "Tarayici bulunamadi"
        return
    }

    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  TESPIT EDILEN TARAYICILAR" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    $sira = 0
    foreach ($s in $sonuclar) {
        $sira++
        $boyutStr = BoyutFormatla $s.Boyut
        $renk = if ($s.Boyut -ge 1GB) { "Red" } elseif ($s.Boyut -ge 200MB) { "Yellow" } else { "Green" }
        Write-Host ("  " + $sira.ToString() + "  " + $s.Tarayici) -ForegroundColor Cyan -NoNewline
        Write-Host ("  [" + $boyutStr + "]") -ForegroundColor $renk

        # Tip bazinda grupla
        $cacheBoyut  = ($s.Detaylar | Where-Object { $_.Tip -eq "Cache" }  | Measure-Object -Property Boyut -Sum).Sum
        $gecmisBoyut = ($s.Detaylar | Where-Object { $_.Tip -eq "Gecmis" } | Measure-Object -Property Boyut -Sum).Sum
        $cerezBoyut  = ($s.Detaylar | Where-Object { $_.Tip -eq "Cerez" }  | Measure-Object -Property Boyut -Sum).Sum
        $oturumBoyut = ($s.Detaylar | Where-Object { $_.Tip -eq "Oturum" } | Measure-Object -Property Boyut -Sum).Sum
        $digerBoyut  = ($s.Detaylar | Where-Object { $_.Tip -eq "Diger" }  | Measure-Object -Property Boyut -Sum).Sum

        if ($cacheBoyut)  { Write-Host ("      Cache    : " + (BoyutFormatla $cacheBoyut))  -ForegroundColor Gray }
        if ($gecmisBoyut) { Write-Host ("      Gecmis   : " + (BoyutFormatla $gecmisBoyut)) -ForegroundColor Gray }
        if ($cerezBoyut)  { Write-Host ("      Cerezler : " + (BoyutFormatla $cerezBoyut))  -ForegroundColor Gray }
        if ($oturumBoyut) { Write-Host ("      Oturum   : " + (BoyutFormatla $oturumBoyut)) -ForegroundColor Gray }
        if ($digerBoyut)  { Write-Host ("      Diger    : " + (BoyutFormatla $digerBoyut))  -ForegroundColor Gray }
        Write-Host ""
    }

    $toplamStr = BoyutFormatla $toplamBoyut
    $topRenk = if ($toplamBoyut -ge 1GB) { "Red" } elseif ($toplamBoyut -ge 300MB) { "Yellow" } else { "Green" }
    Write-Host ("  TOPLAM TEMIZLENEBILIR: " + $toplamStr) -ForegroundColor $topRenk
    Write-Host ""

    # ── Temizlik menu ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  TEMIZLIK SECENEKLERI" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  1  >  Sadece CACHE temizle (guvenli, oturumlara dokunmaz)" -ForegroundColor Cyan
    Write-Host "  2  >  Cache + Gecmis temizle" -ForegroundColor Gray
    Write-Host "  3  >  Cache + Gecmis + Oturum temizle" -ForegroundColor Gray
    Write-Host "  4  >  HEPSINI temizle (cache + gecmis + cerez + oturum)" -ForegroundColor Yellow
    Write-Host "  5  >  Belirli tarayiciyi sec" -ForegroundColor Gray
    Write-Host "  0  >  Geri (temizleme yapma)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  UYARI: Cerez temizligi tum sitelerde oturumunuzu kapatir!" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $secim = Read-Host

    # Temizlenecek tipleri belirle
    $temizTipler = @()
    $hedefTarayicilar = $sonuclar
    $iptal = $false

    switch ($secim.Trim()) {
        "1" { $temizTipler = @("Cache") }
        "2" { $temizTipler = @("Cache","Gecmis") }
        "3" { $temizTipler = @("Cache","Gecmis","Oturum") }
        "4" { $temizTipler = @("Cache","Gecmis","Cerez","Oturum","Diger") }
        "5" {
            Write-Host ""
            Write-Host "  Hangi tarayici? (numara girin): " -ForegroundColor Yellow -NoNewline
            $tSec = Read-Host
            $tIdx = 0
            if ([int]::TryParse($tSec.Trim(), [ref]$tIdx) -and $tIdx -ge 1 -and $tIdx -le $sonuclar.Count) {
                $hedefTarayicilar = @($sonuclar[$tIdx - 1])
                Write-Host ""
                Write-Host "  Ne temizlensin?" -ForegroundColor Yellow
                Write-Host "  1=Cache  2=Cache+Gecmis  3=Cache+Gecmis+Oturum  4=Hepsi" -ForegroundColor Gray
                Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
                $tTip = Read-Host
                switch ($tTip.Trim()) {
                    "1" { $temizTipler = @("Cache") }
                    "2" { $temizTipler = @("Cache","Gecmis") }
                    "3" { $temizTipler = @("Cache","Gecmis","Oturum") }
                    "4" { $temizTipler = @("Cache","Gecmis","Cerez","Oturum","Diger") }
                    default { $iptal = $true }
                }
            } else { $iptal = $true }
        }
        "0" { $iptal = $true }
        default { $iptal = $true }
    }

    if ($iptal -or $temizTipler.Count -eq 0) {
        Yaz "  Temizlik iptal edildi." Gray
        return
    }

    # ── Tarayicilari kapat uyarisi ──
    Write-Host ""
    $acikTarayici = @()
    foreach ($ht in $hedefTarayicilar) {
        $procAd = switch ($ht.Kisa) {
            "Chrome"  { "chrome" }
            "Edge"    { "msedge" }
            "Firefox" { "firefox" }
            "Opera"   { "opera" }
            "OperaGX" { "opera" }
            "Brave"   { "brave" }
            "Vivaldi" { "vivaldi" }
            default   { "" }
        }
        if ($procAd -and (Get-Process -Name $procAd -ErrorAction SilentlyContinue)) {
            $acikTarayici += $ht.Tarayici
        }
    }

    if ($acikTarayici.Count -gt 0) {
        Yaz ("  UYARI: Su tarayicilar acik: " + ($acikTarayici -join ", ")) Red
        Write-Host "  Kapatilsin mi? (E/H): " -ForegroundColor Yellow -NoNewline
        $kapat = Read-Host
        if ($kapat.Trim().ToUpper() -eq "E") {
            foreach ($ht in $hedefTarayicilar) {
                $procAd = switch ($ht.Kisa) {
                    "Chrome"  { "chrome" }
                    "Edge"    { "msedge" }
                    "Firefox" { "firefox" }
                    "Opera"   { "opera" }
                    "OperaGX" { "opera" }
                    "Brave"   { "brave" }
                    "Vivaldi" { "vivaldi" }
                    default   { "" }
                }
                if ($procAd) {
                    Get-Process -Name $procAd -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                }
            }
            Yaz "  Tarayicilar kapatildi. 3 saniye bekleniyor..." Yellow
            Start-Sleep -Seconds 3
        } else {
            Yaz "  Acik tarayicilarin cache dosyalari kilitli olabilir, bazi dosyalar silinmeyebilir." Yellow
        }
    }

    # ── Temizlik islemi ──
    Write-Host ""
    Yaz "  Temizlik basliyor..." Yellow
    Write-Host ""

    $toplamSilinen = 0
    $toplamDosya   = 0

    foreach ($ht in $hedefTarayicilar) {
        Write-Host ("  " + $ht.Tarayici + ":") -ForegroundColor Cyan
        $tSilinen = 0

        foreach ($det in $ht.Detaylar) {
            if ($temizTipler -notcontains $det.Tip) { continue }

            $yol = $det.Yol
            if (-not (Test-Path $yol)) { continue }

            $item = Get-Item $yol -Force -ErrorAction SilentlyContinue
            try {
                if ($item.PSIsContainer) {
                    # Klasor — icindeki dosyalari sil
                    $dosyalar = Get-ChildItem -Path $yol -Recurse -File -Force -ErrorAction SilentlyContinue
                    $klBoyut  = ($dosyalar | Measure-Object Length -Sum).Sum
                    $klSayi   = $dosyalar.Count
                    Remove-Item -Path "$yol\*" -Recurse -Force -ErrorAction SilentlyContinue
                    $tSilinen += $klBoyut
                    $toplamDosya += $klSayi
                    Write-Host ("    " + $det.Ad + ": " + (BoyutFormatla $klBoyut) + " (" + $klSayi + " dosya)") -ForegroundColor Green
                } else {
                    # Tekil dosya (History, Cookies vb.)
                    $dBoyut = $item.Length
                    Remove-Item -Path $yol -Force -ErrorAction SilentlyContinue
                    $tSilinen += $dBoyut
                    $toplamDosya++
                    Write-Host ("    " + $det.Ad + ": " + (BoyutFormatla $dBoyut)) -ForegroundColor Green
                }
            } catch {
                Write-Host ("    " + $det.Ad + ": Silinemedi (kilitli olabilir)") -ForegroundColor DarkGray
            }
        }

        $toplamSilinen += $tSilinen
        if ($tSilinen -gt 0) {
            Write-Host ("    Toplam: " + (BoyutFormatla $tSilinen)) -ForegroundColor Yellow
        } else {
            Write-Host "    Temizlenecek veri yok." -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    # ── Ozet ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  TEMIZLIK OZETI" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host ("  Temizlenen     : " + (BoyutFormatla $toplamSilinen)) -ForegroundColor Green
    Write-Host ("  Silinen dosya  : " + $toplamDosya.ToString()) -ForegroundColor Green
    Write-Host ("  Tarayici sayisi: " + $hedefTarayicilar.Count.ToString()) -ForegroundColor White
    Write-Host ("  Temizlik tipleri: " + ($temizTipler -join ", ")) -ForegroundColor White
    Write-Host ""

    Add-Content $LOG_DOSYA ("  Tarayici Temizlik: " + (BoyutFormatla $toplamSilinen) + " silindi (" + $toplamDosya + " dosya)")
    RaporVeriEkle "tarayici_temizlik" @{ Silinen=(BoyutFormatla $toplamSilinen); Dosya=$toplamDosya; Tipler=($temizTipler -join ",") }
}

#endregion

#region ── MODUL 50: OEM BLOATWARE TESPİTİ ──────────────────

function OEMBloatwareTespiti {
    Baslik "OEM Bloatware Tespiti (Uretici On Yuklu Yazilimlar)" "50"

    if (-not (YoneticiKontrol)) {
        Yaz "  Bu modul icin Yonetici yetkisi gereklidir!" Red
        return
    }

    Write-Host ""
    Write-Host "  Bilgisayar ureticinizin on yukledigi gereksiz yazilimlari tespit eder." -ForegroundColor Cyan
    Write-Host "  Bu yazilimlar arka planda calisarak performans kaybina neden olur." -ForegroundColor Cyan
    Write-Host ""

    # ── Uretici tespiti ──
    $uretici = ""
    try {
        $bios = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
        $uretici = $bios.Manufacturer
        $model   = $bios.Model
        Write-Host ("  Uretici : " + $uretici) -ForegroundColor Yellow
        Write-Host ("  Model   : " + $model) -ForegroundColor Yellow
        Write-Host ""
    } catch {
        Yaz "  Uretici bilgisi alinamadi." DarkGray
    }

    # ── OEM yazilim veritabani ──
    # Her uretici icin: AppxPackage adi, Win32 program adi (DisplayName), servis adi
    $oemAppx = @{
        # HP / Hewlett-Packard
        "HP Smart"                    = @{ Paket="AD2F1837.HPPrinterControl";       Uretici="HP";      Aciklama="Yazici yonetim araci" }
        "HP Support Assistant"        = @{ Paket="";                                 Uretici="HP";      Aciklama="Destek ve guncelleme araci" }
        "HP System Event Utility"     = @{ Paket="";                                 Uretici="HP";      Aciklama="Hotkey ve olay servisi" }
        "HP Audio Switch"             = @{ Paket="";                                 Uretici="HP";      Aciklama="Ses cihazi yonetimi" }
        "HP QuickDrop"                = @{ Paket="";                                 Uretici="HP";      Aciklama="Dosya paylasim araci" }
        "HP PC Hardware Diagnostics"  = @{ Paket="";                                 Uretici="HP";      Aciklama="Donanim tani araci" }
        "HP Sure Click"               = @{ Paket="";                                 Uretici="HP";      Aciklama="Tarayici izolasyon (kaynak tuketir)" }
        "HP Wolf Security"            = @{ Paket="";                                 Uretici="HP";      Aciklama="Guvenlik yazilimi (Defender yeterli)" }
        "HP Connection Optimizer"     = @{ Paket="";                                 Uretici="HP";      Aciklama="Ag yonetim araci" }
        "HP Documentation"            = @{ Paket="";                                 Uretici="HP";      Aciklama="Kullanim kilavuzlari" }
        "myHP"                        = @{ Paket="AD2F1837.myHP";                   Uretici="HP";      Aciklama="HP kontrol paneli" }

        # Dell
        "Dell SupportAssist"          = @{ Paket="";                                 Uretici="Dell";    Aciklama="Destek ve tani araci" }
        "Dell Digital Delivery"       = @{ Paket="DellInc.DellDigitalDelivery";     Uretici="Dell";    Aciklama="Yazilim dagitim araci" }
        "Dell Update"                 = @{ Paket="";                                 Uretici="Dell";    Aciklama="Surucu guncelleme" }
        "Dell Customer Connect"       = @{ Paket="";                                 Uretici="Dell";    Aciklama="Musteri anket araci" }
        "Dell Power Manager"          = @{ Paket="";                                 Uretici="Dell";    Aciklama="Pil ve guc yonetimi" }
        "Dell Cinema"                 = @{ Paket="";                                 Uretici="Dell";    Aciklama="Multimedya gelistirme" }
        "Dell Mobile Connect"         = @{ Paket="";                                 Uretici="Dell";    Aciklama="Telefon baglanti araci" }
        "Dell Optimizer"              = @{ Paket="";                                 Uretici="Dell";    Aciklama="Performans optimizasyon araci" }
        "My Dell"                     = @{ Paket="DellInc.MyDell";                  Uretici="Dell";    Aciklama="Dell kontrol paneli" }

        # Lenovo
        "Lenovo Vantage"              = @{ Paket="E046963F.LenovoCompanion";        Uretici="Lenovo";  Aciklama="Sistem yonetim araci" }
        "Lenovo Now"                  = @{ Paket="";                                 Uretici="Lenovo";  Aciklama="Reklam ve haber uygulamasi" }
        "Lenovo ID"                   = @{ Paket="";                                 Uretici="Lenovo";  Aciklama="Hesap giris araci" }
        "Lenovo Smart Appearance"     = @{ Paket="";                                 Uretici="Lenovo";  Aciklama="Kamera efekt araci" }
        "Lenovo Hotkeys"              = @{ Paket="";                                 Uretici="Lenovo";  Aciklama="Kisayol tus yonetimi" }
        "Lenovo Service Bridge"       = @{ Paket="";                                 Uretici="Lenovo";  Aciklama="Tarayici destek eklentisi" }
        "Lenovo System Update"        = @{ Paket="";                                 Uretici="Lenovo";  Aciklama="Surucu guncelleme" }
        "Lenovo Welcome"              = @{ Paket="";                                 Uretici="Lenovo";  Aciklama="Ilk kullanim sihirbazi" }
        "Lenovo Migration Assistant"  = @{ Paket="";                                 Uretici="Lenovo";  Aciklama="Veri tasima araci" }

        # Asus
        "MyASUS"                      = @{ Paket="B9ECED6F.MyASUS";                Uretici="ASUS";    Aciklama="ASUS kontrol paneli" }
        "ASUS Splendid"               = @{ Paket="";                                 Uretici="ASUS";    Aciklama="Ekran renk profili" }
        "Armoury Crate"               = @{ Paket="";                                 Uretici="ASUS";    Aciklama="Oyun ve performans merkezi" }
        "ASUS GiftBox"                = @{ Paket="";                                 Uretici="ASUS";    Aciklama="Reklam/promosyon araci" }
        "AURA Sync"                   = @{ Paket="";                                 Uretici="ASUS";    Aciklama="RGB aydinlatma kontrolu" }
        "ASUS System Control"         = @{ Paket="";                                 Uretici="ASUS";    Aciklama="Sistem olay yonetimi" }

        # Acer
        "Acer Care Center"            = @{ Paket="";                                 Uretici="Acer";    Aciklama="Sistem tani ve destek" }
        "Acer Quick Access"           = @{ Paket="";                                 Uretici="Acer";    Aciklama="Hizli erisim ayarlari" }
        "Acer Product Registration"   = @{ Paket="";                                 Uretici="Acer";    Aciklama="Urun kayit araci" }
        "Acer Collection"             = @{ Paket="";                                 Uretici="Acer";    Aciklama="Reklam/promosyon araci" }
        "Acer Configuration Manager"  = @{ Paket="";                                 Uretici="Acer";    Aciklama="Sistem yapilandirma" }
        "AcerSense"                   = @{ Paket="";                                 Uretici="Acer";    Aciklama="Performans izleme" }
        "Predator Sense"              = @{ Paket="";                                 Uretici="Acer";    Aciklama="Oyun performans araci" }

        # MSI
        "MSI Center"                  = @{ Paket="";                                 Uretici="MSI";     Aciklama="MSI yonetim merkezi" }
        "Dragon Center"               = @{ Paket="";                                 Uretici="MSI";     Aciklama="Eski MSI kontrol paneli" }
        "MSI App Player"              = @{ Paket="";                                 Uretici="MSI";     Aciklama="Android emulator (BlueStacks)" }
        "Nahimic"                     = @{ Paket="";                                 Uretici="MSI";     Aciklama="Ses gelistirme yazilimi" }
        "Norton Security"             = @{ Paket="";                                 Uretici="MSI";     Aciklama="Deneme antivirusu (Defender yeterli)" }

        # Samsung
        "Samsung Settings"            = @{ Paket="";                                 Uretici="Samsung"; Aciklama="Samsung ayar paneli" }
        "Samsung Update"              = @{ Paket="";                                 Uretici="Samsung"; Aciklama="Surucu guncelleme" }
        "Samsung Flow"                = @{ Paket="SAMSUNGELECTRONICSCoLtd.SamsungFlow"; Uretici="Samsung"; Aciklama="Telefon baglanti araci" }
        "Samsung Notes"               = @{ Paket="SAMSUNGELECTRONICSCoLtd.SamsungNotes"; Uretici="Samsung"; Aciklama="Not alma uygulamasi" }
        "Samsung Gallery"             = @{ Paket="";                                 Uretici="Samsung"; Aciklama="Foto galeri uygulamasi" }

        # Genel OEM / 3rd party pre-install
        "McAfee"                      = @{ Paket="";                                 Uretici="Genel";   Aciklama="Deneme antivirusu (Defender yeterli)" }
        "Norton"                      = @{ Paket="";                                 Uretici="Genel";   Aciklama="Deneme antivirusu (Defender yeterli)" }
        "WildTangent Games"           = @{ Paket="WildTangentGames*";               Uretici="Genel";   Aciklama="Reklam destekli oyunlar" }
        "Candy Crush"                 = @{ Paket="king.com.CandyCrush*";            Uretici="Genel";   Aciklama="Reklam destekli oyun" }
        "Disney Magic Kingdoms"       = @{ Paket="Disney*";                          Uretici="Genel";   Aciklama="Reklam destekli oyun" }
        "Spotify"                     = @{ Paket="SpotifyAB.SpotifyMusic";          Uretici="Genel";   Aciklama="On yuklu muzik uygulamasi" }
        "TikTok"                      = @{ Paket="BytedancePte.Ltd.TikTok";         Uretici="Genel";   Aciklama="On yuklu sosyal medya" }
        "Instagram"                   = @{ Paket="Facebook.Instagram*";             Uretici="Genel";   Aciklama="On yuklu sosyal medya" }
        "Facebook"                    = @{ Paket="Facebook.Facebook*";              Uretici="Genel";   Aciklama="On yuklu sosyal medya" }
        "ExpressVPN"                  = @{ Paket="";                                 Uretici="Genel";   Aciklama="Deneme VPN yazilimi" }
        "Dropbox Promosyon"           = @{ Paket="";                                 Uretici="Genel";   Aciklama="Deneme bulut depolama" }
    }

    # ── OEM servisleri ──
    $oemServisler = @(
        @{ Ad="HPSupportSolutionsFrameworkService"; Uretici="HP";      Aciklama="HP Support Framework" },
        @{ Ad="HPAppHelperCap";                     Uretici="HP";      Aciklama="HP App Helper" },
        @{ Ad="HPDiagsCap";                         Uretici="HP";      Aciklama="HP Diagnostics" },
        @{ Ad="HPNetworkCap";                       Uretici="HP";      Aciklama="HP Network" },
        @{ Ad="HPOmenCap";                          Uretici="HP";      Aciklama="HP Omen" },
        @{ Ad="HPSysInfoCap";                       Uretici="HP";      Aciklama="HP System Info" },
        @{ Ad="HPTouchpointAnalyticsService";       Uretici="HP";      Aciklama="HP Telemetri (veri toplama)" },
        @{ Ad="HotKeyServiceUWP";                   Uretici="HP";      Aciklama="HP HotKey" },
        @{ Ad="DellClientManagementService";        Uretici="Dell";    Aciklama="Dell Client Management" },
        @{ Ad="SupportAssistAgent";                 Uretici="Dell";    Aciklama="Dell SupportAssist" },
        @{ Ad="DDVDataCollector";                   Uretici="Dell";    Aciklama="Dell Veri Toplama" },
        @{ Ad="DDVRulesProcessor";                  Uretici="Dell";    Aciklama="Dell Rules Processor" },
        @{ Ad="DDVCollectorSvcApi";                 Uretici="Dell";    Aciklama="Dell Collector API" },
        @{ Ad="LenovoVantageService";               Uretici="Lenovo";  Aciklama="Lenovo Vantage" },
        @{ Ad="ImControllerService";                Uretici="Lenovo";  Aciklama="Lenovo System Interface" },
        @{ Ad="Lenovo.Modern.ImController";         Uretici="Lenovo";  Aciklama="Lenovo Modern Controller" },
        @{ Ad="ASUSOptimization";                   Uretici="ASUS";    Aciklama="ASUS Optimization" },
        @{ Ad="ASUSSystemAnalysis";                 Uretici="ASUS";    Aciklama="ASUS System Analysis" },
        @{ Ad="ASUSSystemDiagnosis";                Uretici="ASUS";    Aciklama="ASUS Diagnosis" },
        @{ Ad="ArmouryCrateService";                Uretici="ASUS";    Aciklama="Armoury Crate" },
        @{ Ad="MSICentralService";                  Uretici="MSI";     Aciklama="MSI Center Service" },
        @{ Ad="NahimicService";                     Uretici="MSI";     Aciklama="Nahimic Audio" },
        @{ Ad="McAfee*";                            Uretici="Genel";   Aciklama="McAfee Antivirusu" },
        @{ Ad="Norton*";                            Uretici="Genel";   Aciklama="Norton Antivirusu" }
    )

    # ── Appx taramasi ──
    Yaz "  AppX paketleri taranıyor..." Gray
    $bulunanAppx = @()
    foreach ($item in $oemAppx.GetEnumerator()) {
        $bilgi = $item.Value
        if ($bilgi.Paket -and $bilgi.Paket -ne "") {
            $pkg = Get-AppxPackage -Name ($bilgi.Paket) -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($pkg) {
                $bulunanAppx += @{ Ad=$item.Key; Paket=$bilgi.Paket; Uretici=$bilgi.Uretici; Aciklama=$bilgi.Aciklama; Tur="AppX" }
            }
        }
    }

    # ── Win32 program taramasi (Kayit Defteri) ──
    Yaz "  Yuklu programlar taranıyor..." Gray
    $regYollar = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $yukluProgramlar = @()
    foreach ($yol in $regYollar) {
        $yukluProgramlar += Get-ItemProperty $yol -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }
    }

    $bulunanWin32 = @()
    foreach ($item in $oemAppx.GetEnumerator()) {
        $bilgi = $item.Value
        $adAra = $item.Key
        $eslesenProg = $yukluProgramlar | Where-Object {
            $_.DisplayName -like ("*" + $adAra + "*")
        } | Select-Object -First 1

        if ($eslesenProg -and (-not ($bulunanAppx | Where-Object { $_.Ad -eq $adAra }))) {
            $bulunanWin32 += @{
                Ad=$adAra; Uretici=$bilgi.Uretici; Aciklama=$bilgi.Aciklama; Tur="Win32"
                UninstallString=$eslesenProg.UninstallString
                DisplayName=$eslesenProg.DisplayName
            }
        }
    }

    # ── Servis taramasi ──
    Yaz "  OEM servisleri taranıyor..." Gray
    $bulunanServisler = @()
    foreach ($svc in $oemServisler) {
        $servis = Get-Service -Name $svc.Ad -ErrorAction SilentlyContinue
        if ($servis) {
            $bulunanServisler += @{
                Ad=$svc.Ad; Uretici=$svc.Uretici; Aciklama=$svc.Aciklama
                Durum=$servis.Status.ToString(); BaslamaT=$servis.StartType.ToString()
            }
        }
    }

    # ── Sonuclari goster ──
    $toplamBulunan = $bulunanAppx.Count + $bulunanWin32.Count
    Write-Host ""
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  TARAMA SONUCLARI" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    if ($toplamBulunan -eq 0 -and $bulunanServisler.Count -eq 0) {
        Yaz "  Hicbir OEM bloatware tespit edilmedi. Sisteminiz temiz!" Green
        RaporVeriEkle "oem_bloatware" "Temiz"
        return
    }

    # Ureticiye gore grupla
    $tumBulunanlar = $bulunanAppx + $bulunanWin32
    $ureticiGrup = $tumBulunanlar | Group-Object { $_.Uretici }

    $sira = 0
    $siraDizi = @()
    foreach ($grup in $ureticiGrup) {
        Write-Host ("  [ " + $grup.Name + " ]") -ForegroundColor Yellow
        foreach ($uyg in $grup.Group) {
            $sira++
            $turStr = if ($uyg.Tur -eq "AppX") { "[Store]" } else { "[Win32]" }
            Write-Host ("    " + $sira.ToString().PadLeft(2) + "  " + $uyg.Ad) -ForegroundColor White -NoNewline
            Write-Host ("  " + $turStr) -ForegroundColor DarkGray -NoNewline
            Write-Host ("  - " + $uyg.Aciklama) -ForegroundColor Gray
            $siraDizi += $uyg
        }
        Write-Host ""
    }

    Write-Host ("  Toplam: " + $toplamBulunan.ToString() + " OEM uygulama tespit edildi.") -ForegroundColor Yellow
    Write-Host ""

    # Servisler
    if ($bulunanServisler.Count -gt 0) {
        Write-Host "  ================================================" -ForegroundColor DarkCyan
        Write-Host "  OEM SERVISLERI" -ForegroundColor Yellow
        Write-Host "  ================================================" -ForegroundColor DarkCyan
        Write-Host ""
        foreach ($svc in $bulunanServisler) {
            $durumRenk = if ($svc.Durum -eq "Running") { "Red" } else { "Green" }
            Write-Host ("    " + $svc.Ad) -ForegroundColor White -NoNewline
            Write-Host (" [" + $svc.Durum + "/" + $svc.BaslamaT + "]") -ForegroundColor $durumRenk -NoNewline
            Write-Host (" - " + $svc.Aciklama) -ForegroundColor Gray
        }
        Write-Host ""
        Write-Host ("  Toplam: " + $bulunanServisler.Count.ToString() + " OEM servis tespit edildi.") -ForegroundColor Yellow
        Write-Host ""
    }

    # ── Islem menu ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  ISLEMLER" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "  1  >  TUM OEM uygulamalari kaldir" -ForegroundColor Cyan
    Write-Host "  2  >  Secmeli kaldir (numara gir)" -ForegroundColor Gray
    Write-Host "  3  >  OEM servisleri durdur ve devre disi birak" -ForegroundColor Gray
    Write-Host "  4  >  Sadece rapor goster (kaldirma yapma)" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $secim = Read-Host

    switch ($secim.Trim()) {
        "1" {
            Write-Host ""
            Write-Host "  " + $toplamBulunan.ToString() + " uygulama kaldirilacak. Emin misiniz? (E/H): " -ForegroundColor Red -NoNewline
            $onay = Read-Host
            if ($onay.Trim().ToUpper() -ne "E") { Yaz "  Iptal edildi." Gray; return }

            Write-Host ""
            $kaldirilanSayi = 0
            foreach ($uyg in $siraDizi) {
                Write-Host ("  Kaldiriliyor: " + $uyg.Ad + "...") -ForegroundColor Yellow -NoNewline
                if ($uyg.Tur -eq "AppX") {
                    try {
                        Get-AppxPackage -Name ($uyg.Paket) -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction Stop
                        Write-Host " OK" -ForegroundColor Green
                        $kaldirilanSayi++
                    } catch {
                        Write-Host " HATA" -ForegroundColor Red
                    }
                } else {
                    # Win32 — sadece uyar, otomatik uninstall riskli
                    Write-Host " [Manuel kaldirin]" -ForegroundColor DarkGray
                    if ($uyg.UninstallString) {
                        Write-Host ("    Kaldirma komutu: " + $uyg.UninstallString) -ForegroundColor DarkGray
                    }
                }
            }
            Write-Host ""
            Yaz ("  " + $kaldirilanSayi.ToString() + " AppX uygulama kaldirildi.") Green
            if (($siraDizi | Where-Object { $_.Tur -eq "Win32" }).Count -gt 0) {
                Yaz "  Win32 programlar icin: Ayarlar > Uygulamalar'dan manuel kaldirin." Yellow
            }
        }

        "2" {
            Write-Host ""
            Write-Host "  Kaldirmak istediginiz numaralari girin (virgul ile ayirin): " -ForegroundColor Yellow -NoNewline
            $numaralar = Read-Host
            $secilen = $numaralar.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }

            $kaldirilanSayi = 0
            foreach ($no in $secilen) {
                $idx = [int]$no - 1
                if ($idx -ge 0 -and $idx -lt $siraDizi.Count) {
                    $uyg = $siraDizi[$idx]
                    Write-Host ("  Kaldiriliyor: " + $uyg.Ad + "...") -ForegroundColor Yellow -NoNewline
                    if ($uyg.Tur -eq "AppX") {
                        try {
                            Get-AppxPackage -Name ($uyg.Paket) -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction Stop
                            Write-Host " OK" -ForegroundColor Green
                            $kaldirilanSayi++
                        } catch {
                            Write-Host " HATA" -ForegroundColor Red
                        }
                    } else {
                        Write-Host " [Manuel kaldirin]" -ForegroundColor DarkGray
                        if ($uyg.UninstallString) {
                            Write-Host ("    Kaldirma komutu: " + $uyg.UninstallString) -ForegroundColor DarkGray
                        }
                    }
                }
            }
            Write-Host ""
            Yaz ("  " + $kaldirilanSayi.ToString() + " uygulama kaldirildi.") Green
        }

        "3" {
            if ($bulunanServisler.Count -eq 0) {
                Yaz "  OEM servisi bulunamadi." DarkGray
                return
            }
            Write-Host ""
            Yaz ("  " + $bulunanServisler.Count.ToString() + " OEM servis durdurulup devre disi birakilacak...") Yellow
            $durdurulan = 0
            foreach ($svc in $bulunanServisler) {
                try {
                    $servis = Get-Service -Name $svc.Ad -ErrorAction SilentlyContinue
                    if ($servis) {
                        if ($servis.Status -eq "Running") {
                            Stop-Service -Name $svc.Ad -Force -ErrorAction SilentlyContinue
                        }
                        Set-Service -Name $svc.Ad -StartupType Disabled -ErrorAction SilentlyContinue
                        Write-Host ("    " + $svc.Ad + ": Durduruldu + Devre disi") -ForegroundColor Green
                        $durdurulan++
                    }
                } catch {
                    Write-Host ("    " + $svc.Ad + ": Isleme alinamadi") -ForegroundColor Red
                }
            }
            Write-Host ""
            Yaz ("  " + $durdurulan.ToString() + " OEM servis devre disi birakildi.") Green
        }

        "4" {
            Yaz "  Rapor yukarida goruntulendi. Hicbir islem yapilmadi." Gray
        }
    }

    Add-Content $LOG_DOSYA ("  OEM Bloatware: " + $toplamBulunan + " uygulama, " + $bulunanServisler.Count + " servis tespit edildi")
    RaporVeriEkle "oem_bloatware" @{ Uygulama=$toplamBulunan; Servis=$bulunanServisler.Count; Uretici=$uretici }
}

#endregion

#region ── MODUL 51: BOOT SÜRESİ ANALİZİ ───────────────────

function BootSuresiAnalizi {
    Baslik "Boot Suresi Analizi (Baslangic Performansi)" "51"

    Write-Host ""
    Write-Host "  Windows baslangic suresini olcer, yavaslatan bilesenleri tespit eder." -ForegroundColor Cyan
    Write-Host ""

    # ── 1) Son boot suresi (Event Log) ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  SON BASLATMA SURESI" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    $bootSureSn  = $null
    $bootTarih   = $null

    # Yontem 1: Event Log - Microsoft-Windows-Diagnostics-Performance/Operational (Event ID 100)
    try {
        $bootEvent = Get-WinEvent -FilterHashtable @{
            LogName='Microsoft-Windows-Diagnostics-Performance/Operational'
            Id=100
        } -MaxEvents 5 -ErrorAction SilentlyContinue

        if ($bootEvent -and $bootEvent.Count -gt 0) {
            $sonBoot = $bootEvent[0]
            # BootTime ms cinsinden XML property
            $xml = [xml]$sonBoot.ToXml()
            $ns  = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
            $ns.AddNamespace("e","http://schemas.microsoft.com/win/2004/08/events/event")
            $bootMs = $xml.SelectSingleNode("//e:EventData/e:Data[@Name='BootTime']", $ns)
            if ($bootMs) {
                $bootSureSn = [math]::Round([long]$bootMs.InnerText / 1000, 1)
                $bootTarih  = $sonBoot.TimeCreated
            }
        }
    } catch {}

    # Yontem 2: WMI ile son boot zamani + uptime hesapla
    $sonBootZaman = $null
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        $sonBootZaman = $os.LastBootUpTime
        $uptime = (Get-Date) - $sonBootZaman
    } catch {}

    if ($bootSureSn) {
        $bootRenk = if ($bootSureSn -le 15) { "Green" } elseif ($bootSureSn -le 30) { "Yellow" } elseif ($bootSureSn -le 60) { "Red" } else { "DarkRed" }
        $bootNot  = if ($bootSureSn -le 15) { "Mukemmel" } elseif ($bootSureSn -le 30) { "Iyi" } elseif ($bootSureSn -le 60) { "Yavas" } else { "Cok Yavas" }

        Write-Host ("  Boot Suresi    : " + $bootSureSn.ToString() + " saniye") -ForegroundColor $bootRenk
        Write-Host ("  Degerlendirme  : " + $bootNot) -ForegroundColor $bootRenk
        if ($bootTarih) {
            Write-Host ("  Olcum Tarihi   : " + $bootTarih.ToString("dd.MM.yyyy HH:mm")) -ForegroundColor Gray
        }
    } else {
        Yaz "  Boot suresi Event Log'dan okunamadi (log devre disi olabilir)." DarkGray
    }

    if ($sonBootZaman) {
        Write-Host ("  Son Boot       : " + $sonBootZaman.ToString("dd.MM.yyyy HH:mm:ss")) -ForegroundColor White
        Write-Host ("  Uptime         : " + [int]$uptime.TotalDays + " gun, " + $uptime.Hours + " saat, " + $uptime.Minutes + " dakika") -ForegroundColor White
        if ($uptime.TotalDays -gt 7) {
            Yaz "  IPUCU: 7 gunden fazla acik. Yeniden baslatma performansi artirabilir." Yellow
        }
    }
    Write-Host ""

    # Son 5 boot suresi gecmisi
    try {
        $bootEvents = Get-WinEvent -FilterHashtable @{
            LogName='Microsoft-Windows-Diagnostics-Performance/Operational'
            Id=100
        } -MaxEvents 10 -ErrorAction SilentlyContinue

        if ($bootEvents -and $bootEvents.Count -gt 1) {
            Write-Host "  Son Boot Gecmisi:" -ForegroundColor Cyan
            $bootIdx = 0
            foreach ($evt in $bootEvents) {
                $bootIdx++
                if ($bootIdx -gt 5) { break }
                try {
                    $xDoc = [xml]$evt.ToXml()
                    $nsm  = New-Object System.Xml.XmlNamespaceManager($xDoc.NameTable)
                    $nsm.AddNamespace("e","http://schemas.microsoft.com/win/2004/08/events/event")
                    $msNode = $xDoc.SelectSingleNode("//e:EventData/e:Data[@Name='BootTime']", $nsm)
                    if ($msNode) {
                        $sn = [math]::Round([long]$msNode.InnerText / 1000, 1)
                        $r  = if ($sn -le 15) {"Green"} elseif ($sn -le 30) {"Yellow"} else {"Red"}
                        Write-Host ("    " + $evt.TimeCreated.ToString("dd.MM.yyyy HH:mm") + "  " + $sn.ToString().PadLeft(6) + " sn") -ForegroundColor $r
                    }
                } catch {}
            }
            Write-Host ""
        }
    } catch {}

    # ── 2) Baslangic programlari etkisi ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  BASLANGIC PROGRAMLARI ETKISI" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    # Event ID 101 = Boot degradation from application
    $yavasProgramlar = @()
    try {
        $degradeEvents = Get-WinEvent -FilterHashtable @{
            LogName='Microsoft-Windows-Diagnostics-Performance/Operational'
            Id=101
        } -MaxEvents 30 -ErrorAction SilentlyContinue

        if ($degradeEvents) {
            $progGrup = @{}
            foreach ($evt in $degradeEvents) {
                try {
                    $xDoc = [xml]$evt.ToXml()
                    $nsm  = New-Object System.Xml.XmlNamespaceManager($xDoc.NameTable)
                    $nsm.AddNamespace("e","http://schemas.microsoft.com/win/2004/08/events/event")
                    $adNode    = $xDoc.SelectSingleNode("//e:EventData/e:Data[@Name='Name']", $nsm)
                    $sureNode  = $xDoc.SelectSingleNode("//e:EventData/e:Data[@Name='TotalTime']", $nsm)
                    $yolNode   = $xDoc.SelectSingleNode("//e:EventData/e:Data[@Name='PathName']", $nsm)

                    if ($adNode -and $sureNode) {
                        $pAd   = $adNode.InnerText
                        $pMs   = [long]$sureNode.InnerText
                        $pYol  = if ($yolNode) { $yolNode.InnerText } else { "" }

                        if ($progGrup.ContainsKey($pAd)) {
                            $progGrup[$pAd].Toplam += $pMs
                            $progGrup[$pAd].Sayi++
                            if ($pMs -gt $progGrup[$pAd].Max) { $progGrup[$pAd].Max = $pMs }
                        } else {
                            $progGrup[$pAd] = @{ Toplam=$pMs; Sayi=1; Max=$pMs; Yol=$pYol }
                        }
                    }
                } catch {}
            }

            if ($progGrup.Count -gt 0) {
                $sirali = $progGrup.GetEnumerator() | Sort-Object { $_.Value.Max } -Descending
                Write-Host ("  {0,-35} {1,10} {2,10} {3,5}" -f "Program","En Yavas","Ortalama","Sayi") -ForegroundColor DarkGray
                Write-Host ("  " + ("-" * 65)) -ForegroundColor DarkGray

                foreach ($p in $sirali) {
                    $maxSn = [math]::Round($p.Value.Max / 1000, 1)
                    $ortSn = [math]::Round(($p.Value.Toplam / $p.Value.Sayi) / 1000, 1)
                    $r = if ($maxSn -gt 5) {"Red"} elseif ($maxSn -gt 2) {"Yellow"} else {"Green"}
                    Write-Host ("  {0,-35} {1,8} sn {2,8} sn {3,5}" -f $p.Key, $maxSn, $ortSn, $p.Value.Sayi) -ForegroundColor $r
                    $yavasProgramlar += @{ Ad=$p.Key; MaxSn=$maxSn; Yol=$p.Value.Yol }
                }
                Write-Host ""
            }
        }
    } catch {}

    if ($yavasProgramlar.Count -eq 0) {
        Yaz "  Baslangic degradasyon verisi bulunamadi (log bos veya devre disi)." DarkGray
        Write-Host ""
    }

    # ── 3) Surucu yuklenme suresi ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  SURUCU YUKLENME SURESI" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    # Event ID 102 = Boot degradation from driver
    try {
        $driverEvents = Get-WinEvent -FilterHashtable @{
            LogName='Microsoft-Windows-Diagnostics-Performance/Operational'
            Id=102
        } -MaxEvents 20 -ErrorAction SilentlyContinue

        if ($driverEvents -and $driverEvents.Count -gt 0) {
            $drvGrup = @{}
            foreach ($evt in $driverEvents) {
                try {
                    $xDoc = [xml]$evt.ToXml()
                    $nsm  = New-Object System.Xml.XmlNamespaceManager($xDoc.NameTable)
                    $nsm.AddNamespace("e","http://schemas.microsoft.com/win/2004/08/events/event")
                    $adNode   = $xDoc.SelectSingleNode("//e:EventData/e:Data[@Name='Name']", $nsm)
                    $sureNode = $xDoc.SelectSingleNode("//e:EventData/e:Data[@Name='TotalTime']", $nsm)

                    if ($adNode -and $sureNode) {
                        $dAd = $adNode.InnerText
                        $dMs = [long]$sureNode.InnerText
                        if (-not $drvGrup.ContainsKey($dAd) -or $dMs -gt $drvGrup[$dAd]) {
                            $drvGrup[$dAd] = $dMs
                        }
                    }
                } catch {}
            }

            if ($drvGrup.Count -gt 0) {
                $drvSirali = $drvGrup.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10
                foreach ($d in $drvSirali) {
                    $dSn = [math]::Round($d.Value / 1000, 1)
                    $r = if ($dSn -gt 3) {"Red"} elseif ($dSn -gt 1) {"Yellow"} else {"Green"}
                    Write-Host ("    {0,-40} {1,6} sn" -f $d.Key, $dSn) -ForegroundColor $r
                }
            }
        } else {
            Yaz "  Surucu degradasyon verisi bulunamadi." DarkGray
        }
    } catch {
        Yaz "  Surucu verisi okunamadi." DarkGray
    }
    Write-Host ""

    # ── 4) Disk tipi etkisi ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  DISK TIPI VE HIZLI BASLATMA" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    # SSD/HDD tespiti
    try {
        $diskler = Get-PhysicalDisk -ErrorAction SilentlyContinue
        foreach ($disk in $diskler) {
            $tipRenk = if ($disk.MediaType -eq "SSD") { "Green" } elseif ($disk.MediaType -eq "NVMe" -or $disk.BusType -eq "NVMe") { "Green" } else { "Yellow" }
            $tipStr  = if ($disk.BusType -eq "NVMe") { "NVMe SSD" } elseif ($disk.MediaType -eq "SSD") { "SATA SSD" } elseif ($disk.MediaType -eq "HDD") { "HDD" } else { $disk.MediaType }
            $boyut   = if ($disk.Size) { BoyutFormatla $disk.Size } else { "?" }
            Write-Host ("  Disk " + $disk.DeviceId + ": " + $disk.FriendlyName) -ForegroundColor White
            Write-Host ("    Tip: " + $tipStr + " | Boyut: " + $boyut) -ForegroundColor $tipRenk

            if ($disk.MediaType -eq "HDD" -or ($disk.MediaType -ne "SSD" -and $disk.BusType -ne "NVMe")) {
                Yaz "    ONEMLI: HDD ile Windows kullaniyorsaniz boot suresi yavas olacaktir." Red
                Yaz "    SSD'ye gecis en buyuk hiz artisi saglar (10x-20x daha hizli boot)." Yellow
            }
        }
    } catch {
        Yaz "  Disk bilgisi alinamadi." DarkGray
    }
    Write-Host ""

    # Hizli baslatma (Fast Startup) durumu
    $fastBoot = $null
    try {
        $fbPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
        $fbVal  = Get-ItemProperty -Path $fbPath -Name "HiberbootEnabled" -ErrorAction SilentlyContinue
        if ($fbVal) { $fastBoot = $fbVal.HiberbootEnabled }
    } catch {}

    if ($fastBoot -eq 1) {
        Write-Host "  Hizli Baslatma (Fast Startup): " -ForegroundColor White -NoNewline
        Write-Host "AKTIF" -ForegroundColor Green
    } elseif ($fastBoot -eq 0) {
        Write-Host "  Hizli Baslatma (Fast Startup): " -ForegroundColor White -NoNewline
        Write-Host "KAPALI" -ForegroundColor Red
        Yaz "  IPUCU: Hizli baslatmayi acmak boot suresini kisaltir." Yellow
    } else {
        Write-Host "  Hizli Baslatma: Bilinmiyor" -ForegroundColor DarkGray
    }

    # UEFI / Legacy BIOS
    try {
        $fwType = if ($env:firmware_type -eq "UEFI" -or (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\State")) { "UEFI" } else { "Legacy BIOS" }
        $fwRenk = if ($fwType -eq "UEFI") { "Green" } else { "Yellow" }
        Write-Host ("  Firmware        : " + $fwType) -ForegroundColor $fwRenk
        if ($fwType -eq "Legacy BIOS") {
            Yaz "  IPUCU: UEFI modu daha hizli boot saglar." Yellow
        }
    } catch {}
    Write-Host ""

    # ── 5) Baslangic programi sayisi ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  BASLANGIC YUKLEME OZETI" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    $startupSayi = 0
    # Registry Run keys
    $runYollar = @(
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    )
    foreach ($ry in $runYollar) {
        $props = Get-ItemProperty $ry -ErrorAction SilentlyContinue
        if ($props) {
            $startupSayi += ($props.PSObject.Properties | Where-Object { $_.Name -notlike "PS*" }).Count
        }
    }

    # Startup klasoru
    $startupKlasor = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    if (Test-Path $startupKlasor) {
        $startupSayi += (Get-ChildItem $startupKlasor -File -ErrorAction SilentlyContinue).Count
    }

    # Scheduled tasks at logon
    $logonGorevler = 0
    try {
        $gorevler = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object {
            $_.State -eq "Ready" -and $_.Triggers -and ($_.Triggers | Where-Object { $_ -is [CimInstance] -and $_.CimClass.CimClassName -eq "MSFT_TaskLogonTrigger" })
        }
        if ($gorevler) { $logonGorevler = $gorevler.Count }
    } catch {}

    $toplamRenk = if ($startupSayi -le 5) {"Green"} elseif ($startupSayi -le 15) {"Yellow"} else {"Red"}
    Write-Host ("  Registry Run kayitlari  : " + $startupSayi) -ForegroundColor $toplamRenk
    Write-Host ("  Zamanli gorev (logon)   : " + $logonGorevler) -ForegroundColor $(if ($logonGorevler -le 5) {"Green"} else {"Yellow"})

    if ($startupSayi -gt 15) {
        Yaz "  UYARI: 15'ten fazla baslangic programi var. Boot suresi uzar!" Red
        Yaz "  Modul 12 (Baslangic Analizi) ile gereksizleri kapatabilirsiniz." Yellow
    }
    Write-Host ""

    # ── 6) Oneriler ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  IYILESTIRME ONERILERI" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    $oneriSira = 0

    # SSD yoksa en buyuk oneri
    $hddVar = $false
    try {
        $diskler2 = Get-PhysicalDisk -ErrorAction SilentlyContinue
        foreach ($d in $diskler2) {
            if ($d.MediaType -ne "SSD" -and $d.BusType -ne "NVMe") { $hddVar = $true }
        }
    } catch {}
    if ($hddVar) {
        $oneriSira++
        Write-Host ("  " + $oneriSira + ". SSD'ye gecin — en buyuk hiz artisi (10x-20x)") -ForegroundColor Red
    }

    if ($fastBoot -eq 0) {
        $oneriSira++
        Write-Host ("  " + $oneriSira + ". Hizli Baslatma'yi acin") -ForegroundColor Yellow
    }

    if ($startupSayi -gt 10) {
        $oneriSira++
        Write-Host ("  " + $oneriSira + ". Gereksiz baslangic programlarini kapatin (Modul 12)") -ForegroundColor Yellow
    }

    if ($yavasProgramlar.Count -gt 0) {
        $enYavas = $yavasProgramlar | Sort-Object { $_.MaxSn } -Descending | Select-Object -First 3
        foreach ($yp in $enYavas) {
            if ($yp.MaxSn -gt 3) {
                $oneriSira++
                Write-Host ("  " + $oneriSira + ". '" + $yp.Ad + "' baslangictan kaldirilmali (" + $yp.MaxSn + " sn)") -ForegroundColor Yellow
            }
        }
    }

    $oneriSira++
    Write-Host ("  " + $oneriSira + ". OEM bloatware temizleyin (Modul 50)") -ForegroundColor Gray
    $oneriSira++
    Write-Host ("  " + $oneriSira + ". Gereksiz servisleri kapatin (Modul 11)") -ForegroundColor Gray
    $oneriSira++
    Write-Host ("  " + $oneriSira + ". BIOS'ta gereksiz cihazlari kapatin (Wi-Fi/BT kullanmiyorsaniz)") -ForegroundColor Gray

    if ($oneriSira -eq 3) {
        Yaz "  Sisteminiz zaten iyi durumda!" Green
    }
    Write-Host ""

    # ── 7) Menu ──
    Write-Host "  1  >  Hizli Baslatma'yi ac/kapat" -ForegroundColor Gray
    Write-Host "  2  >  Baslangic programlarini yonet (Modul 12)" -ForegroundColor Gray
    Write-Host "  3  >  msconfig ac (gelismis boot ayarlari)" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $s = Read-Host

    switch ($s.Trim()) {
        "1" {
            $fbPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
            if ($fastBoot -eq 1) {
                Set-ItemProperty -Path $fbPath -Name "HiberbootEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue
                Yaz "  Hizli Baslatma KAPATILDI. (Yeniden baslatma gerekli)" Yellow
            } else {
                Set-ItemProperty -Path $fbPath -Name "HiberbootEnabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
                Yaz "  Hizli Baslatma ACILDI. (Yeniden baslatma gerekli)" Green
            }
        }
        "2" { BaslangicAnalizi }
        "3" { Start-Process "msconfig.exe" -ErrorAction SilentlyContinue }
    }

    Add-Content $LOG_DOSYA ("  Boot Suresi Analizi: " + $(if ($bootSureSn) { $bootSureSn.ToString() + " sn" } else { "olculemedi" }) + " | Startup: " + $startupSayi)
    RaporVeriEkle "boot_suresi" @{ BootSn=$bootSureSn; Startup=$startupSayi; FastBoot=$fastBoot; HDD=$hddVar }
}

#endregion

#region ── MODUL 52: SAĞ TIK MENÜ TEMİZLE ──────────────────

function SagTikMenuTemizle {
    Baslik "Sag Tik Menu Temizle (Context Menu Yonetimi)" "52"

    Write-Host ""
    Write-Host "  Windows sag tik menusunu temizler ve hizlandirir." -ForegroundColor Cyan
    Write-Host "  Win11 yeni menuyu eski klasik menuye donusturebilir." -ForegroundColor Cyan
    Write-Host ""

    # ── Win11 tespiti ──
    $win11 = $false
    try {
        $buildNo = [int](Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "CurrentBuildNumber" -ErrorAction SilentlyContinue).CurrentBuildNumber
        if ($buildNo -ge 22000) { $win11 = $true }
    } catch {}

    # ── 1) Win11 Menu Durumu ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  WINDOWS 11 SAG TIK MENUSU" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    if ($win11) {
        Write-Host "  Windows 11 tespit edildi (Build: $buildNo)" -ForegroundColor White

        # Klasik menu aktif mi?
        $klasikAktif = $false
        try {
            $clsidPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
            if (Test-Path $clsidPath) {
                $val = (Get-ItemProperty $clsidPath -Name "(Default)" -ErrorAction SilentlyContinue)."(Default)"
                if ($val -eq "" -or $null -eq $val) { $klasikAktif = $true }
            }
        } catch {}

        if ($klasikAktif) {
            Write-Host "  Sag Tik Menu  : " -ForegroundColor White -NoNewline
            Write-Host "KLASIK (eski Windows 10 stili)" -ForegroundColor Green
        } else {
            Write-Host "  Sag Tik Menu  : " -ForegroundColor White -NoNewline
            Write-Host "YENI (Win11 kisaltilmis menu)" -ForegroundColor Yellow
            Yaz "  IPUCU: Klasik menu daha hizli acilir ve tum secenekleri gosterir." Yellow
        }
    } else {
        Write-Host "  Windows 10 tespit edildi (Build: $buildNo)" -ForegroundColor White
        Write-Host "  Win10'da zaten klasik sag tik menusu kullaniliyor." -ForegroundColor Gray
    }
    Write-Host ""

    # ── 2) Shell Extension taramasi ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  SHELL EXTENSION (SAG TIK EKLENTILERI)" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    Yaz "  Sag tik menu eklentileri taranıyor..." Gray

    # Context menu handler'lari tara
    $shellYollar = @(
        "HKCR:\*\shellex\ContextMenuHandlers",
        "HKCR:\Directory\shellex\ContextMenuHandlers",
        "HKCR:\Directory\Background\shellex\ContextMenuHandlers",
        "HKCR:\Folder\shellex\ContextMenuHandlers",
        "HKCR:\Drive\shellex\ContextMenuHandlers"
    )

    # HKCR PSDrive olustur (yoksa)
    if (-not (Test-Path "HKCR:")) {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null
    }

    $eklentiler = @()
    foreach ($yol in $shellYollar) {
        if (-not (Test-Path $yol)) { continue }
        $anahtarlar = Get-ChildItem $yol -ErrorAction SilentlyContinue
        foreach ($anahtar in $anahtarlar) {
            $ad     = $anahtar.PSChildName
            $clsid  = (Get-ItemProperty $anahtar.PSPath -ErrorAction SilentlyContinue)."(Default)"
            $konum  = $yol -replace "HKCR:\\", ""

            # CLSID'den DLL yolunu bul
            $dllYol = ""
            if ($clsid -match '^\{.*\}$') {
                try {
                    $inprocPath = "HKCR:\CLSID\$clsid\InprocServer32"
                    if (Test-Path $inprocPath) {
                        $dllYol = (Get-ItemProperty $inprocPath -ErrorAction SilentlyContinue)."(Default)"
                    }
                } catch {}
            }

            # Bilinen Windows eklentisi mi?
            $winEklenti = $false
            $bilinen = @("CopyAsPathMenu","Sharing","WorkFolders","FileSyncShell","PintoStartScreen",
                         "OpenWith","SendTo","NewMenu","ShellExtInit","BriefcaseMenu","OfficeAddin")
            if ($bilinen -contains $ad -or $ad -like "*Windows*" -or $ad -like "*Microsoft*") {
                $winEklenti = $true
            }

            $eklentiler += @{
                Ad=$ad; CLSID=$clsid; Konum=$konum; DLL=$dllYol; Windows=$winEklenti
                Yol=$anahtar.PSPath
            }
        }
    }

    # Shell komutlari (static verb) tara
    $staticKomutlar = @()
    $staticYollar = @(
        "HKCR:\*\shell",
        "HKCR:\Directory\shell",
        "HKCR:\Directory\Background\shell"
    )
    foreach ($yol in $staticYollar) {
        if (-not (Test-Path $yol)) { continue }
        $komutlar = Get-ChildItem $yol -ErrorAction SilentlyContinue
        foreach ($cmd in $komutlar) {
            $ad = $cmd.PSChildName
            # Varsayilan Windows komutlarini atla
            $varsayilan = @("open","edit","print","printto","runas","explore","find","cmd",
                           "PowerShell","PowerShell7","WindowsTerminal","git_gui","git_shell")
            if ($varsayilan -contains $ad.ToLower()) { continue }

            $cmdLine = ""
            $cmdPath = Join-Path $cmd.PSPath "command"
            if (Test-Path $cmdPath) {
                $cmdLine = (Get-ItemProperty $cmdPath -ErrorAction SilentlyContinue)."(Default)"
            }

            $gorunurAd = (Get-ItemProperty $cmd.PSPath -ErrorAction SilentlyContinue)."(Default)"
            if (-not $gorunurAd) { $gorunurAd = "" }
            $muiVerb = (Get-ItemProperty $cmd.PSPath -ErrorAction SilentlyContinue).MUIVerb
            if ($muiVerb) { $gorunurAd = $muiVerb }

            $staticKomutlar += @{
                Ad=$ad; GorunurAd=$gorunurAd; Komut=$cmdLine; Yol=$cmd.PSPath
                Konum=($yol -replace "HKCR:\\","")
            }
        }
    }

    # Eklentileri goster
    $ucuncuParti = @($eklentiler | Where-Object { -not $_.Windows })
    $windowsEkl  = @($eklentiler | Where-Object { $_.Windows })

    if ($ucuncuParti.Count -gt 0) {
        Write-Host "  3. Parti Eklentiler ($($ucuncuParti.Count) adet):" -ForegroundColor Yellow
        $sira = 0
        foreach ($e in $ucuncuParti) {
            $sira++
            Write-Host ("    " + $sira.ToString().PadLeft(2) + "  " + $e.Ad) -ForegroundColor White
            if ($e.DLL) { Write-Host ("        DLL: " + $e.DLL) -ForegroundColor DarkGray }
        }
        Write-Host ""
    }

    if ($staticKomutlar.Count -gt 0) {
        Write-Host "  Ek Menu Komutlari ($($staticKomutlar.Count) adet):" -ForegroundColor Yellow
        foreach ($sc in $staticKomutlar) {
            $gAd = if ($sc.GorunurAd) { $sc.GorunurAd } else { $sc.Ad }
            Write-Host ("    " + $gAd) -ForegroundColor White -NoNewline
            Write-Host ("  [" + $sc.Konum + "]") -ForegroundColor DarkGray
        }
        Write-Host ""
    }

    Write-Host ("  Windows Eklentileri : " + $windowsEkl.Count) -ForegroundColor Gray
    Write-Host ("  3. Parti Eklentiler : " + $ucuncuParti.Count) -ForegroundColor $(if ($ucuncuParti.Count -gt 5) {"Yellow"} else {"Green"})
    Write-Host ("  Ek Komutlar         : " + $staticKomutlar.Count) -ForegroundColor Gray
    Write-Host ""

    # ── 3) Menu islemleri ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  ISLEMLER" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""
    if ($win11) {
        if ($klasikAktif) {
            Write-Host "  1  >  Win11 YENI menuye geri don" -ForegroundColor Gray
        } else {
            Write-Host "  1  >  Win11 KLASIK menu etkinlestir (onerilen)" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  1  >  (Win10 — menu degisimi yok)" -ForegroundColor DarkGray
    }
    Write-Host "  2  >  3. parti eklentileri devre disi birak" -ForegroundColor Gray
    Write-Host "  3  >  'Birlikte Ac' listesini temizle" -ForegroundColor Gray
    Write-Host "  4  >  'Gonder' menusunu temizle" -ForegroundColor Gray
    Write-Host "  5  >  'Yeni' menusunu temizle (gereksiz dosya tipleri)" -ForegroundColor Gray
    Write-Host "  6  >  Explorer'i yeniden baslat (degisiklikleri uygula)" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $secim = Read-Host

    switch ($secim.Trim()) {
        "1" {
            if (-not $win11) { Yaz "  Win10'da bu islem gecerli degil." DarkGray; return }

            $clsidPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
            if ($klasikAktif) {
                # Yeni menuye geri don
                Remove-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue
                Yaz "  Win11 yeni menu geri yuklendi." Green
            } else {
                # Klasik menuyu etkinlestir
                New-Item -Path $clsidPath -Force -ErrorAction SilentlyContinue | Out-Null
                Set-ItemProperty -Path $clsidPath -Name "(Default)" -Value "" -Force -ErrorAction SilentlyContinue
                Yaz "  Klasik sag tik menusu etkinlestirildi!" Green
            }
            Yaz "  Explorer yeniden baslatilacak..." Yellow
            Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            Start-Process explorer.exe
            Yaz "  Tamamlandi." Green
        }

        "2" {
            if ($ucuncuParti.Count -eq 0) {
                Yaz "  3. parti eklenti bulunamadi." DarkGray
                return
            }
            Write-Host ""
            Write-Host "  Hangileri devre disi birakilsin?" -ForegroundColor Yellow
            Write-Host "  T = Tumunu devre disi birak" -ForegroundColor Gray
            Write-Host "  Numara girin (virgul ile) veya 0 = iptal" -ForegroundColor Gray
            Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
            $cevap = Read-Host

            $hedefler = @()
            if ($cevap.Trim().ToUpper() -eq "T") {
                $hedefler = $ucuncuParti
            } elseif ($cevap.Trim() -ne "0") {
                $numaralar = $cevap.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' }
                foreach ($no in $numaralar) {
                    $idx = [int]$no - 1
                    if ($idx -ge 0 -and $idx -lt $ucuncuParti.Count) {
                        $hedefler += $ucuncuParti[$idx]
                    }
                }
            }

            $devreDisi = 0
            foreach ($h in $hedefler) {
                try {
                    # Eklentiyi yeniden adlandirarak devre disi birak (geri donulebilir)
                    $yeniAd = $h.Ad + "_DISABLED"
                    Rename-Item -Path $h.Yol -NewName $yeniAd -Force -ErrorAction Stop
                    Write-Host ("    " + $h.Ad + " -> devre disi") -ForegroundColor Green
                    $devreDisi++
                } catch {
                    Write-Host ("    " + $h.Ad + " -> basarisiz (yetki gerekli olabilir)") -ForegroundColor Red
                }
            }
            if ($devreDisi -gt 0) {
                Yaz ("  " + $devreDisi.ToString() + " eklenti devre disi birakildi.") Green
            }
        }

        "3" {
            # OpenWithList temizle
            Write-Host ""
            Yaz "  'Birlikte Ac' gecmisi temizleniyor..." Yellow
            $owYollar = @(
                "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts"
            )
            $temizlenen = 0
            foreach ($oyol in $owYollar) {
                if (-not (Test-Path $oyol)) { continue }
                $uzantilar = Get-ChildItem $oyol -ErrorAction SilentlyContinue
                foreach ($uz in $uzantilar) {
                    $owList = Join-Path $uz.PSPath "OpenWithList"
                    if (Test-Path $owList) {
                        $props = Get-ItemProperty $owList -ErrorAction SilentlyContinue
                        $degerler = $props.PSObject.Properties | Where-Object {
                            $_.Name -notlike "PS*" -and $_.Name -ne "MRUList" -and $_.Name -ne "(Default)"
                        }
                        if ($degerler.Count -gt 5) {
                            # 5'ten fazla kayit varsa ilk 3'u birak, gerisini sil
                            $temizlenen++
                        }
                    }
                }
            }

            # FileExts MRU temizle
            Remove-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU\*" -Force -ErrorAction SilentlyContinue

            Yaz "  'Birlikte Ac' gecmisi temizlendi." Green
        }

        "4" {
            # SendTo klasorunu temizle
            Write-Host ""
            $sendToYol = "$env:APPDATA\Microsoft\Windows\SendTo"
            $sendToItems = Get-ChildItem $sendToYol -ErrorAction SilentlyContinue

            if ($sendToItems.Count -gt 0) {
                Write-Host "  SendTo klasoru icerigi:" -ForegroundColor Cyan
                $stSira = 0
                foreach ($st in $sendToItems) {
                    $stSira++
                    Write-Host ("    " + $stSira.ToString().PadLeft(2) + "  " + $st.Name) -ForegroundColor Gray
                }
                Write-Host ""

                # Gereksiz olanlari tespit et
                $korunacak = @("Desktop (create shortcut).DeskLink","Mail Recipient.MAPIMail",
                               "Compressed (zipped) Folder.ZFSendToTarget","Documents.mydocs",
                               "Bluetooth")
                $gereksiz = @($sendToItems | Where-Object { $_.Name -notin $korunacak -and $_.Name -notlike "*.DeskLink" })

                if ($gereksiz.Count -gt 0) {
                    Yaz ("  " + $gereksiz.Count.ToString() + " gereksiz SendTo kisayolu bulundu.") Yellow
                    Write-Host "  Silinsin mi? (E/H): " -ForegroundColor Yellow -NoNewline
                    $cevap = Read-Host
                    if ($cevap.Trim().ToUpper() -eq "E") {
                        foreach ($g in $gereksiz) {
                            Remove-Item $g.FullName -Force -ErrorAction SilentlyContinue
                            Write-Host ("    Silindi: " + $g.Name) -ForegroundColor Green
                        }
                    }
                } else {
                    Yaz "  SendTo zaten temiz." Green
                }
            }
        }

        "5" {
            # Yeni menusundeki gereksiz dosya tiplerini temizle
            Write-Host ""
            Yaz "  'Yeni' menusundeki dosya tipleri taranıyor..." Gray

            $yeniMenuItems = @()
            $yeniYol = "HKCR:"
            if (-not (Test-Path "HKCR:")) {
                New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null
            }

            # Bilinen gereksiz "New" menu tipleri
            $gereksizTipler = @(
                ".bmp","BMP",
                ".contact","Kisi",
                ".rtf","Rich Text",
                ".zip","Sikistirilmis Klasor"
            )

            # Aktif "New" tiplerini tara
            $uzantilar = Get-ChildItem "HKCR:" -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -like ".*" }
            $yeniSayisi = 0
            foreach ($uz in $uzantilar) {
                $shellNewPath = Join-Path $uz.PSPath "ShellNew"
                if (Test-Path $shellNewPath) {
                    $yeniSayisi++
                    $yeniMenuItems += @{ Uzanti=$uz.PSChildName; Yol=$shellNewPath }
                }
            }

            Write-Host ("  'Yeni' menusunde " + $yeniSayisi.ToString() + " dosya tipi bulundu:") -ForegroundColor Cyan
            foreach ($ym in $yeniMenuItems) {
                Write-Host ("    " + $ym.Uzanti) -ForegroundColor Gray
            }
            Write-Host ""
            Yaz "  Ipucu: Gereksiz tipleri Denetim Masasi > Varsayilan Uygulamalar'dan yonetin." Gray
        }

        "6" {
            Yaz "  Explorer yeniden baslatiliyor..." Yellow
            Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            Start-Process explorer.exe
            Yaz "  Explorer yeniden baslatildi." Green
        }
    }

    Add-Content $LOG_DOSYA ("  Sag Tik Menu: Win11=$win11 | 3.parti=$($ucuncuParti.Count) | Komut=$($staticKomutlar.Count)")
    RaporVeriEkle "sag_tik_menu" @{ Win11=$win11; KlasikAktif=$(if($win11){$klasikAktif}else{$null}); UcuncuParti=$ucuncuParti.Count; Komut=$staticKomutlar.Count }
}

#endregion

#region ── MODUL 53: DNS BENCHMARK ──────────────────────────

function DNSBenchmark {
    Baslik "DNS Benchmark (En Hizli DNS'i Bul ve Uygula)" "53"

    Write-Host ""
    Write-Host "  Farkli DNS sunucularini test eder, en hizlisini bulur." -ForegroundColor Cyan
    Write-Host "  Dogru DNS secimi oyunlarda ping dusurur, sayfa acilisini hizlandirir." -ForegroundColor Cyan
    Write-Host ""

    # ── Mevcut DNS goster ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  MEVCUT DNS AYARLARI" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    $aktifAdapter = $null
    try {
        $adaptorler = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Up" }
        foreach ($adp in $adaptorler) {
            $dns = Get-DnsClientServerAddress -InterfaceIndex $adp.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            $dnsAdr = $dns.ServerAddresses
            Write-Host ("  " + $adp.Name + " (" + $adp.InterfaceDescription + ")") -ForegroundColor White
            if ($dnsAdr -and $dnsAdr.Count -gt 0) {
                $dnsStr = $dnsAdr -join ", "
                # Bilinen DNS adi
                $dnsAdi = switch ($dnsAdr[0]) {
                    "1.1.1.1"       { "Cloudflare" }
                    "1.0.0.1"       { "Cloudflare" }
                    "8.8.8.8"       { "Google" }
                    "8.8.4.4"       { "Google" }
                    "9.9.9.9"       { "Quad9" }
                    "208.67.222.222" { "OpenDNS" }
                    "94.140.14.14"  { "AdGuard" }
                    "76.76.2.0"     { "Control D" }
                    "185.228.168.9" { "CleanBrowsing" }
                    default         { "" }
                }
                Write-Host ("    DNS: " + $dnsStr + $(if ($dnsAdi) { " ($dnsAdi)" } else { "" })) -ForegroundColor Cyan
            } else {
                Write-Host "    DNS: Otomatik (DHCP)" -ForegroundColor Yellow
            }
            if (-not $aktifAdapter) { $aktifAdapter = $adp }
        }
    } catch {
        Yaz "  Ag adaptoru bilgisi alinamadi." Red
    }
    Write-Host ""

    # ── DNS sunucu listesi ──
    $dnsSunucular = @(
        @{ Ad="Cloudflare";       IP="1.1.1.1";         IP2="1.0.0.1";         Aciklama="En hizli, gizlilik odakli" },
        @{ Ad="Google";           IP="8.8.8.8";         IP2="8.8.4.4";         Aciklama="Genis coverage, stabil" },
        @{ Ad="Quad9";            IP="9.9.9.9";         IP2="149.112.112.112"; Aciklama="Guvenlik odakli, malware engel" },
        @{ Ad="OpenDNS";          IP="208.67.222.222";  IP2="208.67.220.220";  Aciklama="Cisco, icerik filtreleme" },
        @{ Ad="AdGuard";          IP="94.140.14.14";    IP2="94.140.15.15";    Aciklama="Reklam engelleyici DNS" },
        @{ Ad="Control D";        IP="76.76.2.0";       IP2="76.76.10.0";      Aciklama="Ozellestirebilir filtreleme" },
        @{ Ad="CleanBrowsing";    IP="185.228.168.9";   IP2="185.228.169.9";   Aciklama="Aile guvenli filtreleme" },
        @{ Ad="Comodo Secure";    IP="8.26.56.26";      IP2="8.20.247.20";     Aciklama="Guvenlik + performans" },
        @{ Ad="Level3";           IP="4.2.2.1";         IP2="4.2.2.2";         Aciklama="ISP seviyesi, dusuk latency" },
        @{ Ad="Yandex";           IP="77.88.8.8";       IP2="77.88.8.1";       Aciklama="Rusya merkezli, hizli EU" },
        @{ Ad="Neustar";          IP="64.6.64.6";       IP2="64.6.65.6";       Aciklama="Guvenlik + hiz" },
        @{ Ad="DNS.WATCH";        IP="84.200.69.80";    IP2="84.200.70.40";    Aciklama="Almanya, log tutmaz" }
    )

    # ── Benchmark baslat ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  DNS HIZ TESTI (12 sunucu)" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    # Test domainleri — cozumlenecek alan adlari
    $testDomainler = @("google.com","youtube.com","facebook.com","cloudflare.com","amazon.com")

    Yaz "  Test basliyor... (her sunucu 5 domain cozumluyor)" Gray
    Write-Host ""

    Write-Host ("  {0,-18} {1,8} {2,8} {3,8} {4,8}  {5}" -f "DNS Sunucu","Min","Ort","Max","Kayip","Sonuc") -ForegroundColor DarkGray
    Write-Host ("  " + ("-" * 72)) -ForegroundColor DarkGray

    $sonuclar = @()

    foreach ($dns in $dnsSunucular) {
        $sureler  = @()
        $basarili = 0
        $basarisiz = 0

        foreach ($domain in $testDomainler) {
            try {
                $sw = [System.Diagnostics.Stopwatch]::StartNew()
                $result = Resolve-DnsName -Name $domain -Server $dns.IP -Type A -DnsOnly -ErrorAction Stop | Select-Object -First 1
                $sw.Stop()
                $sureler += $sw.ElapsedMilliseconds
                $basarili++
            } catch {
                $basarisiz++
            }
        }

        if ($sureler.Count -gt 0) {
            $minMs = [math]::Round(($sureler | Measure-Object -Minimum).Minimum, 0)
            $ortMs = [math]::Round(($sureler | Measure-Object -Average).Average, 0)
            $maxMs = [math]::Round(($sureler | Measure-Object -Maximum).Maximum, 0)
            $kayip = $basarisiz

            $renk = if ($ortMs -le 20) { "Green" } elseif ($ortMs -le 50) { "Yellow" } elseif ($ortMs -le 100) { "White" } else { "Red" }
            $yildiz = if ($ortMs -le 20) { "***" } elseif ($ortMs -le 35) { "** " } elseif ($ortMs -le 60) { "*  " } else { "   " }

            Write-Host ("  {0,-18} {1,6}ms {2,6}ms {3,6}ms {4,5}    {5}" -f $dns.Ad, $minMs, $ortMs, $maxMs, $kayip, $yildiz) -ForegroundColor $renk

            $sonuclar += @{
                Ad=$dns.Ad; IP=$dns.IP; IP2=$dns.IP2; OrtMs=$ortMs; MinMs=$minMs; MaxMs=$maxMs
                Kayip=$kayip; Aciklama=$dns.Aciklama
            }
        } else {
            Write-Host ("  {0,-18} {1}" -f $dns.Ad, "YANIT YOK (zaman asimi)") -ForegroundColor Red
        }
    }

    Write-Host ""

    # ── En iyi 3 ──
    if ($sonuclar.Count -eq 0) {
        Yaz "  Hicbir DNS sunucusundan yanit alinamadi. Internet baglantinizi kontrol edin." Red
        return
    }

    $enIyiler = $sonuclar | Sort-Object { $_.OrtMs } | Select-Object -First 3
    $enIyi    = $enIyiler[0]

    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  EN HIZLI 3 DNS" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""

    $sira = 0
    foreach ($ei in $enIyiler) {
        $sira++
        $madalya = switch ($sira) { 1 { "1." } 2 { "2." } 3 { "3." } }
        $renk    = switch ($sira) { 1 { "Green" } 2 { "Yellow" } 3 { "White" } }
        Write-Host ("  " + $madalya + "  " + $ei.Ad + " (" + $ei.IP + ")") -ForegroundColor $renk
        Write-Host ("       Ortalama: " + $ei.OrtMs + "ms | Min: " + $ei.MinMs + "ms | " + $ei.Aciklama) -ForegroundColor Gray
    }
    Write-Host ""

    # Mevcut DNS ile karsilastir
    $mevcutDnsAdr = $null
    if ($aktifAdapter) {
        try {
            $md = Get-DnsClientServerAddress -InterfaceIndex $aktifAdapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            $mevcutDnsAdr = $md.ServerAddresses | Select-Object -First 1
        } catch {}
    }
    if ($mevcutDnsAdr) {
        $mevcutSonuc = $sonuclar | Where-Object { $_.IP -eq $mevcutDnsAdr } | Select-Object -First 1
        if ($mevcutSonuc) {
            $fark = $mevcutSonuc.OrtMs - $enIyi.OrtMs
            if ($fark -gt 5) {
                Yaz ("  Mevcut DNS'iniz (" + $mevcutSonuc.Ad + ": " + $mevcutSonuc.OrtMs + "ms) en hizlidan " + $fark + "ms yavas!") Yellow
            } else {
                Yaz ("  Mevcut DNS'iniz (" + $mevcutSonuc.Ad + ") zaten en hizlilardan biri.") Green
            }
        }
    }
    Write-Host ""

    # ── Islem menu ──
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host "  ISLEMLER" -ForegroundColor Yellow
    Write-Host "  ================================================" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host ("  1  >  En hizliyi uygula: " + $enIyi.Ad + " (" + $enIyi.IP + " / " + $enIyi.IP2 + ")") -ForegroundColor Cyan
    Write-Host "  2  >  Listeden sec ve uygula" -ForegroundColor Gray
    Write-Host "  3  >  Manuel DNS gir" -ForegroundColor Gray
    Write-Host "  4  >  DNS'i otomatik (DHCP) yap" -ForegroundColor Gray
    Write-Host "  5  >  DNS cache temizle (ipconfig /flushdns)" -ForegroundColor Gray
    Write-Host "  0  >  Geri" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $secim = Read-Host

    switch ($secim.Trim()) {
        "1" {
            if (-not $aktifAdapter) { Yaz "  Aktif ag adaptoru bulunamadi." Red; return }
            try {
                Set-DnsClientServerAddress -InterfaceIndex $aktifAdapter.InterfaceIndex -ServerAddresses @($enIyi.IP, $enIyi.IP2) -ErrorAction Stop
                Yaz ("  DNS ayarlandi: " + $enIyi.Ad + " (" + $enIyi.IP + ", " + $enIyi.IP2 + ")") Green
                # DNS cache temizle
                Clear-DnsClientCache -ErrorAction SilentlyContinue
                Yaz "  DNS cache temizlendi." Green
            } catch {
                Yaz "  DNS ayarlanamadi. Yonetici yetkisi gerekebilir." Red
            }
        }

        "2" {
            Write-Host ""
            $lSira = 0
            foreach ($s in ($sonuclar | Sort-Object { $_.OrtMs })) {
                $lSira++
                Write-Host ("    " + $lSira.ToString().PadLeft(2) + "  " + $s.Ad.PadRight(18) + " " + $s.OrtMs.ToString() + "ms  (" + $s.IP + ")") -ForegroundColor Gray
            }
            Write-Host ""
            Write-Host "  Numara girin: " -ForegroundColor Yellow -NoNewline
            $no = Read-Host
            $idx = 0
            if ([int]::TryParse($no.Trim(), [ref]$idx) -and $idx -ge 1 -and $idx -le $sonuclar.Count) {
                $secilen = ($sonuclar | Sort-Object { $_.OrtMs })[$idx - 1]
                try {
                    Set-DnsClientServerAddress -InterfaceIndex $aktifAdapter.InterfaceIndex -ServerAddresses @($secilen.IP, $secilen.IP2) -ErrorAction Stop
                    Yaz ("  DNS ayarlandi: " + $secilen.Ad + " (" + $secilen.IP + ", " + $secilen.IP2 + ")") Green
                    Clear-DnsClientCache -ErrorAction SilentlyContinue
                    Yaz "  DNS cache temizlendi." Green
                } catch {
                    Yaz "  DNS ayarlanamadi." Red
                }
            }
        }

        "3" {
            Write-Host ""
            Write-Host "  Birincil DNS: " -ForegroundColor Yellow -NoNewline
            $dns1 = Read-Host
            Write-Host "  Ikincil DNS : " -ForegroundColor Yellow -NoNewline
            $dns2 = Read-Host
            if ($dns1.Trim() -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') {
                $adrler = @($dns1.Trim())
                if ($dns2.Trim() -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') { $adrler += $dns2.Trim() }
                try {
                    Set-DnsClientServerAddress -InterfaceIndex $aktifAdapter.InterfaceIndex -ServerAddresses $adrler -ErrorAction Stop
                    Yaz ("  DNS ayarlandi: " + ($adrler -join ", ")) Green
                    Clear-DnsClientCache -ErrorAction SilentlyContinue
                } catch {
                    Yaz "  DNS ayarlanamadi." Red
                }
            } else {
                Yaz "  Gecersiz IP adresi." Red
            }
        }

        "4" {
            if (-not $aktifAdapter) { Yaz "  Aktif adaptor bulunamadi." Red; return }
            try {
                Set-DnsClientServerAddress -InterfaceIndex $aktifAdapter.InterfaceIndex -ResetServerAddresses -ErrorAction Stop
                Yaz "  DNS otomatik (DHCP) ayarlandi." Green
                Clear-DnsClientCache -ErrorAction SilentlyContinue
            } catch {
                Yaz "  Ayarlanamadi." Red
            }
        }

        "5" {
            Clear-DnsClientCache -ErrorAction SilentlyContinue
            ipconfig /flushdns 2>$null | Out-Null
            Yaz "  DNS cache temizlendi." Green
        }
    }

    Add-Content $LOG_DOSYA ("  DNS Benchmark: En iyi=" + $enIyi.Ad + " (" + $enIyi.OrtMs + "ms)")
    RaporVeriEkle "dns_benchmark" @{ EnIyi=$enIyi.Ad; OrtMs=$enIyi.OrtMs; IP=$enIyi.IP; TestSayi=$sonuclar.Count }
}

function WiFiCihazTarama {
    Baslik "MODUL 54 - WiFi Ag Taramasi"

    # 1. WiFi baglanti bilgileri
    Yaz "  [1/3] WiFi baglanti bilgileri aliniyor..." Cyan
    $wifiRaw = netsh wlan show interfaces 2>$null
    $wifiBagli = $false
    if ($wifiRaw) {
        $ssid = ""; $sinyal = ""; $guvenlik = ""; $bant = ""; $kanal = ""; $hiz = ""
        foreach ($line in $wifiRaw) {
            if ($line -match '^\s+SSID\s*:\s*(.+)' -and -not $line.Contains("BSSID")) { $ssid = $Matches[1].Trim() }
            if ($line -match 'Signal\s*:\s*(.+)') { $sinyal = $Matches[1].Trim() }
            if ($line -match 'Authentication\s*:\s*(.+)') { $guvenlik = $Matches[1].Trim() }
            if ($line -match 'Band\s*:\s*(.+)') { $bant = $Matches[1].Trim() }
            if ($line -match 'Channel\s*:\s*(.+)') { $kanal = $Matches[1].Trim() }
            if ($line -match 'Receive rate\s*:\s*(.+)') { $hiz = $Matches[1].Trim() }
        }
        if ($ssid) {
            $wifiBagli = $true
            Yaz ("  Ag Adi (SSID)    : " + $ssid) White
            if ($sinyal) {
                $sinyalRenk = if ([int]($sinyal -replace '%','') -ge 70) { "Green" } elseif ([int]($sinyal -replace '%','') -ge 40) { "Yellow" } else { "Red" }
                Yaz ("  Sinyal Gucu      : " + $sinyal) $sinyalRenk
            }
            if ($guvenlik) { Yaz ("  Guvenlik         : " + $guvenlik) White }
            if ($bant)     { Yaz ("  Frekans Bandi    : " + $bant) White }
            if ($kanal)    { Yaz ("  Kanal            : " + $kanal) White }
            if ($hiz)      { Yaz ("  Baglanti Hizi    : " + $hiz) White }
        } else {
            Yaz "  WiFi'ye bagli degil veya Ethernet kullaniliyor." Yellow
        }
    } else {
        Yaz "  WiFi adaptoru bulunamadi." Yellow
    }

    # 2. Yerel ag bilgileri
    Write-Host ""
    Yaz "  [2/3] Yerel ag bilgileri..." Cyan
    $agYapilandirma = Get-NetIPConfiguration -ErrorAction SilentlyContinue | Where-Object { $_.IPv4DefaultGateway } | Select-Object -First 1
    if (-not $agYapilandirma) {
        Yaz "  Aktif ag baglantisi bulunamadi!" Red
        return
    }
    $benimIP   = $agYapilandirma.IPv4Address.IPAddress
    $agGecidi  = $agYapilandirma.IPv4DefaultGateway.NextHop
    $adaptorAd = $agYapilandirma.InterfaceAlias
    Yaz ("  Adaptor          : " + $adaptorAd) White
    Yaz ("  IP Adresiniz     : " + $benimIP) Green
    Yaz ("  Ag Gecidi/Modem  : " + $agGecidi) Cyan

    $parcalar = $benimIP.Split('.')
    $altAg    = $parcalar[0] + "." + $parcalar[1] + "." + $parcalar[2]

    # 3. Ag taramasi
    Write-Host ""
    Yaz "  [3/3] Agdaki cihazlar taraniyor..." Cyan
    Yaz "  Hizli tarama baslatildi (10-20 saniye)..." Yellow

    # Paralel ping ile ARP tablosunu doldur
    $pingScript = {
        param([string]$hedef)
        try {
            $p = New-Object System.Net.NetworkInformation.Ping
            $p.Send($hedef, 800) | Out-Null
            $p.Dispose()
        } catch {}
    }

    $havuz = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, 64)
    $havuz.Open()
    $isler = [System.Collections.ArrayList]::new()

    for ($i = 1; $i -le 254; $i++) {
        $hedefIP = "$altAg.$i"
        $ps = [PowerShell]::Create().AddScript($pingScript).AddArgument($hedefIP)
        $ps.RunspacePool = $havuz
        [void]$isler.Add(@{ PS = $ps; Sonuc = $ps.BeginInvoke() })
    }

    # Bekle (max 15 sn)
    $bitis = (Get-Date).AddSeconds(15)
    while (($isler | Where-Object { -not $_.Sonuc.IsCompleted }).Count -gt 0) {
        if ((Get-Date) -gt $bitis) { break }
        Start-Sleep -Milliseconds 300
    }
    foreach ($is in $isler) {
        try { if ($is.Sonuc.IsCompleted) { $is.PS.EndInvoke($is.Sonuc) | Out-Null } } catch {}
        $is.PS.Dispose()
    }
    $havuz.Close(); $havuz.Dispose()

    # ARP tablosunu oku
    $arpSatirlar = arp -a
    $cihazlar = [System.Collections.ArrayList]::new()

    foreach ($satir in $arpSatirlar) {
        if ($satir -match '^\s+(\d+\.\d+\.\d+\.\d+)\s+([\w-]{17})\s+(\w+)') {
            $cIP   = $Matches[1]
            $cMAC  = $Matches[2].ToUpper()
            $cTur  = $Matches[3]

            if ($cMAC -eq 'FF-FF-FF-FF-FF-FF') { continue }
            if ($cIP -notmatch ("^" + [regex]::Escape($altAg) + "\.")) { continue }

            [void]$cihazlar.Add(@{ IP = $cIP; MAC = $cMAC; Tur = $cTur })
        }
    }

    # Sirala
    $cihazlar = $cihazlar | Sort-Object { $ipParts = $_.IP.Split('.'); [int]$ipParts[3] }

    # Uretici veritabani (MAC ilk 3 byte)
    function MACUretici([string]$mac) {
        $on6 = ($mac -replace '-','').Substring(0,6).ToUpper()
        $db = @{
            "Apple"    = "DC71C5|A4B197|3C06A7|AC1F74|F0B479|78CA39|B8E856|D4619D|4C57CA|F0D1A9|A860B6|14BD61|F8FF"
            "Samsung"  = "00224D|A4C494|28395E|F8D0BD|9C3A0A|C45006|BC7280|E4FAED|842E27|8C7712|CCB11A|78D6F0"
            "Xiaomi"   = "8C1645|7C1DD9|78110B|286C07|50EC50|640980|F4F5DB|9C9D7E|28E31F|64CC2E|2C3361"
            "Intel"    = "D0D2B0|1C6F65|803F5D|F81654|181DEA|FC3497|7C5CF8|8086F2|A4BB6D|48A472|3497F6"
            "Realtek"  = "00E04C|52540|808643|00E04C|B04E26"
            "TP-Link"  = "B0BE76|EC086B|503EAA|14CC20|A42BB0|6466B3|D46E0E|C4E984|F8D111|60A4B7|B09575|5C628B"
            "Huawei"   = "9C2A70|004E01|E0CB4E|5C7D5E|C8D15E|48DB50|8018A7|7C6097"
            "ASUS"     = "3C7C3F|2C4D54|B06EBF|049226|1CBFCE|708BCD|D850E6"
            "D-Link"   = "B4FBE4|001E58|001CF0|7054D2|1CAFF7|28107B"
            "Netgear"  = "001F1F|C03F0E|6CB0CE|A021B7|B07FB9|A42B8C"
            "LG"       = "38F9D3|001E75|CC2D8C|10F96F|A8E544"
            "Monster"  = "60458A|288023"
            "Google"   = "FC4596|D89695|B047BF|3C5AB4|F4F5E8"
            "Oppo"     = "5CE91E|887F03|A44519"
            "Lenovo"   = "28D244|E8F724|50EBF6|F0038C|8CEC4B"
            "HP"       = "10604B|94577A|B499BA|F860F0|2C768A"
            "Dell"     = "F8DB88|B8CA3A|001A4D|34E6D7|509A4C"
            "MSI"      = "00D861|4CEB42|0017F2"
        }
        foreach ($marka in $db.Keys) {
            foreach ($pre in $db[$marka].Split('|')) {
                if ($on6.StartsWith($pre)) { return $marka }
            }
        }
        return "Bilinmiyor"
    }

    # Sonuclari goster
    Write-Host ""
    Write-Host ("  {0,-4} {1,-16} {2,-20} {3,-10} {4,-14} {5}" -f "#", "IP Adresi", "MAC Adresi", "Durum", "Uretici", "Aciklama") -ForegroundColor Cyan
    Write-Host ("  " + ("-" * 78)) -ForegroundColor DarkGray

    $sayac = 0
    foreach ($c in $cihazlar) {
        $sayac++
        $uretici = MACUretici $c.MAC
        $durum   = if ($c.Tur -eq 'dynamic') { "Aktif" } else { "Sabit" }

        $aciklama = ""
        $renk     = "White"
        if ($c.IP -eq $benimIP)  { $aciklama = ">> BU PC";      $renk = "Green" }
        elseif ($c.IP -eq $agGecidi) { $aciklama = ">> MODEM"; $renk = "Cyan" }

        Write-Host ("  {0,-4} {1,-16} {2,-20} {3,-10} {4,-14} {5}" -f $sayac, $c.IP, $c.MAC, $durum, $uretici, $aciklama) -ForegroundColor $renk
    }

    Write-Host ("  " + ("-" * 78)) -ForegroundColor DarkGray
    Write-Host ""
    $digerCihaz = $sayac - 2
    if ($digerCihaz -lt 0) { $digerCihaz = 0 }
    Yaz ("  Toplam " + $sayac + " cihaz bulundu (sizin disinda " + $digerCihaz + " cihaz bagli)") Green

    if ($digerCihaz -gt 10) {
        Write-Host ""
        Yaz "  UYARI: Agda cok fazla cihaz tespit edildi!" Yellow
        Yaz "  Tanimadiginiz cihazlar varsa:" Yellow
        Yaz ("    - Modem yonetim panelini acin (tarayicida " + $agGecidi + ")") White
        Yaz "    - WiFi sifrenizi degistirin" White
        Yaz "    - MAC filtreleme aktif edin" White
    }

    if ($wifiBagli -and $guvenlik -and $guvenlik -notmatch 'WPA3|WPA2') {
        Write-Host ""
        Yaz "  GUVENLIK: WiFi guvenlik protokolunuz eski!" Red
        Yaz ("  Mevcut: " + $guvenlik + " | Onerilen: WPA2 veya WPA3") Yellow
    }

    Add-Content $LOG_DOSYA ("  WiFi Tarama: " + $sayac + " cihaz bulundu, SSID=" + $ssid)
}

#endregion

#region ── MODUL 55: BOS KLASOR BULUCU ──────────────────────

function BosKlasorBulucu {
    Baslik "Bos Klasor Bulucu" "55"

    $taramaYollari = @(
        $env:USERPROFILE
        "C:\Temp"
        "C:\Users\Public"
        (Join-Path $env:LOCALAPPDATA "Temp")
        (Join-Path $env:APPDATA "")
    )

    # Korunacak klasorler (sistem/gizli/kritik)
    $korunanlar = @(
        "$env:USERPROFILE\.ssh"
        "$env:USERPROFILE\.gnupg"
        "$env:APPDATA\Microsoft"
        "$env:LOCALAPPDATA\Microsoft"
        "C:\Windows"
        "C:\Program Files"
        "C:\Program Files (x86)"
        "$env:USERPROFILE\AppData\Local\Packages"
    )

    Yaz "  Tarama baslatiliyor..." Cyan
    $boslar = [System.Collections.Generic.List[string]]::new()
    $taranan = 0

    foreach ($kok in $taramaYollari) {
        if (-not (Test-Path $kok)) { continue }
        $klasorler = Get-ChildItem -Path $kok -Directory -Recurse -Force -ErrorAction SilentlyContinue
        foreach ($k in $klasorler) {
            $taranan++
            # Korunan yol kontrolu
            $korumali = $false
            foreach ($ky in $korunanlar) {
                $genisKY = [Environment]::ExpandEnvironmentVariables($ky)
                if ($k.FullName -like "$genisKY*") { $korumali = $true; break }
            }
            if ($korumali) { continue }

            # Bos mu? (dosya ve alt klasor yok)
            $icerik = Get-ChildItem -Path $k.FullName -Force -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $icerik) {
                $boslar.Add($k.FullName)
            }
        }
    }

    Durum "Taranan klasor" $taranan.ToString() Cyan
    Durum "Bos klasor" $boslar.Count.ToString() Yellow

    if ($boslar.Count -eq 0) {
        Yaz "  Bos klasor bulunamadi. Temiz!" Green
        return
    }

    Write-Host ""
    $gosterilenMax = [Math]::Min($boslar.Count, 30)
    for ($i = 0; $i -lt $gosterilenMax; $i++) {
        $goreceli = $boslar[$i].Replace($env:USERPROFILE, "~")
        Write-Host ("    [{0,3}]  {1}" -f ($i+1), $goreceli) -ForegroundColor DarkGray
    }
    if ($boslar.Count -gt 30) {
        Yaz ("  ... ve {0} klasor daha" -f ($boslar.Count - 30)) DarkGray
    }

    Write-Host ""
    if (Onay ("{0} bos klasor silinsin mi?" -f $boslar.Count)) {
        $silinen = 0
        foreach ($yol in $boslar) {
            try {
                Remove-Item -Path $yol -Force -ErrorAction Stop
                $silinen++
            } catch { }
        }
        Yaz ("  {0}/{1} bos klasor silindi." -f $silinen, $boslar.Count) Green
    }
}

#endregion

#region ── MODUL 56: DOSYA KIRPICI (SHREDDER) ───────────────

function DosyaKirpici {
    Baslik "Guvenli Dosya Kirpici (Shredder)" "56"

    Yaz "  Bu modul dosyalari kurtarilamaz sekilde imha eder." Yellow
    Yaz "  Yontem: 3 gecis (rastgele + sifir + rastgele) + sil" Gray
    Write-Host ""

    if ($env:SISTEMBAK_GUI -eq '1') {
        Yaz "  GUI modunda: Dosya yolunu log penceresinden okuyun." Cyan
        Yaz "  CLI'dan kullanmak icin konsol surumunu tercih edin." Gray
        return
    }

    Write-Host "  Kirpilacak dosya/klasor yolu: " -ForegroundColor Yellow -NoNewline
    $hedefYol = (Read-Host).Trim().Trim('"')

    if (-not (Test-Path $hedefYol)) {
        Yaz "  HATA: Belirtilen yol bulunamadi!" Red
        return
    }

    # Dosya listesi olustur
    $dosyalar = if ((Get-Item $hedefYol).PSIsContainer) {
        Get-ChildItem -Path $hedefYol -File -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        @(Get-Item $hedefYol)
    }

    if ($dosyalar.Count -eq 0) {
        Yaz "  Kirpilacak dosya bulunamadi." Yellow
        return
    }

    $topBoyut = ($dosyalar | Measure-Object Length -Sum).Sum
    Durum "Dosya sayisi" $dosyalar.Count.ToString() Yellow
    Durum "Toplam boyut" (BoyutFormatla $topBoyut) Yellow

    if (-not (Onay "Bu dosyalar KALICI olarak imha edilecek. Emin misiniz?")) { return }

    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
    $tampon = New-Object byte[] 65536  # 64KB tampon

    $sayac = 0
    foreach ($dosya in $dosyalar) {
        try {
            $boyut = $dosya.Length
            if ($boyut -eq 0) { Remove-Item $dosya.FullName -Force; $sayac++; continue }

            $fs = [System.IO.File]::Open($dosya.FullName, 'Open', 'Write')
            # 3 gecis overwrite
            for ($gecis = 0; $gecis -lt 3; $gecis++) {
                $fs.Position = 0
                $kalan = $boyut
                while ($kalan -gt 0) {
                    $yazilacak = [Math]::Min($kalan, $tampon.Length)
                    if ($gecis -eq 1) {
                        [Array]::Clear($tampon, 0, $yazilacak)  # Gecis 2: sifirlar
                    } else {
                        $rng.GetBytes($tampon)  # Gecis 1,3: rastgele
                    }
                    $fs.Write($tampon, 0, $yazilacak)
                    $kalan -= $yazilacak
                }
                $fs.Flush()
            }
            $fs.Close()

            # Dosya adini rastgele yeniden adlandir, sonra sil
            $rastgeleAd = Join-Path $dosya.DirectoryName ([System.IO.Path]::GetRandomFileName())
            [System.IO.File]::Move($dosya.FullName, $rastgeleAd)
            [System.IO.File]::Delete($rastgeleAd)
            $sayac++
        } catch {
            Yaz ("  Atlandi: " + $dosya.Name + " (" + $_.Exception.Message + ")") DarkGray
        }
    }

    $rng.Dispose()

    # Eger klasorse, bos kalan klasorleri de sil
    if ((Get-Item $hedefYol -ErrorAction SilentlyContinue).PSIsContainer) {
        Get-ChildItem $hedefYol -Directory -Recurse -Force -ErrorAction SilentlyContinue |
            Sort-Object { $_.FullName.Length } -Descending |
            ForEach-Object { Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue }
        Remove-Item $hedefYol -Force -ErrorAction SilentlyContinue
    }

    Yaz ("  {0}/{1} dosya guvenli sekilde imha edildi." -f $sayac, $dosyalar.Count) Green
}

#endregion

#region ── MODUL 57: USB CIHAZ GECMISI ──────────────────────

function USBCihazGecmisi {
    Baslik "USB Cihaz Gecmisi" "57"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    $regYol = "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR"
    if (-not (Test-Path $regYol)) {
        Yaz "  USB kayit defteri yolu bulunamadi." Yellow
        return
    }

    $cihazlar = [System.Collections.Generic.List[PSCustomObject]]::new()
    $altAnahtarlar = Get-ChildItem -Path $regYol -ErrorAction SilentlyContinue

    foreach ($anahtar in $altAnahtarlar) {
        $seriNoAnahtarlari = Get-ChildItem -Path $anahtar.PSPath -ErrorAction SilentlyContinue
        foreach ($seri in $seriNoAnahtarlari) {
            $props = Get-ItemProperty -Path $seri.PSPath -ErrorAction SilentlyContinue
            $dostu = if ($props.FriendlyName) { $props.FriendlyName } else { $anahtar.PSChildName }
            $sinif = if ($props.Class) { $props.Class } else { "Bilinmiyor" }

            # Son baglanti zamani (varsa)
            $sonBaglanti = $null
            try {
                $logYol = "HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR\$($anahtar.PSChildName)\$($seri.PSChildName)\Properties\{83da6326-97a6-4088-9453-a1923f573b29}\0066"
                if (Test-Path $logYol) {
                    $veri = (Get-ItemProperty $logYol -ErrorAction SilentlyContinue).'(default)'
                    if ($veri -is [byte[]]) {
                        $ft = [BitConverter]::ToInt64($veri, 0)
                        $sonBaglanti = [DateTime]::FromFileTime($ft)
                    }
                }
            } catch {}

            $cihazlar.Add([PSCustomObject]@{
                Ad         = $dostu
                Sinif      = $sinif
                SeriNo     = $seri.PSChildName
                SonBaglanti = $sonBaglanti
            })
        }
    }

    if ($cihazlar.Count -eq 0) {
        Yaz "  Kayitli USB cihaz bulunamadi." Green
        return
    }

    Durum "Kayitli USB cihaz" $cihazlar.Count.ToString() Yellow
    Write-Host ""

    foreach ($c in $cihazlar) {
        $zamanStr = if ($c.SonBaglanti) { $c.SonBaglanti.ToString("dd.MM.yyyy HH:mm") } else { "?" }
        $ad = $c.Ad
        if ($ad.Length -gt 40) { $ad = $ad.Substring(0, 37) + "..." }
        Write-Host ("    {0,-40}  {1,-12}  {2}" -f $ad, $zamanStr, $c.SeriNo.Substring(0, [Math]::Min(16, $c.SeriNo.Length))) -ForegroundColor Gray
    }

    Write-Host ""
    if (Onay "USB cihaz gecmisi temizlensin mi? (registry kayitlari silinir)") {
        $silinen = 0
        foreach ($anahtar in $altAnahtarlar) {
            try {
                Remove-Item -Path $anahtar.PSPath -Recurse -Force -ErrorAction Stop
                $silinen++
            } catch {
                Yaz ("  Silinemedi: " + $anahtar.PSChildName) DarkGray
            }
        }
        # SetupAPI logunu da temizle
        $setupLog = "C:\Windows\INF\setupapi.dev.log"
        if (Test-Path $setupLog) {
            try { Clear-Content $setupLog -Force -ErrorAction Stop } catch {}
        }
        Yaz ("  {0} USB kaydi temizlendi." -f $silinen) Green
    }
}

#endregion

#region ── MODUL 58: HOSTS DOSYASI EDITORU ──────────────────

function HostsDosyasiEditoru {
    Baslik "Hosts Dosyasi Editoru" "58"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    $hostsYol = "C:\Windows\System32\drivers\etc\hosts"
    if (-not (Test-Path $hostsYol)) {
        Yaz "  hosts dosyasi bulunamadi!" Red
        return
    }

    $icerik = Get-Content $hostsYol -ErrorAction SilentlyContinue
    $mevcutSatir = ($icerik | Where-Object { $_ -match '^\s*0\.0\.0\.0\s' -or $_ -match '^\s*127\.0\.0\.1\s' }).Count
    $topSatir = $icerik.Count

    Durum "hosts dosyasi" $hostsYol Gray
    Durum "Toplam satir" $topSatir.ToString() Cyan
    Durum "Aktif engel" $mevcutSatir.ToString() Yellow

    # Hazir reklam/tracker listesi (en yaygin 80 domain)
    $engelListesi = @(
        # Reklam aglari
        "ad.doubleclick.net","adclick.g.doubleclick.net","ads.google.com",
        "adservice.google.com","pagead2.googlesyndication.com",
        "googleads.g.doubleclick.net","tpc.googlesyndication.com",
        "ad.lgappstv.com","ads.yahoo.com","ads.facebook.com",
        "pixel.facebook.com","an.facebook.com",
        # Tracker/analitik
        "analytics.google.com","www.google-analytics.com",
        "ssl.google-analytics.com","google-analytics.com",
        "sb.scorecardresearch.com","b.scorecardresearch.com",
        "pixel.quantserve.com","edge.quantserve.com",
        "stats.wp.com","pixel.wp.com",
        # Telemetri (Windows)
        "vortex.data.microsoft.com","vortex-win.data.microsoft.com",
        "telecommand.telemetry.microsoft.com",
        "telecommand.telemetry.microsoft.com.nsatc.net",
        "oca.telemetry.microsoft.com","sqm.telemetry.microsoft.com",
        "watson.telemetry.microsoft.com","redir.metaservices.microsoft.com",
        "settings-sandbox.data.microsoft.com",
        "watson.live.com","statsfe2.ws.microsoft.com",
        "corpext.msitadfs.glbdns2.microsoft.com",
        "compatexchange.cloudapp.net","a-0001.a-msedge.net",
        # Reklam/malware yayginlar
        "tracking.opencandy.com.s3.amazonaws.com",
        "media.opencandy.com","cdn.opencandy.com",
        "ads.opencandy.com","installer.betterinstaller.com",
        "ads.yahoo.com","ads.yap.yahoo.com",
        "adserver.yahoo.com","global.adserver.yahoo.com"
    )

    Write-Host ""
    Yaz "  Islemler:" Cyan
    Yaz "    [1]  Reklam & Tracker Engelle (hazir liste: $($engelListesi.Count) domain)" White
    Yaz "    [2]  Windows Telemetri Engelle" White
    Yaz "    [3]  Mevcut engelleri goster" White
    Yaz "    [4]  Tum SistemBakim engellerini kaldir" White
    Yaz "    [5]  Geri" White
    Write-Host ""

    Write-Host "  Seciminiz: " -ForegroundColor Yellow -NoNewline
    $secim = (Read-Host).Trim()

    switch ($secim) {
        "1" {
            # Yedek al
            $yedek = $hostsYol + ".bak_" + (Get-Date -Format "yyyyMMdd_HHmm")
            Copy-Item $hostsYol $yedek -Force
            Yaz ("  Yedek: " + $yedek) DarkGray

            $eklenen = 0
            $satirlar = [System.Collections.Generic.List[string]]::new()
            $satirlar.Add("")
            $satirlar.Add("# ── SistemBakim Reklam & Tracker Engeli ── " + (Get-Date -Format "yyyy-MM-dd"))
            foreach ($d in $engelListesi) {
                if ($icerik -notcontains "0.0.0.0 $d") {
                    $satirlar.Add("0.0.0.0 $d")
                    $eklenen++
                }
            }
            $satirlar.Add("# ── SistemBakim Engel Sonu ──")
            Add-Content -Path $hostsYol -Value ($satirlar -join "`r`n") -Encoding UTF8
            Yaz ("  {0} yeni domain engellendi." -f $eklenen) Green

            # DNS onbellegi temizle
            ipconfig /flushdns | Out-Null
            Yaz "  DNS onbellegi temizlendi." Green
        }
        "2" {
            $telemetriDomainler = $engelListesi | Where-Object { $_ -match 'microsoft\.com|msedge\.net' }
            $yedek = $hostsYol + ".bak_" + (Get-Date -Format "yyyyMMdd_HHmm")
            Copy-Item $hostsYol $yedek -Force
            $eklenen = 0
            $satirlar = @("", "# ── SistemBakim Telemetri Engeli ──")
            foreach ($d in $telemetriDomainler) {
                if ($icerik -notcontains "0.0.0.0 $d") {
                    $satirlar += "0.0.0.0 $d"
                    $eklenen++
                }
            }
            $satirlar += "# ── SistemBakim Telemetri Sonu ──"
            Add-Content -Path $hostsYol -Value ($satirlar -join "`r`n") -Encoding UTF8
            ipconfig /flushdns | Out-Null
            Yaz ("  {0} telemetri domaini engellendi." -f $eklenen) Green
        }
        "3" {
            $engeller = $icerik | Where-Object { $_ -match '^\s*0\.0\.0\.0\s' }
            if ($engeller.Count -eq 0) { Yaz "  Aktif engel yok." Gray; return }
            Yaz ("  {0} aktif engel:" -f $engeller.Count) Cyan
            $engeller | Select-Object -First 40 | ForEach-Object {
                Write-Host ("    " + $_) -ForegroundColor DarkGray
            }
            if ($engeller.Count -gt 40) { Yaz "  ... ve $($engeller.Count - 40) domain daha" DarkGray }
        }
        "4" {
            $yedek = $hostsYol + ".bak_" + (Get-Date -Format "yyyyMMdd_HHmm")
            Copy-Item $hostsYol $yedek -Force
            $temiz = $icerik | Where-Object { $_ -notmatch '# ── SistemBakim' } |
                     Where-Object { $_ -notmatch '^\s*0\.0\.0\.0\s' -or $_ -match '^\s*0\.0\.0\.0\s+localhost' }
            Set-Content -Path $hostsYol -Value ($temiz -join "`r`n") -Encoding UTF8
            ipconfig /flushdns | Out-Null
            Yaz "  SistemBakim engelleri kaldirildi, yedek alindi." Green
        }
        default { return }
    }
}

#endregion

#region ── MODUL 59: ZAMANLAMA GOREVI TEMIZLEYICI ───────────

function ZamanlamaGoreviTemizle {
    Baslik "Zamanlama Gorevi Temizleyici" "59"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    Yaz "  Windows Gorev Zamanlayici taraniyor..." Cyan

    # Bilinen gereksiz/artik gorev desenleri
    $gereksizDesenler = @(
        '*Adobe*Update*','*CCleaner*','*GoogleUpdate*','*OneDrive*Standalone*',
        '*Opera*Autoupdate*','*Brave*Update*','*Dropbox*Update*',
        '*RealPlayer*','*CyberLink*','*DivX*','*Overwolf*',
        '*Java*Update*','*Bonjour*','*Apple*Push*','*SoftwareDistribution*',
        '*npcap*','*Corel*','*WinZip*','*Avast*','*McAfee*Cleanup*'
    )

    $tumGorevler = Get-ScheduledTask -ErrorAction SilentlyContinue |
        Where-Object { $_.TaskPath -notmatch '\\Microsoft\\Windows\\' -and $_.TaskPath -notmatch '\\Microsoft\\Office\\' }

    $sorunlular = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($gorev in $tumGorevler) {
        $durum = "Temiz"
        $neden = ""

        # Kirik gorev: calismasi gereken exe yok
        $aksiyonlar = $gorev.Actions
        if ($aksiyonlar) {
            foreach ($a in $aksiyonlar) {
                if ($a.Execute -and $a.Execute -notmatch '^\s*$') {
                    $exeYol = $a.Execute.Trim('"')
                    if ($exeYol -match '^[A-Z]:\\' -and -not (Test-Path $exeYol)) {
                        $durum = "Kirik"
                        $neden = "EXE bulunamadi"
                    }
                }
            }
        }

        # Gereksiz bilinen gorevler
        if ($durum -eq "Temiz") {
            foreach ($desen in $gereksizDesenler) {
                if ($gorev.TaskName -like $desen) {
                    $durum = "Gereksiz"
                    $neden = "Bilinen gereksiz gorev"
                    break
                }
            }
        }

        # Devre disi ve 90+ gun calistirilmamis
        if ($durum -eq "Temiz" -and $gorev.State -eq 'Disabled') {
            $bilgi = $gorev | Get-ScheduledTaskInfo -ErrorAction SilentlyContinue
            if ($bilgi -and $bilgi.LastRunTime -and $bilgi.LastRunTime -lt (Get-Date).AddDays(-90)) {
                $durum = "Eski"
                $neden = "90+ gun devre disi"
            }
        }

        if ($durum -ne "Temiz") {
            $sorunlular.Add([PSCustomObject]@{
                Ad    = $gorev.TaskName
                Yol   = $gorev.TaskPath
                Durum = $durum
                Neden = $neden
                State = $gorev.State
            })
        }
    }

    Durum "Taranan gorev" $tumGorevler.Count.ToString() Cyan
    Durum "Sorunlu gorev" $sorunlular.Count.ToString() Yellow

    if ($sorunlular.Count -eq 0) {
        Yaz "  Sorunlu gorev bulunamadi. Temiz!" Green
        return
    }

    Write-Host ""
    $renk = @{ "Kirik"="Red"; "Gereksiz"="Yellow"; "Eski"="DarkGray" }
    foreach ($s in $sorunlular) {
        $r = $renk[$s.Durum]
        if (-not $r) { $r = "Gray" }
        Write-Host ("    [{0,-8}]  {1,-40}  {2}" -f $s.Durum, $s.Ad.Substring(0, [Math]::Min(40, $s.Ad.Length)), $s.Neden) -ForegroundColor $r
    }

    Write-Host ""
    if (Onay ("{0} sorunlu gorev temizlensin mi?" -f $sorunlular.Count)) {
        $silinen = 0
        foreach ($s in $sorunlular) {
            try {
                Unregister-ScheduledTask -TaskName $s.Ad -TaskPath $s.Yol -Confirm:$false -ErrorAction Stop
                $silinen++
            } catch {
                Yaz ("  Atlandi: " + $s.Ad) DarkGray
            }
        }
        Yaz ("  {0}/{1} gorev temizlendi." -f $silinen, $sorunlular.Count) Green
    }
}

#endregion

#region ── MODUL 60: GIZLILIK KALKANI (ANTISPY) ─────────────

function GizlilikKalkani {
    Baslik "Gizlilik Kalkani (AntiSpy)" "60"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    # Win10/Win11 uyumlu gizlilik toggle listesi
    # Her toggle: Ad, Aciklama, Yol (HKCU veya HKLM), Deger, Tip, AcikDeger, KapaliDeger
    $toggleler = @(
        @{ Ad="Reklam Kimligi (Advertising ID)";
           Yol="HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; Anahtar="Enabled"; Kapali=0; Acik=1; Tip="DWord" },
        @{ Ad="Konum Servisleri";
           Yol="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"; Anahtar="Value"; Kapali="Deny"; Acik="Allow"; Tip="String" },
        @{ Ad="Kamera Erisimi";
           Yol="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam"; Anahtar="Value"; Kapali="Deny"; Acik="Allow"; Tip="String" },
        @{ Ad="Mikrofon Erisimi";
           Yol="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone"; Anahtar="Value"; Kapali="Deny"; Acik="Allow"; Tip="String" },
        @{ Ad="Bildirim Erisimi";
           Yol="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener"; Anahtar="Value"; Kapali="Deny"; Acik="Allow"; Tip="String" },
        @{ Ad="Hesap Bilgisi Erisimi";
           Yol="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation"; Anahtar="Value"; Kapali="Deny"; Acik="Allow"; Tip="String" },
        @{ Ad="Rehber (Kisiler) Erisimi";
           Yol="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts"; Anahtar="Value"; Kapali="Deny"; Acik="Allow"; Tip="String" },
        @{ Ad="Takvim Erisimi";
           Yol="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments"; Anahtar="Value"; Kapali="Deny"; Acik="Allow"; Tip="String" },
        @{ Ad="Arama Gecmisi Erisimi";
           Yol="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory"; Anahtar="Value"; Kapali="Deny"; Acik="Allow"; Tip="String" },
        @{ Ad="E-posta Erisimi";
           Yol="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email"; Anahtar="Value"; Kapali="Deny"; Acik="Allow"; Tip="String" },
        @{ Ad="Etkinlik Gecmisi (Timeline)";
           Yol="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Anahtar="EnableActivityFeed"; Kapali=0; Acik=1; Tip="DWord" },
        @{ Ad="Etkinlik Gecmisi Yukleme";
           Yol="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Anahtar="UploadUserActivities"; Kapali=0; Acik=1; Tip="DWord" },
        @{ Ad="Teshis Verileri (Diagnostic Data)";
           Yol="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; Anahtar="AllowTelemetry"; Kapali=0; Acik=3; Tip="DWord" },
        @{ Ad="Teshis Geri Bildirimi";
           Yol="HKCU:\Software\Microsoft\Siuf\Rules"; Anahtar="NumberOfSIUFInPeriod"; Kapali=0; Acik=1; Tip="DWord" },
        @{ Ad="El Yazisi ve Yazma Tanilama";
           Yol="HKCU:\Software\Microsoft\InputPersonalization"; Anahtar="RestrictImplicitInkCollection"; Kapali=1; Acik=0; Tip="DWord" },
        @{ Ad="Yazma Istatistikleri";
           Yol="HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore"; Anahtar="HarvestContacts"; Kapali=0; Acik=1; Tip="DWord" },
        @{ Ad="Tailored Experiences (Kisisellestirme)";
           Yol="HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy"; Anahtar="TailoredExperiencesWithDiagnosticDataEnabled"; Kapali=0; Acik=1; Tip="DWord" },
        @{ Ad="Online Konusma Tanima";
           Yol="HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"; Anahtar="HasAccepted"; Kapali=0; Acik=1; Tip="DWord" },
        @{ Ad="Wi-Fi Sense (Hotspot Paylasimi)";
           Yol="HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"; Anahtar="AutoConnectAllowedOEM"; Kapali=0; Acik=1; Tip="DWord" },
        @{ Ad="SmartScreen Filtresi (Uygulama)";
           Yol="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"; Anahtar="SmartScreenEnabled"; Kapali="Off"; Acik="Warn"; Tip="String" },
        @{ Ad="Web Arama Sonuclari (Baslat)";
           Yol="HKCU:\Software\Policies\Microsoft\Windows\Explorer"; Anahtar="DisableSearchBoxSuggestions"; Kapali=1; Acik=0; Tip="DWord" },
        @{ Ad="Uygulama Baslatma Takibi";
           Yol="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Anahtar="Start_TrackProgs"; Kapali=0; Acik=1; Tip="DWord" },
        @{ Ad="Cihazlar Arasi Deneyim Paylasimi";
           Yol="HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"; Anahtar="EnableCdp"; Kapali=0; Acik=1; Tip="DWord" },
        @{ Ad="Onerilen Icerik (Ayarlar)";
           Yol="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Anahtar="SubscribedContent-338393Enabled"; Kapali=0; Acik=1; Tip="DWord" },
        @{ Ad="Kilit Ekrani Spotlight Onerileri";
           Yol="HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; Anahtar="SubscribedContent-353696Enabled"; Kapali=0; Acik=1; Tip="DWord" }
    )

    # Mevcut durumlari oku
    Write-Host ""
    Yaz ("  {0} gizlilik ayari taraniyor..." -f $toggleler.Count) Cyan
    Write-Host ""

    $sonuclar = [System.Collections.Generic.List[PSCustomObject]]::new()
    $sira = 0
    foreach ($t in $toggleler) {
        $sira++
        $mevcutDeger = $null
        $durum = "?"
        try {
            if (Test-Path $t.Yol) {
                $mevcutDeger = (Get-ItemProperty -Path $t.Yol -Name $t.Anahtar -ErrorAction SilentlyContinue).($t.Anahtar)
            }
        } catch {}

        if ($null -ne $mevcutDeger) {
            if ($t.Tip -eq "String") {
                $durum = if ($mevcutDeger -eq $t.Kapali) { "KORUMALI" } else { "ACIK" }
            } else {
                $durum = if ([int]$mevcutDeger -eq [int]$t.Kapali) { "KORUMALI" } else { "ACIK" }
            }
        } else {
            $durum = "VARSAYILAN"
        }

        $renk = switch ($durum) { "KORUMALI" { "Green" } "ACIK" { "Red" } default { "Yellow" } }
        Write-Host ("  {0,2}. {1,-42} [{2}]" -f $sira, $t.Ad, $durum) -ForegroundColor $renk

        $sonuclar.Add([PSCustomObject]@{ Sira=$sira; Ad=$t.Ad; Durum=$durum; Toggle=$t })
    }

    $acikSay  = ($sonuclar | Where-Object { $_.Durum -ne "KORUMALI" }).Count
    $kapaliSay = ($sonuclar | Where-Object { $_.Durum -eq "KORUMALI" }).Count

    Write-Host ""
    Durum "Korumali (guvenli)" $kapaliSay.ToString() Green
    Durum "Acik (riskli)" $acikSay.ToString() $(if ($acikSay -gt 10){"Red"} else {"Yellow"})
    Write-Host ""

    if ($acikSay -eq 0) {
        Yaz "  Tum gizlilik ayarlari zaten korumali! Temiz." Green
        return
    }

    Yaz "  Islemler:" Cyan
    Yaz "    [1]  Tum acik ayarlari KAPAT (maksimum gizlilik)" White
    Yaz "    [2]  Tum ayarlari VARSAYILANA dondur (Windows fabrika)" White
    Yaz "    [0]  Geri" White
    Write-Host ""
    Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
    $secim = if ($env:SISTEMBAK_GUI -eq '1') { "1" } else { (Read-Host).Trim() }

    if ($secim -eq "0") { return }
    $kapat = ($secim -eq "1")

    $uygulanan = 0
    foreach ($s in $sonuclar) {
        $t = $s.Toggle
        $hedefDeger = if ($kapat) { $t.Kapali } else { $t.Acik }
        try {
            if (-not (Test-Path $t.Yol)) { New-Item -Path $t.Yol -Force | Out-Null }
            if ($t.Tip -eq "String") {
                Set-ItemProperty -Path $t.Yol -Name $t.Anahtar -Value $hedefDeger -Type String -Force
            } else {
                Set-ItemProperty -Path $t.Yol -Name $t.Anahtar -Value $hedefDeger -Type DWord -Force
            }
            $uygulanan++
        } catch {
            Yaz ("  Atlandi: " + $t.Ad + " (" + $_.Exception.Message + ")") DarkGray
        }
    }

    Write-Host ""
    if ($kapat) {
        Yaz ("  {0}/{1} gizlilik ayari KORUMA ALTINA alindi!" -f $uygulanan, $toggleler.Count) Green
    } else {
        Yaz ("  {0}/{1} gizlilik ayari VARSAYILANA dondu." -f $uygulanan, $toggleler.Count) Yellow
    }
    Yaz "  Bazi degisiklikler oturum kapatip acinca aktif olur." DarkGray
    RaporVeriEkle "gizlilik_kalkani" $(if ($kapat) {"Koruma aktif"} else {"Varsayilan"})
}

#endregion

#region ── MODUL 61: TURBO BOOST MODU ───────────────────────

function TurboBoostModu {
    Baslik "Turbo Boost Modu" "61"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    Write-Host ""
    Yaz "  Turbo Boost: RAM + Surec + Guc + Gorsel = TEK TIK" Cyan
    Yaz "  Oyun veya agir is oncesi maksimum performans icin." Gray
    Write-Host ""

    Yaz "  Islemler:" Cyan
    Yaz "    [1]  TURBO AKTIF (performans modu)" White
    Yaz "    [2]  TURBO KAPAT (normal moda don)" White
    Yaz "    [0]  Geri" White
    Write-Host ""
    Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
    $secim = if ($env:SISTEMBAK_GUI -eq '1') { "1" } else { (Read-Host).Trim() }
    if ($secim -eq "0") { return }

    $turboAktif = ($secim -eq "1")
    $adim = 0

    # ── 1. RAM Temizligi ──
    $adim++
    Write-Host "  -- [$adim/6] RAM Temizligi" -ForegroundColor Cyan
    if ($turboAktif) {
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
        # Standby list temizle (varsa EmptyStandbyList.exe yoksa GC yeterli)
        $ramOnce = [Math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024, 0)
        # Working set trim
        Get-Process | Where-Object { $_.WorkingSet64 -gt 50MB -and $_.ProcessName -notin @("svchost","csrss","wininit","System","smss","lsass","services") } |
            ForEach-Object { $_.MinWorkingSet = 204800 } 2>$null
        $ramSonra = [Math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1024, 0)
        Yaz ("    RAM: {0} MB serbest ({1:+#;-#;0} MB)" -f $ramSonra, ($ramSonra - $ramOnce)) Green
    } else {
        Yaz "    RAM normal moda dondu." Gray
    }

    # ── 2. Gereksiz Surecleri Durdur ──
    $adim++
    Write-Host "  -- [$adim/6] Arka Plan Surecleri" -ForegroundColor Cyan
    $hedefler = @("OneDrive","Teams","Spotify","Discord","Steam","EpicGamesLauncher",
                  "GoogleCrashHandler*","MicrosoftEdgeUpdate","YourPhone","PhoneExperienceHost",
                  "SkypeApp","Cortana","GameBar*","BcastDVRUserService","AdobeIPCBroker",
                  "CCXProcess","CalculatorApp","Microsoft.Photos")
    if ($turboAktif) {
        $kapatilan = 0
        foreach ($h in $hedefler) {
            $procs = Get-Process -Name $h -ErrorAction SilentlyContinue
            foreach ($p in $procs) {
                try { $p | Stop-Process -Force -ErrorAction Stop; $kapatilan++ } catch {}
            }
        }
        Yaz ("    {0} gereksiz surec kapatildi." -f $kapatilan) Green
    } else {
        Yaz "    Surecler kullanici tarafindan yeniden baslatilabilir." Gray
    }

    # ── 3. Guc Plani ──
    $adim++
    Write-Host "  -- [$adim/6] Guc Plani" -ForegroundColor Cyan
    if ($turboAktif) {
        # Ultimate Performance plani varsa onu sec, yoksa High Performance
        $ultimate = powercfg /list 2>$null | Select-String "e9a42b02-d5df-448d-aa00-03f14749eb61"
        if (-not $ultimate) {
            powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
            $ultimate = powercfg /list 2>$null | Select-String "e9a42b02-d5df-448d-aa00-03f14749eb61"
        }
        if ($ultimate) {
            powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
            Yaz "    Ultimate Performance plani aktif." Green
        } else {
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
            Yaz "    High Performance plani aktif." Green
        }
    } else {
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e 2>$null
        Yaz "    Dengeli (Balanced) plana donuldu." Gray
    }

    # ── 4. Gorsel Efektler ──
    $adim++
    Write-Host "  -- [$adim/6] Gorsel Efektler" -ForegroundColor Cyan
    $transpYol = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (-not (Test-Path $transpYol)) { New-Item -Path $transpYol -Force | Out-Null }
    Set-ItemProperty -Path $transpYol -Name "EnableTransparency" -Value $(if ($turboAktif) {0} else {1}) -Type DWord -Force
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value $(if ($turboAktif) {"0"} else {"400"}) -Force
    if ($turboAktif) { Yaz "    Seffaflik ve animasyonlar kapatildi." Green }
    else { Yaz "    Gorsel efektler geri acildi." Gray }

    # ── 5. Windows Search Indexer ──
    $adim++
    Write-Host "  -- [$adim/6] Search Indexer" -ForegroundColor Cyan
    if ($turboAktif) {
        Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue
        Yaz "    Search Indexer durduruldu." Green
    } else {
        Start-Service -Name "WSearch" -ErrorAction SilentlyContinue
        Yaz "    Search Indexer baslatildi." Gray
    }

    # ── 6. Gereksiz Servisler ──
    $adim++
    Write-Host "  -- [$adim/6] Gereksiz Servisler" -ForegroundColor Cyan
    $turboServisler = @("SysMain","DiagTrack","WMPNetworkSvc","MapsBroker","lfsvc","RetailDemo")
    $svcSay = 0
    foreach ($svc in $turboServisler) {
        $servis = Get-Service -Name $svc -ErrorAction SilentlyContinue
        if (-not $servis) { continue }
        if ($turboAktif) {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
            $svcSay++
        } else {
            Start-Service -Name $svc -ErrorAction SilentlyContinue
        }
    }
    if ($turboAktif) { Yaz ("    {0} gereksiz servis durduruldu." -f $svcSay) Green }
    else { Yaz "    Servisler geri baslatildi." Gray }

    Write-Host ""
    if ($turboAktif) {
        Yaz "  TURBO BOOST AKTIF! Maksimum performans modu." Green
        Yaz "  Islemleri bitirince [2] ile normal moda donebilirsiniz." DarkGray
    } else {
        Yaz "  Normal moda donuldu. Tum ayarlar eski haline getirildi." Yellow
    }
    RaporVeriEkle "turbo_boost" $(if ($turboAktif) {"Aktif"} else {"Kapali"})
}

#endregion

#region ── MODUL 62: BAGLAM MENUSU YONETICISI ───────────────

function BaglamMenusuYonetici {
    Baslik "Baglam Menusu Yoneticisi (Shell Extension)" "62"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    # HKCR PSDrive
    if (-not (Test-Path "HKCR:")) {
        New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -ErrorAction SilentlyContinue | Out-Null
    }

    Yaz "  Shell Extension'lar taraniyor..." Cyan

    $shellYollar = @(
        "HKCR:\*\shellex\ContextMenuHandlers",
        "HKCR:\Directory\shellex\ContextMenuHandlers",
        "HKCR:\Directory\Background\shellex\ContextMenuHandlers",
        "HKCR:\Folder\shellex\ContextMenuHandlers",
        "HKCR:\Drive\shellex\ContextMenuHandlers"
    )

    # Windows korunan eklentiler (silmek tehlikeli)
    $korunanlar = @("CopyAsPathMenu","Sharing","WorkFolders","OpenWith","SendTo","NewMenu",
                    "Compatibility","PintoStartScreen","OfficeAddin","ShellExtInit","BriefcaseMenu",
                    "{E2BF9676-5F8F-435C-97EB-11607A5BEDF7}")

    $eklentiler = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($yol in $shellYollar) {
        if (-not (Test-Path $yol)) { continue }
        Get-ChildItem $yol -ErrorAction SilentlyContinue | ForEach-Object {
            $ad    = $_.PSChildName
            $clsid = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue)."(Default)"
            $konum = $yol -replace "HKCR:\\", ""

            # DLL yolunu bul
            $dllYol = ""
            if ($clsid -match '^\{.*\}$') {
                try {
                    $ip = "HKCR:\CLSID\$clsid\InprocServer32"
                    if (Test-Path $ip) { $dllYol = (Get-ItemProperty $ip -ErrorAction SilentlyContinue)."(Default)" }
                } catch {}
            }

            # Devre disi mi? (ad basinda - varsa)
            $devreDisi = $ad.StartsWith("-")
            $temizAd = $ad.TrimStart("-")

            # Korunmus mu?
            $korunmus = ($korunanlar -contains $temizAd) -or ($temizAd -like "*Windows*") -or ($temizAd -like "*Microsoft*")

            $eklentiler.Add([PSCustomObject]@{
                Ad=$ad; TemizAd=$temizAd; CLSID=$clsid; DLL=$dllYol; Konum=$konum
                Yol=$_.PSPath; DevreDisi=$devreDisi; Korunmus=$korunmus
            })
        }
    }

    $ucuncuParti = @($eklentiler | Where-Object { -not $_.Korunmus })
    $windowsEkl  = @($eklentiler | Where-Object { $_.Korunmus })
    $devreDisiSay = @($eklentiler | Where-Object { $_.DevreDisi }).Count

    Write-Host ""
    Durum "Toplam eklenti" $eklentiler.Count.ToString() Cyan
    Durum "Windows (korunmus)" $windowsEkl.Count.ToString() Gray
    Durum "3. Parti" $ucuncuParti.Count.ToString() Yellow
    Durum "Devre disi" $devreDisiSay.ToString() DarkGray
    Write-Host ""

    if ($ucuncuParti.Count -eq 0) {
        Yaz "  3. parti shell extension bulunamadi." Green
        return
    }

    # 3. parti eklentileri listele
    Yaz "  3. Parti Eklentiler:" Yellow
    $sira = 0
    foreach ($e in $ucuncuParti) {
        $sira++
        $durumStr = if ($e.DevreDisi) { "[KAPALI]" } else { "[AKTIF] " }
        $durumRenk = if ($e.DevreDisi) { "DarkGray" } else { "White" }
        Write-Host ("    {0,2}. {1}  {2,-36}" -f $sira, $durumStr, $e.TemizAd) -ForegroundColor $durumRenk
        if ($e.DLL) { Write-Host ("        DLL: {0}" -f $e.DLL) -ForegroundColor DarkGray }
    }

    Write-Host ""
    Yaz "  Islemler:" Cyan
    Yaz "    [1]  Tum 3. parti eklentileri DEVRE DISI birak" White
    Yaz "    [2]  Tum devre disi birakilan eklentileri GERI AC" White
    Yaz "    [0]  Geri" White
    Write-Host ""
    Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
    $secim = if ($env:SISTEMBAK_GUI -eq '1') { "1" } else { (Read-Host).Trim() }

    if ($secim -eq "0") { return }

    $islenen = 0
    foreach ($e in $ucuncuParti) {
        try {
            if ($secim -eq "1" -and -not $e.DevreDisi) {
                # Guvenlı yontem: anahtari "-OrijinalAd" olarak yeniden adlandir
                $yeniAd = "-" + $e.Ad
                $ustYol = Split-Path $e.Yol -Parent
                Rename-Item -Path $e.Yol -NewName $yeniAd -Force -ErrorAction Stop
                $islenen++
            }
            elseif ($secim -eq "2" -and $e.DevreDisi) {
                # Basi "-" olan anahtari geri ac
                $yeniAd = $e.Ad.TrimStart("-")
                Rename-Item -Path $e.Yol -NewName $yeniAd -Force -ErrorAction Stop
                $islenen++
            }
        } catch {
            Yaz ("  Atlandi: " + $e.TemizAd) DarkGray
        }
    }

    Write-Host ""
    if ($secim -eq "1") {
        Yaz ("  {0} eklenti devre disi birakildi (guvensiz yol: rename)." -f $islenen) Green
    } else {
        Yaz ("  {0} eklenti geri acildi." -f $islenen) Green
    }
    Yaz "  Degisikliklerin etkili olmasi icin Explorer'i yeniden baslatin." DarkGray
    RaporVeriEkle "baglam_menusu" ("{0} eklenti islendi" -f $islenen)
}

#endregion

#region ── MODUL 63: BASLANGIC GECIKME YONETICISI ───────────

function BaslangicGecikmeYonetici {
    Baslik "Baslangic Gecikme Yoneticisi" "63"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    Yaz "  Baslangic uygulamalari taranıyor..." Cyan

    # Mevcut startup uygulamalari (Run, RunOnce, Startup klasorleri)
    $kaynaklar = @(
        @{ Ad="HKCU Run"; Yol="HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"; Tip="Registry" },
        @{ Ad="HKLM Run"; Yol="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; Tip="Registry" }
    )

    $uygulamalar = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($kaynak in $kaynaklar) {
        if (-not (Test-Path $kaynak.Yol)) { continue }
        $props = Get-ItemProperty -Path $kaynak.Yol -ErrorAction SilentlyContinue
        $props.PSObject.Properties | Where-Object { $_.Name -notlike "PS*" } | ForEach-Object {
            $uygulamalar.Add([PSCustomObject]@{
                Ad       = $_.Name
                Komut    = $_.Value
                Kaynak   = $kaynak.Ad
                RegYol   = $kaynak.Yol
                Tip      = "Registry"
            })
        }
    }

    # Startup klasoru
    $startupKlasor = [Environment]::GetFolderPath("Startup")
    if (Test-Path $startupKlasor) {
        Get-ChildItem $startupKlasor -File -ErrorAction SilentlyContinue | ForEach-Object {
            $uygulamalar.Add([PSCustomObject]@{
                Ad       = $_.BaseName
                Komut    = $_.FullName
                Kaynak   = "Startup Klasoru"
                RegYol   = $startupKlasor
                Tip      = "Klasor"
            })
        }
    }

    # Mevcut SistemBakim gecikmeli gorevleri kontrol et
    $mevcutGecikmeler = Get-ScheduledTask -TaskPath "\SistemBakim\" -ErrorAction SilentlyContinue

    Durum "Baslangic uygulamasi" $uygulamalar.Count.ToString() Yellow
    Durum "Gecikmeli gorev" $(if ($mevcutGecikmeler) { $mevcutGecikmeler.Count } else { 0 }).ToString() Cyan
    Write-Host ""

    if ($uygulamalar.Count -eq 0) {
        Yaz "  Baslangic uygulamasi bulunamadi." Green
        return
    }

    # Uygulamalari listele
    $sira = 0
    foreach ($u in $uygulamalar) {
        $sira++
        $gecikmeVar = $false
        if ($mevcutGecikmeler) {
            $gecikmeVar = ($mevcutGecikmeler | Where-Object { $_.TaskName -eq ("SB_Delay_" + ($u.Ad -replace '[^\w]','_')) }) -ne $null
        }
        $durumStr = if ($gecikmeVar) { "[GECIKMELI]" } else { "[ANLIK]    " }
        $renk = if ($gecikmeVar) { "Cyan" } else { "White" }
        Write-Host ("    {0,2}. {1}  {2,-30}  ({3})" -f $sira, $durumStr, $u.Ad, $u.Kaynak) -ForegroundColor $renk
    }

    Write-Host ""
    Yaz "  Islemler:" Cyan
    Yaz "    [1]  Tum uygulamalara 30 sn gecikme uygula" White
    Yaz "    [2]  Tum uygulamalara 60 sn gecikme uygula" White
    Yaz "    [3]  Tum gecikmeleri kaldir (normal baslangic)" White
    Yaz "    [0]  Geri" White
    Write-Host ""
    Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
    $secim = if ($env:SISTEMBAK_GUI -eq '1') { "1" } else { (Read-Host).Trim() }

    if ($secim -eq "0") { return }

    if ($secim -eq "3") {
        # Tum gecikmeli gorevleri sil
        $silinen = 0
        if ($mevcutGecikmeler) {
            foreach ($g in $mevcutGecikmeler) {
                Unregister-ScheduledTask -TaskName $g.TaskName -TaskPath "\SistemBakim\" -Confirm:$false -ErrorAction SilentlyContinue
                $silinen++
            }
        }
        Yaz ("  {0} gecikmeli gorev kaldirildi. Normal baslangica donuldu." -f $silinen) Green
        return
    }

    $gecikmeSn = if ($secim -eq "2") { 60 } else { 30 }
    $islenen = 0

    foreach ($u in $uygulamalar) {
        $gorevAdi = "SB_Delay_" + ($u.Ad -replace '[^\w]','_')

        try {
            # Oncelikle mevcut gecikmeli gorevi sil
            Unregister-ScheduledTask -TaskName $gorevAdi -TaskPath "\SistemBakim\" -Confirm:$false -ErrorAction SilentlyContinue

            # Registry'den kaldir (gecikmeye aliyoruz)
            if ($u.Tip -eq "Registry") {
                Remove-ItemProperty -Path $u.RegYol -Name $u.Ad -Force -ErrorAction SilentlyContinue
            } elseif ($u.Tip -eq "Klasor") {
                # Klasordeki kisayolu yedekle (silmek yerine gizle)
                $dosya = Get-Item $u.Komut -ErrorAction SilentlyContinue
                if ($dosya) { $dosya.Attributes = $dosya.Attributes -bor [System.IO.FileAttributes]::Hidden }
            }

            # Task Scheduler ile gecikmeli gorev olustur
            $eylem = New-ScheduledTaskAction -Execute "cmd.exe" -Argument ("/c start """" $($u.Komut)")
            $tetik = New-ScheduledTaskTrigger -AtLogOn
            $tetik.Delay = "PT${gecikmeSn}S"
            $ayar = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
            Register-ScheduledTask -TaskName $gorevAdi -TaskPath "\SistemBakim\" `
                -Action $eylem -Trigger $tetik -Settings $ayar `
                -Description ("SistemBakim gecikmeli baslangic: " + $u.Ad) `
                -RunLevel Highest -Force -ErrorAction Stop | Out-Null
            $islenen++
        } catch {
            Yaz ("  Atlandi: " + $u.Ad + " (" + $_.Exception.Message + ")") DarkGray
        }
    }

    Write-Host ""
    Yaz ("  {0}/{1} uygulama {2}sn gecikmeli baslatilacak." -f $islenen, $uygulamalar.Count, $gecikmeSn) Green
    Yaz "  Bir sonraki bilgisayar acilisinda etkili olacak." DarkGray
    RaporVeriEkle "baslangic_gecikme" ("{0} uygulama {1}sn gecikme" -f $islenen, $gecikmeSn)
}

#endregion

#region ── MODUL 64: REGISTRY TEMIZLEYICI ───────────────────

function RegistryTemizleyici {
    Baslik "Registry Temizleyici" "64"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    Yaz "  Kayit defteri taraniyor (HKCU + HKLM)..." Cyan
    Yaz "  Not: Islem oncesi .reg yedegi otomatik olusturulur." DarkGray
    Write-Host ""

    $sorunlar = [System.Collections.Generic.List[PSCustomObject]]::new()

    # ── TARAMA 1: Kirik Uninstall Girisleri ──
    Write-Host "  [1/4] Kirik Uninstall girisleri..." -ForegroundColor Cyan
    $uninstYollar = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    )
    foreach ($uy in $uninstYollar) {
        if (-not (Test-Path $uy)) { continue }
        Get-ChildItem $uy -ErrorAction SilentlyContinue | ForEach-Object {
            $props = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
            $ad = if ($props.DisplayName) { $props.DisplayName } else { $_.PSChildName }
            $instYol = $props.InstallLocation
            $uninstStr = $props.UninstallString

            # Hem install yolu hemde uninstall komutu kirik mi?
            $kirik = $false
            if ($instYol -and $instYol.Length -gt 3 -and $instYol -match '^[A-Z]:\\') {
                if (-not (Test-Path $instYol)) { $kirik = $true }
            }
            if (-not $kirik -and $uninstStr) {
                $exeYol = $uninstStr -replace '"','' -replace '\s+/.*$','' -replace '\s+\-.*$',''
                if ($exeYol -match '^[A-Z]:\\' -and -not (Test-Path $exeYol)) { $kirik = $true }
            }
            # DisplayName bile yoksa artik girdi
            if (-not $kirik -and -not $props.DisplayName -and -not $uninstStr) { $kirik = $true }

            if ($kirik) {
                $sorunlar.Add([PSCustomObject]@{
                    Tip="Kirik Uninstall"; Ad=$ad; Yol=$_.PSPath; Detay="Artik program girisi"
                })
            }
        }
    }

    # ── TARAMA 2: Gecersiz SharedDLL Referanslari ──
    Write-Host "  [2/4] Gecersiz SharedDLLs referanslari..." -ForegroundColor Cyan
    $sharedYol = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDLLs"
    if (Test-Path $sharedYol) {
        $sharedProps = Get-ItemProperty $sharedYol -ErrorAction SilentlyContinue
        $sharedProps.PSObject.Properties | Where-Object { $_.Name -notlike "PS*" } | ForEach-Object {
            $dllYol = $_.Name
            if ($dllYol -match '^[A-Z]:\\' -and -not (Test-Path $dllYol)) {
                $sorunlar.Add([PSCustomObject]@{
                    Tip="Gecersiz SharedDLL"; Ad=(Split-Path $dllYol -Leaf); Yol="$sharedYol\$dllYol"; Detay=$dllYol
                })
            }
        }
    }

    # ── TARAMA 3: Kirik COM/ActiveX Referanslari ──
    Write-Host "  [3/4] Kirik COM/ActiveX referanslari..." -ForegroundColor Cyan
    $comYol = "HKLM:\SOFTWARE\Classes\CLSID"
    if (Test-Path $comYol) {
        $comSayac = 0
        Get-ChildItem $comYol -ErrorAction SilentlyContinue | Select-Object -First 2000 | ForEach-Object {
            $comSayac++
            $ipYol = Join-Path $_.PSPath "InprocServer32"
            if (Test-Path $ipYol) {
                $dll = (Get-ItemProperty $ipYol -ErrorAction SilentlyContinue)."(Default)"
                if ($dll -and $dll -match '^[A-Z]:\\' -and -not (Test-Path $dll)) {
                    $sorunlar.Add([PSCustomObject]@{
                        Tip="Kirik COM"; Ad=$_.PSChildName; Yol=$ipYol; Detay=$dll
                    })
                }
            }
        }
    }

    # ── TARAMA 4: Kirik App Paths ──
    Write-Host "  [4/4] Kirik App Paths girisleri..." -ForegroundColor Cyan
    $appPathYol = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths"
    if (Test-Path $appPathYol) {
        Get-ChildItem $appPathYol -ErrorAction SilentlyContinue | ForEach-Object {
            $exeYol = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue)."(Default)"
            if ($exeYol -and $exeYol -match '^[A-Z]:\\' -and -not (Test-Path $exeYol)) {
                $sorunlar.Add([PSCustomObject]@{
                    Tip="Kirik App Path"; Ad=$_.PSChildName; Yol=$_.PSPath; Detay=$exeYol
                })
            }
        }
    }

    # ── SONUC RAPORU ──
    Write-Host ""
    Durum "Toplam sorunlu girdi" $sorunlar.Count.ToString() $(if ($sorunlar.Count -gt 0){"Yellow"} else {"Green"})
    Write-Host ""

    if ($sorunlar.Count -eq 0) {
        Yaz "  Kayit defteri temiz! Sorunlu girdi bulunamadi." Green
        return
    }

    # Tiplere gore gruplama
    $gruplar = $sorunlar | Group-Object Tip
    foreach ($g in $gruplar) {
        Write-Host ("    [{0}] {1} adet" -f $g.Name, $g.Count) -ForegroundColor Yellow
        $g.Group | Select-Object -First 5 | ForEach-Object {
            Write-Host ("      - {0}" -f $_.Ad) -ForegroundColor DarkGray
        }
        if ($g.Count -gt 5) { Write-Host ("      ... ve {0} daha" -f ($g.Count - 5)) -ForegroundColor DarkGray }
    }

    Write-Host ""
    if (-not (Onay ("{0} sorunlu girdi temizlensin mi? (Yedek alinacak)" -f $sorunlar.Count))) { return }

    # ── YEDEK AL (.reg formati) ──
    $yedekDosya = Join-Path $LOG_KLASOR ("RegistryYedek_{0}.reg" -f (Get-Date -Format "yyyyMMdd_HHmm"))
    Yaz ("  Yedek olusturuluyor: " + $yedekDosya) DarkGray
    $regIcerik = [System.Collections.Generic.List[string]]::new()
    $regIcerik.Add("Windows Registry Editor Version 5.00")
    $regIcerik.Add("")
    $regIcerik.Add("; SistemBakim Registry Yedek - " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
    $regIcerik.Add("; Sorunlu girdi sayisi: " + $sorunlar.Count.ToString())
    $regIcerik.Add("")

    foreach ($s in $sorunlar) {
        # Registry yolunu .reg formatina cevir
        $regYol = $s.Yol -replace '^HKLM:\\','[HKEY_LOCAL_MACHINE\' -replace '^HKCU:\\','[HKEY_CURRENT_USER\' -replace '\\','\'
        $regYol = $regYol + "]"
        $regIcerik.Add("; Tip: " + $s.Tip + " | Ad: " + $s.Ad)
        $regIcerik.Add($regYol)
        $regIcerik.Add("")
    }
    [System.IO.File]::WriteAllLines($yedekDosya, $regIcerik.ToArray(), [System.Text.Encoding]::Unicode)
    Yaz ("  Yedek kaydedildi: " + (Split-Path $yedekDosya -Leaf)) Green

    # ── TEMIZLIK ──
    $silinen = 0; $atlanan = 0
    foreach ($s in $sorunlar) {
        try {
            switch ($s.Tip) {
                "Gecersiz SharedDLL" {
                    $dllAd = $s.Detay
                    Remove-ItemProperty -Path $sharedYol -Name $dllAd -Force -ErrorAction Stop
                    $silinen++
                }
                default {
                    # Kirik Uninstall, COM, App Path → anahtar sil
                    Remove-Item -Path $s.Yol -Recurse -Force -ErrorAction Stop
                    $silinen++
                }
            }
        } catch {
            $atlanan++
        }
    }

    Write-Host ""
    Yaz ("  {0} girdi temizlendi, {1} atlanadi." -f $silinen, $atlanan) Green
    Yaz ("  Geri almak icin: " + (Split-Path $yedekDosya -Leaf) + " dosyasini cift tiklayin.") DarkGray
    RaporVeriEkle "registry_temizlik" ("{0} girdi temizlendi" -f $silinen)
}

#endregion

#region ── MODUL 65: PROGRAM KALDIRICI ──────────────────────

function ProgramKaldirici {
    Baslik "Program Kaldirici (Uninstaller)" "65"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    Yaz "  Yuklu programlar taraniyor (Registry yontemi)..." Cyan

    # Win32_Product KULLANMIYORUZ — cok yavas. Registry okuyoruz.
    $uninstYollar = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    $programlar = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($uy in $uninstYollar) {
        if (-not (Test-Path $uy)) { continue }
        Get-ChildItem $uy -ErrorAction SilentlyContinue | ForEach-Object {
            $props = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
            if (-not $props.DisplayName) { return }  # Isimsiz girdiler atla
            if ($props.SystemComponent -eq 1) { return }  # Sistem bilesenleri atla
            if ($props.ParentKeyName) { return }  # Alt bilesen/patch'ler atla

            $boyut = if ($props.EstimatedSize) { [long]$props.EstimatedSize * 1024 } else { 0 }
            $tarih = $null
            if ($props.InstallDate -match '^\d{8}$') {
                try { $tarih = [DateTime]::ParseExact($props.InstallDate, "yyyyMMdd", $null) } catch {}
            }

            $programlar.Add([PSCustomObject]@{
                Ad          = $props.DisplayName
                Surum       = if ($props.DisplayVersion) { $props.DisplayVersion } else { "-" }
                Yayinci     = if ($props.Publisher) { $props.Publisher } else { "-" }
                Boyut       = $boyut
                Tarih       = $tarih
                UninstStr   = $props.UninstallString
                QUninstStr  = $props.QuietUninstallString
                InstallYol  = $props.InstallLocation
                RegYol      = $_.PSPath
                Bitis       = if ($uy -match 'WOW6432') { "32bit" } elseif ($uy -match 'HKCU') { "Kullanici" } else { "64bit" }
            })
        }
    }

    # Isme gore sirala ve ciftleri cikar
    $programlar = [System.Collections.Generic.List[PSCustomObject]]::new(
        ($programlar | Sort-Object Ad -Unique)
    )

    Durum "Yuklu program" $programlar.Count.ToString() Cyan
    Write-Host ""

    if ($programlar.Count -eq 0) {
        Yaz "  Hicbir program bulunamadi." Yellow
        return
    }

    # Programlari listele (sayfalama: ilk 40)
    $gosterilen = [Math]::Min($programlar.Count, 40)
    for ($i = 0; $i -lt $gosterilen; $i++) {
        $p = $programlar[$i]
        $boyStr = if ($p.Boyut -gt 0) { BoyutFormatla $p.Boyut } else { "   -   " }
        $tarStr = if ($p.Tarih) { $p.Tarih.ToString("dd.MM.yy") } else { "  -  " }
        Write-Host ("  {0,3}.  {1,-38}  {2,-10}  {3,9}  [{4}]" -f ($i+1), `
            $p.Ad.Substring(0, [Math]::Min(38, $p.Ad.Length)), `
            $p.Surum.Substring(0, [Math]::Min(10, $p.Surum.Length)), `
            $boyStr, $p.Bitis) -ForegroundColor Gray
    }
    if ($programlar.Count -gt 40) {
        Yaz ("  ... ve {0} program daha (arama icin modul adini yazin)" -f ($programlar.Count - 40)) DarkGray
    }

    # GUI modunda kaldirma yapmiyoruz (Read-Host gerekli)
    if ($env:SISTEMBAK_GUI -eq '1') {
        Yaz ("  {0} program listelendi. CLI'dan kaldirim yapilabilir." -f $programlar.Count) Cyan
        return
    }

    Write-Host ""
    Write-Host "  Kaldirmak icin numara girin (0=geri): " -ForegroundColor Yellow -NoNewline
    $secim = (Read-Host).Trim()
    if ($secim -eq "0" -or $secim -eq "") { return }

    $idx = 0
    if (-not [int]::TryParse($secim, [ref]$idx) -or $idx -lt 1 -or $idx -gt $programlar.Count) {
        Yaz "  Gecersiz secim." Red; return
    }

    $hedef = $programlar[$idx - 1]
    Write-Host ""
    Durum "Program" $hedef.Ad Yellow
    Durum "Surum" $hedef.Surum Gray
    Durum "Yayinci" $hedef.Yayinci Gray
    Write-Host ""

    if (-not (Onay ("'" + $hedef.Ad + "' kaldirilsin mi?"))) { return }

    # ── Kaldirma islemi ──
    $basarili = $false
    try {
        $kaldirKomut = if ($hedef.QUninstStr) { $hedef.QUninstStr } else { $hedef.UninstStr }
        if (-not $kaldirKomut) {
            Yaz "  HATA: Bu program icin kaldirim komutu bulunamadi." Red
            return
        }

        Yaz ("  Kaldiriliyor: " + $hedef.Ad) Cyan

        # MsiExec veya direkt EXE?
        if ($kaldirKomut -match 'MsiExec') {
            $guid = [regex]::Match($kaldirKomut, '\{[0-9A-Fa-f\-]+\}').Value
            if ($guid) {
                $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $guid /qn /norestart" -Wait -PassThru
                $basarili = ($proc.ExitCode -eq 0)
            }
        } else {
            $exeYol = $kaldirKomut -replace '"',''
            $proc = Start-Process -FilePath "cmd.exe" -ArgumentList ("/c " + $kaldirKomut) -Wait -PassThru
            $basarili = ($proc.ExitCode -eq 0)
        }
    } catch {
        Yaz ("  Kaldirim hatasi: " + $_.Exception.Message) Red
    }

    if ($basarili) {
        Yaz ("  '" + $hedef.Ad + "' basariyla kaldirildi.") Green
    } else {
        Yaz "  Kaldirim tamamlanamadi veya kullanici iptal etti." Yellow
    }

    # ── ARTIK TARAMA (Leftover) ──
    Write-Host ""
    Yaz "  Artik dosya/registry taraniyor..." Cyan
    $artikSay = 0

    # 1. Registry artigi
    if (Test-Path $hedef.RegYol) {
        try {
            Remove-Item $hedef.RegYol -Recurse -Force -ErrorAction Stop
            $artikSay++
            Yaz "    Registry girisi temizlendi." Green
        } catch {}
    }

    # 2. Install klasoru artigi
    if ($hedef.InstallYol -and (Test-Path $hedef.InstallYol)) {
        $kalanDosya = (Get-ChildItem $hedef.InstallYol -Recurse -File -ErrorAction SilentlyContinue).Count
        if ($kalanDosya -gt 0) {
            Durum "    Kalan dosya" $kalanDosya.ToString() Yellow
            if (Onay "    Artik klasor silinsin mi?") {
                Remove-Item $hedef.InstallYol -Recurse -Force -ErrorAction SilentlyContinue
                $artikSay++
                Yaz "    Install klasoru temizlendi." Green
            }
        }
    }

    # 3. AppData artiklari
    $appDataYollar = @(
        (Join-Path $env:APPDATA $hedef.Ad),
        (Join-Path $env:LOCALAPPDATA $hedef.Ad)
    )
    if ($hedef.Yayinci -and $hedef.Yayinci -ne "-") {
        $appDataYollar += (Join-Path $env:APPDATA $hedef.Yayinci)
        $appDataYollar += (Join-Path $env:LOCALAPPDATA $hedef.Yayinci)
    }
    foreach ($ay in $appDataYollar) {
        if (Test-Path $ay) {
            $artikSay++
            Yaz ("    AppData artigi: " + $ay) DarkGray
            Remove-Item $ay -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    if ($artikSay -gt 0) {
        Yaz ("  {0} artik oge temizlendi." -f $artikSay) Green
    } else {
        Yaz "  Artik dosya/registry bulunamadi." Green
    }
    RaporVeriEkle "program_kaldirici" ("Kaldirildi: " + $hedef.Ad)
}

#endregion

#region ── MODUL 66: YAZILIM GUNCELLEYICI ───────────────────

function YazilimGuncelleyici {
    Baslik "Yazilim Guncelleyici" "66"

    Yaz "  Yuklu programlarin surumler kontrol ediliyor..." Cyan

    # Registry'den program listesi (hizli yontem)
    $uninstYollar = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    $programlar = [System.Collections.Generic.List[PSCustomObject]]::new()

    foreach ($uy in $uninstYollar) {
        if (-not (Test-Path $uy)) { continue }
        Get-ChildItem $uy -ErrorAction SilentlyContinue | ForEach-Object {
            $props = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
            if (-not $props.DisplayName -or -not $props.DisplayVersion) { return }
            if ($props.SystemComponent -eq 1 -or $props.ParentKeyName) { return }

            # Bilinen guncellenebilir programlar
            $programlar.Add([PSCustomObject]@{
                Ad    = $props.DisplayName
                Surum = $props.DisplayVersion
                Yayinci = if ($props.Publisher) { $props.Publisher } else { "-" }
                URLInfo = $props.URLInfoAbout
                URLUpdate = $props.URLUpdateInfo
            })
        }
    }

    $programlar = [System.Collections.Generic.List[PSCustomObject]]::new(
        ($programlar | Sort-Object Ad -Unique)
    )

    # Winget mevcut mu?
    $wingetVar = $false
    try {
        $wingetTest = winget --version 2>$null
        if ($wingetTest) { $wingetVar = $true }
    } catch {}

    Durum "Yuklu program" $programlar.Count.ToString() Cyan
    Durum "Winget" $(if ($wingetVar) {"Mevcut"} else {"Bulunamadi"}) $(if ($wingetVar) {"Green"} else {"Yellow"})
    Write-Host ""

    if ($wingetVar) {
        Yaz "  Winget ile guncellemeleri kontrol ediliyor..." Cyan
        Yaz "  (Bu islem birkaç dakika surebilir)" DarkGray
        Write-Host ""

        try {
            $wingetCikti = winget upgrade 2>$null
            $guncellemeler = [System.Collections.Generic.List[string]]::new()
            $baslik_gecti = $false

            foreach ($satir in $wingetCikti) {
                # Winget cikti basligini atla
                if ($satir -match '^[\-]+$') { $baslik_gecti = $true; continue }
                if (-not $baslik_gecti) { continue }
                if ($satir -match '^\s*$') { continue }
                if ($satir -match 'upgrades available' -or $satir -match 'No installed') { continue }

                $guncellemeler.Add($satir)
            }

            if ($guncellemeler.Count -gt 0) {
                Durum "Guncelleme bekleyen" $guncellemeler.Count.ToString() Yellow
                Write-Host ""
                foreach ($g in $guncellemeler) {
                    Write-Host ("    " + $g) -ForegroundColor Yellow
                }
                Write-Host ""

                if (Onay "Tum guncellemeler yuklennsin mi? (winget upgrade --all)") {
                    Yaz "  Guncellemeler baslatiliyor..." Cyan
                    $proc = Start-Process -FilePath "winget" -ArgumentList "upgrade --all --accept-source-agreements --accept-package-agreements --silent" `
                        -Wait -PassThru -NoNewWindow -ErrorAction Stop
                    if ($proc.ExitCode -eq 0) {
                        Yaz "  Guncellemeler basariyla tamamlandi!" Green
                    } else {
                        Yaz "  Bazi guncellemeler tamamlanamadi. Detay icin winget kullanin." Yellow
                    }
                }
            } else {
                Yaz "  Tum programlar guncel!" Green
            }
        } catch {
            Yaz ("  Winget hatasi: " + $_.Exception.Message) Red
        }
    } else {
        Yaz "  Winget bulunamadi. Manuel kontrol yapiliyor..." Yellow
        Write-Host ""

        # Winget yoksa: bilinen programlarin surumlerini listele
        $eski_olabilir = [System.Collections.Generic.List[PSCustomObject]]::new()
        $bilinen = @{
            "Google Chrome"="chrome"; "Mozilla Firefox"="firefox"; "7-Zip"="7zip";
            "VLC media player"="vlc"; "Notepad++"="notepad++"; "Visual Studio Code"="vscode";
            "Git"="git"; "Node.js"="nodejs"; "Python"="python"; "Discord"="discord";
            "Steam"="steam"; "Spotify"="spotify"; "Brave"="brave"; "Opera"="opera"
        }

        foreach ($p in $programlar) {
            foreach ($b in $bilinen.GetEnumerator()) {
                if ($p.Ad -like ("*" + $b.Key + "*")) {
                    $eski_olabilir.Add([PSCustomObject]@{
                        Ad=$p.Ad; Surum=$p.Surum; Yayinci=$p.Yayinci
                        GuncellemeURL = if ($p.URLUpdate) { $p.URLUpdate } elseif ($p.URLInfo) { $p.URLInfo } else { "-" }
                    })
                    break
                }
            }
        }

        if ($eski_olabilir.Count -gt 0) {
            Yaz ("  {0} bilinen program bulundu:" -f $eski_olabilir.Count) Yellow
            Write-Host ""
            foreach ($e in $eski_olabilir) {
                Write-Host ("    {0,-35}  v{1,-12}  {2}" -f `
                    $e.Ad.Substring(0, [Math]::Min(35, $e.Ad.Length)), `
                    $e.Surum.Substring(0, [Math]::Min(12, $e.Surum.Length)), `
                    $e.Yayinci) -ForegroundColor Gray
            }
            Write-Host ""
            Yaz "  ONERI: Winget yukleyin → 'winget install winget' veya Microsoft Store" Yellow
            Yaz "  Winget ile otomatik guncelleme yapilabilir." DarkGray
        } else {
            Yaz "  Bilinen guncellenebilir program bulunamadi." Gray
        }
    }

    RaporVeriEkle "yazilim_guncelleyici" ("Tarama tamamlandi, " + $programlar.Count + " program")
}

#endregion

#region ── MODUL 67: SISTEM GERI YUKLEME YONETICISI ─────────

function SistemGeriYuklemeYonetici {
    Baslik "Sistem Geri Yukleme Yoneticisi" "67"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    # Geri yukleme acik mi?
    $srDurum = $false
    try {
        $srConfig = Get-CimInstance -ClassName SystemRestoreConfig -Namespace root\default -ErrorAction Stop
        $srDurum = ($srConfig.RPSessionInterval -gt 0)
    } catch {
        try {
            $gpYol = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
            $disabled = (Get-ItemProperty $gpYol -Name "RPSessionInterval" -ErrorAction SilentlyContinue).RPSessionInterval
            $srDurum = ($disabled -ne 0)
        } catch {}
    }

    # Disk kullanimi
    $vssKullanim = ""
    try {
        $vss = vssadmin list shadowstorage 2>$null
        $kullanimSatir = $vss | Where-Object { $_ -match 'Used Shadow Copy Storage' }
        if ($kullanimSatir) {
            $vssKullanim = ($kullanimSatir -split ':')[-1].Trim()
        }
    } catch {}

    Durum "Sistem Geri Yukleme" $(if ($srDurum){"AKTIF"} else {"KAPALI"}) $(if ($srDurum){"Green"} else {"Red"})
    if ($vssKullanim) { Durum "VSS Disk Kullanimi" $vssKullanim Yellow }
    Write-Host ""

    # Mevcut noktalar
    $noktalar = @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue)
    Durum "Geri yukleme noktasi" $noktalar.Count.ToString() Cyan

    if ($noktalar.Count -gt 0) {
        Write-Host ""
        $sira = 0
        foreach ($n in ($noktalar | Sort-Object CreationTime -Descending)) {
            $sira++
            $yas = ((Get-Date) - $n.CreationTime).Days
            $yasStr = if ($yas -eq 0) { "bugun" } elseif ($yas -eq 1) { "dun" } else { "$yas gun" }
            $tipStr = switch ($n.RestorePointType) {
                0 {"Uygulama"} 6 {"Restore"} 7 {"Checkpoint"} 10 {"Cihaz"} 12 {"Install"} 13 {"Modify"} default {"Diger"}
            }
            $renk = if ($yas -gt 60) {"DarkGray"} elseif ($yas -gt 30) {"Yellow"} else {"White"}
            Write-Host ("    {0,2}. [{1}]  {2,-8}  {3,-38}  {4}" -f $sira, `
                $n.CreationTime.ToString("dd.MM.yy HH:mm"), $tipStr, `
                $n.Description.Substring(0, [Math]::Min(38, $n.Description.Length)), $yasStr) -ForegroundColor $renk
        }
    }

    Write-Host ""
    Yaz "  Islemler:" Cyan
    Yaz "    [1]  Yeni geri yukleme noktasi olustur" White
    Yaz "    [2]  Eski noktalari temizle (son 3 haric)" White
    Yaz "    [3]  Geri yuklemeyi AKTiF et (kapali ise)" White
    Yaz "    [0]  Geri" White
    Write-Host ""
    Write-Host "  Secim: " -ForegroundColor Yellow -NoNewline
    $secim = if ($env:SISTEMBAK_GUI -eq '1') { "1" } else { (Read-Host).Trim() }

    switch ($secim) {
        "1" {
            $etiket = "SistemBakim_Manuel_{0}" -f (Get-Date -Format "dd.MM.yyyy_HHmm")
            try {
                Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
                Checkpoint-Computer -Description $etiket -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
                Yaz ("  Geri yukleme noktasi olusturuldu: " + $etiket) Green
            } catch {
                Yaz ("  Hata: " + $_.Exception.Message) Red
                Yaz "  Not: Ayni gun icinde 1'den fazla nokta olusturulamayabilir (Windows sinirlamasi)." DarkGray
            }
        }
        "2" {
            if ($noktalar.Count -le 3) {
                Yaz "  3 veya daha az nokta var, temizlik gerekmez." Green
                return
            }
            $silinecek = $noktalar | Sort-Object CreationTime | Select-Object -First ($noktalar.Count - 3)
            Yaz ("  {0} eski nokta silinecek (son 3 korunacak)." -f $silinecek.Count) Yellow
            if (Onay "Devam edilsin mi?") {
                # vssadmin ile en eski snapshot'lari sil
                try {
                    vssadmin delete shadows /for=C: /oldest /quiet 2>$null | Out-Null
                    Yaz "  Eski geri yukleme noktalari temizlendi." Green
                } catch {
                    Yaz "  Temizlik sirasinda hata olustu." Red
                }
            }
        }
        "3" {
            try {
                Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop
                Yaz "  Sistem Geri Yukleme C: icin AKTIF edildi." Green
            } catch {
                Yaz ("  Hata: " + $_.Exception.Message) Red
            }
        }
        default { return }
    }
    RaporVeriEkle "geri_yukleme" "Islem tamamlandi"
}

#endregion

#region ── MODUL 68: WINDOWS HIZMET KONFIGURATORU ────────────

function HizmetKonfiguratoru {
    Baslik "Windows Hizmet Konfiguratoru" "68"
    if (-not (YoneticiKontrol)) { Yaz "  Yonetici yetkisi gereklidir." Red; return }

    # ── PROFIL TANIMLARI ──
    # Her profil: ServisAdi → HedefDurum (Disabled / Manual / Automatic)
    # Sadece Microsoft servisleri, 3. parti dokunulmaz
    # "Korunacaklar" listesi: asla degistirilmemesi gerekenler

    $korunanlar = @(
        "wuauserv","WinDefend","mpssvc","EventLog","Dhcp","Dnscache","LanmanWorkstation",
        "LanmanServer","RpcSs","RpcEptMapper","LSM","Winmgmt","Schedule","ProfSvc",
        "BFE","CryptSvc","DcomLaunch","Power","PlugPlay","SamSs","SecurityHealthService"
    )

    $profiller = @{
        "1" = @{
            Ad = "Oyun Modu"
            Aciklama = "Arka plan servislerini minimize eder, maksimum performans"
            Servisler = @{
                "SysMain"          = "Disabled"   # SuperFetch - RAM baskisi azalir
                "WSearch"          = "Disabled"   # Windows Search Indexer
                "DiagTrack"        = "Disabled"   # Telemetri
                "dmwappushservice"  = "Disabled"   # WAP push
                "MapsBroker"       = "Disabled"   # Offline Maps
                "TabletInputService"= "Disabled"  # Dokunmatik klavye (masaustunde gereksiz)
                "WbioSrvc"         = "Disabled"   # Biyometrik (oyunda gereksiz)
                "lfsvc"            = "Disabled"   # Konum servisi
                "wisvc"            = "Disabled"   # Windows Insider
                "RetailDemo"       = "Disabled"   # Magaza demo modu
                "Fax"              = "Disabled"   # Faks servisi
                "PrintNotify"      = "Manual"     # Yazici bildirimleri
                "Spooler"          = "Manual"     # Yazici kuyrugu (oyunda gereksiz)
            }
        }
        "2" = @{
            Ad = "Is / Ofis Modu"
            Aciklama = "Yazici, arama ve uretkenlik servisleri aktif, gereksizler kapali"
            Servisler = @{
                "SysMain"          = "Automatic"  # SuperFetch acik - SSD onbellekleme
                "WSearch"          = "Automatic"  # Dosya arama aktif
                "Spooler"          = "Automatic"  # Yazici kuyrugu aktif
                "PrintNotify"      = "Automatic"  # Yazici bildirimleri aktif
                "DiagTrack"        = "Disabled"   # Telemetri hala kapali
                "dmwappushservice"  = "Disabled"
                "MapsBroker"       = "Disabled"
                "RetailDemo"       = "Disabled"
                "Fax"              = "Disabled"
                "wisvc"            = "Disabled"
                "TabletInputService"= "Manual"
                "WbioSrvc"         = "Manual"     # Parmak izi giris (is icin faydali)
                "lfsvc"            = "Manual"
            }
        }
        "3" = @{
            Ad = "Gunluk Kullanim"
            Aciklama = "Dengeli profil: cogu servis varsayilan, sadece gereksizler kapali"
            Servisler = @{
                "SysMain"          = "Automatic"
                "WSearch"          = "Automatic"
                "Spooler"          = "Automatic"
                "PrintNotify"      = "Automatic"
                "DiagTrack"        = "Manual"     # Telemetri minimum
                "dmwappushservice"  = "Manual"
                "MapsBroker"       = "Manual"
                "TabletInputService"= "Manual"
                "WbioSrvc"         = "Manual"
                "lfsvc"            = "Manual"
                "wisvc"            = "Disabled"
                "RetailDemo"       = "Disabled"
                "Fax"              = "Disabled"
            }
        }
    }

    # ── MEVCUT DURUMLARI TARA ──
    Yaz "  Mevcut servis durumlari taraniyor..." Cyan
    $mevcutBilgi = @{}
    $tumServisler = @()
    foreach ($p in $profiller.Values) { $tumServisler += $p.Servisler.Keys }
    $tumServisler = $tumServisler | Sort-Object -Unique

    foreach ($srvAd in $tumServisler) {
        try {
            $srv = Get-Service -Name $srvAd -ErrorAction Stop
            $baslama = (Get-CimInstance Win32_Service -Filter "Name='$srvAd'" -ErrorAction Stop).StartMode
            $mevcutBilgi[$srvAd] = @{ Durum=$srv.Status.ToString(); Baslama=$baslama; Goruntu=$srv.DisplayName }
        } catch {
            $mevcutBilgi[$srvAd] = $null  # Servis bu sistemde yok
        }
    }

    $bulunan = ($mevcutBilgi.Values | Where-Object { $_ -ne $null }).Count
    Durum "Taninan servisler" ("{0}/{1}" -f $bulunan, $tumServisler.Count)
    Write-Host ""

    # ── PROFIL SECIMI ──
    Yaz "  Hazir Profiller:" Yellow
    foreach ($pk in ($profiller.Keys | Sort-Object)) {
        $p = $profiller[$pk]
        Write-Host ("    [{0}] {1}" -f $pk, $p.Ad) -ForegroundColor Green
        Write-Host ("        {0}" -f $p.Aciklama) -ForegroundColor DarkGray
        # Kac servis degisecek?
        $degisecek = 0
        foreach ($sa in $p.Servisler.Keys) {
            $mevcut = $mevcutBilgi[$sa]
            if ($mevcut -eq $null) { continue }
            $hedef = $p.Servisler[$sa]
            if ($mevcut.Baslama -ne $hedef) { $degisecek++ }
        }
        Write-Host ("        {0} servis degisecek" -f $degisecek) -ForegroundColor DarkGray
    }
    Write-Host ("    [4] Iptal") -ForegroundColor DarkGray
    Write-Host ""

    $secim = Read-Host "  Profil seciniz (1-4)"
    if ($secim -notin @("1","2","3")) {
        Yaz "  Islem iptal edildi." DarkGray; return
    }

    $secilenProfil = $profiller[$secim]
    Yaz ("  Secilen profil: " + $secilenProfil.Ad) Green
    Write-Host ""

    # ── YEDEK AL (geri donme icin) ──
    $yedekDosya = Join-Path $LOG_KLASOR ("HizmetYedek_{0}.json" -f (Get-Date -Format "yyyyMMdd_HHmm"))
    $yedekVeri = @{}
    foreach ($sa in $secilenProfil.Servisler.Keys) {
        $mevcut = $mevcutBilgi[$sa]
        if ($mevcut -ne $null) {
            $yedekVeri[$sa] = @{ OncekiBaslama=$mevcut.Baslama; OncekiDurum=$mevcut.Durum; Goruntu=$mevcut.Goruntu }
        }
    }
    $yedekVeri | ConvertTo-Json -Depth 3 | Set-Content $yedekDosya -Encoding UTF8
    Yaz ("  Yedek kaydedildi: " + (Split-Path $yedekDosya -Leaf)) DarkGray

    # ── ONAY ──
    $degisecekSayisi = 0
    foreach ($sa in $secilenProfil.Servisler.Keys) {
        $mevcut = $mevcutBilgi[$sa]
        if ($mevcut -eq $null) { continue }
        if ($mevcut.Baslama -ne $secilenProfil.Servisler[$sa]) { $degisecekSayisi++ }
    }

    if ($degisecekSayisi -eq 0) {
        Yaz "  Sistem zaten bu profile uygun. Degisiklik gerekmiyor." Green; return
    }

    if (-not (Onay ("{0} adet servis '{1}' profiline gore ayarlanacak. Devam?" -f $degisecekSayisi, $secilenProfil.Ad))) { return }

    # ── UYGULA ──
    $basarili = 0; $atlanan = 0
    foreach ($sa in $secilenProfil.Servisler.Keys) {
        $mevcut = $mevcutBilgi[$sa]
        if ($mevcut -eq $null) { continue }

        # Koruma kontrolu (ekstra guvenlik)
        if ($sa -in $korunanlar) { $atlanan++; continue }

        $hedef = $secilenProfil.Servisler[$sa]
        if ($mevcut.Baslama -eq $hedef) { continue }  # Zaten dogru durumda

        try {
            # Baslama tipini degistir
            Set-Service -Name $sa -StartupType $hedef -ErrorAction Stop

            # Disabled ise durdur, Automatic ise baslat
            if ($hedef -eq "Disabled") {
                Stop-Service -Name $sa -Force -ErrorAction SilentlyContinue
            } elseif ($hedef -eq "Automatic") {
                Start-Service -Name $sa -ErrorAction SilentlyContinue
            }

            $eski = $mevcut.Baslama
            Write-Host ("    {0,-28} {1,-12} -> {2}" -f $mevcut.Goruntu, $eski, $hedef) -ForegroundColor $(if ($hedef -eq "Disabled"){"Yellow"} elseif ($hedef -eq "Automatic"){"Green"} else {"Cyan"})
            $basarili++
        } catch {
            Write-Host ("    {0,-28} HATA: {1}" -f $mevcut.Goruntu, $_.Exception.Message) -ForegroundColor Red
            $atlanan++
        }
    }

    Write-Host ""
    Yaz ("{0} servis ayarlandi, {1} atlandi." -f $basarili, $atlanan) Green
    Yaz ("  Geri almak icin: " + (Split-Path $yedekDosya -Leaf) + " dosyasindaki degerleri kullanin.") DarkGray
    Yaz "  Bazi degisiklikler yeniden baslatma sonrasi etkili olacaktir." DarkGray
    RaporVeriEkle "hizmet_konfigurator" ("{0} servis '{1}' profiline ayarlandi" -f $basarili, $secilenProfil.Ad)
}

#endregion

#region ── MODUL 69: AG MONITORU ─────────────────────────────

function AgMonitoru {
    Baslik "Ag Monitoru (Canli Bant Genisligi)" "69"

    # ── AKTIF AG ARAYUZLERINI BUL ──
    $arayuzler = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
        Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -ne 'Loopback' }

    if ($arayuzler.Count -eq 0) {
        Yaz "  Aktif ag arayuzu bulunamadi." Red; return
    }

    # Arayuz bilgisi goster
    Yaz "  Aktif ag arayuzleri:" Cyan
    foreach ($a in $arayuzler) {
        $hizMbps = [math]::Round($a.Speed / 1MB, 0)
        Write-Host ("    - {0} ({1}, {2} Mbps)" -f $a.Name, $a.NetworkInterfaceType, $hizMbps) -ForegroundColor DarkGray
    }
    Write-Host ""

    # ── ANLIK OLCUM (2 aralikli delta) ──
    Yaz "  Bant genisligi olculuyor (3 saniye)..." Cyan
    Write-Host ""

    # 1. olcum
    $olcum1 = @{}
    foreach ($a in $arayuzler) {
        $stat = $a.GetIPStatistics()
        $olcum1[$a.Id] = @{ Rx=$stat.BytesReceived; Tx=$stat.BytesSent; Zaman=[DateTime]::Now }
    }

    Start-Sleep -Seconds 3

    # 2. olcum + delta hesapla
    $topRx = 0; $topTx = 0
    foreach ($a in $arayuzler) {
        $stat = $a.GetIPStatistics()
        $dt = ([DateTime]::Now - $olcum1[$a.Id].Zaman).TotalSeconds
        if ($dt -le 0) { $dt = 1 }

        $rxSaniye = [math]::Round(($stat.BytesReceived - $olcum1[$a.Id].Rx) / $dt, 0)
        $txSaniye = [math]::Round(($stat.BytesSent - $olcum1[$a.Id].Tx) / $dt, 0)
        $topRx += $rxSaniye; $topTx += $txSaniye

        # Anlik hiz formatlama
        $rxStr = if ($rxSaniye -ge 1MB) { ("{0:N1} MB/s" -f ($rxSaniye/1MB)) }
                 elseif ($rxSaniye -ge 1KB) { ("{0:N0} KB/s" -f ($rxSaniye/1KB)) }
                 else { ("{0} B/s" -f $rxSaniye) }
        $txStr = if ($txSaniye -ge 1MB) { ("{0:N1} MB/s" -f ($txSaniye/1MB)) }
                 elseif ($txSaniye -ge 1KB) { ("{0:N0} KB/s" -f ($txSaniye/1KB)) }
                 else { ("{0} B/s" -f $txSaniye) }

        $renk = if ($rxSaniye -ge 1MB -or $txSaniye -ge 1MB) {"Yellow"} else {"Green"}
        Write-Host ("    {0,-30} Indirme: {1,-14} Yukleme: {2}" -f $a.Name, $rxStr, $txStr) -ForegroundColor $renk
    }

    Write-Host ""
    $topRxStr = if ($topRx -ge 1MB) { ("{0:N1} MB/s" -f ($topRx/1MB)) }
                elseif ($topRx -ge 1KB) { ("{0:N0} KB/s" -f ($topRx/1KB)) }
                else { ("{0} B/s" -f $topRx) }
    $topTxStr = if ($topTx -ge 1MB) { ("{0:N1} MB/s" -f ($topTx/1MB)) }
                elseif ($topTx -ge 1KB) { ("{0:N0} KB/s" -f ($topTx/1KB)) }
                else { ("{0} B/s" -f $topTx) }
    Durum "Toplam Indirme" $topRxStr
    Durum "Toplam Yukleme" $topTxStr

    # ── TOPLAM TRANSFER ISTATISTIKLERI ──
    Write-Host ""
    Yaz "  Oturum basindan beri toplam transfer:" Cyan
    foreach ($a in $arayuzler) {
        $stat = $a.GetIPStatistics()
        $rxToplam = BoyutFormatla $stat.BytesReceived
        $txToplam = BoyutFormatla $stat.BytesSent
        Write-Host ("    {0,-30} Rx: {1,-10}  Tx: {2}" -f $a.Name, $rxToplam, $txToplam) -ForegroundColor DarkGray
    }

    # ── UYGULAMA BAZLI AG BAGLANTILARI ──
    Write-Host ""
    Yaz "  Uygulama bazli aktif ag baglantilari:" Yellow
    Write-Host ("    {0,-6} {1,-28} {2,-24} {3}" -f "PID","Uygulama","Uzak Adres","Durum") -ForegroundColor DarkGray
    Write-Host ("    " + ("-" * 78)) -ForegroundColor DarkGray

    try {
        $baglantilar = Get-NetTCPConnection -State Established -ErrorAction Stop |
            Where-Object { $_.RemoteAddress -notmatch '^(127\.|::1|0\.0\.)' -and $_.OwningProcess -ne 0 }

        # PID bazli gruplama
        $gruplar = $baglantilar | Group-Object OwningProcess | Sort-Object Count -Descending | Select-Object -First 20

        $uygulamaSayac = 0
        foreach ($g in $gruplar) {
            $pid = [int]$g.Name
            try {
                $proc = Get-Process -Id $pid -ErrorAction Stop
                $procAd = $proc.ProcessName
            } catch {
                $procAd = "(?)"
            }

            # Baglanti sayisi
            $bagSayisi = $g.Count
            $ilkBag = $g.Group | Select-Object -First 1
            $uzakAdres = "{0}:{1}" -f $ilkBag.RemoteAddress, $ilkBag.RemotePort
            $durumStr = if ($bagSayisi -gt 1) { "Established ({0} bag.)" -f $bagSayisi } else { "Established" }

            $renk = if ($bagSayisi -ge 10) {"Yellow"} elseif ($bagSayisi -ge 5) {"Cyan"} else {"White"}
            Write-Host ("    {0,-6} {1,-28} {2,-24} {3}" -f $pid, $procAd, $uzakAdres, $durumStr) -ForegroundColor $renk
            $uygulamaSayac++
        }

        if ($uygulamaSayac -eq 0) {
            Yaz "    Aktif dis baglanti bulunamadi." DarkGray
        }
    } catch {
        Yaz ("    Baglanti bilgisi alinamadi: " + $_.Exception.Message) Red
    }

    # ── DINLEYEN PORTLAR (GUVENLIK AMAÇLI) ──
    Write-Host ""
    Yaz "  Dinleyen (LISTEN) portlar:" Cyan
    try {
        $dinleyenler = Get-NetTCPConnection -State Listen -ErrorAction Stop |
            Where-Object { $_.LocalAddress -notmatch '^(::1)$' } |
            Sort-Object LocalPort | Select-Object -First 15

        foreach ($d in $dinleyenler) {
            $pid = $d.OwningProcess
            try { $procAd = (Get-Process -Id $pid -ErrorAction Stop).ProcessName } catch { $procAd = "(?)" }
            $adres = "{0}:{1}" -f $d.LocalAddress, $d.LocalPort
            $renk = if ($d.LocalPort -lt 1024) {"Yellow"} else {"DarkGray"}
            Write-Host ("    Port {0,-22} PID {1,-6} {2}" -f $adres, $pid, $procAd) -ForegroundColor $renk
        }
    } catch {
        Yaz "    Port bilgisi alinamadi." Red
    }

    # ── DNS CACHE ISTATISTIKLERI ──
    Write-Host ""
    Yaz "  DNS Onbellek istatistikleri:" Cyan
    try {
        $dnsCache = Get-DnsClientCache -ErrorAction Stop
        $dnsSayisi = ($dnsCache | Measure-Object).Count
        $benzersizDomain = ($dnsCache | Select-Object -ExpandProperty Entry -Unique | Measure-Object).Count
        Durum "Onbellekteki kayitlar" $dnsSayisi.ToString()
        Durum "Benzersiz domain" $benzersizDomain.ToString()

        if ($dnsSayisi -gt 0) {
            Yaz "  Son erisilenler:" DarkGray
            $dnsCache | Select-Object Entry -Unique | Select-Object -First 10 | ForEach-Object {
                Write-Host ("    - {0}" -f $_.Entry) -ForegroundColor DarkGray
            }
        }
    } catch {
        Yaz "    DNS onbellek bilgisi alinamadi." DarkGray
    }

    Write-Host ""
    Yaz "  Olcum tamamlandi." Green
    RaporVeriEkle "ag_monitor" ("Indirme: {0}, Yukleme: {1}, {2} aktif baglanti" -f $topRxStr, $topTxStr, $uygulamaSayac)
}

#endregion

#region ── ANA DÖNGÜ ─────────────────────────────────────────

function Ana {
    Add-Content $LOG_DOSYA ("="*64)
    Add-Content $LOG_DOSYA ("SistemBakim v{0} -- OTURUM BASLADI: {1}" -f $SURUM,(Get-Date -Format "dd.MM.yyyy HH:mm:ss"))
    Add-Content $LOG_DOSYA ("Bilgisayar: {0} | Kullanici: {1}" -f $env:COMPUTERNAME,$env:USERNAME)
    Add-Content $LOG_DOSYA ("="*64)

    # Modul adi haritasi (arama ve gecmis icin)
    $modAdlari = @{
        "1"="Disk Analizi"; "2"="Yinelenen Dosyalar"; "3"="Kapsamli Temizlik";
        "4"="SMART Disk Sagligi"; "5"="Crash Dump Temizle"; "6"="Shadow ve Restore";
        "7"="Windows Log Temizle"; "8"="Downloads Analizi"; "9"="Sistem Tarama SFC";
        "10"="Olay Gunlugu"; "11"="Servis Kontrolu"; "12"="Baslangic Analizi";
        "13"="Kaynak Durumu"; "14"="Guc Plani"; "15"="Ag Tanilamasi";
        "16"="Guvenlik Kontrolu"; "17"="Gelismis Guvenlik"; "18"="Gelistirici Araclari";
        "19"="Donanim Raporu"; "20"="HTML Dashboard"; "21"="Saglik Skoru";
        "22"="Haftalik Zamanla"; "23"="Hazir Profil Sec"; "24"="Geri Yukleme Noktasi";
        "25"="Tam Bakim"; "26"="FPS Oyun Optimizasyonu"; "27"="RAM Optimizasyonu";
        "28"="Surec Temizleyici"; "29"="Bloatware Kaldirici"; "30"="Surucu Kontrolu";
        "31"="Windows Update Yoneticisi"; "32"="Disk Optimize Defrag TRIM";
        "33"="WinSxS Component Store Temizligi"; "34"="Pil Sagligi Raporu";
        "35"="Internet Hiz Testi"; "36"="Bant Genisligi Optimizasyonu";
        "37"="DirectX GPU Tani"; "38"="Oyun Modu Yoneticisi";
        "39"="Hesap Guvenlik Denetimi"; "40"="Suphe Uyandiran Baslangic";
        "41"="Format Sonrasi Sihirbaz"; "42"="Windows Performans Tweaks";
        "43"="Sanal Bellek Pagefile Optimize"; "44"="Donanim Skoru Oneri";
        "45"="GPU Optimize NVIDIA AMD"; "46"="Defender Oyun Istisnalari";
        "47"="Monitor Hz Cozunurluk";
        "48"="HyperV VBS HVCI Kapat";
        "49"="Tarayici Temizleyici";
        "50"="OEM Bloatware Tespiti";
        "51"="Boot Suresi Analizi";
        "52"="Sag Tik Menu Temizle";
        "53"="DNS Benchmark";
        "54"="WiFi Ag Taramasi";
        "55"="Bos Klasor Bulucu"; "56"="Dosya Kirpici Shredder";
        "57"="USB Cihaz Gecmisi"; "58"="Hosts Dosyasi Editoru";
        "59"="Zamanlama Gorevi Temizle";
        "60"="Gizlilik Kalkani AntiSpy"; "61"="Turbo Boost Modu";
        "62"="Baglam Menusu Yoneticisi"; "63"="Baslangic Gecikme Yoneticisi";
        "64"="Registry Temizleyici"; "65"="Program Kaldirici";
        "66"="Yazilim Guncelleyici"; "67"="Sistem Geri Yukleme Yoneticisi";
        "68"="Windows Hizmet Konfiguratoru"; "69"="Ag Monitoru"
    }

    while ($true) {
        BannerGoster
        MenuGoster
        $secim      = Read-Host
        $secimTemiz = $secim.Trim()

        # ---- Arama / Gecmis modu ----
        if ($secimTemiz -ne "0" -and $secimTemiz -notmatch '^\d+$') {

            if ($secimTemiz -eq "?") {
                Write-Host ""
                Write-Host "  -- Son Calistirilanlar --" -ForegroundColor Cyan
                if ($global:SonCalistirilanlar.Count -eq 0) {
                    Yaz "  Henuz hicbir modul calistirilmadi." Gray
                } else {
                    $global:SonCalistirilanlar | ForEach-Object { Yaz ("    " + $_) Gray }
                }
                Write-Host ""
                Write-Host "  [Devam icin bir tusa basin...]" -ForegroundColor DarkGray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                continue
            }

            # Modul arama
            $kelime      = $secimTemiz.ToLower()
            $bulunanlar  = @($modAdlari.GetEnumerator() |
                             Where-Object { $_.Value.ToLower() -match $kelime } |
                             Sort-Object { [int]$_.Key })

            Write-Host ""
            if ($bulunanlar.Count -gt 0) {
                Write-Host ("  Arama: '" + $secimTemiz + "'") -ForegroundColor Cyan
                Write-Host ""
                $bulunanlar | ForEach-Object {
                    Write-Host ("    " + $_.Key.PadLeft(2) + "  >  " + $_.Value) -ForegroundColor Gray
                }
                Write-Host ""
                Write-Host "  Secmek icin numara girin (bos=geri): " -ForegroundColor Yellow -NoNewline
                $secimTemiz = (Read-Host).Trim()
                if ($secimTemiz -eq "") { continue }
            } else {
                Yaz ("  '" + $secimTemiz + "' ile eslesen modul bulunamadi.") Red
                Yaz "  Ipucu: 0-54 arasi numara veya modul adi yazin. ? = gecmis" DarkGray
                Write-Host ""
                Write-Host "  [Devam icin bir tusa basin...]" -ForegroundColor DarkGray
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                continue
            }
        }

        # ---- Gecmis kaydet ----
        if ($secimTemiz -match '^\d+$' -and $secimTemiz -ne "0") {
            $gAdi = $modAdlari[$secimTemiz]
            if ($gAdi) {
                $gKayit = $secimTemiz.PadLeft(2) + "  " + $gAdi + "  [" + (Get-Date -Format "HH:mm") + "]"
                $global:SonCalistirilanlar.Insert(0, $gKayit)
                if ($global:SonCalistirilanlar.Count -gt 5) { $global:SonCalistirilanlar.RemoveAt(5) }
            }
        }

        # ---- Modül calistir ----
        switch ($secimTemiz) {
            "1"  { DiskAnalizi }
            "2"  { DuplicateBul }
            "3"  { KapsamliTemizlik }
            "4"  { SmartDiskSagligi }
            "5"  { CrashDumpTemizle }
            "6"  { ShadowVeRestore }
            "7"  { WindowsLogTemizle }
            "8"  { DownloadsAnalizi }
            "9"  { SistemTara }
            "10" { OlayGunlugu }
            "11" { ServisKontrol }
            "12" { BaslangicAnalizi }
            "13" { KaynakDurumu }
            "14" { GucPlani }
            "15" { AgTanilamasi }
            "16" { GuvenlikKontrol }
            "17" { GelismisGuvenlik }
            "18" { GelistiriciAraclari }
            "19" { DonanımRaporu }
            "20" { HtmlDashboard }
            "21" { SaglikSkoru }
            "22" { OtomasyonAyarla }
            "23" { ProfilSec }
            "24" { GeriYuklemeNoktasi }
            "25" { TamBakim }
            "26" { FpsOyunOptimizasyonu }
            "27" { RamOptimizasyonu }
            "28" { SurecTemizleyici }
            "29" { BloatwareKaldirici }
            "30" { SurucuKontrol }
            "31" { WindowsUpdateYonetici }
            "32" { DiskOptimize }
            "33" { WinSxSTemizle }
            "34" { PilSagligi }
            "35" { InternetHiziTesti }
            "36" { BantGenisligiOptimize }
            "37" { DirectXGPUTani }
            "38" { OyunModuYonetici }
            "39" { HesapGuvenlikDenetimi }
            "40" { SuphesizBaslangic }
            "41" { FormatSonrasiSihirbaz }
            "42" { WindowsPerformansTweaks }
            "43" { SanalBellekOptimize }
            "44" { DonanımSkoruVeOneri }
            "45" { GPUOptimize }
            "46" { DefenderOyunIstisna }
            "47" { MonitorOptimize }
            "48" { HyperVVBSKapat }
            "49" { TarayiciTemizleyici }
            "50" { OEMBloatwareTespiti }
            "51" { BootSuresiAnalizi }
            "52" { SagTikMenuTemizle }
            "53" { DNSBenchmark }
            "54" { WiFiCihazTarama }
            "55" { BosKlasorBulucu }
            "56" { DosyaKirpici }
            "57" { USBCihazGecmisi }
            "58" { HostsDosyasiEditoru }
            "59" { ZamanlamaGoreviTemizle }
            "60" { GizlilikKalkani }
            "61" { TurboBoostModu }
            "62" { BaglamMenusuYonetici }
            "63" { BaslangicGecikmeYonetici }
            "64" { RegistryTemizleyici }
            "65" { ProgramKaldirici }
            "66" { YazilimGuncelleyici }
            "67" { SistemGeriYuklemeYonetici }
            "68" { HizmetKonfiguratoru }
            "69" { AgMonitoru }
            "0"  {
                Write-Host ""
                Write-Host "  ============================================" -ForegroundColor DarkCyan
                Write-Host ("  Log     : " + $LOG_DOSYA) -ForegroundColor Cyan
                Write-Host ("  Raporlar: " + $LOG_KLASOR) -ForegroundColor Cyan
                Write-Host ("  Iyi gunler, " + $env:USERNAME + "!") -ForegroundColor Green
                Write-Host "  ============================================" -ForegroundColor DarkCyan
                Add-Content $LOG_DOSYA ("OTURUM SONA ERDI: {0}" -f (Get-Date -Format "HH:mm:ss"))
                return
            }
            default { Yaz ("  Gecersiz secim '" + $secimTemiz + "'. 0-69 arasi girin veya modul adi yazin.") Red }
        }

        Write-Host ""
        Write-Host "  [Devam icin bir tusa basin...]" -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# CALISTIR (dot-source ile yuklendiyse Ana cagrilmaz)
if ($MyInvocation.InvocationName -ne '.') { Ana }
