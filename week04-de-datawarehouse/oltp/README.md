# OLTP - Online Transaction Processing

## 📚 İçindekiler
- [OLTP Nedir?](#oltp-nedir)
- [Dosya Yapısı](#dosya-yapısı)
- [Kurulum](#kurulum)
- [Veritabanı Şeması](#veritabanı-şeması)
- [Örnek Sorgular](#örnek-sorgular)
- [Alıştırmalar](#alıştırmalar)

## 📖 OLTP Nedir?

**OLTP (Online Transaction Processing)** günlük işlemleri yöneten veritabanı sistemidir.

### Özellikler
- ✅ **Hızlı İşlemler:** INSERT, UPDATE, DELETE milisaniyeler içinde
- ✅ **ACID Garantisi:** Transaction güvenliği
- ✅ **Normalizasyon:** 3NF/BCNF - veri tekrarı yok
- ✅ **Çok Kullanıcı:** Binlerce eş zamanlı işlem
- ✅ **Real-time:** Anlık veri güncellemesi

### Kullanım Alanları
- E-ticaret sipariş sistemleri
- Banka işlemleri
- Rezervasyon sistemleri
- CRM uygulamaları

## 📂 Dosya Yapısı

```
oltp/
├── README.md                    # Bu dosya
└── init/                        # PostgreSQL init scriptleri
    ├── 01-schema.sql           # Tablo yapıları, trigger'lar
    ├── 02-sample-data.sql      # Örnek veriler (30 sipariş)
    └── 03-generate-more-data.sql # Ek veri üretimi (100+ sipariş)
```

## 🚀 Kurulum

### 1. Docker Container'ı Başlat

```bash
cd week04-de-datawarehouse

# OLTP PostgreSQL'i başlat
docker-compose up -d postgres-oltp

# Hazır olmasını bekle
docker exec postgres_oltp pg_isready -U oltp_user
```

### 2. Şemayı Yükle

```bash
# Schema ve tablolar
docker exec -i postgres_oltp psql -U oltp_user -d ecommerce_oltp < oltp/init/01-schema.sql

# Örnek veriler
docker exec -i postgres_oltp psql -U oltp_user -d ecommerce_oltp < oltp/init/02-sample-data.sql

# (Opsiyonel) Daha fazla veri
docker exec -i postgres_oltp psql -U oltp_user -d ecommerce_oltp < oltp/init/03-generate-more-data.sql
```

### 3. Bağlan ve Test Et

```bash
# psql ile bağlan
docker exec -it postgres_oltp psql -U oltp_user -d ecommerce_oltp

# Test sorgusu
SELECT COUNT(*) FROM orders;
```

## 🗄️ Veritabanı Şeması

### ER Diagram

```
┌─────────────┐       ┌──────────────┐       ┌──────────────┐
│  CUSTOMERS  │       │   ADDRESSES  │       │  CATEGORIES  │
├─────────────┤       ├──────────────┤       ├──────────────┤
│ customer_id │───┐   │ address_id   │   ┌───│ category_id  │
│ first_name  │   │   │ customer_id  │───┘   │ category_name│
│ last_name   │   │   │ city         │       │ parent_cat_id│
│ email       │   │   │ country      │       └──────────────┘
│ segment     │   │   └──────────────┘              │
└─────────────┘   │                                 │
                  │   ┌──────────────┐              │
                  └───│    ORDERS    │              │
                      ├──────────────┤              │
                      │ order_id     │              │
                      │ customer_id  │              │
                      │ order_date   │              │
                      │ total_amount │              │
                      │ order_status │              │
                      └──────┬───────┘              │
                             │                      │
                      ┌──────▼───────┐       ┌──────▼───────┐
                      │ ORDER_ITEMS  │       │  PRODUCTS    │
                      ├──────────────┤       ├──────────────┤
                      │ order_item_id│       │ product_id   │
                      │ order_id     │───────│ product_name │
                      │ product_id   │       │ category_id  │
                      │ quantity     │       │ unit_price   │
                      │ line_total   │       │ stock        │
                      └──────────────┘       └──────────────┘
```

### Tablo Detayları

#### 1. **customers** (Müşteriler)
```sql
- customer_id (PK)
- first_name, last_name
- email (UNIQUE)
- customer_segment (Standard, Premium, VIP)
- total_orders, total_spent
```

#### 2. **products** (Ürünler)
```sql
- product_id (PK)
- category_id (FK → categories)
- product_name
- sku (UNIQUE)
- unit_price, cost_price
- stock_quantity
```

#### 3. **orders** (Siparişler)
```sql
- order_id (PK)
- customer_id (FK → customers)
- order_number (UNIQUE)
- order_date
- subtotal, discount, tax, shipping, total_amount
- order_status (Pending, Processing, Shipped, Delivered, Cancelled)
- payment_status (Pending, Paid, Failed, Refunded)
```

#### 4. **order_items** (Sipariş Kalemleri)
```sql
- order_item_id (PK)
- order_id (FK → orders)
- product_id (FK → products)
- quantity
- unit_price (sipariş anındaki fiyat)
- discount_percent
- line_total (calculated)
```

### Trigger'lar

1. **decrease_stock:** Sipariş verilince stok düşer
2. **restore_stock:** Sipariş iptal edilince stok geri yüklenir
3. **calculate_order_total:** Sipariş toplamı otomatik hesaplanır
4. **update_customer_stats:** Müşteri istatistikleri güncellenir
5. **update_timestamp:** Güncelleme zamanı otomatik set edilir

## 💻 Örnek Sorgular

### Basit Sorgular

```sql
-- 1. Tüm müşteriler
SELECT * FROM customers LIMIT 10;

-- 2. Aktif ürünler
SELECT product_name, unit_price, stock_quantity 
FROM products 
WHERE is_active = true
ORDER BY unit_price DESC;

-- 3. Son 10 sipariş
SELECT order_number, order_date, total_amount, order_status
FROM orders
ORDER BY order_date DESC
LIMIT 10;

-- 4. Bir müşterinin siparişleri
SELECT 
    o.order_number,
    o.order_date,
    o.total_amount,
    o.order_status
FROM orders o
WHERE o.customer_id = 1
ORDER BY o.order_date DESC;
```

### İleri Seviye Sorgular

```sql
-- 5. Sipariş detayları (JOIN)
SELECT 
    o.order_number,
    c.first_name || ' ' || c.last_name as customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.line_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_id = 1;

-- 6. Kategori bazında satış
SELECT 
    c.category_name,
    COUNT(DISTINCT o.order_id) as siparis_sayisi,
    SUM(oi.quantity) as toplam_adet,
    SUM(oi.line_total) as toplam_gelir
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.category_id, c.category_name
ORDER BY toplam_gelir DESC;

-- 7. En iyi müşteriler (Top 10)
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    c.customer_segment,
    COUNT(o.order_id) as siparis_sayisi,
    SUM(o.total_amount) as toplam_harcama,
    AVG(o.total_amount) as ortalama_sepet
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.first_name, c.last_name, c.customer_segment
ORDER BY toplam_harcama DESC
LIMIT 10;

-- 8. Stok durumu
SELECT 
    p.product_name,
    p.stock_quantity,
    p.reorder_level,
    CASE 
        WHEN p.stock_quantity = 0 THEN 'Tükendi'
        WHEN p.stock_quantity <= p.reorder_level THEN 'Düşük Stok'
        ELSE 'Yeterli'
    END as durum
FROM products p
WHERE p.is_active = true
ORDER BY p.stock_quantity ASC;

-- 9. Günlük satış trendi
SELECT 
    DATE(order_date) as tarih,
    COUNT(*) as siparis_sayisi,
    SUM(total_amount) as gunluk_ciro,
    AVG(total_amount) as ortalama_sepet
FROM orders
WHERE order_status != 'Cancelled'
  AND order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(order_date)
ORDER BY tarih DESC;

-- 10. Sipariş durumu dağılımı
SELECT 
    order_status,
    payment_status,
    COUNT(*) as adet,
    SUM(total_amount) as toplam_tutar
FROM orders
GROUP BY ROLLUP(order_status, payment_status)
ORDER BY order_status, payment_status;
```

### View'ları Kullan

```sql
-- Müşteri özeti
SELECT * FROM v_customer_summary ORDER BY total_spent DESC LIMIT 10;

-- Ürün stok durumu
SELECT * FROM v_product_stock_status WHERE stock_status = 'Low Stock';

-- Günlük satış
SELECT * FROM v_daily_sales ORDER BY sale_date DESC LIMIT 7;

-- RFM Analizi
SELECT * FROM v_rfm_analysis WHERE customer_segment_rfm = 'Champions';
```

## 🎯 Alıştırmalar

### Temel Seviye

**Alıştırma 1:** Belirli bir kategorideki tüm ürünleri listeleyin
```sql
-- Kategori: Elektronik
-- Gösterilecekler: ürün adı, fiyat, stok
```

**Alıştırma 2:** Bir müşterinin tüm siparişlerini getirin
```sql
-- Müşteri: ahmet.yilmaz@email.com
-- Gösterilecekler: sipariş numarası, tarih, tutar, durum
```

**Alıştırma 3:** Bugün verilen siparişleri listeleyin
```sql
-- Bugünün siparişleri
-- Gösterilecekler: sipariş no, müşteri adı, tutar
```

### Orta Seviye

**Alıştırma 4:** Her müşterinin toplam harcamasını hesaplayın
```sql
-- Sadece teslim edilen siparişler
-- Segment bazında gruplayın
```

**Alıştırma 5:** En çok satılan 5 ürünü bulun
```sql
-- Adet bazında
-- Kategori bilgisi de gösterilsin
```

**Alıştırma 6:** Stok uyarısı raporu oluşturun
```sql
-- Stok <= reorder_level olan ürünler
-- Kategori bazında gruplayın
-- Stok değeri de hesaplansın (fiyat * stok)
```

### İleri Seviye

**Alıştırma 7:** Aylık büyüme oranını hesaplayın
```sql
-- Her ay için:
--   - Sipariş sayısı
--   - Toplam ciro
--   - Önceki aya göre % değişim
-- LAG window function kullanın
```

**Alıştırma 8:** Müşteri segmentasyonu yapın
```sql
-- RFM mantığıyla:
--   - Recency: Son sipariş tarihi
--   - Frequency: Toplam sipariş sayısı
--   - Monetary: Toplam harcama
-- NTILE kullanarak 5 gruba ayırın
```

**Alıştırma 9:** Product Affinity analizi
```sql
-- Hangi ürünler birlikte alınıyor?
-- Self JOIN kullanın
-- En az 3 kez birlikte alınmış olsun
```

**Alıştırma 10:** Cohort retention analizi
```sql
-- Her ayın cohort'u için:
--   - İlk ay kaç müşteri?
--   - Sonraki aylarda kaçı aktif?
--   - Retention rate hesaplayın
```

## 📊 OLTP Performans İpuçları

### Index Kullanımı
```sql
-- Sık kullanılan kolonlara index
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- Partial index (sadece aktif kayıtlar)
CREATE INDEX idx_active_products ON products(category_id) WHERE is_active = true;

-- EXPLAIN ile analiz
EXPLAIN ANALYZE
SELECT * FROM orders WHERE customer_id = 1;
```

### Transaction Örnekleri
```sql
-- Sipariş verme transaction'ı
BEGIN;

    -- 1. Sipariş oluştur
    INSERT INTO orders (customer_id, order_number, ...)
    VALUES (1, 'ORD-2025-9999', ...)
    RETURNING order_id;
    
    -- 2. Ürün ekle
    INSERT INTO order_items (order_id, product_id, quantity, ...)
    VALUES (999, 1, 2, ...);
    
    -- 3. Stok kontrolü
    SELECT stock_quantity FROM products WHERE product_id = 1;
    
    -- Hata varsa ROLLBACK, yoksa COMMIT
COMMIT;
```

### Best Practices
1. ✅ Her zaman transaction kullan
2. ✅ Foreign key constraint'leri tanımla
3. ✅ Index'leri akıllıca kullan (çok fazla yavaşlatır)
4. ✅ Trigger'ları dikkatli kullan
5. ✅ View'lar sadece okuma için

## 🔗 İlgili Dosyalar

- `../olap/` - OLAP veritabanı (ETL hedefi)
- `../etl/` - ETL pipeline (OLTP → OLAP)


## 🎓 Sonraki Adım

OLTP veritabanını anladıktan sonra:
1. ✅ OLAP klasörüne geçin
2. ✅ Dimensional modeling öğrenin
3. ✅ ETL pipeline oluşturun

**İyi çalışmalar! 🚀**