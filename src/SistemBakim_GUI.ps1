# ================================================================
#   SistemBakim v5.0 -- Modern Dashboard Arayuzu
#   Tamamen yeni UI/UX: Dashboard, Navigasyon, Gomulu Terminal
# ================================================================

# STA kontrolu (WPF icin zorunlu)
if ([System.Threading.Thread]::CurrentThread.ApartmentState -ne "STA") {
    $myPath = $MyInvocation.MyCommand.Path
    Start-Process PowerShell -ArgumentList "-STA -NoProfile -ExecutionPolicy Bypass -File `"$myPath`"" -Verb RunAs
    exit
}

# Yonetici kontrolu
$_yon = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $_yon.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $myPath = $MyInvocation.MyCommand.Path
    Start-Process PowerShell -ArgumentList "-STA -NoProfile -ExecutionPolicy Bypass -File `"$myPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# == UTF-8 ENCODING ZORLAMA ========================================
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$OutputEncoding = [System.Text.Encoding]::UTF8

$global:KLASOR  = Split-Path $MyInvocation.MyCommand.Path
$global:BACKEND = Join-Path $global:KLASOR "SistemBakim_v5.ps1"

# == IKON TANIMLARI =============================================
$global:IKONLAR = @{
    "disk"      = [string][char]0xEDA2
    "temizlik"  = [string][char]0xE74D
    "sistem"    = [string][char]0xE713
    "ag"        = [string][char]0xE774
    "guvenlik"  = [string][char]0xE72E
    "oyun"      = [string][char]0xE7FC
    "donanim"   = [string][char]0xE7F7
    "rapor"     = [string][char]0xE9F9
    "hiz"       = [string][char]0xECAD
    "bakim"     = [string][char]0xE90F
    "dev"       = [string][char]0xE943
    "wifi"      = [string][char]0xE701
}

# == MODUL TANIMLARI =============================================
$global:MODULLER = [ordered]@{
    "1"  = @{ Ad="Disk Analizi";           Aciklama="Tüm sürücülerinizin doluluk oranını gösterir, en büyük dosya ve klasörleri listeler"; Func="DiskAnalizi"; Renk="#60A5FA"; IkonKat="temizlik" }
    "2"  = @{ Ad="Yinelenen Dosya";        Aciklama="MD5 hash ile aynı içerikli kopya dosyaları bulur, alan kazandırmanızı sağlar"; Func="DuplicateBul"; Renk="#60A5FA"; IkonKat="temizlik" }
    "3"  = @{ Ad="Kapsamlı Temizlik";  Aciklama="Temp, cache, log ve 19 farklı konumdaki gereksiz dosyaları tek seferde siler"; Func="KapsamliTemizlik"; Renk="#60A5FA"; IkonKat="temizlik" }
    "4"  = @{ Ad="SMART Disk";             Aciklama="Diskinizin sağlık durumunu, sıcaklığını ve arızaya ne kadar yakın olduğunu gösterir"; Func="SmartDiskSagligi"; Renk="#FB923C"; IkonKat="donanim" }
    "5"  = @{ Ad="Crash Dump";             Aciklama="Windows çökme (BSOD) dump dosyalarını temizleyerek disk alanı açar"; Func="CrashDumpTemizle"; Renk="#60A5FA"; IkonKat="temizlik" }
    "6"  = @{ Ad="Shadow & Restore";       Aciklama="Sistem geri yükleme noktalarını listeler, eski olanları silerek alan kazandırır"; Func="ShadowVeRestore"; Renk="#60A5FA"; IkonKat="temizlik" }
    "7"  = @{ Ad="Log Temizle";            Aciklama="Windows olay günlüklerini (Event Log) temizler, yüzlerce MB alan açabilir"; Func="WindowsLogTemizle"; Renk="#60A5FA"; IkonKat="temizlik" }
    "8"  = @{ Ad="İndirilenler Analizi"; Aciklama="İndirilenler klasöründeki büyük ve eski dosyaları listeler, temizlik önerir"; Func="DownloadsAnalizi"; Renk="#60A5FA"; IkonKat="temizlik" }
    "9"  = @{ Ad="Sistem Tarama";          Aciklama="SFC ve DISM ile bozuk Windows dosyalarını tarar ve otomatik onarır"; Func="SistemTara"; Renk="#34D399"; IkonKat="sistem" }
    "10" = @{ Ad="Olay Günlüğü";  Aciklama="Son BSOD, kritik hata ve uyarıları analiz eder, sorun kaynaklarını gösterir"; Func="OlayGunlugu"; Renk="#34D399"; IkonKat="sistem" }
    "11" = @{ Ad="Servis Kontrol";         Aciklama="Arka planda çalışan gereksiz servisleri tespit eder, kapatarak hız kazandırır"; Func="ServisKontrol"; Renk="#34D399"; IkonKat="sistem" }
    "12" = @{ Ad="Başlangıç Analizi"; Aciklama="Bilgisayar açılışında çalışan programları listeler, yavaşlatanları gösterir"; Func="BaslangicAnalizi"; Renk="#34D399"; IkonKat="sistem" }
    "13" = @{ Ad="Kaynak Durumu";          Aciklama="Anlık CPU, RAM, GPU ve disk kullanımını canlı olarak izlemenizi sağlar"; Func="KaynakDurumu"; Renk="#34D399"; IkonKat="sistem" }
    "14" = @{ Ad="Güç Planı";       Aciklama="Güç planını Yüksek Performans veya Ultimate olarak ayarlar, hız artırır"; Func="GucPlani"; Renk="#34D399"; IkonKat="sistem" }
    "15" = @{ Ad="Ağ Tanılaması";   Aciklama="DNS, Winsock ve TCP ayarlarını kontrol eder, internet sorunlarını giderir"; Func="AgTanilamasi"; Renk="#38BDF8"; IkonKat="ag" }
    "16" = @{ Ad="Güvenlik Kontrol";  Aciklama="Firewall, Defender ve antivirüsünüzn aktif olup olmadığını kontrol eder"; Func="GuvenlikKontrol"; Renk="#F87171"; IkonKat="guvenlik" }
    "17" = @{ Ad="Gelişmiş Güvenlik"; Aciklama="Açık portları, RDP durumunu, BitLocker ve hosts dosyasını denetler"; Func="GelismisGuvenlik"; Renk="#F87171"; IkonKat="guvenlik" }
    "18" = @{ Ad="Geliştirici";       Aciklama="Node.js, Docker, NuGet, pip cache ve geçici dosyalarını temizler"; Func="GelistiriciAraclari"; Renk="#FB923C"; IkonKat="dev" }
    "19" = @{ Ad="Donanım Raporu";    Aciklama="BIOS, USB cihazlar, termal bilgiler ve güç durumu hakkında detaylı rapor"; Func="DonanımRaporu"; Renk="#FB923C"; IkonKat="donanim" }
    "20" = @{ Ad="HTML Dashboard";         Aciklama="Tüm sistem bilgilerini görsel HTML raporu olarak tarayıcıda gösterir"; Func="HtmlDashboard"; Renk="#F472B6"; IkonKat="rapor" }
    "21" = @{ Ad="Sağlık Skoru"; Aciklama="Sisteminize 100 üzerinden puan verir, zayıf noktaları detaylı gösterir"; Func="SaglikSkoru"; Renk="#F472B6"; IkonKat="rapor" }
    "22" = @{ Ad="Haftalık Zamanla";  Aciklama="Otomatik bakım görevi oluşturur, her hafta sistem temizliğini zamanlar"; Func="OtomasyonAyarla"; Renk="#F472B6"; IkonKat="rapor" }
    "23" = @{ Ad="Profil Seç";        Aciklama="Oyun Öncesi, Haftalık, Hızlı Tarama gibi hazır bakım profillerinden seçin"; Func="ProfilSec"; Renk="#F472B6"; IkonKat="rapor" }
    "24" = @{ Ad="Geri Yükleme";      Aciklama="Değişiklik öncesi güvenli geri dönme noktası oluşturur"; Func="GeriYuklemeNoktasi"; Renk="#F472B6"; IkonKat="rapor" }
    "25" = @{ Ad="TAM BAKIM";             Aciklama="Tüm temel bakım modüllerini sırayla çalıştırır, eksiksiz sistem bakımı yapar"; Func="TamBakim"; Renk="#F472B6"; IkonKat="rapor" }
    "26" = @{ Ad="FPS Optimizasyon";       Aciklama="GameDVR, MMCSS, HAGS, Nagle gibi 11 farklı oyun ayarını optimize eder"; Func="FpsOyunOptimizasyonu"; Renk="#C084FC"; IkonKat="oyun" }
    "27" = @{ Ad="RAM Optimizasyon";       Aciklama="Kullanılmayan belleği boşaltır, Standby List temizler, anında RAM kazandırır"; Func="RamOptimizasyonu"; Renk="#C084FC"; IkonKat="oyun" }
    "28" = @{ Ad="Süreç Temizleyici"; Aciklama="Oyun öncesi gereksiz arka plan uygulamalarını kapatır, kaynak serbest bırakır"; Func="SurecTemizleyici"; Renk="#C084FC"; IkonKat="oyun" }
    "29" = @{ Ad="Bloatware Kaldır";  Aciklama="Xbox, Cortana, Clipchamp gibi 35+ ön yüklü Windows uygulamasını kaldırır"; Func="BloatwareKaldirici"; Renk="#C084FC"; IkonKat="oyun" }
    "30" = @{ Ad="Sürücü Kontrolü"; Aciklama="İmzasız, sorunlu veya güncel olmayan sürücülerinizi (driver) tespit eder"; Func="SurucuKontrol"; Renk="#34D399"; IkonKat="sistem" }
    "31" = @{ Ad="Windows Update";         Aciklama="Bekleyen güncellemeleri listeler, indirip yüklemenize yardımcı olur"; Func="WindowsUpdateYonetici"; Renk="#34D399"; IkonKat="sistem" }
    "32" = @{ Ad="Disk Optimize";          Aciklama="SSD için TRIM komutu, HDD için birleştirme (defrag) yapar, hız artırır"; Func="DiskOptimize"; Renk="#60A5FA"; IkonKat="temizlik" }
    "33" = @{ Ad="WinSxS Temizle";         Aciklama="Windows Component Store boyutunu küçültür, gigabyte'larca alan açabilir"; Func="WinSxSTemizle"; Renk="#60A5FA"; IkonKat="temizlik" }
    "34" = @{ Ad="Pil Sağlığı"; Aciklama="Laptop pilinizin yıpranma seviyesini ölçer, sağlık raporu oluşturur"; Func="PilSagligi"; Renk="#FB923C"; IkonKat="donanim" }
    "35" = @{ Ad="İnternet Hız Testi"; Aciklama="Cloudflare sunucusuyla indirme hızı ve ping süresi ölçer (Mbps)"; Func="InternetHiziTesti"; Renk="#38BDF8"; IkonKat="ag" }
    "36" = @{ Ad="Bant Genişliği"; Aciklama="QoS, P2P ve TCP ayarlarını optimize ederek internet hızını artırır"; Func="BantGenisligiOptimize"; Renk="#38BDF8"; IkonKat="ag" }
    "37" = @{ Ad="DirectX / GPU";          Aciklama="Ekran kartınızın VRAM, yenileme hızı ve DirectX sürümünü gösterir"; Func="DirectXGPUTani"; Renk="#C084FC"; IkonKat="oyun" }
    "38" = @{ Ad="Oyun Modu Toggle";       Aciklama="Windows Game Mode ve Game DVR ayarlarını açar veya kapatır"; Func="OyunModuYonetici"; Renk="#C084FC"; IkonKat="oyun" }
    "39" = @{ Ad="Hesap Denetimi";         Aciklama="Şifresiz, süresi dolmuş ve riskli kullanıcı hesaplarını tespit eder"; Func="HesapGuvenlikDenetimi"; Renk="#F87171"; IkonKat="guvenlik" }
    "40" = @{ Ad="Şüpheli Başlangıç"; Aciklama="İmzasız ve şifresiz başlangıç programlarını güvenlik için tartar"; Func="SuphesizBaslangic"; Renk="#F87171"; IkonKat="guvenlik" }
    "41" = @{ Ad="Format Sihirbazı";  Aciklama="Format sonrası 11 adımlık tam optimizasyonu tek tıkla uygular"; Func="FormatSonrasiSihirbaz"; Renk="#C084FC"; IkonKat="oyun" }
    "42" = @{ Ad="Win. Tweaks";            Aciklama="Şeffaflık, animasyon, indexer, telemetri gibi 11 performans ayarını düzenler"; Func="WindowsPerformansTweaks"; Renk="#34D399"; IkonKat="sistem" }
    "43" = @{ Ad="Sanal Bellek";           Aciklama="Pagefile boyutunu RAM miktarınıza göre otomatik optimize eder"; Func="SanalBellekOptimize"; Renk="#34D399"; IkonKat="sistem" }
    "44" = @{ Ad="Donanım Skoru";     Aciklama="CPU, GPU, RAM ve disk performansını puanlar, yükseltme önerileri sunar"; Func="DonanımSkoruVeOneri"; Renk="#FB923C"; IkonKat="donanim" }
    "45" = @{ Ad="GPU Optimize";           Aciklama="NVIDIA veya AMD ekran kartı için registry tweakler ve shader cache temizliği"; Func="GPUOptimize"; Renk="#C084FC"; IkonKat="oyun" }
    "46" = @{ Ad="Defender İstisna";  Aciklama="Steam, Epic, Riot oyun klasörlerini Defender istisna listesine ekler"; Func="DefenderOyunIstisna"; Renk="#F87171"; IkonKat="guvenlik" }
    "47" = @{ Ad="Monitör Hz";        Aciklama="Monitör yenileme hızını ve DPI ölçeklendirmeyi kontrol eder, düşükse uyarır"; Func="MonitorOptimize"; Renk="#FB923C"; IkonKat="donanim" }
    "48" = @{ Ad="Hyper-V/VBS Kapat";      Aciklama="Sanallaştırma ve bellek bütünlüğü kapatarak %5-15 FPS artışı sağlar"; Func="HyperVVBSKapat"; Renk="#C084FC"; IkonKat="oyun" }
    "49" = @{ Ad="Tarayıcı Temizle"; Aciklama="Chrome, Edge, Firefox, Opera, Brave cache/geçmiş/çerezlerini temizler"; Func="TarayiciTemizleyici"; Renk="#60A5FA"; IkonKat="temizlik" }
    "50" = @{ Ad="OEM Bloatware";          Aciklama="HP, Dell, Lenovo gibi üreticilerin ön yüklü gereksiz yazılımlarını bulur"; Func="OEMBloatwareTespiti"; Renk="#F87171"; IkonKat="guvenlik" }
    "51" = @{ Ad="Boot Süresi";       Aciklama="Windows açılış süresini ölçer, yavaşlatan programları ve sürücülerinizi gösterir"; Func="BootSuresiAnalizi"; Renk="#34D399"; IkonKat="sistem" }
    "52" = @{ Ad="Sağ Tık Menü"; Aciklama="Win11 klasik sağ tık menüsünü açar, gereksiz shell extensionları temizler"; Func="SagTikMenuTemizle"; Renk="#34D399"; IkonKat="sistem" }
    "53" = @{ Ad="DNS Benchmark";          Aciklama="12 DNS sunucusunu test eder, en hızlısını bulur ve tek tıkla uygular"; Func="DNSBenchmark"; Renk="#38BDF8"; IkonKat="ag" }
    "54" = @{ Ad="WiFi Ağ Taraması"; Aciklama="WiFi ağınıza bağlı tüm cihazları tarar, bilinmeyen cihazları tespit eder"; Func="WiFiCihazTarama"; Renk="#38BDF8"; IkonKat="wifi" }
    "55" = @{ Ad="Boş Klasör Bulucu"; Aciklama="Tüm sürücülerde boş klasörleri tarar ve toplu olarak temizler"; Func="BosKlasorBulucu"; Renk="#60A5FA"; IkonKat="temizlik" }
    "56" = @{ Ad="Dosya Kırpıcı";     Aciklama="Dosyaları 3 geçişli güvenli silme ile kurtarılamaz şekilde imha eder"; Func="DosyaKirpici"; Renk="#F87171"; IkonKat="guvenlik" }
    "57" = @{ Ad="USB Cihaz Geçmişi"; Aciklama="Bağlanmış tüm USB cihazların kayıtlarını gösterir ve temizler"; Func="USBCihazGecmisi"; Renk="#F87171"; IkonKat="guvenlik" }
    "58" = @{ Ad="Hosts Editörü";     Aciklama="Reklam, tracker ve telemetri domainlerini hosts dosyasıyla engeller"; Func="HostsDosyasiEditoru"; Renk="#38BDF8"; IkonKat="ag" }
    "59" = @{ Ad="Görev Temizleyici"; Aciklama="Windows Görev Zamanlayıcı'daki kırık ve gereksiz görevleri temizler"; Func="ZamanlamaGoreviTemizle"; Renk="#34D399"; IkonKat="sistem" }
    "60" = @{ Ad="Gizlilik Kalkanı";  Aciklama="25 Windows gizlilik ayarını tarar: konum, kamera, reklam ID, telemetri ve daha fazlası"; Func="GizlilikKalkani"; Renk="#F87171"; IkonKat="guvenlik" }
    "61" = @{ Ad="Turbo Boost";        Aciklama="RAM temizle + süreç kapat + güç planı yükselt + efekt kapat = tek tık performans"; Func="TurboBoostModu"; Renk="#C084FC"; IkonKat="oyun" }
    "62" = @{ Ad="Bağlam Menüsü";      Aciklama="Sağ tık menüsündeki 3. parti shell extension'ları güvenli şekilde yönetir"; Func="BaglamMenusuYonetici"; Renk="#34D399"; IkonKat="sistem" }
    "63" = @{ Ad="Başlangıç Gecikme";  Aciklama="Startup uygulamalarını silmek yerine 30-60sn gecikmeli başlatarak boot hızlandırır"; Func="BaslangicGecikmeYonetici"; Renk="#34D399"; IkonKat="sistem" }
    "64" = @{ Ad="Registry Temizleyici"; Aciklama="Kırık Uninstall, SharedDLL, COM/ActiveX ve App Paths girdilerini tarar ve temizler"; Func="RegistryTemizleyici"; Renk="#60A5FA"; IkonKat="temizlik" }
    "65" = @{ Ad="Program Kaldırıcı";   Aciklama="Yüklü programları listeler, kaldırır ve artık dosya/registry kalıntılarını temizler"; Func="ProgramKaldirici"; Renk="#34D399"; IkonKat="sistem" }
    "66" = @{ Ad="Yazılım Güncelleyici"; Aciklama="Winget ile güncel olmayan programları tespit eder ve toplu güncelleme yapar"; Func="YazilimGuncelleyici"; Renk="#34D399"; IkonKat="sistem" }
    "67" = @{ Ad="Geri Yükleme Yönetici"; Aciklama="Sistem geri yükleme noktalarını yönetir: listele, oluştur, eski noktaları temizle"; Func="SistemGeriYuklemeYonetici"; Renk="#34D399"; IkonKat="sistem" }
    "68" = @{ Ad="Hizmet Konfigüratörü"; Aciklama="Oyun, İş ve Günlük profilleriyle Windows servislerini toplu optimize eder"; Func="HizmetKonfiguratoru"; Renk="#34D399"; IkonKat="sistem" }
    "69" = @{ Ad="Ağ Monitörü";          Aciklama="Canlı bant genişliği ölçer, uygulama bazlı ağ tüketimini ve açık portları listeler"; Func="AgMonitoru"; Renk="#38BDF8"; IkonKat="ag" }
}

# == KATEGORI TANIMLARI ==========================================
$global:KATEGORILER = [ordered]@{
    "Temizlik"  = @{ Moduller=@("1","2","3","5","6","7","8","32","33","49","64"); Renk="#60A5FA"; Ikon=[string][char]0xE74D; Aciklama="Disk, cache ve geçici dosya temizliği" }
    "Sistem"    = @{ Moduller=@("9","10","11","12","13","14","30","31","42","43","51","52","65","66","67","68"); Renk="#34D399"; Ikon=[string][char]0xE713; Aciklama="Sistem bakımı, kontrol ve optimizasyon" }
    "Güvenlik"  = @{ Moduller=@("16","17","39","40","46","50"); Renk="#F87171"; Ikon=[string][char]0xE72E; Aciklama="Güvenlik taraması ve denetim araçları" }
    "Ağ"        = @{ Moduller=@("15","35","36","53","54","69"); Renk="#38BDF8"; Ikon=[string][char]0xE774; Aciklama="Ağ, internet ve DNS optimizasyonu" }
    "Oyun"      = @{ Moduller=@("26","27","28","29","37","38","41","45","48"); Renk="#C084FC"; Ikon=[string][char]0xE7FC; Aciklama="Oyun performansı ve FPS artırma" }
    "Donanım"   = @{ Moduller=@("4","18","19","34","44","47"); Renk="#FB923C"; Ikon=[string][char]0xE7F7; Aciklama="Donanım bilgileri ve sağlık raporları" }
    "Raporlar"  = @{ Moduller=@("20","21","22","23","24","25"); Renk="#F472B6"; Ikon=[string][char]0xE9F9; Aciklama="Raporlar ve otomasyon araçları" }
}

# == FAVORILER SISTEMI ==========================================
$FAV_DOSYA = Join-Path $env:APPDATA "SistemBakim\favorites.txt"
$global:FAVORILER = @()
if (Test-Path $FAV_DOSYA) {
    try { $global:FAVORILER = @(Get-Content $FAV_DOSYA -ErrorAction Stop | Where-Object { $_.Trim() -ne "" }) } catch { $global:FAVORILER = @() }
}
function FavoriKaydet {
    $favKlasor = Split-Path $FAV_DOSYA
    if (-not (Test-Path $favKlasor)) { New-Item -ItemType Directory -Path $favKlasor -Force | Out-Null }
    $global:FAVORILER | Set-Content $FAV_DOSYA -Force -ErrorAction SilentlyContinue
}
function FavoriMi($no) { return ($global:FAVORILER -contains $no) }

# == AYAR DOSYASI (ilk calistirma + bildirim) ===================
$AYAR_DOSYA = Join-Path $env:APPDATA "SistemBakim\ayarlar.json"
$global:AYARLAR = @{ IlkCalistirma = $true; SonBakimTarih = $null; BakimSayisi = 0 }
if (Test-Path $AYAR_DOSYA) {
    try {
        $json = Get-Content $AYAR_DOSYA -Raw -ErrorAction Stop | ConvertFrom-Json
        $global:AYARLAR.IlkCalistirma = if ($null -ne $json.IlkCalistirma) { $json.IlkCalistirma } else { $false }
        $global:AYARLAR.SonBakimTarih = $json.SonBakimTarih
        $global:AYARLAR.BakimSayisi   = if ($null -ne $json.BakimSayisi) { $json.BakimSayisi } else { 0 }
    } catch { }
}
function AyarKaydet {
    $ayarKlasor = Split-Path $AYAR_DOSYA
    if (-not (Test-Path $ayarKlasor)) { New-Item -ItemType Directory -Path $ayarKlasor -Force | Out-Null }
    $global:AYARLAR | ConvertTo-Json | Set-Content $AYAR_DOSYA -Force -Encoding UTF8 -ErrorAction SilentlyContinue
}

# == DURUM DEGISKENLERI =========================================
$global:GOMULU_MOD       = $true
$global:AKTIF_ISLEM      = $null
$global:CIKTI_TIMER      = $null
$global:LOG_DOSYA        = ""
$global:ISLEM_BASLANGIC  = $null
$global:AKTIF_SAYFA      = "Dashboard"
$global:AKTIF_FILTRE     = "Tumu"
$global:NAV_LISTESI      = @()
$global:LOG_ACIK         = $false
$global:SAGLIK_SKORU     = 0

# Hizli erisim varsayilan moduller
$global:HIZLI_ERISIM = @("3","9","27","26","35","53")

# == UYGULAMA IKONU (Base64 PNG 64x64) ==========================
$global:APP_ICON_B64 = "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"

function IkonBitmapOlustur {
    $bytes = [Convert]::FromBase64String($global:APP_ICON_B64)
    $ms = New-Object System.IO.MemoryStream(,$bytes)
    $bmp = New-Object System.Windows.Media.Imaging.BitmapImage
    $bmp.BeginInit()
    $bmp.StreamSource = $ms
    $bmp.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
    $bmp.EndInit()
    $bmp.Freeze()
    return $bmp
}
$global:APP_ICON_BMP = IkonBitmapOlustur

# == WPF XAML ===================================================
[xml]$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Sistem Bakım v5.0"
    Height="850" Width="1300"
    MinHeight="650" MinWidth="1000"
    WindowStartupLocation="CenterScreen"
    Background="#0B0E14">

  <Window.Resources>
    <!-- ===== SIDEBAR NAV BUTONU (artik kullanilmiyor ama uyumluluk icin) ===== -->
    <Style x:Key="NavBtnStyle" TargetType="Button">
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" CornerRadius="10" Background="{TemplateBinding Background}" Padding="14,0">
              <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#0F1219"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- ===== MODUL KARTI ===== -->
    <Style x:Key="CardStyle" TargetType="Button">
      <Setter Property="Background" Value="#131620"/>
      <Setter Property="BorderBrush" Value="#1E2230"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Width" Value="270"/>
      <Setter Property="Height" Value="130"/>
      <Setter Property="Margin" Value="8"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="14" ClipToBounds="True"
                    RenderTransformOrigin="0.5,0.5">
              <Border.RenderTransform>
                <ScaleTransform x:Name="bdScale" ScaleX="1" ScaleY="1"/>
              </Border.RenderTransform>
              <ContentPresenter HorizontalAlignment="Stretch" VerticalAlignment="Stretch"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#1A1F2E"/>
                <Setter TargetName="bd" Property="BorderBrush" Value="#2E3448"/>
                <Setter TargetName="bd" Property="Effect">
                  <Setter.Value>
                    <DropShadowEffect BlurRadius="25" ShadowDepth="0" Color="#7C5CFC" Opacity="0.13"/>
                  </Setter.Value>
                </Setter>
              </Trigger>
              <EventTrigger RoutedEvent="MouseEnter">
                <BeginStoryboard>
                  <Storyboard>
                    <DoubleAnimation Storyboard.TargetName="bdScale" Storyboard.TargetProperty="ScaleX"
                                     To="1.025" Duration="0:0:0.18"/>
                    <DoubleAnimation Storyboard.TargetName="bdScale" Storyboard.TargetProperty="ScaleY"
                                     To="1.025" Duration="0:0:0.18"/>
                  </Storyboard>
                </BeginStoryboard>
              </EventTrigger>
              <EventTrigger RoutedEvent="MouseLeave">
                <BeginStoryboard>
                  <Storyboard>
                    <DoubleAnimation Storyboard.TargetName="bdScale" Storyboard.TargetProperty="ScaleX"
                                     To="1.0" Duration="0:0:0.18"/>
                    <DoubleAnimation Storyboard.TargetName="bdScale" Storyboard.TargetProperty="ScaleY"
                                     To="1.0" Duration="0:0:0.18"/>
                  </Storyboard>
                </BeginStoryboard>
              </EventTrigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- ===== CTA BUTONU (Akilli Tarama) ===== -->
    <Style x:Key="CTAStyle" TargetType="Button">
      <Setter Property="Height" Value="58"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" CornerRadius="16" Padding="40,0"
                    RenderTransformOrigin="0.5,0.5">
              <Border.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,0.5">
                  <GradientStop Color="#6C3AED" Offset="0"/>
                  <GradientStop Color="#7C5CFC" Offset="0.5"/>
                  <GradientStop Color="#A78BFA" Offset="1"/>
                </LinearGradientBrush>
              </Border.Background>
              <Border.RenderTransform>
                <ScaleTransform x:Name="ctaScale" ScaleX="1" ScaleY="1"/>
              </Border.RenderTransform>
              <Border.Effect>
                <DropShadowEffect BlurRadius="30" ShadowDepth="0" Color="#7C5CFC" Opacity="0.35"/>
              </Border.Effect>
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Effect">
                  <Setter.Value>
                    <DropShadowEffect BlurRadius="45" ShadowDepth="0" Color="#7C5CFC" Opacity="0.55"/>
                  </Setter.Value>
                </Setter>
              </Trigger>
              <EventTrigger RoutedEvent="MouseEnter">
                <BeginStoryboard>
                  <Storyboard>
                    <DoubleAnimation Storyboard.TargetName="ctaScale" Storyboard.TargetProperty="ScaleX"
                                     To="1.03" Duration="0:0:0.2"/>
                    <DoubleAnimation Storyboard.TargetName="ctaScale" Storyboard.TargetProperty="ScaleY"
                                     To="1.03" Duration="0:0:0.2"/>
                  </Storyboard>
                </BeginStoryboard>
              </EventTrigger>
              <EventTrigger RoutedEvent="MouseLeave">
                <BeginStoryboard>
                  <Storyboard>
                    <DoubleAnimation Storyboard.TargetName="ctaScale" Storyboard.TargetProperty="ScaleX"
                                     To="1.0" Duration="0:0:0.2"/>
                    <DoubleAnimation Storyboard.TargetName="ctaScale" Storyboard.TargetProperty="ScaleY"
                                     To="1.0" Duration="0:0:0.2"/>
                  </Storyboard>
                </BeginStoryboard>
              </EventTrigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- ===== PROGRESSBAR ===== -->
    <Style x:Key="ModernProgress" TargetType="ProgressBar">
      <Setter Property="Height" Value="6"/>
      <Setter Property="Maximum" Value="100"/>
      <Setter Property="Background" Value="#1A1F2E"/>
      <Setter Property="Foreground" Value="#7C5CFC"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ProgressBar">
            <Grid>
              <Border x:Name="PART_Track" CornerRadius="3" Background="{TemplateBinding Background}"/>
              <Border x:Name="PART_Indicator" CornerRadius="3" Background="{TemplateBinding Foreground}"
                      HorizontalAlignment="Left"/>
            </Grid>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- ===== ARAMA KUTUSU ===== -->
    <Style x:Key="SearchStyle" TargetType="TextBox">
      <Setter Property="Background" Value="#131620"/>
      <Setter Property="Foreground" Value="#E8ECF1"/>
      <Setter Property="BorderBrush" Value="#1E2230"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="FontSize" Value="13"/>
      <Setter Property="FontFamily" Value="Segoe UI"/>
      <Setter Property="Padding" Value="12,10"/>
      <Setter Property="CaretBrush" Value="#7C5CFC"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="TextBox">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="12" Padding="{TemplateBinding Padding}">
              <ScrollViewer x:Name="PART_ContentHost"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsFocused" Value="True">
                <Setter TargetName="bd" Property="BorderBrush" Value="#7C5CFC"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- ===== KUCUK BUTON ===== -->
    <Style x:Key="SmallBtnStyle" TargetType="Button">
      <Setter Property="Background" Value="#131620"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Foreground" Value="#4A5066"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Padding" Value="10,4"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    CornerRadius="6" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#1A1F2E"/>
                <Setter Property="Foreground" Value="#7A8194"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
  </Window.Resources>

  <!-- ====== ANA LAYOUT ====== -->
  <Grid>
    <Grid.ColumnDefinitions>
      <ColumnDefinition Width="220"/>
      <ColumnDefinition Width="*"/>
    </Grid.ColumnDefinitions>

    <!-- ====== SIDEBAR (CCleaner-style: ikon + etiket) ====== -->
    <Border Grid.Column="0" Background="#080B11" BorderBrush="#151A26" BorderThickness="0,0,1,0">
      <DockPanel>
        <!-- BRAND HEADER -->
        <StackPanel DockPanel.Dock="Top" Orientation="Horizontal" Margin="18,20,0,28">
          <Border Width="36" Height="36" CornerRadius="10" Background="Transparent">
            <Image x:Name="BrandIcon" Width="36" Height="36" Stretch="Uniform"
                   RenderOptions.BitmapScalingMode="HighQuality"/>
          </Border>
          <StackPanel VerticalAlignment="Center" Margin="12,0,0,0">
            <TextBlock Text="SistemBakim" FontSize="15" FontWeight="SemiBold" Foreground="#E8ECF1" FontFamily="Segoe UI"/>
            <TextBlock Text="v5.0" FontSize="10" Foreground="#3D4555" Margin="0,-1,0,0"/>
          </StackPanel>
        </StackPanel>

        <!-- BOTTOM: Log toggle + Ayarlar -->
        <StackPanel DockPanel.Dock="Bottom" Margin="10,0,10,14">
          <Border Height="1" Background="#151A26" Margin="6,0,6,10"/>
          <Button x:Name="BtnLogToggle" Cursor="Hand" Background="Transparent" BorderThickness="0" Height="38" Margin="0,1"
                  HorizontalContentAlignment="Left" Padding="0">
            <Button.Template>
              <ControlTemplate TargetType="Button">
                <Border x:Name="bd" Background="Transparent" CornerRadius="10" Padding="14,0">
                  <ContentPresenter VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                  <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="bd" Property="Background" Value="#0F1219"/>
                  </Trigger>
                </ControlTemplate.Triggers>
              </ControlTemplate>
            </Button.Template>
          </Button>
        </StackPanel>

        <!-- NAVIGASYON LISTESI -->
        <ScrollViewer VerticalScrollBarVisibility="Hidden" HorizontalScrollBarVisibility="Disabled">
          <StackPanel x:Name="NavPanel" Margin="10,0,10,0"/>
        </ScrollViewer>
      </DockPanel>
    </Border>

    <!-- ====== ICERIK ALANI ====== -->
    <Grid Grid.Column="1">
      <Grid.RowDefinitions>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>

      <!-- ICERIK FRAME -->
      <Grid Grid.Row="0">

        <!-- DASHBOARD GORUNUMU -->
        <ScrollViewer x:Name="DashboardView" VerticalScrollBarVisibility="Auto"
                      HorizontalScrollBarVisibility="Disabled" Background="#0B0E14">
          <StackPanel Margin="48,32,48,40">

            <StackPanel Margin="0,0,0,6">
              <TextBlock Text="Sistem Durumu" FontSize="26" FontWeight="SemiBold"
                         Foreground="#E8ECF1" FontFamily="Segoe UI"/>
              <StackPanel Orientation="Horizontal" Margin="0,10,0,0">
                <Border Background="#131620" CornerRadius="8"
                        Padding="10,5" VerticalAlignment="Center" BorderBrush="#1E2230" BorderThickness="1">
                  <TextBlock x:Name="TxtOS" Text="Windows" FontSize="11" Foreground="#7A8194"/>
                </Border>
                <Border Background="#0F1A12" CornerRadius="8" Margin="8,0,0,0"
                        Padding="10,5" VerticalAlignment="Center" BorderBrush="#152E1A" BorderThickness="1">
                  <TextBlock Text="v5.0" FontSize="11" Foreground="#34D399" FontWeight="SemiBold"/>
                </Border>
                <Border Background="#1A0F22" CornerRadius="8" Margin="8,0,0,0"
                        Padding="10,5" VerticalAlignment="Center" BorderBrush="#2E1A38" BorderThickness="1">
                  <TextBlock Text="Admin" FontSize="11" Foreground="#C084FC"/>
                </Border>
              </StackPanel>
              <TextBlock Text="Sisteminizin sağlığını izleyin, tek tıkla kapsamlı bakım yapın."
                         FontSize="13" Foreground="#5A6478" Margin="0,10,0,0" FontFamily="Segoe UI"/>
            </StackPanel>

            <!-- BILDIRIM KARTI (bakim hatirlatma) -->
            <Border x:Name="BildirimKarti" Visibility="Collapsed" Background="#1A1520"
                    CornerRadius="14" Padding="18,14" Margin="0,16,0,0"
                    BorderBrush="#2E1A38" BorderThickness="1">
              <Grid>
                <Grid.ColumnDefinitions>
                  <ColumnDefinition Width="Auto"/>
                  <ColumnDefinition Width="*"/>
                  <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>
                <TextBlock x:Name="BildirimIkon" Text="&#xE7BA;" FontFamily="Segoe MDL2 Assets"
                           FontSize="18" Foreground="#FBBF24" VerticalAlignment="Center" Margin="0,0,14,0"/>
                <StackPanel Grid.Column="1" VerticalAlignment="Center">
                  <TextBlock x:Name="BildirimBaslik" Text="" FontSize="13" FontWeight="SemiBold"
                             Foreground="#E8ECF1" FontFamily="Segoe UI"/>
                  <TextBlock x:Name="BildirimMesaj" Text="" FontSize="11"
                             Foreground="#7A8194" FontFamily="Segoe UI" Margin="0,2,0,0"/>
                </StackPanel>
                <Button x:Name="BtnBildirimKapat" Grid.Column="2" Style="{StaticResource SmallBtnStyle}"
                        Content="&#xE894;" FontFamily="Segoe MDL2 Assets" FontSize="9"
                        VerticalAlignment="Top" Margin="8,0,0,0"/>
              </Grid>
            </Border>

            <!-- SAGLIK + METRIKLER -->
            <Border CornerRadius="20" Margin="0,24,0,0"
                    Padding="40,32" BorderBrush="#1A1F2E" BorderThickness="1">
              <Border.Background>
                <LinearGradientBrush StartPoint="0,0" EndPoint="1,1">
                  <GradientStop Color="#111520" Offset="0"/>
                  <GradientStop Color="#0F1A28" Offset="1"/>
                </LinearGradientBrush>
              </Border.Background>
              <Border.Effect>
                <DropShadowEffect BlurRadius="35" ShadowDepth="0" Color="#7C5CFC" Opacity="0.10"/>
              </Border.Effect>
              <Grid>
                <Grid.ColumnDefinitions>
                  <ColumnDefinition Width="200"/>
                  <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>

                <Grid Grid.Column="0" Width="160" Height="160" VerticalAlignment="Center"
                      HorizontalAlignment="Center">
                  <Canvas x:Name="HealthCanvas" Width="160" Height="160"/>
                  <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                    <TextBlock x:Name="TxtSkor" Text="--" FontSize="42" FontWeight="Bold"
                               Foreground="#7C5CFC" HorizontalAlignment="Center" FontFamily="Segoe UI"/>
                    <TextBlock x:Name="TxtSkorLabel" Text="Puan" FontSize="11"
                               Foreground="#4A5066" HorizontalAlignment="Center" Margin="0,-4,0,0"/>
                  </StackPanel>
                </Grid>

                <UniformGrid Grid.Column="1" Columns="3" Margin="28,0,0,0">
                  <Border Background="#0D1016" CornerRadius="16" Margin="6" Padding="20,18"
                          BorderBrush="#151A26" BorderThickness="1">
                    <Border.Effect>
                      <DropShadowEffect BlurRadius="16" ShadowDepth="2" Color="#000000" Opacity="0.18" Direction="270"/>
                    </Border.Effect>
                    <StackPanel>
                      <StackPanel Orientation="Horizontal" Margin="0,0,0,8">
                        <Border Width="8" Height="8" CornerRadius="4" Background="#34D399" Margin="0,0,8,0" VerticalAlignment="Center"/>
                        <TextBlock Text="CPU" FontSize="12" Foreground="#5A6478" FontWeight="SemiBold" VerticalAlignment="Center"/>
                      </StackPanel>
                      <TextBlock x:Name="TxtCPU" Text="--%" FontSize="26" FontWeight="Bold" Foreground="#34D399" Margin="0,0,0,10"/>
                      <ProgressBar x:Name="CpuBar" Style="{StaticResource ModernProgress}" Value="0" Foreground="#34D399"/>
                    </StackPanel>
                  </Border>
                  <Border Background="#0D1016" CornerRadius="16" Margin="6" Padding="20,18"
                          BorderBrush="#151A26" BorderThickness="1">
                    <Border.Effect>
                      <DropShadowEffect BlurRadius="16" ShadowDepth="2" Color="#000000" Opacity="0.18" Direction="270"/>
                    </Border.Effect>
                    <StackPanel>
                      <StackPanel Orientation="Horizontal" Margin="0,0,0,8">
                        <Border Width="8" Height="8" CornerRadius="4" Background="#60A5FA" Margin="0,0,8,0" VerticalAlignment="Center"/>
                        <TextBlock Text="RAM" FontSize="12" Foreground="#5A6478" FontWeight="SemiBold" VerticalAlignment="Center"/>
                      </StackPanel>
                      <TextBlock x:Name="TxtRAM" Text="--%" FontSize="26" FontWeight="Bold" Foreground="#60A5FA" Margin="0,0,0,10"/>
                      <ProgressBar x:Name="RamBar" Style="{StaticResource ModernProgress}" Value="0" Foreground="#60A5FA"/>
                    </StackPanel>
                  </Border>
                  <Border Background="#0D1016" CornerRadius="16" Margin="6" Padding="20,18"
                          BorderBrush="#151A26" BorderThickness="1">
                    <Border.Effect>
                      <DropShadowEffect BlurRadius="16" ShadowDepth="2" Color="#000000" Opacity="0.18" Direction="270"/>
                    </Border.Effect>
                    <StackPanel>
                      <StackPanel Orientation="Horizontal" Margin="0,0,0,8">
                        <Border Width="8" Height="8" CornerRadius="4" Background="#FB923C" Margin="0,0,8,0" VerticalAlignment="Center"/>
                        <TextBlock Text="Disk" FontSize="12" Foreground="#5A6478" FontWeight="SemiBold" VerticalAlignment="Center"/>
                      </StackPanel>
                      <TextBlock x:Name="TxtDisk" Text="--%" FontSize="26" FontWeight="Bold" Foreground="#FB923C" Margin="0,0,0,10"/>
                      <ProgressBar x:Name="DiskBar" Style="{StaticResource ModernProgress}" Value="0" Foreground="#FB923C"/>
                    </StackPanel>
                  </Border>
                </UniformGrid>
              </Grid>
            </Border>

            <!-- AKILLI TARAMA BUTONU -->
            <Button x:Name="BtnSmartScan" Style="{StaticResource CTAStyle}"
                    Margin="0,28,0,0" HorizontalAlignment="Stretch" MaxWidth="560">
              <StackPanel Orientation="Horizontal">
                <TextBlock x:Name="SmartScanIkon" FontFamily="Segoe MDL2 Assets" FontSize="20"
                           VerticalAlignment="Center" Margin="0,0,14,0" Foreground="White"/>
                <TextBlock Text="Akıllı Tarama Başlat" FontSize="16" FontWeight="SemiBold"
                           VerticalAlignment="Center"/>
              </StackPanel>
            </Button>
            <TextBlock Text="Tek tıkla kapsamlı sistem bakımı, temizlik ve optimizasyon"
                       FontSize="12" Foreground="#3D4555" HorizontalAlignment="Center" Margin="0,10,0,0"/>

            <!-- HIZLI ERISIM -->
            <TextBlock Text="HIZLI ERİŞİM" FontSize="11" FontWeight="Bold"
                       Foreground="#3D4555" Margin="0,36,0,14" FontFamily="Segoe UI"/>
            <WrapPanel x:Name="QuickPanel" Orientation="Horizontal"/>

          </StackPanel>
        </ScrollViewer>

        <!-- KATEGORI GORUNUMU (gizli) -->
        <Grid x:Name="CategoryView" Visibility="Collapsed" Background="#0B0E14">
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>

          <StackPanel Grid.Row="0" Margin="48,32,48,0">
            <StackPanel Orientation="Horizontal">
              <Border x:Name="KatIkonBorder" CornerRadius="14" Width="48" Height="48" Margin="0,0,16,0">
                <TextBlock x:Name="TxtKatIkon" FontFamily="Segoe MDL2 Assets" FontSize="20"
                           HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="White"/>
              </Border>
              <StackPanel VerticalAlignment="Center">
                <StackPanel Orientation="Horizontal">
                  <TextBlock x:Name="TxtKatBaslik" Text="" FontSize="24" FontWeight="SemiBold" Foreground="#E8ECF1"/>
                  <TextBlock x:Name="TxtModSay" Text="" FontSize="13" Foreground="#3D4555"
                             VerticalAlignment="Center" Margin="14,0,0,0"/>
                </StackPanel>
                <TextBlock x:Name="TxtKatAciklama" Text="" FontSize="13" Foreground="#5A6478" Margin="0,2,0,0"/>
              </StackPanel>
            </StackPanel>
          </StackPanel>

          <Border Grid.Row="1" Margin="48,18,48,0">
            <Grid>
              <TextBox x:Name="TxtArama" Style="{StaticResource SearchStyle}"/>
              <TextBlock x:Name="TxtAramaYer" Text="Ara... (modül adı veya açıklama)"
                         Foreground="#3D4555" FontSize="13" FontFamily="Segoe UI"
                         IsHitTestVisible="False" VerticalAlignment="Center" Margin="14,0,0,0"/>
            </Grid>
          </Border>

          <ScrollViewer Grid.Row="2" x:Name="ModulScroll"
                        VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled"
                        Margin="0,14,0,0" Background="#0B0E14">
            <WrapPanel x:Name="ModulPanel" Margin="41,0,0,24" Orientation="Horizontal"/>
          </ScrollViewer>
        </Grid>
      </Grid>

      <!-- ISLEM / LOG PANELI (gizli) -->
      <Border x:Name="ActivityPanel" Grid.Row="1" MaxHeight="300" Visibility="Collapsed"
              Background="#080B11" BorderBrush="#151A26" BorderThickness="0,1,0,0">
        <Grid>
          <Grid.RowDefinitions>
            <RowDefinition Height="40"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>

          <Grid Grid.Row="0" Margin="20,0">
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="Auto"/>
              <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <TextBlock Grid.Column="0" Text="İŞLEM ÇIKTISI" Foreground="#3D4555" FontSize="10"
                       FontWeight="Bold" FontFamily="Consolas" VerticalAlignment="Center"/>
            <Button x:Name="BtnLogTemizle" Grid.Column="1" Content="Temizle"
                    Style="{StaticResource SmallBtnStyle}" Margin="12,0,0,0" Height="24" VerticalAlignment="Center"/>
            <Button x:Name="BtnDisaAktar" Grid.Column="2" Content="&#xE78C; Dışa Aktar"
                    Style="{StaticResource SmallBtnStyle}" Margin="8,0,0,0" Height="24"
                    FontFamily="Segoe MDL2 Assets, Segoe UI" VerticalAlignment="Center"/>
            <TextBlock x:Name="TxtDurum" Grid.Column="3" Text="" Foreground="#3D4555"
                       FontSize="11" FontFamily="Consolas" Margin="16,0,0,0" VerticalAlignment="Center"/>
            <Button x:Name="BtnDurdur" Grid.Column="4" Content="Durdur!"
                    Style="{StaticResource SmallBtnStyle}" Height="24" VerticalAlignment="Center" Visibility="Collapsed"/>
            <Button x:Name="BtnLogKapat" Grid.Column="5" Style="{StaticResource SmallBtnStyle}"
                    Height="24" Width="28" FontFamily="Segoe MDL2 Assets" FontSize="10"
                    Margin="12,0,0,0" VerticalAlignment="Center"/>
          </Grid>

          <Border x:Name="PnlDurum" Grid.Row="1" Background="#0D1016"
                  Margin="20,2,20,2" CornerRadius="6" Padding="10,5" Visibility="Collapsed">
            <Grid>
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
              </Grid.ColumnDefinitions>
              <Border x:Name="PnlDurumIndicator" Grid.Column="0"
                      Width="8" Height="8" CornerRadius="4" Background="#7C5CFC"
                      Margin="0,0,10,0" VerticalAlignment="Center"/>
              <TextBlock x:Name="TxtIslemAdi" Grid.Column="1" Text="" Foreground="#5A6478"
                         FontSize="11" FontFamily="Consolas" VerticalAlignment="Center"/>
              <TextBlock x:Name="TxtIslemSure" Grid.Column="2" Text="" Foreground="#3D4555"
                         FontSize="10" FontFamily="Consolas" VerticalAlignment="Center"/>
            </Grid>
          </Border>

          <TextBox x:Name="TxtCikti" Grid.Row="2"
                   Background="Transparent" Foreground="#5A6478"
                   FontFamily="Consolas" FontSize="11"
                   IsReadOnly="True" BorderThickness="0"
                   VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled"
                   TextWrapping="Wrap" Margin="20,4,20,10"/>
        </Grid>
      </Border>
    </Grid>
    <!-- ILK CALISTIRMA SIHIRBAZI OVERLAY -->
    <Border x:Name="SihirbazPanel" Grid.Column="1"
            VerticalAlignment="Center" HorizontalAlignment="Center"
            Visibility="Collapsed" CornerRadius="22" Padding="44,36"
            MinWidth="480" MaxWidth="560">
      <Border.Background>
        <SolidColorBrush Color="#0D1117"/>
      </Border.Background>
      <Border.BorderBrush>
        <SolidColorBrush Color="#1A1F2E"/>
      </Border.BorderBrush>
      <Border.BorderThickness>
        <Thickness>1</Thickness>
      </Border.BorderThickness>
      <Border.Effect>
        <DropShadowEffect BlurRadius="50" ShadowDepth="0" Color="#7C5CFC" Opacity="0.22"/>
      </Border.Effect>
      <StackPanel>
        <Image x:Name="SihirbazLogo" Width="56" Height="56" Stretch="Uniform"
               HorizontalAlignment="Center" Margin="0,0,0,16"
               RenderOptions.BitmapScalingMode="HighQuality"/>
        <TextBlock x:Name="SihirbazBaslik" Text="SistemBakim'e Hoş Geldiniz!"
                   FontSize="22" FontWeight="Bold" Foreground="#E8ECF1"
                   HorizontalAlignment="Center" FontFamily="Segoe UI"/>
        <TextBlock x:Name="SihirbazAciklama"
                   Text="Bilgisayarınızı hızlandırmak, temizlemek ve güvende tutmak için hazırız. İlk taramanızı başlatalım!"
                   FontSize="13" Foreground="#7A8194" TextWrapping="Wrap" TextAlignment="Center"
                   HorizontalAlignment="Center" Margin="0,10,0,24" MaxWidth="420" FontFamily="Segoe UI"/>
        <Border Background="#111824" CornerRadius="14" Padding="20,16" Margin="0,0,0,20">
          <StackPanel>
            <StackPanel Orientation="Horizontal" Margin="0,0,0,8">
              <TextBlock Text="&#xE73E;" FontFamily="Segoe MDL2 Assets" FontSize="13"
                         Foreground="#34D399" Margin="0,0,10,0" VerticalAlignment="Center"/>
              <TextBlock Text="Gereksiz dosyaları ve geçici verileri temizle"
                         FontSize="12" Foreground="#8A8FA0" FontFamily="Segoe UI"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Margin="0,0,0,8">
              <TextBlock Text="&#xE73E;" FontFamily="Segoe MDL2 Assets" FontSize="13"
                         Foreground="#34D399" Margin="0,0,10,0" VerticalAlignment="Center"/>
              <TextBlock Text="Gizlilik ve güvenlik durumunu analiz et"
                         FontSize="12" Foreground="#8A8FA0" FontFamily="Segoe UI"/>
            </StackPanel>
            <StackPanel Orientation="Horizontal">
              <TextBlock Text="&#xE73E;" FontFamily="Segoe MDL2 Assets" FontSize="13"
                         Foreground="#34D399" Margin="0,0,10,0" VerticalAlignment="Center"/>
              <TextBlock Text="Performans önerileri ve sağlık skoru oluştur"
                         FontSize="12" Foreground="#8A8FA0" FontFamily="Segoe UI"/>
            </StackPanel>
          </StackPanel>
        </Border>
        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center">
          <Button x:Name="BtnSihirbazBaslat" Cursor="Hand" Margin="0,0,12,0">
            <Button.Template>
              <ControlTemplate TargetType="Button">
                <Border x:Name="bd" CornerRadius="12" Padding="32,12">
                  <Border.Background>
                    <LinearGradientBrush StartPoint="0,0" EndPoint="1,0.5">
                      <GradientStop Color="#6C3AED" Offset="0"/>
                      <GradientStop Color="#7C5CFC" Offset="1"/>
                    </LinearGradientBrush>
                  </Border.Background>
                  <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                  <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="bd" Property="Opacity" Value="0.85"/>
                  </Trigger>
                </ControlTemplate.Triggers>
              </ControlTemplate>
            </Button.Template>
            <TextBlock Text="Hızlı Tarama Başlat" FontSize="14" FontWeight="SemiBold"
                       Foreground="White" FontFamily="Segoe UI"/>
          </Button>
          <Button x:Name="BtnSihirbazAtla" Cursor="Hand">
            <Button.Template>
              <ControlTemplate TargetType="Button">
                <Border x:Name="bd" CornerRadius="12" Padding="24,12" Background="#1A1F2E">
                  <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                  <Trigger Property="IsMouseOver" Value="True">
                    <Setter TargetName="bd" Property="Background" Value="#252B3B"/>
                  </Trigger>
                </ControlTemplate.Triggers>
              </ControlTemplate>
            </Button.Template>
            <TextBlock Text="Atla" FontSize="13" Foreground="#8A8FA0" FontFamily="Segoe UI"/>
          </Button>
        </StackPanel>
      </StackPanel>
    </Border>

    <!-- TARAMA SONUC OZETI OVERLAY -->
    <Border x:Name="SonucPanel" Grid.Column="1"
            VerticalAlignment="Center" HorizontalAlignment="Center"
            Visibility="Collapsed" CornerRadius="18" Padding="32,28"
            MinWidth="420" MaxWidth="520">
      <Border.Background>
        <SolidColorBrush Color="#111824"/>
      </Border.Background>
      <Border.BorderBrush>
        <SolidColorBrush Color="#1E2A3A"/>
      </Border.BorderBrush>
      <Border.BorderThickness>
        <Thickness>1</Thickness>
      </Border.BorderThickness>
      <Border.Effect>
        <DropShadowEffect BlurRadius="40" ShadowDepth="0" Color="#7C5CFC" Opacity="0.18"/>
      </Border.Effect>
      <StackPanel>
        <TextBlock x:Name="SonucIkon" Text="&#xE73E;" FontFamily="Segoe MDL2 Assets" FontSize="36"
                   Foreground="#34D399" HorizontalAlignment="Center" Margin="0,0,0,12"/>
        <TextBlock x:Name="SonucBaslik" Text="Tarama Tamamlandi" FontSize="20" FontWeight="Bold"
                   Foreground="#E8ECF1" HorizontalAlignment="Center" FontFamily="Segoe UI"/>
        <TextBlock x:Name="SonucSure" Text="" FontSize="12" Foreground="#5A6478"
                   HorizontalAlignment="Center" Margin="0,4,0,16" FontFamily="Segoe UI"/>
        <Border Background="#0D1117" CornerRadius="12" Padding="20,16" Margin="0,0,0,16">
          <Grid>
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="*"/>
              <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <StackPanel Grid.Column="0" HorizontalAlignment="Center">
              <TextBlock x:Name="SonucDosyaSay" Text="0" FontSize="24" FontWeight="Bold"
                         Foreground="#60A5FA" HorizontalAlignment="Center" FontFamily="Segoe UI"/>
              <TextBlock Text="Islenen" FontSize="10" Foreground="#5A6478"
                         HorizontalAlignment="Center" FontFamily="Segoe UI"/>
            </StackPanel>
            <StackPanel Grid.Column="1" HorizontalAlignment="Center">
              <TextBlock x:Name="SonucKazanim" Text="0" FontSize="24" FontWeight="Bold"
                         Foreground="#34D399" HorizontalAlignment="Center" FontFamily="Segoe UI"/>
              <TextBlock Text="Kazanim" FontSize="10" Foreground="#5A6478"
                         HorizontalAlignment="Center" FontFamily="Segoe UI"/>
            </StackPanel>
            <StackPanel Grid.Column="2" HorizontalAlignment="Center">
              <TextBlock x:Name="SonucHata" Text="0" FontSize="24" FontWeight="Bold"
                         Foreground="#F87171" HorizontalAlignment="Center" FontFamily="Segoe UI"/>
              <TextBlock Text="Uyari" FontSize="10" Foreground="#5A6478"
                         HorizontalAlignment="Center" FontFamily="Segoe UI"/>
            </StackPanel>
          </Grid>
        </Border>
        <Button x:Name="BtnSonucKapat" Cursor="Hand" HorizontalAlignment="Center"
                Background="Transparent" BorderThickness="0" Padding="28,10">
          <Button.Template>
            <ControlTemplate TargetType="Button">
              <Border x:Name="bd" CornerRadius="10" Padding="28,10"
                      Background="#1A1F2E">
                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
              </Border>
              <ControlTemplate.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                  <Setter TargetName="bd" Property="Background" Value="#252B3B"/>
                </Trigger>
              </ControlTemplate.Triggers>
            </ControlTemplate>
          </Button.Template>
          <TextBlock Text="Tamam" FontSize="13" Foreground="#8A8FA0" FontFamily="Segoe UI"/>
        </Button>
      </StackPanel>
    </Border>

    <!-- ONCESI / SONRASI KARSILASTIRMA OVERLAY -->
    <Border x:Name="KarsilastirmaPanel" Grid.Column="1"
            VerticalAlignment="Center" HorizontalAlignment="Center"
            Visibility="Collapsed" CornerRadius="18" Padding="32,28"
            MinWidth="480" MaxWidth="580">
      <Border.Background>
        <SolidColorBrush Color="#111824"/>
      </Border.Background>
      <Border.BorderBrush>
        <SolidColorBrush Color="#1E2A3A"/>
      </Border.BorderBrush>
      <Border.BorderThickness>
        <Thickness>1</Thickness>
      </Border.BorderThickness>
      <Border.Effect>
        <DropShadowEffect BlurRadius="40" ShadowDepth="0" Color="#60A5FA" Opacity="0.15"/>
      </Border.Effect>
      <StackPanel>
        <TextBlock Text="&#xE9D5;" FontFamily="Segoe MDL2 Assets" FontSize="32"
                   Foreground="#60A5FA" HorizontalAlignment="Center" Margin="0,0,0,8"/>
        <TextBlock Text="Oncesi / Sonrasi" FontSize="20" FontWeight="Bold"
                   Foreground="#E8ECF1" HorizontalAlignment="Center" FontFamily="Segoe UI"/>
        <TextBlock x:Name="KarsilastirmaSure" Text="" FontSize="11" Foreground="#5A6478"
                   HorizontalAlignment="Center" Margin="0,4,0,16" FontFamily="Segoe UI"/>

        <Grid Margin="0,0,0,16">
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
            <ColumnDefinition Width="*"/>
          </Grid.ColumnDefinitions>

          <!-- ONCESI -->
          <Border Grid.Column="0" Background="#0D1117" CornerRadius="12" Padding="16,14">
            <StackPanel HorizontalAlignment="Center">
              <TextBlock Text="ONCESI" FontSize="10" FontWeight="Bold" Foreground="#5A6478"
                         HorizontalAlignment="Center" Margin="0,0,0,10"/>
              <TextBlock x:Name="KsDiskOnce" Text="--" FontSize="16" FontWeight="Bold"
                         Foreground="#F87171" HorizontalAlignment="Center"/>
              <TextBlock Text="Disk Bos" FontSize="9" Foreground="#5A6478" HorizontalAlignment="Center" Margin="0,2,0,8"/>
              <TextBlock x:Name="KsRamOnce" Text="--" FontSize="16" FontWeight="Bold"
                         Foreground="#F87171" HorizontalAlignment="Center"/>
              <TextBlock Text="RAM Bos" FontSize="9" Foreground="#5A6478" HorizontalAlignment="Center"/>
            </StackPanel>
          </Border>

          <!-- DELTA OK -->
          <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="14,0">
            <TextBlock Text="&#xE72A;" FontFamily="Segoe MDL2 Assets" FontSize="22"
                       Foreground="#34D399" HorizontalAlignment="Center"/>
            <TextBlock x:Name="KsDeltaDisk" Text="" FontSize="13" FontWeight="Bold"
                       Foreground="#34D399" HorizontalAlignment="Center" Margin="0,6,0,4"/>
            <TextBlock x:Name="KsDeltaRam" Text="" FontSize="13" FontWeight="Bold"
                       Foreground="#34D399" HorizontalAlignment="Center"/>
          </StackPanel>

          <!-- SONRASI -->
          <Border Grid.Column="2" Background="#0D1117" CornerRadius="12" Padding="16,14">
            <StackPanel HorizontalAlignment="Center">
              <TextBlock Text="SONRASI" FontSize="10" FontWeight="Bold" Foreground="#5A6478"
                         HorizontalAlignment="Center" Margin="0,0,0,10"/>
              <TextBlock x:Name="KsDiskSonra" Text="--" FontSize="16" FontWeight="Bold"
                         Foreground="#34D399" HorizontalAlignment="Center"/>
              <TextBlock Text="Disk Bos" FontSize="9" Foreground="#5A6478" HorizontalAlignment="Center" Margin="0,2,0,8"/>
              <TextBlock x:Name="KsRamSonra" Text="--" FontSize="16" FontWeight="Bold"
                         Foreground="#34D399" HorizontalAlignment="Center"/>
              <TextBlock Text="RAM Bos" FontSize="9" Foreground="#5A6478" HorizontalAlignment="Center"/>
            </StackPanel>
          </Border>
        </Grid>

        <Button x:Name="BtnKarsilastirmaKapat" Cursor="Hand" HorizontalAlignment="Center"
                Background="Transparent" BorderThickness="0" Padding="28,10">
          <Button.Template>
            <ControlTemplate TargetType="Button">
              <Border x:Name="bd" CornerRadius="10" Padding="28,10" Background="#1A1F2E">
                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
              </Border>
              <ControlTemplate.Triggers>
                <Trigger Property="IsMouseOver" Value="True">
                  <Setter TargetName="bd" Property="Background" Value="#252B3B"/>
                </Trigger>
              </ControlTemplate.Triggers>
            </ControlTemplate>
          </Button.Template>
          <TextBlock Text="Kapat" FontSize="13" Foreground="#8A8FA0" FontFamily="Segoe UI"/>
        </Button>
      </StackPanel>
    </Border>

    <!-- DISK TREEMAP OVERLAY -->
    <Border x:Name="TreemapPanel" Grid.Column="1"
            Visibility="Collapsed" Background="#0B0E14" Margin="0">
      <Grid>
        <Grid.RowDefinitions>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <Grid Grid.Row="0" Margin="20,16,20,8">
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <StackPanel Orientation="Horizontal">
            <TextBlock Text="&#xEDA2;" FontFamily="Segoe MDL2 Assets" FontSize="16"
                       Foreground="#60A5FA" VerticalAlignment="Center" Margin="0,0,10,0"/>
            <TextBlock x:Name="TreemapBaslik" Text="Disk Alani Haritasi" FontSize="16" FontWeight="SemiBold"
                       Foreground="#E8ECF1" VerticalAlignment="Center" FontFamily="Segoe UI"/>
            <TextBlock x:Name="TreemapBilgi" Text="" FontSize="11" Foreground="#5A6478"
                       VerticalAlignment="Center" Margin="14,0,0,0"/>
          </StackPanel>
          <Button x:Name="BtnTreemapKapat" Grid.Column="1" Style="{StaticResource SmallBtnStyle}"
                  Content="&#xE894;" FontFamily="Segoe MDL2 Assets" FontSize="10"
                  Height="28" Width="28"/>
        </Grid>
        <Canvas x:Name="TreemapCanvas" Grid.Row="1" Background="#0B0E14"
                ClipToBounds="True" Margin="20,0,20,20"/>
      </Grid>
    </Border>

    <!-- TOAST BILDIRIM OVERLAY -->
    <Border x:Name="ToastPanel" Grid.Column="1"
            VerticalAlignment="Bottom" HorizontalAlignment="Right"
            Margin="0,0,24,24" Visibility="Collapsed"
            CornerRadius="14" Padding="16,14" MaxWidth="420" MinWidth="300">
      <Border.Background>
        <SolidColorBrush Color="#1A1F2E"/>
      </Border.Background>
      <Border.BorderBrush>
        <SolidColorBrush Color="#2E3448"/>
      </Border.BorderBrush>
      <Border.BorderThickness>
        <Thickness>1</Thickness>
      </Border.BorderThickness>
      <Border.Effect>
        <DropShadowEffect BlurRadius="24" ShadowDepth="6" Color="#000000" Opacity="0.55" Direction="270"/>
      </Border.Effect>
      <Border.RenderTransform>
        <TranslateTransform x:Name="ToastSlide" Y="0"/>
      </Border.RenderTransform>
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <Border x:Name="ToastIkonBorder" Grid.Column="0" Width="36" Height="36"
                CornerRadius="10" Margin="0,0,14,0" VerticalAlignment="Center">
          <TextBlock x:Name="ToastIkon" FontFamily="Segoe MDL2 Assets" FontSize="15"
                     HorizontalAlignment="Center" VerticalAlignment="Center" Foreground="White"/>
        </Border>
        <StackPanel Grid.Column="1" VerticalAlignment="Center">
          <TextBlock x:Name="ToastBaslik" Text="" FontSize="13" FontWeight="SemiBold"
                     Foreground="#E8ECF1" TextWrapping="Wrap" FontFamily="Segoe UI"/>
          <TextBlock x:Name="ToastMesaj" Text="" FontSize="11" Foreground="#7A8194"
                     TextWrapping="Wrap" Margin="0,3,0,0" FontFamily="Segoe UI"/>
        </StackPanel>
        <Border Grid.Column="2" VerticalAlignment="Top" Margin="10,0,0,0">
          <Button x:Name="BtnToastKapat" Style="{StaticResource SmallBtnStyle}"
                  Content="&#xE894;" FontFamily="Segoe MDL2 Assets" FontSize="9"
                  Width="22" Height="22"/>
        </Border>
      </Grid>
    </Border>

  </Grid>
</Window>
'@

# == WINDOW OLUSTUR =============================================
$reader = New-Object System.Xml.XmlNodeReader $xaml
try {
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    [System.Windows.MessageBox]::Show("WPF penceresi açılamadı:`n" + $_.Exception.Message, "Hata")
    exit
}

# == UYGULAMA IKONU AYARLA ======================================
try {
    if ($global:APP_ICON_BMP) {
        $window.Icon = $global:APP_ICON_BMP
        $BrandIcon = $window.FindName("BrandIcon")
        if ($BrandIcon) { $BrandIcon.Source = $global:APP_ICON_BMP }
    } else {
        # Fallback: sistem.ico dosyasindan yukle
        $icoYol = Join-Path $global:KLASOR "sistem.ico"
        if (Test-Path $icoYol) {
            $icoUri = New-Object System.Uri($icoYol)
            $icoBmp = New-Object System.Windows.Media.Imaging.BitmapImage($icoUri)
            $window.Icon = $icoBmp
        }
    }
} catch {
    # Icon yuklenemezse sessizce devam et — uygulama kullanilabilir olmali
}

# == KONTROL REFERANSLARI =======================================
$DashboardView   = $window.FindName("DashboardView")
$CategoryView    = $window.FindName("CategoryView")
$HealthCanvas    = $window.FindName("HealthCanvas")
$TxtSkor         = $window.FindName("TxtSkor")
$TxtSkorLabel    = $window.FindName("TxtSkorLabel")
$TxtCPU          = $window.FindName("TxtCPU")
$TxtRAM          = $window.FindName("TxtRAM")
$TxtDisk         = $window.FindName("TxtDisk")
$CpuBar          = $window.FindName("CpuBar")
$RamBar          = $window.FindName("RamBar")
$DiskBar         = $window.FindName("DiskBar")
$TxtOS           = $window.FindName("TxtOS")
$BtnSmartScan    = $window.FindName("BtnSmartScan")
$SmartScanIkon   = $window.FindName("SmartScanIkon")
$QuickPanel      = $window.FindName("QuickPanel")
$NavPanel        = $window.FindName("NavPanel")
$TxtKatBaslik    = $window.FindName("TxtKatBaslik")
$TxtKatAciklama  = $window.FindName("TxtKatAciklama")
$TxtKatIkon      = $window.FindName("TxtKatIkon")
$KatIkonBorder   = $window.FindName("KatIkonBorder")
$TxtModSay       = $window.FindName("TxtModSay")
$TxtArama        = $window.FindName("TxtArama")
$TxtAramaYer     = $window.FindName("TxtAramaYer")
$ModulPanel      = $window.FindName("ModulPanel")
$ModulScroll     = $window.FindName("ModulScroll")
$ActivityPanel   = $window.FindName("ActivityPanel")
$TxtCikti        = $window.FindName("TxtCikti")
$BtnLogToggle    = $window.FindName("BtnLogToggle")
$BtnLogTemizle   = $window.FindName("BtnLogTemizle")
$BtnLogKapat     = $window.FindName("BtnLogKapat")
$BtnDurdur       = $window.FindName("BtnDurdur")
$BtnDisaAktar    = $window.FindName("BtnDisaAktar")
$TxtDurum        = $window.FindName("TxtDurum")
$PnlDurum        = $window.FindName("PnlDurum")
$PnlDurumIndicator = $window.FindName("PnlDurumIndicator")
$TxtIslemAdi     = $window.FindName("TxtIslemAdi")
$TxtIslemSure    = $window.FindName("TxtIslemSure")
$ToastPanel      = $window.FindName("ToastPanel")
$ToastIkonBorder = $window.FindName("ToastIkonBorder")
$ToastIkon       = $window.FindName("ToastIkon")
$ToastBaslik     = $window.FindName("ToastBaslik")
$ToastMesaj      = $window.FindName("ToastMesaj")
$BtnToastKapat   = $window.FindName("BtnToastKapat")
$SonucPanel      = $window.FindName("SonucPanel")
$SonucIkon       = $window.FindName("SonucIkon")
$SonucBaslik     = $window.FindName("SonucBaslik")
$SonucSure       = $window.FindName("SonucSure")
$SonucDosyaSay   = $window.FindName("SonucDosyaSay")
$SonucKazanim    = $window.FindName("SonucKazanim")
$SonucHata       = $window.FindName("SonucHata")
$BtnSonucKapat   = $window.FindName("BtnSonucKapat")
$BildirimKarti   = $window.FindName("BildirimKarti")
$BildirimIkon    = $window.FindName("BildirimIkon")
$BildirimBaslik  = $window.FindName("BildirimBaslik")
$BildirimMesaj   = $window.FindName("BildirimMesaj")
$BtnBildirimKapat = $window.FindName("BtnBildirimKapat")
$SihirbazPanel   = $window.FindName("SihirbazPanel")
$SihirbazLogo    = $window.FindName("SihirbazLogo")
$BtnSihirbazBaslat = $window.FindName("BtnSihirbazBaslat")
$BtnSihirbazAtla = $window.FindName("BtnSihirbazAtla")

# Karsilastirma panel elemanlari
$KarsilastirmaPanel = $window.FindName("KarsilastirmaPanel")
$KarsilastirmaSure  = $window.FindName("KarsilastirmaSure")
$KsDiskOnce      = $window.FindName("KsDiskOnce")
$KsRamOnce       = $window.FindName("KsRamOnce")
$KsDiskSonra     = $window.FindName("KsDiskSonra")
$KsRamSonra      = $window.FindName("KsRamSonra")
$KsDeltaDisk     = $window.FindName("KsDeltaDisk")
$KsDeltaRam      = $window.FindName("KsDeltaRam")
$BtnKarsilastirmaKapat = $window.FindName("BtnKarsilastirmaKapat")

# Treemap panel elemanlari
$TreemapPanel    = $window.FindName("TreemapPanel")
$TreemapBaslik   = $window.FindName("TreemapBaslik")
$TreemapBilgi    = $window.FindName("TreemapBilgi")
$TreemapCanvas   = $window.FindName("TreemapCanvas")
$BtnTreemapKapat = $window.FindName("BtnTreemapKapat")

# Sonuc paneli kapat butonu
$BtnSonucKapat.Add_Click({ $SonucPanel.Visibility = "Collapsed" }.GetNewClosure())
$BtnKarsilastirmaKapat.Add_Click({ $KarsilastirmaPanel.Visibility = "Collapsed" }.GetNewClosure())
$BtnTreemapKapat.Add_Click({
    $TreemapPanel.Visibility = "Collapsed"
    $DashboardView.Visibility = "Visible"
}.GetNewClosure())

# Bildirim karti kapat
$BtnBildirimKapat.Add_Click({ $BildirimKarti.Visibility = "Collapsed" }.GetNewClosure())

# Sihirbaz logo ayarla
if ($global:APP_ICON_BMP) { $SihirbazLogo.Source = $global:APP_ICON_BMP }

# Log toggle ve kapat ikonlarini ayarla (sidebar stil: ikon + etiket)
$logSp = New-Object System.Windows.Controls.StackPanel
$logSp.Orientation = "Horizontal"
$logIkon = New-Object System.Windows.Controls.TextBlock
$logIkon.Text = [string][char]0xE756
$logIkon.FontFamily = "Segoe MDL2 Assets"
$logIkon.FontSize = 17
$logIkon.Foreground = "#4A5066"
$logIkon.Width = 24
$logIkon.VerticalAlignment = "Center"
$logSp.Children.Add($logIkon) | Out-Null
$logLabel = New-Object System.Windows.Controls.TextBlock
$logLabel.Text = "İşlem Çıktısı"
$logLabel.FontSize = 13
$logLabel.FontFamily = "Segoe UI"
$logLabel.Foreground = "#8A8FA0"
$logLabel.VerticalAlignment = "Center"
$logLabel.Margin = "10,0,0,0"
$logSp.Children.Add($logLabel) | Out-Null
$BtnLogToggle.Content = $logSp

$BtnLogKapat.Content = [string][char]0xE894
$SmartScanIkon.Text = [string][char]0xE9D5

# == YARDIMCI FONKSIYONLAR =====================================
function CiktiEkle($metin) {
    $zaman = Get-Date -Format "HH:mm:ss"
    $TxtCikti.AppendText("[" + $zaman + "]  " + $metin + "`n")
    $TxtCikti.ScrollToEnd()
}

# == TOAST BILDIRIM SISTEMI =====================================
$global:TOAST_TIMER = $null
$global:PROSES_CIKIS_ZAMANI = $null

function ToastGoster([string]$baslik, [string]$mesaj, [string]$tip) {
    # tip: "basari", "hata", "bilgi", "uyari"
    $renkler = @{
        "basari" = @{ Bg="#0F2418"; Border="#1B4332"; Ikon=[string][char]0xE73E; IkonBg="#34D399" }
        "hata"   = @{ Bg="#2A1215"; Border="#4A1D22"; Ikon=[string][char]0xEA39; IkonBg="#F87171" }
        "bilgi"  = @{ Bg="#0F1A2E"; Border="#1A3050"; Ikon=[string][char]0xE946; IkonBg="#60A5FA" }
        "uyari"  = @{ Bg="#2A2010"; Border="#4A3820"; Ikon=[string][char]0xE7BA; IkonBg="#FBBF24" }
    }
    $r = $renkler[$tip]
    if (-not $r) { $r = $renkler["bilgi"] }

    $ToastIkon.Text = $r.Ikon
    $ToastIkonBorder.Background = $r.IkonBg
    $ToastBaslik.Text = $baslik
    $ToastMesaj.Text = $mesaj
    $ToastPanel.Background = [System.Windows.Media.BrushConverter]::new().ConvertFrom($r.Bg)
    $ToastPanel.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFrom($r.Border)

    # Slide-up + fade-in animasyonu
    if ($ToastPanel.RenderTransform -isnot [System.Windows.Media.TranslateTransform]) {
        $ToastPanel.RenderTransform = New-Object System.Windows.Media.TranslateTransform
    }
    $ToastPanel.Opacity = 0
    $ToastPanel.RenderTransform.Y = 20
    $ToastPanel.Visibility = "Visible"

    $fadeIn = New-Object System.Windows.Media.Animation.DoubleAnimation
    $fadeIn.From = 0; $fadeIn.To = 1
    $fadeIn.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(280))
    $fadeIn.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
    $fadeIn.EasingFunction.EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseOut
    $ToastPanel.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $fadeIn)

    $slideUp = New-Object System.Windows.Media.Animation.DoubleAnimation
    $slideUp.From = 20; $slideUp.To = 0
    $slideUp.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(280))
    $slideUp.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
    $slideUp.EasingFunction.EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseOut
    $ToastPanel.RenderTransform.BeginAnimation([System.Windows.Media.TranslateTransform]::YProperty, $slideUp)

    if ($global:TOAST_TIMER -ne $null) { $global:TOAST_TIMER.Stop() }
    $global:TOAST_TIMER = New-Object System.Windows.Threading.DispatcherTimer
    $global:TOAST_TIMER.Interval = [TimeSpan]::FromSeconds(5)
    $global:TOAST_TIMER.Add_Tick({
        # Fade-out animasyonu
        $fadeOut = New-Object System.Windows.Media.Animation.DoubleAnimation
        $fadeOut.From = 1; $fadeOut.To = 0
        $fadeOut.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(200))
        $fadeOut.Add_Completed({ $ToastPanel.Visibility = "Collapsed" }.GetNewClosure())
        $ToastPanel.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $fadeOut)
        $global:TOAST_TIMER.Stop()
    }.GetNewClosure())
    $global:TOAST_TIMER.Start()
}

