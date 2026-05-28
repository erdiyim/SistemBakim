<div align="center">

# SistemBakim v5.0 — Branding & Authority Kit

### Case Study · LinkedIn Post · B2B Agency Showcase

*Kişisel marka, profesyonel ağ ve kurumsal satış için hazır metinler.*

</div>

---

# 1. Portfolyo Case Study

> Kişisel web sitende "Projects" veya "Case Studies" bölümüne ekle.
> Markdown veya HTML olarak kullanılabilir. Görseller için yer tutucular işaretlenmiştir.

---

<div align="center">

## SistemBakim v5.0

### Engineering a Zero-Dependency Windows Maintenance Platform from Scratch

**Role:** Solo Developer & Architect
**Duration:** 4 development phases, end-to-end
**Stack:** PowerShell 5.1 · WPF/XAML · .NET Interop · Inno Setup · GitHub Actions
**Output:** 11,000+ lines · 69 modules · 338 KB single EXE

</div>

---

### The Problem

Windows system maintenance tools exist in a paradox: the software designed to optimize your computer is often the thing slowing it down. Leading products like CCleaner (42 MB installer, telemetry, subscription prompts) and IObit Advanced SystemCare (65 MB, bundled browser extensions) have evolved into the very bloatware they claim to remove.

Meanwhile, IT professionals and power users resort to scattered PowerShell scripts, obscure registry guides, and tools that require separate installations for each task — disk cleanup here, privacy hardening there, network diagnostics somewhere else.

**I set out to build one tool that replaces them all — with no dependencies, no internet requirement, and no way to break the user's system.**

---

### Challenge #1: Asynchronous UI Over a Single-Threaded Scripting Language

PowerShell is inherently single-threaded. WPF requires an STA (Single-Threaded Apartment) thread for UI rendering. Running a 69-module backend — some operations taking 15+ minutes (WinSxS cleanup via DISM) — on the same thread as the GUI would freeze the interface entirely.

**The architectural constraint:** I couldn't use background runspaces (PowerShell's threading model) because WPF controls can only be accessed from the thread that created them. I also couldn't use simple script concatenation for the compiled EXE because ps2exe's `-noConsole` flag converts every `Write-Host` call into a `MessageBox.Show()` — the user would see hundreds of popup dialogs instead of log output.

**Solution:** A three-layer decoupled architecture:

