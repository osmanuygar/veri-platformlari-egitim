-- Hafta 13 — Text-to-SQL alıştırması için örnek veri
SET search_path TO shop, public;

INSERT INTO customers (full_name, city, segment) VALUES
 ('Ayşe Yılmaz','İstanbul','gold'),
 ('Mehmet Demir','Ankara','silver'),
 ('Zeynep Kaya','İzmir','gold'),
 ('Ali Şahin','Bursa','bronze'),
 ('Fatma Çelik','Antalya','silver');

INSERT INTO products (sku, name, category, price) VALUES
 ('LPT-001','Ultrabook 14"','Bilgisayar',32999.00),
 ('PHN-001','Akıllı Telefon 128GB','Telefon',21499.00),
 ('HDP-001','Kablosuz Kulaklık','Aksesuar',3299.00),
 ('MON-001','27" 4K Monitör','Monitör',9899.00),
 ('KBD-001','Mekanik Klavye','Aksesuar',2499.00);

INSERT INTO orders (customer_id, order_date, status) VALUES
 (1,'2025-06-01','completed'),
 (1,'2025-07-15','completed'),
 (2,'2025-06-10','shipped'),
 (3,'2025-06-20','completed'),
 (4,'2025-07-01','cancelled'),
 (5,'2025-07-10','completed');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
 (1,1,1,32999.00),
 (1,3,1,3299.00),
 (2,2,1,21499.00),
 (3,4,1,9899.00),
 (4,5,2,2499.00),
 (5,3,1,3299.00),
 (6,1,1,32999.00);
