# ================================================================
#   SistemBakim v5.0 -- Kapsamli Ozellik Testi
#   Her UI ozelligi tek tek test edilir, sonuc raporu cikarilir
# ================================================================

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$KLASOR  = "C:\Users\Erdi\Desktop\SistemBakim"
$BACKEND = Join-Path $KLASOR "SistemBakim_v5.ps1"
$LOGFILE = Join-Path $KLASOR "_FeatureTest_Results.txt"

# Test sonuc listesi
$script:SONUCLAR = @()
$script:TEST_NO = 0

function TestYaz($testAdi, $basarili, $detay) {
    $script:TEST_NO++
    $simge = if ($basarili) { "PASS" } else { "FAIL" }
    $satir = "[$simge]  TEST $($script:TEST_NO.ToString('00')): $testAdi"
    if ($detay) { $satir += "  -->  $detay" }
    $script:SONUCLAR += $satir
    $satir | Out-File $LOGFILE -Append -Encoding utf8
    Write-Host $satir
}

"=" * 60 | Out-File $LOGFILE -Encoding utf8
"  SistemBakim v5.0 Ozellik Test Raporu" | Out-File $LOGFILE -Append -Encoding utf8
"  Tarih: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File $LOGFILE -Append -Encoding utf8
"=" * 60 | Out-File $LOGFILE -Append -Encoding utf8
"" | Out-File $LOGFILE -Append -Encoding utf8

# ================================================================
# BOLUM 1: VERI YAPILARI
# ================================================================
"--- BOLUM 1: VERI YAPILARI ---" | Out-File $LOGFILE -Append -Encoding utf8

# GUI scriptini yukle (bootstrap haric)
$lines = Get-Content "$KLASOR\SistemBakim_GUI.ps1" -Encoding UTF8

# Satir 26-138 arasi: data tanimlari
$dataCode = ($lines[25..137]) -join "`r`n"
try {
    Invoke-Expression $dataCode
    TestYaz "Veri tanimlari yukleme" $true "Ikon, modul, kategori, favori, state"
} catch {
    TestYaz "Veri tanimlari yukleme" $false $_.Exception.Message
}

# TEST 02: $IKONLAR
try {
    $ikonSay = $IKONLAR.Count
    $bos = ($IKONLAR.Values | Where-Object { $_ -eq $null -or $_ -eq "" }).Count
    $ok = ($ikonSay -ge 10 -and $bos -eq 0)
    TestYaz "`$IKONLAR sozlugu" $ok "$ikonSay ikon, $bos bos"
} catch { TestYaz "`$IKONLAR sozlugu" $false $_.Exception.Message }

# TEST 03: $MODULLER
try {
    $modSay = $MODULLER.Count
    $eksikFunc = @()
    foreach ($no in $MODULLER.Keys) {
        $m = $MODULLER[$no]
        if (-not $m.Ad -or -not $m.Func -or -not $m.Renk) { $eksikFunc += $no }
    }
    $ok = ($modSay -eq 54 -and $eksikFunc.Count -eq 0)
    TestYaz "`$MODULLER sozlugu ($modSay modul)" $ok "Eksik alan: $($eksikFunc.Count)"
} catch { TestYaz "`$MODULLER sozlugu" $false $_.Exception.Message }

# TEST 04: Modul renk kodlari gecerli mi
try {
    $gecersizRenk = @()
    foreach ($no in $MODULLER.Keys) {
        if ($MODULLER[$no].Renk -notmatch '^#[0-9A-Fa-f]{6}$') { $gecersizRenk += $no }
    }
    TestYaz "Modul renk kodlari" ($gecersizRenk.Count -eq 0) "Gecersiz: $($gecersizRenk -join ',')"
} catch { TestYaz "Modul renk kodlari" $false $_.Exception.Message }

# TEST 05: $KATEGORILER
try {
    $katSay = $KATEGORILER.Count
    $toplamMod = 0
    $eksikMod = @()
    foreach ($kAd in $KATEGORILER.Keys) {
        $kat = $KATEGORILER[$kAd]
        $toplamMod += $kat.Moduller.Count
        foreach ($modNo in $kat.Moduller) {
            if (-not $MODULLER.Contains($modNo)) { $eksikMod += "$kAd/$modNo" }
        }
    }
    $ok = ($katSay -eq 7 -and $eksikMod.Count -eq 0)
    TestYaz "`$KATEGORILER ($katSay kategori, $toplamMod modul ref)" $ok "Eksik ref: $($eksikMod -join ',')"
} catch { TestYaz "`$KATEGORILER" $false $_.Exception.Message }

