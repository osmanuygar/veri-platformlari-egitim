-- ============================================
-- Star Schema Görselleştirme ve Örnekler
-- ============================================

/*
    STAR SCHEMA DİYAGRAMI:

              dim_date
                 │
                 │ date_key
                 │
    dim_customer ├─────────────────┐
                 │                 │
    customer_key │                 │
                 │   FACT_SALES    │ product_key
                 ├─────────────────┤
                 │                 │
     store_key   │                 │
                 │                 │
      dim_store ─┘                 └─ dim_product
                 │
                 │ payment_method_key
                 │
         dim_payment_method

    Merkez: fact_sales (metrikler burada)
    Çevre: dimension'lar (bağlam bilgisi)

*/

-- ============================================
-- Star Schema Örnek Sorgular
-- ============================================

-- ============================================
-- 1. BASIT STAR SCHEMA SORGUSU
-- ============================================
-- Fact + 1 Dimension

SELECT
    -- Dimension bilgileri (KİM?)
    c.full_name,
    c.customer_segment,
    c.city,

    -- Fact metrikleri (NE KADAR?)
    COUNT(DISTINCT f.order_number) as siparis_sayisi,
    SUM(f.quantity) as toplam_adet,
    SUM(f.line_total) as toplam_harcama,
    AVG(f.line_total) as ortalama_islem,
    SUM(f.gross_profit) as toplam_kar

FROM fact_sales f
JOIN dim_customer c ON f.customer_key = c.customer_key

WHERE c.is_current = TRUE  -- Aktif dimension kaydı
  AND f.order_status = 'Delivered'

GROUP BY c.customer_key, c.full_name, c.customer_segment, c.city
ORDER BY toplam_harcama DESC
LIMIT 10;

-- ============================================
-- 2. İKİ BOYUTLU ANALİZ
-- ============================================
-- Fact + 2 Dimensions (Kategori x Segment)

SELECT
    -- Dimension 1: Ürün kategorisi (NE?)
    p.category_name,
    p.brand,

    -- Dimension 2: Müşteri segmenti (KİM?)
    c.customer_segment,

    -- Metrikler
    COUNT(DISTINCT f.sales_fact_key) as islem_sayisi,
    SUM(f.quantity) as toplam_adet,
    SUM(f.line_total) as toplam_gelir,
    AVG(f.profit_margin) as ort_kar_marji

FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_customer c ON f.customer_key = c.customer_key

WHERE p.is_current = TRUE
  AND c.is_current = TRUE
  AND f.order_status = 'Delivered'

GROUP BY p.category_name, p.brand, c.customer_segment
ORDER BY toplam_gelir DESC;

-- ============================================
-- 3. ZAMAN SERİSİ ANALİZİ
-- ============================================
-- Fact + Date Dimension (en önemli!)

