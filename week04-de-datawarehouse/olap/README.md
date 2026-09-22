# OLAP - Online Analytical Processing

## 📚 İçindekiler
- [OLAP Nedir?](#olap-nedir)
- [Dosya Yapısı](#dosya-yapısı)
- [Kurulum](#kurulum)
- [Dimensional Modeling](#dimensional-modeling)
- [Star Schema](#star-schema)
- [Örnek Sorgular](#örnek-sorgular)
- [Best Practices](#best-practices)

## 📖 OLAP Nedir?

**OLAP (Online Analytical Processing)** veri analizi ve raporlama için optimize edilmiş veritabanı sistemidir.

### Özellikler
- ✅ **Kompleks Sorgular:** Milyonlarca kayıt üzerinde agregasyon
- ✅ **Denormalizasyon:** Star/Snowflake schema
- ✅ **Eventual Consistency:** Real-time olması gerekmez
- ✅ **Tarihsel Veri:** SCD (Slowly Changing Dimensions)
- ✅ **Hızlı Okuma:** Index ve materialized view'lar

### Kullanım Alanları
- Executive dashboard'lar
- Trend analizleri
- KPI takibi
- BI raporları
- Data mining

## 📂 Dosya Yapısı

```
olap/
├── README.md                      # Bu dosya
└── init/                          # PostgreSQL init scriptleri
    ├── 01-dimensions.sql         # Dimension tabloları
    ├── 02-facts.sql              # Fact tabloları
    └── 03-star-schema.sql        # Örnek sorgular
```

## 🚀 Kurulum

### 1. Docker Container'ı Başlat

```bash
cd week04-de-datawarehouse

# OLAP PostgreSQL'i başlat
docker-compose up -d postgres-olap

# Hazır olmasını bekle
docker exec postgres_olap pg_isready -U olap_user
```

### 2. Dimension Tabloları Oluştur

```bash
# Dimension'ları yükle (5 tablo + date dimension doldurulur)
docker exec -i postgres_olap psql -U olap_user -d ecommerce_olap < olap/init/01-dimensions.sql
```

**Oluşturulan Tablolar:**
- ✅ dim_date (1,095 satır - 2024-2026 arası)
- ✅ dim_customer (SCD Type 2)
- ✅ dim_product (SCD Type 2)
- ✅ dim_store (SCD Type 1)
- ✅ dim_payment_method

### 3. Fact Tabloları Oluştur

```bash
# Fact tabloları ve view'ları yükle
docker exec -i postgres_olap psql -U olap_user -d ecommerce_olap < olap/init/02-facts.sql
```

**Oluşturulan Tablolar:**
- ✅ fact_sales (transaction fact)
- ✅ fact_daily_sales_summary (aggregate fact)
- ✅ fact_promotion_coverage (factless fact)
- ✅ fact_inventory_snapshot (snapshot fact)

**View'lar:**
- ✅ v_sales_summary
- ✅ v_monthly_sales_trend
- ✅ v_category_performance
- ✅ v_customer_segment_analysis
- ✅ v_daily_performance

### 4. Bağlan ve Test Et

```bash
# psql ile bağlan
docker exec -it postgres_olap psql -U olap_user -d ecommerce_olap

# Dimension'ları kontrol et
SELECT COUNT(*) FROM dim_date;
-- 1095 satır olmalı (3 yıl)

# Test sorgusu
SELECT * FROM dim_date WHERE full_date = CURRENT_DATE;
```

## 🏗️ Dimensional Modeling

### Star Schema Mimarisi

```
         dim_date          dim_customer        dim_product
             │                   │                   │
         date_key          customer_key         product_key
             │                   │                   │
             └───────────────────┼───────────────────┘
                                 │
                         ┌───────▼────────┐
                         │   FACT_SALES   │
                         ├────────────────┤
                         │ • quantity     │
                         │ • line_total   │
                         │ • gross_profit │
                         └───────┬────────┘
                                 │
                    ┌────────────┼────────────┐
                    │                         │
              store_key              payment_method_key
                    │                         │
             dim_store              dim_payment_method
```

### Fact vs Dimension

#### Fact Tablosu (Merkez)
**Özellikler:**
- Measures (metrikler) içerir: quantity, amount, profit
- Foreign key'ler dimension'lara referans verir
- Çok sayıda kayıt (milyonlar)
- Narrow (az kolon), tall (çok satır)

**Örnek:**
```sql
fact_sales:
- sales_fact_key (PK)
- date_key (FK)
- customer_key (FK)
- product_key (FK)
- quantity (measure)
- line_total (measure)
- gross_profit (measure)
```

#### Dimension Tablosu (Çevre)
**Özellikler:**
- Bağlam bilgisi: kim, ne, nerede, ne zaman
- Tanımlayıcı alanlar
- Az sayıda kayıt (binler)
- Wide (çok kolon), short (az satır)

**Örnek:**
```sql
dim_customer:
- customer_key (PK - surrogate)
- customer_id (natural key)
- full_name
- age, age_group
- city, region
- customer_segment
```

### SCD (Slowly Changing Dimensions)

#### Type 1: Overwrite (Üzerine Yaz)
```sql
-- Değişiklik olunca direkt güncelle
UPDATE dim_store 
SET manager_name = 'Yeni Müdür'
WHERE store_id = 1;
```
**Kullanım:** Manager adı, telefon gibi tarihsel takip gerektirmeyen

#### Type 2: Historical Tracking (Tarihsel Takip)
```sql
-- Eski kaydı kapat
UPDATE dim_customer
SET expiry_date = CURRENT_DATE, is_current = FALSE
WHERE customer_id = 1 AND is_current = TRUE;

-- Yeni kayıt ekle
INSERT INTO dim_customer (customer_id, segment, effective_date, is_current)
VALUES (1, 'VIP', CURRENT_DATE, TRUE);
```
**Kullanım:** Segment, fiyat gibi tarihsel değişimleri takip edilmesi gereken

### Grain (Tanecik) Nedir?

**Grain = Fact tablosunda bir satır neyi temsil eder?**

Örnekler:
- ✅ **Transaction grain:** Bir sipariş kalemi (order line item)
- ✅ **Daily snapshot:** Günlük stok durumu
- ✅ **Monthly aggregate:** Aylık satış özeti

**Grain belirleme kritik!** Tüm dimension'lar ve measure'lar grain ile uyumlu olmalı.

## ⭐ Star Schema

### Avantajları
- ✅ Basit JOIN'ler (3-6 tablo)
- ✅ Hızlı sorgular
- ✅ BI tool'lar için ideal
- ✅ Anlaşılır yapı

### Dezavantajları
- ❌ Veri tekrarı (denormalized)
- ❌ Disk alanı kullanımı

### Star vs Snowflake

| Özellik | Star Schema | Snowflake Schema |
|---------|-------------|------------------|
| Dimension yapısı | Denormalized | Normalized |
| JOIN sayısı | Az (3-6) | Çok (10+) |
| Sorgu hızı | Hızlı | Yavaş |
| Disk kullanımı | Fazla | Az |
| Güncellemeler | Zor | Kolay |
| **Ne zaman?** | **BI, raporlama** | **Veri tutarlılığı kritik** |

## 💻 Örnek Sorgular

### 1. Basit Dimension Sorgusu

```sql
-- Müşteri bazında toplam satış
SELECT 
    c.full_name,
    c.customer_segment,
    COUNT(DISTINCT f.order_number) as siparisler,
    SUM(f.line_total) as toplam_harcama
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE c.is_current = TRUE
  AND f.order_status = 'Delivered'
GROUP BY c.customer_key, c.full_name, c.customer_segment
ORDER BY toplam_harcama DESC
LIMIT 10;
```

### 2. Zaman Serisi Analizi

```sql
-- Aylık satış trendi
SELECT 
    d.year,
    d.month_name,
    COUNT(DISTINCT f.order_number) as siparisler,
    SUM(f.line_total) as ciro,
    AVG(f.line_total) as ortalama_sepet
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2025
  AND f.order_status = 'Delivered'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.month;
```

### 3. Multi-Dimensional Analiz

```sql
-- Kategori x Segment x Ay
SELECT 
    d.month_name,
    p.category_name,
    c.customer_segment,
    SUM(f.line_total) as ciro,
    COUNT(DISTINCT f.customer_key) as musteriler
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE d.year = 2025
  AND p.is_current = TRUE
  AND c.is_current = TRUE
  AND f.order_status = 'Delivered'
GROUP BY d.month, d.month_name, p.category_name, c.customer_segment
ORDER BY ciro DESC;
```

### 4. YoY Growth (Yıllık Büyüme)

```sql
-- Yıllık büyüme oranı
SELECT 
    d.year,
    d.month_name,
    SUM(f.line_total) as ciro,
    LAG(SUM(f.line_total), 12) OVER (ORDER BY d.year, d.month) as prev_year_ciro,
    ROUND(
        (SUM(f.line_total) - LAG(SUM(f.line_total), 12) OVER (ORDER BY d.year, d.month))
        / LAG(SUM(f.line_total), 12) OVER (ORDER BY d.year, d.month) * 100,
        2
    ) as yoy_growth_pct
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.order_status = 'Delivered'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
```

### 5. View Kullanımı

```sql
-- Hazır view'ları kullan (hızlı!)
SELECT * FROM v_monthly_sales_trend;

SELECT * FROM v_category_performance
ORDER BY total_revenue DESC
LIMIT 10;

SELECT * FROM v_customer_segment_analysis;
```

### 6. Materialized View (Süper Hızlı)

```sql
-- Önceden hesaplanmış KPI'lar
SELECT * FROM mv_monthly_kpi
WHERE year = 2025;

-- Refresh (günde 1 kez çalıştır)
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_monthly_kpi;
```

## 📊 OLAP Küp Operasyonları

### Drill-Down (Detaya İn)
```sql
-- Yıl -> Çeyrek -> Ay -> Gün
SELECT 
    d.year, d.quarter_name, d.month_name,
    SUM(f.line_total) as ciro
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY CUBE(d.year, d.quarter_name, d.month_name);
```

### Roll-Up (Özet Çıkar)
```sql
-- Gün -> Ay -> Çeyrek -> Yıl
SELECT 
    d.year, d.quarter_name,
    SUM(f.line_total) as ciro
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY ROLLUP(d.year, d.quarter_name);
```

### Slice (Dilimleme)
```sql
-- Sadece 2025 Q1'e odaklan
SELECT * FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2025 AND d.quarter = 1;
```

### Dice (Küp Kesme)
```sql
-- 2025 Q1, VIP müşteriler, Elektronik
SELECT * FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_product p ON f.product_key = p.product_key
WHERE d.year = 2025 AND d.quarter = 1
  AND c.customer_segment = 'VIP'
  AND p.category_name = 'Elektronik';
```

## 🎯 Best Practices

### Dimension Tasarımı
```sql
✅ DO:
- Surrogate key kullan (SERIAL)
- Natural key'i sakla
- Denormalize et (performance için)
- SCD Type 2 değişimler için
- Unknown/Not Applicable kayıtları ekle

❌ DON'T:
- Measure koyma (fact'te olmalı)
- NULL bırakma
- Çok normalize etme (snowflake'e dönüşür)
```

### Fact Tasarımı
```sql
✅ DO:
- Additive measures tercih et (SUM yapılabilir)
- Grain'i net belirle
- Foreign key'lere index koy
- Partition'la (date bazlı)

❌ DON'T:
- Text alanlar ekleme
- NULL FK bırakma
- Calculated field store etme
```

### Performance
```sql
-- Index stratejisi
CREATE INDEX idx_fact_sales_date ON fact_sales(date_key);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_key);
CREATE INDEX idx_fact_sales_date_customer ON fact_sales(date_key, customer_key);

-- Partition (büyük fact'ler için)
CREATE TABLE fact_sales_2025_q1 PARTITION OF fact_sales
FOR VALUES FROM ('20250101') TO ('20250401');

-- Materialized View (sık kullanılan agregasyonlar)
CREATE MATERIALIZED VIEW mv_daily_summary AS
SELECT date_key, SUM(line_total) as daily_total
FROM fact_sales
GROUP BY date_key;
```

## 🔗 İlgili Dosyalar

- `../oltp/` - Kaynak OLTP veritabanı
- `../etl/` - ETL pipeline (OLTP → OLAP)
- `03-star-schema.sql` - 10+ örnek sorgu

## 🎓 Sonraki Adım

OLAP yapısını anladıktan sonra:
1. ✅ ETL pipeline ile veri yükle
2. ✅ Analitik sorgular yaz
3. ✅ BI tool'da dashboard oluştur
4. ✅ Materialized view'ları optimize et

**İyi çalışmalar! 🚀**