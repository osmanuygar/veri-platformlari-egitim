# Week-NoSQL with Trino Federated Query Engine

Modern NoSQL veritabanlarını (MongoDB, Cassandra, Redis, Neo4j) Trino federated query engine ile birleştiren kapsamlı bir proje.

## 🎯 Özellikler

- **MongoDB**: Doküman tabanlı veritabanı
- **Cassandra**: Dağıtık sütun tabanlı veritabanı
- **Redis**: In-memory key-value store
- **Neo4j**: Graf veritabanı
- **Trino**: Federated SQL query engine - Tüm veritabanlarını SQL ile sorgulama

## 🚀 Hızlı Başlangıç

### Gereksinimler

- Docker
- Docker Compose
- 8GB+ RAM önerilir

### Kurulum

```bash
# Projeyi klonlayın
git clone <repository-url>
cd week-nosql

# Trino yapılandırma dizinlerini oluşturun
mkdir -p trino/catalog trino/config

# Docker container'ları başlatın
docker-compose up -d

# Servislerin durumunu kontrol edin
docker-compose ps
```

## 📊 Servis Portları

| Servis | Port | Erişim URL |
|--------|------|------------|
| MongoDB | 27017 | mongodb://localhost:27017 |
| Cassandra | 9042 | localhost:9042 |
| Redis | 6379 | localhost:6379 |
| Neo4j | 7474, 7687 | http://localhost:7474 |
| Trino | 8080 | http://localhost:8080 |

## 🔍 Trino Kullanımı

### Trino CLI'ye Bağlanma

```bash
docker exec -it week-trino trino
```

### Örnek Sorgular

#### MongoDB Verilerini Sorgulama
```sql
SHOW SCHEMAS FROM mongodb;
USE mongodb.testdb;
SHOW TABLES;
SELECT * FROM users LIMIT 10;
```

#### Cassandra Verilerini Sorgulama
```sql
SHOW SCHEMAS FROM cassandra;
USE cassandra.test_keyspace;
SELECT * FROM users;
```

#### Redis Verilerini Sorgulama
```sql
SHOW SCHEMAS FROM redis;
USE redis.default;
SELECT * FROM users;
```

#### Cross-Database Join Örneği
```sql
-- MongoDB ve Cassandra verilerini birleştirme
SELECT 
    m.name as mongo_user,
    c.email as cassandra_email
FROM mongodb.testdb.users m
JOIN cassandra.test_keyspace.users c 
ON m.user_id = c.user_id;
```

## 🛠️ Yapılandırma

### Trino Catalog Yapılandırmaları

Catalog dosyaları `trino/catalog/` dizininde bulunur:

- `mongodb.properties`: MongoDB bağlantı ayarları
- `cassandra.properties`: Cassandra bağlantı ayarları
- `redis.properties`: Redis bağlantı ayarları

### Örnek Veri Yükleme

```bash
# MongoDB'ye örnek veri yükleme
docker exec -i week-mongodb mongosh testdb < scripts/mongodb-init.js

# Cassandra'ya örnek veri yükleme
docker exec -i week-cassandra cqlsh < scripts/cassandra-init.cql

# Redis'e örnek veri yükleme
docker exec -i week-redis redis-cli < scripts/redis-init.txt
```

## 📝 Trino Script Örnekleri

### Katalogları Listeleme
```bash
docker exec -it week-trino trino --execute "SHOW CATALOGS;"
```

### Tüm Veritabanlarından Veri Sayma
```bash
docker exec -it week-trino trino --file /scripts/count-all-data.sql
```

## 🐛 Sorun Giderme

### Trino'ya Bağlanamıyorum
```bash
# Trino loglarını kontrol edin
docker logs week-trino

# Trino'nun hazır olup olmadığını kontrol edin
curl http://localhost:8080/v1/info
```

### Catalog Hatası
```bash
# Catalog yapılandırmalarını kontrol edin
docker exec week-trino cat /etc/trino/catalog/mongodb.properties
```

### Container'lar Başlamıyor
```bash
# Tüm container'ları durdurun ve temizleyin
docker-compose down -v

# Yeniden başlatın
docker-compose up -d
```

## 📚 Kaynaklar

- [Trino Documentation](https://trino.io/docs/current/)
- [MongoDB Connector](https://trino.io/docs/current/connector/mongodb.html)
- [Cassandra Connector](https://trino.io/docs/current/connector/cassandra.html)
- [Redis Connector](https://trino.io/docs/current/connector/redis.html)

## 🤝 Katkıda Bulunma

Pull request'ler memnuniyetle karşılanır. Büyük değişiklikler için lütfen önce bir issue açın.

## 📄 Lisans

MIT

## 👨‍💻 Geliştirici Notları

### Performans İpuçları
- Trino sorguları için worker node sayısını artırabilirsiniz
- Memory ayarlarını `config.properties` dosyasından optimize edebilirsiniz
- Büyük veri setleri için partition kullanımı önerilir

### Güvenlik
- Production ortamında mutlaka authentication ekleyin
- Network izolasyonu için overlay network kullanın
- Sensitive bilgiler için environment variables kullanın