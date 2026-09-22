# Alıştırma 3: Maskeleme ve Rol Bazlı Erişim

**Süre:** ~30 dakika

---

## 3.1 Ham veriyi inceleyin

```bash
docker exec week12_postgres psql -U dg_user -d dg_db -c "SELECT id, full_name, tckn, email, phone, birth_date FROM raw.customers LIMIT 5;"
```

**Görev:** Bu sütunlardan hangileri **doğrudan** kimliklendirici (direct
identifier — tek başına kişiyi belirler), hangileri **dolaylı**
kimliklendirici (indirect identifier — başka bilgilerle birleşince
kişiyi belirleyebilir)?

| Sütun | Doğrudan / Dolaylı / Hassas değil | Gerekçe |
|---|---|---|
| `full_name` | | |
| `tckn` | | |
| `email` | | |
| `phone` | | |
| `birth_date` | | |
| `city` | | |
| `income_band` | | |

---

## 3.2 Hazır maskelenmiş görünümü inceleyin

```bash
docker exec week12_postgres psql -U dg_user -d dg_db -c "SELECT * FROM marts.customers_masked LIMIT 5;"
```

**Görev:** `init/01-schema.sql`'deki `customers_masked` view'ının SQL'ini
okuyun. Her sütun için hangi maskeleme TEKNİĞİ kullanılmış
(kısaltma/yıldızlama, kısmi gösterim, genelleştirme)?

**Soru:** `birth_year_only` sütunu tam doğum tarihi yerine sadece **yılı**
gösteriyor. Bu bir maskeleme tekniği mi yoksa **genelleştirme**
(generalization) mi? İkisi arasındaki fark nedir — genelleştirme, veriyi
tamamen gizlemek yerine ne yapar?

---

## 3.3 Kendi maskelenmiş görünümünüzü yazın

**Görev:** `orders` tablosunu da içeren, müşteri toplam harcamasını
gösteren ama **hiçbir PII sütunu içermeyen** yeni bir view yazın:

```sql
CREATE VIEW marts.customer_spend_anonymous AS
SELECT
    c.id AS customer_ref,        -- gerçek id yerine referans (isterseniz hash'leyin)
    c.city,
    c.income_band,
    count(o.id) AS order_count,
    sum(o.amount) AS total_spent
FROM raw.customers c
LEFT JOIN raw.orders o ON o.customer_id = c.id
GROUP BY c.id, c.city, c.income_band;
```

**Soru:** Bu view'da `full_name`, `tckn`, `email` hiç yok. Yine de,
`city` + `income_band` + `total_spent` kombinasyonu, küçük bir şehirde
**tek bir kişiyi** işaret edebilir mi? (İpucu: k-anonimlik kavramı —
bir kombinasyonu paylaşan en az kaç kişi olmalı?)

---

## 3.4 Rol bazlı erişim kurun

```sql
-- init/01-schema.sql'de zaten tanımlı roller: analyst_role, support_role
-- support_role'e SADECE iletişim bilgisi (maskelenmemiş telefon/email) erişimi verin,
-- finansal veriye (income_band, orders) erişimi OLMASIN

GRANT USAGE ON SCHEMA raw TO support_role;
GRANT SELECT (id, full_name, email, phone) ON raw.customers TO support_role;
```

**Görev:** Bu GRANT'i çalıştırın. Ardından `support_role`'e income_band
sorgulatmayı deneyin — reddedilmeli.

```sql
-- Test: gercek bir kullanıcı olmadan rol yetkisini simüle etmek için
SET ROLE support_role;
SELECT income_band FROM raw.customers;   -- HATA vermeli
RESET ROLE;
```

**Soru:** Sütun bazlı GRANT (`GRANT SELECT (col1, col2) ON ...`) ile
tablo bazlı GRANT arasındaki fark nedir? Destek ekibinin finansal veriye
**hiç ihtiyacı yoksa**, tablo bazlı erişim vermek neden gereksiz bir risktir?

---

## 3.5 Denetim izi (audit trail)

**Soru:** Kim, ne zaman, hangi müşterinin ham (maskelenmemiş) verisine
eriştiğini kaydetmek isteseniz, PostgreSQL'de hangi mekanizmaları
kullanırdınız? (İpucu: `pg_audit` eklentisi, ya da uygulama katmanında
her sorguyu loglamak)

---

## ✅ Ne öğrendik

- Doğrudan kimliklendiriciler (TCKN, email) her zaman maskelenmeli;
  dolaylı kimliklendiriciler (şehir + gelir bandı gibi) **birleştiğinde**
  risk oluşturabilir (k-anonimlik).
- Maskeleme teknikleri: kısmi gösterim (`***@example.com`), genelleştirme
  (tam tarih yerine yıl), tokenizasyon (id yerine referans).
- Sütun bazlı GRANT, "en az ayrıcalık" (least privilege) ilkesinin
  PostgreSQL'deki somut uygulamasıdır.
- Maskeleme tek başına yeterli değildir — **kimin eriştiği** de
  kayıt altına alınmalıdır (audit trail).

📎 [Çözüm](./solutions/03-masking-rbac.md)
