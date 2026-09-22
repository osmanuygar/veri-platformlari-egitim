-- Hafta 7 — CDC kaynak şeması
-- Debezium bu tabloları PostgreSQL WAL'ından okuyup Kafka'ya akıtacak.

CREATE SCHEMA IF NOT EXISTS shop;
SET search_path TO shop, public;

CREATE TABLE customers (
    id          SERIAL PRIMARY KEY,
    full_name   VARCHAR(120)  NOT NULL,
    email       VARCHAR(160)  NOT NULL UNIQUE,
    city        VARCHAR(60),
    segment     VARCHAR(20)   DEFAULT 'standard',
    created_at  TIMESTAMPTZ   DEFAULT now(),
    updated_at  TIMESTAMPTZ   DEFAULT now()
);

CREATE TABLE products (
    id          SERIAL PRIMARY KEY,
    sku         VARCHAR(40)   NOT NULL UNIQUE,
    name        VARCHAR(160)  NOT NULL,
    category    VARCHAR(60),
    price       NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    stock       INTEGER       NOT NULL DEFAULT 0 CHECK (stock >= 0),
    updated_at  TIMESTAMPTZ   DEFAULT now()
);

CREATE TABLE orders (
    id           SERIAL PRIMARY KEY,
    customer_id  INTEGER      NOT NULL REFERENCES customers(id),
    status       VARCHAR(20)  NOT NULL DEFAULT 'created',
    total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ  DEFAULT now(),
    updated_at   TIMESTAMPTZ  DEFAULT now()
);

CREATE TABLE order_items (
    id          SERIAL PRIMARY KEY,
    order_id    INTEGER       NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id  INTEGER       NOT NULL REFERENCES products(id),
    quantity    INTEGER       NOT NULL CHECK (quantity > 0),
    unit_price  NUMERIC(10,2) NOT NULL
);

-- ─────────────────────────────────────────────────────────────
-- CDC için kritik ayar: REPLICA IDENTITY FULL
--
-- Varsayılan (DEFAULT) ayarda Debezium bir UPDATE/DELETE olayında
-- "before" alanını sadece primary key ile doldurur. FULL dediğimizde
-- satırın ESKİ HALİNİN TAMAMI WAL'a yazılır; böylece
-- "fiyat 100'den 120'ye çıktı" gibi bir olayı olduğu gibi görebiliriz.
--
-- Maliyeti: WAL boyutu büyür. Production'da tablo tablo karar verilir.
-- ─────────────────────────────────────────────────────────────
ALTER TABLE customers   REPLICA IDENTITY FULL;
ALTER TABLE products    REPLICA IDENTITY FULL;
ALTER TABLE orders      REPLICA IDENTITY FULL;
ALTER TABLE order_items REPLICA IDENTITY FULL;

-- updated_at'i otomatik güncelle: CDC olaylarında değişim zamanı görünsün
CREATE OR REPLACE FUNCTION touch_updated_at() RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customers_touch BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER trg_products_touch  BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();
CREATE TRIGGER trg_orders_touch    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

-- Debezium'un yayın (publication) yapacağı tablolar
CREATE PUBLICATION dbz_publication FOR TABLE
    shop.customers, shop.products, shop.orders, shop.order_items;
