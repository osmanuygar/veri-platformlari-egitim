-- Hafta 11 — örnek veri (2 yıl, ~6000 satış satırı)
SET search_path TO bi, public;

-- dim_date: 2024-2025 aralığı
INSERT INTO dim_date (date_key, full_date, year, month, month_name, quarter, day_of_week, is_weekend)
SELECT
    to_char(d, 'YYYYMMDD')::int,
    d,
    extract(year from d)::int,
    extract(month from d)::int,
    to_char(d, 'Month'),
    extract(quarter from d)::int,
    to_char(d, 'Day'),
    extract(isodow from d) IN (6,7)
FROM generate_series('2024-01-01'::date, '2025-12-31'::date, '1 day') d;

INSERT INTO dim_customer (customer_id, full_name, city, region, segment) VALUES
 (1,'Ayşe Yılmaz','İstanbul','Marmara','gold'),
 (2,'Mehmet Demir','Ankara','İç Anadolu','silver'),
 (3,'Zeynep Kaya','İzmir','Ege','gold'),
 (4,'Ali Şahin','Bursa','Marmara','bronze'),
 (5,'Fatma Çelik','Antalya','Akdeniz','silver'),
 (6,'Emre Arslan','İstanbul','Marmara','gold'),
 (7,'Elif Doğan','Adana','Akdeniz','bronze'),
 (8,'Burak Koç','Konya','İç Anadolu','silver'),
 (9,'Deniz Yıldız','Trabzon','Karadeniz','bronze'),
 (10,'Gökhan Aydın','Gaziantep','Güneydoğu','silver');

INSERT INTO dim_product (sku, product_name, category) VALUES
 ('LPT-001','Ultrabook 14"','Bilgisayar'),
 ('LPT-002','Oyuncu Laptop 16"','Bilgisayar'),
 ('PHN-001','Akıllı Telefon 128GB','Telefon'),
 ('PHN-002','Akıllı Telefon 512GB','Telefon'),
 ('HDP-001','Kablosuz Kulaklık','Aksesuar'),
 ('MON-001','27" 4K Monitör','Monitör'),
 ('MON-002','34" Ultrawide Monitör','Monitör'),
 ('KBD-001','Mekanik Klavye','Aksesuar'),
 ('MSE-001','Kablosuz Mouse','Aksesuar'),
 ('TAB-001','Tablet 11"','Tablet');

-- ~6000 satış satırı, mevsimsellik + büyüme trendi ile (Kasım-Aralık'ta artış)
INSERT INTO fact_sales (date_key, customer_key, product_key, quantity, unit_price, revenue, order_status)
SELECT
    d.date_key,
    c.customer_key,
    p.product_key,
    qty,
    price,
    (qty * price)::numeric(12,2),
    status
FROM (
    SELECT
        dd.date_key,
        (1 + floor(random()*10))::int AS cust_n,
        (1 + floor(random()*10))::int AS prod_n,
        (1 + floor(random()*3))::int AS qty,
        round((500 + random()*30000)::numeric, 2) AS price,
        (ARRAY['completed','completed','completed','shipped','cancelled'])[1+floor(random()*5)] AS status
    FROM dim_date dd
    CROSS JOIN generate_series(1, 8) gs   -- günde ortalama 8 işlem denemesi
    WHERE random() < (
        CASE WHEN dd.month IN (11,12) THEN 0.55   -- Kasım-Aralık: kampanya sezonu
             ELSE 0.35 END
    )
) sub
JOIN dim_date d ON d.date_key = sub.date_key
JOIN dim_customer c ON c.customer_key = sub.cust_n
JOIN dim_product p ON p.product_key = sub.prod_n;

INSERT INTO region_managers (username, region) VALUES
 ('marmara_muduru', 'Marmara'),
 ('ege_muduru', 'Ege'),
 ('akdeniz_muduru', 'Akdeniz');

-- Hızlı doğrulama görünümü
CREATE OR REPLACE VIEW v_monthly_revenue AS
SELECT d.year, d.month, d.month_name,
       count(*) AS order_count,
       sum(f.revenue) FILTER (WHERE f.order_status <> 'cancelled') AS revenue
FROM fact_sales f
JOIN dim_date d ON d.date_key = f.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
