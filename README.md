#  Veri Platformları Eğitim Projesi

Modern veri platformlarını öğrenmek için kapsamlı, pratik odaklı Docker tabanlı eğitim ortamı.

[![Docker](https://img.shields.io/badge/Docker-Required-blue)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## 📚 İçindekiler

- [Genel Bakış](#-genel-bakış)
- [Gereksinimler](#-gereksinimler)
- [Hızlı Başlangıç](#-hızlı-başlangıç)
- [Haftalık Müfredat](#-haftalık-müfredat)
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
- Docker Yerine  [orbstack] (https://orbstack.dev/) (Mac kullanıcıları için, Docker'a hafif alternatif, ben orbstack kullanıyorum)
- [Git](https://git-scm.com/downloads) 2.30+
- Bir kod editörü (Ben Pycharm kullanıyorum)

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

### [Hafta 1: Veri Dünyasına Giriş](./week1-intro/)
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

### [Hafta 2: Temel Veri Tabanı Kavramları](./week2-rdbms/)
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

### [Hafta 3: NoSQL ve NewSQL Yaklaşımı](./week3-nosql/)
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

### [Hafta 4: Veri Ambarları, Veri Gölleri ve Mimariler](./week4-datawarehouse/)
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

### [Hafta 5: SQL ve İleri SQL ile Veri İşleme](./week5-advanced-sql)
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

**Hızlı Başlangıç:**
```bash
# PostgreSQL'e bağlan
docker exec -it veri_postgres psql -U veri_user -d veri_db

# Window functions örneğini çalıştır
\i /docker-entrypoint-initdb.d/window-functions.sql

# Query performance analizi
EXPLAIN ANALYZE SELECT ...;
```

## 🎮 Kullanım Kılavuzu

### Belirli Bir Haftanın Servislerini Çalıştırma

```bash
# Sadece Hafta 2 servisleri
docker-compose up -d postgres mysql pgadmin adminer

# Sadece Hafta 3 servisleri
docker-compose up -d mongodb redis cassandra neo4j mongo-express

# Sadece Hafta 4 servisleri
docker-compose -f docker-compose.week4.yml up -d
```

### Veritabanlarına Bağlanma

#### PostgreSQL
```bash
# Komut satırından
docker exec -it veri_postgres psql -U veri_user -d veri_db

# Python'dan
import psycopg2
conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="veri_db",
    user="veri_user",
    password="veri_pass"
)
```

#### MongoDB
```bash
# Komut satırından
docker exec -it veri_mongodb mongosh -u admin -p admin_pass

# Python'dan
from pymongo import MongoClient
client = MongoClient('mongodb://admin:admin_pass@localhost:27017/')
```

#### Redis
```bash
# Komut satırından
docker exec -it veri_redis redis-cli

# Python'dan
import redis
r = redis.Redis(host='localhost', port=6379, db=0)
```

#### Neo4j
```bash
# Browser: http://localhost:7474
# Bolt: bolt://localhost:7687

# Python'dan
from neo4j import GraphDatabase
driver = GraphDatabase.driver("bolt://localhost:7687", 
                               auth=("neo4j", "password123"))
```

### Veri Yükleme ve Yedekleme

```bash
# PostgreSQL dump alma
docker exec veri_postgres pg_dump -U veri_user veri_db > backup.sql

# PostgreSQL dump geri yükleme
docker exec -i veri_postgres psql -U veri_user veri_db < backup.sql

# MongoDB export
docker exec veri_mongodb mongodump --out /backup

# MongoDB import
docker exec veri_mongodb mongorestore /backup
```

### Log İzleme

```bash
# Tüm servislerin logları
docker-compose logs -f

# Belirli bir servisin logları
docker-compose logs -f postgres

# Son 100 satır
docker-compose logs --tail=100 mongodb
```

### Performans İzleme

```bash
# Container kaynak kullanımı
docker stats

# Disk kullanımı
docker system df

# Belirli bir container'ın detayları
docker inspect veri_postgres
```

## 🎯 Örnek Projeler

### 1. E-Ticaret Veritabanı
**Seviye:** Başlangıç  
**Süre:** 2-3 saat  
**Teknolojiler:** PostgreSQL, SQL

Tam özellikli bir e-ticaret veritabanı tasarlayın:
- Müşteriler, ürünler, siparişler
- İlişkisel model
- ACID transaction'lar
- Kompleks sorgular

📂 [Proje Detayları](./projects/project1-ecommerce/)

### 2. Sosyal Ağ Analizi
**Seviye:** Orta  
**Süre:** 3-4 saat  
**Teknolojiler:** Neo4j, Cypher

Sosyal ağ grafiği oluşturun ve analiz edin:
- Kullanıcılar ve arkadaşlıklar
- Takip ilişkileri
- Öneri algoritmaları
- Community detection

📂 [Proje Detayları](./projects/project2-social-network/)

### 3. IoT Veri Pipeline
**Seviye:** İleri  
**Süre:** 5-6 saat  
**Teknolojiler:** Redis, Cassandra, Spark, MinIO

Gerçek zamanlı IoT veri pipeline:
- Sensor verisi simülasyonu
- Redis ile streaming
- Cassandra'da time-series storage

📂 [Proje Detayları](./projects/project3-iot-pipeline/)

### 4. Kurumsal Veri Ambarı
**Seviye:** İleri  
**Süre:** 8-10 saat  
**Teknolojiler:** PostgreSQL, dbt, Superset, MinIO

End-to-end veri ambarı projesi:
- OLTP'den OLAP'a ETL
- Star schema implementation
- dbt transformations
- BI dashboard

📂 [Proje Detayları](./projects/project4-data-warehouse/)

## 🔧 Sorun Giderme

### Port Çakışması
```bash
# Kullanılan portları kontrol et
# Windows
netstat -ano | findstr :5432

# Linux/Mac
lsof -i :5432

# docker-compose.yml'de portları değiştir
ports:
  - "5433:5432"  # 5432 yerine 5433 kullan
```

### Container Başlamıyor
```bash
# Container durumunu kontrol et
docker-compose ps

# Logları incele
docker-compose logs 

# Container'ı yeniden başlat
docker-compose restart 

# Tamamen temiz başlangıç
docker-compose down
docker-compose up -d
```

### Bellek Yetersizliği
```bash
# Docker'a daha fazla bellek ayır
# Docker Desktop > Settings > Resources > Memory

# Sadece gerekli servisleri çalıştır
docker-compose up -d postgres mongodb redis
```

### Veritabanı Bağlantı Hatası
```bash
# Container'ın hazır olup olmadığını kontrol et
docker-compose ps

# Health check
docker inspect --format='{{.State.Health.Status}}' veri_postgres

# Bağlantıyı test et
docker exec -it veri_postgres pg_isready -U veri_user
```

### Tüm Verileri Sıfırlama
```bash
# DİKKAT: Bu komut TÜM verileri siler!
docker-compose down -v

# Yeniden başlat
docker-compose up -d
```

### Disk Alanı Temizliği
```bash
# Kullanılmayan image'leri temizle
docker image prune -a

# Kullanılmayan volume'leri temizle
docker volume prune

# Sistem geneli temizlik
docker system prune -a --volumes
```

## 📚 Ek Kaynaklar

### Resmi Dokümantasyonlar
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MongoDB Manual](https://docs.mongodb.com/manual/)
- [Redis Documentation](https://redis.io/documentation)
- [Neo4j Documentation](https://neo4j.com/docs/)
- [Apache Cassandra Docs](https://cassandra.apache.org/doc/)

### Kitaplar
- "Designing Data-Intensive Applications" - Martin Kleppmann
- "Database Internals" - Alex Petrov
- "The Data Warehouse Toolkit" - Ralph Kimball
- "Seven Databases in Seven Weeks" - Eric Redmond

### YouTube Kanalları
- [Hussein Nasser](https://www.youtube.com/c/HusseinNasser-software-engineering)
- [CMU Database Group](https://www.youtube.com/c/CMUDatabaseGroup)
- [The Art of PostgreSQL](https://www.youtube.com/@tapoueh)

### Blog'lar ve Makaleler
- [High Scalability](http://highscalability.com/)
- [Martin Fowler's Blog](https://martinfowler.com/)
- [Uber Engineering Blog](https://eng.uber.com/)
- [Netflix Tech Blog](https://netflixtechblog.com/)

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Bu projeye nasıl katkıda bulunabileceğiniz:

### Katkı Türleri
- 🐛 Bug raporları
- ✨ Yeni özellik önerileri
- 📝 Dokümantasyon iyileştirmeleri
- 🎓 Yeni alıştırmalar ve örnekler
- 🔧 Kod optimizasyonları


### Katkı Süreci
1. Bu repoyu fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/yeni-ozellik`)
3. Değişikliklerinizi commit edin (`git commit -am 'Yeni özellik: XYZ'`)
4. Branch'inizi push edin (`git push origin feature/yeni-ozellik`)
5. Pull Request oluşturun


## 📋 Roadmap

### v1.0 (Mevcut)
- ✅ Temel Docker setup
- ✅ PostgreSQL, MySQL
- ✅ MongoDB, Redis, Cassandra, Neo4j
- ✅ Temel ETL pipeline
- ✅ Jupyter Lab entegrasyonu
- ✅ Haftalık müfredat ve alıştırmalar
- ✅ Örnek projeler

## 🙏 Teşekkürler

Bu proje şu açık kaynak projeleri kullanmaktadır:
- [PostgreSQL](https://www.postgresql.org/)
- [MongoDB](https://www.mongodb.com/)
- [Redis](https://redis.io/)
- [Neo4j](https://neo4j.com/)
- [Apache Cassandra](https://cassandra.apache.org/)
- [MinIO](https://min.io/)
- [Docker](https://www.docker.com/)

Ve tüm katkıda bulunanlara teşekkürler! 🎉

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](./LICENSE) dosyasına bakın.

## 📧 İletişim

- **Proje Sahibi:** Osman Uygar KOSE
- **Email:** osmanuygar@gmail.com
- **LinkedIn:** [linkedin.com/in/osmanuygarkose](https://linkedin.com/in/osman-uygar-kose-56785820/)
- **Issues:** [GitHub Issues](https://github.com/osmanuygar/veri-platformlari-egitim/issues)

## 🌟 Yıldız Verin

Bu projeyi faydalı bulduysanız, lütfen ⭐ vererek destek olun!

