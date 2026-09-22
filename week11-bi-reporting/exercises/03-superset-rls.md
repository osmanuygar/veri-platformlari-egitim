# Alıştırma 3: Superset + Satır Düzeyi Güvenlik

**Süre:** ~35 dakika

---

## 3.1 Veri kaynağını bağlayın

[Cheatsheet](../cheatsheets/superset-cheatsheet.md)'teki bağlantı dizesiyle
Superset'e Postgres'i bağlayın, `bi.fact_sales` üzerinde bir dataset oluşturun.

---

## 3.2 SQL Lab ile keşif

```sql
SELECT c.region, p.category, sum(f.revenue) AS ciro
FROM bi.fact_sales f
JOIN bi.dim_customer c ON c.customer_key = f.customer_key
JOIN bi.dim_product p ON p.product_key = f.product_key
WHERE f.order_status <> 'cancelled'
GROUP BY 1, 2
ORDER BY ciro DESC;
```

**Görev:** Bu sorguyu SQL Lab'da çalıştırıp **Save as new dataset** ile
kaydedin — Metabase'de bunu ayrı ayrı sorular kurarak yapardınız, burada
tek bir SQL ile hazırlayıp chart'lara temel oluşturuyorsunuz.

---

## 3.3 Chart ve Dashboard

**Görev:** 3.2'deki dataset üzerinden bir **heatmap** (bölge × kategori)
chart'ı oluşturun. Bir dashboard'a ekleyip **Native Filter** (bölge seçici)
ekleyin.

**Soru:** Native Filter eklediğinizde, Metabase'deki gibi her chart'a elle
bağlamanız gerekti mi? Superset'in varsayılan davranışı ne?

---

## 3.4 Satır Düzeyi Güvenlik kuralı

`bi.region_managers` tablosunda 3 kullanıcı-bölge eşlemesi var:

```
marmara_muduru  → Marmara
ege_muduru      → Ege
akdeniz_muduru  → Akdeniz
```

**Görev:** Superset'te bu 3 kullanıcıyı oluşturun (**Settings → List Users**),
sonra **Settings → Row Level Security → + Rule** ile bir kural kurun:

```
Clause: region = (SELECT region FROM bi.region_managers WHERE username = current_username())
```

(Ya da basitleştirilmiş: kullanıcı adını doğrudan bölgeyle eşleyen bir CASE ifadesi.)

**Görev:** `marmara_muduru` olarak giriş yapıp aynı dashboard'u açın.

**Soru:** Sadece Marmara verisini mi görüyorsunuz? Bu kural, dashboard'un
**tasarımından bağımsız** olarak mı çalışıyor — yani dashboard'u değiştirmeden
farklı kullanıcılar farklı veri mi görüyor?

---

## 3.5 RLS'nin gücü ve sınırı

**Soru:** RLS kuralı veritabanı sorgusuna otomatik `WHERE` ekliyor. Bu
yaklaşımın, "her bölge için ayrı bir dashboard kopyası" oluşturmaya göre
avantajı nedir? (İpucu: 10 bölge olsaydı, 10 ayrı dashboard'u güncel
tutmanın maliyetini düşünün.)

---

## ✅ Ne öğrendik

- SQL Lab, karmaşık çok-tablolu sorguları tek seferde hazırlayıp dataset
  olarak kaydetmenin yolu — Metabase'in GUI-öncelikli yaklaşımından farklı.
- Superset'in Native Filters'ı varsayılan olarak **tüm** chart'lara
  uygulanır — Metabase'deki elle bağlama adımına gerek yok.
- Row-Level Security, **tek bir dashboard tasarımıyla**, kullanıcıya göre
  otomatik farklı veri göstermenin ölçeklenebilir yoludur.

📎 [Çözüm](./solutions/03-superset-rls.md)