# TEST 06: Kategori-modul kapsami (54 modülün hepsi bir kategoride mi?)
try {
    $tumKatMod = @()
    foreach ($kAd in $KATEGORILER.Keys) { $tumKatMod += $KATEGORILER[$kAd].Moduller }
    $kapsanmayan = @()
    foreach ($no in $MODULLER.Keys) {
        if ($tumKatMod -notcontains $no) { $kapsanmayan += $no }
    }
    $cift = ($tumKatMod | Group-Object | Where-Object { $_.Count -gt 1 })
    TestYaz "Kategori kapsam analizi" ($kapsanmayan.Count -eq 0) "Kapsanmayan: $($kapsanmayan -join ','), Cift: $($cift.Count)"
} catch { TestYaz "Kategori kapsam analizi" $false $_.Exception.Message }

# TEST 07: IkonKat referanslari gecerli mi
try {
    $gecersizIkon = @()
    foreach ($no in $MODULLER.Keys) {
        $ik = $MODULLER[$no].IkonKat
        if ($ik -and -not $IKONLAR.ContainsKey($ik)) { $gecersizIkon += "#$no=$ik" }
    }
    TestYaz "IkonKat referanslari" ($gecersizIkon.Count -eq 0) "Gecersiz: $($gecersizIkon -join ',')"
} catch { TestYaz "IkonKat referanslari" $false $_.Exception.Message }

# ================================================================
# BOLUM 2: XAML / WPF
# ================================================================
"" | Out-File $LOGFILE -Append -Encoding utf8
"--- BOLUM 2: XAML / WPF ---" | Out-File $LOGFILE -Append -Encoding utf8

# TEST 08: XAML XML parse
$xamlLines = $lines[140..617]
$xamlStr = $xamlLines -join "`r`n"
$xamlOK = $false
try {
    [xml]$xamlDoc = $xamlStr
    $xamlOK = $true
    TestYaz "XAML XML parse" $true "Root: $($xamlDoc.DocumentElement.LocalName)"
} catch {
    TestYaz "XAML XML parse" $false $_.Exception.Message
}

# TEST 09: WPF XamlReader
$window = $null
if ($xamlOK) {
    try {
        $reader = New-Object System.Xml.XmlNodeReader $xamlDoc
        $window = [Windows.Markup.XamlReader]::Load($reader)
        TestYaz "WPF XamlReader.Load" $true "Window: $($window.Title)"
    } catch {
        TestYaz "WPF XamlReader.Load" $false $_.Exception.Message
    }
}

# TEST 10: Tum named kontroller (36 kontrol)
if ($window) {
    $kontroller = @(
        "DashboardView","CategoryView","HealthCanvas",
        "TxtSkor","TxtSkorLabel","TxtCPU","TxtRAM","TxtDisk",
        "CpuBar","RamBar","DiskBar","TxtOS",
        "BtnSmartScan","SmartScanIkon","QuickPanel","NavPanel",
        "TxtKatBaslik","TxtKatAciklama","TxtKatIkon","KatIkonBorder","TxtModSay",
        "TxtArama","TxtAramaYer","ModulPanel","ModulScroll",
        "ActivityPanel","TxtCikti","BtnLogToggle","BtnLogTemizle","BtnLogKapat",
        "BtnDurdur","TxtDurum","PnlDurum","PnlDurumIndicator",
        "TxtIslemAdi","TxtIslemSure"
    )
    $bulunan = 0; $eksik = @()
    foreach ($name in $kontroller) {
        if ($window.FindName($name)) { $bulunan++ } else { $eksik += $name }
    }
    $ok = ($eksik.Count -eq 0)
    TestYaz "Named kontrol referanslari ($bulunan/$($kontroller.Count))" $ok "Eksik: $($eksik -join ',')"
}

# TEST 11: XAML Style referanslari
if ($window) {
    $stiller = @("NavBtnStyle","CardStyle","CTAStyle","ModernProgress","SearchStyle","SmallBtnStyle")
    $bulunanS = 0; $eksikS = @()
    foreach ($s in $stiller) {
        if ($window.Resources[$s]) { $bulunanS++ } else { $eksikS += $s }
    }
    TestYaz "XAML Style tanimlari ($bulunanS/$($stiller.Count))" ($eksikS.Count -eq 0) "Eksik: $($eksikS -join ',')"
}

