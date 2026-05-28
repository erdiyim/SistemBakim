<div align="center">

# SistemBakim v5.0 — The Ultimate Release

### Everything your PC needs. Nothing it doesn't.

*27 Mayis 2026*

</div>

---

## What's New in v5.0

This isn't an incremental update — it's a ground-up rebuild. **69 modules**, a completely new dark-themed WPF interface, professional installer, and a level of polish that makes SistemBakim a serious contender against tools 10x its size.

---

### New Modules

| # | Module | Category | Highlights |
|---|--------|----------|------------|
| 60 | **Startup Delay Manager** | Performance | Delays startup apps by 30-60s via Task Scheduler — faster boot without losing anything |
| 61 | **DNS Benchmark** | Network | Tests 12 DNS servers, finds the fastest, applies with one click |
| 62 | **WiFi Scanner** | Network | Discovers all devices on your local network |
| 63 | **Internet Speed Test** | Network | Download speed + ping via Cloudflare endpoint |
| 64 | **File Shredder** | Security | 3-pass secure delete (random-zero-random), 64KB buffer, file rename before removal |
| 65 | **USB History** | Security | Scans USBSTOR registry for all connected USB devices, optional cleanup |
| 66 | **Hosts Editor** | Privacy | Blocks 40+ ad/tracker/telemetry domains via hosts file with DNS flush |
| 67 | **HTML Dashboard** | Reports | Visual health report that opens in your default browser |
| 68 | **Service Configurator** | Performance | Gaming / Office / Daily profiles for Windows services. 21 critical services protected, JSON backup |
| 69 | **Network Monitor** | Network | Live bandwidth via .NET NetworkInterface, per-app connections, open port scan |

---

### New GUI Features

- **Before/After Comparison**
  Every operation now shows a visual overlay with disk space and RAM deltas. You see exactly what changed — down to the megabyte.

- **Dark / Light Theme Toggle**
  Switch between dark and light mode from the sidebar. Your preference is saved and persists across sessions.

- **Disk Treemap**
  A WinDirStat-style visual block map of your drive, built right into the app. Files under 50MB are grouped to keep the view clean. Color-coded by file type.

- **Export System**
  One-click HTML + TXT report export from any scan result. Reports land on your Desktop in the `BakimRaporlari` folder.

- **Smart Scan Wizard**
  A guided 4-step wizard that runs the most common maintenance tasks in sequence — perfect for users who just want to click one button and walk away.

---

### Improvements

- **Deep Clean** now reports locked files instead of silently skipping them. You'll see exactly how many files couldn't be removed and why.
- **Windows Log Cleaner** uses proper delta measurement (`before - after`) instead of reporting pre-delete sizes. Numbers you see are now accurate.
- **WinSxS Cleanup** streams DISM output in real-time instead of running silently. No more staring at a blank screen for 15 minutes.
- **Process management** now includes a 3-second grace period for backend exit, eliminating false "process crashed" errors during transcript flush.
- **Registry Cleaner** creates `.reg` backup files before any deletion — double-click to restore if anything goes wrong.
- **FPS Optimizer** expanded to 11 tweaks: GameDVR, MMCSS priority, Nagle algorithm, HAGS, mouse raw input, power plan, transparency — all individually reversible.
- **Privacy Shield** expanded to 25 toggles covering AdvertisingID, Location, Camera, Microphone, Telemetry, Timeline, Speech, WiFi Sense, and more.

---

### Architecture

- **GZip + Base64 embedding** — Backend is compressed and embedded as a data blob inside the GUI script, then extracted at runtime. This avoids the `Write-Host → MessageBox` bug that occurs with direct concatenation in `-noConsole` mode.
- **Separate process execution** — Backend runs as a hidden child PowerShell process. Output streams to a temp log file. GUI reads it via 500ms DispatcherTimer — the UI thread never blocks.
- **`$global:` scope by design** — WPF event handlers use `.GetNewClosure()` which isolates `$script:` variables. Only `$global:` survives the closure boundary.
- **Registry over WMI** — Uses Uninstall registry keys (HKLM 64-bit + WOW6432Node + HKCU) instead of `Win32_Product`, which triggers MSI reconfiguration on every query. 100x faster.

---

### Safety

Every optimization in SistemBakim is designed to be reversible:

- **21 critical services** (WinDefend, RpcSs, EventLog, etc.) are hardcoded as untouchable — no profile can disable them
- **Registry operations** always create `.reg` backups before deletion
- **Context menu cleanup** uses rename-with-dash instead of deletion — remove the prefix to re-enable
- **Startup management** delays apps via Task Scheduler instead of removing entries — originals are preserved
- **Destructive operations** require explicit confirmation via `Onay()` gate
- **Secure deletion** uses 3-pass overwrite — no half-measures

---

### Installer

New professional Inno Setup installer:

- Admin privileges with UAC prompt
- 64-bit only (32-bit blocked with clear message)
- LZMA2/Ultra64 compression
- Turkish + English language support
- Desktop and Start Menu shortcuts with custom icon
- Clean uninstall via Settings > Apps
- Optional checkbox to remove user data (settings, logs, backups)
- Pre-install kills any running instance automatically

---

### Numbers

| Metric | Value |
|--------|-------|
| Total modules | 69 |
| Backend lines | 8,900+ |
| GUI lines | 2,400+ |
| GUI EXE size | 338 KB |
| CLI EXE size | 486 KB |
| Dependencies | 0 |
| Internet required | No |
| Supported OS | Windows 10 / 11 (64-bit) |

---

### Requirements

- Windows 10 or 11 (64-bit)
- Administrator privileges
- ~5 MB disk space
- No .NET install needed — PowerShell 5.1 is built into Windows

---

<div align="center">

**Built with obsession by [Erdi](https://github.com/erdiyim) + [Claude](https://claude.ai)**

[Download v5.0](https://github.com/erdiyim/SistemBakim/releases/latest)

</div>
