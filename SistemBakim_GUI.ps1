# ================================================================
#   SistemBakim v5.0 -- WPF Grafik Arayuz
#   Kullanim: Cift tikla veya "Run with PowerShell"
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

$KLASOR  = Split-Path $MyInvocation.MyCommand.Path
$BACKEND = Join-Path $KLASOR "SistemBakim_v5.ps1"

# ── MODUL TANIMLARI ──────────────────────────────────────────
$MODULLER = [ordered]@{
    1  = @{ Ad="Disk Analizi";        Aciklama="Surucu doluluk ve buyuk dosya";  Func="DiskAnalizi";              Renk="#89B4FA" }
    2  = @{ Ad="Yinelenen Dosya";     Aciklama="MD5 hash ile kopya tarama";      Func="DuplicateBul";             Renk="#89B4FA" }
    3  = @{ Ad="Kapsamli Temizlik";   Aciklama="19 konum, junk ve temp temizle"; Func="KapsamliTemizlik";         Renk="#89B4FA" }
    4  = @{ Ad="SMART Disk";          Aciklama="Disk saglik ve sicaklik";         Func="SmartDiskSagligi";         Renk="#F9E2AF" }
    5  = @{ Ad="Crash Dump";          Aciklama="Cokme dosyalarini temizle";       Func="CrashDumpTemizle";         Renk="#89B4FA" }
    6  = @{ Ad="Shadow & Restore";    Aciklama="Geri yukleme noktalari yonet";   Func="ShadowVeRestore";          Renk="#89B4FA" }
    7  = @{ Ad="Log Temizle";         Aciklama="Windows olay gunluklerini sil";  Func="WindowsLogTemizle";        Renk="#89B4FA" }
    8  = @{ Ad="Downloads Analizi";   Aciklama="Buyuk ve eski indirilenler";      Func="DownloadsAnalizi";         Renk="#89B4FA" }
    9  = @{ Ad="Sistem Tarama";       Aciklama="SFC ve DISM ile Windows onari";  Func="SistemTara";               Renk="#A6E3A1" }
    10 = @{ Ad="Olay Gunlugu";        Aciklama="Kritik hata ve uyari olaylari";  Func="OlayGunlugu";              Renk="#A6E3A1" }
    11 = @{ Ad="Servis Kontrol";      Aciklama="Gereksiz servisleri durdur";     Func="ServisKontrol";            Renk="#A6E3A1" }
    12 = @{ Ad="Baslangic Analizi";   Aciklama="Startup programlari ve suredigi"; Func="BaslangicAnalizi";        Renk="#A6E3A1" }
    13 = @{ Ad="Kaynak Durumu";       Aciklama="Canli CPU RAM GPU Disk izle";    Func="KaynakDurumu";             Renk="#A6E3A1" }
    14 = @{ Ad="Guc Plani";           Aciklama="Enerji profili sec ve ayarla";   Func="GucPlani";                 Renk="#A6E3A1" }
    15 = @{ Ad="Ag Tanilamasi";       Aciklama="DNS Winsock TCP optimize";       Func="AgTanilamasi";             Renk="#94E2D5" }
    16 = @{ Ad="Guvenlik Kontrol";    Aciklama="Firewall ve Defender tarama";    Func="GuvenlikKontrol";          Renk="#F38BA8" }
    17 = @{ Ad="Gelismis Guvenlik";   Aciklama="Port host BitLocker RDP";        Func="GelismisGuvenlik";         Renk="#F38BA8" }
    18 = @{ Ad="Gelistirici";         Aciklama="node Docker NuGet pip temizlik"; Func="GelistiriciAraclari";      Renk="#F9E2AF" }
    19 = @{ Ad="Donanim Raporu";      Aciklama="BIOS USB termal ozet rapor";     Func="DonanımRaporu";            Renk="#F9E2AF" }
    20 = @{ Ad="HTML Dashboard";      Aciklama="Tarayicida gorsel sistem raporu"; Func="HtmlDashboard";           Renk="#CBA6F7" }
    21 = @{ Ad="Saglik Skoru";        Aciklama="100 puan sistem puanlama";       Func="SaglikSkoru";              Renk="#CBA6F7" }
    22 = @{ Ad="Haftalik Zamanla";    Aciklama="Otomatik bakim gorev ayarla";    Func="OtomasyonAyarla";          Renk="#CBA6F7" }
    23 = @{ Ad="Profil Sec";          Aciklama="Oyun Haftalik Hizli vb. profil"; Func="ProfilSec";                Renk="#CBA6F7" }
    24 = @{ Ad="Geri Yukleme";        Aciklama="Sistem geri yukleme noktasi";    Func="GeriYuklemeNoktasi";       Renk="#CBA6F7" }
    25 = @{ Ad="TAM BAKIM";           Aciklama="Tum temel modulleri calistir";   Func="TamBakim";                 Renk="#FAB387" }
    26 = @{ Ad="FPS Optimizasyon";    Aciklama="GameDVR MMCSS HAGS GPU Ag";     Func="FpsOyunOptimizasyonu";     Renk="#CBA6F7" }
    27 = @{ Ad="RAM Optimizasyon";    Aciklama="Standby list + working set";     Func="RamOptimizasyonu";         Renk="#CBA6F7" }
    28 = @{ Ad="Surec Temizleyici";   Aciklama="Oyun oncesi arka plan killer";   Func="SurecTemizleyici";         Renk="#CBA6F7" }
    29 = @{ Ad="Bloatware Kaldir";    Aciklama="Xbox Cortana Eglence uyg. sil";  Func="BloatwareKaldirici";       Renk="#CBA6F7" }
    30 = @{ Ad="Surucu Kontrolu";     Aciklama="Imzasiz ve sorunlu driverlar";   Func="SurucuKontrol";            Renk="#F9E2AF" }
    31 = @{ Ad="Windows Update";      Aciklama="Bekleyen guncelleme listesi";    Func="WindowsUpdateYonetici";    Renk="#F9E2AF" }
    32 = @{ Ad="Disk Optimize";       Aciklama="SSD TRIM veya HDD defrag";       Func="DiskOptimize";             Renk="#89B4FA" }
    33 = @{ Ad="WinSxS Temizle";      Aciklama="Component store boyutunu azalt"; Func="WinSxSTemizle";            Renk="#89B4FA" }
    34 = @{ Ad="Pil Sagligi";         Aciklama="Laptop pil wear level raporu";   Func="PilSagligi";               Renk="#F9E2AF" }
    35 = @{ Ad="Internet Hiz Testi";  Aciklama="Mbps indirme ve ping olcumu";    Func="InternetHiziTesti";        Renk="#94E2D5" }
    36 = @{ Ad="Bant Genisligi";      Aciklama="QoS rezervasyon P2P TCP ayar";  Func="BantGenisligiOptimize";    Renk="#94E2D5" }
    37 = @{ Ad="DirectX / GPU";       Aciklama="VRAM yenileme Hz DirectX surum"; Func="DirectXGPUTani";           Renk="#CBA6F7" }
    38 = @{ Ad="Oyun Modu Toggle";    Aciklama="Game Mode DVR acar veya kapatir"; Func="OyunModuYonetici";        Renk="#CBA6F7" }
    39 = @{ Ad="Hesap Denetimi";      Aciklama="Sifresiz ve suresi bitmez hesap"; Func="HesapGuvenlikDenetimi";   Renk="#F38BA8" }
    40 = @{ Ad="Suphe Baslangic";     Aciklama="Imzasiz baslangic programlari";  Func="SuphesizBaslangic";        Renk="#F38BA8" }
    41 = @{ Ad="Format Sihirbazi";    Aciklama="Tek tikla tum optimizasyonlar";  Func="FormatSonrasiSihirbaz";    Renk="#FAB387" }
    42 = @{ Ad="Win. Tweaks";         Aciklama="Transparency animasyon telemetri"; Func="WindowsPerformansTweaks"; Renk="#A6E3A1" }
    43 = @{ Ad="Sanal Bellek";        Aciklama="Pagefile RAM boyutuna gore";     Func="SanalBellekOptimize";      Renk="#A6E3A1" }
    44 = @{ Ad="Donanim Skoru";       Aciklama="CPU GPU RAM puanla ve oner";     Func="DonanımSkoruVeOneri";     Renk="#CBA6F7" }
    45 = @{ Ad="GPU Optimize";        Aciklama="NVIDIA AMD surucu tweakleri";   Func="GPUOptimize";              Renk="#A6E3A1" }
    46 = @{ Ad="Defender Istisna";     Aciklama="Oyun klasorlerini tara ekle";   Func="DefenderOyunIstisna";     Renk="#F38BA8" }
    47 = @{ Ad="Monitor Hz";           Aciklama="Yenileme hizi cozunurluk";     Func="MonitorOptimize";          Renk="#F9E2AF" }
    48 = @{ Ad="Hyper-V/VBS Kapat";  Aciklama="Sanallastirma kapat FPS arttir"; Func="HyperVVBSKapat";          Renk="#CBA6F7" }
    49 = @{ Ad="Tarayici Temizle";  Aciklama="Chrome Edge Firefox cache sil"; Func="TarayiciTemizleyici";     Renk="#89B4FA" }
    50 = @{ Ad="OEM Bloatware";     Aciklama="HP Dell Lenovo on yuklu sil";  Func="OEMBloatwareTespiti";     Renk="#F38BA8" }
    51 = @{ Ad="Boot Suresi";       Aciklama="Baslangic hizi olc iyilestir"; Func="BootSuresiAnalizi";      Renk="#A6E3A1" }
    52 = @{ Ad="Sag Tik Menu";      Aciklama="Win11 klasik menu shell ext"; Func="SagTikMenuTemizle";      Renk="#A6E3A1" }
    53 = @{ Ad="DNS Benchmark";     Aciklama="12 DNS test et en hizliyi bul"; Func="DNSBenchmark";            Renk="#94E2D5" }
}

