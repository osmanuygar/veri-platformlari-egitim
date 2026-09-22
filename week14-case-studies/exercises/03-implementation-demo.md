# Aşama 3: Uygulama ve Demo

**Süre:** 3-6 saat (vakaya göre değişir)

---

## 3.1 Servisleri başlatın

[`cheatsheets/combining-weeks-cheatsheet.md`](../cheatsheets/combining-weeks-cheatsheet.md)'teki
3 yöntemden vakanıza uygun olanı seçin. Çoğu vaka için **Yöntem 1**
(her hafta kendi terminalinde, entegrasyonu siz kod yazarak yaparsınız) yeterlidir.

```bash
cd week02-di-rdbms && docker compose up -d
cd ../week07-de-kafka && docker compose up -d
# ...
```

## 3.2 Uçtan uca akışı kurun

Kapsamınızdaki (Aşama 1.3) her adımı sırayla inşa edin. **Her adımı
tek başına test edin** — hepsini birden bağlayıp "çalışmıyor" demekten
daha kolay hata ayıklama sağlar.

## 3.3 Başarı kriterinizi doğrulayın

Aşama 1.4'te yazdığınız somut, gözlemlenebilir kriteri **gerçekten test edin**.

```bash
# Örnek: "5 saniye içinde CDC olayı görünmeli" testi
time (
  psql ... -c "UPDATE orders SET status='shipped' WHERE id=1;"
  # ve CDC olayının ne zaman göründüğünü gözlemleyin
)
```

## 3.4 Demo senaryonuzu yazın

**Görev:** Sunumda göstereceğiniz **adım adım demo senaryosunu** yazın
(hangi komutu çalıştıracaksınız, ne göstereceksiniz, hangi sırayla).
Canlı demo'da doğaçlama yapmak risklidir — bir senaryo notu, sunumun
kaymasını önler.

## 3.5 Bilinen sınırlamaları listeleyin

**Görev:** Vaka özetinizdeki "Bilinen Sınırlamalar" bölümünü doldurun.
Hiçbir capstone projesi mükemmel değildir — hangi kısımları kasıtlı
basitleştirdiğinizi (Aşama 1.3'teki "Hariç" listesiyle tutarlı olmalı)
açıkça belirtmek, **olgunluk** göstergesidir, eksiklik değil.

---

**[← Aşama 2](./02-architecture-adr.md)** · **[Aşama 4 →](./04-presentation-peer-review.md)**
