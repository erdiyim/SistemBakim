# SistemBakim v5.0 — Launch Kit

Viral lansman metinleri. Kopyala-yapıştır hazır.

---

## 1. Reddit Post

> Bu metni r/Windows11, r/pcmasterrace, r/sysadmin, r/opensource, r/software için kullanabilirsin.
> Başlık ve gövde ayrı verilmiştir.

### Title (Başlık)

```
I built a 69-module Windows maintenance tool because I was tired of CCleaner asking me to upgrade
```

### Body (Gövde)

```
Hey everyone,

I'm a solo developer and I've been working on SistemBakim for a while now. It started as a personal PowerShell script to clean up my own PC after a fresh Windows install — disable telemetry, kill bloatware, trim RAM, the usual stuff.

Over time it grew. Friends asked for it. I added a GUI. Then a registry cleaner. Then an FPS optimizer. Then... 69 modules.

**What it does:**

- Deep cleans 19 locations (temp, browser caches, shader caches, prefetch, WER, delivery optimization, etc.)
- FPS optimizer with 11 registry tweaks (GameDVR, MMCSS, Nagle, HAGS — all reversible with one click)
- Privacy Shield — 25 Windows privacy toggles (advertising ID, location, camera, telemetry, timeline, speech recognition...)
- Registry cleaner that actually creates .reg backups before touching anything
- Service configurator with Gaming/Office/Daily profiles (21 critical services are hardcoded as untouchable)
- RAM optimizer using NtSetSystemInformation standby list purge
- Network monitor, DNS benchmark, WiFi scanner, internet speed test
- Disk treemap (WinDirStat-style, built into the app)
- File shredder (3-pass: random-zero-random)
- Full before/after comparison for every operation

**What it doesn't do:**

- No internet connection required (zero cloud, zero telemetry)
- No subscription, no "Pro" version, no upsells
- No bundled toolbar, no browser hijacking
- Does not use Win32_Product (which triggers MSI reconfiguration)
- Never touches the 21 protected services list (WinDefend, RpcSs, EventLog, etc.)

**Technical details for the curious:**

- Single PowerShell 5.1 script (8,900+ lines), compiled to EXE via ps2exe
- Backend is GZip+Base64 embedded into the GUI (not concatenated — this avoids the Write-Host→MessageBox bug in -noConsole mode)
- WPF dark-themed UI with DispatcherTimer for non-blocking updates
- 338 KB for the GUI, 486 KB for the CLI. That's it. No .NET install needed.

**Links:**

- GitHub: https://github.com/erdiyim/SistemBakim
- Download: https://github.com/erdiyim/SistemBakim/releases/latest
- Full module documentation: https://github.com/erdiyim/SistemBakim/blob/main/docs/MODULES.md

It's free and open source. I'd genuinely appreciate feedback — especially if something breaks on your setup. I've tested on Win10 22H2 and Win11 24H2 but edge cases are always lurking.

Note: You'll get a SmartScreen warning because I don't have an EV code signing certificate ($400+/year). The code is fully open source — you can audit every line or build from source yourself.
```

---

## 2. Product Hunt — Maker's Comment

> Bu metni Product Hunt'a ürün gönderdikten sonra ilk yorum olarak ekle.
> "Maker's Comment" formatı — kişisel hikaye + teknik fark + vizyon.

### Tagline (Slogan — 60 karakter)

```
69-module Windows optimizer. Single EXE. Zero bloat.
```

### Maker's Comment

```
Hey Product Hunt!

I'm Erdi, and I built SistemBakim because I was frustrated with the state of Windows maintenance tools.

Here's the problem: Most "system optimizers" fall into two categories:

1. Bloated subscription traps (CCleaner, IObit) that upsell you on every click and now bundle their own telemetry — the very thing they claim to remove.

2. Shallow registry cleaners that delete random keys and actually make things worse.

I wanted something different: a tool that does real work, explains what it's doing, and can't break your system even if you try.

**So I built one.** 69 modules. Single EXE. 338 KB. No internet required. No account. No cloud. No payment.

What makes it different:

→ Every optimization is reversible. Registry changes create .reg backups. Context menu entries are renamed (not deleted). Startup apps are delayed (not removed).

→ 21 critical Windows services are hardcoded as untouchable. No profile, no setting, no user input can disable WinDefend, RpcSs, or EventLog.

→ The FPS optimizer applies 11 specific, documented registry tweaks — not vague "boost" buttons. Each one can be individually reversed.

→ The privacy shield shows you exactly which registry key controls each setting. Full transparency, not "trust us, we fixed it."

→ It's a single PowerShell script compiled to EXE. You can read every line of the source code. No obfuscation, no hidden network calls.

The code is open source on GitHub. I'd love your feedback — what modules would you add? What's missing?

https://github.com/erdiyim/SistemBakim
```

---

## 3. Hacker News (Show HN)

> HN için kısa, teknik odaklı, "pazarlama" kokmayan bir post.
> "Show HN" formatı kullan.

### Title

```
Show HN: SistemBakim – 69-module Windows maintenance toolkit in a single 338 KB EXE
```

### Body

```
I built a Windows 10/11 system maintenance tool with 69 modules — cleaning, privacy, gaming optimization, network diagnostics, and more.

The interesting technical bits:

- Single PowerShell 5.1 script (8,900 lines) compiled to EXE via ps2exe
- Backend is GZip-compressed, Base64-encoded, and embedded as a data blob in the GUI script. Direct concatenation doesn't work because ps2exe's -noConsole flag turns Write-Host into MessageBox calls. Embedding as compressed data and extracting at runtime sidesteps this entirely.
- WPF XAML GUI runs in STA mode. Backend executes as a hidden child process, streaming output to a temp log file. GUI reads it via 500ms DispatcherTimer — the UI thread never blocks.
- $global: scope is required (not $script:) because WPF event handlers use .GetNewClosure() which isolates $script: variables across the closure boundary.
- Registry Uninstall keys (HKLM + WOW6432Node + HKCU) instead of Win32_Product, which triggers MSI reconfiguration on every WMI query.
- RAM optimization uses NtSetSystemInformation P/Invoke to purge the standby memory list.

Safety mechanisms: 21 services are hardcoded as protected (no profile can disable them), registry operations create .reg backups, context menu shell extensions use safe rename instead of deletion, startup delay uses Task Scheduler instead of entry removal.

No internet required, no telemetry, no dependencies. 338 KB GUI, 486 KB CLI.

GitHub: https://github.com/erdiyim/SistemBakim
```

---

## Posting Checklist

- [ ] Reddit: Post to r/Windows11, r/pcmasterrace ilk. Yanıt gelirse r/sysadmin ve r/opensource'a da at.
- [ ] Product Hunt: Pazartesi veya Salı günü 00:01 PST'de yayınla (en yüksek görünürlük).
- [ ] Hacker News: "Show HN" prefiksi ile gönder. Hafta içi öğle saatlerinde (US East) en iyi sonuç verir.
- [ ] GitHub: Release notes'u yayınla, README "Sponsor" butonunu aktif et.
- [ ] Twitter/X: Reddit post linkini paylaşarak cross-traffic oluştur.

---

## Hashtags & Keywords

```
#Windows11 #Windows10 #SystemOptimizer #OpenSource #PowerShell
#FPSBoost #PCOptimization #Gaming #Privacy #FreeSoftware
#CCleaner #Alternative #SingleEXE #NoBloat #ZeroDependencies
```

---

*Bu dosya sadece dahili kullanım içindir — doğrudan yayınlanmaz.*