```
┌─────────────────────────────────────┐
│  WPF GUI Process (STA Thread)       │
│  ├─ XAML rendering                  │
│  ├─ DispatcherTimer (500ms poll)    │  ← Reads log file
│  └─ Event handlers (.GetNewClosure) │
│         │                           │
│         │  Start-Process -Verb RunAs│
│         ▼       -WindowStyle Hidden │
│  ┌──────────────────────────────┐   │
│  │  Backend Child Process       │   │
│  │  ├─ 69 module functions      │   │
│  │  ├─ Write-Host → log file    │   │  ← Writes to temp log
│  │  └─ Exit code signaling      │   │
│  └──────────────────────────────┘   │
│         │                           │
│         │  GZip + Base64 embedded   │
│         ▼                           │
│  ┌──────────────────────────────┐   │
│  │  Single EXE (338 KB)         │   │  ← ps2exe compiled
│  │  Backend = compressed blob   │   │
│  │  Extracted to %TEMP% at run  │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

The backend runs as a hidden child PowerShell process. Its output streams to a temporary log file. The GUI reads this file every 500ms via a `DispatcherTimer`, parsing new lines and rendering them in the output panel. The UI thread never blocks — even during operations that take minutes.

**Key discovery:** WPF event handlers created with `.GetNewClosure()` capture variables in an isolated scope, making `$script:` variables invisible inside closures. This forced a deliberate decision to use `$global:` scope for all shared state — unconventional in PowerShell, but the only pattern that survives the closure boundary in compiled WPF applications.

---

### Challenge #2: Building a "Cannot Break Your System" Guarantee

A system maintenance tool has a unique engineering requirement: it must be destructive enough to clean gigabytes of junk, but safe enough that no combination of user actions can cause a BSOD, data loss, or unbootable system.

**Solution:** A multi-layer safety architecture:

| Layer | Mechanism | What it prevents |
|-------|-----------|-----------------|
| **Hardcoded protection list** | 21 Windows services (WinDefend, RpcSs, EventLog, etc.) are defined as an immutable array. No code path — no profile, no user input — can disable them. | BSOD from disabled critical services |
| **Pre-operation backups** | Registry Cleaner exports `.reg` files before deletion. Service Configurator saves JSON state snapshots. | Irreversible registry/service damage |
| **Safe rename over delete** | Context menu shell extensions are disabled by prefixing with `-` (rename), not removed. Removing the prefix re-enables them instantly. | Lost shell extensions |
| **Delay over removal** | Startup Delay Manager creates Task Scheduler entries with `PT30S`/`PT60S` triggers instead of deleting original startup entries. Boot is faster, but nothing is lost. | Missing startup programs |
| **Confirmation gate** | Every destructive operation routes through an `Onay()` function that requires explicit `[E]` input. In GUI mode, `Read-Host` returns `'1'` (which never matches `[Ee]`), so destructive operations are safely skipped. | Accidental mass deletion |
| **Per-file error handling** | Deep Clean wraps each file removal in individual `try-catch`. Locked files increment a counter instead of failing silently. The user sees "12 locked files skipped" instead of a misleading "100% cleaned." | Silent failures, inaccurate reporting |
| **Grace period** | Backend process exit triggers a 3-second grace period (`$global:PROSES_CIKIS_ZAMANI`) before the GUI declares failure — preventing false "process crashed" errors during transcript flush. | False crash reports |

**Result:** Across all testing — including deliberate stress scenarios (running all 69 modules sequentially, killing processes mid-operation, testing on minimal-permission accounts) — zero system-breaking bugs shipped to users.

---

### Challenge #3: Compiling an 11,000-Line Script into a 338 KB Portable EXE

The entire application — 8,900 lines of backend + 2,400 lines of WPF GUI — compiles into a single 338 KB executable with zero runtime dependencies. No .NET installer, no DLL files, no config folder.

**The compilation problem:** Direct concatenation of backend + GUI scripts doesn't work in ps2exe's `-noConsole` mode. Every `Write-Host` becomes `[System.Windows.MessageBox]::Show()`, producing hundreds of modal dialogs.

**Solution:** The build pipeline (`Build-EXE.ps1`) uses a GZip + Base64 embedding strategy:

1. Backend script (8,900 lines, ~420 KB) is read as raw bytes
2. Compressed via `GZipStream` (~55-60% reduction)
3. Encoded as Base64 string
4. Embedded as a data literal inside the GUI script
5. At runtime: decoded → decompressed → written to `%TEMP%\SistemBakim_v5_runtime.ps1`
6. Executed as a child process

This approach avoids the `Write-Host` → `MessageBox` problem entirely because the backend runs as a separate process, not inline code. The build script also strips STA/Admin check blocks (ps2exe handles these via `-STA` and `-requireAdmin` flags) and remaps `$BACKEND` paths to the temp extraction location.

**Performance of the build:** Full compilation completes in ~15 seconds. The resulting EXE starts in under 2 seconds on modern hardware.

---

### Challenge #4: Production-Grade CI/CD for a PowerShell Desktop App

Desktop applications written in scripting languages are rarely treated as first-class CI/CD citizens. I built a GitHub Actions pipeline that fully automates the release process:

```
git tag v5.1 → git push origin v5.1
    │
    ▼
GitHub Actions (windows-latest)
    ├─ Install ps2exe from PSGallery
    ├─ Run Build-EXE.ps1 (GUI + CLI)
    ├─ Verify output (size sanity check: >50 KB)
    ├─ Silent-install Inno Setup 6
    ├─ Compile .iss → Setup EXE
    ├─ Upload artifacts (30-day retention)
    └─ Create GitHub Release with 3 EXE assets