# ── KATEGORI TANIMLARI ────────────────────────────────────────
$KATEGORILER = [ordered]@{
    "Tumu"          = @{ Modüller=@(1..53);                           Renk="#585B70"; Ikon="##" }
    "Temizlik"      = @{ Modüller=@(1,2,3,5,6,7,8,32,33,49,50);        Renk="#89B4FA"; Ikon="T"  }
    "Sistem"        = @{ Modüller=@(9,10,11,12,13,14,30,31,42,43,51,52); Renk="#A6E3A1"; Ikon="S"  }
    "Ag Guvenlik"   = @{ Modüller=@(15,16,17,35,36,39,40,53);          Renk="#F38BA8"; Ikon="G"  }
    "Oyun FPS"      = @{ Modüller=@(26,27,28,29,37,38,41,45,46,48);    Renk="#CBA6F7"; Ikon="O"  }
    "Donanim"       = @{ Modüller=@(4,18,19,34,44,45,47);             Renk="#F9E2AF"; Ikon="D"  }
    "Raporlar"      = @{ Modüller=@(20,21,22,23,24,25,44);            Renk="#FAB387"; Ikon="R"  }
    "Ag Hiz"        = @{ Modüller=@(15,35,36,53);                      Renk="#94E2D5"; Ikon="H"  }
    "Hizli Basla"   = @{ Modüller=@(41,42,43,44,45,46,48,49,50,26,27,28,29); Renk="#FAB387"; Ikon="!"  }
}