# ================================================================
# BOLUM 3: FONKSIYONLAR
# ================================================================
"" | Out-File $LOGFILE -Append -Encoding utf8
"--- BOLUM 3: FONKSIYONLAR ---" | Out-File $LOGFILE -Append -Encoding utf8

if ($window) {
    # Fonksiyonlari yukle (satir 668 sonrası)
    # Kontrol referanslarini al
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
    $TxtDurum        = $window.FindName("TxtDurum")
    $PnlDurum        = $window.FindName("PnlDurum")
    $PnlDurumIndicator = $window.FindName("PnlDurumIndicator")
    $TxtIslemAdi     = $window.FindName("TxtIslemAdi")
    $TxtIslemSure    = $window.FindName("TxtIslemSure")

    # Fonksiyon tanimlari
    $funcCode = ($lines[667..($lines.Count-2)]) -join "`r`n"

    # ShowDialog haric calıstır (son satiri cikar)
    $funcCode = $funcCode -replace '\$window\.ShowDialog\(\)\s*\|\s*Out-Null', ''
    $funcCode = $funcCode -replace '\$window\.Add_Closed\(\{[\s\S]*?\}\)', ''
    $funcCode = $funcCode -replace '\$statusTimer\.Start\(\)', ''

    try {
        Invoke-Expression $funcCode
        TestYaz "Fonksiyon tanimlari yukleme" $true ""
    } catch {
        TestYaz "Fonksiyon tanimlari yukleme" $false "$($_.Exception.Message) AT LINE $($_.InvocationInfo.ScriptLineNumber)"
    }

    # TEST 13: CiktiEkle fonksiyonu
    try {
        CiktiEkle "Test mesaji 123"
        $icerik = $TxtCikti.Text
        $ok = $icerik.Contains("Test mesaji 123")
        TestYaz "CiktiEkle (log yazma)" $ok "Icerik: $($icerik.Length) char"
    } catch { TestYaz "CiktiEkle (log yazma)" $false $_.Exception.Message }

    # TEST 14: LogPanelAc / LogPanelKapat
    try {
        LogPanelAc
        $acik = ($ActivityPanel.Visibility -eq "Visible")
        LogPanelKapat
        $kapali = ($ActivityPanel.Visibility -eq "Collapsed")
        TestYaz "Log panel toggle (Ac/Kapat)" ($acik -and $kapali) "Ac=$acik, Kapat=$kapali"
    } catch { TestYaz "Log panel toggle" $false $_.Exception.Message }

    # TEST 15: DrawHealthRing - 0 puan
    try {
        DrawHealthRing 0
        $childSay = $HealthCanvas.Children.Count
        TestYaz "DrawHealthRing(0) - sifir puan" ($childSay -ge 1) "Canvas child: $childSay"
    } catch { TestYaz "DrawHealthRing(0)" $false $_.Exception.Message }

    # TEST 16: DrawHealthRing - 50 puan (orta, sari renk)
    try {
        DrawHealthRing 50
        $childSay = $HealthCanvas.Children.Count
        $skorTxt = $TxtSkor.Text
        $ok = ($childSay -ge 2 -and $skorTxt -eq "50")
        TestYaz "DrawHealthRing(50) - orta puan" $ok "Canvas: $childSay child, Skor: $skorTxt"
    } catch { TestYaz "DrawHealthRing(50)" $false $_.Exception.Message }

    # TEST 17: DrawHealthRing - 85 puan (yuksek, yesil renk)
    try {
        DrawHealthRing 85
        $childSay = $HealthCanvas.Children.Count
        $skorTxt = $TxtSkor.Text
        $renkStr = $TxtSkor.Foreground.ToString()
        $ok = ($childSay -ge 2 -and $skorTxt -eq "85")
        TestYaz "DrawHealthRing(85) - yuksek puan" $ok "Skor: $skorTxt, Renk: $renkStr"
    } catch { TestYaz "DrawHealthRing(85)" $false $_.Exception.Message }

    # TEST 18: DrawHealthRing - 30 puan (dusuk, kirmizi renk)
    try {
        DrawHealthRing 30
        $skorTxt = $TxtSkor.Text
        $renkStr = $TxtSkor.Foreground.ToString()
        $ok = ($skorTxt -eq "30" -and $renkStr -like "*F87171*")
        TestYaz "DrawHealthRing(30) - dusuk puan (kirmizi)" $ok "Skor: $skorTxt, Renk: $renkStr"
    } catch { TestYaz "DrawHealthRing(30)" $false $_.Exception.Message }

    # TEST 19: NavBtnOlustur
    try {
        $testNav = NavBtnOlustur ([string][char]0xE713) "#34D399" "TestNav"
        $hasContainer = ($testNav.Container -ne $null)
        $hasButton    = ($testNav.Button -ne $null)
        $hasIndicator = ($testNav.Indicator -ne $null)
        $hasIcon      = ($testNav.Icon -ne $null)
        $ok = $hasContainer -and $hasButton -and $hasIndicator -and $hasIcon
        TestYaz "NavBtnOlustur (sidebar buton)" $ok "Container=$hasContainer, Btn=$hasButton, Ind=$hasIndicator, Icon=$hasIcon"
    } catch { TestYaz "NavBtnOlustur" $false $_.Exception.Message }

    # TEST 20: Sidebar dolu mu (NavPanel children)
    try {
        $navSay = $NavPanel.Children.Count
        # En az: 1 home + 1 sep + 7 kategori + 1 sep + 1 fav + 1 tumu = 12
        $ok = ($navSay -ge 12)
        TestYaz "Sidebar navigasyon ($navSay eleman)" $ok "Beklenen min: 12"
    } catch { TestYaz "Sidebar navigasyon" $false $_.Exception.Message }

    # TEST 21: NAV_LISTESI boyutu
    try {
        $navListeSay = $script:NAV_LISTESI.Count
        # Home + 7 kategori + favoriler + tum araclar = 10
        $ok = ($navListeSay -ge 10)
        TestYaz "NAV_LISTESI ($navListeSay buton)" $ok "Beklenen: 10"
    } catch { TestYaz "NAV_LISTESI" $false $_.Exception.Message }

    # TEST 22: KartOlustur
    try {
        $testMod = $MODULLER["3"]
        $kart = KartOlustur "3" $testMod
        $ok = ($kart -ne $null -and $kart.GetType().Name -eq "Button")
        $tag = $kart.Tag
        TestYaz "KartOlustur (modul kart)" $ok "Tip: $($kart.GetType().Name), Tag: $tag"
    } catch { TestYaz "KartOlustur" $false $_.Exception.Message }

    # TEST 23: HizliKartOlustur
    try {
        $hkart = HizliKartOlustur "9" $MODULLER["9"]
        $ok = ($hkart -ne $null -and $hkart.Width -eq 180 -and $hkart.Height -eq 72)
        TestYaz "HizliKartOlustur (quick access)" $ok "Size: $($hkart.Width)x$($hkart.Height)"
    } catch { TestYaz "HizliKartOlustur" $false $_.Exception.Message }

    # TEST 24: SayfaGoster - Dashboard
    try {
        SayfaGoster "Dashboard"
        $dashVis = $DashboardView.Visibility.ToString()
        $catVis  = $CategoryView.Visibility.ToString()
        $ok = ($dashVis -eq "Visible" -and $catVis -eq "Collapsed")
        TestYaz "SayfaGoster('Dashboard')" $ok "Dash=$dashVis, Cat=$catVis"
    } catch { TestYaz "SayfaGoster('Dashboard')" $false $_.Exception.Message }

    # TEST 25: SayfaGoster - Kategori (Temizlik)
    try {
        $temizMod = $KATEGORILER["Temizlik"].Moduller
        SayfaGoster "Kategori" "Temizlik" $temizMod
        $dashVis = $DashboardView.Visibility.ToString()
        $catVis  = $CategoryView.Visibility.ToString()
        $kartSay = $ModulPanel.Children.Count
        $baslik  = $TxtKatBaslik.Text
        $ok = ($catVis -eq "Visible" -and $kartSay -eq $temizMod.Count -and $baslik -eq "Temizlik")
        TestYaz "SayfaGoster Temizlik ($kartSay kart)" $ok "Baslik=$baslik, Beklenen=$($temizMod.Count)"
    } catch { TestYaz "SayfaGoster Temizlik" $false $_.Exception.Message }

    # TEST 26: Her kategori icin kart sayisi dogrulama
    $katHata = @()
    foreach ($katAd in $KATEGORILER.Keys) {
        try {
            $kat = $KATEGORILER[$katAd]
            SayfaGoster "Kategori" $katAd $kat.Moduller
            $kartSay = $ModulPanel.Children.Count
            if ($kartSay -ne $kat.Moduller.Count) {
                $katHata += "$katAd(beklenen:$($kat.Moduller.Count),gelen:$kartSay)"
            }
        } catch { $katHata += "$katAd(HATA:$($_.Exception.Message))" }
    }
    TestYaz "7 kategori kart sayisi eslestirme" ($katHata.Count -eq 0) "$($katHata -join ', ')"

    # TEST 27: SayfaGoster - Tum Araclar
    try {
        SayfaGoster "Kategori" "Tum Araclar" @()
        $kartSay = $ModulPanel.Children.Count
        $baslik  = $TxtKatBaslik.Text
        $ok = ($kartSay -eq 54 -and $baslik -eq "Tum Araclar")
        TestYaz "SayfaGoster 'Tum Araclar' ($kartSay kart)" $ok "Beklenen: 54"
    } catch { TestYaz "SayfaGoster Tum Araclar" $false $_.Exception.Message }

    # TEST 28: SayfaGoster - Favoriler (bos)
    try {
        $script:FAVORILER = @()
        SayfaGoster "Kategori" "Favoriler" @()
        $kartSay = $ModulPanel.Children.Count
        TestYaz "SayfaGoster 'Favoriler' (bos liste)" ($kartSay -eq 0) "Kart: $kartSay"
    } catch { TestYaz "SayfaGoster Favoriler" $false $_.Exception.Message }

    # TEST 29: Favori ekleme/cikarma
    try {
        $script:FAVORILER = @()
        $script:FAVORILER = @($script:FAVORILER) + @("3")
        $fm1 = FavoriMi "3"
        $fm2 = FavoriMi "9"
        $script:FAVORILER = @($script:FAVORILER) + @("9")
        $fm3 = FavoriMi "9"
        $script:FAVORILER = @($script:FAVORILER | Where-Object { $_ -ne "3" })
        $fm4 = FavoriMi "3"
        $ok = ($fm1 -and -not $fm2 -and $fm3 -and -not $fm4)
        TestYaz "Favori ekle/cikar mantigi" $ok "Ekle3=$fm1, 9yok=$($fm2), Ekle9=$fm3, Cikar3=$($fm4)"
    } catch { TestYaz "Favori ekle/cikar" $false $_.Exception.Message }

    # TEST 30: Favorilerle SayfaGoster
    try {
        $script:FAVORILER = @("3","9","26")
        SayfaGoster "Kategori" "Favoriler" @()
        $kartSay = $ModulPanel.Children.Count
        TestYaz "Favoriler gorunumu (3 favori)" ($kartSay -eq 3) "Kart: $kartSay"
    } catch { TestYaz "Favoriler gorunumu" $false $_.Exception.Message }

    # TEST 31: Arama/Filtre - "Disk" aramasi
    try {
        SayfaGoster "Kategori" "Tum Araclar" @()
        ModulFiltele "Disk"
        $kartSay = $ModulPanel.Children.Count
        # "Disk" geçen modüller: Disk Analizi, SMART Disk, Disk Optimize, + Disk kelimesi olanlar
        $ok = ($kartSay -gt 0 -and $kartSay -lt 54)
        TestYaz "Arama filtreleme 'Disk'" $ok "Sonuc: $kartSay kart (toplam 54'ten az olmali)"
    } catch { TestYaz "Arama filtreleme" $false $_.Exception.Message }

    # TEST 32: Arama - bos string (tum kartlar donmeli)
    try {
        SayfaGoster "Kategori" "Tum Araclar" @()
        ModulFiltele ""
        $kartSay = $ModulPanel.Children.Count
        TestYaz "Arama bos string (tumu gormeli)" ($kartSay -eq 54) "Kart: $kartSay"
    } catch { TestYaz "Arama bos string" $false $_.Exception.Message }

    # TEST 33: Arama - olmayan kelime
    try {
        SayfaGoster "Kategori" "Tum Araclar" @()
        ModulFiltele "xyzasdfqwerty"
        $kartSay = $ModulPanel.Children.Count
        TestYaz "Arama olmayan kelime (0 sonuc)" ($kartSay -eq 0) "Kart: $kartSay"
    } catch { TestYaz "Arama olmayan kelime" $false $_.Exception.Message }

    # TEST 34: Arama - kategori icinde filtreleme
    try {
        $oyunMod = $KATEGORILER["Oyun"].Moduller
        SayfaGoster "Kategori" "Oyun" $oyunMod
        $onceki = $ModulPanel.Children.Count
        ModulFiltele "FPS"
        $sonraki = $ModulPanel.Children.Count
        $ok = ($sonraki -gt 0 -and $sonraki -lt $onceki)
        TestYaz "Kategori icinde arama (Oyun>'FPS')" $ok "Once: $onceki, Sonra: $sonraki"
    } catch { TestYaz "Kategori icinde arama" $false $_.Exception.Message }

    # TEST 35: NavAktifYap
    try {
        $ilkNav = $script:NAV_LISTESI[0]
        NavAktifYap $ilkNav
        $renkStr = $ilkNav.Indicator.Background.ToString()
        $ikonRenk = $ilkNav.Icon.Foreground.ToString()
        # Diger butonlarin deaktif olmasi
        $ikinciNav = $script:NAV_LISTESI[1]
        $deaktifRenk = $ikinciNav.Indicator.Background.ToString()
        $ok = ($renkStr -ne "Transparent" -and $deaktifRenk -eq "Transparent")
        TestYaz "NavAktifYap (sidebar highlight)" $ok "Aktif renk: $renkStr, Deaktif: $deaktifRenk"
    } catch { TestYaz "NavAktifYap" $false $_.Exception.Message }

    # TEST 36: HizliPaneliYenile - varsayilan
    try {
        $script:FAVORILER = @()
        HizliPaneliYenile
        $say = $QuickPanel.Children.Count
        TestYaz "HizliPanel varsayilan ($say kart)" ($say -eq 6) "Beklenen: 6 (HIZLI_ERISIM)"
    } catch { TestYaz "HizliPanel varsayilan" $false $_.Exception.Message }

    # TEST 37: HizliPaneliYenile - favorilerle
    try {
        $script:FAVORILER = @("1","2","3")
        HizliPaneliYenile
        $say = $QuickPanel.Children.Count
        TestYaz "HizliPanel favorilerle ($say kart)" ($say -eq 3) "Beklenen: 3"
        $script:FAVORILER = @()
    } catch { TestYaz "HizliPanel favorilerle" $false $_.Exception.Message }

    # TEST 38: BtnLogToggle iconu
    try {
        $logIkon = $BtnLogToggle.Content
        $ok = ($logIkon -ne $null -and $logIkon.FontFamily.Source -eq "Segoe MDL2 Assets")
        TestYaz "BtnLogToggle ikon ayari" $ok "Font: $($logIkon.FontFamily.Source)"
    } catch { TestYaz "BtnLogToggle ikon" $false $_.Exception.Message }

    # TEST 39: SmartScanIkon
    try {
        $ssIkon = $SmartScanIkon.Text
        $ok = ($ssIkon -ne $null -and $ssIkon -ne "")
        TestYaz "SmartScan ikon atama" $ok "Ikon: [char]$([int][char]$ssIkon)"
    } catch { TestYaz "SmartScan ikon" $false $_.Exception.Message }

    # TEST 40: Pencere boyut ozellikleri
    try {
        $ok = ($window.MinWidth -eq 950 -and $window.MinHeight -eq 650 -and $window.Width -eq 1220 -and $window.Height -eq 850)
        TestYaz "Pencere boyut ozellikleri" $ok "Min=$($window.MinWidth)x$($window.MinHeight), Default=$($window.Width)x$($window.Height)"
    } catch { TestYaz "Pencere boyut" $false $_.Exception.Message }

    # TEST 41: Arka plan rengi
    try {
        $bg = $window.Background.ToString()
        $ok = ($bg -eq "#FF0B0E14")
        TestYaz "Pencere arka plan (#0B0E14)" $ok "Gelen: $bg"
    } catch { TestYaz "Pencere arka plan" $false $_.Exception.Message }

    # TEST 42: ActivityPanel varsayilan durumu (Collapsed)
    try {
        $vis = $ActivityPanel.Visibility.ToString()
        TestYaz "ActivityPanel varsayilan (Collapsed)" ($vis -eq "Collapsed") "Durum: $vis"
    } catch { TestYaz "ActivityPanel varsayilan" $false $_.Exception.Message }

    # TEST 43: BtnDurdur varsayilan (Collapsed)
    try {
        $vis = $BtnDurdur.Visibility.ToString()
        TestYaz "BtnDurdur varsayilan (Collapsed)" ($vis -eq "Collapsed") "Durum: $vis"
    } catch { TestYaz "BtnDurdur varsayilan" $false $_.Exception.Message }

    # TEST 44: TxtModSay guncellenmesi
    try {
        SayfaGoster "Kategori" "Tum Araclar" @()
        $modSayTxt = $TxtModSay.Text
        TestYaz "TxtModSay guncelleme" ($modSayTxt -eq "54 arac") "Metin: '$modSayTxt'"
    } catch { TestYaz "TxtModSay" $false $_.Exception.Message }

    # TEST 45: KategoriGoster ikon ve renk ayari
    try {
        $agMod = $KATEGORILER["Ag"].Moduller
        SayfaGoster "Kategori" "Ag" $agMod
        $baslik = $TxtKatBaslik.Text
        $acik   = $TxtKatAciklama.Text
        $bgRenk = $KatIkonBorder.Background.ToString()
        $ok = ($baslik -eq "Ag" -and $acik -ne "" -and $bgRenk -like "*38BDF8*")
        TestYaz "Kategori header (ikon, baslik, renk)" $ok "Baslik=$baslik, Renk=$bgRenk"
    } catch { TestYaz "Kategori header" $false $_.Exception.Message }

    # Pencereyi kapat
    $window.Close()
}

