# Hafta 3: NoSQL ve NewSQL Yaklaşımı

## 📚 İçindekiler

1. [CAP Teoremi](#1-cap-teoremi)
2. [NoSQL Kavramı ve BASE](#2-nosql-kavramı-ve-base)
3. [NoSQL Veritabanı Türleri](#3-nosql-veritabanı-türleri)
4. [Dağıtık Sistemler ve Ölçeklenebilirlik](#4-dağıtık-sistemler-ve-ölçeklenebilirlik)
5. [NewSQL Sistemler](#5-newsql-sistemler)
6. [Bulut Tabanlı Veri Platformları (DBaaS)](#6-bulut-tabanlı-veri-platformları-dbaas)
7. [Pratik Uygulamalar](#7-pratik-uygulamalar)
8. [Alıştırmalar](#8-alıştırmalar)
9. [Kaynaklar](#9-kaynaklar)

---

## 1. CAP Teoremi

### 1.1 Tanım

**CAP Teoremi (Brewer's Theorem):** Eric Brewer tarafından 2000 yılında öne sürülmüş, dağıtık sistemlerde aynı anda sadece iki özelliğin garanti edilebileceğini söyleyen teorem.

```
C + A + P → Sadece 2 Tanesini Seçebilirsin!
```

### 1.2 Üç Özellik

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

#### MongoDB Örneği

**Veri Modeli:**
```javascript
{
  "_id": ObjectId("507f1f77bcf86cd799439011"),
  "ad": "Ahmet",
  "soyad": "Yılmaz",
  "email": "ahmet@example.com",
  "adres": {
    "sehir": "Istanbul",
    "ilce": "Kadikoy"
  },
  "siparisler": [
    {
      "siparis_no": "ORD-001",
      "tutar": 450.50
    }
  ]
}
```

**CRUD İşlemleri:**
```javascript
// CREATE
db.musteriler.insertOne({
  ad: "Mehmet",
  soyad: "Kaya",
  email: "mehmet@example.com"
});

// READ
db.musteriler.find({ "adres.sehir": "Istanbul" });

// UPDATE
db.musteriler.updateOne(
  { email: "ahmet@example.com" },
  { $set: { aktif: false } }
);

// DELETE
db.musteriler.deleteOne({ email: "test@example.com" });
```

### 3.2 Key-Value Store

#### Redis Örneği

```bash
# String operations
SET user:1000:name "Ahmet Yilmaz"
GET user:1000:name

# Lists
LPUSH queue:emails "email1@example.com"
RPOP queue:emails

# Sets
SADD tags:post:1 "python" "redis" "nosql"
SMEMBERS tags:post:1

# Sorted Sets (Leaderboard)
ZADD leaderboard 1500 "player:1"
ZREVRANGE leaderboard 0 9 WITHSCORES

# Hash
HSET user:1000 name "Ahmet" email "ahmet@example.com"
HGETALL user:1000
```

### 3.3 Column-Family Store

#### Cassandra Örneği

```cql
-- Keyspace oluşturma
CREATE KEYSPACE iot_data
WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': 3
};

-- Tablo oluşturma
CREATE TABLE sensor_readings (
  sensor_id UUID,
  reading_time TIMESTAMP,
  temperature DOUBLE,
  humidity DOUBLE,
  PRIMARY KEY (sensor_id, reading_time)
) WITH CLUSTERING ORDER BY (reading_time DESC);

-- INSERT
INSERT INTO sensor_readings (sensor_id, reading_time, temperature, humidity)
VALUES (uuid(), toTimestamp(now()), 22.5, 65.3);

-- SELECT
SELECT * FROM sensor_readings
WHERE sensor_id = 123e4567-e89b-12d3-a456-426614174000
AND reading_time > '2025-01-01';
```

### 3.4 Graph Database (Grafik Veritabanı)

#### Özellikler
- Node'lar ve relationship'ler
- Hızlı graph traversal
- İlişki-odaklı sorgular
- Pattern matching

#### Neo4j Örneği

**Docker ile Başlatma:**
```bash
docker-compose up -d neo4j
# Browser: http://localhost:7474
```

**Veri Modeli:**
```cypher
-- Node oluşturma
CREATE (a:Person {name: 'Ahmet', age: 30, city: 'Istanbul'})
CREATE (m:Person {name: 'Mehmet', age: 28, city: 'Ankara'})
CREATE (f:Person {name: 'Fatma', age: 32, city: 'Izmir'})

-- Relationship oluşturma
MATCH (a:Person {name: 'Ahmet'}), (m:Person {name: 'Mehmet'})
CREATE (a)-[:FRIEND_OF {since: 2020}]->(m)

-- Film ve rating
CREATE (movie:Movie {title: 'Inception', year: 2010})
MATCH (a:Person {name: 'Ahmet'}), (m:Movie {title: 'Inception'})
CREATE (a)-[:RATED {score: 9.5, date: date()}]->(m)
```

**Graph Sorguları:**
```cypher
-- Ahmet'in arkadaşlarını bul
MATCH (a:Person {name: 'Ahmet'})-[:FRIEND_OF]->(friend)
RETURN friend.name, friend.age

-- Arkadaşların arkadaşları (2 derece)
MATCH (a:Person {name: 'Ahmet'})-[:FRIEND_OF*2]->(fof)
RETURN DISTINCT fof.name

-- En kısa yol
MATCH path = shortestPath(
  (a:Person {name: 'Ahmet'})-[:FRIEND_OF*]-(m:Person {name: 'Mehmet'})
)
RETURN path

-- Ortak arkadaş bulma
MATCH (a:Person {name: 'Ahmet'})-[:FRIEND_OF]-(mutual)-[:FRIEND_OF]-(b:Person {name: 'Mehmet'})
RETURN mutual.name

-- Film önerisi
MATCH (me:Person {name: 'Ahmet'})-[:FRIEND_OF]->(friend)-[:RATED]->(movie:Movie)
WHERE friend.score >= 8
RETURN movie.title, AVG(friend.score) as avg_rating
ORDER BY avg_rating DESC
LIMIT 5
```

**Avantajlar:**
- ✅ İlişki sorguları çok hızlı
- ✅ Pattern matching
- ✅ Graph algoritmaları

**Dezavantajlar:**
- ❌ Yatay ölçeklendirme zor
- ❌ Memory intensive

**Kullanım Alanları:**
- Sosyal ağlar
- Öneri sistemleri
- Fraud detection
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

**[← Hafta 2](../week2-rdms/README.md) | [Ana Sayfa](../README.md) | [Hafta 4 →](../week4-datawarehouse/README.md)**