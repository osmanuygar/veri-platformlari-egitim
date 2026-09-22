-- ============================================
-- OLTP Sample Data
-- E-Ticaret Örnek Verileri
-- ============================================

-- ============================================
-- 1. CATEGORIES (Kategoriler)
-- ============================================
INSERT INTO categories (category_name, parent_category_id, description) VALUES
-- Ana kategoriler
('Elektronik', NULL, 'Elektronik ürünler'),
('Giyim', NULL, 'Giyim ve aksesuar'),
('Ev & Yaşam', NULL, 'Ev eşyaları'),
('Kitap', NULL, 'Kitaplar ve dergiler'),
('Spor', NULL, 'Spor malzemeleri');

-- Alt kategoriler
INSERT INTO categories (category_name, parent_category_id, description) VALUES
('Bilgisayar', 1, 'Laptop, masaüstü, tablet'),
('Telefon', 1, 'Akıllı telefonlar'),
('Kulaklık', 1, 'Kulaklıklar ve ses sistemleri'),
('Erkek Giyim', 2, 'Erkek kıyafetleri'),
('Kadın Giyim', 2, 'Kadın kıyafetleri'),
('Mobilya', 3, 'Ev mobilyaları'),
('Mutfak', 3, 'Mutfak eşyaları'),
('Roman', 4, 'Roman kitaplar'),
('Teknik Kitap', 4, 'Teknik ve eğitim kitapları'),
('Fitness', 5, 'Fitness ekipmanları');

-- ============================================
-- 2. CUSTOMERS (50 Müşteri)
-- ============================================
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, customer_segment, registration_date) VALUES
('Ahmet', 'Yılmaz', 'ahmet.yilmaz@email.com', '5551234567', '1990-05-15', 'M', 'Premium', '2024-01-15 10:30:00'),
('Ayşe', 'Demir', 'ayse.demir@email.com', '5551234568', '1992-08-22', 'F', 'Standard', '2024-02-20 14:20:00'),
('Mehmet', 'Kara', 'mehmet.kara@email.com', '5551234569', '1988-03-10', 'M', 'VIP', '2024-01-05 09:15:00'),
('Fatma', 'Şahin', 'fatma.sahin@email.com', '5551234570', '1995-11-30', 'F', 'Premium', '2024-03-12 16:45:00'),
('Ali', 'Çelik', 'ali.celik@email.com', '5551234571', '1987-07-18', 'M', 'Standard', '2024-04-08 11:00:00'),
('Zeynep', 'Arslan', 'zeynep.arslan@email.com', '5551234572', '1993-01-25', 'F', 'Premium', '2024-02-28 13:30:00'),
('Mustafa', 'Yıldız', 'mustafa.yildiz@email.com', '5551234573', '1991-09-12', 'M', 'Standard', '2024-05-14 10:15:00'),
('Elif', 'Aydın', 'elif.aydin@email.com', '5551234574', '1994-04-08', 'F', 'VIP', '2024-01-20 15:00:00'),
('Can', 'Özdemir', 'can.ozdemir@email.com', '5551234575', '1989-12-20', 'M', 'Premium', '2024-03-05 09:45:00'),
('Selin', 'Koç', 'selin.koc@email.com', '5551234576', '1996-06-14', 'F', 'Standard', '2024-04-18 12:20:00');

-- Daha fazla müşteri
INSERT INTO customers (first_name, last_name, email, phone, date_of_birth, gender, customer_segment) VALUES
('Burak', 'Güneş', 'burak.gunes@email.com', '5551234577', '1992-02-11', 'M', 'Standard'),
('Deniz', 'Kurt', 'deniz.kurt@email.com', '5551234578', '1990-07-25', 'F', 'Premium'),
('Emre', 'Kaya', 'emre.kaya@email.com', '5551234579', '1985-10-30', 'M', 'VIP'),
('Gizem', 'Yurt', 'gizem.yurt@email.com', '5551234580', '1997-03-15', 'F', 'Standard'),
('Hakan', 'Polat', 'hakan.polat@email.com', '5551234581', '1991-08-08', 'M', 'Premium');

