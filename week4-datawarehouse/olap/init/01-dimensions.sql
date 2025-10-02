-- ============================================
-- OLAP Database - Dimension Tables
-- Data Warehouse Dimensional Model
-- ============================================

-- Mevcut tabloları temizle
DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_payment_method CASCADE;

-- ============================================
-- 1. DIM_DATE (Tarih Dimension'ı)
-- ============================================
-- En önemli dimension! Her veri ambarında olmalı

CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY,  -- 20250101 formatında

    -- Tam tarih
    full_date DATE NOT NULL UNIQUE,

    -- Yıl bilgileri
    year INTEGER NOT NULL,
    year_name VARCHAR(10),  -- "2025"

    -- Çeyrek bilgileri
    quarter INTEGER NOT NULL,  -- 1, 2, 3, 4
    quarter_name VARCHAR(10),  -- "Q1", "Q2", "Q3", "Q4"

    -- Ay bilgileri
    month INTEGER NOT NULL,  -- 1-12
    month_name VARCHAR(20),  -- "Ocak", "Şubat", ...
    month_name_short VARCHAR(10),  -- "Oca", "Şub", ...
    month_year VARCHAR(20),  -- "2025-01"

    -- Hafta bilgileri
    week_of_year INTEGER,  -- 1-53
    week_of_month INTEGER,  -- 1-5

    -- Gün bilgileri
    day_of_month INTEGER NOT NULL,  -- 1-31
    day_of_year INTEGER,  -- 1-366
    day_of_week INTEGER,  -- 1-7 (Pazartesi=1)
    day_name VARCHAR(20),  -- "Pazartesi", "Salı", ...
    day_name_short VARCHAR(10),  -- "Pzt", "Sal", ...

    -- İş günü/Tatil
    is_weekday BOOLEAN,  -- Hafta içi mi?
    is_weekend BOOLEAN,  -- Hafta sonu mu?
    is_holiday BOOLEAN DEFAULT FALSE,  -- Resmi tatil mi?
    holiday_name VARCHAR(100),  -- Tatil adı

    -- Fiscal (Mali yıl) - şirketlere göre değişir
    fiscal_year INTEGER,
    fiscal_quarter INTEGER,
    fiscal_month INTEGER,

    -- Özel tanımlar
    season VARCHAR(20),  -- "İlkbahar", "Yaz", "Sonbahar", "Kış"

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Date dimension index
CREATE INDEX idx_dim_date_full_date ON dim_date(full_date);
CREATE INDEX idx_dim_date_year_month ON dim_date(year, month);
CREATE INDEX idx_dim_date_quarter ON dim_date(year, quarter);

COMMENT ON TABLE dim_date IS 'Tarih dimension - tüm analizler için temel';
COMMENT ON COLUMN dim_date.date_key IS 'Surrogate key - YYYYMMDD formatında';
COMMENT ON COLUMN dim_date.full_date IS 'Natural key - gerçek tarih';

-- ============================================
-- 2. DIM_CUSTOMER (Müşteri Dimension'ı)
-- ============================================
-- SCD Type 2: Tarihsel değişimleri saklar

CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,  -- Surrogate key

    -- Natural key (OLTP'den gelen)
    customer_id INTEGER NOT NULL,  -- Business key

    -- Müşteri bilgileri
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),

    -- Demografik bilgiler
    date_of_birth DATE,
    age INTEGER,
    age_group VARCHAR(20),  -- "18-25", "26-35", "36-45", "46-55", "55+"
    gender VARCHAR(10),  -- "Male", "Female", "Other"

    -- Lokasyon bilgileri
    city VARCHAR(100),
    state_province VARCHAR(100),
    country VARCHAR(100),
    region VARCHAR(50),  -- "Marmara", "Ege", "İç Anadolu", ...

    -- Segmentasyon
    customer_segment VARCHAR(20),  -- "Standard", "Premium", "VIP"
    customer_lifetime_value DECIMAL(12,2),

    -- RFM Skorları
    rfm_recency_score INTEGER,  -- 1-5
    rfm_frequency_score INTEGER,  -- 1-5
    rfm_monetary_score INTEGER,  -- 1-5
    rfm_segment VARCHAR(30),  -- "Champions", "Loyal", "At Risk", ...

    -- SCD Type 2 alanları (Slowly Changing Dimension)
    effective_date DATE NOT NULL,  -- Bu kayıt ne zaman başladı?
    expiry_date DATE,  -- Bu kayıt ne zaman bitti? (NULL = aktif)
    is_current BOOLEAN DEFAULT TRUE,  -- Aktif kayıt mı?
    version INTEGER DEFAULT 1,  -- Kaçıncı versiyon?

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_dim_customer_id ON dim_customer(customer_id);
CREATE INDEX idx_dim_customer_current ON dim_customer(customer_id, is_current);
CREATE INDEX idx_dim_customer_segment ON dim_customer(customer_segment);
CREATE INDEX idx_dim_customer_city ON dim_customer(city);
CREATE INDEX idx_dim_customer_effective_date ON dim_customer(effective_date);

COMMENT ON TABLE dim_customer IS 'Müşteri dimension - SCD Type 2';
COMMENT ON COLUMN dim_customer.customer_key IS 'Surrogate key - DW içinde kullanılır';
COMMENT ON COLUMN dim_customer.customer_id IS 'Natural key - OLTP customer_id';
COMMENT ON COLUMN dim_customer.is_current IS 'TRUE = aktif kayıt, FALSE = eski versiyon';

-- ============================================
-- 3. DIM_PRODUCT (Ürün Dimension'ı)
-- ============================================
-- SCD Type 2: Fiyat değişimlerini takip eder

CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,  -- Surrogate key

    -- Natural key
    product_id INTEGER NOT NULL,  -- Business key
    sku VARCHAR(50),  -- Stock Keeping Unit

    -- Ürün bilgileri
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    brand VARCHAR(100),

    -- Kategori hiyerarşisi (denormalized)
    category_id INTEGER,
    category_name VARCHAR(100),
    parent_category_id INTEGER,
    parent_category_name VARCHAR(100),
    category_path VARCHAR(500),  -- "Elektronik > Bilgisayar > Laptop"

    -- Fiyat bilgileri (tarihsel)
    unit_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    profit_margin DECIMAL(5,2),  -- (unit_price - cost_price) / unit_price * 100
    price_range VARCHAR(20),  -- "Budget", "Mid-Range", "Premium", "Luxury"

    -- Ürün özellikleri
    weight_kg DECIMAL(8,2),
    dimensions VARCHAR(50),
    color VARCHAR(50),
    size VARCHAR(20),

    -- Durum bilgileri
    is_active BOOLEAN DEFAULT TRUE,
    discontinuation_date DATE,

    -- SCD Type 2 alanları
    effective_date DATE NOT NULL,
    expiry_date DATE,
    is_current BOOLEAN DEFAULT TRUE,
    version INTEGER DEFAULT 1,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX idx_dim_product_id ON dim_product(product_id);
CREATE INDEX idx_dim_product_current ON dim_product(product_id, is_current);
CREATE INDEX idx_dim_product_category ON dim_product(category_id);
CREATE INDEX idx_dim_product_brand ON dim_product(brand);
CREATE INDEX idx_dim_product_sku ON dim_product(sku);

COMMENT ON TABLE dim_product IS 'Ürün dimension - SCD Type 2 fiyat değişiklikleri için';
COMMENT ON COLUMN dim_product.category_path IS 'Denormalized kategori hiyerarşisi - kolay filtreleme için';

-- ============================================
-- 4. DIM_STORE (Mağaza/Lokasyon Dimension'ı)
-- ============================================
-- SCD Type 1: Değişiklikler üzerine yazılır

CREATE TABLE dim_store (
    store_key SERIAL PRIMARY KEY,

    -- Natural key
    store_id INTEGER NOT NULL UNIQUE,

    -- Mağaza bilgileri
    store_name VARCHAR(100) NOT NULL,
    store_type VARCHAR(50),  -- "Physical", "Online", "Warehouse"

    -- Lokasyon
    address_line1 VARCHAR(200),
    address_line2 VARCHAR(200),
    city VARCHAR(100),
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    region VARCHAR(50),  -- "Marmara", "Ege", ...

    -- Coğrafi koordinatlar
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),

    -- Mağaza detayları
    opening_date DATE,
    square_meters INTEGER,
    employee_count INTEGER,

    -- Yönetim
    manager_name VARCHAR(100),
    district_manager VARCHAR(100),

    -- Durum
    is_active BOOLEAN DEFAULT TRUE,
    closing_date DATE,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dim_store_city ON dim_store(city);
CREATE INDEX idx_dim_store_region ON dim_store(region);

COMMENT ON TABLE dim_store IS 'Mağaza/Lokasyon dimension - SCD Type 1';

-- ============================================
-- 5. DIM_PAYMENT_METHOD (Ödeme Yöntemi)
-- ============================================
-- SCD Type 1: Basit lookup dimension

CREATE TABLE dim_payment_method (
    payment_method_key SERIAL PRIMARY KEY,

    -- Natural key
    payment_method_id INTEGER NOT NULL UNIQUE,

    -- Ödeme yöntemi bilgileri
    method_name VARCHAR(50) NOT NULL,
    method_type VARCHAR(30),  -- "Card", "Cash", "Digital", "Transfer"

    -- Özellikler
    requires_verification BOOLEAN DEFAULT FALSE,
    average_processing_time_minutes INTEGER,
    transaction_fee_percent DECIMAL(5,2),

    -- Durum
    is_active BOOLEAN DEFAULT TRUE,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dim_payment_method IS 'Ödeme yöntemi dimension - lookup table';

-- ============================================
-- Date Dimension'ı Doldur (2024-2026)
-- ============================================

CREATE OR REPLACE FUNCTION populate_dim_date(start_date DATE, end_date DATE)
RETURNS void AS $$
DECLARE
    current_date DATE := start_date;
    turkish_months TEXT[] := ARRAY['Ocak','Şubat','Mart','Nisan','Mayıs','Haziran',
                                    'Temmuz','Ağustos','Eylül','Ekim','Kasım','Aralık'];
    turkish_days TEXT[] := ARRAY['Pazartesi','Salı','Çarşamba','Perşembe','Cuma','Cumartesi','Pazar'];
    turkish_days_short TEXT[] := ARRAY['Pzt','Sal','Çar','Per','Cum','Cmt','Paz'];
    turkish_months_short TEXT[] := ARRAY['Oca','Şub','Mar','Nis','May','Haz','Tem','Ağu','Eyl','Eki','Kas','Ara'];
BEGIN
    WHILE current_date <= end_date LOOP
        INSERT INTO dim_date (
            date_key,
            full_date,
            year,
            year_name,
            quarter,
            quarter_name,
            month,
            month_name,
            month_name_short,
            month_year,
            week_of_year,
            week_of_month,
            day_of_month,
            day_of_year,
            day_of_week,
            day_name,
            day_name_short,
            is_weekday,
            is_weekend,
            fiscal_year,
            fiscal_quarter,
            fiscal_month,
            season
        ) VALUES (
            TO_CHAR(current_date, 'YYYYMMDD')::INTEGER,
            current_date,
            EXTRACT(YEAR FROM current_date)::INTEGER,
            EXTRACT(YEAR FROM current_date)::TEXT,
            EXTRACT(QUARTER FROM current_date)::INTEGER,
            'Q' || EXTRACT(QUARTER FROM current_date)::TEXT,
            EXTRACT(MONTH FROM current_date)::INTEGER,
            turkish_months[EXTRACT(MONTH FROM current_date)::INTEGER],
            turkish_months_short[EXTRACT(MONTH FROM current_date)::INTEGER],
            TO_CHAR(current_date, 'YYYY-MM'),
            EXTRACT(WEEK FROM current_date)::INTEGER,
            CEIL(EXTRACT(DAY FROM current_date) / 7.0)::INTEGER,
            EXTRACT(DAY FROM current_date)::INTEGER,
            EXTRACT(DOY FROM current_date)::INTEGER,
            EXTRACT(ISODOW FROM current_date)::INTEGER,
            turkish_days[EXTRACT(ISODOW FROM current_date)::INTEGER],
            turkish_days_short[EXTRACT(ISODOW FROM current_date)::INTEGER],
            EXTRACT(ISODOW FROM current_date) <= 5,
            EXTRACT(ISODOW FROM current_date) >= 6,
            -- Fiscal year (Mali yıl - Ocak başlangıçlı)
            EXTRACT(YEAR FROM current_date)::INTEGER,
            EXTRACT(QUARTER FROM current_date)::INTEGER,
            EXTRACT(MONTH FROM current_date)::INTEGER,
            -- Mevsim
            CASE
                WHEN EXTRACT(MONTH FROM current_date) IN (3,4,5) THEN 'İlkbahar'
                WHEN EXTRACT(MONTH FROM current_date) IN (6,7,8) THEN 'Yaz'
                WHEN EXTRACT(MONTH FROM current_date) IN (9,10,11) THEN 'Sonbahar'
                ELSE 'Kış'
            END
        );

        current_date := current_date + INTERVAL '1 day';
    END LOOP;

    -- Resmi tatilleri işaretle (Türkiye)
    UPDATE dim_date SET is_holiday = TRUE, holiday_name = 'Yılbaşı'
    WHERE month = 1 AND day_of_month = 1;

    UPDATE dim_date SET is_holiday = TRUE, holiday_name = '23 Nisan'
    WHERE month = 4 AND day_of_month = 23;

    UPDATE dim_date SET is_holiday = TRUE, holiday_name = '1 Mayıs'
    WHERE month = 5 AND day_of_month = 1;

    UPDATE dim_date SET is_holiday = TRUE, holiday_name = '19 Mayıs'
    WHERE month = 5 AND day_of_month = 19;

    UPDATE dim_date SET is_holiday = TRUE, holiday_name = '30 Ağustos'
    WHERE month = 8 AND day_of_month = 30;

    UPDATE dim_date SET is_holiday = TRUE, holiday_name = '29 Ekim'
    WHERE month = 10 AND day_of_month = 29;

    RAISE NOTICE 'Date dimension populated from % to %', start_date, end_date;
END;
$$ LANGUAGE plpgsql;

-- 2024-2026 arası tarihleri doldur
SELECT populate_dim_date('2024-01-01'::DATE, '2026-12-31'::DATE);

-- ============================================
-- İstatistikler
-- ============================================

SELECT
    '========================================' as separator;

SELECT 'OLAP Dimension Tabloları Oluşturuldu!' as status;

SELECT
    '========================================' as separator;

SELECT
    'dim_date' as dimension,
    COUNT(*) as kayit_sayisi,
    MIN(full_date) as baslangic,
    MAX(full_date) as bitis
FROM dim_date
UNION ALL
SELECT 'dim_customer', COUNT(*), NULL, NULL FROM dim_customer
UNION ALL
SELECT 'dim_product', COUNT(*), NULL, NULL FROM dim_product
UNION ALL
SELECT 'dim_store', COUNT(*), NULL, NULL FROM dim_store
UNION ALL
SELECT 'dim_payment_method', COUNT(*), NULL, NULL FROM dim_payment_method;

SELECT
    '========================================' as separator;

SELECT 'Dimension tabloları hazır! Şimdi Fact tablosunu oluşturun.' as mesaj;