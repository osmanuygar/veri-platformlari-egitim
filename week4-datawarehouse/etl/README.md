# ETL Service - Extract, Transform, Load

Week 4 Data Warehouse projesi için ETL (Extract, Transform, Load) servisi.

## 📁 Klasör Yapısı

```
etl/
├── README.md              # Bu dosya
├── Dockerfile            # ETL container image
├── requirements.txt      # Python dependencies
└── python/              # Python ETL scripts
    ├── config.py        # Yapılandırma modülü
    ├── extract.py       # Extract: OLTP'den veri çekme
    ├── transform.py     # Transform: Veri dönüştürme
    ├── load.py          # Load: OLAP'a ve Data Lake'e yükleme
    └── full_pipeline.py # Tam pipeline orchestration
```

## 🎯 ETL Süreci

### 1. **Extract (Çıkarma)**
OLTP veritabanından veri çeker:
- `customers` - Müşteri bilgileri
- `products` - Ürün katalog
- `categories` - Kategori hiyerarşisi
- `orders` - Sipariş başlıkları
- `order_items` - Sipariş detayları
- `addresses` - Adres bilgileri
- `payment_methods` - Ödeme yöntemleri

### 2. **Transform (Dönüştürme)**
Verileri dimensional model'e dönüştürür:

#### Dimension Tables
- `dim_customer` - Müşteri dimensiyonu
- `dim_product` - Ürün dimensiyonu
- `dim_category` - Kategori dimensiyonu
- `dim_date` - Tarih dimensiyonu

#### Fact Tables
- `fact_sales` - Satış fact tablosu
- `fact_inventory` - Envanter snapshot'ı

### 3. **Load (Yükleme)**
İki hedefe yükler:
- **OLAP Database**: PostgreSQL data warehouse
- **Data Lake**: MinIO/S3 (Parquet format)

## 🚀 Kullanım

### Tek Seferlik Çalıştırma

```bash
# Docker Compose ile
docker-compose run --rm etl

# Manuel olarak
cd python
python full_pipeline.py
```

### Sürekli Çalıştırma (Scheduled)

```bash
# Docker Compose ile (5 dakikada bir)
docker-compose --profile etl up -d etl

# Manuel olarak
cd python
ETL_RUN_MODE=continuous python full_pipeline.py
```

### Environment Variables

```bash
# OLTP (Source)
OLTP_HOST=postgres-oltp
OLTP_PORT=5432
OLTP_DB=ecommerce_oltp
OLTP_USER=oltp_user
OLTP_PASSWORD=oltp_pass123

# OLAP (Target)
OLAP_HOST=postgres-olap
OLAP_PORT=5432
OLAP_DB=ecommerce_dw
OLAP_USER=olap_user
OLAP_PASSWORD=olap_pass123

# MinIO (Data Lake)
MINIO_ENDPOINT=minio:9000
MINIO_ROOT_USER=minio_admin
MINIO_ROOT_PASSWORD=minio_password123
MINIO_BUCKET=datawarehouse

# ETL Settings
ETL_RUN_MODE=continuous        # once | continuous
ETL_INTERVAL_SECONDS=300       # 5 minutes
ETL_BATCH_SIZE=1000
```

## 📊 Modüller Detayı

### config.py
Yapılandırma yönetimi:
- Database bağlantı ayarları
- MinIO/S3 yapılandırması
- ETL çalışma modu ve aralıkları
- Logging setup

```python
from config import config, logger

# Kullanım
print(config.oltp.host)
logger.info("ETL started")
```

### extract.py
OLTP'den veri çekme:
- Tam tablo çekme (full load)
- Artırımlı çekme (incremental load)
- Özel sorgular
- Tablo istatistikleri

```python
from extract import OLTPExtractor

extractor = OLTPExtractor()
extractor.connect()

# Tüm müşterileri çek
customers = extractor.extract_customers()

# Son 24 saatteki değişiklikleri çek
new_orders = extractor.extract_incremental(
    'orders', 
    'updated_at',
    last_extract_time
)

extractor.disconnect()
```

### transform.py
Veri dönüştürme işlemleri:
- OLTP → Dimensional Model dönüşümü
- Hesaplanmış alanlar ekleme
- Veri temizleme ve normalizasyon
- Validasyon

```python
from transform import DataTransformer

transformer = DataTransformer()

# Müşteri dimensiyonuna dönüştür
dim_customer = transformer.transform_dim_customer(customers_df)

# Satış fact tablosuna dönüştür
fact_sales = transformer.transform_fact_sales(order_items_df)

# Tüm dönüşümleri yap
all_transformed = transformer.transform_all(extracted_data)

# Validasyon
is_valid = transformer.validate_transformations(all_transformed)
```

### load.py
OLAP ve Data Lake'e yükleme:
- Bulk insert (hızlı yükleme)
- COPY komutu (çok büyük veri için)
- Upsert (güncelleme/ekleme)
- Parquet formatında arşivleme

```python
from load import ETLLoader

loader = ETLLoader()
loader.connect_all()

# Dimension yükle
loader.load_dimension(dim_customer_df, 'dim_customer')

# Fact yükle
loader.load_fact(fact_sales_df, 'fact_sales')

# Tümünü yükle
loader.load_all(transformed_data)

loader.disconnect_all()
```