function LogPanelAc {
    $ActivityPanel.Visibility = "Visible"
    $global:LOG_ACIK = $true
}
function LogPanelKapat {
    $ActivityPanel.Visibility = "Collapsed"
    $global:LOG_ACIK = $false
}

# == SAGLIK HALKASI CIZIMI =====================================
function DrawHealthRing([int]$puan) {
    $HealthCanvas.Children.Clear()
    $size = 160; $cx = 80; $cy = 80; $r = 64; $sw = 8

    $renk = "#F87171"
    if ($puan -ge 80) { $renk = "#34D399" }
    elseif ($puan -ge 60) { $renk = "#FBBF24" }

    # Arka plan daire
    $bg = New-Object System.Windows.Shapes.Ellipse
    $bg.Width = $r * 2; $bg.Height = $r * 2
    $bg.StrokeThickness = $sw
    $bg.Fill = [System.Windows.Media.Brushes]::Transparent
    $bg.Stroke = [System.Windows.Media.BrushConverter]::new().ConvertFrom("#151A26")
    [System.Windows.Controls.Canvas]::SetLeft($bg, $cx - $r)
    [System.Windows.Controls.Canvas]::SetTop($bg, $cy - $r)
    $HealthCanvas.Children.Add($bg) | Out-Null

    if ($puan -le 0) { return }
    $pct = [Math]::Min($puan, 99.5)

    $angleRad = ($pct / 100) * 2 * [Math]::PI
    $startX = $cx; $startY = $cy - $r
    $endX = $cx + $r * [Math]::Sin($angleRad)
    $endY = $cy - $r * [Math]::Cos($angleRad)

    $figure = New-Object System.Windows.Media.PathFigure
    $figure.StartPoint = [System.Windows.Point]::new($startX, $startY)
    $figure.IsClosed = $false

    $arc = New-Object System.Windows.Media.ArcSegment
    $arc.Point = [System.Windows.Point]::new($endX, $endY)
    $arc.Size = [System.Windows.Size]::new($r, $r)
    $arc.IsLargeArc = ($pct -gt 50)
    $arc.SweepDirection = "Clockwise"
    $figure.Segments.Add($arc)

    $geo = New-Object System.Windows.Media.PathGeometry
    $geo.Figures.Add($figure)

    $path = New-Object System.Windows.Shapes.Path
    $path.Data = $geo
    $path.StrokeThickness = $sw
    $path.StrokeStartLineCap = "Round"
    $path.StrokeEndLineCap = "Round"
    $path.Fill = [System.Windows.Media.Brushes]::Transparent
    $path.Stroke = [System.Windows.Media.BrushConverter]::new().ConvertFrom($renk)
    $HealthCanvas.Children.Add($path) | Out-Null

    $TxtSkor.Text = $puan.ToString()
    $TxtSkor.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFrom($renk)
}

