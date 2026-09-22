# Alıştırma 2: Metabase Dashboard

**Süre:** ~35 dakika

---

## 2.1 Veri kaynağını bağlayın

`Admin ⚙ → Databases → Add a database` — [cheatsheet](../cheatsheets/metabase-cheatsheet.md)'teki bilgilerle bağlanın.

**Görev:** Bağlantı başarılı olduktan sonra `Fact Sales`, `Dim Customer`,
`Dim Product`, `Dim Date` tablolarının göründüğünü doğrulayın.

---

## 2.2 İlk soru: Aylık Ciro Trendi

**+ New → Question** → `Fact Sales` → **Summarize**: Sum of revenue →
**Group by**: Date (by Month)

**Görev:** Sonucu çizgi grafiğe çevirin, "Aylık Ciro Trendi" adıyla kaydedin.

**Soru:** Kasım-Aralık aylarında bir sıçrama görüyor musunuz? (Veri
kasıtlı olarak bu aylarda daha yoğun üretildi — kampanya sezonu simülasyonu.)

---

## 2.3 İkinci soru: Bölge Bazında Performans

`Fact Sales`'i `Dim Customer` ile ilişkilendirip (Metabase otomatik JOIN
önerir) bölgeye göre toplam ciroyu bulun.

**Görev:** Bar grafik olarak kaydedin, "Bölge Performansı" adıyla kaydedin.

---

## 2.4 Üçüncü soru: İptal Oranı

**Görev:** `order_status = 'cancelled'` olan siparişlerin oranını hesaplayan
bir soru yazın (SQL Editor'e geçmeniz gerekebilir).

```sql
SELECT
  round(100.0 * count(*) FILTER (WHERE order_status = 'cancelled') / count(*), 1) AS iptal_orani
FROM bi.fact_sales;
```

---

## 2.5 Dashboard'u birleştirin

**+ New → Dashboard** → 3 sorunuzu ekleyin → bir **tarih aralığı filtresi**
ekleyip her karta bağlayın.

**Görev:** Filtreyi "son 3 ay" olarak ayarlayıp tüm kartların güncellendiğini doğrulayın.

**Soru:** Filtre bir karta bağlı değilse ne olur? Neden her kartı **elle**
bağlamanız gerekiyor (Superset'teki Native Filters ile karşılaştıracaksınız — Alıştırma 3)?

---

## ✅ Ne öğrendik

- Metabase'de bir soru, agregasyon + gruplama + filtre üçlüsüyle kurulur —
  SQL bilmeden de üretilebilir.
- Dashboard filtreleri **kartlara elle bağlanmalıdır** — bu Metabase'in
  basitliğinin bir maliyeti.
- Aynı veriden farklı sorular üretip birleştirmek, tek bir karmaşık
  sorgudan çok daha esnektir.

📎 [Çözüm](./solutions/02-metabase-dashboard.md)
