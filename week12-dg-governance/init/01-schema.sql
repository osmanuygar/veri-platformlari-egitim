-- Hafta 12 — PII içeren kaynak şema (maskeleme ve KVKK alıştırmaları için)

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS marts;
SET search_path TO raw, public;

-- Gerçekçi bir banka/e-ticaret müşteri tablosu — özellikle
-- KVKK'da "özel nitelikli" SAYILMAYAN ama yine de kişisel veri olan
-- alanları (TCKN, telefon, e-posta, doğum tarihi) içerir.
CREATE TABLE customers (
    id           SERIAL PRIMARY KEY,
    full_name    VARCHAR(120)  NOT NULL,
    tckn         VARCHAR(11)   NOT NULL,   -- T.C. Kimlik No — kişisel veri
    email        VARCHAR(160),   -- NOT NULL kasıtlı olarak koyulmadı: Alıştırma 1'de
                                  -- Great Expectations'ın eksik e-postayı YAKALAMASI bekleniyor.
                                  -- Veritabanı kısıtı burada olsaydı, veri hiç yazılamaz ve
                                  -- "kalite kontrolü" alıştırmasının konusu ortadan kalkardı.
    phone        VARCHAR(20),
    birth_date   DATE,
    city         VARCHAR(60),
    income_band  VARCHAR(20),               -- 'low','medium','high' — hassas olabilir
    consent_marketing BOOLEAN DEFAULT false, -- açık rıza kaydı
    consent_date TIMESTAMPTZ,
    created_at   TIMESTAMPTZ DEFAULT now(),
    updated_at   TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE orders (
    id           SERIAL PRIMARY KEY,
    customer_id  INTEGER REFERENCES customers(id),
    order_date   DATE NOT NULL,
    amount       NUMERIC(10,2) NOT NULL,
    status       VARCHAR(20)
);

-- Rol bazlı erişim alıştırması için roller
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'analyst_role') THEN
        CREATE ROLE analyst_role NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'support_role') THEN
        CREATE ROLE support_role NOLOGIN;
    END IF;
END
$$;

-- marts.customers_masked: analist rolünün göreceği maskelenmiş görünüm
-- (Alıştırma 3'te öğrenciler benzerini kendileri kuracak; bu bir örnek şablon)
CREATE OR REPLACE VIEW marts.customers_masked AS
SELECT
    id,
    full_name,
    left(tckn, 3) || repeat('*', 6) || right(tckn, 2)         AS tckn_masked,
    regexp_replace(email, '(^.).*(@.*$)', '\1***\2')          AS email_masked,
    'XXX-XXX-' || right(phone, 4)                              AS phone_masked,
    date_trunc('year', birth_date)::date                       AS birth_year_only,
    city,
    income_band,
    consent_marketing
FROM raw.customers;

GRANT USAGE ON SCHEMA marts TO analyst_role;
GRANT SELECT ON marts.customers_masked TO analyst_role;
