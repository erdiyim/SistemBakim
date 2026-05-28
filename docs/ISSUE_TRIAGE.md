<div align="center">

# SistemBakim — Issue Triage & Prioritization Guide

### Solo Geliştirici İçin Hata Önceliklendirme Rehberi

*Her bug eşit değildir. Bu rehber hangisi için uykunu bozacağını, hangisini v5.1'e bırakacağını söyler.*

</div>

---

## Altın Kural

> **Kural #1:** Kullanıcının sistemini BOZAN veya VERİ KAYBINA yol açan her şey P0'dır.
> **Kural #2:** Kullanıcının SistemBakim'i KULLANMASINI ENGELLEYEN her şey P1'dir.
> **Kural #3:** Geri kalan her şey bekleyebilir.

---

## Öncelik Seviyeleri

### P0 — KRİTİK (Uykunu Boz, Şimdi Fix'le)

**Hedef süre:** 2-4 saat içinde hotfix release

**Tanımlama:** Aşağıdakilerden BİR TANESİ bile geçerliyse P0'dır:

| Belirti | Örnek |
|---------|-------|
| Uygulama BSOD'a neden oluyor | Korunan servis listesinde olmayan bir kritik servisin kapatılması |
| Veri kaybı | Dosya Kırpıcı yanlış dosyayı siliyor, Registry temizleyici olmaması gereken bir şeyi siliyor |
| Yedek mekanizması çalışmıyor | `.reg` dosyası oluşturulmuyor, JSON yedek boş |
| Korunan servislerin devre dışı kalabilmesi | `$korunanlar` listesindeki bir servisin profil tarafından değiştirilebilmesi |
| Uygulama hiç açılmıyor (widespread) | Birden fazla kullanıcı aynı crash'i bildiriyor |

**Eylem planı:**
```
1. Issue'ya "P0-critical" + "bug" label'ı ekle
2. Hemen reproduce et (Win10 + Win11)
3. Fix yap → Lokal test → Commit
4. git tag v5.0.X && git push origin v5.0.X
5. CI/CD otomatik build + release
6. Issue'ya yanıt: "Fixed in v5.0.X — please update and confirm"
7. Reddit/PH'de güncelleme yorumu yaz (varsa)
```

**Asla yapma:**
- Issue'yu "investigate later" diye bırakma
- Fix'i birden fazla değişiklikle bundle etme — tek fix, tek release

---

### P1 — YÜKSEK (Bugün veya Yarın Fix'le)

**Hedef süre:** 24-48 saat

**Tanımlama:**

| Belirti | Örnek |
|---------|-------|
| Belirli bir modül tamamen çalışmıyor | DNS Benchmark hiç DNS sorgusu yapmıyor |
| Modül yanlış sonuç üretiyor ama zarar vermiyor | RAM Optimizer "-500 MB" yerine "+500 MB" gösteriyor |
| Geri alma mekanizması çalışıyor ama eksik | FPS Optimizer 11 tweak'ten 9'unu geri alıyor, 2'sini atlıyor |
| Belirli bir Windows sürümünde crash | Win11 24H2'de Treemap açılırken hata |
| GUI donuyor ama çökmüyor | DispatcherTimer thread bloklama sorunu |

**Eylem planı:**
```
1. Issue'ya "P1-high" + "bug" label'ı ekle
2. Kullanıcıdan ek bilgi iste (Windows sürümü, log çıktısı)
3. Reproduce et → root cause bul
4. Gün içinde veya ertesi gün fix yap
5. Bir sonraki hotfix batch'ine dahil et (v5.0.X)
6. Issue'ya: "Fix is ready, will be in the next patch release"
```

---

### P2 — ORTA (Bu Hafta veya v5.1'e Bırak)

**Hedef süre:** 1 hafta veya sonraki minor release

**Tanımlama:**

| Belirti | Örnek |
|---------|-------|
| Modül çalışıyor ama UX kötü | Temizlik modülü tamamlanma yüzdesini göstermiyor |
| Küçük hesaplama hatası | Disk Analizi 1-2 MB yanlış gösteriyor |
| Edge case handling eksik | Boş Klasör Bulucu junction/symlink'lerde hata |
| Log/rapor formatlama sorunu | HTML Dashboard'da Türkçe karakter bozuk |
| Performans iyileştirmesi | WinSxS temizliği 20dk sürüyor, 10dk'ya indirilebilir |

**Eylem planı:**
```
1. Issue'ya "P2-medium" + "bug" label'ı ekle
2. "v5.1" milestone'una ata
3. Kullanıcıya: "Tracked for v5.1 — thanks for reporting!"
4. Haftalık code session'da toplu fix yap
```

---

### P3 — DÜŞÜK (v5.1 veya Sonrası)

**Hedef süre:** Sonraki minor/major release

**Tanımlama:**

| Belirti | Örnek |
|---------|-------|
| Kozmetik / görsel sorun | Buton hizalama kayık, font boyutu tutarsız |
| "Nice to have" iyileştirme | "Temizlik sırasında ses çıkarsa güzel olur" |
| Dokümantasyon hatası | MODULES.md'de yanlış satır numarası referansı |
| Nadiren tetiklenen edge case | Sadece Almanca Windows'ta oluşan bir sorun |
| Eski OS uyumluluk | Win10 1903'te çalışmıyor (EOL sürümler) |