SELECT
    -- Tarih hiyerarşisi
    d.year,
    d.quarter_name,
    d.month_name,

    -- Hafta içi/sonu analizi
    d.is_weekend,

    -- Metrikler
    COUNT(DISTINCT f.order_number) as siparis_sayisi,
    SUM(f.line_total) as gunluk_ciro,
    AVG(f.line_total) as ortalama_sepet,
    SUM(f.gross_profit) as kar,

    -- Moving average (3 günlük)
    AVG(SUM(f.line_total)) OVER (
        ORDER BY d.full_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as hareketli_ortalama_3gun

FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key

WHERE f.order_status = 'Delivered'
  AND d.year = 2025

GROUP BY d.year, d.quarter, d.quarter_name, d.month, d.month_name,
         d.full_date, d.is_weekend
ORDER BY d.full_date;

-- ============================================
-- 4. DRILL-DOWN ANALİZİ
-- ============================================
-- Yıl -> Çeyrek -> Ay -> Gün

-- Level 1: Yıllık
SELECT
    d.year,
    COUNT(DISTINCT f.order_number) as siparisler,
    SUM(f.line_total) as ciro
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.order_status = 'Delivered'
GROUP BY d.year;

-- Level 2: Çeyrek
SELECT
    d.year,
    d.quarter_name,
    COUNT(DISTINCT f.order_number) as siparisler,
    SUM(f.line_total) as ciro
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.order_status = 'Delivered'
  AND d.year = 2025
GROUP BY d.year, d.quarter, d.quarter_name;

-- Level 3: Ay
SELECT
    d.year,
    d.quarter_name,
    d.month_name,
    COUNT(DISTINCT f.order_number) as siparisler,
    SUM(f.line_total) as ciro
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.order_status = 'Delivered'
  AND d.year = 2025
  AND d.quarter = 1
GROUP BY d.year, d.quarter, d.quarter_name, d.month, d.month_name;

-- ============================================
-- 5. SLICE AND DICE
-- ============================================
-- Belirli boyutları sabitle, diğerlerini analiz et

-- SLICE: Sadece 2025 Q1
SELECT
    p.category_name,
    c.customer_segment,
    SUM(f.line_total) as ciro
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE d.year = 2025
  AND d.quarter = 1  -- SLICE: Q1'e odaklan
  AND f.order_status = 'Delivered'
GROUP BY p.category_name, c.customer_segment
ORDER BY ciro DESC;

-- DICE: 2025 Q1, VIP müşteriler, Elektronik
SELECT
    d.month_name,
    p.product_name,
    p.brand,
    SUM(f.line_total) as ciro
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_customer c ON f.customer_key = c.customer_key
WHERE d.year = 2025
  AND d.quarter = 1
  AND c.customer_segment = 'VIP'  -- DICE
  AND p.category_name = 'Elektronik'  -- DICE
  AND f.order_status = 'Delivered'
GROUP BY d.month, d.month_name, p.product_name, p.brand
ORDER BY ciro DESC;

-- ============================================
-- 6. ROLL-UP ANALİZİ
-- ============================================
-- Detaydan özete (gün -> ay -> çeyrek -> yıl)

SELECT
    -- Tüm seviyeler
    d.year,
    d.quarter_name,
    d.month_name,
    p.parent_category_name,
    p.category_name,

    SUM(f.line_total) as ciro

FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key

WHERE f.order_status = 'Delivered'

-- ROLLUP: Otomatik subtotal'lar
GROUP BY ROLLUP(
    d.year,
    d.quarter_name,
    d.month_name,
    p.parent_category_name,
    p.category_name
)
ORDER BY d.year, d.quarter_name, d.month_name,
         p.parent_category_name, p.category_name;

-- ============================================
-- 7. TÜM BOYUTLARI KULLANAN ANALİZ
-- ============================================
-- Fact + Tüm Dimensions (5W1H)

SELECT
    -- NE ZAMAN? (When)
    d.full_date,
    d.day_name,
    d.is_weekend,

    -- KİM? (Who)
    c.full_name,
    c.customer_segment,
    c.city as musteri_sehir,

    -- NE? (What)
    p.product_name,
    p.category_name,
    p.brand,

    -- NEREDE? (Where)
    s.store_name,
    s.city as magaza_sehir,

    -- NASIL? (How)
    pm.method_name as odeme_yontemi,

    -- NE KADAR? (Measures)
    f.quantity,
    f.unit_price,
    f.discount_amount,
    f.line_total,
    f.gross_profit,
    f.profit_margin

FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_product p ON f.product_key = p.product_key
LEFT JOIN dim_store s ON f.store_key = s.store_key
LEFT JOIN dim_payment_method pm ON f.payment_method_key = pm.payment_method_key

WHERE f.order_status = 'Delivered'
  AND d.full_date >= CURRENT_DATE - INTERVAL '7 days'

ORDER BY d.full_date DESC, f.line_total DESC
LIMIT 100;

-- ============================================
-- 8. COHORT ANALİZİ (Dimension'larla)
-- ============================================
-- Müşterilerin ilk alışveriş ayına göre grupla

WITH first_purchase AS (
    SELECT
        f.customer_key,
        MIN(d.year || '-' || LPAD(d.month::TEXT, 2, '0')) as cohort_month
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    WHERE f.order_status = 'Delivered'
    GROUP BY f.customer_key
),
cohort_data AS (
    SELECT
        fp.cohort_month,
        d.year || '-' || LPAD(d.month::TEXT, 2, '0') as order_month,
        COUNT(DISTINCT f.customer_key) as active_customers,
        SUM(f.line_total) as revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    JOIN first_purchase fp ON f.customer_key = fp.customer_key
    WHERE f.order_status = 'Delivered'
    GROUP BY fp.cohort_month, order_month
)
SELECT
    cohort_month,
    order_month,
    active_customers,
    revenue,
    ROUND(revenue / active_customers, 2) as revenue_per_customer
FROM cohort_data
ORDER BY cohort_month, order_month;

-- ============================================
-- 9. WINDOW FUNCTIONS ile ANALİZ
-- ============================================

SELECT
    d.full_date,
    d.day_name,
    p.category_name,

    -- Günlük metrikler
    SUM(f.line_total) as gunluk_ciro,
    COUNT(DISTINCT f.customer_key) as gunluk_musteri,

    -- Running total (kümülatif)
    SUM(SUM(f.line_total)) OVER (
        PARTITION BY p.category_name
        ORDER BY d.full_date
        ROWS UNBOUNDED PRECEDING
    ) as kumulatif_ciro,

    -- Önceki gün
    LAG(SUM(f.line_total)) OVER (
        PARTITION BY p.category_name
        ORDER BY d.full_date
    ) as onceki_gun_ciro,

    -- % Değişim
    ROUND(
        (SUM(f.line_total) - LAG(SUM(f.line_total)) OVER (
            PARTITION BY p.category_name
            ORDER BY d.full_date
        )) / NULLIF(LAG(SUM(f.line_total)) OVER (
            PARTITION BY p.category_name
            ORDER BY d.full_date
        ), 0) * 100,
        2
    ) as degisim_yuzdesi,

    -- Ranking
    RANK() OVER (
        PARTITION BY d.full_date
        ORDER BY SUM(f.line_total) DESC
    ) as gun_icinde_sira

FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key

WHERE f.order_status = 'Delivered'
  AND d.full_date >= CURRENT_DATE - INTERVAL '30 days'

GROUP BY d.full_date, d.day_name, p.category_name
ORDER BY d.full_date DESC, gunluk_ciro DESC;

-- ============================================
-- 10. PERFORMANS KARŞILAŞTIRMA
-- ============================================
-- Star Schema vs Normalized (OLTP)

-- Star Schema (HIZLI - 1 fact + join'ler)
EXPLAIN ANALYZE
SELECT
    d.month_name,
    p.category_name,
    SUM(f.line_total) as ciro
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_key = p.product_key
WHERE d.year = 2025
GROUP BY d.month, d.month_name, p.category_name;

-- Normalized OLTP equivalent'i daha çok JOIN gerektirir
-- Bu Star Schema'nın avantajı!

-- ============================================
-- Özet İstatistikler
-- ============================================

SELECT
    '==========================================' as separator;

SELECT 'STAR SCHEMA ÖRNEK SORGULAR' as baslik;

SELECT
    '==========================================' as separator;

SELECT 'Star Schema Avantajları:' as bilgi
UNION ALL SELECT '✅ Basit JOIN''ler (max 5-6 tablo)'
UNION ALL SELECT '✅ Hızlı sorgular (index optimizasyonu)'
UNION ALL SELECT '✅ Kolay anlaşılır (BI tool''lar için ideal)'
UNION ALL SELECT '✅ Denormalize (veri tekrarı OK, performans önemli)'
UNION ALL SELECT '✅ Aggregate''ler hızlı (SUM, AVG, COUNT)'
UNION ALL SELECT ''
UNION ALL SELECT 'Kullanım Senaryoları:'
UNION ALL SELECT '📊 BI Dashboard''ları'
UNION ALL SELECT '📈 Executive raporları'
UNION ALL SELECT '🔍 OLAP küpler'
UNION ALL SELECT '📉 Trend analizleri'
UNION ALL SELECT '💹 KPI takibi';

SELECT
    '==========================================' as separator;