-- ============================================
-- 3. ADDRESSES (Her müşteri için 1-2 adres)
-- ============================================
INSERT INTO addresses (customer_id, address_type, address_line1, city, state_province, postal_code, is_default) VALUES
(1, 'Home', 'Atatürk Cad. No: 123', 'İstanbul', 'Kadıköy', '34710', true),
(1, 'Work', 'Büyükdere Cad. No: 456', 'İstanbul', 'Şişli', '34394', false),
(2, 'Home', 'İnönü Sok. No: 78', 'Ankara', 'Çankaya', '06100', true),
(3, 'Home', 'Cumhuriyet Bulvarı No: 234', 'İzmir', 'Konak', '35250', true),
(4, 'Home', 'Kültür Sok. No: 45', 'Bursa', 'Nilüfer', '16110', true),
(5, 'Home', 'Gazi Cad. No: 567', 'Antalya', 'Muratpaşa', '07100', true),
(6, 'Home', 'Üniversite Cad. No: 89', 'İstanbul', 'Beşiktaş', '34340', true),
(7, 'Home', 'Güzelyalı Mah. No: 123', 'İzmir', 'Karşıyaka', '35540', true),
(8, 'Home', 'Kızılay Meydanı No: 456', 'Ankara', 'Kızılay', '06420', true),
(9, 'Home', 'Deniz Sok. No: 78', 'Antalya', 'Konyaaltı', '07050', true),
(10, 'Home', 'Park Cad. No: 234', 'Bursa', 'Osmangazi', '16200', true);

-- ============================================
-- 4. PRODUCTS (100 Ürün)
-- ============================================

-- Bilgisayar ürünleri
INSERT INTO products (category_id, product_name, description, brand, sku, unit_price, cost_price, stock_quantity) VALUES
(6, 'MacBook Pro 16"', 'Apple M3 Pro, 36GB RAM, 512GB SSD', 'Apple', 'LAPTOP-001', 89999.00, 75000.00, 15),
(6, 'Dell XPS 15', 'Intel i7, 16GB RAM, 512GB SSD', 'Dell', 'LAPTOP-002', 45999.00, 38000.00, 25),
(6, 'Lenovo ThinkPad X1', 'Intel i5, 16GB RAM, 256GB SSD', 'Lenovo', 'LAPTOP-003', 35999.00, 30000.00, 30),
(6, 'HP Pavilion', 'AMD Ryzen 5, 8GB RAM, 512GB SSD', 'HP', 'LAPTOP-004', 18999.00, 16000.00, 40),
(6, 'Asus ROG Strix', 'Intel i9, 32GB RAM, 1TB SSD, RTX 4070', 'Asus', 'LAPTOP-005', 75999.00, 65000.00, 10);

-- Telefon ürünleri
INSERT INTO products (category_id, product_name, description, brand, sku, unit_price, cost_price, stock_quantity) VALUES
(7, 'iPhone 15 Pro Max', '256GB, Titanyum', 'Apple', 'PHONE-001', 64999.00, 55000.00, 50),
(7, 'Samsung Galaxy S24 Ultra', '512GB', 'Samsung', 'PHONE-002', 54999.00, 47000.00, 45),
(7, 'Google Pixel 8 Pro', '256GB', 'Google', 'PHONE-003', 42999.00, 37000.00, 35),
(7, 'Xiaomi 14 Ultra', '512GB', 'Xiaomi', 'PHONE-004', 38999.00, 33000.00, 40),
(7, 'OnePlus 12', '256GB', 'OnePlus', 'PHONE-005', 32999.00, 28000.00, 55);

-- Kulaklık ürünleri
INSERT INTO products (category_id, product_name, description, brand, sku, unit_price, cost_price, stock_quantity) VALUES
(8, 'Sony WH-1000XM5', 'Gürültü önleyici kulaklık', 'Sony', 'HEADPHONE-001', 12999.00, 11000.00, 60),
(8, 'AirPods Pro 2', 'USB-C', 'Apple', 'HEADPHONE-002', 9999.00, 8500.00, 100),
(8, 'Bose QuietComfort Ultra', 'Premium kulaklık', 'Bose', 'HEADPHONE-003', 14999.00, 13000.00, 45),
(8, 'JBL Tune 720BT', 'Kablosuz kulaklık', 'JBL', 'HEADPHONE-004', 1999.00, 1700.00, 150);

-- Giyim ürünleri
INSERT INTO products (category_id, product_name, brand, sku, unit_price, cost_price, stock_quantity) VALUES
(9, 'Erkek Kot Pantolon', 'Levi''s', 'CLOTH-M-001', 899.00, 700.00, 80),
(9, 'Erkek Tişört', 'Nike', 'CLOTH-M-002', 299.00, 200.00, 120),
(10, 'Kadın Elbise', 'Mango', 'CLOTH-W-001', 1299.00, 1000.00, 60),
(10, 'Kadın Bluz', 'Zara', 'CLOTH-W-002', 599.00, 450.00, 90);

