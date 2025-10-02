-- ============================================
-- OLTP - Daha Fazla Veri Üretme Scripti
-- Büyük veri seti oluşturmak için
-- ============================================

-- Bu script OPSIYONEL'dir
-- Daha fazla test verisi istiyorsanız çalıştırın

-- ============================================
-- Daha fazla müşteri (35 ek müşteri)
-- ============================================

INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, customer_segment) VALUES
('İrem', 'Öz', 'irem.oz@email.com', '5551234582', '1993-04-12', 'F', 'Standard'),
('Kaan', 'Bulut', 'kaan.bulut@email.com', '5551234583', '1988-09-20', 'M', 'Premium'),
('Lale', 'Akın', 'lale.akin@email.com', '5551234584', '1995-06-18', 'F', 'Standard'),
('Mert', 'Taş', 'mert.tas@email.com', '5551234585', '1990-12-05', 'M', 'VIP'),
('Nil', 'Erdem', 'nil.erdem@email.com', '5551234586', '1994-03-22', 'F', 'Premium'),
('Okan', 'Yaman', 'okan.yaman@email.com', '5551234587', '1987-07-14', 'M', 'Standard'),
('Pelin', 'Şen', 'pelin.sen@email.com', '5551234588', '1996-01-30', 'F', 'Premium'),
('Rıza', 'Acar', 'riza.acar@email.com', '5551234589', '1989-10-08', 'M', 'Standard'),
('Seda', 'Tekin', 'seda.tekin@email.com', '5551234590', '1992-05-16', 'F', 'VIP'),
('Taner', 'Uzun', 'taner.uzun@email.com', '5551234591', '1991-08-25', 'M', 'Premium'),
('Ufuk', 'Dal', 'ufuk.dal@email.com', '5551234592', '1986-11-12', 'M', 'Standard'),
('Vildan', 'Kılıç', 'vildan.kilic@email.com', '5551234593', '1993-02-28', 'F', 'Premium'),
('Yalçın', 'Bozkurt', 'yalcin.bozkurt@email.com', '5551234594', '1990-07-19', 'M', 'VIP'),
('Zehra', 'Ergün', 'zehra.ergun@email.com', '5551234595', '1995-04-07', 'F', 'Standard'),
('Barış', 'Güler', 'baris.guler@email.com', '5551234596', '1988-12-15', 'M', 'Premium');

-- ============================================
-- Fonksiyon: Rastgele sipariş oluştur
-- ============================================

CREATE OR REPLACE FUNCTION generate_random_orders(order_count INTEGER)
RETURNS void AS $$
DECLARE
    i INTEGER;
    random_customer_id INTEGER;
    random_address_id INTEGER;
    random_payment_method INTEGER;
    order_num VARCHAR(50);
    order_dt TIMESTAMP;
BEGIN
    FOR i IN 1..order_count LOOP
        -- Rastgele müşteri seç
        SELECT customer_id INTO random_customer_id
        FROM customers
        ORDER BY RANDOM()
        LIMIT 1;

        -- Müşterinin adresini al
        SELECT address_id INTO random_address_id
        FROM addresses
        WHERE customer_id = random_customer_id
        LIMIT 1;

        -- Rastgele ödeme yöntemi
        random_payment_method := FLOOR(1 + RANDOM() * 5);

        -- Sipariş numarası oluştur
        order_num := 'ORD-2025-' || LPAD((1000 + i)::TEXT, 4, '0');

        -- Rastgele tarih (son 90 gün)
        order_dt := CURRENT_TIMESTAMP - (RANDOM() * INTERVAL '90 days');

        -- Sipariş oluştur
        INSERT INTO orders (
            customer_id,
            order_number,
            order_date,
            shipping_address_id,
            billing_address_id,
            payment_method_id,
            payment_status,
            order_status,
            shipping_cost,
            tax_amount
        ) VALUES (
            random_customer_id,
            order_num,
            order_dt,
            random_address_id,
            random_address_id,
            random_payment_method,
            CASE WHEN RANDOM() > 0.1 THEN 'Paid' ELSE 'Pending' END,
            CASE
                WHEN order_dt < CURRENT_TIMESTAMP - INTERVAL '7 days' THEN 'Delivered'
                WHEN order_dt < CURRENT_TIMESTAMP - INTERVAL '3 days' THEN 'Shipped'
                WHEN order_dt < CURRENT_TIMESTAMP - INTERVAL '1 day' THEN 'Processing'
                ELSE 'Pending'
            END,
            CASE WHEN RANDOM() > 0.5 THEN 29.99 ELSE 0 END,
            0
        );

        -- Her siparişe 1-5 arası ürün ekle
        PERFORM add_random_items_to_order(
            (SELECT order_id FROM orders WHERE order_number = order_num),
            FLOOR(1 + RANDOM() * 5)::INTEGER
        );

    END LOOP;

    RAISE NOTICE '% adet sipariş oluşturuldu', order_count;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Fonksiyon: Siparişe rastgele ürün ekle
