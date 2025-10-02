-- ============================================
-- OLTP Database Schema
-- E-Ticaret İşlemsel Veritabanı
-- ============================================

-- Mevcut tabloları temizle (geliştirme için)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS addresses CASCADE;
DROP TABLE IF EXISTS payment_methods CASCADE;

-- ============================================
-- 1. CUSTOMERS (Müşteriler)
-- ============================================
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    customer_segment VARCHAR(20) DEFAULT 'Standard', -- Standard, Premium, VIP
    total_orders INTEGER DEFAULT 0,
    total_spent DECIMAL(12,2) DEFAULT 0,

    -- Indexes
    CONSTRAINT chk_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Index'ler
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_segment ON customers(customer_segment);
CREATE INDEX idx_customers_registration ON customers(registration_date);

-- ============================================
-- 2. ADDRESSES (Adresler)
-- ============================================
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    address_type VARCHAR(20) NOT NULL, -- Home, Work, Billing, Shipping
    address_line1 VARCHAR(200) NOT NULL,
    address_line2 VARCHAR(200),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) DEFAULT 'Turkey',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_addresses_customer ON addresses(customer_id);
CREATE INDEX idx_addresses_city ON addresses(city);

-- ============================================
-- 3. CATEGORIES (Kategoriler)
-- ============================================
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    parent_category_id INTEGER REFERENCES categories(category_id),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_categories_parent ON categories(parent_category_id);

-- ============================================
-- 4. PRODUCTS (Ürünler)
-- ============================================
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE SET NULL,
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    brand VARCHAR(100),
    sku VARCHAR(50) UNIQUE NOT NULL, -- Stock Keeping Unit
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    cost_price DECIMAL(10,2) CHECK (cost_price >= 0),
    stock_quantity INTEGER DEFAULT 0 CHECK (stock_quantity >= 0),
    reorder_level INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT TRUE,
    weight_kg DECIMAL(8,2),
    dimensions VARCHAR(50), -- "30x20x10 cm"
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index'ler
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_name ON products(product_name);
CREATE INDEX idx_products_brand ON products(brand);

-- Full-text search için
CREATE INDEX idx_products_search ON products USING GIN(to_tsvector('turkish', product_name || ' ' || COALESCE(description, '')));

-- ============================================
-- 5. PAYMENT_METHODS (Ödeme Yöntemleri)
-- ============================================
CREATE TABLE payment_methods (
    payment_method_id SERIAL PRIMARY KEY,
    method_name VARCHAR(50) NOT NULL UNIQUE, -- Credit Card, Debit Card, Cash, Bank Transfer
    is_active BOOLEAN DEFAULT TRUE
);

-- Varsayılan ödeme yöntemleri
INSERT INTO payment_methods (method_name) VALUES
    ('Credit Card'),
    ('Debit Card'),
    ('Cash'),
    ('Bank Transfer'),
    ('Digital Wallet');

-- ============================================
-- 6. ORDERS (Siparişler)
-- ============================================
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    order_number VARCHAR(50) UNIQUE NOT NULL, -- ORD-2025-0001
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Adres bilgileri (snapshot - müşteri adresi değişebilir)
    shipping_address_id INTEGER REFERENCES addresses(address_id),
    billing_address_id INTEGER REFERENCES addresses(address_id),

    -- Tutarlar
    subtotal DECIMAL(12,2) DEFAULT 0, -- Ara toplam
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    shipping_cost DECIMAL(8,2) DEFAULT 0,
    total_amount DECIMAL(12,2) DEFAULT 0, -- Grand total

    -- Ödeme
    payment_method_id INTEGER REFERENCES payment_methods(payment_method_id),
    payment_status VARCHAR(20) DEFAULT 'Pending', -- Pending, Paid, Failed, Refunded
    payment_date TIMESTAMP,

    -- Sipariş durumu
    order_status VARCHAR(20) DEFAULT 'Pending', -- Pending, Processing, Shipped, Delivered, Cancelled

    -- Kargo
    shipping_date TIMESTAMP,
    delivery_date TIMESTAMP,
    tracking_number VARCHAR(100),

    -- Notlar
    customer_notes TEXT,
    internal_notes TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index'ler
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_number ON orders(order_number);

-- ============================================
-- 7. ORDER_ITEMS (Sipariş Kalemleri)
-- ============================================
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id),

    -- Ürün bilgileri (snapshot - ürün fiyatı değişebilir)
    product_name VARCHAR(200) NOT NULL, -- Sipariş anındaki isim
    unit_price DECIMAL(10,2) NOT NULL, -- Sipariş anındaki fiyat
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    discount_percent DECIMAL(5,2) DEFAULT 0,
    line_total DECIMAL(12,2) GENERATED ALWAYS AS (
        unit_price * quantity * (1 - discount_percent / 100)
    ) STORED,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index'ler
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger 1: Ürün güncellendiğinde updated_at'i güncelle
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_products_updated
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trigger_orders_updated
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Trigger 2: Sipariş verildiğinde stok düş
CREATE OR REPLACE FUNCTION decrease_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;

    -- Stok kontrolü
    IF (SELECT stock_quantity FROM products WHERE product_id = NEW.product_id) < 0 THEN
        RAISE EXCEPTION 'Yetersiz stok! Ürün ID: %', NEW.product_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_decrease_stock
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION decrease_stock();