# ================================================================
# BOLUM 4: BUILD-EXE UYUMLULUK
# ================================================================
"" | Out-File $LOGFILE -Append -Encoding utf8
"--- BOLUM 4: BUILD-EXE UYUMLULUK ---" | Out-File $LOGFILE -Append -Encoding utf8

# TEST 46: $KLASOR regex match
try {
    $gui = Get-Content "$KLASOR\SistemBakim_GUI.ps1" -Raw
    $ok = ($gui -match '^\s*\$KLASOR\s*=')
    TestYaz "Build-EXE: `$KLASOR regex eslesmesi" $ok ""
} catch { TestYaz "Build-EXE: `$KLASOR" $false $_.Exception.Message }

# TEST 47: $BACKEND regex match
try {
    $ok = ($gui -match '^\s*\$BACKEND\s*=')
    TestYaz "Build-EXE: `$BACKEND regex eslesmesi" $ok ""
} catch { TestYaz "Build-EXE: `$BACKEND" $false $_.Exception.Message }

# TEST 48: STA thread check
try {
    $ok = ($gui -match 'ApartmentState.*STA')
    TestYaz "Build-EXE: STA thread kontrolu" $ok ""
} catch { TestYaz "Build-EXE: STA" $false $_.Exception.Message }

# TEST 49: Admin elevation
try {
    $ok = ($gui -match 'IsInRole.*Administrator')
    TestYaz "Build-EXE: Admin elevation" $ok ""
} catch { TestYaz "Build-EXE: Admin" $false $_.Exception.Message }