-- ============================================

CREATE OR REPLACE FUNCTION add_random_items_to_order(p_order_id INTEGER, item_count INTEGER)
RETURNS void AS $$
DECLARE
    i INTEGER;
    random_product_id INTEGER;
    random_product_name VARCHAR(200);
    random_price DECIMAL(10,2);
    random_quantity INTEGER;
    random_discount DECIMAL(5,2);
BEGIN
    FOR i IN 1..item_count LOOP
        -- Rastgele ürün seç
        SELECT
            product_id,
            product_name,
            unit_price
        INTO
            random_product_id,
            random_product_name,
            random_price
        FROM products
        WHERE is_active = true
        ORDER BY RANDOM()
        LIMIT 1;

        -- Rastgele miktar (1-3)
        random_quantity := FLOOR(1 + RANDOM() * 3);

        -- Rastgele indirim (%0-20)
        random_discount := FLOOR(RANDOM() * 21);

        -- Ürünü siparişe ekle
        INSERT INTO order_items (
            order_id,
            product_id,
            product_name,
            unit_price,
            quantity,
            discount_percent
        ) VALUES (
            p_order_id,
            random_product_id,
            random_product_name,
            random_price,
            random_quantity,
            random_discount
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Örnek: 100 ek sipariş oluştur
-- ============================================

-- UYARI: Bu işlem birkaç saniye sürebilir
-- İsterseniz yorum satırından çıkarın:

-- SELECT generate_random_orders(100);

-- ============================================
-- Müşteri segmentasyonunu güncelle
-- (Harcama miktarına göre)
-- ============================================

CREATE OR REPLACE FUNCTION update_customer_segments()
RETURNS void AS $$
BEGIN
    -- VIP: 50.000 TL üzeri
    UPDATE customers
    SET customer_segment = 'VIP'
    WHERE total_spent >= 50000;

    -- Premium: 10.000 - 50.000 TL
    UPDATE customers
    SET customer_segment = 'Premium'
    WHERE total_spent >= 10000 AND total_spent < 50000;

    -- Standard: 10.000 TL altı
    UPDATE customers
    SET customer_segment = 'Standard'
    WHERE total_spent < 10000;

    RAISE NOTICE 'Müşteri segmentasyonu güncellendi';
END;
$$ LANGUAGE plpgsql;

-- Segmentasyonu çalıştır
SELECT update_customer_segments();

-- ============================================
-- Stok uyarısı fonksiyonu
-- ============================================

CREATE OR REPLACE FUNCTION check_low_stock()
RETURNS TABLE (
    product_name VARCHAR,
    current_stock INTEGER,
    reorder_level INTEGER,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.product_name::VARCHAR,
        p.stock_quantity,
        p.reorder_level,
        CASE
            WHEN p.stock_quantity = 0 THEN 'OUT OF STOCK'::TEXT
            WHEN p.stock_quantity <= p.reorder_level THEN 'LOW STOCK'::TEXT
            ELSE 'OK'::TEXT
        END as status
    FROM products p
    WHERE p.stock_quantity <= p.reorder_level
    ORDER BY p.stock_quantity ASC;
END;
$$ LANGUAGE plpgsql;

-- Stok durumunu kontrol et
SELECT * FROM check_low_stock();

-- ============================================
-- RFM Analizi (Recency, Frequency, Monetary)
-- ============================================

CREATE OR REPLACE VIEW v_rfm_analysis AS
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name as customer_name,
        c.email,
        -- Recency: Son sipariş ne kadar önce?
        CURRENT_DATE - MAX(DATE(o.order_date)) as recency_days,
        -- Frequency: Kaç sipariş verdi?
        COUNT(DISTINCT o.order_id) as frequency,
        -- Monetary: Toplam ne kadar harcadı?
        SUM(o.total_amount) as monetary_value
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Delivered'
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email
),
rfm_scores AS (
    SELECT
        *,
        -- Recency score (düşük iyi)
        NTILE(5) OVER (ORDER BY recency_days DESC) as r_score,
        -- Frequency score (yüksek iyi)
        NTILE(5) OVER (ORDER BY frequency ASC) as f_score,
        -- Monetary score (yüksek iyi)
        NTILE(5) OVER (ORDER BY monetary_value ASC) as m_score
    FROM customer_metrics
)
SELECT
    customer_id,
    customer_name,
    email,
    recency_days,
    frequency,
    ROUND(monetary_value, 2) as monetary_value,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) as rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Promising'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
        ELSE 'Potential'
    END as customer_segment_rfm