# == GOMULU TERMINAL ============================================
function BaslatGomulu($funcName, $modAdi) {
    if ($global:AKTIF_ISLEM -ne $null) { DurdurGomulu }

    $global:LOG_DOSYA = Join-Path $env:TEMP ("SistemBakim_out_" + (Get-Date -Format "HHmmss") + ".log")
    $global:ISLEM_BASLANGIC = Get-Date

    # ── ONCESI SNAPSHOT (Karsilastirma icin) ──
    try {
        $osDisk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
        $osRam  = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $global:SNAPSHOT_ONCE = @{
            DiskBos = $osDisk.FreeSpace
            RamBos  = ($osRam.FreePhysicalMemory * 1KB)
        }
    } catch { $global:SNAPSHOT_ONCE = $null }

    $TxtCikti.Clear()
    CiktiEkle ("Çalışıyor: " + $modAdi + "...")
    $TxtDurum.Text = "Çalışıyor: " + $modAdi
    $BtnDurdur.Visibility = "Visible"
    $PnlDurum.Visibility = "Visible"
    $TxtIslemAdi.Text = $modAdi
    $TxtIslemSure.Text = "0s"
    $PnlDurumIndicator.Background = "#7C5CFC"
    LogPanelAc

    $logDosya   = $global:LOG_DOSYA
    $backendYol = $global:BACKEND
    $scriptContent = "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; `$OutputEncoding = [System.Text.Encoding]::UTF8; `$env:SISTEMBAK_GUI = '1'; Start-Transcript -Path '" + $logDosya + "' -Force; . '" + $backendYol + "'; " + $funcName + "; Stop-Transcript; '__BITTI__' | Add-Content '" + $logDosya + "'"
    $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($scriptContent))

    try {
        $proc = Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded" -Verb RunAs -WindowStyle Hidden -PassThru -ErrorAction Stop
        $global:AKTIF_ISLEM = $proc
    } catch {
        $hataMsg = $_.Exception.Message
        CiktiEkle ("HATA: " + $modAdi + " baslatma basarisiz -- " + $hataMsg)
        $BtnDurdur.Visibility = "Collapsed"
        $PnlDurum.Visibility = "Collapsed"
        ToastGoster "Baslatma Hatasi" ($modAdi + ": " + $hataMsg) "hata"
        return
    }

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(500)
    $global:SON_OKUNAN = 0

    $timer.Add_Tick({
        if ($global:ISLEM_BASLANGIC -ne $null) {
            $gecen = (Get-Date) - $global:ISLEM_BASLANGIC
            $TxtIslemSure.Text = ([int]$gecen.TotalSeconds).ToString() + "s"
        }
        if ($PnlDurumIndicator.Background.ToString() -eq "#FF7C5CFC") {
            $PnlDurumIndicator.Background = "#6C3AED"
        } else {
            $PnlDurumIndicator.Background = "#7C5CFC"
        }

        if (Test-Path $global:LOG_DOSYA) {
            try {
                $icerik = Get-Content $global:LOG_DOSYA -ErrorAction Stop
                if ($icerik.Count -gt $global:SON_OKUNAN) {
                    $yeniSatirlar = $icerik[$global:SON_OKUNAN..($icerik.Count - 1)]
                    foreach ($satir in $yeniSatirlar) {
                        if ($satir -ne "__BITTI__" -and $satir.Trim() -ne "") {
                            # CLI menu/prompt satirlarini filtrele — GUI log'unu temiz tut
                            if ($satir -match '^\s*(Secim\s*:|Seçim\s*:|Ana Men[uü]|Devam etmek icin|0\.\s*(Geri|Cik|Ana)|Read-Host|\[GUI Otomatik\]|Secim yapin|Seçim yapın|\>\s*$)') { continue }
                            if ($satir -match '^\s*\d+\.\s+\w+.*\d+\.\s+\w+' -and $satir -match '(Geri|Cik)') { continue }
                            $TxtCikti.AppendText($satir + "`n")
                            # Gercek zamanli durum: log satirlarindan ilerleme bilgisi cikar
                            if ($satir -match '^\s*\[(\d+)/(\d+)\]') {
                                $TxtDurum.Text = "Adim " + $Matches[1] + "/" + $Matches[2] + " - " + $TxtIslemAdi.Text
                            } elseif ($satir -match '(Temizleniyor|Taraniyor|Analiz|Kontrol|Optimize|Siliniyor|Yukleniyor)') {
                                $durum = $satir.Trim()
                                if ($durum.Length -gt 70) { $durum = $durum.Substring(0, 67) + "..." }
                                $TxtDurum.Text = $durum
                            }
                        }
                    }
                    $TxtCikti.ScrollToEnd()
                    $global:SON_OKUNAN = $icerik.Count
                }
                $tumIcerik = $icerik -join "`n"
                if ($tumIcerik.Contains("__BITTI__")) {
                    $global:CIKTI_TIMER.Stop()
                    $global:AKTIF_ISLEM = $null
                    $BtnDurdur.Visibility = "Collapsed"
                    $PnlDurumIndicator.Background = "#34D399"
                    $gecen2 = (Get-Date) - $global:ISLEM_BASLANGIC
                    $sureTxt = ([int]$gecen2.TotalSeconds).ToString() + "s"
                    $TxtIslemSure.Text = $sureTxt
                    $tamamMsg = $TxtIslemAdi.Text + " (" + $sureTxt + ")"
                    CiktiEkle ("Tamamlandi: " + $tamamMsg)
                    $TxtDurum.Text = "Tamamlandi: " + $TxtIslemAdi.Text
                    # Hata kontrolu: log iceriginde HATA var mi?
                    $hataVar = ($tumIcerik -match "HATA:|Exception|Error:")
                    if ($hataVar) {
                        ToastGoster "Tamamlandi (Uyari)" ($tamamMsg + " - Bazi islemlerde uyari olusmus olabilir.") "uyari"
                    } else {
                        ToastGoster "Basariyla Tamamlandi" $tamamMsg "basari"
                    }
                    # Sonuc Ozeti panelini goster
                    SonucOzetiGoster
                }
            } catch {}
        }
        # Proses beklenmedik sekilde sonlanma kontrolu (3sn grace period)
        if ($global:AKTIF_ISLEM -ne $null -and $global:AKTIF_ISLEM.HasExited) {
            $logIcerik = if (Test-Path $global:LOG_DOSYA) { Get-Content $global:LOG_DOSYA -Raw -ErrorAction SilentlyContinue } else { "" }
            if ($logIcerik -match '__BITTI__') {
                # Normal bitis — ust bloktaki Contains("__BITTI__") zaten handle eder, burasi fallback
            } else {
                # Grace period: process ciktiktan sonra transcript flush'a 3sn ver
                if ($global:PROSES_CIKIS_ZAMANI -eq $null) {
                    $global:PROSES_CIKIS_ZAMANI = Get-Date
                } elseif (((Get-Date) - $global:PROSES_CIKIS_ZAMANI).TotalSeconds -gt 3) {
                    $global:CIKTI_TIMER.Stop()
                    $global:AKTIF_ISLEM = $null
                    $global:PROSES_CIKIS_ZAMANI = $null
                    $BtnDurdur.Visibility = "Collapsed"
                    $PnlDurumIndicator.Background = "#F87171"
                    CiktiEkle ("HATA: Islem beklenmedik sekilde sonlandi.")
                    $TxtDurum.Text = "Hata ile sonlandi"
                    ToastGoster "Islem Basarisiz" ($TxtIslemAdi.Text + " beklenmedik sekilde sonlandi.") "hata"
                }
            }
        } else {
            $global:PROSES_CIKIS_ZAMANI = $null
        }
    }.GetNewClosure())

    $global:CIKTI_TIMER = $timer
    $timer.Start()
}

