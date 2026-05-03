# 🛡️ SistemBakim — Windows Bakım Aracı v5.0

> Tek script ile Windows temizlik, performans, güvenlik ve bakım.  
> **Türkçe · Yerel çalışır · İnternet gerektirmez · Veri göndermez**

---

## 📋 İçindekiler

- [Nedir?](#nedir)
- [Özellikler](#özellikler)
- [Kurulum & Kullanım](#kurulum--kullanım)
- [Modüller](#modüller)
- [KVKK & Gizlilik](#kvkk--gizlilik)
- [Güvenlik](#güvenlik)
- [Katkı](#katkı)
- [Lisans](#lisans)

---

## Nedir?

SistemBakim, Windows işletim sistemleri için geliştirilmiş kapsamlı bir PowerShell bakım aracıdır. Tek bir `.ps1` dosyasından çalışır, hiçbir kurulum gerektirmez, internete bağlanmaz ve bilgisayarınızdaki hiçbir veriyi dışarıya göndermez.

**Kimler için?**
- Bilgisayarını düzenli bakımda tutmak isteyen ev kullanıcıları
- Geliştirici araç artıklarını temizlemek isteyen yazılımcılar
- Şirket bilgisayarlarını yönetmek isteyen IT personeli

---

## Özellikler

| Kategori | Kapsam |
|---|---|
| 🧹 Temizlik | 19 konum temp, browser cache, duplicate dosya, crash dump, shadow copy, Windows log |
| 🔍 Sağlık | SFC, DISM, ChkDsk, S.M.A.R.T., Event Log, BSOD tespiti |
| ⚡ Performans | Başlangıç analizi, RAM/CPU/GPU raporu, güç planı optimizasyonu |
| 🌐 Ağ | DNS temizleme, Winsock reset, ping testi, bağlantı analizi |
| 🔒 Güvenlik | Firewall, Defender, driver kontrolü, hosts tarama, port analizi, BitLocker |
| 👨‍💻 Geliştirici | node_modules, bin/obj, NuGet, pip, git, Docker, WSL2 optimizasyonu |
| 🖥️ Donanım | BIOS versiyonu, USB geçmişi, termal throttling, pil raporu |
| 📊 Raporlama | HTML dashboard, 100 puanlık sağlık skoru, trend geçmişi |
| 🤖 Otomasyon | Haftalık sessiz bakım (Task Scheduler), hazır profiller |

---

## Kurulum & Kullanım

### Gereksinimler

- Windows 10 veya Windows 11
- PowerShell 5.1 veya üzeri *(zaten yüklü gelir)*
- Yönetici yetkisi *(bazı modüller için)*

### Adım 1 — İndir

```
Sag ust kosedeki yesil "Code" dugmesine tikla → "Download ZIP"
```

veya git ile:

```bash
git clone https://github.com/KULLANICI_ADIN/SistemBakim.git
```

### Adım 2 — Çalıştır

**PowerShell'i Yönetici olarak aç** (Başlat → PowerShell → Sağ tık → Yönetici olarak çalıştır)

```powershell
# Çalıştırma iznini bu oturum için aç (bir kerelik)
Set-ExecutionPolicy -Scope Process Bypass

# Scripti çalıştır
& "C:\...\SistemBakim_v5.ps1"
```

### Adım 3 — Menüden seç

Araç açıldığında numaralı menü karşına gelir. Yapmak istediğin işlemin numarasını gir, Enter'a bas.

**Hızlı başlangıç önerisi:**
```
21 → Sağlık Skoru (mevcut durumunu gör)
25 → Tam Bakım    (hepsini yaptır)
20 → HTML Raporu  (sonucu tarayıcıda gör)
```

---

## Modüller

<details>
<summary><b>Temizlik (1-8)</b></summary>

| No | Modül | Açıklama |
|---|---|---|
| 1 | Disk Analizi | Büyük dosyalar, boş klasörler, Windows.old, hiberfil.sys |
| 2 | Yinelenen Dosyalar | MD5 hash ile birebir kopyaları tespit eder |
| 3 | Kapsamlı Temizlik | 19 konum: Temp, browser cache, Discord, Spotify, Teams... |
| 4 | S.M.A.R.T. | Disk sağlığı, sıcaklık, aşınma, hata sayısı |
| 5 | Crash Dump | .dmp dosyaları ve WER hata raporları |
| 6 | Shadow & Restore | Volume shadow copy ve restore point yönetimi |
| 7 | Windows Logları | CBS, DISM, Setup, Update log dosyaları |
| 8 | Downloads Analizi | Yaşa ve türe göre indirme klasörü raporu |

</details>

<details>
<summary><b>Sağlık (9-11)</b></summary>

| No | Modül | Açıklama |
|---|---|---|
| 9 | Sistem Tarama | SFC + DISM + ChkDsk, Türkçe CBS.log yorumu |
| 10 | Olay Günlüğü | Son 7 günün System/App/Security logları, BSOD tespiti |
| 11 | Servis Kontrolü | 20 kritik Windows servisi, kapalı olanları başlat |

</details>

<details>
<summary><b>Performans (12-14)</b></summary>

| No | Modül | Açıklama |
|---|---|---|
| 12 | Başlangıç Analizi | Kayıt defteri + klasör startup programları |
| 13 | Kaynak Durumu | RAM slot detayı, CPU/GPU, disk tipi, uptime |
| 14 | Güç Planı | 4 plan arasında geçiş, Son Teknoloji Performans dahil |

</details>

<details>
<summary><b>Ağ & Güvenlik (15-17)</b></summary>

| No | Modül | Açıklama |
|---|---|---|
| 15 | Ağ Tanılama | DNS flush, Winsock reset, 5 DNS ping testi |
| 16 | Güvenlik Kontrolü | Firewall, Defender, driver sağlığı, bekleyen güncellemeler |
| 17 | Gelişmiş Güvenlik | Hosts tarama, açık port analizi, RDP, BitLocker, şüpheli görevler, kayıt defteri artıkları |

</details>

<details>
<summary><b>Geliştirici & Donanım (18-19)</b></summary>

| No | Modül | Açıklama |
|---|---|---|
| 18 | Geliştirici Araçları | node_modules, bin/obj, NuGet, pip, git gc, Docker prune, WSL2 compact |
| 19 | Donanım Raporu | BIOS sürümü, USB geçmişi, termal throttling, pil sağlığı |

</details>

<details>
<summary><b>Akıllı Araçlar (20-24)</b></summary>

| No | Modül | Açıklama |
|---|---|---|
| 20 | HTML Dashboard | Tarayıcıda açılan grafik bakım raporu |
| 21 | Sağlık Skoru | 100 üzerinden puan, trend geçmişi, bileşen bazlı analiz |
| 22 | Haftalık Zamanlama | Task Scheduler ile her Pazar 03:00 sessiz bakım |
| 23 | Hazır Profiller | Oyun Öncesi / Haftalık / Hızlı / Geliştirici / Güvenlik |
| 24 | Geri Yükleme | İşlem öncesi otomatik restore point oluşturur |

</details>

---

## KVKK & Gizlilik

### ✅ Bu araç KVKK uyumludur

| Madde | Durum | Açıklama |
|---|---|---|
| Veri toplama | ✅ Hayır | Hiçbir kişisel veri toplanmaz |
| Veri iletimi | ✅ Hayır | İnternete hiçbir şey gönderilmez |
| Sunucu bağlantısı | ✅ Hayır | Tamamen yerel çalışır |
| Log içeriği | ✅ Yerel | Loglar yalnızca kendi masaüstünüzde saklanır |
| Üçüncü taraf | ✅ Yok | Herhangi bir API veya harici servis kullanılmaz |
| Ping testleri | ℹ️ Genel DNS | Yalnızca 8.8.8.8 gibi genel adreslere bağlantı testi yapılır, veri gönderilmez |

### Log Dosyaları Nerede?

```
C:\Users\KULLANICI_ADIN\Desktop\BakimRaporlari\
├── Bakim_20260427_1943.log   ← Metin log
├── Rapor_20260427_1943.html  ← HTML dashboard
└── skor_gecmis.json          ← Skor geçmişi
```

**Bu dosyaları istediğiniz zaman silebilirsiniz.** Araç her çalıştığında yeni bir log oluşturur.

### Ne İçeriyor?

Log dosyaları yalnızca şunları içerir:
- Bilgisayar adı ve kullanıcı adı *(Windows ortam değişkenlerinden)*
- Disk doluluk yüzdeleri
- Hangi işlemlerin yapıldığı *(silinen klasör boyutları vb.)*
- Servis ve güvenlik durumları

**Parola, kimlik bilgisi, belge içeriği veya şahsi dosya içeriği kesinlikle kaydedilmez.**

---

## Güvenlik

### ⚠️ Silinmeden Önce Her Zaman Onay İster

Araç, hiçbir dosyayı veya klasörü onaysız silmez. Her silme işlemi öncesinde:

```
? Bu bos klasorler silinsin mi? [E/H]:
```

şeklinde onay sorar. **H** yazarsanız hiçbir şey yapılmaz.

### Neler Silinebilir?

| İşlem | Geri Alınabilir mi? |
|---|---|
| Temp dosyaları | ✅ Evet (Windows yeniden oluşturur) |
| Browser cache | ✅ Evet (tarayıcı yeniden oluşturur) |
| Boş klasörler | ✅ Evet (manuel oluşturulabilir) |
| node_modules | ✅ Evet (`npm install` ile) |
| Windows.old | ⚠️ Hayır (eski Windows'a dönülemez) |
| Shadow copy | ⚠️ Hayır (geri alınamaz) |
| Crash dump | ✅ Evet (gerekmiyor zaten) |

### Kayıt Defteri

Araç kayıt defterini **okur** ama **yazmaz**. Tek istisna: güç planı değiştirme ve isteğe bağlı TRIM aktivasyonu.

---

## Katkı

Her türlü katkı memnuniyetle karşılanır.

```bash
# Fork et → değişiklik yap → Pull Request aç
git checkout -b ozellik/yeni-modul
git commit -m "feat: yeni modul eklendi"
git push origin ozellik/yeni-modul
```

**Katkı fikirleri:**
- Yeni temizlik konumları
- Farklı dil desteği
- Ek güvenlik kontrolleri
- Test sonuçları (farklı Windows sürümleri)

---

## Sürüm Geçmişi

| Sürüm | Tarih | Değişiklikler |
|---|---|---|
| v5.0 | Nisan 2026 | HTML dashboard, sağlık skoru, geliştirici araçları, gelişmiş güvenlik, donanım raporu, profil sistemi, otomasyon |
| v4.0 | Nisan 2026 | SMART, crash dump, shadow copy, Windows log, downloads analizi |
| v3.0 | Nisan 2026 | Event log, başlangıç analizi, kaynak durumu, güç planı, 20 servis |
| v2.0 | Nisan 2026 | Temel temizlik, SFC/DISM, servis kontrolü, ağ sıfırlama |

---

## Lisans

MIT Lisansı — Kişisel ve ticari olmayan kullanım serbesttir.  
Kaynak göstermek güzel olur ama zorunlu değil.

---

<div align="center">

**Temizlik imandan gelir** 🧹

*Sorularınız için [Issues](../../issues) bölümünü kullanabilirsiniz.*

</div>
