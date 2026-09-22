-- Hafta 13 — pgvector şeması
-- "Postgres'i vektör veritabanına çevirmek" — tek bir CREATE EXTENSION ile.

CREATE EXTENSION IF NOT EXISTS vector;

CREATE SCHEMA IF NOT EXISTS ai;
SET search_path TO ai, public;

-- Ders notu parçaları (chunk'lar) — RAG'ın "bilgi tabanı"
-- embedding boyutu 768 = nomic-embed-text modelinin çıktı boyutu
CREATE TABLE course_chunks (
    id          SERIAL PRIMARY KEY,
    week_no     INTEGER NOT NULL,
    week_title  VARCHAR(200) NOT NULL,
    section     VARCHAR(200),
    chunk_text  TEXT NOT NULL,
    embedding   VECTOR(768),
    created_at  TIMESTAMPTZ DEFAULT now()
);

-- HNSW indeksi: yaklaşık en yakın komşu (ANN) araması için.
-- Küçük veri setinde (birkaç yüz satır) indekssiz de hızlıdır, ama
-- gerçek boyutta (milyonlarca satır) bu indeks olmadan arama saniyeler sürer.
-- Not: cosine mesafesi kullanıyoruz (metin embedding'lerinde standart tercih).
CREATE INDEX ON course_chunks USING hnsw (embedding vector_cosine_ops);

-- Text-to-SQL alıştırması için: hafta 2'nin basitleştirilmiş bir kopyası
-- (bağımsız çalışsın diye kendi şemasında)
CREATE SCHEMA IF NOT EXISTS shop;

CREATE TABLE shop.customers (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(120),
    city VARCHAR(60),
    segment VARCHAR(20)
);

CREATE TABLE shop.products (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(40),
    name VARCHAR(160),
    category VARCHAR(60),
    price NUMERIC(10,2)
);

CREATE TABLE shop.orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES shop.customers(id),
    order_date DATE,
    status VARCHAR(20)
);

CREATE TABLE shop.order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES shop.orders(id),
    product_id INTEGER REFERENCES shop.products(id),
    quantity INTEGER,
    unit_price NUMERIC(10,2)
);