function DurdurGomulu {
    if ($global:CIKTI_TIMER -ne $null) { $global:CIKTI_TIMER.Stop(); $global:CIKTI_TIMER = $null }
    if ($global:AKTIF_ISLEM -ne $null) {
        try {
            $pid = $global:AKTIF_ISLEM.Id
            # Alt proses agacini da oldur (zombi process onleme)
            try { Get-CimInstance Win32_Process -Filter "ParentProcessId=$pid" -ErrorAction SilentlyContinue |
                  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } } catch {}
            $global:AKTIF_ISLEM | Stop-Process -Force -ErrorAction SilentlyContinue
        } catch {}
        $global:AKTIF_ISLEM = $null
    }
    $BtnDurdur.Visibility = "Collapsed"
    $PnlDurumIndicator.Background = "#F87171"
    CiktiEkle "Islem kullanici tarafindan durduruldu."
    $TxtDurum.Text = "Durduruldu"
    ToastGoster "Durduruldu" ($TxtIslemAdi.Text + " islemi iptal edildi.") "uyari"
}

# == TARAMA SONUC OZETI FONKSIYONU ==============================
function SonucOzetiGoster {
    if (-not (Test-Path $global:LOG_DOSYA)) { return }
    $logIcerik = Get-Content $global:LOG_DOSYA -ErrorAction SilentlyContinue

    # Metrikleri log iceriginden ayristir
    $islenen = 0; $kazanim = ""; $hataSay = 0
    $uyariDetaylari = [System.Collections.Generic.List[string]]::new()

    foreach ($satir in $logIcerik) {
        # Silinen/temizlenen dosya sayilari
        if ($satir -match '(\d+)\s*(dosya|klasor|gorev|kayit|domain)\s*(silind|temizlend|engellend|kirpild|kaldirildi)') {
            $islenen += [int]$Matches[1]
        }
        # Kazanilan alan (GB/MB/KB)
        if ($satir -match 'Kazan[ıi]l?an\s*:?\s*([\d,\.]+\s*[GMKB]+)') {
            $kazanim = $Matches[1]
        }
        if ($satir -match 'Toplam\s*:?\s*([\d,\.]+\s*[GMKB]+)') {
            if (-not $kazanim) { $kazanim = $Matches[1] }
        }
        # Hata/uyari sayisi ve detay toplama
        if ($satir -match 'HATA|Atlandi|Silinemedi|Exception|UYARI|Basarisiz') {
            $hataSay++
            $temiz = $satir.Trim()
            if ($temiz.Length -gt 120) { $temiz = $temiz.Substring(0, 117) + "..." }
            if ($uyariDetaylari.Count -lt 15) { $uyariDetaylari.Add($temiz) }
        }
    }

    # Uyari detaylarini log paneline yaz (kullanici NE oldugunu gorsun)
    if ($uyariDetaylari.Count -gt 0) {
        CiktiEkle ""
        CiktiEkle ("━━━ UYARI DETAYLARI ({0} adet) ━━━" -f $hataSay)
        foreach ($ud in $uyariDetaylari) { CiktiEkle ("  ⚠ " + $ud) }
        if ($hataSay -gt $uyariDetaylari.Count) {
            CiktiEkle ("  ... ve " + ($hataSay - $uyariDetaylari.Count) + " uyari daha (log dosyasinda)")
        }
        CiktiEkle "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    }

    $gecenSure = (Get-Date) - $global:ISLEM_BASLANGIC
    $sureTxt = "{0:N0} saniye" -f $gecenSure.TotalSeconds

    # Paneli doldur
    $SonucSure.Text = $TxtIslemAdi.Text + " - " + $sureTxt
    $SonucDosyaSay.Text = $islenen.ToString()
    $SonucKazanim.Text = if ($kazanim) { $kazanim } else { "-" }
    $SonucHata.Text = $hataSay.ToString()

    if ($hataSay -gt 0) {
        $SonucIkon.Text = [string][char]0xE7BA  # Uyari ikonu
        $SonucIkon.Foreground = "#FBBF24"
        $SonucBaslik.Text = "Tamamlandi (Uyarilar Var)"
    } else {
        $SonucIkon.Text = [string][char]0xE73E  # Check ikonu
        $SonucIkon.Foreground = "#34D399"
        $SonucBaslik.Text = "Basariyla Tamamlandi"
    }

    # Bakim tarihini guncelle
    $global:AYARLAR.SonBakimTarih = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    $global:AYARLAR.BakimSayisi = $global:AYARLAR.BakimSayisi + 1
    AyarKaydet

    # Animasyonlu goster
    $SonucPanel.Opacity = 0
    $SonucPanel.Visibility = "Visible"
    $anim = New-Object System.Windows.Media.Animation.DoubleAnimation
    $anim.From = 0.0; $anim.To = 1.0
    $anim.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(300))
    $anim.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
    $anim.EasingFunction.EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseOut
    $SonucPanel.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $anim)

    # ── ONCESI/SONRASI KARSILASTIRMA ──
    if ($global:SNAPSHOT_ONCE -ne $null) {
        try {
            $osDisk2 = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
            $osRam2  = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
            $diskSonra = $osDisk2.FreeSpace
            $ramSonra  = ($osRam2.FreePhysicalMemory * 1KB)
            $diskOnce  = $global:SNAPSHOT_ONCE.DiskBos
            $ramOnce   = $global:SNAPSHOT_ONCE.RamBos

            # Formatla (GB/MB)
            $fmtBoyut = { param($b) if ($b -ge 1GB) { "{0:N2} GB" -f ($b/1GB) } elseif ($b -ge 1MB) { "{0:N0} MB" -f ($b/1MB) } else { "{0:N0} KB" -f ($b/1KB) } }

            $KsDiskOnce.Text  = & $fmtBoyut $diskOnce
            $KsDiskSonra.Text = & $fmtBoyut $diskSonra
            $KsRamOnce.Text   = & $fmtBoyut $ramOnce
            $KsRamSonra.Text  = & $fmtBoyut $ramSonra

            $diskDelta = $diskSonra - $diskOnce
            $ramDelta  = $ramSonra - $ramOnce

            $diskIsaret = if ($diskDelta -ge 0) { "+" } else { "" }
            $ramIsaret  = if ($ramDelta -ge 0) { "+" } else { "" }
            $KsDeltaDisk.Text = $diskIsaret + (& $fmtBoyut ([math]::Abs($diskDelta)))
            $KsDeltaRam.Text  = $ramIsaret + (& $fmtBoyut ([math]::Abs($ramDelta)))

            # Renk: pozitif=yesil, negatif=kirmizi
            $KsDeltaDisk.Foreground = if ($diskDelta -ge 0) { "#34D399" } else { "#F87171" }
            $KsDeltaRam.Foreground  = if ($ramDelta -ge 0) { "#34D399" } else { "#F87171" }
            $KsDiskSonra.Foreground = if ($diskDelta -ge 0) { "#34D399" } else { "#F87171" }
            $KsRamSonra.Foreground  = if ($ramDelta -ge 0) { "#34D399" } else { "#F87171" }

            $KarsilastirmaSure.Text = $TxtIslemAdi.Text + " - " + $sureTxt
            $global:SNAPSHOT_ONCE = $null

            # 1.5sn sonra karsilastirma panelini goster (sonuc paneli kapandiktan sonra)
            $ksTimer = New-Object System.Windows.Threading.DispatcherTimer
            $ksTimer.Interval = [TimeSpan]::FromMilliseconds(1500)
            $ksTimer.Add_Tick({
                $ksTimer.Stop()
                $KarsilastirmaPanel.Opacity = 0
                $KarsilastirmaPanel.Visibility = "Visible"
                $ksAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
                $ksAnim.From = 0; $ksAnim.To = 1
                $ksAnim.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(350))
                $ksAnim.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
                $KarsilastirmaPanel.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $ksAnim)
            }.GetNewClosure())
            $ksTimer.Start()
        } catch {}
    }
}

