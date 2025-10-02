# MinIO - Object Storage / Data Lake

MinIO, S3-compatible object storage sistemi. Data Lake olarak kullanılır.

## 🚀 Kullanım

### Web Console
```
URL: http://localhost:9001
Kullanıcı: minio_admin
Şifre: minio_password123
```

### Bucket'lar
Docker Compose başlatıldığında otomatik oluşturulur:
- `datawarehouse` - Ana veri bucket'ı
- `raw-data` - Ham veriler (CSV, JSON)
- `processed-data` - İşlenmiş veriler (Parquet)
- `archive` - Arşiv verileri

## 📦 Scriptler

### 1. Bucket Listeleme
```bash
python scripts/list_buckets.py
```

### 2. Örnek Veri Yükleme
```bash
python scripts/upload_data.py
```

### 3. Parquet Dönüşümü
CSV ve JSON dosyalarını Parquet formatına dönüştürür:
```bash
python scripts/create_parquet.py
```

**Özellikler:**
- Snappy compression
- Veri tipi optimizasyonu
- Partitioned tables (sales: year/month)
- MinIO'ya otomatik yükleme

### 4. Iceberg Table Oluşturma
Apache Iceberg tablo yapıları oluşturur:
```bash
python scripts/create_iceberg_table.py
```

**Özellikler:**
- Schema evolution desteği
- Time travel capability
- ACID transactions
- Hidden partitioning

## 💻 Python ile Kullanım

```python
from minio import Minio

# Bağlantı
client = Minio(
    "localhost:9000",
    access_key="minio_admin",
    secret_key="minio_password123",
    secure=False
)

# Dosya yükle
client.fput_object(
    "datawarehouse",
    "data/myfile.csv",
    "local/path/file.csv"
)

# Dosya indir
client.fget_object(
    "datawarehouse",
    "data/myfile.csv",
    "downloaded/file.csv"
)
```

## 🐳 Docker ile Çalıştırma

```bash
# MinIO client container'ı build et
docker build -t minio-client .

# Script çalıştır
docker run --rm --network datawarehouse_network \
  -e MINIO_ENDPOINT=minio:9000 \
  minio-client python scripts/create_parquet.py
```

## 📊 Veri Formatları

### CSV → Parquet
- Sıkıştırma: ~60-80% daha küçük
- Okuma hızı: ~10x daha hızlı
- Column-based storage

### Iceberg Tables
- Schema evolution
- Time travel queries
- ACID transactions
- Efficient updates/deletes

## 📁 Data Lake Yapısı

```
raw-data/
  samples/
    ├── customers.csv
    ├── products.json
    └── sales.csv

processed-data/
  tables/
    ├── customers/
    │   └── customers.parquet
    ├── products/
    │   └── products.parquet
    └── sales/
        ├── year=2024/
        │   └── month=1/
        │       └── data.parquet

archive/
  2024/
    ├── 01/
    └── 02/
```

## 🔗 Kaynaklar
- [MinIO Docs](https://min.io/docs/minio/linux/index.html)
- [Python SDK](https://min.io/docs/minio/linux/developers/python/minio-py.html)
- [Apache Iceberg](https://iceberg.apache.org/)
- [Parquet Format](https://parquet.apache.org/)