-- Trigger 3: Sipariş iptal edilirse stok geri yükle
CREATE OR REPLACE FUNCTION restore_stock()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_status = 'Cancelled' AND OLD.order_status != 'Cancelled' THEN
        UPDATE products p
        SET stock_quantity = stock_quantity + oi.quantity
        FROM order_items oi
        WHERE oi.order_id = NEW.order_id
          AND oi.product_id = p.product_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_restore_stock
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION restore_stock();

-- Trigger 4: Sipariş toplamını otomatik hesapla
CREATE OR REPLACE FUNCTION calculate_order_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE orders
    SET subtotal = (
        SELECT COALESCE(SUM(line_total), 0)
        FROM order_items
        WHERE order_id = NEW.order_id
    ),
    total_amount = (
        SELECT COALESCE(SUM(line_total), 0)
        FROM order_items
        WHERE order_id = NEW.order_id
    ) + COALESCE(NEW.shipping_cost, 0) + COALESCE(NEW.tax_amount, 0) - COALESCE(NEW.discount_amount, 0)
    WHERE order_id = NEW.order_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calculate_total
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
EXECUTE FUNCTION calculate_order_total();

-- Trigger 5: Müşteri istatistiklerini güncelle
CREATE OR REPLACE FUNCTION update_customer_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_status = 'Delivered' THEN
        UPDATE customers
        SET total_orders = total_orders + 1,
            total_spent = total_spent + NEW.total_amount
        WHERE customer_id = NEW.customer_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_customer_stats
AFTER UPDATE ON orders
FOR EACH ROW
WHEN (NEW.order_status = 'Delivered' AND OLD.order_status != 'Delivered')
EXECUTE FUNCTION update_customer_stats();

-- ============================================
-- VIEWS (İstatistikler için)
-- ============================================

-- View 1: Müşteri özeti
CREATE VIEW v_customer_summary AS
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name as full_name,
    c.email,
    c.customer_segment,
    c.total_orders,
    c.total_spent,
    CASE
        WHEN c.total_spent >= 10000 THEN 'VIP'
        WHEN c.total_spent >= 5000 THEN 'Premium'
        ELSE 'Standard'
    END as suggested_segment,
    COUNT(DISTINCT o.order_id) as order_count,
    MAX(o.order_date) as last_order_date,
    AVG(o.total_amount) as avg_order_value
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- View 2: Ürün stok durumu
CREATE VIEW v_product_stock_status AS
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    c.category_name,
    p.stock_quantity,
    p.reorder_level,
    CASE
        WHEN p.stock_quantity = 0 THEN 'Out of Stock'
        WHEN p.stock_quantity <= p.reorder_level THEN 'Low Stock'
        ELSE 'In Stock'
    END as stock_status,
    p.unit_price * p.stock_quantity as stock_value
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
WHERE p.is_active = true;

-- View 3: Günlük satış özeti
CREATE VIEW v_daily_sales AS
SELECT
    DATE(order_date) as sale_date,
    COUNT(DISTINCT order_id) as order_count,
    COUNT(DISTINCT customer_id) as unique_customers,
    SUM(total_amount) as daily_revenue,
    AVG(total_amount) as avg_order_value,
    SUM(subtotal) as subtotal,
    SUM(discount_amount) as total_discounts,
    SUM(shipping_cost) as total_shipping
FROM orders
WHERE order_status != 'Cancelled'
GROUP BY DATE(order_date)
ORDER BY sale_date DESC;

-- ============================================
-- COMMENTS (Dokümantasyon)
-- ============================================

COMMENT ON TABLE customers IS 'Müşteri bilgileri - OLTP işlemsel tablo';
COMMENT ON TABLE orders IS 'Sipariş başlıkları - Transaction header';
COMMENT ON TABLE order_items IS 'Sipariş kalemleri - Transaction details';
COMMENT ON TABLE products IS 'Ürün kataloğu';
COMMENT ON COLUMN orders.order_number IS 'Unique sipariş numarası (ORD-2025-0001)';
COMMENT ON COLUMN order_items.line_total IS 'Otomatik hesaplanan satır toplamı';

-- ============================================
-- İstatistikler
-- ============================================

SELECT 'OLTP Schema başarıyla oluşturuldu!' as status;

SELECT
    'customers' as table_name,
    COUNT(*) as row_count
FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items;