# == MODUL KART OLUSTURUCU =====================================
function KartOlustur($no, $mod) {
    $btn = New-Object System.Windows.Controls.Button
    $btn.Style = $window.Resources["CardStyle"]
    $btn.Tag = $no
    $btn.ToolTip = "#" + $no + " - " + $mod.Ad + "`n" + $mod.Aciklama

    $mainGrid = New-Object System.Windows.Controls.Grid
    $r1 = New-Object System.Windows.Controls.RowDefinition; $r1.Height = "4"
    $r2 = New-Object System.Windows.Controls.RowDefinition; $r2.Height = "*"
    $mainGrid.RowDefinitions.Add($r1)
    $mainGrid.RowDefinitions.Add($r2)

    # Ust renk cubugu
    $accent = New-Object System.Windows.Controls.Border
    $accent.Background = $mod.Renk
    $accent.CornerRadius = "14,14,0,0"
    [System.Windows.Controls.Grid]::SetRow($accent, 0)
    $mainGrid.Children.Add($accent) | Out-Null

    # Icerik
    $icerik = New-Object System.Windows.Controls.Grid
    $icerik.Margin = "18,12,18,12"
    $cr1 = New-Object System.Windows.Controls.RowDefinition; $cr1.Height = "Auto"
    $cr2 = New-Object System.Windows.Controls.RowDefinition; $cr2.Height = "*"
    $cr3 = New-Object System.Windows.Controls.RowDefinition; $cr3.Height = "Auto"
    $icerik.RowDefinitions.Add($cr1)
    $icerik.RowDefinitions.Add($cr2)
    $icerik.RowDefinitions.Add($cr3)
    [System.Windows.Controls.Grid]::SetRow($icerik, 1)

    # Baslik satiri (ikon + ad)
    $baslikPanel = New-Object System.Windows.Controls.StackPanel
    $baslikPanel.Orientation = "Horizontal"
    [System.Windows.Controls.Grid]::SetRow($baslikPanel, 0)

    $ikonKat = $mod.IkonKat
    if ($ikonKat -and $global:IKONLAR.ContainsKey($ikonKat)) {
        $tbIkon = New-Object System.Windows.Controls.TextBlock
        $tbIkon.Text = $global:IKONLAR[$ikonKat]
        $tbIkon.FontFamily = "Segoe MDL2 Assets"
        $tbIkon.FontSize = 18
        $tbIkon.Foreground = $mod.Renk
        $tbIkon.Margin = "0,0,10,0"
        $tbIkon.VerticalAlignment = "Center"
        $baslikPanel.Children.Add($tbIkon) | Out-Null
    }

    $tbAd = New-Object System.Windows.Controls.TextBlock
    $tbAd.Text = $mod.Ad
    $tbAd.FontSize = 14
    $tbAd.FontWeight = "SemiBold"
    $tbAd.Foreground = "#E8ECF1"
    $tbAd.TextTrimming = "CharacterEllipsis"
    $tbAd.VerticalAlignment = "Center"
    $baslikPanel.Children.Add($tbAd) | Out-Null
    $icerik.Children.Add($baslikPanel) | Out-Null

    # Aciklama
    $tbAcik = New-Object System.Windows.Controls.TextBlock
    $tbAcik.Text = $mod.Aciklama
    $tbAcik.FontSize = 11
    $tbAcik.Foreground = "#5A6478"
    $tbAcik.TextWrapping = "Wrap"
    $tbAcik.TextTrimming = "CharacterEllipsis"
    $tbAcik.MaxHeight = 36
    $tbAcik.Margin = "0,6,0,0"
    [System.Windows.Controls.Grid]::SetRow($tbAcik, 1)
    $icerik.Children.Add($tbAcik) | Out-Null

    # Alt satir (minimal: sadece favori yildiz)
    $altPanel = New-Object System.Windows.Controls.DockPanel
    $altPanel.Margin = "0,4,0,0"
    [System.Windows.Controls.Grid]::SetRow($altPanel, 2)

    # Favori yildiz
    $favTb = New-Object System.Windows.Controls.TextBlock
    $favTb.FontSize = 14
    $favTb.Cursor = "Hand"
    $favTb.HorizontalAlignment = "Right"
    $favTb.VerticalAlignment = "Center"
    [System.Windows.Controls.DockPanel]::SetDock($favTb, "Right")
    if (FavoriMi $no) {
        $favTb.Text = [string][char]0x2605
        $favTb.Foreground = "#FBBF24"
    } else {
        $favTb.Text = [string][char]0x2606
        $favTb.Foreground = "#2A2F3C"
    }
    $altPanel.Children.Add($favTb) | Out-Null
    $icerik.Children.Add($altPanel) | Out-Null
    $mainGrid.Children.Add($icerik) | Out-Null
    $btn.Content = $mainGrid

    # Favori toggle (sag tik)
    $favNo = $no
    $btn.Add_MouseRightButtonUp({
        if (FavoriMi $favNo) {
            $global:FAVORILER = @($global:FAVORILER | Where-Object { $_ -ne $favNo })
            $favTb.Text = [string][char]0x2606
            $favTb.Foreground = "#2A2F3C"
            CiktiEkle ("Favorilerden çıkarıldı: #" + $favNo)
        } else {
            $global:FAVORILER = @($global:FAVORILER) + @($favNo)
            $favTb.Text = [string][char]0x2605
            $favTb.Foreground = "#FBBF24"
            CiktiEkle ("Favorilere eklendi!: #" + $favNo)
        }
        FavoriKaydet
    }.GetNewClosure())

    # Sol tik: modulu calistir
    $funcName    = $mod.Func
    $backendYolu = $global:BACKEND
    $modAdi      = $mod.Ad
    $btn.Add_Click({
        $f = $funcName; $b = $backendYolu; $ad = $modAdi
        if ($global:GOMULU_MOD) {
            BaslatGomulu $f $ad
        } else {
            $sc = ". `"$b`"; Clear-Host; $f; Write-Host ''; Write-Host '  [Kapatmak icin Enter]' -ForegroundColor DarkGray; Read-Host | Out-Null"
            $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($sc))
            try {
                Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $enc" -Verb RunAs -ErrorAction Stop
                CiktiEkle ("Açıldı: " + $ad)
            } catch { CiktiEkle ("HATA: " + $ad + " -- " + $_.Exception.Message) }
        }
    }.GetNewClosure())

    return $btn
}

# == HIZLI ERISIM KARTI ========================================
function HizliKartOlustur($no, $mod) {
    $btn = New-Object System.Windows.Controls.Button
    $btn.Style = $window.Resources["CardStyle"]
    $btn.Width = 180; $btn.Height = 72
    $btn.ToolTip = $mod.Ad + " - " + $mod.Aciklama

    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Margin = "16,12"

    $baslik = New-Object System.Windows.Controls.StackPanel
    $baslik.Orientation = "Horizontal"

    $ikonKat = $mod.IkonKat
    if ($ikonKat -and $global:IKONLAR.ContainsKey($ikonKat)) {
        $ik = New-Object System.Windows.Controls.TextBlock
        $ik.Text = $global:IKONLAR[$ikonKat]
        $ik.FontFamily = "Segoe MDL2 Assets"
        $ik.FontSize = 15
        $ik.Foreground = $mod.Renk
        $ik.Margin = "0,0,8,0"
        $ik.VerticalAlignment = "Center"
        $baslik.Children.Add($ik) | Out-Null
    }

    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text = $mod.Ad
    $tb.FontSize = 13
    $tb.FontWeight = "SemiBold"
    $tb.Foreground = "#E8ECF1"
    $tb.TextTrimming = "CharacterEllipsis"
    $tb.VerticalAlignment = "Center"
    $baslik.Children.Add($tb) | Out-Null
    $sp.Children.Add($baslik) | Out-Null

    $desc = New-Object System.Windows.Controls.TextBlock
    $desc.Text = $mod.Aciklama
    $desc.FontSize = 10
    $desc.Foreground = "#3D4555"
    $desc.TextTrimming = "CharacterEllipsis"
    $desc.Margin = "0,4,0,0"
    $sp.Children.Add($desc) | Out-Null

    $btn.Content = $sp

    $funcName = $mod.Func; $modAdi = $mod.Ad; $backendYolu = $global:BACKEND
    $btn.Add_Click({
        $f = $funcName; $ad = $modAdi
        if ($global:GOMULU_MOD) { BaslatGomulu $f $ad }
        else {
            $b = $backendYolu
            $sc = ". `"$b`"; Clear-Host; $f; Write-Host ''; Read-Host | Out-Null"
            $enc = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($sc))
            Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $enc" -Verb RunAs -ErrorAction SilentlyContinue
        }
    }.GetNewClosure())

    return $btn
}

