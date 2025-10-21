# 🚀 Quick Start Guide - Week-NoSQL with Trino

5 dakikada Trino federated query engine ile NoSQL veritabanlarınızı sorgulamaya başlayın!

## 📋 Önkoşullar

```bash
# Docker ve Docker Compose kurulu olmalı
docker --version
docker-compose --version
```

## ⚡ Hızlı Kurulum (3 Adım)

### Adım 1: Projeyi Hazırlayın

```bash
# Dizinleri oluşturun
make setup

# VEYA manuel olarak:
mkdir -p trino/catalog trino/config trino/scripts
```

### Adım 2: Servisleri Başlatın

```bash
# Tüm servisleri başlat
make up

# Servislerin hazır olmasını bekleyin (30-60 saniye)
make status
```

### Adım 3: Trino'yu Kurun ve Test Edin

```bash
# Trino'yu yapılandır
make trino-setup

# Test sorgularını çalıştır
make trino-test
```

## 🎯 İlk Sorgularınız

### Trino CLI'ye Bağlanın

```bash
make trino-cli

# VEYA
docker exec -it week-trino trino
```

### Katalogları Gösterin

```sql
SHOW CATALOGS;
```

**Beklenen çıktı:**
```
mongodb
cassandra
redis
system
```

### MongoDB'den Veri Çekin

```sql
-- Şemaları göster
SHOW SCHEMAS FROM mongodb;

-- Veritabanı seç
USE mongodb.testdb;

-- Tabloları göster
SHOW TABLES;

-- Veri çek
SELECT * FROM users LIMIT 5;
```

### Cassandra'dan Veri Çekin

```sql
-- Keyspace'leri göster
SHOW SCHEMAS FROM cassandra;

-- Keyspace seç
USE cassandra.test_keyspace;

-- Veri çek
SELECT * FROM users LIMIT 5;
```

### Cross-Database Sorgu

```sql
-- MongoDB ve Cassandra'yı birleştir
SELECT 
    m.name as mongo_user,
    c.email as cassandra_email
FROM mongodb.testdb.users m
JOIN cassandra.test_keyspace.users c 
    ON CAST(m.user_id AS VARCHAR) = CAST(c.user_id AS VARCHAR)
LIMIT 10;
```

## 🔍 Yararlı Komutlar

### Makefile Komutları

```bash
make help          # Tüm komutları göster
make up            # Servisleri başlat
make down          # Servisleri durdur
make status        # Durum kontrolü
make logs          # Tüm logları göster
make logs-trino    # Sadece Trino logları
make trino-cli     # Trino CLI'ye bağlan
make trino-web     # Trino Web UI'yi aç
make test          # Testleri çalıştır
make clean         # Tüm verileri temizle
```

### Manuel Docker Komutları

```bash
# Trino logları
docker logs -f week-trino

# MongoDB'ye bağlan
docker exec -it week-mongodb mongosh

# Cassandra'ya bağlan
docker exec -it week-cassandra cqlsh

# Redis'e bağlan
docker exec -it week-redis redis-cli

# Trino container'ına shell
docker exec -it week-trino /bin/bash
```

## 🌐 Web Arayüzleri

| Servis | URL | Kullanıcı | Şifre |
|--------|-----|-----------|-------|
| Trino UI | http://localhost:8080 | - | - |
| Neo4j Browser | http://localhost:7474 | neo4j | password |

## 📊 Örnek Senaryolar

### Senaryo 1: Veri Sayıları

```sql
-- Tüm veritabanlarındaki kayıt sayıları
SELECT 'MongoDB' as source, COUNT(*) as count FROM mongodb.testdb.users
UNION ALL
SELECT 'Cassandra' as source, COUNT(*) as count FROM cassandra.test_keyspace.users
UNION ALL
SELECT 'Redis' as source, COUNT(*) as count FROM redis.default.users;
```

