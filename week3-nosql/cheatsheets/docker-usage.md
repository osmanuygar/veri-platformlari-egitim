# Week 3 - Docker Kurulum ve Kullanım Rehberi



## 🚀 Hızlı Başlangıç


### 1. Tüm Servisleri Başlat

```bash
cd week3-nosql

# Tüm servisleri başlat
docker-compose up -d

# Durumu kontrol et
docker-compose ps

# Logları izle
docker-compose logs -f
```

### 2. Servislerin Hazır Olmasını Bekle

```bash
# Tüm servislerin durumunu kontrol et
docker-compose ps

# Her servisin "healthy" olmasını bekle
# (Cassandra'nın başlaması 1-2 dakika sürebilir)
```

## 🎯 Servis Seçmeli Başlatma

### Sadece MongoDB
```bash
docker-compose up -d mongodb mongo-express
```

### Sadece Redis
```bash
docker-compose up -d redis
```

### Sadece Neo4j
```bash
docker-compose up -d neo4j
```

### Sadece Cassandra
```bash
docker-compose up -d cassandra
```

### MongoDB + Redis (Sık kullanılanlar)
```bash
docker-compose up -d mongodb mongo-express redis
```

## 📊 Servis Bilgileri

### MongoDB
- **Port:** 27017
- **Admin User:** admin
- **Admin Pass:** admin_pass
- **Bağlantı:** `mongodb://admin:admin_pass@localhost:27017`

**Bağlanma:**
```bash
docker exec -it veri_mongodb mongosh -u admin -p admin_pass
```

### Mongo Express (Web GUI)
- **URL:** http://localhost:8081
- **User:** admin
- **Pass:** admin_pass

### Redis
- **Port:** 6379
- **Password:** redis_pass
- **Bağlantı:** `redis://localhost:6379`

**Bağlanma:**
```bash
# Şifresiz (default yapılandırma)
docker exec -it veri_redis redis-cli

# Şifreli (yukarıdaki compose'da)
docker exec -it veri_redis redis-cli -a redis_pass
```

### Redis Commander (Web GUI - Opsiyonel)
```bash
# Redis GUI'yi başlatmak için:
docker-compose --profile gui up -d redis-commander

# URL: http://localhost:8082
```

### Cassandra
- **Port:** 9042 (CQL)
- **Port:** 7000 (Inter-node)
- **No Auth:** Default yapılandırma

**Bağlanma:**
```bash
# 30-60 saniye bekleyin (yavaş başlar)
docker exec -it veri_cassandra cqlsh

# Uzaktan bağlantı için:
# cqlsh localhost 9042
```

### Neo4j
- **HTTP:** http://localhost:7474 (Browser)
- **Bolt:** bolt://localhost:7687
- **User:** neo4j
- **Pass:** password123

**Neo4j Browser:**
- URL: http://localhost:7474
- İlk giriş: neo4j / neo4j (şifre değiştirilecek)
- Yeni şifre: password123

## 🔧 Yönetim Komutları

### Servisleri Başlat/Durdur
```bash
# Başlat
docker-compose up -d

# Durdur
docker-compose stop

# Durdur ve kaldır
docker-compose down

# Durdur, kaldır ve volume'leri sil (DİKKAT: Tüm veri silinir!)
docker-compose down -v
```

### Servis Durumu
```bash
# Tüm servislerin durumu
docker-compose ps

# Detaylı durum
docker-compose ps -a

# Logları göster
docker-compose logs

# Belirli bir servisin logları
docker-compose logs mongodb
docker-compose logs -f redis  # Canlı takip
```

### Tek Servisi Yönet
```bash
# MongoDB'yi yeniden başlat
docker-compose restart mongodb

# Redis'i durdur
docker-compose stop redis

# Neo4j'yi başlat
docker-compose start neo4j
```

### Container'a Shell Erişimi
```bash
# MongoDB
docker exec -it veri_mongodb bash

# Redis
docker exec -it veri_redis sh

# Cassandra
docker exec -it veri_cassandra bash

# Neo4j
docker exec -it veri_neo4j bash
```

## 🗄️ Veri Yönetimi

### Backup (Yedekleme)

```bash
# MongoDB backup
docker exec veri_mongodb mongodump --out /backup
docker cp veri_mongodb:/backup ./mongodb_backup

# Redis backup
docker exec veri_redis redis-cli -a redis_pass SAVE
docker cp veri_redis:/data/dump.rdb ./redis_backup.rdb

# Cassandra backup
docker exec veri_cassandra nodetool snapshot

# Neo4j backup (otomatik /data'da)
docker cp veri_neo4j:/data ./neo4j_backup
```

### Restore (Geri Yükleme)

```bash
# MongoDB restore
docker cp ./mongodb_backup veri_mongodb:/backup
docker exec veri_mongodb mongorestore /backup

# Redis restore
docker cp ./redis_backup.rdb veri_redis:/data/dump.rdb
docker-compose restart redis

# Neo4j restore
docker cp ./neo4j_backup/data veri_neo4j:/
docker-compose restart neo4j
```

### Verileri Temizle

