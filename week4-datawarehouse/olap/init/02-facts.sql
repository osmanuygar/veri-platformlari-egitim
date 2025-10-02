-- ============================================
-- OLAP Database - Fact Tables
-- Star Schema Implementation
-- ============================================

-- ============================================
-- FACT_SALES (Satış Fact Tablosu)
-- ============================================
-- Grain: Bir sipariş kalemi (order line item)

CREATE TABLE fact_sales (
    sales_fact_key BIGSERIAL PRIMARY KEY,  -- Surrogate key

    -- Foreign Keys (Dimension'lara referanslar)
    date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    customer_key INTEGER NOT NULL REFERENCES dim_customer(customer_key),
    product_key INTEGER NOT NULL REFERENCES dim_product(product_key),
    store_key INTEGER REFERENCES dim_store(store_key),
    payment_method_key INTEGER REFERENCES dim_payment_method(payment_method_key),

    -- Degenerate Dimensions (Fact içinde saklanan dimension'lar)
    order_number VARCHAR(50) NOT NULL,  -- Sipariş numarası
    order_line_number INTEGER NOT NULL,  -- Sipariş satır numarası

    -- Measures (Metrikler) - Additive
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    unit_cost DECIMAL(10,2) CHECK (unit_cost >= 0),
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    line_total DECIMAL(12,2) NOT NULL,  -- quantity * unit_price - discount

    -- Calculated Measures (Hesaplanan)
    gross_profit DECIMAL(12,2),  -- line_total - (quantity * unit_cost)
    profit_margin DECIMAL(5,2),  -- (gross_profit / line_total) * 100

    -- Semi-Additive Measures
    shipping_cost DECIMAL(8,2),  -- Sipariş bazında (order item'ler arasında paylaştırılır)

    -- Non-Additive Measures
    discount_percent DECIMAL(5,2),

    -- Flags (Ek bilgiler)
    is_promotion BOOLEAN DEFAULT FALSE,
    is_returned BOOLEAN DEFAULT FALSE,
    is_first_purchase BOOLEAN DEFAULT FALSE,  -- Müşterinin ilk alışveri şi mi?

    -- Order Status (snapshot)
    order_status VARCHAR(20),  -- Sipariş durumu (snapshot)
    payment_status VARCHAR(20),  -- Ödeme durumu (snapshot)

    -- Metadata
    source_system VARCHAR(50) DEFAULT 'OLTP',  -- Hangi sistemden geldi?
    etl_batch_id INTEGER,  -- Hangi ETL batch'inde yüklendi?
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- Indexes (Performans için kritik!)
-- ============================================

-- Foreign key indexes
CREATE INDEX idx_fact_sales_date ON fact_sales(date_key);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_key);
CREATE INDEX idx_fact_sales_product ON fact_sales(product_key);
CREATE INDEX idx_fact_sales_store ON fact_sales(store_key);
CREATE INDEX idx_fact_sales_payment ON fact_sales(payment_method_key);

-- Composite indexes (sık kullanılan kombinasyonlar)
CREATE INDEX idx_fact_sales_date_customer ON fact_sales(date_key, customer_key);
CREATE INDEX idx_fact_sales_date_product ON fact_sales(date_key, product_key);
CREATE INDEX idx_fact_sales_customer_product ON fact_sales(customer_key, product_key);

-- Degenerate dimension index
CREATE INDEX idx_fact_sales_order_number ON fact_sales(order_number);

-- Status indexes
CREATE INDEX idx_fact_sales_order_status ON fact_sales(order_status);

-- Date range queries için (partition key olabilir)
CREATE INDEX idx_fact_sales_created_at ON fact_sales(created_at);

-- ============================================
-- Trigger: Hesaplanan alanları otomatik doldur
-- ============================================

CREATE OR REPLACE FUNCTION calculate_fact_measures()
RETURNS TRIGGER AS $$
BEGIN
    -- Gross profit hesapla
    IF NEW.unit_cost IS NOT NULL THEN
        NEW.gross_profit := NEW.line_total - (NEW.quantity * NEW.unit_cost);

        -- Profit margin hesapla
        IF NEW.line_total > 0 THEN
            NEW.profit_margin := (NEW.gross_profit / NEW.line_total) * 100;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calculate_measures
BEFORE INSERT OR UPDATE ON fact_sales
FOR EACH ROW
EXECUTE FUNCTION calculate_fact_measures();

-- ============================================
-- Comments (Dokümantasyon)
-- ============================================

COMMENT ON TABLE fact_sales IS 'Satış fact tablosu - Star Schema merkez tablosu';
COMMENT ON COLUMN fact_sales.sales_fact_key IS 'Surrogate key - Fact tablosu için unique ID';
COMMENT ON COLUMN fact_sales.date_key IS 'FK -> dim_date (ne zaman?)';
COMMENT ON COLUMN fact_sales.customer_key IS 'FK -> dim_customer (kim?)';
COMMENT ON COLUMN fact_sales.product_key IS 'FK -> dim_product (ne?)';
COMMENT ON COLUMN fact_sales.store_key IS 'FK -> dim_store (nerede?)';
COMMENT ON COLUMN fact_sales.payment_method_key IS 'FK -> dim_payment_method (nasıl?)';
COMMENT ON COLUMN fact_sales.order_number IS 'Degenerate dimension - sipariş numarası';
COMMENT ON COLUMN fact_sales.line_total IS 'Additive measure - toplanabilir';
COMMENT ON COLUMN fact_sales.discount_percent IS 'Non-additive measure - toplanamaz';
COMMENT ON COLUMN fact_sales.shipping_cost IS 'Semi-additive measure - bazı boyutlarda toplanabilir';

-- ============================================
-- Aggregate Fact Table (Performans için)
-- ============================================
-- Günlük özet - detay yerine aggregate sorguları hızlandırır

CREATE TABLE fact_daily_sales_summary (
    daily_summary_key BIGSERIAL PRIMARY KEY,

    -- Dimensions
    date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    customer_key INTEGER REFERENCES dim_customer(customer_key),
    product_key INTEGER REFERENCES dim_product(product_key),
    store_key INTEGER REFERENCES dim_store(store_key),

    -- Aggregated Measures
    total_orders INTEGER NOT NULL DEFAULT 0,
    total_quantity INTEGER NOT NULL DEFAULT 0,
    total_revenue DECIMAL(14,2) NOT NULL DEFAULT 0,
    total_cost DECIMAL(14,2) DEFAULT 0,
    total_profit DECIMAL(14,2) DEFAULT 0,
    total_discount DECIMAL(12,2) DEFAULT 0,
    total_tax DECIMAL(12,2) DEFAULT 0,

    -- Calculated
    average_order_value DECIMAL(12,2),
    average_profit_margin DECIMAL(5,2),

    -- Counts
    unique_customers INTEGER DEFAULT 0,
    unique_products INTEGER DEFAULT 0,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Unique constraint
    UNIQUE(date_key, customer_key, product_key, store_key)
);

CREATE INDEX idx_fact_daily_date ON fact_daily_sales_summary(date_key);
CREATE INDEX idx_fact_daily_customer ON fact_daily_sales_summary(customer_key);
CREATE INDEX idx_fact_daily_product ON fact_daily_sales_summary(product_key);

COMMENT ON TABLE fact_daily_sales_summary IS 'Günlük satış özeti - aggregate fact table';

-- ============================================
-- Factless Fact Table (Promotion Tracking)
-- ============================================
-- "Coverage fact" - hangi müşterilere hangi promosyonlar gösterildi?

CREATE TABLE fact_promotion_coverage (
    promotion_coverage_key BIGSERIAL PRIMARY KEY,

    -- Dimensions
    date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    customer_key INTEGER NOT NULL REFERENCES dim_customer(customer_key),
    product_key INTEGER NOT NULL REFERENCES dim_product(product_key),

    -- Degenerate dimensions
    promotion_id VARCHAR(50),
    promotion_name VARCHAR(200),
    promotion_type VARCHAR(50),  -- "Discount", "BOGO", "Free Shipping"

    -- Flags (No measures!)
    was_shown BOOLEAN DEFAULT TRUE,
    was_clicked BOOLEAN DEFAULT FALSE,
    was_purchased BOOLEAN DEFAULT FALSE,

    -- Metadata
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(date_key, customer_key, product_key, promotion_id)
);

CREATE INDEX idx_fact_promo_date ON fact_promotion_coverage(date_key);
CREATE INDEX idx_fact_promo_customer ON fact_promotion_coverage(customer_key);

COMMENT ON TABLE fact_promotion_coverage IS 'Factless fact - promosyon izleme (measure yok, sadece olay kaydı)';

-- ============================================
-- Snapshot Fact Table (Stock Levels)
-- ============================================
-- Günlük stok durumu (periodic snapshot)

CREATE TABLE fact_inventory_snapshot (
    inventory_snapshot_key BIGSERIAL PRIMARY KEY,

    -- Dimensions
    date_key INTEGER NOT NULL REFERENCES dim_date(date_key),
    product_key INTEGER NOT NULL REFERENCES dim_product(product_key),
    store_key INTEGER REFERENCES dim_store(store_key),

    -- Semi-Additive Measures (sadece zaman dışında toplanabilir)
    quantity_on_hand INTEGER NOT NULL,  -- Eldeki miktar
    quantity_on_order INTEGER DEFAULT 0,  -- Siparişteki miktar
    quantity_reserved INTEGER DEFAULT 0,  -- Rezerve edilmiş

    -- Additive Measures
    units_received_today INTEGER DEFAULT 0,
    units_sold_today INTEGER DEFAULT 0,
    units_returned_today INTEGER DEFAULT 0,

    -- Calculated
    available_to_sell INTEGER,  -- on_hand - reserved
    inventory_value DECIMAL(12,2),  -- quantity * cost
    days_of_supply INTEGER,  -- Kaç günlük stok?

    -- Flags
    is_out_of_stock BOOLEAN DEFAULT FALSE,
    is_low_stock BOOLEAN DEFAULT FALSE,

    -- Metadata
    snapshot_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(date_key, product_key, store_key)
);

CREATE INDEX idx_fact_inventory_date ON fact_inventory_snapshot(date_key);
CREATE INDEX idx_fact_inventory_product ON fact_inventory_snapshot(product_key);

COMMENT ON TABLE fact_inventory_snapshot IS 'Snapshot fact - günlük stok durumu';

-- ============================================
-- Analytics Views (Hazır raporlar)
-- ============================================

-- 1. Satış özeti view
CREATE VIEW v_sales_summary AS
SELECT
    d.full_date,
    d.year,
    d.month_name,
    d.day_name,
    c.full_name as customer_name,
    c.customer_segment,
    c.city as customer_city,
    p.product_name,
    p.category_name,
    p.brand,
    s.store_name,
    s.city as store_city,
    pm.method_name as payment_method,
    f.order_number,
    f.quantity,
    f.unit_price,
    f.discount_amount,
    f.line_total,
    f.gross_profit,
    f.profit_margin,
    f.order_status
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_product p ON f.product_key = p.product_key
LEFT JOIN dim_store s ON f.store_key = s.store_key
LEFT JOIN dim_payment_method pm ON f.payment_method_key = pm.payment_method_key
WHERE f.order_status != 'Cancelled';

-- 2. Aylık satış trendi
CREATE VIEW v_monthly_sales_trend AS
SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT f.order_number) as total_orders,
    SUM(f.quantity) as total_quantity,
    SUM(f.line_total) as total_revenue,
    SUM(f.gross_profit) as total_profit,
    AVG(f.profit_margin) as avg_profit_margin,
    COUNT(DISTINCT f.customer_key) as unique_customers,
    COUNT(DISTINCT f.product_key) as unique_products
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.order_status = 'Delivered'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- 3. Kategori performansı
CREATE VIEW v_category_performance AS
SELECT
    p.category_name,
    p.parent_category_name,
    COUNT(DISTINCT f.sales_fact_key) as total_transactions,
    SUM(f.quantity) as total_quantity_sold,
    SUM(f.line_total) as total_revenue,
    SUM(f.gross_profit) as total_profit,
    AVG(f.profit_margin) as avg_profit_margin,
    COUNT(DISTINCT f.customer_key) as unique_customers,
    COUNT(DISTINCT f.product_key) as products_sold
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
WHERE f.order_status = 'Delivered'
  AND p.is_current = TRUE
GROUP BY p.category_name, p.parent_category_name
ORDER BY total_revenue DESC;

-- 4. Müşteri segment analizi
CREATE VIEW v_customer_segment_analysis AS
SELECT
    c.customer_segment,
    COUNT(DISTINCT c.customer_key) as customer_count,
    COUNT(DISTINCT f.order_number) as total_orders,
    SUM(f.line_total) as total_revenue,
    AVG(f.line_total) as avg_transaction_value,
    SUM(f.gross_profit) as total_profit,
    AVG(f.profit_margin) as avg_profit_margin
FROM dim_customer c
LEFT JOIN fact_sales f ON c.customer_key = f.customer_key
WHERE c.is_current = TRUE
  AND (f.order_status = 'Delivered' OR f.order_status IS NULL)
GROUP BY c.customer_segment
ORDER BY total_revenue DESC;

-- 5. Günlük satış performansı
CREATE VIEW v_daily_performance AS
SELECT
    d.full_date,
    d.day_name,
    d.is_weekend,
    d.is_holiday,
    COUNT(DISTINCT f.order_number) as orders,
    SUM(f.line_total) as revenue,
    SUM(f.gross_profit) as profit,
    COUNT(DISTINCT f.customer_key) as customers,
    SUM(f.line_total) / NULLIF(COUNT(DISTINCT f.order_number), 0) as avg_order_value
FROM dim_date d
LEFT JOIN fact_sales f ON d.date_key = f.date_key
    AND f.order_status = 'Delivered'
WHERE d.full_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY d.full_date, d.day_name, d.is_weekend, d.is_holiday
ORDER BY d.full_date DESC;

-- ============================================
-- Materialized Views (Performans için)
-- ============================================

-- Aylık özet - sık kullanılıyor, materialize edilmeli
CREATE MATERIALIZED VIEW mv_monthly_kpi AS
SELECT
    d.year,
    d.month,
    d.month_name,
    d.quarter,
    d.quarter_name,

    -- Satış metrikleri
    COUNT(DISTINCT f.order_number) as total_orders,
    SUM(f.quantity) as total_items_sold,
    SUM(f.line_total) as total_revenue,
    SUM(f.discount_amount) as total_discounts,
    SUM(f.gross_profit) as total_profit,

    -- Ortalamalar
    AVG(f.line_total) as avg_transaction_value,
    AVG(f.profit_margin) as avg_profit_margin,

    -- Müşteri metrikleri
    COUNT(DISTINCT f.customer_key) as unique_customers,

    -- Ürün metrikleri
    COUNT(DISTINCT f.product_key) as unique_products_sold,

    -- Growth (önceki aya göre)
    LAG(SUM(f.line_total)) OVER (ORDER BY d.year, d.month) as prev_month_revenue,

    -- YoY (Year over Year)
    LAG(SUM(f.line_total), 12) OVER (ORDER BY d.year, d.month) as prev_year_revenue

FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.order_status = 'Delivered'
GROUP BY d.year, d.month, d.month_name, d.quarter, d.quarter_name
ORDER BY d.year, d.month;

-- Refresh için index
CREATE UNIQUE INDEX idx_mv_monthly_kpi ON mv_monthly_kpi(year, month);

-- Refresh function
CREATE OR REPLACE FUNCTION refresh_monthly_kpi()
RETURNS void AS $
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_monthly_kpi;
    RAISE NOTICE 'Monthly KPI materialized view refreshed';
END;
$ LANGUAGE plpgsql;

COMMENT ON MATERIALIZED VIEW mv_monthly_kpi IS 'Aylık KPI özeti - günde 1 kez refresh edilmeli';

-- ============================================
-- Data Quality Checks
-- ============================================

CREATE OR REPLACE FUNCTION check_fact_data_quality()
RETURNS TABLE (
    check_name TEXT,
    status TEXT,
    issue_count BIGINT,
    details TEXT
) AS $
BEGIN
    -- 1. Orphan records (dimension'da olmayan FK)
    RETURN QUERY
    SELECT
        'Orphan Customer Keys'::TEXT,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::TEXT,
        COUNT(*),
        'Fact records with invalid customer_key'::TEXT
    FROM fact_sales f
    WHERE NOT EXISTS (SELECT 1 FROM dim_customer c WHERE c.customer_key = f.customer_key);

    -- 2. Negatif değerler
    RETURN QUERY
    SELECT
        'Negative Values'::TEXT,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::TEXT,
        COUNT(*),
        'Fact records with negative measures'::TEXT
    FROM fact_sales
    WHERE quantity < 0 OR unit_price < 0 OR line_total < 0;

    -- 3. Null foreign keys
    RETURN QUERY
    SELECT
        'Null Foreign Keys'::TEXT,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::TEXT,
        COUNT(*),
        'Fact records with NULL required foreign keys'::TEXT
    FROM fact_sales
    WHERE date_key IS NULL OR customer_key IS NULL OR product_key IS NULL;

    -- 4. Future dates
    RETURN QUERY
    SELECT
        'Future Dates'::TEXT,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::TEXT,
        COUNT(*),
        'Fact records with future dates'::TEXT
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    WHERE d.full_date > CURRENT_DATE;

    -- 5. Duplicate records
    RETURN QUERY
    SELECT
        'Duplicate Records'::TEXT,
        CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END::TEXT,
        COUNT(*),
        'Duplicate order_number + order_line_number combinations'::TEXT
    FROM (
        SELECT order_number, order_line_number, COUNT(*) as cnt
        FROM fact_sales
        GROUP BY order_number, order_line_number
        HAVING COUNT(*) > 1
    ) duplicates;

END;
$ LANGUAGE plpgsql;

COMMENT ON FUNCTION check_fact_data_quality() IS 'ETL sonrası veri kalitesi kontrolü';

-- ============================================
-- Helper Functions
-- ============================================

-- Belirli bir tarih aralığındaki satışları sil (ETL reprocessing için)
CREATE OR REPLACE FUNCTION delete_sales_by_date_range(
    p_start_date DATE,
    p_end_date DATE
)
RETURNS INTEGER AS $
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM fact_sales
    WHERE date_key BETWEEN
        TO_CHAR(p_start_date, 'YYYYMMDD')::INTEGER
        AND TO_CHAR(p_end_date, 'YYYYMMDD')::INTEGER;

    GET DIAGNOSTICS deleted_count = ROW_COUNT;

    RAISE NOTICE 'Deleted % fact records between % and %',
        deleted_count, p_start_date, p_end_date;

    RETURN deleted_count;
END;
$ LANGUAGE plpgsql;

-- Fact tablo istatistikleri
CREATE OR REPLACE FUNCTION get_fact_statistics()
RETURNS TABLE (
    metric_name TEXT,
    metric_value TEXT
) AS $
BEGIN
    RETURN QUERY
    SELECT 'Total Records'::TEXT, COUNT(*)::TEXT FROM fact_sales
    UNION ALL
    SELECT 'Date Range',
        MIN(d.full_date)::TEXT || ' to ' || MAX(d.full_date)::TEXT
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    UNION ALL
    SELECT 'Total Revenue',
        TO_CHAR(SUM(line_total), 'FM999,999,999.00')
    FROM fact_sales
    WHERE order_status = 'Delivered'
    UNION ALL
    SELECT 'Total Profit',
        TO_CHAR(SUM(gross_profit), 'FM999,999,999.00')
    FROM fact_sales
    WHERE order_status = 'Delivered'
    UNION ALL
    SELECT 'Unique Customers',
        COUNT(DISTINCT customer_key)::TEXT
    FROM fact_sales
    UNION ALL
    SELECT 'Unique Products',
        COUNT(DISTINCT product_key)::TEXT
    FROM fact_sales
    UNION ALL
    SELECT 'Average Order Value',
        TO_CHAR(AVG(line_total), 'FM999,999.00')
    FROM fact_sales
    WHERE order_status = 'Delivered';
END;
$ LANGUAGE plpgsql;

-- ============================================
-- İstatistikler ve Özet
-- ============================================

SELECT
    '========================================' as separator;

SELECT 'OLAP Fact Tabloları Oluşturuldu!' as status;

SELECT
    '========================================' as separator;

-- Tablo listesi
SELECT
    'fact_sales' as fact_table,
    'Transactional grain - order line item' as description,
    COUNT(*) as row_count
FROM fact_sales
UNION ALL
SELECT
    'fact_daily_sales_summary',
    'Aggregate fact - daily summary',
    COUNT(*)
FROM fact_daily_sales_summary
UNION ALL
SELECT
    'fact_promotion_coverage',
    'Factless fact - promotion tracking',
    COUNT(*)
FROM fact_promotion_coverage
UNION ALL
SELECT
    'fact_inventory_snapshot',
    'Snapshot fact - daily inventory',
    COUNT(*)
FROM fact_inventory_snapshot;

SELECT
    '========================================' as separator;

-- View listesi
SELECT
    'v_sales_summary' as view_name,
    'Satış detay raporu' as description
UNION ALL
SELECT 'v_monthly_sales_trend', 'Aylık satış trendi'
UNION ALL
SELECT 'v_category_performance', 'Kategori performansı'
UNION ALL
SELECT 'v_customer_segment_analysis', 'Müşteri segment analizi'
UNION ALL
SELECT 'v_daily_performance', 'Günlük performans';

SELECT
    '========================================' as separator;

SELECT 'Fact tabloları hazır! ETL ile veri yüklenebilir.' as mesaj;

SELECT
    '========================================' as separator;