# TEST 50: UTF-8 BOM
try {
    $bytes = [System.IO.File]::ReadAllBytes("$KLASOR\SistemBakim_GUI.ps1")
    $bom = ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    TestYaz "UTF-8 BOM encoding" $bom ""
} catch { TestYaz "UTF-8 BOM" $false $_.Exception.Message }

# ================================================================
# OZET
# ================================================================
"" | Out-File $LOGFILE -Append -Encoding utf8
"=" * 60 | Out-File $LOGFILE -Append -Encoding utf8
$gecen = ($script:SONUCLAR | Where-Object { $_ -like "*[PASS]*" }).Count
$kalan = ($script:SONUCLAR | Where-Object { $_ -like "*[FAIL]*" }).Count
$toplam = $script:SONUCLAR.Count
$ozet = "SONUC: $gecen PASS / $kalan FAIL / $toplam TOPLAM"
$ozet | Out-File $LOGFILE -Append -Encoding utf8
"=" * 60 | Out-File $LOGFILE -Append -Encoding utf8
Write-Host ""
Write-Host $ozet
Write-Host ""
if ($kalan -gt 0) {
    Write-Host "BASARISIZ TESTLER:"
    $script:SONUCLAR | Where-Object { $_ -like "*[FAIL]*" } | ForEach-Object { Write-Host "  $_" }
}