-- Kitap ürünleri
INSERT INTO products (category_id, product_name, brand, sku, unit_price, cost_price, stock_quantity) VALUES
(13, 'Sapiens', 'Can Yayınları', 'BOOK-001', 129.00, 90.00, 200),
(13, '1984', 'İletişim', 'BOOK-002', 89.00, 60.00, 150),
(14, 'Designing Data-Intensive Applications', 'O''Reilly', 'BOOK-TECH-001', 450.00, 350.00, 50),
(14, 'Clean Code', 'Pearson', 'BOOK-TECH-002', 380.00, 290.00, 60);

-- Spor ürünleri
INSERT INTO products (category_id, product_name, brand, sku, unit_price, cost_price, stock_quantity) VALUES
(15, 'Yoga Matı', 'Adidas', 'SPORT-001', 599.00, 450.00, 120),
(15, 'Dumbbell Set 20kg', 'Nike', 'SPORT-002', 1299.00, 1000.00, 40),
(15, 'Koşu Bandı', 'Reebok', 'SPORT-003', 8999.00, 7500.00, 15);

-- ============================================
-- 5. ORDERS (100 Sipariş - Son 3 ay)
-- ============================================

-- Ocak 2025 siparişleri
INSERT INTO orders (customer_id, order_number, order_date, shipping_address_id, billing_address_id, payment_method_id, payment_status, order_status, shipping_cost, tax_amount) VALUES
(3, 'ORD-2025-0001', '2025-01-05 10:30:00', 4, 4, 1, 'Paid', 'Delivered', 29.99, 0),
(1, 'ORD-2025-0002', '2025-01-06 14:20:00', 1, 1, 1, 'Paid', 'Delivered', 29.99, 0),
(8, 'ORD-2025-0003', '2025-01-07 09:15:00', 9, 9, 2, 'Paid', 'Delivered', 29.99, 0),
(2, 'ORD-2025-0004', '2025-01-08 16:45:00', 3, 3, 1, 'Paid', 'Delivered', 29.99, 0),
(6, 'ORD-2025-0005', '2025-01-10 11:00:00', 7, 7, 3, 'Paid', 'Delivered', 0, 0), -- Cash
(4, 'ORD-2025-0006', '2025-01-12 13:30:00', 5, 5, 1, 'Paid', 'Delivered', 29.99, 0),
(9, 'ORD-2025-0007', '2025-01-15 10:15:00', 10, 10, 1, 'Paid', 'Delivered', 29.99, 0),
(5, 'ORD-2025-0008', '2025-01-18 15:00:00', 6, 6, 2, 'Paid', 'Delivered', 29.99, 0),
(1, 'ORD-2025-0009', '2025-01-20 09:45:00', 1, 1, 1, 'Paid', 'Delivered', 29.99, 0),
(7, 'ORD-2025-0010', '2025-01-22 12:20:00', 8, 8, 1, 'Paid', 'Delivered', 29.99, 0);

-- Şubat 2025 siparişleri
INSERT INTO orders (customer_id, order_number, order_date, shipping_address_id, billing_address_id, payment_method_id, payment_status, order_status, shipping_cost, tax_amount) VALUES
(10, 'ORD-2025-0011', '2025-02-01 10:30:00', 11, 11, 1, 'Paid', 'Delivered', 29.99, 0),
(3, 'ORD-2025-0012', '2025-02-03 14:20:00', 4, 4, 1, 'Paid', 'Delivered', 29.99, 0),
(2, 'ORD-2025-0013', '2025-02-05 09:15:00', 3, 3, 2, 'Paid', 'Delivered', 29.99, 0),
(6, 'ORD-2025-0014', '2025-02-07 16:45:00', 7, 7, 1, 'Paid', 'Delivered', 29.99, 0),
(8, 'ORD-2025-0015', '2025-02-10 11:00:00', 9, 9, 1, 'Paid', 'Delivered', 29.99, 0),
(4, 'ORD-2025-0016', '2025-02-12 13:30:00', 5, 5, 3, 'Paid', 'Delivered', 0, 0),
(1, 'ORD-2025-0017', '2025-02-14 10:15:00', 1, 1, 1, 'Paid', 'Delivered', 29.99, 0),
(9, 'ORD-2025-0018', '2025-02-16 15:00:00', 10, 10, 2, 'Paid', 'Delivered', 29.99, 0),
(5, 'ORD-2025-0019', '2025-02-18 09:45:00', 6, 6, 1, 'Paid', 'Delivered', 29.99, 0),
(7, 'ORD-2025-0020', '2025-02-20 12:20:00', 8, 8, 1, 'Paid', 'Delivered', 29.99, 0);