# ── WPF XAML ─────────────────────────────────────────────────
[xml]$xaml = @'
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Sistem Bakim Araci v5.0"
    Height="760" Width="1080"
    MinHeight="580" MinWidth="760"
    WindowStartupLocation="CenterScreen">
  <Window.Background>
    <SolidColorBrush Color="#1E1E2E"/>
  </Window.Background>
  <Window.Resources>

    <!-- Tile butonu stili -->
    <Style x:Key="TileStyle" TargetType="Button">
      <Setter Property="Background" Value="#313244"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Foreground" Value="#CDD6F4"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Margin" Value="6"/>
      <Setter Property="Width" Value="195"/>
      <Setter Property="Height" Value="78"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    CornerRadius="8" Padding="12,10">
              <ContentPresenter HorizontalAlignment="Left" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#45475A"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#585B70"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- Sidebar kategori butonu -->
    <Style x:Key="SidebarStyle" TargetType="Button">
      <Setter Property="Background" Value="Transparent"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Foreground" Value="#BAC2DE"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Margin" Value="4,2"/>
      <Setter Property="Padding" Value="10,8"/>
      <Setter Property="HorizontalContentAlignment" Value="Left"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    CornerRadius="6" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}"
                                VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#313244"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#45475A"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- Kucuk buton (header) -->
    <Style x:Key="SmallBtnStyle" TargetType="Button">
      <Setter Property="Background" Value="#313244"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Foreground" Value="#6C7086"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="Padding" Value="10,4"/>
      <Setter Property="FontSize" Value="11"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Border x:Name="bd" Background="{TemplateBinding Background}"
                    CornerRadius="4" Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="bd" Property="Background" Value="#45475A"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
  </Window.Resources>

  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="56"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="165"/>
    </Grid.RowDefinitions>

    <!-- ===== HEADER ===== -->
    <Border Grid.Row="0" Background="#181825">
      <Grid Margin="18,0">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>

        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
          <TextBlock Text="SISTEM BAKIM" FontSize="17" FontWeight="Bold"
                     Foreground="#CDD6F4" VerticalAlignment="Center"/>
          <TextBlock Text="  v5.0" FontSize="13" Foreground="#89B4FA"
                     VerticalAlignment="Center" Margin="0,1,0,0"/>
          <Border Background="#1E3A5F" CornerRadius="4" Margin="14,0,0,0" Padding="8,3">
            <TextBlock x:Name="TxtYetki" Text="Yonetici [AKTIF]"
                       FontSize="11" Foreground="#89B4FA"/>
          </Border>
        </StackPanel>

        <!-- Status cipleri -->
        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
          <Border Background="#1A2E1A" CornerRadius="4" Margin="0,0,8,0" Padding="10,5">
            <StackPanel Orientation="Horizontal">
              <TextBlock Text="CPU  " Foreground="#45475A" FontSize="11" FontFamily="Consolas"/>
              <TextBlock x:Name="TxtCPU" Text="--%"
                         Foreground="#A6E3A1" FontSize="11" FontFamily="Consolas" FontWeight="Bold"/>
            </StackPanel>
          </Border>
          <Border Background="#1A1A2E" CornerRadius="4" Margin="0,0,8,0" Padding="10,5">
            <StackPanel Orientation="Horizontal">
              <TextBlock Text="RAM  " Foreground="#45475A" FontSize="11" FontFamily="Consolas"/>
              <TextBlock x:Name="TxtRAM" Text="--%"
                         Foreground="#89B4FA" FontSize="11" FontFamily="Consolas" FontWeight="Bold"/>
            </StackPanel>
          </Border>
          <Border Background="#2A1A0A" CornerRadius="4" Padding="10,5">
            <StackPanel Orientation="Horizontal">
              <TextBlock Text="SKOR  " Foreground="#45475A" FontSize="11" FontFamily="Consolas"/>
              <TextBlock x:Name="TxtSkor" Text="--"
                         Foreground="#F9E2AF" FontSize="11" FontFamily="Consolas" FontWeight="Bold"/>
            </StackPanel>
          </Border>
        </StackPanel>
      </Grid>
    </Border>

    <!-- ===== MAIN AREA ===== -->
    <Grid Grid.Row="1">
      <Grid.ColumnDefinitions>
        <ColumnDefinition Width="150"/>
        <ColumnDefinition Width="*"/>
      </Grid.ColumnDefinitions>

      <!-- SIDEBAR -->
      <Border Grid.Column="0" Background="#181825">
        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
          <StackPanel x:Name="Sidebar" Margin="8,14,8,14"/>
        </ScrollViewer>
      </Border>

      <!-- TILES -->
      <ScrollViewer x:Name="TileScroll" Grid.Column="1" VerticalScrollBarVisibility="Auto"
                    HorizontalScrollBarVisibility="Disabled" Background="#1E1E2E">
        <WrapPanel x:Name="TilePanel" Margin="12,12,0,12" Orientation="Horizontal"/>
      </ScrollViewer>
    </Grid>

    <!-- ===== OUTPUT PANEL ===== -->
    <Border Grid.Row="2" Background="#11111B">
      <Grid>
        <Grid.RowDefinitions>
          <RowDefinition Height="30"/>
          <RowDefinition Height="*"/>
        </Grid.RowDefinitions>

        <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="14,0,14,0"
                    VerticalAlignment="Center">
          <TextBlock Text="CIKTI" Foreground="#45475A" FontSize="10"
                     FontWeight="Bold" FontFamily="Consolas" VerticalAlignment="Center"/>
          <Border Background="#1E1E2E" CornerRadius="3" Margin="10,0,0,0">
            <Button x:Name="BtnTemizle" Content="Temizle"
                    Style="{StaticResource SmallBtnStyle}" Height="20"/>
          </Border>
          <TextBlock x:Name="TxtDurum" Text="" Foreground="#6C7086"
                     FontSize="11" FontFamily="Consolas" Margin="14,0,0,0"
                     VerticalAlignment="Center"/>
        </StackPanel>

        <TextBox x:Name="TxtCikti" Grid.Row="1"
                 Background="Transparent" Foreground="#CDD6F4"
                 FontFamily="Consolas" FontSize="12"
                 IsReadOnly="True" BorderThickness="0"
                 VerticalScrollBarVisibility="Auto"
                 HorizontalScrollBarVisibility="Disabled"
                 TextWrapping="Wrap"
                 Margin="14,0,14,10"/>
      </Grid>
    </Border>
  </Grid>
