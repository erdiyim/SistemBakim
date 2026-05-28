<div align="center">

# SistemBakim — Ready-to-Use Response Templates

### Kopyala-Yapistir Hazir Yanit Sablonlari

*Her yanit EN (English) ve TR (Turkce) olarak verilmistir.*

</div>

---

## Icindekiler

1. [SmartScreen / Virus Uyarisi](#1-smartscreen--virus-uyarisi)
2. [Registry / Servis Bozuldu — Geri Alma](#2-registry--servis-bozuldu--geri-alma)
3. [Ozellik Istegi / UI Onerisi](#3-ozellik-istegi--ui-onerisi)
4. [Uygulama Acilmiyor / Crash](#4-uygulama-acilmiyor--crash)
5. [Hangi Moduller Guvenli?](#5-hangi-moduller-guvenli)
6. [Veri Toplaniyor mu / Telemetri](#6-veri-toplaniyor-mu--telemetri)
7. [Win10 / Win11 Uyumluluk](#7-win10--win11-uyumluluk)
8. [Tesekkur ve Yildiz Istegi](#8-tesekkur-ve-yildiz-istegi)
9. [Duplicate / Tekrar Eden Issue](#9-duplicate--tekrar-eden-issue)
10. [Dil Destegi / Ingilizce UI](#10-dil-destegi--ingilizce-ui)

---

## 1. SmartScreen / Virus Uyarisi

> Kullanici: "SmartScreen uyari verdi, bu guvenli mi?" / "VirusTotal'da flag var!"

### English

```
Thanks for asking — this is a completely valid concern!

The SmartScreen warning appears because SistemBakim doesn't have an EV Code Signing 
Certificate ($400+/year). As a free, open-source project, that's not feasible right now. 
This warning has nothing to do with the app's safety — it simply means Microsoft hasn't 
seen enough installations to "trust" the binary yet. Tools like Rufus, Ventoy, and 
HWiNFO portable trigger the exact same warning.

Here's why you can trust SistemBakim:

✅ 100% open source — every line of the 8,900-line codebase is on GitHub
✅ Zero internet connection — the app never contacts any server
✅ Zero telemetry — no tracking, no analytics, no data collection
✅ Reproducible build — you can clone the repo and build from source yourself:

   git clone https://github.com/erdi/SistemBakim.git
   cd SistemBakim/src
   echo "" | powershell -NoProfile -ExecutionPolicy Bypass -File "Build-EXE.ps1"

To bypass SmartScreen: Click "More info" → "Run anyway"

If you uploaded to VirusTotal and saw 1-2 flags: this is a known false positive with 
ps2exe-compiled PowerShell scripts. The major engines (Microsoft, Kaspersky, ESET, 
Bitdefender) all report it as clean.
```

### Turkce

```
Sordugunuz icin tesekkurler — cok anlasilir bir endise!

SmartScreen uyarisi, SistemBakim'in EV Code Signing Sertifikasi (yillik $400+) 
olmadigi icin cikiyor. Ucretsiz ve acik kaynakli bir proje olarak bunu su an 
karsilayamiyoruz. Bu uyari uygulamanin guvenligi ile HICBIR ilgisi yoktur — 
sadece Microsoft'un bu dosyayi henuz yeterince "tanimadigi" anlamina gelir. 
Rufus, Ventoy, HWiNFO gibi araclar da ayni uyariyi verir.

SistemBakim'e neden guvenebilirsiniz:

✅ %100 acik kaynak — 8.900 satirlik kodun tamami GitHub'da gorulebilir
✅ Sifir internet baglantisi — hicbir sunucuyla iletisim kurmaz
✅ Sifir telemetri — izleme, analitik veya veri toplama yoktur
✅ Kendiniz derleyebilirsiniz — kaynak kodu klonlayip dogrulayabilirsiniz

Gecmek icin: "Ek bilgi" → "Yine de calistir" tiklayin.

VirusTotal'da 1-2 flag gorduyseniz: ps2exe ile derlenmis PowerShell scriptlerinde 
bilinen bir false positive'dir. Buyuk motorlar (Microsoft, Kaspersky, ESET, 
Bitdefender) hepsinde temiz cikar.
```

---

## 2. Registry / Servis Bozuldu — Geri Alma

> Kullanici: "Registry temizleyiciden sonra X programim calismıyor!" / "Servisleri degistirdim, sistemim yavasladı!"

### English

```
Don't worry — SistemBakim creates backups before every destructive operation. 
Here's how to restore:

**Registry Cleaner (Module #64):**
1. Open: `%USERPROFILE%\Desktop\BakimRaporlari\`
2. Find the file: `RegistryYedek_YYYYMMDD_HHMM.reg`
3. Double-click it → Click "Yes" when prompted
4. Restart your computer
→ All deleted registry entries will be restored to their original state.

**Service Configurator (Module #68):**
1. Open: `%USERPROFILE%\Desktop\BakimRaporlari\`
2. Find the file: `HizmetYedek_YYYYMMDD_HHMM.json`
3. Open PowerShell as Administrator
4. For each service you want to restore, run:
   Set-Service -Name "ServiceName" -StartupType Automatic
   (Replace "ServiceName" and "Automatic" with the values from the JSON file)

**FPS Optimizer (Module #26):**
1. Open SistemBakim → Module #26 (FPS Optimizer)
2. Select option [2] "Reverse optimizations"
→ All 11 tweaks will be individually reverted to Windows defaults.

**System Restore (if all else fails):**
If you created a restore point (Module #24) before making changes:
1. Press Win+R → type `rstrui.exe` → Enter
2. Select the restore point dated before your changes
3. Follow the wizard

If none of the above helps, please open a bug report with:
- Your Windows version
- Which module you used
- The error or symptom you're seeing
- The backup file contents (if available)

We'll help you fix it. 🔧
```

### Turkce

```
Endiselenmeyin — SistemBakim her yikici islemden once otomatik yedek olusturur.
Geri almak icin:

**Registry Temizleyici (Modul #64):**
1. Su klasoru acin: `%USERPROFILE%\Desktop\BakimRaporlari\`
2. `RegistryYedek_YYYYMMDD_HHMM.reg` dosyasini bulun
3. Cift tiklayin → "Evet" deyin
4. Bilgisayari yeniden baslatin
→ Silinen tum registry girisleri eski haline donecektir.

**Hizmet Konfiguratoru (Modul #68):**
1. `%USERPROFILE%\Desktop\BakimRaporlari\` klasorunu acin
2. `HizmetYedek_YYYYMMDD_HHMM.json` dosyasini bulun
3. PowerShell'i yonetici olarak acin
4. Her servis icin: Set-Service -Name "ServisAdi" -StartupType Automatic
   (JSON dosyasindaki degerleri kullanin)

**FPS Optimizer (Modul #26):**
1. SistemBakim'i acin → Modul #26
2. [2] "Geri Al" secenegini tiklayin
→ 11 tweak'in tamami Windows varsayilanlarina doner.

**Sistem Geri Yukleme (hicbiri islemediyse):**
Degisikliklerden once geri yukleme noktasi olusturduysaniz (Modul #24):
1. Win+R → `rstrui.exe` yazin → Enter
2. Degisikliklerden onceki tarihi secin

Bunlarin hicbiri ise yaramadiysa, lutfen bir bug report acin — yardim edecegiz. 🔧
```

---

## 3. Ozellik Istegi / UI Onerisi

> Kullanici: "Su ozellik eklenirse harika olur!" / "UI boyle olsa daha iyi"

### English

```
Thank you for the suggestion — I really appreciate you taking the time to share this!

To make sure your idea gets properly tracked and doesn't get lost in the comments, 
could you open a Feature Request on GitHub? There's a structured template that helps 
me understand the context better:

👉 https://github.com/erdi/SistemBakim/issues/new?template=feature_request.yml

This way I can:
- Properly categorize and prioritize it
- Link related requests together
- Update you when it's being worked on

Your feedback directly shapes the roadmap — every feature in v5.0 started as 
a suggestion like yours. 🙏
```

### Turkce

```
Oneriniz icin cok tesekkur ederim — geri bildirimler projeyi sekillendiren 
en degerli sey!

Bu fikrin kaybolmamasi ve duzgun takip edilebilmesi icin bunu GitHub'da bir 
Feature Request olarak acar misiniz? Hazir bir sablon var:

👉 https://github.com/erdi/SistemBakim/issues/new?template=feature_request.yml

Boylece:
- Doğru kategoriye koyup onceliklendiriyorum
- Benzer istekleri birlestiriyorum
- Uzerinde calisildiginda sizi bilgilendiriyorum

v5.0'daki her ozellik sizin gibi kullanicilarin onerileriyle basladi. 🙏
```

---

## 4. Uygulama Acilmiyor / Crash

> Kullanici: "Uygulama acilmiyor!" / "Hemen kapaniyor!"

### English

```
Sorry you're running into this! Let's figure it out.

Could you try these quick checks:

1. **Run as Administrator** — Right-click → "Run as Administrator". Most modules 
   need admin privileges, and the app may silently fail without them.

2. **Check your Windows version** — SistemBakim requires Windows 10 or 11 (64-bit). 
   Run `winver` to verify.

3. **Try the CLI version** — Download `SistemBakim_CLI.exe` from the same Release page. 
   If this works but the GUI doesn't, it's a WPF rendering issue and helps narrow 
   down the problem.

4. **Check for antivirus blocking** — Some AV software may quarantine ps2exe-compiled 
   apps. Check your AV quarantine/log.

5. **Check the log folder** — Look in `%USERPROFILE%\Desktop\BakimRaporlari\` for 
   any log files that might contain error details.

If none of these help, please open a bug report with:
- Your exact Windows version (run `winver`)
- Whether you ran as Administrator
- Any error message you see (screenshot helps!)
- Whether the CLI version works

👉 https://github.com/erdi/SistemBakim/issues/new?template=bug_report.yml
```

### Turkce

```
Bu durumla karsilasmis olmaniz icin uzgunum! Hemen cozelim.

Su kontrolleri yapar misiniz:

1. **Yonetici olarak calistirin** — Sag tik → "Yonetici olarak calistir". 
   Cogu modul admin yetkisi gerektirir.

2. **Windows surumunuzu kontrol edin** — Win10 veya Win11 (64-bit) gerekli. 
   `winver` komutuyla dogrulayin.

3. **CLI surumunu deneyin** — `SistemBakim_CLI.exe` dosyasini indirin. Bu 
   calisip GUI calismiyorsa WPF render sorunu demektir.

4. **Antivirus kontrolu** — Bazi antivirusler ps2exe dosyalarini engelleyebilir. 
   Karantina logunu kontrol edin.

5. **Log klasorunu kontrol edin** — `%USERPROFILE%\Desktop\BakimRaporlari\` 
   icinde hata detaylari olabilir.

Bunlar ise yaramadiysa, lutfen bug report acin:
👉 https://github.com/erdi/SistemBakim/issues/new?template=bug_report.yml
```

---

## 5. Hangi Moduller Guvenli?

> Kullanici: "Hangi modulleri guvenle kullanabilirim?" / "Sistemi bozar mi?"

### English

```
Great question! SistemBakim is designed with a "do no harm" principle. Here's the 
safety breakdown:

🟢 **Always safe (read-only, no system changes):**
Disk Analysis (#1), Duplicate Finder (#2), SMART Disk (#4), Downloads Analysis (#8), 
Event Log Viewer (#10), Resource Monitor (#13), Hardware Report (#19), Health Score (#21), 
Battery Health (#34), Internet Speed Test (#35), DNS Benchmark (#53), WiFi Scanner (#54), 
Network Monitor (#69)

🟡 **Safe with automatic backups (reversible):**
Deep Clean (#3), Registry Cleaner (#64), FPS Optimizer (#26), Service Configurator (#68), 
Context Menu (#52, #62), Privacy Shield (#60)
→ These all create backups (.reg files or JSON) before making changes

🔴 **Requires attention (destructive by design):**
File Shredder (#56) — 3-pass secure delete, files CANNOT be recovered
Bloatware Remover (#29) — removes Windows apps permanently
→ These modules always ask for explicit confirmation via Onay() dialog

Every module that makes system changes has a built-in reversal mechanism. 
Full technical documentation: https://github.com/erdi/SistemBakim/blob/main/docs/MODULES.md
```

---

## 6. Veri Toplaniyor mu / Telemetri

> Kullanici: "Bu uygulama veri topluyor mu?"

### English

```
No. Zero telemetry, zero analytics, zero data collection. Period.

SistemBakim does not connect to the internet for any reason except one optional check: 
on startup, it queries the GitHub Releases API to check if a newer version exists. 
This is a single GET request to api.github.com, runs in a background job, times out 
in 6 seconds, and contains no user data — only the app version string.

You can verify this yourself:
- The source code is fully open: https://github.com/erdi/SistemBakim
- Search for any network call in the code — you'll only find the update check
- The app works perfectly fine without any internet connection

No accounts, no registration, no cloud sync, no "anonymous usage statistics."
```

---

## 7. Win10 / Win11 Uyumluluk

> Kullanici: "Windows 10'da calisiyor mu?" / "Win11 24H2'de sorun var mi?"

### English

```
SistemBakim is tested on both Windows 10 (22H2) and Windows 11 (23H2, 24H2). 
Both 64-bit only — 32-bit is not supported.

If you're running into a version-specific issue, please open a bug report and 
include your exact Windows version (run `winver` to check). Some modules behave 
slightly differently between Win10/11 — for example, the classic context menu 
restore (#52) only applies to Windows 11.

Minimum requirements:
- Windows 10 or 11 (64-bit)
- PowerShell 5.1 (built into Windows — no install needed)
- Administrator privileges
```

---

## 8. Tesekkur ve Yildiz Istegi

> Pozitif yorum geldiginde — momentum icin nazikce star isteme

### English

```
Thank you so much — comments like this make the late nights worth it! 🙏

If SistemBakim saved you some time (or disk space!), a GitHub star would really 
help others discover it: https://github.com/erdi/SistemBakim

And if you run into anything weird, don't hesitate to open an issue. 
Happy optimizing! ⚡
```

### Turkce

```
Cok tesekkur ederim — boyle yorumlar gece mesailerini anlamli kiliyor! 🙏

SistemBakim size zaman (veya disk alani!) kazandirdiysa, GitHub'da bir yildiz 
birakmak baskalarinin da kesfedemasine yardimci olur: 
https://github.com/erdi/SistemBakim

Herhangi bir sorun yasarsaniz issue acmaktan cekinmeyin. 
Kolay gelsin! ⚡
```

---

## 9. Duplicate / Tekrar Eden Issue

> Daha once bildirilen bir bug/istek tekrar acildiginda

### English

```
Thanks for reporting this! This is a known issue that's already being tracked in #XX.

I'm closing this as a duplicate to keep the discussion in one place. 
Please follow #XX for updates — I'll post there when there's progress.

If your case is different from what's described in #XX, feel free to reopen 
this issue with the additional details.
```

---

## 10. Dil Destegi / Ingilizce UI

> Kullanici: "Turkce anlamiyorum, Ingilizce olsa..." / "Will there be English UI?"

### English

```
English language support is on the roadmap! Currently the UI is in Turkish, 
but all module names and most technical terms are recognizable.

If you'd like to contribute translations, that would be amazing — it's listed 
as a contribution area in the README:
https://github.com/erdi/SistemBakim#contributing

For now, the full module documentation in English is available here:
https://github.com/erdi/SistemBakim/blob/main/docs/MODULES.md
```

---

<div align="center">

*Bu sablonlari duruma gore kucuk duzenlemelerle kullanin.
Kisisel dokunuslar (kullanicinin adini kullanmak vb.) etkiyi artirir.*

</div>
