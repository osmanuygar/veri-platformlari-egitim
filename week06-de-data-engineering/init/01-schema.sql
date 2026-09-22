-- Hafta 6 — kaynak (raw) şema
-- dbt'nin kendi eğitim materyaliyle (jaffle_shop) aynı desen:
-- customers, orders, payments. dbt Öğren dokümantasyonuna geçiş kolay olsun diye.

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS analytics;   -- dbt modelleri buraya yazacak

SET search_path TO raw, public;

CREATE TABLE raw_customers (
    id         INTEGER PRIMARY KEY,
    first_name VARCHAR(50),
    last_name  VARCHAR(50),
    email      VARCHAR(120),
    city       VARCHAR(60),
    created_at TIMESTAMP
);

CREATE TABLE raw_orders (
    id          INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES raw_customers(id),
    order_date  DATE,
    status      VARCHAR(20)   -- placed, shipped, completed, returned, cancelled
);

CREATE TABLE raw_payments (
    id             INTEGER PRIMARY KEY,
    order_id       INTEGER REFERENCES raw_orders(id),
    payment_method VARCHAR(20),   -- credit_card, coupon, bank_transfer, gift_card
    amount         INTEGER        -- kuruş cinsinden (dbt tutorial ile aynı desen)
);

-- Airflow'un kendi metadata veritabanı (docker-compose.yml'de bağlantı ayarı var)
CREATE DATABASE airflow_meta;
