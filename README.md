# 🎓 Veri Platformları Eğitim Projesi

Modern veri platformlarını öğrenmek için kapsamlı, pratik odaklı Docker tabanlı eğitim ortamı.

[![Docker](https://img.shields.io/badge/Docker-Required-blue)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## 📚 İçindekiler

- [Genel Bakış](#-genel-bakış)
- [Gereksinimler](#-gereksinimler)
- [Hızlı Başlangıç](#-hızlı-başlangıç)
- [Haftalık Müfredat](#-haftalık-müfredat)
- [Proje Yapısı](#-proje-yapısı)
- [Kullanım Kılavuzu](#-kullanım-kılavuzu)
- [Örnek Projeler](#-örnek-projeler)
- [Sorun Giderme](#-sorun-giderme)
- [Katkıda Bulunma](#-katkıda-bulunma)

## 🎯 Genel Bakış

Bu repo, 5 haftalık Veri Platformları dersini desteklemek için hazırlanmış, tamamen Docker container'lar üzerinde çalışan pratik örnekler içerir. Her hafta için:

- ✅ Detaylı ders notları (Markdown formatında)
- ✅ Çalışır durumda Docker container'lar
- ✅ Gerçek dünya veri setleri
- ✅ Hands-on alıştırmalar
- ✅ Kod örnekleri ve SQL scriptleri
- ✅ Jupyter Notebook'lar

## 💻 Gereksinimler

### Minimum Sistem Gereksinimleri
- **RAM**: 8GB (16GB önerilir)
- **Disk**: 30GB boş alan
- **CPU**: 4 core (önerilir)
- **OS**: Windows 10/11, macOS 10.15+, Linux (Ubuntu 20.04+)

### Yazılım Gereksinimleri
- [Docker Desktop](https://www.docker.com/products/docker-desktop) 4.0+ veya Docker Engine 20.10+
- [Docker Compose](https://docs.docker.com/compose/install/) v2.0+
- [Git](https://git-scm.com/downloads) 2.30+
- Bir kod editörü (VS Code önerilir)

### Opsiyonel Araçlar
- [DBeaver](https://dbeaver.io/) - Veritabanı yönetim aracı
- [Postman](https://www.postman.com/) - API testi
- [Python 3.8+](https://www.python.org/) - Script'ler için

## 🚀 Hızlı Başlangıç

### 1. Repoyu Klonlayın
```bash
git clone https://github.com/osmanuygar/veri-platformlari-egitim.git
cd veri-platformlari-egitim
```

### 2. Environment Dosyasını Oluşturun
```bash
cp .env.example .env
```

`.env` dosyasını düzenleyerek şifreleri değiştirin (güvenlik için önemli!)

### 3. Tüm Servisleri Başlatın
```bash
# Tüm servisleri arka planda başlat
docker-compose up -d

# İlk kurulum 5-10 dakika sürebilir
# Logları izlemek için:
docker-compose logs -f
```

### 4. Servislerin Hazır Olduğunu Kontrol Edin
```bash
docker-compose ps
```

Tüm servisler "healthy" veya "running" durumunda olmalı.

### 5. Web Arayüzlerine Erişin

| Servis | URL | Kullanıcı Adı | Şifre |
|--------|-----|---------------|-------|
| Adminer (DB GUI) | http://localhost:8080 | - | - |
| Jupyter Lab | http://localhost:8888 | - | Token'ı loglardan alın |
| Neo4j Browser | http://localhost:7474 | neo4j | password123 |
| MinIO Console | http://localhost:9001 | minioadmin | minioadmin |
| pgAdmin | http://localhost:5050 | admin@admin.com | admin |
| Mongo Express | http://localhost:8081 | admin | pass |

### 6. İlk Test
```bash
# PostgreSQL'e bağlanma testi
docker exec -it veri_postgres psql -U veri_user -d veri_db -c "SELECT version();"

# MongoDB'ye bağlanma testi
docker exec -it veri_mongodb mongosh --eval "db.version()"

# Redis'e bağlanma testi
docker exec -it veri_redis redis-cli PING
```

Hepsi başarılı dönerse, ortam hazır! 🎉

## 📖 Haftalık Müfredat

### [Hafta 1: Veri Dünyasına Giriş](./docs/hafta1-veri-dunyasina-giris.md)
**Konular:**
- Veri nedir? Veri vs Bilgi vs Bilgi
- Veri türleri: Yapısal, yarı-yapısal, yapısal olmayan
- Veri kaynakları: İç ve dış kaynaklar
- Veri platformlarının tarihsel evrimi (1960'lardan günümüze)

**Pratik Çalışmalar:**
- Farklı veri formatlarıyla çalışma (CSV, JSON, XML, PDF)
- Python ile veri okuma ve temel analiz
- Veri kalitesi kontrolü

**Docker Servisleri:** Jupyter Lab

📂 [Hafta 1 Klasörü](./week1-intro/)

---

### [Hafta 2: Temel Veri Tabanı Kavramları](./docs/hafta2-temel-veritabani.md)
**Konular:**
- RDBMS nedir? İlişkisel model temelleri
- ACID prensipleri (Atomicity, Consistency, Isolation, Durability)
- Primary Key, Foreign Key, İlişki türleri
- Temel SQL komutları (SELECT, INSERT, UPDATE, DELETE, JOIN)
- İlişkisel veritabanlarının sınırlamaları

**Pratik Çalışmalar:**
- PostgreSQL ve MySQL kurulumu ve konfigürasyonu
- ACID transaction örnekleri
- Kompleks JOIN sorguları
- Constraint'ler ve trigger'lar

**Docker Servisleri:** PostgreSQL, MySQL, pgAdmin, Adminer

📂 [Hafta 2 Klasörü](./week2-rdbms/)

**Hızlı Başlangıç:**
```bash
# Sadece RDBMS servislerini başlat
docker-compose up -d postgres mysql pgadmin adminer

# PostgreSQL'e bağlan
docker exec -it veri_postgres psql -U veri_user -d veri_db

# Örnek veritabanını yükle
docker exec -i veri_postgres psql -U veri_user -d veri_db < week2-rdbms/postgres/sample-data.sql
```

---

### [Hafta 3: NoSQL ve NewSQL Yaklaşımı](./docs/hafta3-nosql-newsql.md)
**Konular:**
- CAP Teoremi (Consistency, Availability, Partition Tolerance)
- NoSQL kavramı ve BASE prensipleri
- NoSQL türleri:
  - Document Store (MongoDB)
  - Key-Value (Redis)
  - Column-Family (Cassandra)
  - Graph Database (Neo4j)
- Dağıtık sistemler ve ölçeklenebilirlik
- NewSQL sistemler (CockroachDB, Google Spanner)
- Bulut tabanlı DBaaS çözümleri

**Pratik Çalışmalar:**
- MongoDB CRUD operasyonları
- Redis cache implementasyonu
- Cassandra ile time-series veri
- Neo4j ile sosyal ağ analizi
- CAP teoremi simülasyonu

**Docker Servisleri:** MongoDB, Redis, Cassandra, Neo4j, Mongo Express

📂 [Hafta 3 Klasörü](./week3-nosql/)

**Hızlı Başlangıç:**
```bash
# NoSQL servislerini başlat
docker-compose up -d mongodb redis cassandra neo4j mongo-express

# MongoDB'ye örnek veri yükle
docker exec -i veri_mongodb mongosh < week3-nosql/mongodb/sample-data.js

# Redis'te cache örneği
docker exec -it veri_redis redis-cli SET mykey "Hello Redis"
docker exec -it veri_redis redis-cli GET mykey
```

---

### [Hafta 4: Veri Ambarları, Veri Gölleri ve Mimariler](./docs/hafta4-datawarehouse-datalake.md)
**Konular:**
- OLTP vs OLAP karşılaştırması
- Veri Ambarı (Data Warehouse) mimarisi
- ETL vs ELT süreçleri
- Star Schema ve Snowflake Schema
- Fact ve Dimension tabloları
- Veri Gölü (Data Lake) kavramı
- Data Lakehouse mimarisi
- Modern veri mimarileri (Lambda, Kappa, Data Mesh)
- Veri kalitesi ve yönetişimi (Data Governance)
- Veri modelleme teknikleri
- Veri görselleştirme prensipleri
- Veri kariyer yolları

**Pratik Çalışmalar:**
- OLTP veritabanından OLAP'a ETL pipeline
- Star ve Snowflake şema tasarımı
- MinIO ile Data Lake oluşturma
- Apache Spark ile batch processing
- dbt ile veri transformasyonu
- Superset ile dashboard oluşturma

**Docker Servisleri:** PostgreSQL (OLTP), PostgreSQL (OLAP), MinIO, Apache Spark, dbt, Superset

📂 [Hafta 4 Klasörü](./week4-datawarehouse/)

**Hızlı Başlangıç:**
```bash
# Data Warehouse servislerini başlat
docker-compose -f docker-compose.week4.yml up -d

# ETL pipeline'ı çalıştır
docker exec -it veri_spark spark-submit /app/etl/run_etl.py

# MinIO'ya veri yükle
python week4-datawarehouse/scripts/upload_to_lake.py
```

---

### [Hafta 5: SQL ve İleri SQL ile Veri İşleme](./docs/hafta5-ileri-sql.md)
**Konular:**
- Window Functions (ROW_NUMBER, RANK, DENSE_RANK, LEAD, LAG)
- Common Table Expressions (CTE)
- Recursive queries
- Normalizasyon (1NF, 2NF, 3NF, BCNF)
- Denormalizasyon stratejileri
- İndeksleme (B-Tree, Hash, GiST, GIN)
- Query optimization ve EXPLAIN
- Stored Procedures ve Functions
- Triggers ve Events
- Transaction management
- Partitioning ve Sharding

**Pratik Çalışmalar:**
- Analitik sorgular yazma
- Performans optimizasyonu case study
- İndeks stratejileri karşılaştırması
- Complex business logic implementation
- Query tuning workshop

**Docker Servisleri:** PostgreSQL, MySQL
