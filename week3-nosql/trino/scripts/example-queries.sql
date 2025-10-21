-- Cassandra keyspace'lerini göster
SHOW SCHEMAS FROM cassandra;

-- Cassandra tabloları göster
SHOW TABLES FROM cassandra.ecommerce;

-- Cassandra'dan veri çek
SELECT * FROM cassandra.ecommerce.users LIMIT 10;

-- Cassandra'da filtreleme
SELECT user_id, email, created_at
FROM cassandra.ecommerce.users
WHERE user_id = '123e4567-e89b-12d3-- =================================================
-- Trino Federated Query Examples for Week-NoSQL
-- =================================================

-- 1. KATALOGLARI GÖSTER
-- Tüm mevcut katalogları listele
SHOW CATALOGS;

-- =================================================
-- MONGODB SORULARI
-- =================================================

-- MongoDB şemalarını göster
SHOW SCHEMAS FROM mongodb;

-- MongoDB veritabanı seç ve tabloları göster
USE mongodb.ecommerce;
SHOW TABLES;

-- MongoDB'den veri çek
SELECT * FROM mongodb.ecommerce.users LIMIT 10;

-- MongoDB'de filtreleme
SELECT name, email, age
FROM mongodb.ecommerce.users
WHERE age > 25
ORDER BY age DESC;

-- MongoDB'de agregasyon
SELECT
    COUNT(*) as total_users,
    AVG(age) as average_age,
    MIN(age) as min_age,
    MAX(age) as max_age
FROM mongodb.ecommerce.users;

-- =================================================
-- CASSANDRA SORULARI
-- =================================================

-- Cassandra keyspace'lerini göster
SHOW SCHEMAS FROM cassandra;

-- Cassandra tabloları göster
SHOW TABLES FROM cassandra.test_keyspace;

-- Cassandra'dan veri çek
SELECT * FROM cassandra.test_keyspace.users LIMIT 10;

-- Cassandra'da filtreleme
SELECT user_id, email, created_at
FROM cassandra.test_keyspace.users
WHERE user_id = '123e4567-e89b-12d3-a456-426614174000';

-- =================================================
-- REDIS SORULARI
-- =================================================

-- Redis şemalarını göster
SHOW SCHEMAS FROM redis;

-- Redis tablolarını göster
SHOW TABLES FROM redis.default;

-- Redis'ten veri çek
SELECT * FROM redis.default.users LIMIT 10;

-- =================================================
-- CROSS-DATABASE FEDERATED SORULARI
-- =================================================

-- MongoDB ve Cassandra JOIN
-- MongoDB'deki kullanıcıları Cassandra'daki kullanıcılarla birleştir
SELECT
    m._id as mongo_id,
    m.name as mongo_name,
    c.email as cassandra_email,
    c.created_at
FROM mongodb.testdb.users m
INNER JOIN cassandra.test_keyspace.users c
    ON CAST(m.user_id AS VARCHAR) = CAST(c.user_id AS VARCHAR)
LIMIT 10;

-- Tüm veritabanlarından veri sayıları
SELECT 'MongoDB' as source, COUNT(*) as record_count
FROM mongodb.testdb.users
UNION ALL
SELECT 'Cassandra' as source, COUNT(*) as record_count
FROM cassandra.test_keyspace.users
UNION ALL
SELECT 'Redis' as source, COUNT(*) as record_count
FROM redis.default.users;

-- MongoDB ve Redis'ten veri karşılaştırma
SELECT
    m.name as mongo_user,
    r.value as redis_value
FROM mongodb.testdb.users m
LEFT JOIN redis.default.users r
    ON m.user_id = r.key;

-- =================================================
-- KOMPLEKS ANALİTİK SORULARI
-- =================================================

-- Yaş gruplarına göre kullanıcı dağılımı (MongoDB)
SELECT
    CASE
        WHEN age < 20 THEN '0-19'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END as age_group,
    COUNT(*) as user_count
FROM mongodb.testdb.users
GROUP BY
    CASE
        WHEN age < 20 THEN '0-19'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50+'
    END
ORDER BY age_group;

-- Her veritabanından en aktif kullanıcılar
WITH mongo_users AS (
    SELECT name, email, 'MongoDB' as source
    FROM mongodb.testdb.users
    LIMIT 5
),
cassandra_users AS (
    SELECT CAST(user_id AS VARCHAR) as name, email, 'Cassandra' as source
    FROM cassandra.test_keyspace.users
    LIMIT 5
)
SELECT * FROM mongo_users
UNION ALL
SELECT * FROM cassandra_users;

-- =================================================
-- VERİTABANI İSTATİSTİKLERİ
-- =================================================

-- MongoDB koleksiyon istatistikleri
SELECT
    'testdb' as database_name,
    'users' as collection_name,
    COUNT(*) as total_documents
FROM mongodb.testdb.users;

-- Cassandra tablo istatistikleri
SELECT
    'test_keyspace' as keyspace_name,
    'users' as table_name,
    COUNT(*) as total_rows
FROM cassandra.test_keyspace.users;

-- =================================================
-- PERFORMANS SORULARI
-- =================================================

-- EXPLAIN ile sorgu planını göster
EXPLAIN
SELECT m.name, c.email
FROM mongodb.testdb.users m
JOIN cassandra.test_keyspace.users c
    ON CAST(m.user_id AS VARCHAR) = CAST(c.user_id AS VARCHAR);

-- EXPLAIN ANALYZE ile sorgu performansını analiz et
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM mongodb.testdb.users
WHERE age > 30;