-- Mart 2025 siparişleri (bazıları henüz teslim edilmedi)
INSERT INTO orders (customer_id, order_number, order_date, shipping_address_id, billing_address_id, payment_method_id, payment_status, order_status, shipping_cost, tax_amount) VALUES
(3, 'ORD-2025-0021', '2025-03-01 10:30:00', 4, 4, 1, 'Paid', 'Delivered', 29.99, 0),
(8, 'ORD-2025-0022', '2025-03-03 14:20:00', 9, 9, 1, 'Paid', 'Delivered', 29.99, 0),
(1, 'ORD-2025-0023', '2025-03-05 09:15:00', 1, 1, 2, 'Paid', 'Shipped', 29.99, 0),
(6, 'ORD-2025-0024', '2025-03-07 16:45:00', 7, 7, 1, 'Paid', 'Shipped', 29.99, 0),
(2, 'ORD-2025-0025', '2025-03-10 11:00:00', 3, 3, 1, 'Paid', 'Processing', 29.99, 0),
(4, 'ORD-2025-0026', '2025-03-12 13:30:00', 5, 5, 3, 'Paid', 'Processing', 0, 0),
(9, 'ORD-2025-0027', '2025-03-15 10:15:00', 10, 10, 1, 'Paid', 'Pending', 29.99, 0),
(5, 'ORD-2025-0028', '2025-03-18 15:00:00', 6, 6, 2, 'Pending', 'Pending', 29.99, 0),
(7, 'ORD-2025-0029', '2025-03-20 09:45:00', 8, 8, 1, 'Pending', 'Pending', 29.99, 0),
(10, 'ORD-2025-0030', '2025-03-22 12:20:00', 11, 11, 1, 'Pending', 'Pending', 29.99, 0);

-- ============================================
-- 6. ORDER_ITEMS (Sipariş Kalemleri)
-- ============================================

-- Sipariş 1 - VIP müşteri - Yüksek değerli
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(1, 1, 'MacBook Pro 16"', 89999.00, 1, 0),
(1, 11, 'Sony WH-1000XM5', 12999.00, 1, 5);

-- Sipariş 2 - Premium müşteri
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(2, 6, 'iPhone 15 Pro Max', 64999.00, 1, 0),
(2, 12, 'AirPods Pro 2', 9999.00, 1, 0);

-- Sipariş 3 - VIP müşteri - Çoklu ürün
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(3, 2, 'Dell XPS 15', 45999.00, 1, 5),
(3, 7, 'Samsung Galaxy S24 Ultra', 54999.00, 1, 0),
(3, 14, 'JBL Tune 720BT', 1999.00, 2, 10);

-- Sipariş 4 - Standart müşteri - Düşük değerli
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(4, 16, 'Erkek Tişört', 299.00, 3, 0),
(4, 19, 'Sapiens', 129.00, 2, 0);

-- Sipariş 5 - Nakit ödeme
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(5, 21, 'Designing Data-Intensive Applications', 450.00, 1, 0),
(5, 22, 'Clean Code', 380.00, 1, 0);

-- Sipariş 6
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(6, 8, 'Google Pixel 8 Pro', 42999.00, 1, 0);

-- Sipariş 7
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(7, 3, 'Lenovo ThinkPad X1', 35999.00, 1, 10);

-- Sipariş 8
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(8, 23, 'Yoga Matı', 599.00, 2, 15),
(8, 24, 'Dumbbell Set 20kg', 1299.00, 1, 0);

-- Sipariş 9 - Tekrar alım (müşteri 1)
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(9, 13, 'Bose QuietComfort Ultra', 14999.00, 1, 0);

-- Sipariş 10
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(10, 4, 'HP Pavilion', 18999.00, 1, 5);

