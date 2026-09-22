# 📋 Metabase Cheatsheet

**URL:** http://localhost:3001 · İlk açılışta kurulum sihirbazı (admin hesabı oluşturma) çıkar.

---

## 🔌 Veri Kaynağı Ekleme

**Admin ⚙ → Databases → Add a database**

| Alan | Değer |
|---|---|
| Database type | PostgreSQL |
| Host | `postgres` (Metabase container'ından erişim) |
| Port | `5432` |
| Database name | `bi_db` |
| Username | `bi_user` |
| Password | `bi_pass` |

---

## ❓ Soru (Question) Oluşturma

1. **+ New → Question**
2. Tablo seç: `Fact Sales`
3. **Summarize** ile agregasyon ekle (Sum of revenue, Count of rows…)
4. **Group by** ile boyut ekle (Date → by Month, Customer → City…)
5. **Filter** ile koşul ekle (order_status = completed)

Grafiğe çevirmek için sonuç ekranının altındaki **Visualization** panelinden
grafik türü seçin.

---

## 📁 Koleksiyon (Collection) Yapısı

```
Our Analytics
├── Satış Ekibi/
│   ├── Aylık Ciro Trendi
│   ├── Bölge Bazında Performans
│   └── Ürün Kategorisi Analizi
└── Yönetim Dashboard/
    └── Yönetici Özeti
```

Sorularınızı klasörlere organize edin — "Our Analytics" kök klasörüne her
şeyi atmak, birkaç ay sonra "hangi soru neydi" kaosuna yol açar.

---

## 🧮 Modeller (Models)

Sık kullanılan bir sorguyu (örn. "tamamlanmış siparişler") bir **Model**
olarak kaydedin — diğer sorular bu modelin üzerine inşa edilebilir,
mantık tek bir yerde yaşar (dbt'deki `ref()` felsefesine benzer).

**Admin → Data Model** üzerinden sütun açıklamaları, görünürlük ve
hesaplanmış sütunlar (custom columns) tanımlanabilir.

---

## 📊 Dashboard Oluşturma

1. **+ New → Dashboard**
2. Kaydedilmiş soruları sürükle-bırak ile ekle
3. **Add a filter** ile dashboard geneli filtre ekle (tarih aralığı, şehir…)
4. Filtreyi her karta **bağlayın** (kartın üstündeki filtre ikonuna tıklayın)

---

## ⏰ Zamanlanmış Gönderim ve Uyarılar

- **Dashboard → Subscriptions**: belirli aralıklarla (günlük/haftalık) e-posta ile gönder
- **Question → Alert (🔔)**: bir metrik eşiği aştığında/altına düştüğünde bildirim al
  (örn. "günlük ciro 50.000 TL'nin altına düşerse haber ver")

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| Veri kaynağı bağlanamıyor | `Host` olarak `localhost` yazılmış | Container ağı içinden `postgres` kullanın |
| Sorgu çok yavaş | İndekssiz büyük tablo | `init/01-star-schema.sql`'deki indeksleri kontrol edin |
| SQL Editor'de yazdığım sorgu grafiğe dönüşmüyor | Sonuç sütunları grafiğe uygun değil | En az 1 kategorik + 1 sayısal sütun olmalı |
| Dashboard filtresi karta etki etmiyor | Filtre karta bağlanmamış | Kartın üstündeki filtre ikonuna tıklayıp bağlayın |

---

**[← Hafta 11 README](../README.md)** · **[Superset Cheatsheet →](./superset-cheatsheet.md)**