FROM rfm_scores
ORDER BY rfm_total DESC;

-- RFM analizi sonuçları
SELECT
    customer_segment_rfm,
    COUNT(*) as musteri_sayisi,
    AVG(monetary_value) as ortalama_harcama
FROM v_rfm_analysis
GROUP BY customer_segment_rfm
ORDER BY ortalama_harcama DESC;

-- ============================================
-- Kohort Analizi View
-- ============================================

CREATE OR REPLACE VIEW v_cohort_analysis AS
WITH first_purchase AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) as cohort_month
    FROM orders
    WHERE order_status = 'Delivered'
    GROUP BY customer_id
),
orders_with_cohort AS (
    SELECT
        o.customer_id,
        o.order_id,
        DATE_TRUNC('month', o.order_date) as order_month,
        fp.cohort_month,
        EXTRACT(YEAR FROM AGE(DATE_TRUNC('month', o.order_date), fp.cohort_month)) * 12 +
        EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.order_date), fp.cohort_month)) as months_since_first
    FROM orders o
    JOIN first_purchase fp ON o.customer_id = fp.customer_id
    WHERE o.order_status = 'Delivered'
)
SELECT
    cohort_month,
    months_since_first,
    COUNT(DISTINCT customer_id) as active_customers
FROM orders_with_cohort
GROUP BY cohort_month, months_since_first
ORDER BY cohort_month, months_since_first;

-- ============================================
-- Özet İstatistikler
-- ============================================

SELECT
    '========================================' as separator;

SELECT 'OLTP VERİTABANI ÖZETİ' as title;

SELECT
    '========================================' as separator;

-- Toplam veriler
SELECT
    (SELECT COUNT(*) FROM customers) as toplam_musteri,
    (SELECT COUNT(*) FROM products) as toplam_urun,
    (SELECT COUNT(*) FROM orders) as toplam_siparis,
    (SELECT SUM(total_amount) FROM orders WHERE order_status = 'Delivered') as toplam_ciro;

SELECT
    '========================================' as separator;

SELECT 'Veri üretim scriptleri hazır!' as mesaj;
SELECT 'Daha fazla veri için: SELECT generate_random_orders(100);' as komut;