### full_pipeline.py
Tam ETL orchestration:
- Connect → Extract → Transform → Load → Disconnect
- Hata yönetimi
- Loglama
- İstatistikler

```python
from full_pipeline import ETLPipeline

pipeline = ETLPipeline()

# Tek seferlik çalıştır
pipeline.run_once()

# Sürekli çalıştır (5 dakikada bir)
pipeline.run_continuous(interval_seconds=300)
```

## 🔍 ETL İzleme

### Console Logs
ETL çalışırken renkli loglar görürsünüz:
- 🟢 **INFO**: Normal işlemler
- 🟡 **WARNING**: Uyarılar
- 🔴 **ERROR**: Hatalar
- ✓ Başarılı işlemler
- ✗ Başarısız işlemler

### Log Dosyaları
```bash
# ETL loglarını görüntüle
docker logs -f etl_service

# Son 100 satır
docker logs --tail 100 etl_service

# Belirli tarihten itibaren
docker logs --since "2024-01-01T00:00:00" etl_service
```

## 📈 Performans

### Optimize Edilmiş Yükleme Stratejileri

1. **Küçük veri (<10K satır)**: Bulk insert
2. **Büyük veri (>10K satır)**: COPY komutu
3. **Artırımlı**: Upsert ile merge

### Benchmark (örnek)
```
Extract Phase:   ~5 seconds  (50K rows)
Transform Phase: ~3 seconds  (data processing)
Load Phase:      ~7 seconds  (OLAP + Data Lake)
Total:          ~15 seconds
```

## 🧪 Test Etme

### Manuel Test

```bash
# Extract modülünü test et
cd python
python extract.py

# Transform modülünü test et
python transform.py

# Load modülünü test et
python load.py

# Tam pipeline'ı test et
python full_pipeline.py
```

### Docker ile Test

```bash
# Tek seferlik test
docker-compose run --rm etl

# Logları takip et
docker-compose --profile etl up etl
```

## 🛠️ Troubleshooting

### Problem: Bağlantı hatası
```bash
# Database'lerin hazır olduğunu kontrol et
docker ps | grep postgres

# Network bağlantısını test et
docker exec etl_service ping postgres-oltp
```

### Problem: Transformation hatası
```python
# Veri kalitesini kontrol et
df.info()
df.describe()
df.isnull().sum()
```

### Problem: Load hatası
```bash
# OLAP database'i kontrol et
docker exec -it postgres_olap psql -U olap_user -d ecommerce_dw

# Tablo yapısını kontrol et
\d+ dim_customer
```

## 🔐 Güvenlik

### Best Practices
1. ✅ Environment variables kullan (şifreleri hardcode etme)
2. ✅ `.env` dosyasını `.gitignore`'a ekle
3. ✅ Production'da güçlü şifreler kullan
4. ✅ MinIO için SSL aktif et (production)
5. ✅ Database kullanıcılarına minimum yetki ver

### Production Checklist
```bash
# .env dosyasını güncelle
OLTP_PASSWORD=<strong-password>
OLAP_PASSWORD=<strong-password>
MINIO_ROOT_PASSWORD=<strong-password>

# SSL için MinIO yapılandır
MINIO_SECURE=true
```

## 📚 Öğrenme Kaynakları

### ETL Best Practices
- [Kimball Group - ETL Best Practices](https://www.kimballgroup.com/)
- [Data Warehouse Toolkit](https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/books/)

### Python Data Engineering
- [Pandas Documentation](https://pandas.pydata.org/)
- [PostgreSQL COPY Command](https://www.postgresql.org/docs/current/sql-copy.html)
- [MinIO Python SDK](https://min.io/docs/minio/linux/developers/python/minio-py.html)

## 🎓 Alıştırmalar

### Temel Seviye
1. ✏️ Yeni bir extract fonksiyonu ekle (örn: `extract_top_customers`)
2. ✏️ Transform'da yeni bir calculated field ekle
3. ✏️ Log mesajlarını özelleştir

### Orta Seviye
4. ✏️ Incremental load stratejisi ekle
5. ✏️ Hata durumunda retry mekanizması ekle
6. ✏️ Data quality check'leri ekle

### İleri Seviye
7. ✏️ Parallel processing ekle (çoklu tablo aynı anda)
8. ✏️ Change Data Capture (CDC) implementasyonu
9. ✏️ Slowly Changing Dimensions (SCD Type 2) ekle
10. ✏️ Airflow DAG'e dönüştür

## 🤝 Katkıda Bulunma

Bu ETL servisini geliştirmek için:
1. Yeni transformation logic'leri ekleyin
2. Performans iyileştirmeleri yapın
3. Daha fazla veri kalite kontrolü ekleyin
4. Dokümantasyonu iyileştirin

## 📝 Notlar

### Önemli Hatırlatmalar
- 🔴 **Production'da**: Incremental load kullanın (full load maliyetli)
- 🟡 **Data Quality**: Her zaman transformation sonrası validasyon yapın
- 🟢 **Monitoring**: Loglara dikkat edin, başarı/başarısızlık oranlarını takip edin
- 🔵 **Backup**: Data Lake'de tutulan parquet dosyaları backup olarak kullanılabilir
