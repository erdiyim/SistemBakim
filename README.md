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

### v5.1 — Planned

| Feature | Status | Description |
|---------|--------|-------------|
| **Auto-Updater** | 🔬 Research | In-app update check with one-click download. No background services — you control when to update. The app already checks GitHub Releases on startup; v5.1 will add a "Download & Replace" button that fetches the new EXE, verifies its hash, and swaps the binary. |
| **English UI** | 📋 Planned | Full English language support with runtime toggle. All 69 module names, descriptions, menu items, and dialog texts translated. Language preference saved in `ayarlar.json`. |
| **Advanced Ping Analyzer** | 📋 Planned | Real-time ping graph with jitter, packet loss, and route tracing. Continuous monitoring mode that logs latency spikes over hours — perfect for diagnosing intermittent connection drops during gaming or video calls. |

### Future Ideas

- **Profile Export/Import** — Share your optimization profiles with others as JSON files
- **CLI Automation Mode** — `SistemBakim_CLI.exe --run 3,26,60 --auto` for scripted maintenance
- **Plugin System** — Community-contributed modules loaded from a `plugins/` directory

> Have an idea? [Open a Feature Request](https://github.com/erdiyim/SistemBakim/issues/new?template=feature_request.yml) — your suggestions built v5.0, and they'll build v5.1 too.

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

### Yol Haritası (Roadmap)

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| **Otomatik Güncelleyici** | 🔬 Araştırma | Uygulama içinden tek tıkla güncelleme |
| **İngilizce Arayüz** | 📋 Planlandı | Tüm UI metinleri İngilizce seçeneği |
| **Ping Analizörü** | 📋 Planlandı | Canlı ping grafiği, jitter ve paket kaybı ölçümü |

> Fikriniz mi var? [Özellik İsteği açın](https://github.com/erdiyim/SistemBakim/issues/new?template=feature_request.yml) — v5.0'daki her özellik sizin gibi kullanıcıların önerileriyle oluşturuldu.

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
