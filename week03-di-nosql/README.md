# Hafta 3: NoSQL ve NewSQL Yaklaşımı

## 📚 İçindekiler

1. [CAP Teoremi](#1-cap-teoremi)
2. [NoSQL Kavramı ve BASE](#2-nosql-kavramı-ve-base)
3. [NoSQL Veritabanı Türleri](#3-nosql-veritabanı-türleri)
4. [Dağıtık Sistemler ve Ölçeklenebilirlik](#4-dağıtık-sistemler-ve-ölçeklenebilirlik)
5. [NewSQL Sistemler](#5-newsql-sistemler)
6. [Bulut Tabanlı Veri Platformları (DBaaS)](#6-bulut-tabanlı-veri-platformları-dbaas)
7. [Alternatifler ve Ekosistem](#-alternatifler-ve-ekosistem)
8. [Pratik Uygulamalar](#7-pratik-uygulamalar)
9. [Alıştırmalar](#8-alıştırmalar)
10. [Kaynaklar](#9-kaynaklar)

---

## 1. CAP Teoremi

### 1.1 Tanım

**CAP Teoremi (Brewer's Theorem):** Eric Brewer tarafından 2000 yılında öne sürülmüş, dağıtık sistemlerde aynı anda sadece iki özelliğin garanti edilebileceğini söyleyen teorem.

```
C + A + P → Sadece 2 Tanesini Seçebilirsin!
```

### 1.2 CAP Trade-offs
```
       C (Consistency)
            /\
           /  \
          /    \
         /  CA  \
        /________\
       /\        /\
      /  \  CP  /  \
     / AP \    / PA \
    /______\  /______\
   A                  P
```

### 1.3 Üç Özellik

#### C - Consistency (Tutarlılık)
**Tanım:** Tüm node'lar aynı anda aynı veriyi görür. Her okuma en son yazılan veriyi döner.

```
Node 1: x = 10
Node 2: x = 10  ✅ Consistent
Node 3: x = 10

Node 1: x = 20
Node 2: x = 10  ❌ Inconsistent!
```

#### A - Availability (Erişilebilirlik)
**Tanım:** Her istek bir yanıt alır (başarılı veya hata). Sistem her zaman çalışır durumda.

#### P - Partition Tolerance (Bölüm Toleransı)
**Tanım:** Ağ bölünmeleri olsa bile sistem çalışmaya devam eder.

### 1.3 CAP Kombinasyonları

#### CA Sistemler
- Geleneksel RDBMS (tek sunucu)

#### CP Sistemler  
- MongoDB, HBase, Redis

#### AP Sistemler
- Cassandra, DynamoDB, CouchDB

---

## 2. NoSQL Kavramı ve BASE

### 2.1 NoSQL Nedir?

**NoSQL:** "Not Only SQL" - SQL'e alternatif veya onu tamamlayan veri tabanları

### 2.2 BASE Prensipleri

- **BA - Basically Available:** Sistem çoğu zaman erişilebilir
- **S - Soft State:** Sistemin durumu zaman içinde değişebilir
- **E - Eventual Consistency:** Güncellemeler sonunda tüm node'lara yayılır

---

## 3. NoSQL Veritabanı Türleri

### 3.1 Document Store (Belge Tabanlı)

## 📗 MongoDB - Document Store

### Temel Kavramlar

- **Database:** Veritabanı
- **Collection:** Tablo benzeri (ama schema-less)
- **Document:** JSON benzeri doküman (BSON)
- **Field:** Alan

### Kurulum ve Bağlantı

```bash
# Docker ile
docker-compose up -d mongodb mongo-express

# MongoDB'ye bağlan
docker exec -it veri_mongodb mongosh

# Veya Mongo Express GUI
# http://localhost:8081
```

### Temel Komutlar

```javascript
// Database seç
use ecommerce

// Collection oluştur
db.createCollection("products")

// Doküman ekle
db.products.insertOne({
  name: "Laptop",
  price: 15000,
  category: "Electronics",
  specs: {
    ram: "16GB",
    cpu: "Intel i7"
  },
  tags: ["computer", "portable"]
})

// Sorgula
db.products.find({ category: "Electronics" })

// Güncelle
db.products.updateOne(
  { name: "Laptop" },
  { $set: { price: 14000 } }
)

// Sil
db.products.deleteOne({ name: "Laptop" })
```

**Ne zaman kullanılır?**
- Esnek schema gerektiğinde
- Hiyerarşik veri yapıları
- Hızlı geliştirme
- Content management sistemleri

## 🔴 Redis - Key-Value Store

### Temel Kavramlar

- **Key:** Benzersiz anahtar
- **Value:** String, List, Set, Hash, Sorted Set
- **In-memory:** Veriler RAM'de
- **Persistence:** Opsiyonel disk yazma

### Kurulum ve Bağlantı

```bash
# Redis'e bağlan
docker exec -it veri_redis redis-cli

# Test
PING  # Yanıt: PONG
```

### Temel Komutlar

```redis
# String
SET user:1000 "John Doe"
GET user:1000
EXPIRE user:1000 3600  # 1 saat sonra sil

# Hash (nesne benzeri)
HSET product:1 name "Laptop" price 15000
HGET product:1 name
HGETALL product:1

# List (kuyruk/stack)
LPUSH queue:jobs "job1"
RPUSH queue:jobs "job2"
LPOP queue:jobs

# Set (benzersiz değerler)
SADD tags:product:1 "electronic" "portable"
SMEMBERS tags:product:1

# Sorted Set (sıralı)
ZADD leaderboard 100 "player1" 200 "player2"
ZRANGE leaderboard 0 -1 WITHSCORES
```

**Ne zaman kullanılır?**
- Cache (önbellekleme)
- Session yönetimi
- Real-time analytics
- Message queue
- Rate limiting

## 📊 Cassandra - Column-Family Store

### Temel Kavramlar

- **Keyspace:** Database benzeri
- **Table:** Tablo
- **Row:** Satır
- **Column:** Sütun (dinamik)
- **Partition Key:** Verinin dağıtım anahtarı

### Kurulum ve Bağlantı

```bash
# Cassandra'ya bağlan
docker exec -it veri_cassandra cqlsh

# Test
DESCRIBE KEYSPACES;
```

### Temel Komutlar

```cql
-- Keyspace oluştur
CREATE KEYSPACE iot WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': 1
};

USE iot;

-- Tablo oluştur
CREATE TABLE sensor_data (
  sensor_id UUID,
  timestamp TIMESTAMP,
  temperature DOUBLE,
  humidity DOUBLE,
  PRIMARY KEY (sensor_id, timestamp)
) WITH CLUSTERING ORDER BY (timestamp DESC);

-- Veri ekle
INSERT INTO sensor_data (sensor_id, timestamp, temperature, humidity)
VALUES (uuid(), toTimestamp(now()), 22.5, 65.0);

-- Sorgula
SELECT * FROM sensor_data 
WHERE sensor_id = <uuid>
AND timestamp > '2025-01-01';
```

**Ne zaman kullanılır?**
- Time-series veriler
- IoT sensör verileri
- Log ve event tracking
- Yüksek yazma performansı gerektiğinde

## 🕸️ Neo4j - Graph Database

### Temel Kavramlar

- **Node:** Varlık (entity)
- **Relationship:** İlişki
- **Property:** Özellik
- **Label:** Etiket/tip

### Kurulum ve Bağlantı

```bash
# Neo4j Browser
# http://localhost:7474
# bolt://localhost:7687
# Kullanıcı: neo4j
# Şifre: password123
```

### Temel Komutlar (Cypher)

```cypher
// Node oluştur
CREATE (u:User {name: 'Alice', age: 30})
CREATE (u:User {name: 'Bob', age: 25})

// İlişki oluştur
MATCH (a:User {name: 'Alice'})
MATCH (b:User {name: 'Bob'})
CREATE (a)-[:FOLLOWS]->(b)

// Sorgula
MATCH (u:User)-[:FOLLOWS]->(friend)
WHERE u.name = 'Alice'
RETURN friend.name

// Öneri algoritması
MATCH (u:User {name: 'Alice'})-[:FOLLOWS]->()-[:FOLLOWS]->(recommendation)
WHERE NOT (u)-[:FOLLOWS]->(recommendation)
RETURN DISTINCT recommendation.name
```
## federated query engines (Trino)

* Federated Queries: Tüm NoSQL veritabanlarınızı tek bir SQL arayüzünden sorgulayabilirsiniz
* Cross-Database Joins: MongoDB'deki verilerle Cassandra'daki verileri birleştirebilirsiniz
* Standart SQL: SQL bilgisiyle tüm veri kaynaklarına erişim



**Ne zaman kullanılır?**
- Sosyal ağlar
- Öneri sistemleri
- Fraud detection
- Network analizi
- Knowledge graphs
---



## 4. Dağıtık Sistemler ve Ölçeklenebilirlik

### 4.1 Ölçeklendirme Türleri

#### Dikey Ölçeklendirme (Scale-Up)
```
Daha güçlü sunucu
CPU: 4 core → 16 core
RAM: 16GB → 128GB

❌ Pahalı
❌ Sınırlı
❌ Single point of failure
```

#### Yatay Ölçeklendirme (Scale-Out)
```
Daha fazla sunucu
Server 1 + Server 2 + Server 3

✅ Maliyet efektif
✅ Sınırsız ölçeklendirme
✅ Fault tolerance
```

### 4.2 Sharding (Parçalama)

**Stratejiler:**

**1. Range-Based:**
```
Shard 1: user_id 1-1000000
Shard 2: user_id 1000001-2000000
```

**2. Hash-Based:**
```
Shard = hash(user_id) % num_shards
```

**3. Geography-Based:**
```
Shard 1: Avrupa
Shard 2: Asya
Shard 3: Amerika
```

### 4.3 Replication

#### Master-Slave
```
Master (Write)
  ↓
Slave 1, 2, 3 (Read)
```

#### MongoDB Replica Set
```javascript
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo1:27017" },
    { _id: 1, host: "mongo2:27017" },
    { _id: 2, host: "mongo3:27017" }
  ]
})
```

### 4.4 Consistency Models

- **Strong Consistency:** Her zaman en son veri
- **Eventual Consistency:** Zamanla tutarlı hale gelir
- **Causal Consistency:** İlişkili işlemler sıralı

---

## 5. NewSQL Sistemler

### 5.1 Tanım

**NewSQL = ACID + Scalability**

### 5.2 Popüler Sistemler

#### Google Cloud Spanner
```sql
CREATE TABLE users (
  user_id INT64 NOT NULL,
  email STRING(100)
) PRIMARY KEY (user_id);
```

#### CockroachDB
```sql
-- PostgreSQL compatible
CREATE TABLE orders (
  id UUID PRIMARY KEY,
  amount DECIMAL(10,2)
);
```

---

## 6. Bulut Tabanlı Veri Platformları (DBaaS)

### 6.1 Avantajlar

- ✅ Kolay kurulum
- ✅ Otomatik yedekleme
- ✅ Otomatik scaling
- ✅ Kullandığın kadar öde

### 6.2 Popüler Çözümler

**AWS:** RDS, DynamoDB, DocumentDB, Neptune  
**Azure:** SQL Database, Cosmos DB  
**GCP:** Cloud SQL, Spanner, Firestore

---

## 🔄 Alternatifler ve Ekosistem

Bu hafta kullandığımız araçlar tek seçenek değil. Aynı işi yapan açık kaynak ve
enterprise/yönetilen alternatifler:

| Kullandığımız | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|
| **MongoDB** | FerretDB (Postgres üzerinde Mongo protokolü), CouchDB | MongoDB Atlas, Couchbase, Azure Cosmos DB, Amazon DocumentDB | Yönetilen servis, çoklu bölge, SSPL lisansından kaçınma |
| **Redis** | **Valkey**, Dragonfly, KeyDB, Memcached | Redis Cloud/Enterprise, Amazon ElastiCache/MemoryDB, Azure Cache for Redis | Lisans hassasiyeti, çok çekirdekli performans, yönetilen HA |
| **Cassandra** | ScyllaDB (Cassandra uyumlu, C++), HBase | DataStax Astra DB, Amazon Keyspaces, Azure Managed Instance for Cassandra | Daha düşük gecikme ve daha az düğüm (ScyllaDB), operasyon yükünü azaltma |
| **Neo4j (Community)** | Memgraph, ArangoDB, JanusGraph, Apache AGE (Postgres eklentisi) | Neo4j Enterprise/AuraDB, Amazon Neptune, TigerGraph | Kümeleme/HA gerekiyorsa (Community'de yok), çok büyük graf |
| **Trino** | Presto, Apache Drill, DuckDB (küçük ölçek) | Starburst, Dremio, Amazon Athena | Kurumsal erişim kontrolü, önbellek/hızlandırma, sunucusuz sorgu (Athena) |
| **NewSQL** (bölüm 5) | YugabyteDB, TiDB | Google Cloud Spanner, CockroachDB, Aurora DSQL | Hem yatay ölçek hem ACID gerekiyorsa |
| **Zaman serisi** (bu hafta yok) | TimescaleDB (Postgres uzantısı), InfluxDB, QuestDB, VictoriaMetrics | Timescale Cloud, InfluxDB Cloud, kdb+ (KX), Amazon Timestream, Azure Data Explorer | Sensör/IoT ve metrik verisi, zaman aralığı sorguları (Hafta 14, Vaka 5) |
| **Arama motoru** (bu hafta yok) | OpenSearch, Apache Solr, Meilisearch, Typesense · Elasticsearch (AGPL seçeneği) | Elastic Cloud, Amazon OpenSearch Service, Algolia | Tam metin arama, log analitiği, filtreli ürün arama |
| **Bellek içi / HTAP** (bu hafta yok) | Apache Ignite | SAP HANA, SingleStore, Hazelcast | Aynı veri üzerinde hem işlem hem analitik |

**Değerlendirirken bakılacaklar:** veri modeli uyumu (önce model, sonra ürün), tutarlılık ihtiyacı (CAP), operasyon yükü, lisans, bulut sağlayıcı bağımlılığı (Cosmos DB, DynamoDB gibi servisler taşınamaz).

> ⚖️ **Lisans notu:** Redis 2024'te BSD'den RSAL/SSPL'e geçti (Redis 8 ile AGPL seçeneği geldi);
> topluluk Linux Foundation altında **Valkey** fork'unu başlattı. MongoDB SSPL, Neo4j Community GPLv3'tür.
> CockroachDB 2024'te ücretsiz core sürümünü kaldırdı. Ayrıntı: [Lisans okuryazarlığı](../ALTERNATIVES.md#-lisans-okuryazarlığı)

📎 Tüm katmanların haritası ve lisans rehberi: [ALTERNATIVES.md](../ALTERNATIVES.md#-veritabanları-hafta-23)

---

## 7. Pratik Uygulamalar

### 7.1 MongoDB

```python
from pymongo import MongoClient

client = MongoClient('mongodb://admin:pass@localhost:27017/')
db = client.ecommerce

# Insert
product = {
    "name": "Laptop",
    "price": 15000,
    "stock": 50
}
db.products.insert_one(product)

# Query
products = db.products.find({"price": {"$gt": 10000}})
```

### 7.2 Redis

```python
import redis

r = redis.Redis(host='localhost', port=6379)

# Cache
r.setex("product:123", 3600, json.dumps(product_data))
cached = r.get("product:123")

# Leaderboard
r.zadd("leaderboard", {"player1": 1500})
top_10 = r.zrevrange("leaderboard", 0, 9, withscores=True)
```

### 7.3 Neo4j

```python
from neo4j import GraphDatabase

driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "pass"))

with driver.session() as session:
    result = session.run(
        "MATCH (p:Person {name: $name})-[:FRIEND_OF]->(friend) RETURN friend.name",
        name="Ahmet"
    )
    for record in result:
        print(record["friend.name"])
```

---

## 8. Alıştırmalar

### Alıştırma 1: MongoDB CRUD
E-ticaret ürün sistemi oluşturun

### Alıştırma 2: Redis Cache
Cache ve session management implementasyonu

### Alıştırma 3: Neo4j Graph
Sosyal ağ analizi ve öneri sistemi

### Alıştırma 4: CAP Analizi
Farklı senaryolar için veritabanı seçimi

---

## 9. Kaynaklar

- [MongoDB Manual](https://docs.mongodb.com/)
- [Redis Documentation](https://redis.io/documentation)
- [Neo4j Documentation](https://neo4j.com/docs/)
- "NoSQL Distilled" - Martin Fowler
- "Seven Databases in Seven Weeks" - Eric Redmond

---

**[← Hafta 2: Temel Veri Tabanı Kavramları](../week02-di-rdbms/README.md) | [🏠 Ana Sayfa](../README.md) | [Hafta 4: Veri Ambarları, Veri Gölleri ve Mimariler →](../week04-de-datawarehouse/README.md)**