# == NAVIGASYON SISTEMI ========================================
function NavAktifYap($hedef) {
    foreach ($nav in $global:NAV_LISTESI) {
        $nav.Container.Background = [System.Windows.Media.Brushes]::Transparent
        $nav.Icon.Foreground = "#4A5066"
        $nav.Label.Foreground = "#8A8FA0"
        $nav.Label.FontWeight = "Normal"
    }
    if ($hedef -ne $null) {
        $nav_bg = [System.Windows.Media.BrushConverter]::new().ConvertFrom("#111824")
        $hedef.Container.Background = $nav_bg
        $hedef.Icon.Foreground = $hedef.Renk
        $hedef.Label.Foreground = "#E8ECF1"
        $hedef.Label.FontWeight = "SemiBold"
    }
}

function HizliPaneliYenile {
    $QuickPanel.Children.Clear()
    $liste = $global:HIZLI_ERISIM
    if ($global:FAVORILER.Count -gt 0) {
        $liste = @($global:FAVORILER | Select-Object -First 6)
    }
    foreach ($no in $liste) {
        if ($global:MODULLER.Contains($no)) {
            $QuickPanel.Children.Add((HizliKartOlustur $no $global:MODULLER[$no])) | Out-Null
        }
    }
}

function WrapPanelBagla($panel, $scroll) {
    $global:_wp = $panel; $global:_sc = $scroll
    $g = $scroll.ActualWidth
    if ($g -gt 40) { $panel.Width = $g - 20 }
    $scroll.Add_SizeChanged({
        $gn = $global:_sc.ActualWidth
        if ($gn -gt 40) { $global:_wp.Width = $gn - 20 }
    })
}

