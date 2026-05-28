<div align="center">

# SistemBakim v5.0 — Module Reference

### What Every Module Does Under the Hood

*Full transparency for power users — no black boxes.*

</div>

---

> **Why this document exists:** Most system optimizers hide what they do. SistemBakim is different — every registry key, every API call, every file path is documented here. You should know exactly what runs on your machine before you click "Apply."

---

## Table of Contents

1. [Temizlik & Disk (Cleaning)](#1-temizlik--disk-cleaning) — 11 modules
2. [Sistem (System)](#2-sistem-system) — 16 modules
3. [Güvenlik (Security)](#3-guvenlik-security) — 6 modules
4. [Ağ & İnternet (Network)](#4-ag--internet-network) — 6 modules
5. [Oyun & Performans (Gaming)](#5-oyun--performans-gaming) — 9 modules
6. [Donanım (Hardware)](#6-donanim-hardware) — 6 modules
7. [Raporlar & Otomasyon (Reports)](#7-raporlar--otomasyon-reports) — 6 modules
8. [Gizlilik (Privacy)](#8-gizlilik-privacy) — 5 modules
9. [Safety Guarantees](#safety-guarantees)

---

## 1. Temizlik & Disk (Cleaning)

*11 modules — disk space recovery and junk file removal.*

### #1 — Disk Analizi

Scans all mounted drives via `Get-PSDrive -PSProvider FileSystem`. Reports free/used space percentages, identifies the largest files and folders using recursive `Get-ChildItem` with size aggregation. **Read-only** — does not delete anything.

### #2 — Yinelenen Dosya (Duplicate Finder)

Computes MD5 hashes via `[System.Security.Cryptography.MD5]::Create()` on files above the `$DUP_MIN` (5 MB) threshold. Groups files by identical hash, presents duplicates for user review. Deletion requires explicit confirmation via `Onay()`.

### #3 — Kapsamli Temizlik (Deep Clean)

Scans **19 locations** for temporary and cache files:

| Location | Path |
|----------|------|
| Windows Temp | `$env:TEMP`, `C:\Windows\Temp` |
| Prefetch | `C:\Windows\Prefetch\*.pf` |
| Browser caches | Chrome, Edge, Firefox, Opera, Brave cache dirs |
| Shader caches | `$env:LOCALAPPDATA\NVIDIA\DXCache`, AMD equivalent |
| Thumbnail cache | `$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*` |
| Windows Update | `C:\Windows\SoftwareDistribution\Download` |
| Error reports | `C:\ProgramData\Microsoft\Windows\WER` |
| Delivery Opt. | `C:\Windows\SoftwareDistribution\DeliveryOptimization` |

Each file removal is wrapped in individual `try-catch`. Locked files are counted and reported at the end (`$topAtlanan` counter) rather than silently skipped.

### #5 — Crash Dump Temizle

Removes Windows crash dump files from `C:\Windows\MEMORY.DMP` and `C:\Windows\Minidump\*.dmp`. Reports space recovered.

### #6 — Shadow & Restore

Lists System Restore points via `Get-ComputerRestorePoint`. Offers cleanup of old restore points using `vssadmin delete shadows /for=C: /oldest`. Keeps the most recent restore point.

### #7 — Windows Log Temizle

Clears Windows Event Logs via `wevtutil cl <LogName>`. Uses **delta measurement** (`$onceBoy - $sonraBoy`) to report accurate space recovered, not pre-delete sizes.

### #8 — Indirilenler Analizi

Scans `$env:USERPROFILE\Downloads` for files larger than `$BUYUK_ESIK` (100 MB) and files older than 90 days. **Read-only** — lists files with sizes, does not auto-delete.

### #32 — Disk Optimize

Detects drive type (SSD vs HDD) via `Get-PhysicalDisk`. For SSDs: sends TRIM command via `Optimize-Volume -ReTrim`. For HDDs: runs defragmentation via `Optimize-Volume -Defrag`.

### #33 — WinSxS Temizle

Runs `dism /Online /Cleanup-Image /StartComponentCleanup` with optional `/ResetBase`. DISM output is **streamed line-by-line** (not swallowed) with `$LASTEXITCODE` verification. Can recover multiple GB on older installations.

### #49 — Tarayici Temizleyici (Browser Cleaner)

Targets cache, history, and cookie directories for 5 browsers:

| Browser | Cache Path |
|---------|-----------|
| Chrome | `$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache` |
| Edge | `$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache` |
| Firefox | `$env:APPDATA\Mozilla\Firefox\Profiles\*\cache2` |
| Opera | `$env:APPDATA\Opera Software\Opera Stable\Cache` |
| Brave | `$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache` |

### #55 — Bos Klasor Bulucu (Empty Folder Finder)

Recursive scan across all drives. Identifies directories with zero files (including nested empty dirs). Bulk delete with confirmation.

### #64 — Registry Temizleyici

Four-phase registry scan:

| Phase | What it scans | Registry path |
|-------|--------------|---------------|
| 1. Broken Uninstall | Programs with missing `InstallLocation` or invalid `UninstallString` | `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall` + `WOW6432Node` + `HKCU` |
| 2. Invalid SharedDLLs | DLL references pointing to non-existent files | `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SharedDLLs` |
| 3. Dead COM/ActiveX | CLSID entries with missing `InprocServer32` | `HKLM:\SOFTWARE\Classes\CLSID` |
| 4. Orphaned App Paths | App Paths pointing to non-existent executables | `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths` |

**Safety:** Creates a `.reg` backup file via `reg export` before any deletion. Double-click the backup to restore.

---

## 2. Sistem (System)

*16 modules — system repair, service management, and OS configuration.*

### #9 — Sistem Tarama (SFC/DISM)

Runs `sfc /scannow` followed by `dism /Online /Cleanup-Image /RestoreHealth`. Parses output for corruption status and repair results.

### #11 — Servis Kontrol

Lists non-Microsoft services via `Get-Service | Where-Object { $_.StartType -eq 'Automatic' }`. Cross-references with a known safe-list. Suggests disabling unnecessary services.

### #14 — Guc Plani (Power Plan)

Switches power plan via `powercfg /setactive`. Supports Balanced, High Performance, and Ultimate Performance (`powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61`).

### #42 — Windows Performans Tweaks

11 registry-based tweaks:

| Tweak | Registry Key | Value |
|-------|-------------|-------|
| Disable transparency | `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize` → `EnableTransparency` | `0` |
| Disable animations | `HKCU:\Control Panel\Desktop\WindowMetrics` → `MinAnimate` | `0` |
| Disable indexer | `HKLM:\SYSTEM\CurrentControlSet\Services\WSearch` → `Start` | `4` (Disabled) |
| Reduce menu delay | `HKCU:\Control Panel\Desktop` → `MenuShowDelay` | `0` |

All tweaks are individually reversible.

### #43 — Sanal Bellek (Virtual Memory)

Calculates optimal pagefile size based on installed RAM. Sets via `wmic computersystem set AutomaticManagedPagefile=False` and `wmic pagefileset set InitialSize=X,MaximumSize=Y`.

### #52 — Sag Tik Menu (Context Menu)

Restores Windows 11 classic context menu by setting `HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32` default value to empty string. Shell extensions are **renamed with dash prefix** (not deleted) — remove the prefix to re-enable.

### #62 — Baglam Menusu Yonetici

Manages third-party shell extensions in `HKCR:\*\shellex\ContextMenuHandlers`. Uses **safe rename** (dash prefix) instead of deletion.

### #63 — Baslangic Gecikme Yonetici (Startup Delay)

Instead of removing startup entries, creates Task Scheduler tasks with delayed triggers (`PT30S` or `PT60S`). Original startup entries are preserved — the delay just pushes them past the critical boot window.

### #65 — Program Kaldirici

Reads installed programs from registry Uninstall keys (HKLM 64-bit + WOW6432Node + HKCU) — **never uses `Win32_Product`** (which triggers MSI reconfiguration). Runs uninstall strings and cleans leftover files/registry entries.

### #66 — Yazilim Guncelleyici

Uses `winget upgrade --include-unknown` to detect outdated software. Offers batch update via `winget upgrade --all --accept-package-agreements`.

### #68 — Hizmet Konfiguratoru (Service Configurator)

Three pre-built profiles for Windows services:

| Profile | Behavior |
|---------|----------|
| **Oyun (Gaming)** | Disables: SysMain, WSearch, DiagTrack, MapsBroker, WbioSrvc. Sets Spooler to Manual. |
| **Is (Office)** | Keeps SysMain + WSearch + Spooler active. Disables telemetry. |
| **Gunluk (Daily)** | Balanced — only disables DiagTrack, RetailDemo, Fax. |

**21 protected services** are hardcoded and can never be modified by any profile:

```
WinDefend, RpcSs, EventLog, Dhcp, Dnscache, LanmanWorkstation,
LanmanServer, RpcEptMapper, LSM, Winmgmt, Schedule, ProfSvc,
BFE, CryptSvc, DcomLaunch, Power, PlugPlay, SamSs,
SecurityHealthService, wuauserv, mpssvc
```

Creates JSON backup of current service states before any change. Restore by loading the backup file.

---

## 3. Güvenlik (Security)

*6 modules — security auditing and threat detection.*

### #16 — Güvenlik Kontrol

Checks status of Windows Defender (`Get-MpComputerStatus`), Firewall (`Get-NetFirewallProfile`), and UAC (`HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System` → `EnableLUA`).

### #17 — Gelişmiş Güvenlik

Scans open ports via `Get-NetTCPConnection`, checks RDP status (`HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server` → `fDenyTSConnections`), verifies BitLocker status, and audits the hosts file.

### #39 — Hesap Denetimi

Detects local accounts with no password, expired passwords, or accounts that haven't been used. Uses `Get-LocalUser` with property inspection.

### #40 — Supheli Baslangic

Scans startup programs for unsigned executables and entries without valid digital signatures. Uses `Get-AuthenticodeSignature` to verify.

### #46 — Defender Oyun Istisna

Adds game launcher directories (Steam, Epic Games, Riot Games) to Windows Defender exclusion list via `Add-MpPreference -ExclusionPath`. Reduces Defender scan overhead during gameplay.

### #50 — OEM Bloatware Tespiti

Detects pre-installed manufacturer software (HP, Dell, Lenovo, Acer, ASUS patterns) via registry Uninstall keys. Lists for user review.

---

## 4. Ağ & İnternet (Network)

*6 modules — network diagnostics, speed testing, and optimization.*

### #15 — Ag Tanilamasi (Network Diagnostics)

Resets network stack: `netsh winsock reset`, `netsh int ip reset`, `ipconfig /flushdns`, `ipconfig /release`, `ipconfig /renew`. Tests DNS resolution and gateway connectivity.

### #35 — Internet Hiz Testi

Downloads a test payload from Cloudflare's CDN (`speed.cloudflare.com`). Measures download speed in Mbps and latency via `[System.Net.NetworkInformation.Ping]::Send()`.

### #36 — Bant Genisligi Optimize

Adjusts QoS and TCP settings: disables P2P delivery optimization (`HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization` → `DODownloadMode=0`), optimizes TCP window auto-tuning.

### #53 — DNS Benchmark

Tests 12 DNS servers with timed resolution queries:

```
Google (8.8.8.8), Cloudflare (1.1.1.1), Quad9 (9.9.9.9),
OpenDNS (208.67.222.222), AdGuard (94.140.14.14),
CleanBrowsing (185.228.168.168), and more
```

Ranks by response time, offers one-click apply for the fastest via `Set-DnsClientServerAddress`.

### #54 — WiFi Cihaz Tarama (WiFi Scanner)

Discovers devices on the local network using ARP table (`arp -a`) and `Get-NetNeighbor`. Lists IP, MAC address, and attempts hostname resolution.

### #69 — Ag Monitoru (Network Monitor)

Live bandwidth measurement using `.NET NetworkInterface.GetIPStatistics()` with delta calculation over time intervals. Lists per-app network connections via `Get-NetTCPConnection` joined with `Get-Process`. Scans listening ports.

---

## 5. Oyun & Performans (Gaming)

*9 modules — FPS optimization and gaming tweaks.*

### #26 — FPS Optimizasyon (11 Tweaks)

All tweaks are registry-based and individually reversible:

| # | Tweak | Registry Path | Optimized Value |
|---|-------|--------------|----------------|
| 1 | Game DVR off | `HKCU:\System\GameConfigStore` → `GameDVR_Enabled` | `0` |
| 2 | MMCSS priority | `HKLM:\...\Multimedia\SystemProfile` → `SystemResponsiveness` | `0` |
| 3 | Network throttling | Same path → `NetworkThrottlingIndex` | `0xFFFFFFFF` |
| 4 | Nagle disabled | Per-interface under `HKLM:\...\Interfaces\{GUID}` → `TcpAckFrequency` + `TCPNoDelay` | `1` |
| 5 | HAGS enabled | `HKLM:\SYSTEM\...\GraphicsDrivers` → `HwSchMode` | `2` |
| 6 | Visual effects | `SystemPropertiesPerformance.exe` preset | Best Performance |
| 7 | Mouse raw input | `HKCU:\Control Panel\Mouse` → `MouseSpeed` | `0` |
| 8 | Power plan | `powercfg /setactive` | Ultimate Performance |
| 9 | Background apps | `HKCU:\...\BackgroundAccessApplications` → `GlobalUserDisabled` | `1` |
| 10 | FSO disabled | `HKCU:\System\GameConfigStore` → `GameDVR_FSEBehaviorMode` | `2` |
| 11 | Transparency off | `HKCU:\...\Themes\Personalize` → `EnableTransparency` | `0` |

### #27 — RAM Optimizasyon

Two-stage memory optimization:

1. **Working Set Trim** — Iterates all processes via `Get-Process`, triggers `MinWorkingSet` reset to release unused committed memory
2. **Standby List Purge** — Calls `NtSetSystemInformation` (via P/Invoke) with `SystemMemoryListInformation` class to clear the standby page list

Shows before/after comparison with exact MB freed.

### #28 — Surec Temizleyici

Terminates known resource-heavy background processes before gaming sessions. Uses a curated process list (OneDrive, Teams, Cortana, etc.). Excludes critical system processes.

### #29 — Bloatware Kaldirici

Removes 35+ pre-installed Windows apps via `Get-AppxPackage | Remove-AppxPackage`:

```
Microsoft.Xbox*, Microsoft.GetHelp, Clipchamp, Microsoft.People,
Microsoft.BingWeather, Microsoft.ZuneMusic, Microsoft.549981C3F5F10 (Cortana), etc.
```

### #41 — Format Sonrasi Sihirbazi

Runs 11 optimization steps sequentially after a fresh Windows install: privacy settings, power plan, visual effects, bloatware removal, driver check, Windows Update, and more.

### #45 — GPU Optimize

Cleans shader caches for NVIDIA (`$env:LOCALAPPDATA\NVIDIA\DXCache`, `$env:LOCALAPPDATA\NVIDIA\GLCache`) and AMD (`$env:LOCALAPPDATA\AMD\DxCache`). Applies GPU-specific registry tweaks.

### #48 — Hyper-V / VBS Kapat

Disables Virtualization-Based Security and Hyper-V for gaming performance (5-15% FPS improvement):

```
bcdedit /set hypervisorlaunchtype off
HKLM:\SYSTEM\...\DeviceGuard → EnableVirtualizationBasedSecurity = 0
```

**Warning:** This reduces security isolation. Module clearly warns the user before applying.

### #61 — Turbo Boost

One-click composite optimization:
1. RAM Working Set trim
2. Kill non-essential background processes
3. Set Ultimate Performance power plan
4. Disable visual animations
5. Stop Windows Search indexer temporarily

All changes are session-temporary — restart restores defaults.

---

## 6. Donanım (Hardware)

*6 modules — hardware diagnostics and health monitoring.*

### #4 — SMART Disk Sagligi

Reads S.M.A.R.T. attributes via `Get-PhysicalDisk` and `Get-StorageReliabilityCounter`. Reports temperature, power-on hours, reallocated sectors, and overall health status.

### #19 — Donanim Raporu

Comprehensive hardware inventory: BIOS info (`Get-WmiObject Win32_BIOS`), USB devices (`Get-PnpDevice`), thermal info, power/battery status, installed RAM modules.

### #34 — Pil Sagligi (Battery Health)

Generates battery report via `powercfg /batteryreport`. Parses HTML output for design capacity vs. full charge capacity, calculates wear percentage.

### #44 — Donanim Skoru

Benchmarks CPU (prime calculation), RAM (sequential read/write speed), GPU (DirectX feature level), and disk (sequential read via `[System.IO.File]::ReadAllBytes`). Provides upgrade recommendations based on bottleneck analysis.

### #47 — Monitor Hz

Checks current refresh rate via `Get-CimInstance Win32_VideoController`. Alerts if monitor is running below its maximum capable refresh rate. Reports DPI scaling settings.

### #18 — Gelistirici Araclari

Cleans development tool caches: Node.js (`npm cache`), Docker (`docker system prune` data), NuGet, pip, and .NET temporary files.

---

## 7. Raporlar & Otomasyon (Reports)

*6 modules — health scoring, reporting, and automation.*

### #20 — HTML Dashboard

Generates a visual HTML report with system overview, opens in default browser. Collects data from `$global:RaporVerisi` accumulated during the session.

### #21 — Saglik Skoru (Health Score)

100-point scoring system with weighted categories:

| Category | Max Points | What it measures |
|----------|-----------|-----------------|
| Disk Space | 20 | Free space percentage |
| RAM Usage | 15 | Current utilization |
| Startup Programs | 15 | Count of auto-start entries |
| Windows Updates | 15 | Pending update count |
| Security | 20 | Defender + Firewall + UAC status |
| System Integrity | 15 | SFC scan results |

### #22 — Haftalik Zamanla (Weekly Scheduler)

Creates a Task Scheduler task via `Register-ScheduledTask` that runs specified maintenance modules weekly. Uses `-RunLevel Highest` for admin-required modules.

### #23 — Profil Sec

Pre-built maintenance profiles: Gaming Pre-Session, Weekly Maintenance, Quick Scan. Each runs a curated set of modules in sequence.

### #24 — Geri Yukleme Noktasi

Creates a System Restore point via `Checkpoint-Computer -Description "SistemBakim"`. Safety net before major system changes.

### #25 — TAM BAKIM (Full Maintenance)

Runs all core maintenance modules sequentially: Deep Clean → Log Clean → Registry Clean → WinSxS → RAM Optimize → Health Score. Shows cumulative before/after results.

---

## 8. Gizlilik (Privacy)

*5 modules — privacy hardening and data protection.*

### #56 — Dosya Kirpici (File Shredder)

3-pass secure deletion algorithm:

```
Pass 1: Random bytes (RNGCryptoServiceProvider, 64KB buffer)
Pass 2: Zero fill
Pass 3: Random bytes again
Final:  File rename to random string → delete
```

Uses `[System.IO.File]::Open()` with direct stream writing. File is renamed before deletion to prevent filename recovery.

### #57 — USB Cihaz Gecmisi

Reads USB device history from `HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR`. Lists all previously connected USB devices with serial numbers, timestamps, and device descriptions. Optional cleanup of stale entries.

### #58 — Hosts Dosyasi Editoru

Adds 40+ known ad, tracker, and telemetry domains to `C:\Windows\System32\drivers\etc\hosts` file, pointing them to `0.0.0.0`. Flushes DNS cache via `ipconfig /flushdns` after modification.

### #59 — Zamanlama Gorevi Temizle

Scans Task Scheduler for broken tasks (missing executables, disabled tasks from uninstalled programs). Uses `Get-ScheduledTask` with status filtering.

### #60 — Gizlilik Kalkani (Privacy Shield)

**25 privacy toggles** — each is a registry key that can be toggled on/off:

| Toggle | Registry Path | Off Value |
|--------|--------------|-----------|
| Advertising ID | `HKCU:\...\AdvertisingInfo` → `Enabled` | `0` |
| Location Services | `HKLM:\...\ConsentStore\location` → `Value` | `Deny` |
| Camera Access | `HKLM:\...\ConsentStore\webcam` → `Value` | `Deny` |
| Microphone Access | `HKLM:\...\ConsentStore\microphone` → `Value` | `Deny` |
| Diagnostic Data | `HKLM:\...\DataCollection` → `AllowTelemetry` | `0` |
| Activity History | `HKLM:\...\System` → `EnableActivityFeed` | `0` |
| Online Speech | `HKCU:\...\OnlineSpeechPrivacy` → `HasAccepted` | `0` |
| Wi-Fi Sense | `HKLM:\...\wifinetworkmanager` → `AutoConnectAllowedOEM` | `0` |
| SmartScreen (App) | `HKCU:\...\Explorer` → `SmartScreenEnabled` | `Off` |
| Web Search (Start) | `HKCU:\...\Explorer` → `DisableSearchBoxSuggestions` | `1` |
| App Launch Tracking | `HKCU:\...\Explorer\Advanced` → `Start_TrackProgs` | `0` |
| Tailored Experiences | `HKCU:\...\Privacy` → `TailoredExperiencesWithDiagnosticDataEnabled` | `0` |
| Cross-Device Sharing | `HKLM:\...\System` → `EnableCdp` | `0` |
| + 12 more | Contacts, Calendar, Email, Notifications, etc. | `Deny` / `0` |

Each toggle shows current status (green/red) and can be flipped individually or all at once.

---

## Safety Guarantees

Every module in SistemBakim follows these safety principles:

| Mechanism | What it protects | Applied in |
|-----------|-----------------|------------|
| **21-service protection list** | Prevents BSOD from disabling critical services | Module #68 (Service Configurator) |
| **`.reg` backup before delete** | Reversible registry changes | Module #64 (Registry Cleaner) |
| **Rename-with-dash (not delete)** | Shell extension preservation | Modules #52, #62 (Context Menu) |
| **Task Scheduler delay (not removal)** | Startup program preservation | Module #63 (Startup Delay) |
| **`Onay()` confirmation gate** | Prevents accidental destructive operations | All destructive modules |
| **3-pass shredding** | Complete secure deletion | Module #56 (File Shredder) |
| **Delta measurement** | Accurate space reporting | Modules #3, #7, #33 |
| **JSON backup** | Service state restoration | Module #68 (Service Configurator) |
| **3-second grace period** | Prevents false crash reports | GUI process management |

---

<div align="center">

*Every line of code is open source. If something isn't documented here, read the source — it's all in one file.*

**[SistemBakim_v5.ps1](../src/SistemBakim_v5.ps1)** — 8,900+ lines, 69 modules, zero secrets.

</div>
