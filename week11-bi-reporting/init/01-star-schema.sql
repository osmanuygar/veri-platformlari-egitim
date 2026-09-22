-- Hafta 11 — kendi kendine yetebilen star şema (hafta 4'ün küçültülmüş, hazır hali)
-- Metabase ve Superset'in doğrudan üzerine dashboard kuracağı şema.

CREATE SCHEMA IF NOT EXISTS bi;
SET search_path TO bi, public;

CREATE TABLE dim_date (
    date_key    INTEGER PRIMARY KEY,      -- YYYYMMDD
    full_date   DATE NOT NULL,
    year        INTEGER,
    month       INTEGER,
    month_name  VARCHAR(20),
    quarter     INTEGER,
    day_of_week VARCHAR(10),
    is_weekend  BOOLEAN
);

CREATE TABLE dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id  INTEGER NOT NULL,
    full_name    VARCHAR(120),
    city         VARCHAR(60),
    region       VARCHAR(30),          -- satır düzeyi güvenlik alıştırması için
    segment      VARCHAR(20)
);

CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    sku         VARCHAR(40),
    product_name VARCHAR(160),
    category    VARCHAR(60)
);

CREATE TABLE fact_sales (
    sale_id      SERIAL PRIMARY KEY,
    date_key     INTEGER REFERENCES dim_date(date_key),
    customer_key INTEGER REFERENCES dim_customer(customer_key),
    product_key  INTEGER REFERENCES dim_product(product_key),
    quantity     INTEGER NOT NULL,
    unit_price   NUMERIC(10,2) NOT NULL,
    revenue      NUMERIC(12,2) NOT NULL,
    order_status VARCHAR(20)
);

CREATE INDEX idx_fact_sales_date ON fact_sales(date_key);
CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_key);
CREATE INDEX idx_fact_sales_product ON fact_sales(product_key);

-- Superset native filters / row-level security alıştırması için:
-- her "bölge müdürü" kullanıcısının SADECE kendi bölgesini görmesi istenebilir.
CREATE TABLE region_managers (
    username VARCHAR(60) PRIMARY KEY,
    region   VARCHAR(30) NOT NULL
);