function SayfaAnimasyonu([System.Windows.UIElement]$hedef) {
    $hedef.Opacity = 0
    $hedef.Visibility = "Visible"
    $anim = New-Object System.Windows.Media.Animation.DoubleAnimation
    $anim.From     = 0.0
    $anim.To       = 1.0
    $anim.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(220))
    $anim.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
    $anim.EasingFunction.EasingMode = [System.Windows.Media.Animation.EasingMode]::EaseOut
    $hedef.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $anim)
}

function SayfaGoster([string]$sayfa, [string]$katAdi, [array]$katFiltre) {
    $TxtArama.Text = ""
    if ($sayfa -eq "Dashboard") {
        $CategoryView.Visibility = "Collapsed"
        SayfaAnimasyonu $DashboardView
        $global:AKTIF_SAYFA = "Dashboard"
        HizliPaneliYenile
    } else {
        $DashboardView.Visibility = "Collapsed"
        SayfaAnimasyonu $CategoryView
        $global:AKTIF_SAYFA = "Kategori"

        if ($katAdi -eq "Favoriler") {
            $TxtKatBaslik.Text = "Favoriler"
            $TxtKatAciklama.Text = "Favori olarak işaretlediğiniz araçlar"
            $TxtKatIkon.Text = [string][char]0xE735
            $KatIkonBorder.Background = "#FBBF24"
        } elseif ($katAdi -eq "Tüm Araçlar") {
            $TxtKatBaslik.Text = "Tüm Araçlar"
            $TxtKatAciklama.Text = ($global:MODULLER.Count.ToString() + " modülü tek listede görün")
            $TxtKatIkon.Text = [string][char]0xEA37
            $KatIkonBorder.Background = "#5A6478"
        } else {
            $kat = $global:KATEGORILER[$katAdi]
            if ($kat) {
                $TxtKatBaslik.Text = $katAdi
                $TxtKatAciklama.Text = $kat.Aciklama
                $TxtKatIkon.Text = $kat.Ikon
                $KatIkonBorder.Background = $kat.Renk
            }
        }
        KategoriGoster $katAdi $katFiltre
    }
}

function KategoriGoster([string]$katAdi, [array]$katFiltre) {
    $ModulPanel.Children.Clear()
    if ($katAdi -eq "Favoriler") {
        $global:AKTIF_FILTRE = "Favoriler"
        foreach ($no in $global:MODULLER.Keys) {
            if (FavoriMi $no) { $ModulPanel.Children.Add((KartOlustur $no $global:MODULLER[$no])) | Out-Null }
        }
    } elseif ($katAdi -eq "Tüm Araçlar") {
        $global:AKTIF_FILTRE = "Tumu"
        foreach ($no in $global:MODULLER.Keys) {
            $ModulPanel.Children.Add((KartOlustur $no $global:MODULLER[$no])) | Out-Null
        }
    } else {
        $global:AKTIF_FILTRE = $katAdi
        foreach ($n in $katFiltre) {
            if ($global:MODULLER.Contains($n)) {
                $ModulPanel.Children.Add((KartOlustur $n $global:MODULLER[$n])) | Out-Null
            }
        }
    }
    if ($global:ModulScrollRef -ne $null) {
        $g = $global:ModulScrollRef.ActualWidth
        if ($g -gt 40) { $ModulPanel.Width = $g - 20 }
    }
    $TxtModSay.Text = $ModulPanel.Children.Count.ToString() + " araç"
}

function ModulFiltele([string]$aranan) {
    $ModulPanel.Children.Clear()
    $kelime = $aranan.Trim().ToLower()

    if ($global:AKTIF_FILTRE -eq "Favoriler") {
        foreach ($no in $global:MODULLER.Keys) {
            $mod = $global:MODULLER[$no]
            if (FavoriMi $no) {
                if ($kelime -eq "" -or $mod.Ad.ToLower().Contains($kelime) -or $mod.Aciklama.ToLower().Contains($kelime)) {
                    $ModulPanel.Children.Add((KartOlustur $no $mod)) | Out-Null
                }
            }
        }
    } elseif ($global:AKTIF_FILTRE -eq "Tumu") {
        foreach ($no in $global:MODULLER.Keys) {
            $mod = $global:MODULLER[$no]
            if ($kelime -eq "" -or $mod.Ad.ToLower().Contains($kelime) -or $mod.Aciklama.ToLower().Contains($kelime)) {
                $ModulPanel.Children.Add((KartOlustur $no $mod)) | Out-Null
            }
        }
    } else {
        $kat = $global:KATEGORILER[$global:AKTIF_FILTRE]
        if ($kat) {
            foreach ($n in $kat.Moduller) {
                if ($global:MODULLER.Contains($n)) {
                    $mod = $global:MODULLER[$n]
                    if ($kelime -eq "" -or $mod.Ad.ToLower().Contains($kelime) -or $mod.Aciklama.ToLower().Contains($kelime)) {
                        $ModulPanel.Children.Add((KartOlustur $n $mod)) | Out-Null
                    }
                }
            }
        }
    }
    $TxtModSay.Text = $ModulPanel.Children.Count.ToString() + " araç"
}

# == SIDEBAR NAV BUTONU OLUSTUR (CCleaner stil: ikon + etiket) ====
function NavBtnOlustur($ikonChar, $renkStr, $etiketStr) {
    $btn = New-Object System.Windows.Controls.Button
    $btn.Cursor = "Hand"
    $btn.HorizontalContentAlignment = "Left"
    $btn.Height = 40
    $btn.Margin = "0,1"
    $btn.ToolTip = $etiketStr
    $btn.Background = [System.Windows.Media.Brushes]::Transparent
    $btn.BorderThickness = [System.Windows.Thickness]::new(0)
    $btn.Padding = [System.Windows.Thickness]::new(0)

    # Custom template: rounded highlight
    $templateStr = '<ControlTemplate xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" TargetType="Button"><Border x:Name="bd" Background="Transparent" CornerRadius="10" Padding="14,0"><ContentPresenter VerticalAlignment="Center"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="bd" Property="Background" Value="#0F1219"/></Trigger></ControlTemplate.Triggers></ControlTemplate>'
    $btn.Template = [System.Windows.Markup.XamlReader]::Parse($templateStr)

    # Container border — aktif state icin arka plan olarak kullanilacak
    $container = New-Object System.Windows.Controls.Border
    $container.CornerRadius = "10"
    $container.Background = [System.Windows.Media.Brushes]::Transparent
    $container.Margin = "0,1"
    $container.Child = $btn

    # Icerik: ikon + etiket
    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Orientation = "Horizontal"

    $ikonTb = New-Object System.Windows.Controls.TextBlock
    $ikonTb.Text = $ikonChar
    $ikonTb.FontFamily = "Segoe MDL2 Assets"
    $ikonTb.FontSize = 17
    $ikonTb.Foreground = "#4A5066"
    $ikonTb.Width = 24
    $ikonTb.VerticalAlignment = "Center"
    $sp.Children.Add($ikonTb) | Out-Null

    $labelTb = New-Object System.Windows.Controls.TextBlock
    $labelTb.Text = $etiketStr
    $labelTb.FontSize = 13
    $labelTb.FontFamily = "Segoe UI"
    $labelTb.Foreground = "#8A8FA0"
    $labelTb.VerticalAlignment = "Center"
    $labelTb.Margin = "10,0,0,0"
    $sp.Children.Add($labelTb) | Out-Null

    $btn.Content = $sp

    return @{ Container=$container; Button=$btn; Icon=$ikonTb; Label=$labelTb; Renk=$renkStr }
}

# == SIDEBAR DOLDUR (CCleaner stil: ikon + etiket) ============
# Ana Sayfa
$homeNav = NavBtnOlustur ([string][char]0xEA8A) "#7C5CFC" "Dashboard"
$homeNav.Button.Add_Click({
    NavAktifYap $homeNav
    SayfaGoster "Dashboard"
}.GetNewClosure())
$NavPanel.Children.Add($homeNav.Container) | Out-Null
$global:NAV_LISTESI += $homeNav

# Ayirac
$sep1 = New-Object System.Windows.Controls.Border
$sep1.Height = 1; $sep1.Background = "#151A26"; $sep1.Margin = "6,8"
$NavPanel.Children.Add($sep1) | Out-Null

# Kategori butonlari
foreach ($katAd in $global:KATEGORILER.Keys) {
    $kat = $global:KATEGORILER[$katAd]
    $navItem = NavBtnOlustur $kat.Ikon $kat.Renk $katAd

    $localNav   = $navItem
    $localAd    = $katAd
    $localFiltre = $kat.Moduller
    $navItem.Button.Add_Click({
        NavAktifYap $localNav
        SayfaGoster "Kategori" $localAd $localFiltre
    }.GetNewClosure())

    $NavPanel.Children.Add($navItem.Container) | Out-Null
    $global:NAV_LISTESI += $navItem
}

# Ayirac 2
$sep2 = New-Object System.Windows.Controls.Border
$sep2.Height = 1; $sep2.Background = "#151A26"; $sep2.Margin = "6,8"
$NavPanel.Children.Add($sep2) | Out-Null

# Favoriler
$favNav = NavBtnOlustur ([string][char]0xE735) "#FBBF24" "Favoriler"
$favNav.Button.Add_Click({
    NavAktifYap $favNav
    SayfaGoster "Kategori" "Favoriler" @()
}.GetNewClosure())
$NavPanel.Children.Add($favNav.Container) | Out-Null
$global:NAV_LISTESI += $favNav

# Tum Araclar
$tumNav = NavBtnOlustur ([string][char]0xEA37) "#5A6478" "Tüm Araçlar"
$tumNav.Button.Add_Click({
    NavAktifYap $tumNav
    SayfaGoster "Kategori" "Tüm Araçlar" @()
}.GetNewClosure())
$NavPanel.Children.Add($tumNav.Container) | Out-Null
$global:NAV_LISTESI += $tumNav

# ── Disk Treemap nav butonu ──
$treemapNav = NavBtnOlustur ([string][char]0xEDA2) "#60A5FA" "Disk Haritası"
$treemapNav.Button.Add_Click({
    TreemapCiz "C:\"
}.GetNewClosure())
$NavPanel.Children.Add($treemapNav.Container) | Out-Null

# ── Tema Degistir nav butonu ──
$temaNav = NavBtnOlustur ([string][char]0xE793) "#C084FC" "Tema"
$temaNav.Button.Add_Click({
    TemaDegistir
}.GetNewClosure())
$NavPanel.Children.Add($temaNav.Container) | Out-Null

# == TEMA DESTEGI ==================================================
$global:TEMA_MODU = "dark"  # dark / light

function TemaUygula([hashtable]$t) {
    $bc = [System.Windows.Media.BrushConverter]::new()
    # Ana pencere
    $window.Background = $bc.ConvertFromString($t.WindowBg)
    # Dashboard & Kategori arka planlari
    $DashboardView.Background = $bc.ConvertFromString($t.ContentBg)
    $CategoryView.Background  = $bc.ConvertFromString($t.ContentBg)
    # Sidebar
    $sidebar = $window.FindName("SidebarBorder")
    # Sidebar parent border — Grid.Column=0'daki ilk Border
    try {
        $sideGrid = $window.Content
        if ($sideGrid -and $sideGrid.Children.Count -gt 0) {
            $sidePanel = $sideGrid.Children[0]
            if ($sidePanel -is [System.Windows.Controls.Border]) {
                $sidePanel.Background = $bc.ConvertFromString($t.SidebarBg)
                $sidePanel.BorderBrush = $bc.ConvertFromString($t.BorderColor)
            }
        }
    } catch {}
    # Log paneli
    $TxtCikti.Foreground = $bc.ConvertFromString($t.LogFg)
    $TxtCikti.Background = $bc.ConvertFromString($t.LogBg)
    $ActivityPanel.Background = $bc.ConvertFromString($t.PanelBg)
    $ActivityPanel.BorderBrush = $bc.ConvertFromString($t.BorderColor)
    # Treemap arka plan
    $TreemapPanel.Background = $bc.ConvertFromString($t.ContentBg)
    $TreemapCanvas.Background = $bc.ConvertFromString($t.ContentBg)
    # Nav butonlari — metin renklerini guncelle
    foreach ($nav in $global:NAV_LISTESI) {
        if ($nav.Label.FontWeight -ne [System.Windows.FontWeights]::SemiBold) {
            $nav.Icon.Foreground = $bc.ConvertFromString($t.NavIconFg)
            $nav.Label.Foreground = $bc.ConvertFromString($t.NavLabelFg)
        }
    }
    # Baslik metinleri
    try {
        foreach ($tb in @($TxtKatBaslik, $TxtKatAciklama)) {
            if ($tb) { $tb.Foreground = $bc.ConvertFromString($t.TextPrimary) }
        }
    } catch {}
}

function TemaDegistir {
    if ($global:TEMA_MODU -eq "dark") {
        $global:TEMA_MODU = "light"
        # ── LIGHT TEMA — Material Design Surface renkleri ──
        TemaUygula @{
            WindowBg    = "#F5F5F5"
            ContentBg   = "#FAFAFA"
            SidebarBg   = "#FFFFFF"
            PanelBg     = "#FFFFFF"
            LogBg       = "#F8F9FA"
            LogFg       = "#37474F"
            BorderColor = "#E0E0E0"
            NavIconFg   = "#90A4AE"
            NavLabelFg  = "#546E7A"
            TextPrimary = "#212121"
        }
        ToastGoster "Tema" "Acik tema uygulandı" "bilgi"
    } else {
        $global:TEMA_MODU = "dark"
        # ── DARK TEMA — Varsayilan ──
        TemaUygula @{
            WindowBg    = "#0B0E14"
            ContentBg   = "#0B0E14"
            SidebarBg   = "#080B11"
            PanelBg     = "#080B11"
            LogBg       = "Transparent"
            LogFg       = "#5A6478"
            BorderColor = "#151A26"
            NavIconFg   = "#4A5066"
            NavLabelFg  = "#8A8FA0"
            TextPrimary = "#E8ECF1"
        }
        ToastGoster "Tema" "Koyu tema uygulandı" "bilgi"
    }

    # Ayara kaydet
    $global:AYARLAR.Tema = $global:TEMA_MODU
    AyarKaydet
}

# == DISK ALANI HARITASI (TREEMAP) =================================
function TreemapBoyutStr($b) {
    if ($b -ge 1GB) { "{0:N1} GB" -f ($b/1GB) }
    elseif ($b -ge 1MB) { "{0:N0} MB" -f ($b/1MB) }
    elseif ($b -ge 1KB) { "{0:N0} KB" -f ($b/1KB) }
    else { "{0} B" -f $b }
}