**Eylem planı:**
```
1. Issue'ya "P3-low" + ilgili label'ı ekle
2. "backlog" milestone'una ata
3. Kullanıcıya: "Noted — added to backlog for a future release"
4. Zaman buldukça veya PR gelirse fix'le
```

---

## GitHub Label Sistemi

### Oluşturulacak Label'lar

```
Öncelik (Renk: kırmızı → yeşil):
  P0-critical     #D73A4A   Sistem bozulma / veri kaybı riski
  P1-high         #E99695   Modül çalışmıyor / yanlış sonuç
  P2-medium       #FBCA04   Küçük hata / iyileştirme
  P3-low          #0E8A16   Kozmetik / edge case

Tür:
  bug             #D73A4A   Hata bildirimi
  enhancement     #A2EEEF   Özellik isteği
  question        #D876E3   Soru / destek
  documentation   #0075CA   Dokümantasyon
  duplicate       #CFD3D7   Tekrar eden issue
  wontfix         #FFFFFF   Düzeltilmeyecek (tasarım kararı)

Durum:
  triage          #FBCA04   Henüz değerlendirilmedi
  confirmed       #0E8A16   Tekrarlanabilir, fix planlanıyor
  needs-info      #D876E3   Kullanıcıdan ek bilgi bekleniyor
  in-progress     #1D76DB   Üzerinde çalışılıyor

Modül:
  mod-temizlik    #60A5FA   Temizlik & Disk modülleri
  mod-sistem      #34D399   Sistem modülleri
  mod-guvenlik    #F87171   Güvenlik modülleri
  mod-ag          #38BDF8   Ağ & İnternet modülleri
  mod-oyun        #C084FC   Oyun & Performans modülleri
  mod-gui         #F472B6   GUI / arayüz sorunları

Milestone:
  v5.0.x          Hotfix release'ler
  v5.1            Sonraki minor release
  backlog         Gelecek sürümler
```

---

## Günlük Triage Rutini (10 Dakika)

> Her gün sabah veya akşam 10 dk ayır. Daha fazlası gerekmiyor.

```
ADIM 1: Yeni issue'ları tara (2 dk)
  → GitHub → Issues → label:triage sort:created-desc
  → Her birini oku, ilk izlenimi belirle

ADIM 2: Label'la (3 dk)
  → Öncelik: P0/P1/P2/P3
  → Tür: bug / enhancement / question
  → Modül: hangi modül etkilenmiş
  → Durum: confirmed / needs-info

ADIM 3: Hızlı yanıt (3 dk)
  → P0: Hemen çalışmaya başla (triage'ı bırak)
  → P1: "I can reproduce this, working on a fix"
  → P2: "Tracked for v5.1 — thanks!"
  → P3: "Added to backlog"
  → needs-info: FAQ_RESPONSES.md'den uygun şablonu yapıştır

ADIM 4: Stale issue kontrol (2 dk)
  → 14+ gün needs-info'da yanıt gelmemiş → "Closing due to inactivity. 
     Feel free to reopen if the issue persists."
  → 30+ gün P3'te → Hâlâ geçerli mi? Değilse kapat.
```

---

## Karar Ağacı (Issue Geldiğinde)

```
Yeni Issue Geldi
│
├── Crash / BSOD / Veri Kaybı mı?
│   ├── EVET → P0 → ŞİMDİ fix'le
│   └── HAYIR ↓
│
├── Modül tamamen çalışmıyor mu?
│   ├── EVET → P1 → 24-48 saat
│   └── HAYIR ↓
│
├── Yanlış sonuç ama zarar yok mu?
│   ├── EVET → P2 → Bu hafta veya v5.1
│   └── HAYIR ↓
│
├── Kozmetik / edge case / dokümantasyon mu?
│   ├── EVET → P3 → Backlog
│   └── HAYIR ↓
│
├── Özellik isteği mi?
│   ├── EVET → "enhancement" label → v5.1 milestone
│   └── HAYIR ↓
│
├── Soru mu?
│   ├── EVET → FAQ yanıtı yapıştır → Kapat (veya Discussions'a yönlendir)
│   └── HAYIR ↓
│
└── Anlaşılmıyor → "needs-info" label → Soru sor → 14 gün bekle
```

---

## Solo Geliştirici İçin Zihinsel Sağlık Kuralları

```
1. Her bug'ı hemen fix'lemek ZORUNDA değilsin.
   P0 dışında her şey BEKLEYEBİLİR.

2. Her özellik isteğine "evet" deme.
   "Great idea — tracked for future consideration" yeterli.

3. Toksik yorumları kişisel alma.
   Kibar ama kesin ol: "I appreciate the feedback. If you'd like 
   to help, PRs are welcome."

4. Haftada 1 gün HİÇBİR issue'ya bakma.
   Burnout en büyük düşmanın — kodun değil.

5. Metriklere takılma.
   10 mutlu kullanıcı, 1000 yıldızdan daha değerlidir.
```

---

<div align="center">

*Bu rehber sabit değil — deneyimle güncelle. İlk 2 hafta sana en çok
hangi tür issue geldiğini izle ve triage rutinini buna göre ayarla.*

</div>
