<div align="center">

<img src="src/sistem_64.png" width="80" alt="SistemBakim Logo"/>

# SistemBakim v5.0

### The Ultimate Windows Maintenance Toolkit

**69 Modules** · **WPF Dark UI** · **Zero Dependencies** · **Single EXE**

[![Release](https://img.shields.io/badge/release-v5.0-7C5CFC?style=for-the-badge)](https://github.com/erdiyim/SistemBakim/releases)
[![Downloads](https://img.shields.io/github/downloads/erdiyim/SistemBakim/total?style=for-the-badge&color=7C5CFC&label=Downloads)](https://github.com/erdiyim/SistemBakim/releases)
[![Stars](https://img.shields.io/github/stars/erdiyim/SistemBakim?style=for-the-badge&color=34D399)](https://github.com/erdiyim/SistemBakim)
[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?style=for-the-badge&logo=windows)](https://microsoft.com)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://docs.microsoft.com/powershell)
[![License](https://img.shields.io/badge/license-Personal%20Use-34D399?style=for-the-badge)](LICENSE)

[**Download Setup**](https://github.com/erdiyim/SistemBakim/releases/latest) · [Turkce](#-turkce) · [Features](#-features) · [Install](#-installation) · [Architecture](#-architecture)

---

*One toolkit. 69 modules. Zero bloat. Your PC, fully optimized.*

</div>

## Why SistemBakim?

Most system optimizers are either bloated subscription traps or shallow registry cleaners that do more harm than good. SistemBakim is different:

- **Actually works** — every module performs real operations with real results, verified through stress testing
- **Cannot break your system** — 21 critical services are hardcoded as protected, registry operations create `.reg` backups, context menu changes use safe rename instead of deletion
- **No internet required** — single portable EXE, zero cloud dependencies, zero telemetry
- **Fully reversible** — every optimization can be undone with one click

---

## Features

### Cleaning & Disk

| Module | What it does |
|--------|-------------|
| Deep Clean (19 locations) | Temp, Prefetch, browser caches, shader caches, app caches — with locked-file skip reporting |
| Registry Cleaner | Scans broken Uninstall entries, invalid SharedDLLs, dead COM/ActiveX refs, orphaned App Paths. Creates `.reg` backup before any deletion |
| Browser Cleaner | Chrome, Edge, Firefox, Opera, Brave — cache, history, cookies |
| WinSxS Cleanup | Standard and deep DISM component store cleanup with live progress output |
| Disk Treemap | Visual block map of your drive — WinDirStat-style, built into the app |
| Empty Folder Finder | Recursive scan across all drives with bulk delete |

### Performance & Gaming

| Module | What it does |
|--------|-------------|
| FPS Optimizer (11 tweaks) | GameDVR, MMCSS priority, Nagle algorithm, HAGS, mouse raw input, power plan, transparency — all reversible |
| Turbo Boost | One-click: RAM trim + process kill + Ultimate power plan + disable animations + stop indexer |
| RAM Optimizer | Working Set trim + Standby List purge via `NtSetSystemInformation` with before/after comparison |
| Startup Delay Manager | Instead of removing startup apps, delays them 30-60s via Task Scheduler — faster boot, nothing lost |
| Service Configurator | Gaming / Office / Daily profiles for Windows services. 21 critical services protected, JSON backup |

### Privacy & Security

| Module | What it does |
|--------|-------------|
| Privacy Shield (25 toggles) | AdvertisingID, Location, Camera, Microphone, Telemetry, Timeline, Speech, WiFi Sense, SmartScreen and more |
| File Shredder | 3-pass secure delete (random-zero-random), 64KB buffer, file rename before removal |
| USB History | Scan all connected USB device records from USBSTOR registry, optional cleanup |
| Hosts Editor | Block 40+ ad/tracker/telemetry domains via hosts file with DNS flush |

### Network & Monitoring

| Module | What it does |
|--------|-------------|
| Network Monitor | Live bandwidth measurement via .NET NetworkInterface, per-app connection list, open port scan |
| DNS Benchmark | Tests 12 DNS servers, finds the fastest, applies with one click |
| WiFi Scanner | Discovers all devices on your network |
| Internet Speed Test | Download speed and ping measurement via Cloudflare |

### Reports & Automation

| Module | What it does |
|--------|-------------|
| Health Score | 100-point system health rating with detailed breakdown |
| HTML Dashboard | Visual report that opens in your browser |
| Export System | HTML + TXT report export from any scan result |
| Weekly Scheduler | Automated maintenance via Task Scheduler |
| Before/After Comparison | Disk and RAM delta overlay shown after every operation |

---

## Installation

### Option A: Setup Installer (Recommended)

1. Download **`SistemBakim_v5.0_Setup.exe`** from [Releases](https://github.com/erdiyim/SistemBakim/releases/latest)
2. Run the installer — it will request administrator privileges
3. Choose install directory (default: `C:\Program Files\SistemBakim\`)
4. Desktop and Start Menu shortcuts are created automatically
5. Launch and enjoy

> Uninstall cleanly via **Settings > Apps** or **Control Panel > Programs**. Optional checkbox to remove all user data (logs, settings, backups).

### Option B: Portable (No Install)

1. Download **`SistemBakim.exe`** from Releases
2. Place anywhere on your drive
3. Right-click > Run as Administrator
4. That's it — single file, zero dependencies

### Requirements

- Windows 10 or 11 (64-bit)
- Administrator privileges (for system-level operations)
- ~5 MB disk space
- No .NET install needed — PowerShell 5.1 is built into Windows

### Windows SmartScreen Warning

> **"Windows protected your PC"** — you may see this when running the installer or portable EXE. This is completely normal and expected.

<details>
<summary><strong>Why does this happen and how to bypass it?</strong></summary>

#### Why?

Windows SmartScreen shows this warning for any application that is **not digitally signed with an EV (Extended Validation) Code Signing Certificate**. These certificates cost **$300–$600/year** and require a registered business entity. As a free, open-source, independently developed tool, SistemBakim does not have one — and that's the *only* reason for the warning.

**This warning says nothing about the safety of the application.** It simply means Microsoft hasn't seen enough installations to "trust" the signature yet. Even well-known open-source tools (Rufus, Ventoy, HWiNFO portable) trigger this exact same warning.

#### Is SistemBakim safe?

- **100% open source** — every line of code is visible in this repository
- **Zero internet connection** — the app never contacts any server, sends no data
- **Zero telemetry** — no tracking, no analytics, no cloud dependencies
- **VirusTotal clean** — you can upload the EXE yourself and verify: [VirusTotal.com](https://www.virustotal.com)
- **Reproducible build** — clone the repo, run `Build-EXE.ps1`, compare the output yourself

#### How to bypass

1. Click **"More info"** (or "Ek bilgi" in Turkish Windows)
2. Click **"Run anyway"** (or "Yine de calistir")
3. That's it — the app will launch normally

The warning only appears **once per file**. After the first run, Windows remembers your choice.

#### For Turkish users / Turkce kullanicilar icin

SmartScreen ekraninda **"Ek bilgi"** linkine tiklayin, ardindan **"Yine de calistir"** butonuna basin. Bu uyari sadece dijital imza sertifikasi olmayan uygulamalarda cikar ve guvenlikle ilgisi yoktur. Uygulamanin tum kaynak kodu bu depoda acik olarak gorulebilir.

</details>

---

## Architecture

```
PowerShell 5.1 Backend (8900+ lines, 69 modules)
        |
        |  GZip + Base64 embedding (NOT concatenation)
        v
   WPF XAML GUI (2400+ lines, inline dark-theme UI)
        |
        |  ps2exe compilation (-STA -requireAdmin -noConsole)
        v
   Single .exe (338 KB GUI / 486 KB CLI)
```

**Key design decisions:**

- **Why GZip embedding?** Direct script concatenation causes `Write-Host` to become `MessageBox` in `-noConsole` mode. Embedding backend as a data blob avoids this entirely.
- **Why `$global:` scope?** WPF event handlers use `.GetNewClosure()` which isolates `$script:` variables. Only `$global:` survives the closure boundary.
- **Why separate process?** Backend runs as a child PowerShell process (`Start-Process -Verb RunAs -WindowStyle Hidden`). Output streams to a temp log file. GUI reads it via 500ms `DispatcherTimer` — UI thread never blocks.
- **Why not Win32_Product?** The WMI class `Win32_Product` triggers MSI reconfiguration on every query. Registry Uninstall keys (HKLM 64-bit + WOW6432Node + HKCU) are 100x faster.

### Safety guarantees

| Mechanism | Protects against |
|-----------|-----------------|
| 21-service protection list | BSOD from disabling critical services (WinDefend, RpcSs, EventLog...) |
| `.reg` backup before registry clean | Irreversible registry damage — double-click to restore |
| Rename-with-dash instead of delete | Context menu shell extension loss — prefix removal re-enables |
| Task Scheduler delay instead of startup removal | Lost startup programs — original entries preserved |
| `Onay()` confirmation gate | Accidental destructive operations |
| 3-pass shredder | Incomplete secure deletion |
| Grace period on process exit | False "process crashed" errors from transcript flush delay |

---

## Screenshots

> *Coming soon — contribution welcome!*

---

## Building from Source

```powershell
# Prerequisites: ps2exe module
Install-Module ps2exe -Scope CurrentUser

# Clone and build
git clone https://github.com/erdiyim/SistemBakim.git
cd SistemBakim/src
echo "" | powershell -NoProfile -ExecutionPolicy Bypass -File "Build-EXE.ps1"

# Output: bin/SistemBakim.exe + bin/SistemBakim_CLI.exe
```

To build the installer, open `installer/SistemBakim_Setup.iss` in [Inno Setup 6.x](https://jrsoftware.org/isinfo.php) and compile.

---

## Roadmap

SistemBakim is actively developed. Here's what's coming next:

### v5.1 — Quality of Life Update *(Coming Soon)*

> *The v5.0 engine is solid. v5.1 makes it seamless.*

| Feature | Status | Description |
|---------|--------|-------------|
| **In-App Auto Updater** | 🚧 In Progress | Never miss a release. On startup, the app queries GitHub Releases API for newer versions. If found, a non-intrusive banner appears: *"v5.2 available — Update now"*. One click downloads the new Setup.exe, verifies SHA256 hash, and launches the installer. No background services, no forced updates — you decide when. |
| **HTML/PDF Report Export** | 🚧 In Progress | After any scan or cleanup, generate a professional report with one click. Includes: system info header, module-by-module results, before/after metrics, disk space recovered, and a health score gauge. Pure HTML with inline CSS + SVG charts — opens in any browser, prints as PDF. Perfect for IT professionals who need documentation. |
| **Custom Profiles** | 📋 Planned | Stop clicking the same checkboxes every time. Create named profiles like *"Gaming Cleanup"*, *"Weekly Deep Clean"*, or *"Office PC Maintenance"* — each saves your selected modules as a JSON file. One-click execution from a dedicated Profiles panel. Export/import profiles to share with others. |
| **System Tray Mode** | 📋 Planned | Minimize to tray instead of closing. Right-click the tray icon for a quick-action context menu: *"Quick Clean"*, *"RAM Optimize"*, *"Open SistemBakim"*, *"Exit"*. The tray icon shows system health status via color: green (healthy), yellow (needs attention), red (critical). |
| **English UI** | 📋 Planned | Full English language support with runtime toggle. All 69 module names, descriptions, and dialogs translated. Language preference saved in settings. |

### v6.0 — Platform Vision *(Future)*

| Feature | Description |
|---------|-------------|
| **Guardian Mode** | System Tray watchdog — auto-cleans RAM when usage exceeds 90%, clears temp when disk is 95% full, weekly silent maintenance via Task Scheduler |
| **Live Pulse Dashboard** | Real-time CPU/RAM/GPU/Disk telemetry with animated charts, temperature monitors, and 24-hour history sparklines |
| **Script Bazaar** | Community plugin marketplace — browse, install, and share custom PS1 modules with one click. Sandboxed execution with SHA256 verification |
| **NetMap** | Live network topology map — visualize all active connections on a world map with GeoIP, one-click firewall blocking for suspicious connections |
| **TimeMachine** | Pre-maintenance system snapshots with selective rollback — registry, services, startup items, DNS, firewall rules. Never worry about breaking something |

> Have an idea? [Open a Feature Request](https://github.com/erdiyim/SistemBakim/issues/new?template=feature_request.yml) — your suggestions built v5.0, and they'll shape v6.0 too.

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first.

**Areas where help is appreciated:**
- Screenshots and GIF recordings for the README
- Translations (English UI strings)
- Code signing certificate sponsorship (eliminates SmartScreen warnings)

---

## License

Personal and non-commercial use is free. See [LICENSE](LICENSE) for details.

---

<div align="center">

## Türkçe

</div>

## SistemBakim Nedir?

SistemBakim, Windows 10/11 için geliştirilmiş **69 modüllük** bir sistem bakım, temizlik, optimizasyon ve güvenlik aracıdır. Tek bir EXE dosyası olarak çalışır, hiçbir bağımlılığı yoktur.

### Temel Özellikler

- **Derin Temizlik** — 19 farklı konumda temp, cache, log ve gereksiz dosya temizliği
- **Registry Temizleyici** — Kırık program girişlerini, geçersiz DLL referanslarını tarar, .reg yedeği alır
- **FPS Optimizasyonu** — GameDVR, MMCSS, Nagle, HAGS dahil 11 farklı oyun tweakı (geri alınabilir)
- **Gizlilik Kalkanı** — 25 Windows gizlilik ayarını tek tıkla yönet
- **Turbo Boost** — RAM temizle + süreç kapat + güç planı yükselt + efekt kapat = anında performans
- **Disk Haritası** — WinDirStat benzeri görsel blok harita, uygulamanın içinde
- **Dosya Kırpıcı** — 3 geçişli güvenli silme (rastgele-sıfır-rastgele)
- **Ağ Monitörü** — Canlı bant genişliği ölçümü ve uygulama bazlı ağ tüketimi
- **Hizmet Yapılandırıcısı** — Oyun / İş / Günlük profilleriyle Windows servislerini toplu optimize et
- **Tema Desteği** — Koyu ve açık mod arasında geçiş
- **Öncesi/Sonrası Karşılaştırma** — Her işlem sonrası disk ve RAM fark göstergesi
- **Dışa Aktarma** — HTML + TXT rapor oluşturma

### Nasıl Kurulur?

1. [Releases](https://github.com/erdiyim/SistemBakim/releases/latest) sayfasından **SistemBakim_v5.0_Setup.exe** indirin
2. Kurulum sihirbazını çalıştırın (yönetici yetkisi isteyecektir)
3. Masaüstü kısayolundan uygulamayı başlatıp keyfini çıkarın

### Gereksinimler

- Windows 10 veya 11 (64-bit)
- Yönetici yetkisi
- Ek kurulum gerekmez

### Yol Haritasi (Roadmap)

#### v5.1 — Yasam Kalitesi Guncellemesi *(Yakinda)*

> *v5.0 motoru saglam. v5.1 onu kusursuz yapiyor.*

| Ozellik | Durum | Aciklama |
|---------|-------|----------|
| **Otomatik Guncelleyici** | 🚧 Gelistiriliyor | Uygulama acildiginda GitHub Releases API'sini kontrol eder. Yeni surum varsa tek tikla indir + kur. Zorla guncelleme yok — karar sizin. |
| **HTML/PDF Rapor** | 🚧 Gelistiriliyor | Tarama veya temizlik sonrasi profesyonel rapor olusturma. Sistem bilgisi, modul sonuclari, oncesi/sonrasi metrikleri, saglik skoru — tek tikla HTML ciktisi. IT profesyonelleri icin dokumantasyon. |
| **Ozel Profiller** | 📋 Planlandi | "Oyun Temizligi", "Haftalik Derin Temizlik" gibi kendi modul profillerinizi JSON olarak kaydedin. Tek tikla calistirin. Baskalarinin profilleri iceri aktarin. |
| **System Tray Modu** | 📋 Planlandi | Kapatmak yerine gorev cubuguna kucultme. Sag tik menusu: "Hizli Temizlik", "RAM Optimize", "Ac", "Cikis". Ikon rengi sistem sagligini gosterir. |
| **Ingilizce Arayuz** | 📋 Planlandi | Tum 69 modul adi, aciklamasi ve diyalog metinleri Ingilizce secenegi. |

#### v6.0 — Platform Vizyonu *(Gelecek)*

| Ozellik | Aciklama |
|---------|----------|
| **Nobetci Modu** | System Tray'de 7/24 izleme — RAM %90'i gecince otomatik temizle, disk dolunca uyar, haftalik sessiz bakim |
| **Canli Telemetri** | CPU/RAM/GPU/Disk icin gercek zamanli animasyonlu grafikler ve sicaklik monitoru |
| **Script Pazari** | Topluluk plugin magazasi — tek tikla yukle, calistir, paylas. Sandbox + SHA256 dogrulama |
| **Ag Haritasi** | Aktif baglantilari dunya haritasinda gorsellestirme, supheli IP'leri tek tikla engelleme |
| **Zaman Makinesi** | Bakim oncesi sistem snapshot'i + secici geri alma (registry, servisler, baslangic ogeleri) |

> Fikriniz mi var? [Ozellik Istegi acin](https://github.com/erdiyim/SistemBakim/issues/new?template=feature_request.yml) — v5.0'i sizin onerileriniz sekillendirdi, v6.0'i da oyle olacak.

---

<div align="center">

## Support the Project / Projeye Destek Ol

</div>

SistemBakim is and will always be **free, open source, and ad-free**. There are no premium tiers, no "Pro" upsells, no tracking. This is a deliberate choice — not a temporary pricing strategy.

But building and maintaining 69 modules, testing across Windows versions, and keeping up with OS changes takes real time. If SistemBakim saved you hours of manual cleanup or helped you squeeze extra FPS out of your rig, you can support the project:

- **Star this repo** — it's free and helps others discover the tool
- **Report bugs** — well-written bug reports are incredibly valuable ([Bug Report template](.github/ISSUE_TEMPLATE/bug_report.yml))
- **Suggest features** — your ideas shape the roadmap ([Feature Request template](.github/ISSUE_TEMPLATE/feature_request.yml))
- **Sponsor** — if you want to directly support development: [![GitHub Sponsors](https://img.shields.io/badge/GitHub-Sponsor-EA4AAA?style=flat-square&logo=github-sponsors&logoColor=white)](https://github.com/sponsors/erdiyim)

Every contribution — code, feedback, or coffee — keeps this project alive and independent.

---

SistemBakim, her zaman **ücretsiz, açık kaynak ve reklamsız** kalacak. Premium katman, "Pro" sürümü veya gizli izleme yoktur. Bu bilinçli bir karar.

Ama 69 modülü geliştirmek, Windows sürümleri arasında test etmek ve güncel tutmak ciddi zaman alıyor. SistemBakim size zaman kazandırdıysa veya bilgisayarınızı hızlandırdıysa, projeye destek olabilirsiniz:

- **Yıldız verin** — ücretsiz ve keşfedilebilirlik için önemli
- **Hata bildirin** — iyi yazılmış hata raporları çok değerli
- **Özellik önerin** — fikirleriniz yol haritasını şekillendiriyor
- **Sponsor olun** — geliştirmeyi doğrudan desteklemek için: [GitHub Sponsors](https://github.com/sponsors/erdiyim)

---

<div align="center">

**Built with obsession by [Erdi](https://github.com/erdiyim) + [Claude](https://claude.ai)**

*If SistemBakim saved you time, consider giving it a star.*

</div>