-- Şubat siparişleri
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(11, 10, 'OnePlus 12', 32999.00, 1, 0),
(12, 5, 'Asus ROG Strix', 75999.00, 1, 0),
(13, 17, 'Kadın Elbise', 1299.00, 2, 0),
(14, 12, 'AirPods Pro 2', 9999.00, 2, 0),
(15, 25, 'Koşu Bandı', 8999.00, 1, 0);

INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(16, 20, '1984', 89.00, 5, 10),
(17, 6, 'iPhone 15 Pro Max', 64999.00, 1, 0),
(18, 18, 'Kadın Bluz', 599.00, 3, 0),
(19, 15, 'Erkek Kot Pantolon', 899.00, 2, 0),
(20, 11, 'Sony WH-1000XM5', 12999.00, 1, 5);

-- Mart siparişleri
INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(21, 1, 'MacBook Pro 16"', 89999.00, 1, 0),
(22, 7, 'Samsung Galaxy S24 Ultra', 54999.00, 1, 0),
(23, 2, 'Dell XPS 15', 45999.00, 1, 0),
(24, 3, 'Lenovo ThinkPad X1', 35999.00, 1, 0),
(25, 9, 'Xiaomi 14 Ultra', 38999.00, 1, 0);

INSERT INTO order_items (order_id, product_id, product_name, unit_price, quantity, discount_percent) VALUES
(26, 21, 'Designing Data-Intensive Applications', 450.00, 3, 0),
(27, 14, 'JBL Tune 720BT', 1999.00, 2, 0),
(28, 12, 'AirPods Pro 2', 9999.00, 1, 0),
(29, 23, 'Yoga Matı', 599.00, 1, 0),
(30, 19, 'Sapiens', 129.00, 1, 0);

-- ============================================
-- Sipariş durumlarını güncelle (delivery tarihlerini ekle)
-- ============================================

UPDATE orders SET
    shipping_date = order_date + INTERVAL '1 day',
    delivery_date = order_date + INTERVAL '3 days',
    tracking_number = 'TRK-' || order_number
WHERE order_status = 'Delivered';

UPDATE orders SET
    shipping_date = order_date + INTERVAL '1 day',
    tracking_number = 'TRK-' || order_number
WHERE order_status = 'Shipped';

UPDATE orders SET
    payment_date = order_date + INTERVAL '1 hour'
WHERE payment_status = 'Paid';

-- ============================================
-- İstatistikler
-- ============================================

SELECT
    '================================' as separator;

SELECT 'OLTP Örnek Veriler Yüklendi!' as status;

SELECT
    '================================' as separator;

SELECT 'VERİ İSTATİSTİKLERİ' as title;

SELECT
    'Kategoriler' as tablo,
    COUNT(*) as kayit_sayisi
FROM categories
UNION ALL
SELECT 'Ürünler', COUNT(*) FROM products
UNION ALL
SELECT 'Müşteriler', COUNT(*) FROM customers
UNION ALL
SELECT 'Adresler', COUNT(*) FROM addresses
UNION ALL
SELECT 'Siparişler', COUNT(*) FROM orders
UNION ALL
SELECT 'Sipariş Kalemleri', COUNT(*) FROM order_items;

SELECT
    '================================' as separator;

-- Sipariş durumu özeti
SELECT
    order_status,
    COUNT(*) as siparis_sayisi,
    SUM(total_amount) as toplam_tutar
FROM orders
GROUP BY order_status
ORDER BY siparis_sayisi DESC;

SELECT
    '================================' as separator;

-- Müşteri segment özeti
SELECT
    customer_segment,
    COUNT(*) as musteri_sayisi
FROM customers
GROUP BY customer_segment
ORDER BY musteri_sayisi DESC;

SELECT
    '================================' as separator;

-- En çok satan ürünler
SELECT
    p.product_name,
    SUM(oi.quantity) as toplam_satis,
    SUM(oi.line_total) as toplam_gelir
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY toplam_satis DESC
LIMIT 10;

SELECT
    '================================' as separator;

-- Aylık satış özeti
SELECT
    TO_CHAR(order_date, 'YYYY-MM') as ay,
    COUNT(*) as siparis_sayisi,
    SUM(total_amount) as toplam_ciro,
    AVG(total_amount) as ortalama_sepet
FROM orders
WHERE order_status != 'Cancelled'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY ay;

SELECT
    '================================' as separator;

SELECT 'Veri yükleme tamamlandı! OLTP hazır.' as mesaj;