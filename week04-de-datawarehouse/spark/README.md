# Apache Spark - Big Data Processing

Apache Spark ile distributed data processing.

## 🚀 Hızlı Başlangıç

### 1. Spark Cluster'ı Başlat

```bash
# Spark klasörüne git
cd spark

# Cluster'ı başlat (Master + Worker)
docker-compose up -d

# Logları izle
docker-compose logs -f

# Durumu kontrol et
docker-compose ps
```

### 2. Web UI'lara Eriş

```
Spark Master UI: http://localhost:8080
Spark Worker UI: http://localhost:8081
```

### 3. Job Çalıştır

```bash
# PostgreSQL → Parquet ETL
docker exec -it spark_master python /opt/spark-jobs/etl_postgres_to_parquet.py

# MinIO'dan okuma ve analiz
docker exec -it spark_master python /opt/spark-jobs/read_from_minio.py

# Satış aggregation
docker exec -it spark_master python /opt/spark-jobs/sales_aggregation.py
```

## 🛠️ Kullanım Seçenekleri

### Seçenek 1: Doğrudan Python (Kolay)
```bash
docker exec -it spark_master python /opt/spark-jobs/etl_postgres_to_parquet.py
```

### Seçenek 2: Spark Submit (Distributed)
```bash
docker exec -it spark_master spark-submit \
  --master spark://spark-master:7077 \
  --executor-memory 1G \
  --total-executor-cores 2 \
  /opt/spark-jobs/etl_postgres_to_parquet.py
```

### Seçenek 3: PySpark Shell (İnteraktif)
```bash
docker exec -it spark_master pyspark \
  --master spark://spark-master:7077
```

## 📦 Örnek Job'lar

### 1. PostgreSQL → Parquet ETL
PostgreSQL'den veri çeker, Parquet'e dönüştürür ve MinIO'ya yazar:
```bash
docker exec -it spark_master \
  python /opt/spark-jobs/etl_postgres_to_parquet.py
```

**Ne yapar:**
- customers, products, orders, order_items tablolarını okur
- Parquet formatına dönüştürür
- MinIO'nun `processed-data` bucket'ına yazar

### 2. MinIO'dan Okuma ve Analiz
MinIO'daki Parquet dosyalarını okur ve analiz eder:
```bash
docker exec -it spark_master \
  python /opt/spark-jobs/read_from_minio.py
```

**Ne yapar:**
- Müşteri analizi (şehir/ülke bazında)
- Ürün analizi (kategori, fiyat)
- Sipariş analizi (durum, ödeme)
- Sipariş detay analizi

### 3. Satış Aggregation
Satış verilerini aggregate eder (günlük, aylık):
```bash
docker exec -it spark_master \
  python /opt/spark-jobs/sales_aggregation.py
```

**Ne yapar:**
- Günlük satış toplamları
- Ürün bazında satışlar
- Kategori bazında satışlar
- Müşteri bazında satışlar
- Running totals (Window function)
- Sonuçları MinIO'ya kaydeder

## 💻 PySpark ile Kullanım

```python
from pyspark.sql import SparkSession

# Spark session oluştur
spark = SparkSession.builder \
    .appName("MyApp") \
    .master("spark://spark-master:7077") \
    .getOrCreate()

# PostgreSQL'den oku
df = spark.read \
    .format("jdbc") \
    .option("url", "jdbc:postgresql://postgres-oltp:5432/ecommerce_oltp") \
    .option("dbtable", "customers") \
    .option("user", "oltp_user") \
    .option("password", "oltp_pass123") \
    .load()

# Parquet olarak kaydet
df.write.mode("overwrite").parquet("s3a://datawarehouse/customers/")

spark.stop()
```

## 🔧 S3/MinIO Konfigürasyonu

Spark'ın MinIO ile çalışması için gerekli ayarlar:

```python
spark = SparkSession.builder \
    .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
    .config("spark.hadoop.fs.s3a.access.key", "minio_admin") \
    .config("spark.hadoop.fs.s3a.secret.key", "minio_password123") \
    .config("spark.hadoop.fs.s3a.path.style.access", "true") \
    .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .getOrCreate()
```

## 📊 Spark DataFrame Operations

```python
# Okuma
df = spark.read.parquet("s3a://datawarehouse/sales/")

# Transformations
result = df.groupBy("product_id") \
    .agg({"quantity": "sum", "total_amount": "sum"}) \
    .orderBy("sum(total_amount)", ascending=False)

# Yazma
result.write.mode("overwrite").parquet("s3a://processed-data/top_products/")
```

## 🐳 Docker Compose Detayları

### Servisler
- **spark-master**: Spark master node (port 8080, 7077)
- **spark-worker**: Spark worker node (port 8081)
- **spark-jobs**: (Opsiyonel) Custom dependencies ile job container

### Kaynaklar
- Worker Memory: 2GB
- Worker Cores: 2
- Master UI: 8080
- Worker UI: 8081

### Profiller
```bash
# Sadece Master ve Worker
docker-compose up -d

# Custom jobs container ile
docker-compose --profile jobs up -d
```

## 🔍 Monitoring ve Debug

### Cluster Durumu
```bash
# Container durumu
docker-compose ps

# Master logları
docker-compose logs -f spark-master

# Worker logları
docker-compose logs -f spark-worker

# Kaynak kullanımı
docker stats spark_master spark_worker
```

### Web UI'dan İzleme
- **Master UI (8080)**: Aktif worker'lar, running applications
- **Worker UI (8081)**: Executor'lar, resource kullanımı
- **Application UI (4040)**: Job detayları (job çalışırken aktif)

## 🛑 Durdurma ve Temizlik

```bash
# Durdur
docker-compose down

# Volume'ler ile birlikte sil
docker-compose down -v

# Yeniden başlat
docker-compose restart
```

## 🎯 Özellikler

- ✅ Spark Standalone Cluster (Master + Worker)
- ✅ PostgreSQL JDBC connector
- ✅ MinIO/S3 entegrasyonu (S3A)
- ✅ Parquet okuma/yazma
- ✅ DataFrame API
- ✅ SQL sorguları
- ✅ Window functions
- ✅ Web UI monitoring

## 📚 Öğrenme Kaynakları

### Temel
- [Spark Documentation](https://spark.apache.org/docs/latest/)
- [PySpark API](https://spark.apache.org/docs/latest/api/python/)

### İleri Seviye
- [Spark SQL Guide](https://spark.apache.org/docs/latest/sql-programming-guide.html)
- [Spark Performance Tuning](https://spark.apache.org/docs/latest/tuning.html)

## 💡 İpuçları

1. **Küçük veri için**: Doğrudan Python ile çalıştırın
2. **Büyük veri için**: Spark submit kullanın
3. **Geliştirme**: PySpark shell ile interaktif test edin
4. **Production**: Cluster mode ve resource ayarlarını optimize edin

## 🔗 Bağımlılıklar

Bu Spark cluster'ı Week 4 eğitiminin parçasıdır ve şunları gerektirir:
- ✅ PostgreSQL (OLTP) - Kaynak veri
- ✅ MinIO - Data Lake storage
- ✅ `datawarehouse_network` - Docker network

Ana docker-compose.yml ile birlikte çalışacak şekilde yapılandırılmıştır.