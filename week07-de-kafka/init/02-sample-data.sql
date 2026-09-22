-- Hafta 7 — başlangıç verisi
-- Container açılır açılmaz sorgulanacak veri hazır olsun diye yüklenir.
-- Debezium ilk bağlandığında bu satırları "snapshot" olarak Kafka'ya basacak.

SET search_path TO shop, public;

INSERT INTO customers (full_name, email, city, segment) VALUES
  ('Ayşe Yılmaz',     'ayse.yilmaz@example.com',   'İstanbul', 'premium'),
  ('Mehmet Demir',    'mehmet.demir@example.com',  'Ankara',   'standard'),
  ('Zeynep Kaya',     'zeynep.kaya@example.com',   'İzmir',    'premium'),
  ('Ali Şahin',       'ali.sahin@example.com',     'Bursa',    'standard'),
  ('Fatma Çelik',     'fatma.celik@example.com',   'Antalya',  'standard'),
  ('Emre Arslan',     'emre.arslan@example.com',   'İstanbul', 'gold'),
  ('Elif Doğan',      'elif.dogan@example.com',    'Adana',    'standard'),
  ('Burak Koç',       'burak.koc@example.com',     'Konya',    'premium');

INSERT INTO products (sku, name, category, price, stock) VALUES
  ('LPT-001', 'Ultrabook 14"',          'Bilgisayar',   32999.00, 25),
  ('LPT-002', 'Oyuncu Laptop 16"',      'Bilgisayar',   54999.00, 12),
  ('PHN-001', 'Akıllı Telefon 128GB',   'Telefon',      21499.00, 60),
  ('PHN-002', 'Akıllı Telefon 512GB',   'Telefon',      28999.00, 30),
  ('HDP-001', 'Kablosuz Kulaklık',      'Aksesuar',      3299.00, 150),
  ('HDP-002', 'Kulak İçi Kulaklık',     'Aksesuar',      1199.00, 320),
  ('MON-001', '27" 4K Monitör',         'Monitör',       9899.00, 40),
  ('MON-002', '34" Ultrawide Monitör',  'Monitör',      18499.00, 15),
  ('KBD-001', 'Mekanik Klavye',         'Aksesuar',      2499.00, 90),
  ('MSE-001', 'Kablosuz Mouse',         'Aksesuar',       899.00, 200);

INSERT INTO orders (customer_id, status, total_amount) VALUES
  (1, 'completed', 36298.00),
  (2, 'shipped',   21499.00),
  (3, 'created',    9899.00),
  (1, 'completed',  3299.00),
  (6, 'shipped',   54999.00);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
  (1, 1, 1, 32999.00),
  (1, 5, 1,  3299.00),
  (2, 3, 1, 21499.00),
  (3, 7, 1,  9899.00),
  (4, 5, 1,  3299.00),
  (5, 2, 1, 54999.00);

-- Hızlı kontrol için görünüm
CREATE OR REPLACE VIEW v_order_summary AS
SELECT o.id            AS order_id,
       c.full_name     AS customer,
       c.city,
       o.status,
       o.total_amount,
       count(oi.id)    AS item_count,
       o.created_at
FROM orders o
JOIN customers c   ON c.id = o.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.id
GROUP BY o.id, c.full_name, c.city, o.status, o.total_amount, o.created_at
ORDER BY o.id;
