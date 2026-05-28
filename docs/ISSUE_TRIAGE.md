<div align="center">

# SistemBakim — Issue Triage & Prioritization Guide

### Solo Gelistirici Icin Hata Onceliklendirme Rehberi

*Her bug esit degildir. Bu rehber hangisi icin uykunu bozacagini, hangisini v5.1'e birakacagini soyler.*

</div>

---

## Altin Kural

> **Kural #1:** Kullanicinin sistemini BOZAN veya VERI KAYBINA yol acan her sey P0'dir.
> **Kural #2:** Kullanicinin SistemBakim'i KULLANMASINI ENGELLEYEN her sey P1'dir.
> **Kural #3:** Geri kalan her sey bekleyebilir.

---

## Oncelik Seviyeleri

### P0 — KRITIK (Uykunu Boz, Simdi Fix'le)

**Hedef sure:** 2-4 saat icinde hotfix release

**Tanimlama:** Asagidakilerden BIR TANESI bile gecerliyse P0'dir:

| Belirti | Ornek |
|---------|-------|
| Uygulama BSOD'a neden oluyor | Korunan servis listesinde olmayan bir kritik servisin kapatilmasi |
| Veri kaybi | Dosya Kirpici yanlis dosyayi siliyor, Registry temizleyici olmamasi gereken bir seyi siliyor |
| Yedek mekanizmasi calismıyor | `.reg` dosyasi olusturulmuyor, JSON yedek bos |
| Korunan servislerin devre disi kalabilmesi | `$korunanlar` listesindeki bir servisin profil tarafindan degistirilebilmesi |
| Uygulama hic acilmiyor (widespread) | Birden fazla kullanici ayni crash'i bildiriyor |

**Eylem plani:**
```
1. Issue'ya "P0-critical" + "bug" label'i ekle
2. Hemen reproduce et (Win10 + Win11)
3. Fix yap → Lokal test → Commit
4. git tag v5.0.X && git push origin v5.0.X
5. CI/CD otomatik build + release
6. Issue'ya yanit: "Fixed in v5.0.X — please update and confirm"
7. Reddit/PH'de guncelleme yorumu yaz (varsa)
```

**Asla yapma:**
- Issue'yu "investigate later" diye birakma
- Fix'i birden fazla degisiklikle bundle etme — tek fix, tek release

---

### P1 — YUKSEK (Bugun veya Yarin Fix'le)

**Hedef sure:** 24-48 saat

**Tanimlama:**

| Belirti | Ornek |
|---------|-------|
| Belirli bir modul tamamen calismıyor | DNS Benchmark hic DNS sorgusu yapmiyor |
| Modul yanlis sonuc uretyor ama zarar vermiyor | RAM Optimizer "-500 MB" yerine "+500 MB" gostruyor |
| Geri alma mekanizmasi calisiyor ama eksik | FPS Optimizer 11 tweak'ten 9'unu geri aliyor, 2'sini atliyor |
| Belirli bir Windows surumunde crash | Win11 24H2'de Treemap acilirken hata |
| GUI donuyor ama cokmuyor | DispatcherTimer thread bloklama sorunu |

**Eylem plani:**
```
1. Issue'ya "P1-high" + "bug" label'i ekle
2. Kullanicidan ek bilgi iste (Windows surumu, log ciktisi)
3. Reproduce et → root cause bul
4. Gun icinde veya ertesi gun fix yap
5. Bir sonraki hotfix batch'ine dahil et (v5.0.X)
6. Issue'ya: "Fix is ready, will be in the next patch release"
```

---

### P2 — ORTA (Bu Hafta veya v5.1'e Birak)

**Hedef sure:** 1 hafta veya sonraki minor release

**Tanimlama:**

| Belirti | Ornek |
|---------|-------|
| Modul calisiyor ama UX kotu | Temizlik modulu tamamlanma yuzdesini gostermiyor |
| Kucuk hesaplama hatasi | Disk Analizi 1-2 MB yanlis gosteriyor |
| Edge case handling eksik | Bos Klasor Bulucu junction/symlink'lerde hata |
| Log/rapor formatlama sorunu | HTML Dashboard'da Turkce karakter bozuk |
| Performans iyilestirmesi | WinSxS temizligi 20dk suruyor, 10dk'ya indirilebilir |

**Eylem plani:**
```
1. Issue'ya "P2-medium" + "bug" label'i ekle
2. "v5.1" milestone'una ata
3. Kullaniciya: "Tracked for v5.1 — thanks for reporting!"
4. Haftalik code session'da toplu fix yap
```

---

### P3 — DUSUK (v5.1 veya Sonrasi)

**Hedef sure:** Sonraki minor/major release

**Tanimlama:**

| Belirti | Ornek |
|---------|-------|
| Kozmetik / gorsel sorun | Buton hizalama kayik, font boyutu tutarsız |
| "Nice to have" iyilestirme | "Temizlik sirasinda ses cikarsa guzel olur" |
| Dokumantasyon hatasi | MODULES.md'de yanlis satir numarasi referansi |
| Nadiren tetiklenen edge case | Sadece Almanca Windows'ta olusn bir sorun |
| Eski OS uyumluluk | Win10 1903'te calismıyor (EOL surumler) |