```bash
# Tüm volume'leri sil (DİKKAT: TÜM VERİ SİLİNİR!)
docker-compose down -v

# Yeniden başlat (temiz kurulum)
docker-compose up -d
```

## 🔍 Sorun Giderme

### Port Çakışması
```bash
# Kullanılan portları kontrol et
netstat -an | grep LISTEN

# docker-compose.yml'de portları değiştir
# Örnek: "27018:27017" (MongoDB'yi 27018'de aç)
```

### Container Başlamıyor
```bash
# Logları kontrol et
docker-compose logs <servis_adı>

# Örnek:
docker-compose logs mongodb
docker-compose logs cassandra
```

### Cassandra Bağlantı Sorunu
```bash
# Cassandra başlaması 1-2 dakika sürer
docker logs veri_cassandra

# "Starting listening for CQL clients" mesajını bekle
# Sonra bağlan:
docker exec -it veri_cassandra cqlsh
```

### Neo4j Şifre Sorunu
```bash
# Eğer şifre uyuşmazsa container'ı temizle
docker-compose down -v neo4j
docker-compose up -d neo4j

# İlk giriş: neo4j / neo4j
# Yeni şifre: password123
```

### Disk Dolu
```bash
# Kullanılmayan volume'leri temizle
docker volume prune

# Kullanılmayan image'leri temizle
docker image prune -a

# Sistem geneli temizlik
docker system prune -a --volumes
```

## 📦 Resource Kullanımı

### Minimum Gereksinimler
- **RAM:** 4GB (8GB önerilir)
- **Disk:** 10GB boş alan
- **CPU:** 2 core

### Servis Bazlı RAM Kullanımı
- MongoDB: ~500MB
- Redis: ~100MB
- Cassandra: ~1GB
- Neo4j: ~1GB
- **Toplam:** ~2.5-3GB

### Resource Limitleri Ayarla
```yaml
# docker-compose.yml'e ekle
services:
  mongodb:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          memory: 256M
```

## 🚦 Healthcheck Durumları

```bash
# Tüm servislerin health durumu
docker-compose ps

# Detaylı health bilgisi
docker inspect veri_mongodb | grep -A 10 Health
```

### Servis Hazır mı?
```bash
# MongoDB
docker exec veri_mongodb mongosh --eval "db.runCommand('ping')"

# Redis
docker exec veri_redis redis-cli -a redis_pass PING

# Cassandra (30-60 saniye bekle)
docker exec veri_cassandra cqlsh -e "DESCRIBE KEYSPACES"

# Neo4j
curl http://localhost:7474
```

## 🔐 Güvenlik (Production için)

### Şifreleri .env Dosyasında Tut

`.env` dosyası oluştur:
```env
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=change_this_password
REDIS_PASSWORD=change_this_too
NEO4J_PASSWORD=strong_password_here
```

`docker-compose.yml`'de kullan:
```yaml
environment:
  MONGO_INITDB_ROOT_USERNAME: ${MONGO_ROOT_USERNAME}
  MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASSWORD}
```

### .gitignore'a Ekle
```bash
echo ".env" >> .gitignore
echo "*.backup" >> .gitignore
```

## 📊 Monitoring (İzleme)

### Container Stats
```bash
# Gerçek zamanlı kaynak kullanımı
docker stats

# Sadece NoSQL servisleri
docker stats veri_mongodb veri_redis veri_cassandra veri_neo4j
```

### Disk Kullanımı
```bash
# Volume boyutları
docker system df -v

# Belirli bir volume
docker volume inspect mongodb_data
```

## 🎓 Örnek Kullanım Senaryoları

### Senaryo 1: Sadece MongoDB Çalıştır (Hafif)
```bash
# Başlat
docker-compose up -d mongodb mongo-express

# Kullan
open http://localhost:8081

# Durdur
docker-compose stop mongodb mongo-express
```

### Senaryo 2: Tüm NoSQL DB'leri Dene
```bash
# Hepsini başlat
docker-compose up -d

# 2 dakika bekle (Cassandra için)
sleep 120

# Bağlantı testleri
docker exec -it veri_mongodb mongosh --eval "db.version()"
docker exec -it veri_redis redis-cli -a redis_pass PING
docker exec -it veri_cassandra cqlsh -e "SELECT release_version FROM system.local"
curl http://localhost:7474

# Her şey OK ise alıştırmalara başla!
```

### Senaryo 3: Geliştirme Ortamı (Auto-restart)
```yaml
# docker-compose.yml'de her servis için:
restart: unless-stopped

# veya
restart: always
```

## 📝 Özet

```bash
# BAŞLATMA
cd week3-nosql
docker-compose up -d

# KONTROL
docker-compose ps

# BAĞLANMA
docker exec -it veri_mongodb mongosh
docker exec -it veri_redis redis-cli -a redis_pass
docker exec -it veri_cassandra cqlsh
open http://localhost:7474  # Neo4j

# DURDURMA
docker-compose stop

# SİLME (veriler kalır)
docker-compose down

# TAM SİLME (veriler gider!)
docker-compose down -v
```

## 🎉 Hazırsınız!

Artık Week 3 alıştırmalarına başlayabilirsiniz! 🚀