</Window>
'@

# ── WINDOW OLUSTUR ───────────────────────────────────────────
$reader = New-Object System.Xml.XmlNodeReader $xaml
try {
    $window = [Windows.Markup.XamlReader]::Load($reader)
} catch {
    [System.Windows.MessageBox]::Show("WPF penceresi acilamadi:`n" + $_.Exception.Message, "Hata")
    exit
}

# Kontrolleri al
$TxtCPU     = $window.FindName("TxtCPU")
$TxtRAM     = $window.FindName("TxtRAM")
$TxtSkor    = $window.FindName("TxtSkor")
$TxtCikti   = $window.FindName("TxtCikti")
$TxtDurum   = $window.FindName("TxtDurum")
$BtnTemizle = $window.FindName("BtnTemizle")
$Sidebar    = $window.FindName("Sidebar")
$TilePanel  = $window.FindName("TilePanel")
$TileScroll = $window.FindName("TileScroll")

# ── YARDIMCI FONKSIYONLAR ─────────────────────────────────────
function CiktiEkle($metin) {
    $zaman = Get-Date -Format "HH:mm:ss"
    $TxtCikti.AppendText("[" + $zaman + "]  " + $metin + "`n")
    $TxtCikti.ScrollToEnd()
}

function Chip($metin, $renk) {
    $b = New-Object System.Windows.Controls.Border
    $b.Background   = $renk
    $b.CornerRadius  = "4"
    $b.Padding       = "8,3"
    $b.Margin        = "0,0,6,0"
    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text         = $metin
    $tb.FontSize     = 11
    $tb.Foreground   = "#1E1E2E"
    $tb.FontWeight   = "Bold"
    $b.Child         = $tb
    return $b
}

