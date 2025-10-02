# Hafta 4: Veri Ambarları, Veri Gölleri ve Mimariler

## 📚 İçindekiler

1. [OLTP vs OLAP](#1-oltp-vs-olap)
2. [Veri Ambarı (Data Warehouse)](#2-veri-ambarı-data-warehouse)
3. [Boyutsal Modelleme: Star ve Snowflake Şemaları](#3-boyutsal-modelleme-star-ve-snowflake-şemaları)
4. [ETL vs ELT](#4-etl-vs-elt)
5. [Veri Gölü (Data Lake)](#5-veri-gölü-data-lake)
6. [Modern Veri Mimarileri](#6-modern-veri-mimarileri)
7. [Veri Kalitesi ve Yönetişimi](#7-veri-kalitesi-ve-yönetişimi)
8. [Veri Görselleştirme](#8-veri-görselleştirme)
9. [Pratik Uygulamalar](#9-pratik-uygulamalar)
10. [Alıştırmalar](#10-alıştırmalar)

---

## 1. OLTP vs OLAP

### 1.1 OLTP (Online Transaction Processing)

**Tanım:** Günlük operasyonel işlemlerin yürütüldüğü sistem

#### Özellikler
```
✅ Kısa, hızlı transaction'lar
✅ INSERT, UPDATE, DELETE ağırlıklı
✅ Çok sayıda kullanıcı
✅ Normalizeşmiş veri
✅ Anlık veri tutarlılığı
✅ Düşük latency (< 100ms)
```

#### Örnek Sorgular
```sql
-- Sipariş oluşturma
INSERT INTO orders (customer_id, order_date, total)
VALUES (12345, CURRENT_DATE, 450.00);

-- Stok güncelleme
UPDATE products 
SET stock_quantity = stock_quantity - 5
WHERE product_id = 789;

-- Müşteri bilgisi görüntüleme
SELECT * FROM customers WHERE customer_id = 12345;
```

#### Kullanım Alanları
- E-ticaret siteleri
- Banka işlemleri
- CRM sistemleri
- Rezervasyon sistemleri
- ERP uygulamaları

### 1.2 OLAP (Online Analytical Processing)

**Tanım:** Analiz ve raporlama için optimize edilmiş sistem

#### Özellikler
```
✅ Kompleks, uzun sorgular
✅ SELECT (okuma) ağırlıklı
✅ Az sayıda kullanıcı (analistler)
✅ Denormalize veri
✅ Tarihsel veri
✅ Yüksek throughput
```

#### Örnek Sorgular
```sql
-- Yıllık satış trendi
SELECT 
    EXTRACT(YEAR FROM order_date) as year,
    EXTRACT(MONTH FROM order_date) as month,
    SUM(total_amount) as monthly_sales,
    COUNT(DISTINCT customer_id) as unique_customers
FROM orders
WHERE order_date >= '2020-01-01'
GROUP BY year, month
ORDER BY year, month;

-- Ürün kategorisi analizi
SELECT 
    c.category_name,
    COUNT(DISTINCT o.order_id) as order_count,
    SUM(oi.quantity * oi.unit_price) as revenue,
    AVG(oi.quantity * oi.unit_price) as avg_order_value
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY c.category_name
ORDER BY revenue DESC;
```

#### Kullanım Alanları
- İş zekası (BI) dashboards
- Satış analizleri
- Trend raporları
- Veri madenciliği
- Forecasting

### 1.3 Detaylı Karşılaştırma

| Özellik | OLTP | OLAP                           |
|---------|------|--------------------------------|
| **Amaç** | Operasyonel | Analitik                       |
| **İşlem Türü** | INSERT, UPDATE, DELETE | SELECT (kompleks)              |
| **Veri Hacmi** | GB - TB | TB - PB                        |
| **Sorgu Karmaşıklığı** | Basit | Kompleks                       |
| **Response Time** | Milisaniyeler | Saniyeler-Dakikalar            |
| **Kullanıcı Sayısı** | Binlerce | Onlarca                        |
| **Veri Güncelliği** | Gerçek zamanlı | Periyodik (günlük, saatlik)    |
| **Normalizasyon** | Yüksek (3NF) | Düşük (Denormalize)            |
| **Yedekleme** | Sık (her gün) | Nadiren                        |
| **Veri Yaşı** | Güncel (son 3-12 ay) | Tarihsel (yıllar)              |
| **Örnek** | MySQL, PostgreSQL | Clcikhouse, Redshift, BigQuery |

### 1.4 OLTP'den OLAP'a Veri Akışı

```
OLTP (Operasyonel DB)
    ↓ ETL/ELT
Data Warehouse (OLAP)
    ↓ Transformation
Data Marts (Departman bazlı)
    ↓ Visualization
BI Dashboards
```

---

## 2. Veri Ambarı (Data Warehouse)

### 2.1 Tanım

**Data Warehouse:** Farklı kaynaklardan gelen verilerin birleştirildiği, analiz ve raporlama için optimize edilmiş merkezi veri deposu.

#### Bill Inmon'un Tanımı (1990)
```
Veri Ambarı:
1. Subject-Oriented (Konu odaklı)
2. Integrated (Entegre)
3. Time-Variant (Zaman bazlı)
4. Non-Volatile (Değişmez)
```

### 2.2 Özellikler

#### 1. Subject-Oriented (Konu Odaklı)
```
❌ OLTP: Uygulama odaklı (Sipariş sistemi, Stok sistemi)
✅ OLAP: İş konusu odaklı (Satışlar, Müşteriler, Ürünler)
```

#### 2. Integrated (Entegre)
```
Farklı Kaynaklar:
- CRM (Salesforce)
- ERP (SAP)
- E-ticaret platformu
- Excel dosyaları
↓ ETL
Tek, tutarlı format
```

#### 3. Time-Variant (Zaman Bazlı)
```sql
-- Her kayıt zaman damgası içerir
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_id INT,
    name VARCHAR(100),
    valid_from DATE,
    valid_to DATE,
    is_current BOOLEAN
);
```

#### 4. Non-Volatile (Değişmez)
```
❌ OLTP: UPDATE/DELETE sık
✅ OLAP: Sadece INSERT (geçmiş korunur)
```

### 2.3 Veri Ambarı Mimarisi

```
┌─────────────────────────────────────┐
│        Data Sources                 │
│  (OLTP, Files, APIs, Streams)       │
└───────────────┬─────────────────────┘
                ↓
┌─────────────────────────────────────┐
│        ETL/ELT Layer                │
│  (Extract, Transform, Load)         │
└───────────────┬─────────────────────┘
                ↓
┌─────────────────────────────────────┐
│      Staging Area                   │
│  (Temporary storage)                │
└───────────────┬─────────────────────┘
                ↓
┌─────────────────────────────────────┐
│    Data Warehouse (Core)            │
│  - Fact Tables                      │
│  - Dimension Tables                 │
└───────────────┬─────────────────────┘
                ↓
┌─────────────────────────────────────┐
│       Data Marts                    │
│  (Department-specific)              │
│  Sales Mart | Marketing Mart        │
└───────────────┬─────────────────────┘
                ↓
┌─────────────────────────────────────┐
│    BI Tools & Reports               │
│  (Tableau, Power BI, Looker)        │
└─────────────────────────────────────┘
```

### 2.4 Popüler Data Warehouse Çözümleri

#### Snowflake
```
✅ Cloud-native
✅ Ayrık storage ve compute
✅ Otomatik scaling
✅ Zero-copy cloning
✅ Time travel
❌ Pahalı olabilir
```

#### Amazon Redshift
```
✅ AWS entegrasyonu
✅ Columnar storage
✅ Massively parallel
✅ Spectrum (S3 query)
❌ Manual scaling
```

#### Google BigQuery
```
✅ Serverless
✅ Petabyte ölçeği
✅ ML entegrasyonu
✅ Streaming insert
❌ SQL dialect farklı
```

#### Azure Synapse Analytics
```
✅ OLAP + OLTP (Hybrid)
✅ Azure entegrasyonu
✅ Spark integration
✅ Serverless veya provisioned
```

---

## 3. Boyutsal Modelleme: Star ve Snowflake Şemaları

### 3.1 Boyutsal Modelleme Nedir?

**Tanım:** OLAP için optimize edilmiş veri modelleme tekniği. Ralph Kimball tarafından geliştirildi.

#### Temel Kavramlar

**Fact Table (Olgu Tablosu):**
- İşlem/olay verileri
- Ölçülebilir metrikler (sales, quantity, amount)
- Foreign key'ler (boyutlara referans)
- Çok sayıda satır (milyonlar, milyarlar)

**Dimension Table (Boyut Tablosu):**
- Tanımlayıcı bilgiler
- Filtreleme ve gruplama için
- Az sayıda satır (binler)
- Zengin metin alanları

### 3.2 Star Schema (Yıldız Şeması)

#### Yapı
```
      Dim_Date
          ↓
Dim_Customer → FACT_Sales ← Dim_Product
          ↑
      Dim_Store
```

#### Örnek: E-Ticaret Satış Veri Ambarı

**Fact Tablosu:**
```sql
CREATE TABLE fact_sales (
    sale_id BIGINT PRIMARY KEY,
    
    -- Foreign Keys (Boyutlara referanslar)
    date_key INT REFERENCES dim_date(date_key),
    customer_key INT REFERENCES dim_customer(customer_key),
    product_key INT REFERENCES dim_product(product_key),
    store_key INT REFERENCES dim_store(store_key),
    
    -- Metrikler (Measures)
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    
    -- Degenerate Dimension
    order_number VARCHAR(50),
    
    -- Audit columns
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Columnstore index (OLAP için)
CREATE INDEX idx_fact_sales_columnstore 
ON fact_sales (date_key, customer_key, product_key, store_key);
```

**Boyut Tabloları:**

```sql
-- Zaman Boyutu
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day_of_week VARCHAR(10),
    day_of_month INT,
    day_of_year INT,
    week_of_year INT,
    month_name VARCHAR(10),
    month_number INT,
    quarter INT,
    year INT,
    is_weekend BOOLEAN,
    is_holiday BOOLEAN,
    holiday_name VARCHAR(50)
);

-- Müşteri Boyutu
CREATE TABLE dim_customer (
    customer_key INT PRIMARY KEY,
    customer_id INT, -- Business key
    full_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    birth_date DATE,
    age_group VARCHAR(20), -- '18-25', '26-35', etc.
    gender VARCHAR(10),
    
    -- Address
    address_line1 VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    
    -- Segmentation
    customer_segment VARCHAR(30), -- 'VIP', 'Regular', 'New'
    lifetime_value DECIMAL(12,2),
    
    -- SCD Type 2 (Slowly Changing Dimension)
    valid_from DATE,
    valid_to DATE,
    is_current BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Ürün Boyutu
CREATE TABLE dim_product (
    product_key INT PRIMARY KEY,
    product_id INT, -- Business key
    product_name VARCHAR(200),
    product_description TEXT,
    sku VARCHAR(50),
    
    -- Hierarchy
    category_name VARCHAR(50),
    subcategory_name VARCHAR(50),
    brand_name VARCHAR(50),
    
    -- Attributes
    color VARCHAR(30),
    size VARCHAR(20),
    weight DECIMAL(10,2),
    
    -- Pricing
    list_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    margin_percent DECIMAL(5,2),
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    
    valid_from DATE,
    valid_to DATE,
    is_current BOOLEAN DEFAULT TRUE
);

-- Mağaza Boyutu
CREATE TABLE dim_store (
    store_key INT PRIMARY KEY,
    store_id INT,
    store_name VARCHAR(100),
    store_type VARCHAR(30), -- 'Physical', 'Online'
    
    -- Location
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    region VARCHAR(50),
    
    -- Details
    manager_name VARCHAR(100),
    opening_date DATE,
    square_meters INT,
    
    is_active BOOLEAN DEFAULT TRUE
);
```

#### Örnek Analitik Sorgular

```sql
-- Aylık satış trendi
SELECT 
    d.year,
    d.month_name,
    COUNT(DISTINCT f.sale_id) as total_orders,
    SUM(f.quantity) as total_quantity,
    SUM(f.total_amount) as total_revenue,
    AVG(f.total_amount) as avg_order_value
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024
GROUP BY d.year, d.month_number, d.month_name
ORDER BY d.month_number;

-- En çok satan ürünler (kategori bazında)
SELECT 
    p.category_name,
    p.product_name,
    SUM(f.quantity) as units_sold,
    SUM(f.total_amount) as revenue,
    AVG(f.unit_price) as avg_price
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024
GROUP BY p.category_name, p.product_name
ORDER BY revenue DESC
LIMIT 20;

-- Müşteri segmenti analizi
SELECT 
    c.customer_segment,
    c.age_group,
    COUNT(DISTINCT c.customer_key) as customer_count,
    COUNT(f.sale_id) as order_count,
    SUM(f.total_amount) as total_revenue,
    AVG(f.total_amount) as avg_order_value,
    SUM(f.total_amount) / COUNT(DISTINCT c.customer_key) as revenue_per_customer
FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024 AND c.is_current = TRUE
GROUP BY c.customer_segment, c.age_group
ORDER BY total_revenue DESC;

-- Bölgesel performans
SELECT 
    s.region,
    s.city,
    d.quarter,
    COUNT(DISTINCT f.sale_id) as orders,
    SUM(f.total_amount) as revenue,
    SUM(f.quantity) as units_sold
FROM fact_sales f
JOIN dim_store s ON f.store_key = s.store_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024
GROUP BY s.region, s.city, d.quarter
ORDER BY revenue DESC;
```

#### Star Schema Avantajları
```
✅ Basit ve anlaşılır
✅ Hızlı sorgular
✅ İyi BI tool desteği
✅ Az JOIN
❌ Veri tekrarı (denormalize)
❌ Daha fazla storage
```

### 3.3 Snowflake Schema (Kar Tanesi Şeması)

#### Yapı
```
                    Dim_Date
                        ↓
Dim_Customer → FACT_Sales ← Dim_Product
     ↓                            ↓
Dim_City                    Dim_Category
     ↓                            ↓
Dim_State                   Dim_Subcategory
     ↓
Dim_Country
```

#### Örnek: Normalize Edilmiş Boyutlar

```sql
-- Ürün boyutu (normalize)
CREATE TABLE dim_product (
    product_key INT PRIMARY KEY,
    product_id INT,
    product_name VARCHAR(200),
    sku VARCHAR(50),
    subcategory_key INT REFERENCES dim_subcategory(subcategory_key),
    brand_key INT REFERENCES dim_brand(brand_key),
    list_price DECIMAL(10,2)
);

-- Alt kategori tablosu
CREATE TABLE dim_subcategory (
    subcategory_key INT PRIMARY KEY,
    subcategory_name VARCHAR(50),
    category_key INT REFERENCES dim_category(category_key)
);

-- Kategori tablosu
CREATE TABLE dim_category (
    category_key INT PRIMARY KEY,
    category_name VARCHAR(50),
    department_key INT REFERENCES dim_department(department_key)
);

-- Departman tablosu
CREATE TABLE dim_department (
    department_key INT PRIMARY KEY,
    department_name VARCHAR(50)
);

-- Marka tablosu
CREATE TABLE dim_brand (
    brand_key INT PRIMARY KEY,
    brand_name VARCHAR(50),
    brand_country VARCHAR(50)
);
```

#### Snowflake Schema ile Sorgu

```sql
-- Departman bazında satışlar (çoklu JOIN)
SELECT 
    dept.department_name,
    cat.category_name,
    subcat.subcategory_name,
    SUM(f.total_amount) as revenue
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_subcategory subcat ON p.subcategory_key = subcat.subcategory_key
JOIN dim_category cat ON subcat.category_key = cat.category_key
JOIN dim_department dept ON cat.department_key = dept.department_key
GROUP BY dept.department_name, cat.category_name, subcat.subcategory_name
ORDER BY revenue DESC;
```

#### Snowflake Schema Avantajları
```
✅ Az veri tekrarı
✅ Kolay güncelleme
✅ Storage tasarrufu
❌ Kompleks sorgular
❌ Daha fazla JOIN
❌ Daha yavaş
```

### 3.4 Star vs Snowflake Karşılaştırma

| Özellik | Star Schema | Snowflake Schema |
|---------|-------------|------------------|
| **Normalizasyon** | Düşük (denormalize) | Yüksek (normalize) |
| **JOIN Sayısı** | Az | Çok |
| **Sorgu Hızı** | Hızlı | Yavaş |
| **Storage** | Fazla | Az |
| **Karmaşıklık** | Basit | Karmaşık |
| **Bakım** | Kolay | Orta |
| **Tercih** | Çoğu durumda | Nadiren |

### 3.5 Slowly Changing Dimensions (SCD)

#### Type 0: Değişmez
```sql
-- Hiç değişmez (dogum_tarihi gibi)
```

#### Type 1: Üzerine Yaz
```sql
-- Eski değer kaybolur
UPDATE dim_customer
SET email = 'new@example.com'
WHERE customer_key = 123;
```

#### Type 2: Tarihçe Tut (En Yaygın)
```sql
-- Eski kayıt kapat, yeni kayıt ekle
UPDATE dim_customer
SET valid_to = CURRENT_DATE, is_current = FALSE
WHERE customer_key = 123 AND is_current = TRUE;

INSERT INTO dim_customer (
    customer_id, email, valid_from, valid_to, is_current
) VALUES (
    12345, 'new@example.com', CURRENT_DATE, '9999-12-31', TRUE
);
```

#### Type 3: Önceki Değeri Sakla
```sql
ALTER TABLE dim_customer 
ADD COLUMN previous_email VARCHAR(100);

UPDATE dim_customer
SET previous_email = email,
    email = 'new@example.com'
WHERE customer_key = 123;
```

---

## 4. ETL vs ELT

### 4.1 ETL (Extract, Transform, Load)

**Geleneksel Yaklaşım:**

```
┌─────────────┐
│   Source    │
│   (OLTP)    │
└──────┬──────┘
       │ Extract
       ↓
┌──────────────┐
│ Staging Area │
└──────┬───────┘
       │ Transform
       │ (ETL Tool)
       ↓
┌──────────────┐
│ Data Warehouse│
│    (OLAP)    │
└──────────────┘
```

#### Extract (Çıkarma)
```python
import psycopg2
import pandas as pd

def extract_from_source():
    # OLTP veritabanından veri çek
    conn = psycopg2.connect("dbname=oltp_db user=user password=pass")
    
    query = """
        SELECT order_id, customer_id, order_date, total_amount
        FROM orders
        WHERE order_date >= CURRENT_DATE - INTERVAL '1 day'
    """
    
    df = pd.read_sql(query, conn)
    conn.close()
    
    return df
```

#### Transform (Dönüştürme)
```python
def transform_data(df):
    # Veri temizleme
    df = df.dropna()
    
    # Veri tipi dönüşümü
    df['order_date'] = pd.to_datetime(df['order_date'])
    
    # İş kuralları uygulama
    df['discount_amount'] = df['total_amount'] * 0.1
    df['final_amount'] = df['total_amount'] - df['discount_amount']
    
    # Aggregation
    df_agg = df.groupby(['customer_id', 'order_date']).agg({
        'order_id': 'count',
        'final_amount': 'sum'
    }).reset_index()
    
    return df_agg
```

#### Load (Yükleme)
```python
def load_to_warehouse(df):
    # Veri ambarına yükle
    conn = psycopg2.connect("dbname=dwh user=user password=pass")
    cursor = conn.cursor()
    
    for _, row in df.iterrows():
        cursor.execute("""
            INSERT INTO fact_daily_sales 
            (customer_key, date_key, order_count, total_revenue)
            VALUES (%s, %s, %s, %s)
        """, (row['customer_id'], row['order_date'], 
              row['order_id'], row['final_amount']))
    
    conn.commit()
    conn.close()
```

#### ETL Avantajları
```
✅ Veri warehouse'a temiz veri gelir
✅ Network trafiği az
✅ Transformation mantığı merkezi
❌ ETL server yükü
❌ Esneklik düşük
```

### 4.2 ELT (Extract, Load, Transform)

**Modern Yaklaşım:**

```
┌─────────────┐
│   Source    │
│   (OLTP)    │
└──────┬──────┘
       │ Extract
       ↓ Load (Raw)
┌──────────────┐
│ Data Lake/   │
│  Warehouse   │
│  Transform   │ ← SQL/dbt
│  (Inside)    │
└──────────────┘
```

#### Modern ELT ile dbt Örneği

```sql
-- models/staging/stg_orders.sql
WITH source AS (
    SELECT * FROM {{ source('raw', 'orders') }}
),

cleaned AS (
    SELECT
        order_id,
        customer_id,
        CAST(order_date AS DATE) as order_date,
        CAST(total_amount AS DECIMAL(10,2)) as total_amount,
        CURRENT_TIMESTAMP as loaded_at
    FROM source
    WHERE total_amount > 0
)

SELECT * FROM cleaned;

-- models/marts/fct_daily_sales.sql
WITH daily_orders AS (
    SELECT
        customer_id,
        DATE(order_date) as order_date,
        COUNT(*) as order_count,
        SUM(total_amount) as total_revenue
    FROM {{ ref('stg_orders') }}
    GROUP BY 1, 2
)

SELECT * FROM daily_orders;
```

#### ELT Avantajları
```
✅ Data warehouse gücünü kullanır
✅ Esnek (SQL ile transform)
✅ Hızlı data loading
✅ Raw data saklanır
❌ Warehouse compute maliyeti
```

### 4.3 ETL vs ELT Karşılaştırma

| Özellik | ETL | ELT |
|---------|-----|-----|
| **Transform Yeri** | ETL server | Data Warehouse |
| **Hız** | Yavaş | Hızlı |
| **Esneklik** | Düşük | Yüksek |
| **Maliyet** | ETL tool lisansı | Warehouse compute |
| **Uygun** | On-premise | Cloud |
| **Araçlar** | Informatica, Talend | dbt, Fivetran |

---

## 5. Veri Gölü (Data Lake)

### 5.1 Tanım

**Data Lake:** Ham verilerin her türlü formatında saklandığı merkezi depo. Schema-on-read yaklaşımı.

```
Data Warehouse: Schema-on-write
Data Lake: Schema-on-read
```
```
Data Lake Mimarisi
┌─────────────────────────────────────────┐
│          Data Sources                    │
├─────────────────────────────────────────┤
│  IoT  │  Logs  │  Social  │  Database  │
└────┬────┴────┬───┴────┬────┴─────┬──────┘
     │         │        │          │
     ▼         ▼        ▼          ▼
┌─────────────────────────────────────────┐
│      Ingestion Layer (Kafka, Nifi)      │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│         Raw Zone (Bronze)                │
│    MinIO / S3 - Ham veriler              │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│      Processing Layer (Spark)            │
│    Temizleme, Filtreleme, Dönüştürme    │
└─────────────┬───────────────────────────┘
              │
         ┌────┴────┐
         ▼         ▼
┌──────────────┐ ┌─────────────────┐
│ Processed    │ │  Curated Zone   │
│ Zone (Silver)│ │  (Gold)         │
│ Temiz veriler│ │  Analytics-ready│
└──────────────┘ └─────────────────┘
```

### 5.2 Data Warehouse vs Data Lake

| Özellik | Data Warehouse | Data Lake |
|---------|---------------|-----------|
| **Veri Türü** | Yapısal | Tüm türler |
| **Şema** | Önceden tanımlı | İhtiyaç anında |
| **Maliyet** | Yüksek | Düşük |
| **Kullanıcı** | İş analistleri | Data scientists |
| **Amaç** | BI, raporlama | ML, keşif |
| **İşleme** | Batch | Batch + Stream |
| **Storage** | Pahalı | Object storage (ucuz) |

### 5.3 Medallion Architecture (Bronze, Silver, Gold)

```
┌──────────────┐
│    BRONZE    │  Raw Data (Olduğu gibi)
│  (Raw Zone)  │  - JSON, CSV, Parquet
└──────┬───────┘  - Kaynak sistemden aynen
       │
       ↓ Cleaning, Validation
┌──────────────┐
│    SILVER    │  Temizlenmiş, Validate
│ (Curated)    │  - Standart format
└──────┬───────┘  - Veri kalitesi kontrollü
       │
       ↓ Business Logic, Aggregation
┌──────────────┐
│     GOLD     │  İş değeri yaratan
│  (Business)  │  - Aggregate tables
└──────────────┘  - Feature stores
```

#### MinIO ile Data Lake Örneği

**Docker ile Başlatma:**
```bash
docker-compose up -d minio minio-client
```

**Python ile Veri Yükleme:**
```python
from minio import Minio
from datetime import datetime
import json

# MinIO client
client = Minio(
    "localhost:9000",
    access_key="minioadmin",
    secret_key="minioadmin",
    secure=False
)

# BRONZE: Ham veri yükle
def upload_to_bronze(data, filename):
    bucket = "bronze"
    
    # JSON olarak kaydet
    json_data = json.dumps(data)
    
    client.put_object(
        bucket,
        f"raw-data/{datetime.now().strftime('%Y/%m/%d')}/{filename}",
        data=json_data.encode('utf-8'),
        length=len(json_data),
        content_type='application/json'
    )

# SILVER: Temizlenmiş veri
def upload_to_silver(df, filename):
    import io
    
    # Parquet formatında kaydet
    buffer = io.BytesIO()
    df.to_parquet(buffer, index=False)
    buffer.seek(0)
    
    client.put_object(
        "silver",
        f"cleaned-data/{filename}.parquet",
        data=buffer,
        length=buffer.getbuffer().nbytes,
        content_type='application/octet-stream'
    )

# GOLD: Aggregate veri
def upload_to_gold(df, table_name):
    import io
    
    buffer = io.BytesIO()
    df.to_parquet(buffer, index=False)
    buffer.seek(0)
    
    client.put_object(
        "gold",
        f"business-tables/{table_name}.parquet",
        data=buffer,
        length=buffer.getbuffer().nbytes,
        content_type='application/octet-stream'
    )
```

### 5.4 Data Lakehouse

**Tanım:** Data Lake + Data Warehouse = Lakehouse

```
Data Lake'in esnekliği
    +
Data Warehouse'un performansı
    =
Data Lakehouse
```

#### Lakehouse Teknolojileri

**Delta Lake (Databricks):**
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("Delta Lake Example") \
    .config("spark.jars.packages", "io.delta:delta-core_2.12:2.0.0") \
    .getOrCreate()

# Delta table oluştur
df.write.format("delta").mode("overwrite").save("/mnt/delta/events")

# ACID transactions
df.write.format("delta").mode("append").save("/mnt/delta/events")

# Time travel
df_historical = spark.read.format("delta") \
    .option("versionAsOf", 0) \
    .load("/mnt/delta/events")

# Schema evolution
df.write.format("delta") \
    .option("mergeSchema", "true") \
    .mode("append") \
    .save("/mnt/delta/events")
```

**Apache Iceberg:**
```sql
-- Iceberg table oluştur
CREATE TABLE events (
    event_id BIGINT,
    user_id BIGINT,
    event_type STRING,
    timestamp TIMESTAMP
) USING iceberg
PARTITIONED BY (days(timestamp));

-- Time travel
SELECT * FROM events
TIMESTAMP AS OF '2025-01-01 00:00:00';

-- Schema evolution
ALTER TABLE events ADD COLUMN device_type STRING;
```

---

## 6. Modern Veri Mimarileri

### 6.1 Lambda Architecture

**Tanım:** Batch + Speed layer ile hem tarihsel hem gerçek zamanlı analiz

```
┌─────────────┐
│   Sources   │
└──────┬──────┘
       │
   ┌───┴───┐
   │       │
   ↓       ↓
BATCH    SPEED
Layer    Layer
(Hadoop) (Storm/Flink)
   │       │
   └───┬───┘
       ↓
┌─────────────┐
│  Serving    │
│   Layer     │
└─────────────┘
```

#### Batch Layer
```python
# Spark batch processing
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("BatchLayer").getOrCreate()

# Tüm tarihsel veriyi işle
df = spark.read.parquet("s3://data-lake/events/")

# Aggregation
daily_stats = df.groupBy("date", "user_id") \
    .agg({
        "event_count": "sum",
        "revenue": "sum"
    })

# Batch view'a yaz
daily_stats.write.mode("overwrite").parquet("s3://batch-views/daily_stats")
```

#### Speed Layer
```python
# Kafka + Flink for streaming
from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import StreamTableEnvironment

env = StreamExecutionEnvironment.get_execution_environment()
t_env = StreamTableEnvironment.create(env)

# Kafka'dan oku
t_env.execute_sql("""
    CREATE TABLE events (
        event_id BIGINT,
        user_id BIGINT,
        amount DECIMAL(10,2),
        event_time TIMESTAMP(3)
    ) WITH (
        'connector' = 'kafka',
        'topic' = 'events',
        'properties.bootstrap.servers' = 'localhost:9092'
    )
""")

# Gerçek zamanlı aggregation
t_env.execute_sql("""
    CREATE TABLE realtime_stats AS
    SELECT 
        TUMBLE_START(event_time, INTERVAL '1' MINUTE) as window_start,
        user_id,
        COUNT(*) as event_count,
        SUM(amount) as total_amount
    FROM events
    GROUP BY TUMBLE(event_time, INTERVAL '1' MINUTE), user_id
""")
```

#### Serving Layer
```python
# Batch ve Speed sonuçlarını birleştir
def get_user_stats(user_id, date):
    # Batch view'dan oku (tarihsel)
    batch_stats = read_from_batch_view(user_id, date)
    
    # Speed layer'dan oku (son dakika)
    realtime_stats = read_from_speed_layer(user_id)
    
    # Birleştir
    total_events = batch_stats['event_count'] + realtime_stats['event_count']
    total_revenue = batch_stats['revenue'] + realtime_stats['revenue']
    
    return {
        'event_count': total_events,
        'revenue': total_revenue
    }
```

### 6.2 Kappa Architecture

**Tanım:** Sadece streaming (Lambda'nın basitleştirilmiş versiyonu)

```
┌─────────────┐
│   Sources   │
└──────┬──────┘
       │
       ↓
┌─────────────┐
│  Streaming  │
│   Layer     │
│ (Kafka/Flink)│
└──────┬──────┘
       │
       ↓
┌─────────────┐
│  Serving    │
│   Layer     │
└─────────────┘
```

**Avantajlar:**
- ✅ Tek kod tabanı
- ✅ Basit mimari
- ✅ Gerçek zamanlı

**Dezavantajlar:**
- ❌ Tarihsel veri yeniden işleme zor
- ❌ Debugging karmaşık

### 6.3 Data Mesh

**Tanım:** Domain-oriented, decentralized data ownership

#### Temel Prensipler

**1. Domain Ownership**
```
❌ Merkezi veri ekibi tüm verileri yönetir
✅ Her domain kendi verisini yönetir

Sales Domain → Sales Data Product
Marketing Domain → Marketing Data Product
Product Domain → Product Data Product
```

**2. Data as a Product**
```
Veri bir ürün gibi ele alınır:
- Kalite garantisi
- Dokümantasyon
- SLA
- API/Interface
```

**3. Self-serve Platform**
```
Her domain kendi veri altyapısını yönetir:
- Kendi database'i
- Kendi pipeline'ı
- Kendi quality checks
```

**4. Federated Governance**
```
Merkezi standartlar + Domain özgürlüğü:
- Veri formatları (JSON, Parquet)
- Güvenlik standartları
- Privacy regulations
- Metadata standards
```

### 6.4 Modern Data Stack

```
┌──────────────────────────────────────┐
│         Data Sources                 │
│  (Databases, APIs, SaaS, Files)      │
└───────────────┬──────────────────────┘
                ↓
┌──────────────────────────────────────┐
│      Ingestion (EL)                  │
│  Fivetran, Airbyte, Stitch           │
└───────────────┬──────────────────────┘
                ↓
┌──────────────────────────────────────┐
│    Storage & Compute                 │
│  Snowflake, BigQuery, Databricks     │
└───────────────┬──────────────────────┘
                ↓
┌──────────────────────────────────────┐
│    Transformation (T)                │
│  dbt (data build tool)               │
└───────────────┬──────────────────────┘
                ↓
┌──────────────────────────────────────┐
│    BI & Analytics                    │
│  Looker, Tableau, Power BI           │
└──────────────────────────────────────┘
```

---

## 7. Veri Kalitesi ve Yönetişimi

### 7.1 Veri Kalitesi Boyutları

#### 1. Accuracy (Doğruluk)
```python
# Email format kontrolü
def check_email_accuracy(df):
    import re
    email_pattern = r'^[\w\.-]+@[\w\.-]+\.\w+
    
    df['email_valid'] = df['email'].apply(
        lambda x: bool(re.match(email_pattern, str(x)))
    )
    
    accuracy_rate = df['email_valid'].mean() * 100
    return accuracy_rate
```

#### 2. Completeness (Tamlık)
```python
# Eksik veri kontrolü
def check_completeness(df):
    completeness = {}
    
    for col in df.columns:
        null_count = df[col].isnull().sum()
        total_count = len(df)
        completeness[col] = ((total_count - null_count) / total_count) * 100
    
    return completeness
```

#### 3. Consistency (Tutarlılık)
```python
# Tutarlılık kontrolü
def check_consistency(df):
    # Yaş ve doğum tarihi tutarlı mı?
    from datetime import datetime
    
    current_year = datetime.now().year
    df['calculated_age'] = current_year - df['birth_year']
    df['age_consistent'] = abs(df['age'] - df['calculated_age']) <= 1
    
    consistency_rate = df['age_consistent'].mean() * 100
    return consistency_rate
```

#### 4. Timeliness (Zamanlılık)
```python
# Veri güncel mi?
def check_timeliness(df):
    from datetime import datetime, timedelta
    
    current_time = datetime.now()
    df['is_fresh'] = (current_time - df['updated_at']) < timedelta(days=1)
    
    timeliness_rate = df['is_fresh'].mean() * 100
    return timeliness_rate
```

#### 5. Uniqueness (Benzersizlik)
```python
# Tekrar eden kayıtlar
def check_uniqueness(df, key_columns):
    total_records = len(df)
    unique_records = df[key_columns].drop_duplicates().shape[0]
    
    uniqueness_rate = (unique_records / total_records) * 100
    
    duplicates = df[df.duplicated(subset=key_columns, keep=False)]
    
    return uniqueness_rate, duplicates
```

### 7.2 Data Quality Framework

```python
class DataQualityChecker:
    def __init__(self, df):
        self.df = df
        self.results = {}
    
    def check_all(self):
        """Tüm kalite kontrollerini çalıştır"""
        self.results['completeness'] = self.check_completeness()
        self.results['accuracy'] = self.check_accuracy()
        self.results['consistency'] = self.check_consistency()
        self.results['uniqueness'] = self.check_uniqueness()
        
        return self.results
    
    def check_completeness(self):
        """Eksik veri oranı"""
        missing_pct = (self.df.isnull().sum() / len(self.df)) * 100
        return missing_pct.to_dict()
    
    def check_accuracy(self):
        """Veri formatı doğruluğu"""
        accuracy = {}
        
        # Email kontrolü
        if 'email' in self.df.columns:
            import re
            pattern = r'^[\w\.-]+@[\w\.-]+\.\w+
            accuracy['email'] = self.df['email'].apply(
                lambda x: bool(re.match(pattern, str(x))) if pd.notna(x) else False
            ).mean() * 100
        
        return accuracy
    
    def check_consistency(self):
        """Mantıksal tutarlılık"""
        issues = []
        
        # Negatif fiyat kontrolü
        if 'price' in self.df.columns:
            negative_prices = (self.df['price'] < 0).sum()
            if negative_prices > 0:
                issues.append(f"Negatif fiyat: {negative_prices} kayıt")
        
        # Gelecek tarih kontrolü
        date_columns = self.df.select_dtypes(include=['datetime64']).columns
        for col in date_columns:
            future_dates = (self.df[col] > pd.Timestamp.now()).sum()
            if future_dates > 0:
                issues.append(f"{col}: {future_dates} gelecek tarih")
        
        return issues
    
    def check_uniqueness(self):
        """Tekrar eden kayıtlar"""
        duplicates = self.df.duplicated().sum()
        return {
            'duplicate_count': duplicates,
            'duplicate_pct': (duplicates / len(self.df)) * 100
        }
    
    def generate_report(self):
        """Detaylı rapor oluştur"""
        self.check_all()
        
        print("=" * 50)
        print("VERİ KALİTESİ RAPORU")
        print("=" * 50)
        
        print("\n1. COMPLETENESS (Tamlık)")
        for col, pct in self.results['completeness'].items():
            status = "✅" if pct < 5 else "⚠️" if pct < 20 else "❌"
            print(f"{status} {col}: %{100-pct:.2f} dolu")
        
        print("\n2. ACCURACY (Doğruluk)")
        for field, pct in self.results['accuracy'].items():
            status = "✅" if pct > 95 else "⚠️" if pct > 80 else "❌"
            print(f"{status} {field}: %{pct:.2f} doğru")
        
        print("\n3. CONSISTENCY (Tutarlılık)")
        if self.results['consistency']:
            for issue in self.results['consistency']:
                print(f"❌ {issue}")
        else:
            print("✅ Tutarlılık sorunu yok")
        
        print("\n4. UNIQUENESS (Benzersizlik)")
        dup = self.results['uniqueness']
        if dup['duplicate_count'] == 0:
            print("✅ Tekrar eden kayıt yok")
        else:
            print(f"❌ {dup['duplicate_count']} tekrar eden kayıt "
                  f"(%{dup['duplicate_pct']:.2f})")

# Kullanım
df = pd.read_csv('data.csv')
checker = DataQualityChecker(df)
checker.generate_report()
```

### 7.3 Data Governance

#### Temel Bileşenler

**1. Data Catalog**
```yaml
# Metadata yönetimi
dataset:
  name: customer_transactions
  description: Daily customer transaction data
  owner: sales-team@company.com
  tags: [pii, financial, daily]
  
  schema:
    - name: customer_id
      type: bigint
      description: Unique customer identifier
      pii: false
    
    - name: email
      type: string
      description: Customer email address
      pii: true
      sensitivity: high
    
    - name: transaction_amount
      type: decimal(10,2)
      description: Transaction amount in TRY
      pii: false
  
  quality_rules:
    - field: email
      rule: email_format
      threshold: 95
    
    - field: transaction_amount
      rule: positive_value
      threshold: 100
  
  access_control:
    - role: analyst
      permissions: [read]
    - role: data_engineer
      permissions: [read, write]
```

**2. Data Lineage**
```python
# Veri akışını izleme
lineage = {
    "dataset": "gold.customer_metrics",
    "upstream": [
        {
            "dataset": "silver.customers",
            "transformations": ["deduplication", "validation"]
        },
        {
            "dataset": "silver.transactions",
            "transformations": ["aggregation", "filtering"]
        }
    ],
    "transformations": [
        "join on customer_id",
        "group by customer_id",
        "calculate lifetime_value"
    ],
    "downstream": [
        "bi_dashboard.customer_360",
        "ml_model.churn_prediction"
    ]
}
```

**3. Data Security**
```sql
-- Satır seviyesi güvenlik (Row-Level Security)
CREATE POLICY sales_rep_policy ON orders
FOR SELECT
TO sales_role
USING (sales_rep_id = current_user_id());

-- Sütun seviyesi şifreleme
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    ssn VARCHAR(11) ENCRYPTED,  -- Şifreli
    email VARCHAR(100)
);

-- Maskeleme (Data Masking)
CREATE VIEW customers_masked AS
SELECT 
    customer_id,
    name,
    CONCAT('***-**-', RIGHT(ssn, 4)) as ssn_masked,
    CONCAT(LEFT(email, 3), '***@', SPLIT_PART(email, '@', 2)) as email_masked
FROM customers;
```

---

## 8. Veri Görselleştirme

### 8.1 Görselleştirme Prensipleri

#### 1. Doğru Grafik Seçimi

**Karşılaştırma:** Bar Chart
**Trend:** Line Chart
**Dağılım:** Scatter Plot
**Oran:** Pie Chart (dikkatli kullan!)
**İlişki:** Scatter Plot, Heatmap

#### 2. Renk Kullanımı
```python
import matplotlib.pyplot as plt
import seaborn as sns

# Colorblind-friendly palette
sns.set_palette("colorblind")

# Diverging colormap (pozitif-negatif için)
colors = sns.diverging_palette(10, 133, as_cmap=True)
```

#### 3. Eksen ve Label'lar
```python
fig, ax = plt.subplots(figsize=(12, 6))

ax.plot(dates, values)

# Clear labels
ax.set_xlabel('Tarih', fontsize=12)
ax.set_ylabel('Satış (TRY)', fontsize=12)
ax.set_title('Aylık Satış Trendi - 2024', fontsize=14, fontweight='bold')

# Format axis
ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'₺{x:,.0f}'))

# Grid
ax.grid(True, alpha=0.3)

plt.tight_layout()
```

### 8.2 Python ile Dashboard

```python
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import pandas as pd

# Veri hazırlama
df = pd.read_csv('sales_data.csv')

# Dashboard layout
fig = make_subplots(
    rows=2, cols=2,
    subplot_titles=('Aylık Satış Trendi', 'Kategori Dağılımı',
                    'Bölgesel Performans', 'Top 10 Ürün'),
    specs=[[{"type": "scatter"}, {"type": "pie"}],
           [{"type": "bar"}, {"type": "bar"}]]
)

# 1. Trend chart
monthly_sales = df.groupby('month')['revenue'].sum()
fig.add_trace(
    go.Scatter(x=monthly_sales.index, y=monthly_sales.values,
               mode='lines+markers', name='Satış'),
    row=1, col=1
)

# 2. Pie chart
category_dist = df.groupby('category')['revenue'].sum()
fig.add_trace(
    go.Pie(labels=category_dist.index, values=category_dist.values),
    row=1, col=2
)

# 3. Bar chart - Bölgesel
regional_sales = df.groupby('region')['revenue'].sum().sort_values(ascending=False)
fig.add_trace(
    go.Bar(x=regional_sales.index, y=regional_sales.values),
    row=2, col=1
)

# 4. Bar chart - Top products
top_products = df.groupby('product')['revenue'].sum().nlargest(10)
fig.add_trace(
    go.Bar(x=top_products.values, y=top_products.index, orientation='h'),
    row=2, col=2
)

# Layout
fig.update_layout(
    height=800,
    title_text="Satış Dashboard - 2024",
    showlegend=False
)

fig.show()
```

---

## 9. Pratik Uygulamalar

## 🚀 Hızlı Başlangıç

### 1. Temel Servisleri Başlat

```bash
# Dizine git
cd week4-datawarehouse

# Environment değişkenlerini kopyala
cp .env.example .env

# OLTP ve OLAP başlat
docker-compose up -d postgres-oltp postgres-olap pgadmin
```

### 2. OLTP Verisini Yükle

```bash
# Schema ve örnek verileri yükle
docker exec -i postgres_oltp psql -U oltp_user -d ecommerce_oltp < oltp/init/01-schema.sql
docker exec -i postgres_oltp psql -U oltp_user -d ecommerce_oltp < oltp/init/02-sample-data.sql
```

### 3. OLAP Yapısını Oluştur

```bash
# Dimension ve Fact tablolarını oluştur
docker exec -i postgres_olap psql -U olap_user -d ecommerce_olap < olap/init/01-dimensions.sql
docker exec -i postgres_olap psql -U olap_user -d ecommerce_olap < olap/init/02-facts.sql
docker exec -i postgres_olap psql -U olap_user -d ecommerce_olap < olap/init/03-star-schema.sql
```

### 4. ETL Pipeline Çalıştır

```bash
# ETL servisini başlat
docker-compose --profile etl up -d etl-service

# ETL'i manuel çalıştır
docker exec etl_service python full_pipeline.py
```

### 5. Data Lake Oluştur

```bash
# MinIO başlat
docker-compose up -d minio minio-init

# MinIO Console aç
open http://localhost:9001
# Giriş: minio_admin / minio_password123
```

### 6. Spark ile Veri İşle

```bash
# Spark başlat
docker-compose up -d spark-master spark-worker

# Spark UI aç
open http://localhost:8080

# Spark job çalıştır
docker exec spark_master spark-submit /opt/spark-jobs/batch_processing.py
```

### 7. BI Dashboard Oluştur

```bash
# Superset başlat
docker-compose up -d superset

# Superset aç (2-3 dakika bekleyin)
open http://localhost:8088
# Giriş: admin / admin123
```

## 📊 Servisler ve Erişim

### Web Arayüzleri

| Servis | URL | Kullanıcı | Şifre |
|--------|-----|-----------|-------|
| pgAdmin | http://localhost:5050 | admin@datawarehouse.com | admin123 |
| MinIO Console | http://localhost:9001 | minio_admin | minio_password123 |
| Spark Master UI | http://localhost:8080 | - | - |
| Jupyter Lab | http://localhost:8888 | - | token: datawarehouse123 |
| Superset | http://localhost:8088 | admin | admin123 |
| Airflow | http://localhost:8089 | airflow | airflow123 |
| Metabase | http://localhost:3000 | - | İlk kurulum |

### Veritabanı Bağlantıları

**OLTP PostgreSQL:**
```bash
Host: localhost
Port: 5432
Database: ecommerce_oltp
User: oltp_user
Password: oltp_pass

# Bağlan:
docker exec -it postgres_oltp psql -U oltp_user -d ecommerce_oltp
```

**OLAP PostgreSQL:**
```bash
Host: localhost
Port: 5433
Database: ecommerce_olap
User: olap_user
Password: olap_pass

# Bağlan:
docker exec -it postgres_olap psql -U olap_user -d ecommerce_olap
```


### Komple ETL Pipeline Örneği

```python
import pandas as pd
import psycopg2
from datetime import datetime

class ETLPipeline:
    def __init__(self):
        self.oltp_conn = psycopg2.connect(
            "host=localhost port=5432 dbname=oltp_db user=veri_user password=veri_pass"
        )
        self.olap_conn = psycopg2.connect(
            "host=localhost port=5433 dbname=olap_db user=veri_user password=veri_pass"
        )
    
    def extract(self):
        """OLTP'den veri çek"""
        print(f"[{datetime.now()}] Extracting data from OLTP...")
        
        query = """
            SELECT 
                o.order_id,
                o.customer_id,
                o.order_date,
                oi.product_id,
                oi.quantity,
                oi.unit_price,
                oi.quantity * oi.unit_price as line_total
            FROM orders o
            JOIN order_items oi ON o.order_id = oi.order_id
            WHERE o.order_date >= CURRENT_DATE - INTERVAL '1 day'
        """
        
        df = pd.read_sql(query, self.oltp_conn)
        print(f"Extracted {len(df)} records")
        
        return df
    
    def transform(self, df):
        """Veri dönüşümü"""
        print(f"[{datetime.now()}] Transforming data...")
        
        # Temizleme
        df = df.dropna()
        
        # Tarih parçalama
        df['order_date'] = pd.to_datetime(df['order_date'])
        df['year'] = df['order_date'].dt.year
        df['month'] = df['order_date'].dt.month
        df['day'] = df['order_date'].dt.day
        
        # Aggregation
        daily_summary = df.groupby([
            'order_date', 'customer_id', 'product_id'
        ]).agg({
            'quantity': 'sum',
            'line_total': 'sum'
        }).reset_index()
        
        print(f"Transformed to {len(daily_summary)} records")
        
        return daily_summary
    
    def load(self, df):
        """OLAP'a yükle"""
        print(f"[{datetime.now()}] Loading data to OLAP...")
        
        cursor = self.olap_conn.cursor()
        
        for _, row in df.iterrows():
            cursor.execute("""
                INSERT INTO fact_daily_sales 
                (date_key, customer_key, product_key, quantity, revenue)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (date_key, customer_key, product_key) 
                DO UPDATE SET
                    quantity = EXCLUDED.quantity,
                    revenue = EXCLUDED.revenue
            """, (
                row['order_date'].strftime('%Y%m%d'),
                row['customer_id'],
                row['product_id'],
                row['quantity'],
                row['line_total']
            ))
        
        self.olap_conn.commit()
        print(f"Loaded {len(df)} records")
    
    def run(self):
        """Pipeline'ı çalıştır"""
        try:
            # Extract
            df = self.extract()
            
            # Transform
            df_transformed = self.transform(df)
            
            # Load
            self.load(df_transformed)
            
            print(f"[{datetime.now()}] ETL pipeline completed successfully!")
            
        except Exception as e:
            print(f"[{datetime.now()}] ETL pipeline failed: {str(e)}")
            raise
        
        finally:
            self.oltp_conn.close()
            self.olap_conn.close()

# Çalıştır
pipeline = ETLPipeline()
pipeline.run()
```

---

## 10. Alıştırmalar

### Alıştırma 1: Star Schema Tasarımı
Bir online kitap mağazası için star schema tasarlayın:
- Fact: Satışlar
- Dimensions: Müşteri, Kitap, Yazar, Yayınevi, Tarih

**[Çözüm](./week4-datawarehouse/exercises/solutions/star-schema-design.sql)**

### Alıştırma 2: ETL Pipeline
OLTP'den OLAP'a günlük ETL pipeline'ı yazın.

**[Çözüm](./week4-datawarehouse/exercises/solutions/etl-pipeline.py)**

### Alıştırma 3: Data Quality
Veri kalitesi kontrol scripti yazın ve rapor oluşturun.

**[Çözüm](./week4-datawarehouse/exercises/solutions/data-quality.py)**

---

**Özet:** Bu haftada OLTP/OLAP ayrımını, veri ambarı mimarisini, boyutsal modellemeyi, ETL süreçlerini, data lake kavramını ve modern veri mimarilerini öğrendik.

**[← Hafta 3'e Dön](../week3-nosql/README.md) | [Ana Sayfaya Dön](../README.md) | [Hafta 5'e Git →](../week5-advanced-sql/README.md)**