### Senaryo 2: Yaş Analizi (MongoDB)

```sql
SELECT 
    CASE 
        WHEN age < 20 THEN '0-19'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age >= 40 THEN '40+'
    END as age_group,
    COUNT(*) as user_count,
    AVG(age) as avg_age
FROM mongodb.testdb.users
GROUP BY 
    CASE 
        WHEN age < 20 THEN '0-19'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age >= 40 THEN '40+'
    END
ORDER BY age_group;
```

### Senaryo 3: Performance Analysis

```sql
-- Sorgu planını göster
EXPLAIN 
SELECT m.name, c.email 
FROM mongodb.testdb.users m
JOIN cassandra.test_keyspace.users c 
    ON CAST(m.user_id AS VARCHAR) = CAST(c.user_id AS VARCHAR);
```

## 🐛 Sorun Giderme

### Problem: Trino başlamıyor

```bash
# Logları kontrol edin
make logs-trino

# Servisi yeniden başlatın
docker-compose restart trino

# Gerekirse yeniden build edin
make rebuild-trino
```

### Problem: Kataloglar görünmüyor

```bash
# Catalog dosyalarını kontrol edin
docker exec week-trino ls -la /etc/trino/catalog/

# Catalog içeriğini görüntüleyin
docker exec week-trino cat /etc/trino/catalog/mongodb.properties
```

### Problem: Veritabanına bağlanılamıyor

```bash
# Tüm servislerin durumunu kontrol edin
make status

# Ağ bağlantısını test edin
docker exec week-trino ping mongodb
docker exec week-trino ping cassandra
docker exec week-trino ping redis
```

### Problem: Memory hatası

```bash
# JVM ayarlarını düzenleyin
nano trino/config/jvm.config

# Heap size'ı artırın
-Xmx4G  # 2G yerine 4G

# Container'ı yeniden başlatın
docker-compose restart trino
```

## 📚 İleri Seviye

### Custom Catalog Ekleme

1. Yeni catalog dosyası oluşturun:
```bash
nano trino/catalog/mydb.properties
```

2. Connector yapılandırmasını ekleyin:
```properties
connector.name=mongodb
mongodb.connection-url=mongodb://myhost:27017
```

3. Trino'yu yeniden başlatın:
```bash
docker-compose restart trino
```

### Query Optimization

```sql
-- İstatistikleri analiz edin
SHOW STATS FOR mongodb.testdb.users;

-- Sorgu performansını ölçün
EXPLAIN ANALYZE
SELECT COUNT(*) FROM mongodb.testdb.users WHERE age > 30;
```

### Batch Queries

```bash
# SQL dosyasını çalıştır
docker exec -i week-trino trino < trino/scripts/example-queries.sql
```

## 🎓 Öğrenme Kaynakları

- **Trino Docs**: https://trino.io/docs/current/
- **SQL Örnekleri**: `trino/scripts/example-queries.sql`
- **Test Script**: `trino/scripts/test-queries.sh`

## 💡 İpuçları

1. **CLI'de otomatik tamamlama**: Tab tuşunu kullanın
2. **Query geçmişi**: Yukarı/aşağı ok tuşları
3. **Sonuçları CSV'ye**: `--output-format CSV > results.csv`
4. **Web UI kullanın**: Query planları ve performans için
5. **EXPLAIN kullanın**: Sorgu optimizasyonu için

## 🚦 Hızlı Komut Referansı

```bash
# Başlangıç
make up && make trino-setup

# Sorgulama
make trino-cli

# Monitoring
make status && make logs-trino

# Test
make trino-test

# Temizlik
make down

# Tam reset
make clean && make up
```

## 🎉 Başarılı!

Artık Trino ile federated query çalıştırmaya hazırsınız! 

İlk sorgunuzu çalıştırın:
```bash
make trino-cli
```

Sonra:
```sql
SHOW CATALOGS;
```

Mutlu sorgular! 🚀