# ── TILE OLUSTURUCU ───────────────────────────────────────────
function TileOlustur($no, $mod) {
    $btn = New-Object System.Windows.Controls.Button
    $btn.Style = $window.Resources["TileStyle"]
    $btn.Tag   = $no

    # Sol renk cubugu + icerik
    $satırGrid = New-Object System.Windows.Controls.Grid
    $kolon1 = New-Object System.Windows.Controls.ColumnDefinition
    $kolon1.Width = "4"
    $kolon2 = New-Object System.Windows.Controls.ColumnDefinition
    $kolon2.Width = "*"
    $satırGrid.ColumnDefinitions.Add($kolon1)
    $satırGrid.ColumnDefinitions.Add($kolon2)

    # Sol renk serit
    $serit = New-Object System.Windows.Controls.Border
    $serit.Background   = $mod.Renk
    $serit.CornerRadius  = "2"
    $serit.Margin        = "0,4,8,4"
    [System.Windows.Controls.Grid]::SetColumn($serit, 0)
    $satırGrid.Children.Add($serit) | Out-Null

    # Icerik
    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Orientation = "Vertical"
    [System.Windows.Controls.Grid]::SetColumn($sp, 1)

    $tbAd = New-Object System.Windows.Controls.TextBlock
    $tbAd.Text       = $mod.Ad
    $tbAd.FontSize   = 12
    $tbAd.FontWeight = "SemiBold"
    $tbAd.Foreground = $mod.Renk

    $tbAcik = New-Object System.Windows.Controls.TextBlock
    $tbAcik.Text        = $mod.Aciklama
    $tbAcik.FontSize    = 10
    $tbAcik.Foreground  = "#6C7086"
    $tbAcik.TextWrapping = "Wrap"
    $tbAcik.Margin      = "0,3,0,0"

    $tbNo = New-Object System.Windows.Controls.TextBlock
    $tbNo.Text       = "#" + $no
    $tbNo.FontSize   = 9
    $tbNo.Foreground = "#45475A"
    $tbNo.FontFamily = "Consolas"
    $tbNo.Margin     = "0,4,0,0"

    $sp.Children.Add($tbAd)   | Out-Null
    $sp.Children.Add($tbAcik) | Out-Null
    $sp.Children.Add($tbNo)   | Out-Null
    $satırGrid.Children.Add($sp) | Out-Null
    $btn.Content = $satırGrid

    # Click: modulu yeni konsolda calistir
    $funcName    = $mod.Func
    $backendYolu = $BACKEND
    $modAdi      = $mod.Ad

    $btn.Add_Click({
        $f    = $funcName
        $b    = $backendYolu
        $ad   = $modAdi

        $scriptContent = ". `"$b`"; Clear-Host; $f; Write-Host ''; Write-Host '  [Bitmek icin Enter]' -ForegroundColor DarkGray; Read-Host | Out-Null"
        $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($scriptContent))

        try {
            Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded" -Verb RunAs -ErrorAction Stop
            CiktiEkle ("Acildi: " + $ad + "  (#" + $f + ")")
            $TxtDurum.Text = "Son: " + $ad
        } catch {
            CiktiEkle ("HATA: " + $ad + " acilamadi -- " + $_.Exception.Message)
        }
    }.GetNewClosure())

    return $btn
}

# ── SIDEBAR BUTONU ────────────────────────────────────────────
$aktifKatRenk = "#313244"

function SidebarBtnOlustur($ad, $renk, $modüller) {
    $btn = New-Object System.Windows.Controls.Button
    $btn.Style = $window.Resources["SidebarStyle"]

    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.Orientation = "Horizontal"

    $nokta = New-Object System.Windows.Controls.Border
    $nokta.Width            = 8
    $nokta.Height           = 8
    $nokta.CornerRadius     = "4"
    $nokta.Background       = $renk
    $nokta.Margin           = "0,0,8,0"
    $nokta.VerticalAlignment = "Center"

    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text             = $ad
    $tb.FontSize         = 12
    $tb.Foreground       = "#BAC2DE"
    $tb.VerticalAlignment = "Center"

    $sp.Children.Add($nokta) | Out-Null
    $sp.Children.Add($tb)   | Out-Null
    $btn.Content = $sp

    $filtre       = $modüller
    $modListesi   = $MODULLER

    $btn.Add_Click({
        $TilePanel.Children.Clear()
        if ($filtre -contains 0) {
            foreach ($n in $modListesi.Keys) {
                $TilePanel.Children.Add((TileOlustur $n $modListesi[$n])) | Out-Null
            }
        } else {
            foreach ($n in $filtre) {
                if ($modListesi.Contains($n)) {
                    $TilePanel.Children.Add((TileOlustur $n $modListesi[$n])) | Out-Null
                }
            }
        }
        CiktiEkle ("Kategori: " + $ad + "  (" + $TilePanel.Children.Count + " modul)")
    }.GetNewClosure())

    return $btn
}

# ── SIDEBAR'I DOLDUR ──────────────────────────────────────────
$Sidebar.Children.Add((Chip "KATEGORILER" "#45475A")) | Out-Null
$sepPad = New-Object System.Windows.Controls.Border
$sepPad.Height = 8
$Sidebar.Children.Add($sepPad) | Out-Null

foreach ($katAd in $KATEGORILER.Keys) {
    $kat   = $KATEGORILER[$katAd]
    $filtre = if ($katAd -eq "Tumu") { @(0) } else { $kat.Modüller }
    $sbBtn = SidebarBtnOlustur $katAd $kat.Renk $filtre
    $Sidebar.Children.Add($sbBtn) | Out-Null
}

# Ayirac
$sep2 = New-Object System.Windows.Controls.Separator
$sep2.Background = "#313244"
$sep2.Margin     = "8,10"
$Sidebar.Children.Add($sep2) | Out-Null

# Hizli erisim: TAM BAKIM
$tamBtn = New-Object System.Windows.Controls.Button
$tamBtn.Style = $window.Resources["SidebarStyle"]
$tamBtnSP = New-Object System.Windows.Controls.StackPanel
$tamBtnSP.Orientation = "Horizontal"
$tamNokta = New-Object System.Windows.Controls.Border
$tamNokta.Width = 8; $tamNokta.Height = 8
$tamNokta.CornerRadius = "4"
$tamNokta.Background = "#FAB387"
$tamNokta.Margin = "0,0,8,0"
$tamNokta.VerticalAlignment = "Center"
$tamTb = New-Object System.Windows.Controls.TextBlock
$tamTb.Text = "TAM BAKIM"; $tamTb.FontSize = 12; $tamTb.FontWeight = "Bold"
$tamTb.Foreground = "#FAB387"; $tamTb.VerticalAlignment = "Center"
$tamBtnSP.Children.Add($tamNokta) | Out-Null
$tamBtnSP.Children.Add($tamTb) | Out-Null
$tamBtn.Content = $tamBtnSP

$tamBtnBackend = $BACKEND
$tamBtn.Add_Click({
    $b = $tamBtnBackend
    $scriptContent = ". `"$b`"; Clear-Host; TamBakim; Write-Host ''; Read-Host | Out-Null"
    $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($scriptContent))
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded" -Verb RunAs -ErrorAction SilentlyContinue
    CiktiEkle "TAM BAKIM basladi (yeni pencere)"
}.GetNewClosure())
$Sidebar.Children.Add($tamBtn) | Out-Null