**Eylem plani:**
```
1. Issue'ya "P3-low" + ilgili label'i ekle
2. "backlog" milestone'una ata
3. Kullaniciya: "Noted — added to backlog for a future release"
4. Zaman buldukca veya PR gelirse fix'le
```

---

## GitHub Label Sistemi

### Olusturulacak Label'lar

```
Oncelik (Renk: kirmizi → yesil):
  P0-critical     #D73A4A   Sistem bozulma / veri kaybi riski
  P1-high         #E99695   Modul calismıyor / yanlis sonuc
  P2-medium       #FBCA04   Kucuk hata / iyilestirme
  P3-low          #0E8A16   Kozmetik / edge case

Tur:
  bug             #D73A4A   Hata bildirimi
  enhancement     #A2EEEF   Ozellik istegi
  question        #D876E3   Soru / destek
  documentation   #0075CA   Dokumantasyon
  duplicate       #CFD3D7   Tekrar eden issue
  wontfix         #FFFFFF   Duzeltilmeyecek (tasarim karari)

Durum:
  triage          #FBCA04   Henuz degerlendirilmedi
  confirmed       #0E8A16   Tekrarlanabilir, fix planlanıyor
  needs-info      #D876E3   Kullanicidan ek bilgi bekleniyor
  in-progress     #1D76DB   Uzerinde calisilıyor

Modul:
  mod-temizlik    #60A5FA   Temizlik & Disk modulleri
  mod-sistem      #34D399   Sistem modulleri
  mod-guvenlik    #F87171   Guvenlik modulleri
  mod-ag          #38BDF8   Ag & Internet modulleri
  mod-oyun        #C084FC   Oyun & Performans modulleri
  mod-gui         #F472B6   GUI / arayuz sorunlari

Milestone:
  v5.0.x          Hotfix release'ler
  v5.1            Sonraki minor release
  backlog         Gelecek surumler
```

---

## Gunluk Triage Rutini (10 Dakika)

> Her gun sabah veya aksam 10 dk ayir. Daha fazlasi gerekmiyor.

```
ADIM 1: Yeni issue'lari tara (2 dk)
  → GitHub → Issues → label:triage sort:created-desc
  → Her birini oku, ilk izlenimi belirle

ADIM 2: Label'la (3 dk)
  → Oncelik: P0/P1/P2/P3
  → Tur: bug / enhancement / question
  → Modul: hangi modul etkilenmis
  → Durum: confirmed / needs-info

ADIM 3: Hizli yanit (3 dk)
  → P0: Hemen calismaya basla (triage'i birak)
  → P1: "I can reproduce this, working on a fix"
  → P2: "Tracked for v5.1 — thanks!"
  → P3: "Added to backlog"
  → needs-info: FAQ_RESPONSES.md'den uygun sablonu yapistir

ADIM 4: Stale issue kontrol (2 dk)
  → 14+ gun needs-info'da yanit gelmemis → "Closing due to inactivity. 
     Feel free to reopen if the issue persists."
  → 30+ gun P3'te → Hala gecerli mi? Degilse kapat.
```

---

## Karar Agaci (Issue Geldiginde)

```
Yeni Issue Geldi
│
├── Crash / BSOD / Veri Kaybi mi?
│   ├── EVET → P0 → SIMDI fix'le
│   └── HAYIR ↓
│
├── Modul tamamen calismıyor mu?
│   ├── EVET → P1 → 24-48 saat
│   └── HAYIR ↓
│
├── Yanlis sonuc ama zarar yok mu?
│   ├── EVET → P2 → Bu hafta veya v5.1
│   └── HAYIR ↓
│
├── Kozmetik / edge case / dokumantasyon mu?
│   ├── EVET → P3 → Backlog
│   └── HAYIR ↓
│
├── Ozellik istegi mi?
│   ├── EVET → "enhancement" label → v5.1 milestone
│   └── HAYIR ↓
│
├── Soru mu?
│   ├── EVET → FAQ yaniti yapistir → Kapat (veya Discussions'a yonlendir)
│   └── HAYIR ↓
│
└── Anlasilmiyor → "needs-info" label → Soru sor → 14 gun bekle
```

---

## Solo Gelistirici Icin Zihinsel Saglik Kurallari

```
1. Her bug'i hemen fix'lemek ZORUNDA degilsin.
   P0 disinda her sey BEKLEYEBILIR.

2. Her ozellik istegine "evet" deme.
   "Great idea — tracked for future consideration" yeterli.

3. Toksik yorumlari kisisel alma.
   Kibar ama kesin ol: "I appreciate the feedback. If you'd like 
   to help, PRs are welcome."

4. Haftada 1 gun HICBIR issue'ya bakma.
   Burnout en buyuk dusmanin — kodun degil.

5. Metriklere takilma.
   10 mutlu kullanici, 1000 yildizdan daha degerlidir.
```

---

<div align="center">

*Bu rehber sabit degil — deneyimle guncelle. Ilk 2 hafta sana en cok
hangi tur issue geldigini izle ve triage rutinini buna gore ayarla.*

</div>