function TreemapCiz([string]$surucu) {
    $TreemapCanvas.Children.Clear()
    $TreemapPanel.Visibility = "Visible"
    $DashboardView.Visibility = "Collapsed"
    $CategoryView.Visibility  = "Collapsed"
    $TreemapBaslik.Text = "Disk Haritasi - " + $surucu
    $TreemapBilgi.Text  = "Taranıyor... (bu islem birkac saniye surebilir)"

    try { $window.Dispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background) } catch {}

    try {
        $klasorler = [System.Collections.Generic.List[PSCustomObject]]::new()
        $digerBoyut = [long]0

        $hedef = if ($surucu -match '^[A-Z]:') { $surucu } else { "C:\" }

        # Erisim hatasi veren sistem klasorlerini atla
        $atlanacak = @('$Recycle.Bin','System Volume Information','Config.Msi','$WinREAgent','Recovery','$SysReset','DumpStack.log.tmp')
        $items = Get-ChildItem -Path $hedef -Directory -Force -ErrorAction SilentlyContinue |
                 Where-Object { $atlanacak -notcontains $_.Name }

        $toplamKlasor = @($items).Count
        $sayac = 0
        foreach ($dir in $items) {
            $sayac++
            try { $TreemapBilgi.Text = ("Taraniyor: {0} ({1}/{2})" -f $dir.Name, $sayac, $toplamKlasor) } catch {}
            try { $window.Dispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background) } catch {}
            try {
                # Depth 2 ile sinirla — UI thread'i bloke etmeden makul sonuc
                $boyut = (Get-ChildItem $dir.FullName -Recurse -File -Force -Depth 2 -ErrorAction SilentlyContinue |
                          Measure-Object Length -Sum -ErrorAction SilentlyContinue).Sum
                if ($boyut -eq $null) { $boyut = 0 }

                if ($boyut -ge 50MB) {
                    $klasorler.Add([PSCustomObject]@{ Ad=$dir.Name; Boyut=[long]$boyut; Yol=$dir.FullName })
                } else {
                    $digerBoyut += $boyut
                }
            } catch {
                $digerBoyut += 0
            }
        }

        # "Diger" blok ekle
        if ($digerBoyut -gt 0) {
            $klasorler.Add([PSCustomObject]@{ Ad="Diger Dosyalar"; Boyut=$digerBoyut; Yol="" })
        }

        # Buyukten kucuge sirala
        $klasorler = [System.Collections.Generic.List[PSCustomObject]]($klasorler | Sort-Object Boyut -Descending)

        $toplamBoyut = ($klasorler | Measure-Object Boyut -Sum).Sum
        if ($toplamBoyut -le 0) {
            $TreemapBilgi.Text = "Klasor bulunamadi veya erisim engellendi."
            return
        }

        $TreemapBilgi.Text = ("{0} klasor, toplam {1}" -f $klasorler.Count, (TreemapBoyutStr $toplamBoyut))

        # Canvas boyutunu al
        try { $window.Dispatcher.Invoke([Action]{}, [System.Windows.Threading.DispatcherPriority]::Background) } catch {}
        $cW = $TreemapCanvas.ActualWidth;  if ($cW -le 0) { $cW = 700 }
        $cH = $TreemapCanvas.ActualHeight; if ($cH -le 0) { $cH = 400 }

        # ── SQUARIFIED TREEMAP ALGORITMASI ──
        # Basit slice-and-dice (yatay/dikey alternatif bolme)
        $renkler = @("#60A5FA","#34D399","#F87171","#FBBF24","#C084FC","#FB923C","#38BDF8",
                     "#A78BFA","#F472B6","#4ADE80","#818CF8","#FCD34D","#FB7185","#2DD4BF")

        function CizBlok($items, $x, $y, $w, $h, $dikey) {
            if ($items.Count -eq 0 -or $w -lt 2 -or $h -lt 2) { return }

            $itemToplam = ($items | Measure-Object Boyut -Sum).Sum
            if ($itemToplam -le 0) { return }

            $pos = 0
            for ($i = 0; $i -lt $items.Count; $i++) {
                $oran = $items[$i].Boyut / $itemToplam
                if ($dikey) {
                    $bH = [math]::Max(2, [math]::Floor($h * $oran))
                    if ($i -eq $items.Count - 1) { $bH = $h - $pos }  # Son blok kalan alani doldurur
                    $bX = $x; $bY = $y + $pos; $bW = $w; $bHh = $bH
                    $pos += $bH
                } else {
                    $bW2 = [math]::Max(2, [math]::Floor($w * $oran))
                    if ($i -eq $items.Count - 1) { $bW2 = $w - $pos }
                    $bX = $x + $pos; $bY = $y; $bW = $bW2; $bHh = $h
                    $pos += $bW2
                }

                # Blok ciz
                $border = New-Object System.Windows.Controls.Border
                $renkIdx = $i % $renkler.Count
                $border.Background = $renkler[$renkIdx]
                $border.BorderBrush = "#0B0E14"
                $border.BorderThickness = "1"
                $border.CornerRadius = "3"
                $border.Width = [math]::Max(2, $bW)
                $border.Height = [math]::Max(2, $bHh)
                $border.Opacity = 0.85
                $border.ToolTip = $items[$i].Ad + " - " + (TreemapBoyutStr $items[$i].Boyut)

                # Etiket (yeterli alan varsa)
                if ($bW -gt 60 -and $bHh -gt 28) {
                    $sp = New-Object System.Windows.Controls.StackPanel
                    $sp.VerticalAlignment = "Center"
                    $sp.HorizontalAlignment = "Center"
                    $sp.Margin = "4"

                    $lbl = New-Object System.Windows.Controls.TextBlock
                    $lbl.Text = $items[$i].Ad
                    $lbl.FontSize = if ($bW -gt 120 -and $bHh -gt 50) { 11 } else { 9 }
                    $lbl.FontWeight = "SemiBold"
                    $lbl.Foreground = "#0B0E14"
                    $lbl.TextTrimming = "CharacterEllipsis"
                    $lbl.HorizontalAlignment = "Center"
                    $sp.Children.Add($lbl) | Out-Null

                    if ($bHh -gt 42 -and $bW -gt 70) {
                        $szLbl = New-Object System.Windows.Controls.TextBlock
                        $szLbl.Text = TreemapBoyutStr $items[$i].Boyut
                        $szLbl.FontSize = 9
                        $szLbl.Foreground = "#1A202C"
                        $szLbl.HorizontalAlignment = "Center"
                        $sp.Children.Add($szLbl) | Out-Null
                    }
                    $border.Child = $sp
                }

                [System.Windows.Controls.Canvas]::SetLeft($border, $bX)
                [System.Windows.Controls.Canvas]::SetTop($border, $bY)
                $TreemapCanvas.Children.Add($border) | Out-Null
            }
        }

        # Iki yariya bol: sol yarim buyuk klasorler, sag yarim kucukler (daha iyi goruntu)
        $yarisi = [math]::Min([math]::Ceiling($klasorler.Count / 2), $klasorler.Count)
        $sol = [System.Collections.Generic.List[PSCustomObject]]($klasorler | Select-Object -First $yarisi)
        $sag = [System.Collections.Generic.List[PSCustomObject]]($klasorler | Select-Object -Skip $yarisi)

        $solToplam = ($sol | Measure-Object Boyut -Sum).Sum
        $sagToplam = ($sag | Measure-Object Boyut -Sum).Sum
        $genelToplam = $solToplam + $sagToplam
        if ($genelToplam -le 0) { $genelToplam = 1 }

        $solW = [math]::Floor($cW * ($solToplam / $genelToplam))
        $sagW = $cW - $solW

        CizBlok $sol 0 0 $solW $cH $true
        if ($sag.Count -gt 0) {
            CizBlok $sag $solW 0 $sagW $cH $true
        }
    } catch {
        $TreemapBilgi.Text = "Hata: " + $_.Exception.Message
    }
}

# == EVENT HANDLER'LAR ==========================================
$BtnLogToggle.Add_Click({
    if ($global:LOG_ACIK) { LogPanelKapat } else { LogPanelAc }
}.GetNewClosure())

$BtnLogKapat.Add_Click({ LogPanelKapat }.GetNewClosure())
$BtnLogTemizle.Add_Click({ $TxtCikti.Clear(); $TxtDurum.Text = "" }.GetNewClosure())
$BtnDurdur.Add_Click({ DurdurGomulu }.GetNewClosure())

# == DISA AKTARMA (EXPORT) ========================================
$BtnDisaAktar.Add_Click({
    try {
        $icerik = $TxtCikti.Text
        if ([string]::IsNullOrWhiteSpace($icerik)) {
            ToastGoster "Uyari" "Disa aktarilacak cikti yok. Once bir modul calistirin." "#FB923C" ([string][char]0xE7BA)
            return
        }

        $logKlasor = Join-Path $env:APPDATA "SistemBakim\Logs"
        if (-not (Test-Path $logKlasor)) { New-Item -ItemType Directory -Path $logKlasor -Force | Out-Null }
        $tarih = Get-Date -Format "yyyyMMdd_HHmmss"

        # --- TXT Export ---
        $txtDosya = Join-Path $logKlasor ("SistemBakim_Rapor_{0}.txt" -f $tarih)
        $txtRapor = [System.Collections.Generic.List[string]]::new()
        $txtRapor.Add("=" * 60)
        $txtRapor.Add("  SistemBakim - Islem Raporu")
        $txtRapor.Add("  Tarih: " + (Get-Date -Format "dd.MM.yyyy HH:mm:ss"))
        $txtRapor.Add("  Bilgisayar: " + $env:COMPUTERNAME + " / " + $env:USERNAME)
        $txtRapor.Add("=" * 60)
        $txtRapor.Add("")
        $txtRapor.Add($icerik)
        $txtRapor.Add("")
        $txtRapor.Add("=" * 60)
        $txtRapor.Add("  SistemBakim v5 - github.com/erdiyim/SistemBakim")
        [System.IO.File]::WriteAllLines($txtDosya, $txtRapor.ToArray(), [System.Text.Encoding]::UTF8)

        # --- HTML Export ---
        $htmlDosya = Join-Path $logKlasor ("SistemBakim_Rapor_{0}.html" -f $tarih)
        $satirlar = $icerik -split "`n"
        $htmlBody = ""
        foreach ($s in $satirlar) {
            $satir = $s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;'
            if ($satir -match '^\[.*\]\s+MODUL|BASLIK|TAMAMLANDI|SONUC') {
                $htmlBody += "<div class='ok'>$satir</div>`n"
            } elseif ($satir -match 'HATA|UYARI|Basarisiz|Red') {
                $htmlBody += "<div class='hata'>$satir</div>`n"
            } else {
                $htmlBody += "<div>$satir</div>`n"
            }
        }
        $htmlIcerik = @"
<!DOCTYPE html>
<html lang="tr"><head><meta charset="UTF-8">
<title>SistemBakim Rapor - $tarih</title>
<style>
body{background:#0D1117;color:#C9D1D9;font-family:Consolas,monospace;font-size:13px;padding:30px;max-width:900px;margin:0 auto}
h1{color:#7C5CFC;font-size:20px;border-bottom:2px solid #1A1F2E;padding-bottom:10px}
.meta{color:#5A6478;font-size:11px;margin-bottom:20px}
.ok{color:#34D399} .hata{color:#F87171}
div{line-height:1.6;white-space:pre-wrap;word-wrap:break-word}
.footer{margin-top:30px;padding-top:10px;border-top:1px solid #1A1F2E;color:#3D4555;font-size:11px}
</style></head><body>
<h1>SistemBakim - Islem Raporu</h1>
<div class="meta">Tarih: $(Get-Date -Format "dd.MM.yyyy HH:mm:ss") | $env:COMPUTERNAME / $env:USERNAME</div>
$htmlBody
<div class="footer">SistemBakim v5 | Otomatik olusturuldu</div>
</body></html>
"@
        [System.IO.File]::WriteAllText($htmlDosya, $htmlIcerik, [System.Text.Encoding]::UTF8)

        # Kullaniciya bildir ve HTML'yi ac
        ToastGoster "Basarili" ("Rapor kaydedildi: " + (Split-Path $htmlDosya -Leaf)) "#34D399" ([string][char]0xE8FB)
        Start-Process $htmlDosya
    } catch {
        ToastGoster "Hata" ("Disa aktarma basarisiz: " + $_.Exception.Message) "#F87171" ([string][char]0xE783)
    }
}.GetNewClosure())

$BtnToastKapat.Add_Click({
    $ToastPanel.Visibility = "Collapsed"
    if ($global:TOAST_TIMER -ne $null) { $global:TOAST_TIMER.Stop() }
}.GetNewClosure())

# Sihirbaz butonlari
$BtnSihirbazBaslat.Add_Click({
    $SihirbazPanel.Visibility = "Collapsed"
    $global:AYARLAR.IlkCalistirma = $false
    AyarKaydet
    BaslatGomulu "TamBakim" "Hizli Tarama (Ilk Calistirma)"
}.GetNewClosure())

$BtnSihirbazAtla.Add_Click({
    $SihirbazPanel.Visibility = "Collapsed"
    $global:AYARLAR.IlkCalistirma = $false
    AyarKaydet
}.GetNewClosure())

$BtnSmartScan.Add_Click({
    BaslatGomulu "TamBakim" "Akıllı Tarama (Tam Bakım)"
}.GetNewClosure())

$TxtArama.Add_TextChanged({
    $TxtAramaYer.Visibility = if ($TxtArama.Text -eq "") { "Visible" } else { "Collapsed" }
    ModulFiltele $TxtArama.Text
}.GetNewClosure())

# == STATUS TIMER (5 sn) =======================================
$statusTimer = New-Object System.Windows.Threading.DispatcherTimer
$statusTimer.Interval = [TimeSpan]::FromSeconds(5)
$statusTimer.Add_Tick({
    try {
        $cpuYuz = [int]((Get-CimInstance Win32_Processor -ErrorAction Stop |
                  Measure-Object -Property LoadPercentage -Average).Average)
        $os2    = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $ramYuz = [int](($os2.TotalVisibleMemorySize - $os2.FreePhysicalMemory) /
                        $os2.TotalVisibleMemorySize * 100)
        $diskYuz = 0
        try {
            $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
            $diskYuz = [int](($disk.Size - $disk.FreeSpace) / $disk.Size * 100)
        } catch {}

        $TxtCPU.Text  = $cpuYuz.ToString() + "%"
        $TxtRAM.Text  = $ramYuz.ToString() + "%"
        $TxtDisk.Text = $diskYuz.ToString() + "%"
        $CpuBar.Value  = $cpuYuz
        $RamBar.Value  = $ramYuz
        $DiskBar.Value = $diskYuz

        # Skor hesapla
        $skor = 100
        if ($cpuYuz -ge 90) { $skor -= 25 } elseif ($cpuYuz -ge 70) { $skor -= 12 }
        if ($ramYuz -ge 90) { $skor -= 25 } elseif ($ramYuz -ge 75) { $skor -= 12 }
        if ($diskYuz -ge 95) { $skor -= 20 } elseif ($diskYuz -ge 85) { $skor -= 10 }
        $global:SAGLIK_SKORU = $skor

        # Saglik halkasini guncelle (sadece dashboard gorunuyorsa)
        if ($global:AKTIF_SAYFA -eq "Dashboard") {
            DrawHealthRing $skor
        }

        # Dinamik renkler
        $TxtCPU.Foreground  = if ($cpuYuz -gt 80) { "#F87171" } elseif ($cpuYuz -gt 50) { "#FBBF24" } else { "#34D399" }
        $TxtRAM.Foreground  = if ($ramYuz -gt 80) { "#F87171" } elseif ($ramYuz -gt 60) { "#FBBF24" } else { "#60A5FA" }
        $TxtDisk.Foreground = if ($diskYuz -gt 90) { "#F87171" } elseif ($diskYuz -gt 75) { "#FBBF24" } else { "#FB923C" }
        $CpuBar.Foreground  = $TxtCPU.Foreground
        $RamBar.Foreground  = $TxtRAM.Foreground
        $DiskBar.Foreground = $TxtDisk.Foreground
    } catch {}
})
$statusTimer.Start()

# == PENCERE YUKLENDIGINDE ======================================
$window.Add_Loaded({
    # WrapPanel genislik baglama
    $global:ModulScrollRef = $ModulScroll
    $ModulScroll.Add_SizeChanged({
        $g = $global:ModulScrollRef.ActualWidth
        if ($g -gt 40) { $ModulPanel.Width = $g - 20 }
    })

    # Dashboard hizli paneli yukle
    HizliPaneliYenile

    # OS bilgisi
    try {
        $osVer = (Get-CimInstance Win32_OperatingSystem -ErrorAction Stop).Caption -replace 'Microsoft ',''
        $TxtOS.Text = $osVer
    } catch { $TxtOS.Text = "Windows" }

    # Ilk saglik halkasi
    DrawHealthRing 0

    # Kayitli tema tercihini uygula
    if ($global:AYARLAR.Tema -eq "light") {
        $global:TEMA_MODU = "dark"  # TemaDegistir toggle edecek
        TemaDegistir
    }

    # Home nav aktif
    NavAktifYap $global:NAV_LISTESI[0]

    # ── BILDIRIM KARTI: Son bakim tarihine gore hatirlatma ──
    $sonBakim = $global:AYARLAR.SonBakimTarih
    if ($sonBakim) {
        try {
            $sonTarih = [DateTime]::Parse($sonBakim)
            $gun = ((Get-Date) - $sonTarih).Days
            if ($gun -ge 30) {
                $BildirimIkon.Text = [string][char]0xE7BA
                $BildirimIkon.Foreground = "#FBBF24"
                $BildirimBaslik.Text = "Bakim Hatirlatmasi"
                $BildirimMesaj.Text = ("Son bakimdan bu yana {0} gun gecti. Akilli Tarama ile hizli bir kontrol yapabilirsiniz." -f $gun)
                $BildirimKarti.Visibility = "Visible"
            } elseif ($gun -ge 7) {
                $BildirimIkon.Text = [string][char]0xE946
                $BildirimIkon.Foreground = "#60A5FA"
                $BildirimBaslik.Text = "Hosgeldiniz!"
                $BildirimMesaj.Text = ("Son bakim: {0} gun once. Sisteminiz kontrol altinda." -f $gun)
                $BildirimKarti.Visibility = "Visible"
            }
        } catch {}
    } elseif (-not $global:AYARLAR.IlkCalistirma) {
        $BildirimIkon.Text = [string][char]0xE7BA
        $BildirimIkon.Foreground = "#FBBF24"
        $BildirimBaslik.Text = "Henuz bakim yapilmadi"
        $BildirimMesaj.Text = "Akilli Tarama ile sisteminizi hizlica kontrol edin."
        $BildirimKarti.Visibility = "Visible"
    }

    # ── ILK CALISTIRMA SIHIRBAZI ──
    if ($global:AYARLAR.IlkCalistirma) {
        $SihirbazPanel.Opacity = 0
        $SihirbazPanel.Visibility = "Visible"
        $fadeAnim = New-Object System.Windows.Media.Animation.DoubleAnimation
        $fadeAnim.From = 0; $fadeAnim.To = 1
        $fadeAnim.Duration = [System.Windows.Duration]::new([TimeSpan]::FromMilliseconds(400))
        $fadeAnim.EasingFunction = New-Object System.Windows.Media.Animation.CubicEase
        $SihirbazPanel.BeginAnimation([System.Windows.UIElement]::OpacityProperty, $fadeAnim)
    }
})

# == HAZIR MESAJI ===============================================
CiktiEkle ("SistemBakim v5.0 hazır -- " + $global:MODULLER.Count + " modül yüklendi")
CiktiEkle ("Backend: " + $global:BACKEND)

# == PENCEREYI GOSTER ==========================================
$window.Add_Closed({
    $statusTimer.Stop()
    if ($global:TOAST_TIMER -ne $null) { $global:TOAST_TIMER.Stop() }
    if ($global:CIKTI_TIMER -ne $null) { $global:CIKTI_TIMER.Stop() }
    if ($global:AKTIF_ISLEM -ne $null) {
        try {
            $pid = $global:AKTIF_ISLEM.Id
            # Alt proses agacini temizle
            try { Get-CimInstance Win32_Process -Filter "ParentProcessId=$pid" -ErrorAction SilentlyContinue |
                  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue } } catch {}
            $global:AKTIF_ISLEM | Stop-Process -Force -ErrorAction SilentlyContinue
        } catch {}
    }
    # Temp log dosyasini temizle
    if ($global:LOG_DOSYA -and (Test-Path $global:LOG_DOSYA)) {
        Remove-Item $global:LOG_DOSYA -Force -ErrorAction SilentlyContinue
    }
})
$window.ShowDialog() | Out-Null