# ── BASLANGIC: TUM TILELER (Loaded eventinde, layout hesaplandiktan sonra) ──
$window.Add_Loaded({
    # WrapPanel genisligini ScrollViewer'a bagla
    $TilePanel.Width = $TileScroll.ViewportWidth - 24
    $TileScroll.Add_SizeChanged({
        $TilePanel.Width = $TileScroll.ViewportWidth - 24
    })
    # Tum tile'lari yukle
    foreach ($no in $MODULLER.Keys) {
        $TilePanel.Children.Add((TileOlustur $no $MODULLER[$no])) | Out-Null
    }
})

# ── BUTONLAR ─────────────────────────────────────────────────
$BtnTemizle.Add_Click({ $TxtCikti.Clear(); $TxtDurum.Text = "" })

# ── STATUS TIMER (3 sn) ───────────────────────────────────────
$statusTimer = New-Object System.Windows.Threading.DispatcherTimer
$statusTimer.Interval = [TimeSpan]::FromSeconds(3)
$statusTimer.Add_Tick({
    try {
        $cpuYuz = [int]((Get-CimInstance Win32_Processor -ErrorAction Stop |
                  Measure-Object -Property LoadPercentage -Average).Average)
        $os2    = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $ramYuz = [int](($os2.TotalVisibleMemorySize - $os2.FreePhysicalMemory) /
                        $os2.TotalVisibleMemorySize * 100)

        $TxtCPU.Text = $cpuYuz.ToString() + "%"
        $TxtRAM.Text = $ramYuz.ToString() + "%"

        $skor = 100
        if ($cpuYuz -ge 90) { $skor -= 25 } elseif ($cpuYuz -ge 70) { $skor -= 12 }
        if ($ramYuz -ge 90) { $skor -= 25 } elseif ($ramYuz -ge 75) { $skor -= 12 }
        $TxtSkor.Text = $skor.ToString() + "/100"

        $TxtCPU.Foreground  = if ($cpuYuz -gt 80) { "#F38BA8" } elseif ($cpuYuz -gt 50) { "#F9E2AF" } else { "#A6E3A1" }
        $TxtRAM.Foreground  = if ($ramYuz -gt 80) { "#F38BA8" } elseif ($ramYuz -gt 60) { "#F9E2AF" } else { "#89B4FA" }
        $TxtSkor.Foreground = if ($skor -ge 80) { "#A6E3A1" } elseif ($skor -ge 60) { "#F9E2AF" } else { "#F38BA8" }
    } catch {}
})
$statusTimer.Start()

# ── HAZIR MESAJI ─────────────────────────────────────────────
CiktiEkle ("Sistem Bakim Araci v5.0 hazir  --  53 modul yuklendi")
CiktiEkle ("Backend: " + $BACKEND)
CiktiEkle "Bir tile'a tikla -- modul yeni pencerede acilir."

# ── PENCEREYI GOSTER ─────────────────────────────────────────
$window.Add_Closed({ $statusTimer.Stop() })
$window.ShowDialog() | Out-Null
