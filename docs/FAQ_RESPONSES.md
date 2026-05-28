<div align="center">

# SistemBakim — Ready-to-Use Response Templates

### Kopyala-Yapıştır Hazır Yanıt Şablonları

*Her yanıt EN (English) ve TR (Türkçe) olarak verilmiştir.*

</div>

---

## İçindekiler

1. [SmartScreen / Virüs Uyarısı](#1-smartscreen--virüs-uyarısı)
2. [Registry / Servis Bozuldu — Geri Alma](#2-registry--servis-bozuldu--geri-alma)
3. [Özellik İsteği / UI Önerisi](#3-özellik-isteği--ui-önerisi)
4. [Uygulama Açılmıyor / Crash](#4-uygulama-açılmıyor--crash)
5. [Hangi Modüller Güvenli?](#5-hangi-modüller-güvenli)
6. [Veri Toplanıyor mu / Telemetri](#6-veri-toplanıyor-mu--telemetri)
7. [Win10 / Win11 Uyumluluk](#7-win10--win11-uyumluluk)
8. [Teşekkür ve Yıldız İsteği](#8-teşekkür-ve-yıldız-isteği)
9. [Duplicate / Tekrar Eden Issue](#9-duplicate--tekrar-eden-issue)
10. [Dil Desteği / İngilizce UI](#10-dil-desteği--ingilizce-ui)

---

## 1. SmartScreen / Virüs Uyarısı

> Kullanıcı: "SmartScreen uyarı verdi, bu güvenli mi?" / "VirusTotal'da flag var!"

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

   git clone https://github.com/erdiyim/SistemBakim.git
   cd SistemBakim/src
   echo "" | powershell -NoProfile -ExecutionPolicy Bypass -File "Build-EXE.ps1"

To bypass SmartScreen: Click "More info" → "Run anyway"

If you uploaded to VirusTotal and saw 1-2 flags: this is a known false positive with 
ps2exe-compiled PowerShell scripts. The major engines (Microsoft, Kaspersky, ESET, 
Bitdefender) all report it as clean.
```

### Türkçe

```
Sorduğunuz için teşekkürler — çok anlaşılır bir endişe!

SmartScreen uyarısı, SistemBakim'in EV Code Signing Sertifikası (yıllık $400+) 
olmadığı için çıkıyor. Ücretsiz ve açık kaynaklı bir proje olarak bunu şu an 
karşılayamıyoruz. Bu uyarının uygulamanın güvenliği ile HİÇBİR ilgisi yoktur — 
sadece Microsoft'un bu dosyayı henüz yeterince "tanımadığı" anlamına gelir. 
Rufus, Ventoy, HWiNFO gibi araçlar da aynı uyarıyı verir.

SistemBakim'e neden güvenebilirsiniz:

✅ %100 açık kaynak — 8.900 satırlık kodun tamamı GitHub'da görülebilir
✅ Sıfır internet bağlantısı — hiçbir sunucuyla iletişim kurmaz
✅ Sıfır telemetri — izleme, analitik veya veri toplama yoktur
✅ Kendiniz derleyebilirsiniz — kaynak kodu klonlayıp doğrulayabilirsiniz

Geçmek için: "Ek bilgi" → "Yine de çalıştır" tıklayın.

VirusTotal'da 1-2 flag gördüyseniz: ps2exe ile derlenmiş PowerShell scriptlerinde 
bilinen bir false positive'dir. Büyük motorlar (Microsoft, Kaspersky, ESET, 
Bitdefender) hepsinde temiz çıkar.
```

---

## 2. Registry / Servis Bozuldu — Geri Alma

> Kullanıcı: "Registry temizleyiciden sonra X programım çalışmıyor!" / "Servisleri değiştirdim, sistemim yavaşladı!"

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

We'll help you fix it.
```

### Türkçe

```
Endişelenmeyin — SistemBakim her yıkıcı işlemden önce otomatik yedek oluşturur.
Geri almak için:

**Registry Temizleyici (Modül #64):**
1. Şu klasörü açın: `%USERPROFILE%\Desktop\BakimRaporlari\`
2. `RegistryYedek_YYYYMMDD_HHMM.reg` dosyasını bulun
3. Çift tıklayın → "Evet" deyin
4. Bilgisayarı yeniden başlatın
→ Silinen tüm registry girişleri eski haline dönecektir.

**Hizmet Yapılandırıcısı (Modül #68):**
1. `%USERPROFILE%\Desktop\BakimRaporlari\` klasörünü açın
2. `HizmetYedek_YYYYMMDD_HHMM.json` dosyasını bulun
3. PowerShell'i yönetici olarak açın
4. Her servis için: Set-Service -Name "ServisAdı" -StartupType Automatic
   (JSON dosyasındaki değerleri kullanın)

**FPS Optimizer (Modül #26):**
1. SistemBakim'i açın → Modül #26
2. [2] "Geri Al" seçeneğini tıklayın
→ 11 tweak'in tamamı Windows varsayılanlarına döner.

**Sistem Geri Yükleme (hiçbiri işlemediyse):**
Değişikliklerden önce geri yükleme noktası oluşturduysanız (Modül #24):
1. Win+R → `rstrui.exe` yazın → Enter
2. Değişikliklerden önceki tarihi seçin

Bunların hiçbiri işe yaramadıysa, lütfen bir bug report açın — yardım edeceğiz.
```

---

## 3. Özellik İsteği / UI Önerisi

> Kullanıcı: "Şu özellik eklenirse harika olur!" / "UI böyle olsa daha iyi"

### English

```
Thank you for the suggestion — I really appreciate you taking the time to share this!

To make sure your idea gets properly tracked and doesn't get lost in the comments, 
could you open a Feature Request on GitHub? There's a structured template that helps 
me understand the context better:

👉 https://github.com/erdiyim/SistemBakim/issues/new?template=feature_request.yml

This way I can:
- Properly categorize and prioritize it
- Link related requests together
- Update you when it's being worked on

Your feedback directly shapes the roadmap — every feature in v5.0 started as 
a suggestion like yours.
```

### Türkçe

```
Öneriniz için çok teşekkür ederim — geri bildirimler projeyi şekillendiren 
en değerli şey!

Bu fikrin kaybolmaması ve düzgün takip edilebilmesi için bunu GitHub'da bir 
Feature Request olarak açar mısınız? Hazır bir şablon var:

👉 https://github.com/erdiyim/SistemBakim/issues/new?template=feature_request.yml

Böylece:
- Doğru kategoriye koyup önceliklendiriyorum
- Benzer istekleri birleştiriyorum
- Üzerinde çalışıldığında sizi bilgilendiriyorum

v5.0'daki her özellik sizin gibi kullanıcıların önerileriyle başladı.
```

---

## 4. Uygulama Açılmıyor / Crash

> Kullanıcı: "Uygulama açılmıyor!" / "Hemen kapanıyor!"

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

👉 https://github.com/erdiyim/SistemBakim/issues/new?template=bug_report.yml
```

### Türkçe

```
Bu durumla karşılaşmış olmanız için üzgünüm! Hemen çözelim.

Şu kontrolleri yapar mısınız:

1. **Yönetici olarak çalıştırın** — Sağ tık → "Yönetici olarak çalıştır". 
   Çoğu modül admin yetkisi gerektirir.

2. **Windows sürümünüzü kontrol edin** — Win10 veya Win11 (64-bit) gerekli. 
   `winver` komutuyla doğrulayın.

3. **CLI sürümünü deneyin** — `SistemBakim_CLI.exe` dosyasını indirin. Bu 
   çalışıp GUI çalışmıyorsa WPF render sorunu demektir.

4. **Antivirüs kontrolü** — Bazı antivirüsler ps2exe dosyalarını engelleyebilir. 
   Karantina logunu kontrol edin.

5. **Log klasörünü kontrol edin** — `%USERPROFILE%\Desktop\BakimRaporlari\` 
   içinde hata detayları olabilir.

Bunlar işe yaramadıysa, lütfen bug report açın:
👉 https://github.com/erdiyim/SistemBakim/issues/new?template=bug_report.yml
```

---

## 5. Hangi Modüller Güvenli?

> Kullanıcı: "Hangi modülleri güvenle kullanabilirim?" / "Sistemi bozar mı?"

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
Full technical documentation: https://github.com/erdiyim/SistemBakim/blob/main/docs/MODULES.md
```

---

## 6. Veri Toplanıyor mu / Telemetri

> Kullanıcı: "Bu uygulama veri topluyor mu?"

### English

```
No. Zero telemetry, zero analytics, zero data collection. Period.

SistemBakim does not connect to the internet for any reason except one optional check: 
on startup, it queries the GitHub Releases API to check if a newer version exists. 
This is a single GET request to api.github.com, runs in a background job, times out 
in 6 seconds, and contains no user data — only the app version string.

You can verify this yourself:
- The source code is fully open: https://github.com/erdiyim/SistemBakim
- Search for any network call in the code — you'll only find the update check
- The app works perfectly fine without any internet connection

No accounts, no registration, no cloud sync, no "anonymous usage statistics."
```

---

## 7. Win10 / Win11 Uyumluluk

> Kullanıcı: "Windows 10'da çalışıyor mu?" / "Win11 24H2'de sorun var mı?"

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

## 8. Teşekkür ve Yıldız İsteği

> Pozitif yorum geldiğinde — momentum için nazikçe star isteme

### English

```
Thank you so much — comments like this make the late nights worth it!

If SistemBakim saved you some time (or disk space!), a GitHub star would really 
help others discover it: https://github.com/erdiyim/SistemBakim

And if you run into anything weird, don't hesitate to open an issue. 
Happy optimizing!
```

### Türkçe

```
Çok teşekkür ederim — böyle yorumlar gece mesailerini anlamlı kılıyor!

SistemBakim size zaman (veya disk alanı!) kazandırdıysa, GitHub'da bir yıldız 
bırakmak başkalarının da keşfetmesine yardımcı olur: 
https://github.com/erdiyim/SistemBakim

Herhangi bir sorun yaşarsanız issue açmaktan çekinmeyin. 
Kolay gelsin!
```

---

## 9. Duplicate / Tekrar Eden Issue

> Daha önce bildirilen bir bug/istek tekrar açıldığında

### English

```
Thanks for reporting this! This is a known issue that's already being tracked in #XX.

I'm closing this as a duplicate to keep the discussion in one place. 
Please follow #XX for updates — I'll post there when there's progress.

If your case is different from what's described in #XX, feel free to reopen 
this issue with the additional details.
```

---

## 10. Dil Desteği / İngilizce UI

> Kullanıcı: "Türkçe anlamıyorum, İngilizce olsa..." / "Will there be English UI?"

### English

```
English language support is on the roadmap! Currently the UI is in Turkish, 
but all module names and most technical terms are recognizable.

If you'd like to contribute translations, that would be amazing — it's listed 
as a contribution area in the README:
https://github.com/erdiyim/SistemBakim#contributing

For now, the full module documentation in English is available here:
https://github.com/erdiyim/SistemBakim/blob/main/docs/MODULES.md
```

---

<div align="center">

*Bu şablonları duruma göre küçük düzenlemelerle kullanın.
Kişisel dokunuşlar (kullanıcının adını kullanmak vb.) etkiyi artırır.*

</div>