```

A version tag push is the only manual step. Everything else — compilation, installer creation, release notes, asset upload — is fully automated.

---

### Impact & Metrics

| Metric | Value |
|--------|-------|
| Total modules | 69 |
| Backend code | 8,900+ lines |
| GUI code | 2,400+ lines |
| GUI EXE size | 338 KB |
| CLI EXE size | 486 KB |
| External dependencies | 0 |
| Critical bugs shipped | 0 |
| Runtime crashes (stress test) | 0 |
| Protected services (hardcoded) | 21 |
| Privacy toggles | 25 |
| FPS optimization tweaks | 11 (all individually reversible) |
| Supported platforms | Windows 10/11 (64-bit) |

---

### Technical Decisions Worth Noting

| Decision | Why |
|----------|-----|
| Registry Uninstall keys instead of `Win32_Product` | WMI's `Win32_Product` triggers MSI reconfiguration on every query. Registry scan is 100x faster and non-destructive. |
| `NtSetSystemInformation` for RAM purge | Managed APIs don't expose standby list management. P/Invoke to the NT kernel function is the only way to clear the standby page list. |
| Slice-and-dice treemap instead of squarified | Squarified algorithm requires recursive sorting + complex aspect ratio calculation. Slice-and-dice with 50MB grouping threshold produces visually clean results with 1/3 the code complexity. |
| `$global:` scope by design | Not a shortcut — it's the only scope that survives `.GetNewClosure()` in WPF event handlers. Documented as an architectural decision, not tech debt. |

---

### Links

- **GitHub:** [github.com/erdiyim/SistemBakim](https://github.com/erdiyim/SistemBakim)
- **Live Landing Page:** [erdiyim.github.io/SistemBakim](https://erdiyim.github.io/SistemBakim)
- **Technical Documentation:** [Module Reference (69 modules)](https://github.com/erdiyim/SistemBakim/blob/main/docs/MODULES.md)

---

`<!-- Görsel yer tutucular -->`
`<!-- [Screenshot: Dashboard görünümü] -->`
`<!-- [Screenshot: Disk Treemap] -->`
`<!-- [Screenshot: Before/After Comparison] -->`
`<!-- [Diagram: Architecture (yukarıdaki ASCII'nin görsel versiyonu)] -->`

---
---

# 2. LinkedIn "Build in Public" Post

> Doğrudan LinkedIn'e kopyala-yapıştır. Karakter sınırı: ~3000.
> Emoji kullanımı LinkedIn algoritması için optimize edilmiştir (aşırı değil, stratejik).

---

```
I just shipped a solo project that took everything I know about systems engineering and put it into one file.

SistemBakim v5.0 — a 69-module Windows maintenance toolkit. 11,000+ lines of PowerShell. WPF dark-themed GUI. Single 338 KB executable. Zero dependencies.

Here's what I learned building it alone:

⸻

𝟏. 𝐓𝐡𝐞 𝐡𝐚𝐫𝐝𝐞𝐬𝐭 𝐩𝐫𝐨𝐛𝐥𝐞𝐦 𝐰𝐚𝐬𝐧'𝐭 𝐜𝐨𝐝𝐢𝐧𝐠 — 𝐢𝐭 𝐰𝐚𝐬 𝐚𝐫𝐜𝐡𝐢𝐭𝐞𝐜𝐭𝐮𝐫𝐞.

PowerShell is single-threaded. WPF needs an STA thread. Some operations (WinSxS cleanup) take 15+ minutes.

If I ran the backend on the UI thread, the app would freeze. If I used standard threading, WPF controls wouldn't be accessible. If I concatenated scripts for compilation, every Write-Host would become a MessageBox popup.

Solution: GZip-embed the backend as a compressed blob, extract at runtime, execute as a hidden child process, stream output to a temp file, and poll it with a 500ms DispatcherTimer.

Zero UI freezes. Zero MessageBox bugs. 338 KB total.

𝟐. "𝐂𝐚𝐧𝐧𝐨𝐭 𝐛𝐫𝐞𝐚𝐤 𝐲𝐨𝐮𝐫 𝐬𝐲𝐬𝐭𝐞𝐦" 𝐢𝐬 𝐚𝐧 𝐞𝐧𝐠𝐢𝐧𝐞𝐞𝐫𝐢𝐧𝐠 𝐩𝐫𝐨𝐦𝐢𝐬𝐞, 𝐧𝐨𝐭 𝐚 𝐦𝐚𝐫𝐤𝐞𝐭𝐢𝐧𝐠 𝐜𝐥𝐚𝐢𝐦.

I hardcoded 21 critical Windows services as untouchable. No profile, no setting, no user input can disable WinDefend, RpcSs, or EventLog.

Registry changes create .reg backups before deletion. Shell extensions are renamed (not deleted). Startup apps are delayed via Task Scheduler (not removed). Every file deletion has individual try-catch with locked-file counting.

The result: zero system-breaking bugs across stress testing all 69 modules sequentially.

𝟑. 𝐒𝐨𝐥𝐨 𝐝𝐨𝐞𝐬𝐧'𝐭 𝐦𝐞𝐚𝐧 𝐮𝐧𝐩𝐫𝐨𝐟𝐞𝐬𝐬𝐢𝐨𝐧𝐚𝐥.

This project has:
→ GitHub Actions CI/CD (tag push → auto build → auto release)
→ Inno Setup professional installer (Turkish + English, clean uninstall)
→ Structured issue templates (Bug Report + Feature Request)
→ Full module documentation (every registry key, every API call documented)
→ Tailwind CSS landing page
→ Before/After comparison for every operation

One developer. Zero shortcuts.

⸻

The tech stack that made it possible:
• PowerShell 5.1 (no external runtime needed — built into Windows)
• WPF/XAML (inline dark-themed UI, no external dependencies)
• ps2exe (PowerShell → EXE compilation)
• Inno Setup 6 (professional installer)
• GitHub Actions (CI/CD)

⸻

Why am I sharing this?

Because "Build in Public" isn't just about shipping updates — it's about showing the engineering decisions behind the product.

Every $global: scope decision, every GZip embedding workaround, every 3-second grace period for process exit timing — these are the invisible choices that make software reliable.

If you're building something solo: document your architecture decisions. They're more impressive than your feature list.

⸻

🔗 GitHub: github.com/erdiyim/SistemBakim
📦 Download: github.com/erdiyim/SistemBakim/releases/latest

Free. Open source. Zero telemetry. 

If you've read this far, I'd love to hear: what's the hardest engineering constraint you've worked around in a solo project?

#BuildInPublic #OpenSource #PowerShell #Windows #SoftwareEngineering #IndieHacker #DevTools #SystemAdmin
```

---

### LinkedIn Post Stratejik Notlar

| Parametre | Değer |
|-----------|-------|
| Uzunluk | ~2,800 karakter (ideal aralık: 1,500-3,000) |
| Yapı | Hook → 3 numaralı bölüm → CTA → Soru |
| Emoji kullanımı | Minimal ve stratejik (liste işaretleyicileri, linkler) |
| Bold başlıklar | Unicode bold karakterler (LinkedIn native bold desteklemiyor) |
| Hashtag sayısı | 8 (LinkedIn optimal: 3-10) |
| CTA | Soru ile bitiyor — yorum tetikleyici |
| Görseller | Post ile birlikte: Dashboard screenshot + Architecture diagram |

**Zamanlama:** Salı veya Çarşamba 08:00-10:00 (yerel saat). LinkedIn'de B2B etkileşimi hafta içi sabah saatlerinde en yüksek.

---
---

# 3. B2B Ajans Vitrini

> Ajans web sitesinde "Portfolio", "Case Studies" veya "Our Work" bölümüne ekle.
> İki versiyon: Kısa (paragraf) ve Uzun (detaylı).

---

## Versiyon A: Kısa Paragraf (Web sitesi, teklif dokümanı, sunumlarda)

```
SistemBakim v5.0 — Enterprise-Grade Windows Platform, Built Solo

We don't just build websites and mobile apps. We engineer systems.

SistemBakim is an 11,000-line Windows maintenance platform compiled into a single 
338 KB executable — with zero external dependencies, zero runtime installations, 
and zero crash tolerance. It manages 69 discrete system operations through an 
asynchronous WPF architecture that keeps the UI responsive during 15-minute 
background tasks, protects 21 critical Windows services with hardcoded safety 
lists, and automatically backs up every registry and service change before 
execution.

The project ships with a complete CI/CD pipeline (GitHub Actions → Inno Setup → 
automated release), structured issue tracking, professional installer with 
dual-language support, and full technical documentation of every registry key 
and API call in the codebase.

This is the level of engineering discipline we bring to every client engagement — 
whether it's a customer-facing web application or an operating-system-level 
automation platform. If your project requires zero-defect tolerance, complex 
state management, or deep systems integration, we have the architecture mindset 
to deliver it.
```

---

## Versiyon B: Detaylı (Özel portfolyo sayfası veya teklif eki)

```
CASE REFERENCE: SistemBakim v5.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Category       : Desktop Systems Engineering
Platform       : Windows 10/11 (64-bit)
Codebase       : 11,000+ lines (PowerShell 5.1 + WPF/XAML)
Deliverable    : Single portable EXE (338 KB) + Professional installer
Timeline       : 4-phase development cycle
Team           : Solo architect & developer


SCOPE
─────
Design and implementation of a comprehensive Windows system maintenance 
platform — 69 independent modules spanning disk cleanup, registry management, 
network diagnostics, privacy hardening, gaming optimization, and automated 
reporting. All modules operate at the OS level, interacting directly with 
Windows registry, WMI/CIM providers, kernel APIs (NtSetSystemInformation), 
DISM servicing stack, and Task Scheduler.


ENGINEERING CHALLENGES SOLVED
─────────────────────────────
1. ASYNCHRONOUS UI ARCHITECTURE
   Built a non-blocking GUI over a single-threaded scripting runtime. 
   Backend runs as a hidden child process with output streamed via 
   DispatcherTimer polling — achieving responsive UI during operations 
   that take up to 15 minutes.

2. ZERO-DEFECT SAFETY ARCHITECTURE
   Implemented a 7-layer protection system: hardcoded critical service 
   lists, automatic pre-operation backups (.reg / JSON), safe rename 
   instead of deletion, startup delay instead of removal, confirmation 
   gates, per-file error handling, and process exit grace periods.

3. SINGLE-FILE COMPILATION
   Developed a GZip + Base64 embedding pipeline that compresses the 
   backend into a data blob within the GUI script, avoiding ps2exe 
   compilation artifacts (Write-Host → MessageBox conversion). Full 
   application compiles to 338 KB with zero external dependencies.

4. PRODUCTION CI/CD FOR DESKTOP SOFTWARE
   GitHub Actions pipeline: version tag push → ps2exe compilation → 
   output verification → Inno Setup compilation → GitHub Release with 
   automatic asset upload. One manual step (git tag), fully automated 
   delivery.


WHAT THIS DEMONSTRATES
──────────────────────
→ We can architect systems at the operating system level, not just 
  the application layer
→ We build with zero-defect methodology: backups, rollbacks, 
  protection lists, and confirmation gates are architectural 
  requirements, not afterthoughts
→ We ship production-grade CI/CD for non-standard platforms 
  (desktop PowerShell compiled to EXE)
→ We deliver complete ecosystems: source code, installer, documentation, 
  landing page, issue tracking, community management

This is the engineering standard we apply to every engagement.
```

---

## Versiyon C: Tek Cümle (Email imzası, kısa bio, konuşma tanıtımı)

```
Creator of SistemBakim — an 11,000-line, zero-dependency Windows maintenance 
platform compiled into a single 338 KB executable, serving 69 modules through 
an asynchronous WPF architecture with hardcoded system safety guarantees.
```

---

## Versiyon D: Türkçe B2B (Türkiye pazarı için)

```
SistemBakim v5.0 — İşletim Sistemi Seviyesinde Mühendislik

Biz sadece web sitesi veya mobil uygulama yapmıyoruz. Sistem mühendisliği 
yapıyoruz.

SistemBakim, 11.000 satırlık bir Windows bakım platformunun tek bir 338 KB'lik 
çalıştırılabilir dosyaya sıkıştırılmış halidir — sıfır dış bağımlılık, sıfır 
çalışma zamanı kurulumu, sıfır çökme toleransı. 69 farklı sistem operasyonunu, 
15 dakikalık arka plan görevleri sırasında bile arayüzün donmamasını sağlayan 
asenkron bir WPF mimarisi üzerinden yönetir. 21 kritik Windows servisini 
donanıma gömülmüş güvenlik listeleriyle korur ve her registry ve servis 
değişikliğinden önce otomatik yedek oluşturur.

Proje, tam bir CI/CD pipeline'ı (GitHub Actions → Inno Setup → otomatik release), 
yapılandırılmış hata takibi, profesyonel kurulum sihirbazı ve kod tabanındaki 
her registry anahtarının teknik dokümantasyonuyla birlikte teslim edilir.

Bu, her müşteri projesine getirdiğimiz mühendislik disiplinidir — ister 
kullanıcıya yönelik bir web uygulaması olsun, ister işletim sistemi 
seviyesinde bir otomasyon platformu. Projeniz sıfır hata toleransı, karmaşık 
durum yönetimi veya derin sistem entegrasyonu gerektiriyorsa, bunu teslim 
edecek mimari zihniyete sahibiz.
```

---

<div align="center">

*Bu metinler birbirini tamamlar:*
*Case Study → derinlik, LinkedIn → görünürlük, B2B → güven ve satış.*

*Hepsini aynı hafta içinde yayınla — tutarlı bir profesyonel imaj oluşturur.*

</div>
