# Hafta 1: Veri Dünyasına Giriş

## 📚 İçindekiler

1. [Veri Nedir?](#1-veri-nedir)
2. [Veri Türleri ve Sınıflandırması](#2-veri-türleri-ve-sınıflandırması)
3. [Veri Kaynakları](#3-veri-kaynakları)
4. [Veri Platformlarının Tarihsel Evrimi](#4-veri-platformlarının-tarihsel-evrimi)
5. [Pratik Uygulamalar](#5-pratik-uygulamalar)
6. [Alıştırmalar](#6-alıştırmalar)
7. [Kaynaklar](#7-kaynaklar)

---

## 1. Veri Nedir?

### 1.1 Temel Tanım

**Veri (Data):** Ham gerçekler, sayılar, metinler veya gözlemler. Tek başına anlamsız olabilir, işlendiğinde anlam kazanır.

```
Veri → İşleme → Bilgi → Analiz → Bilgi (Wisdom)
```

#### Hiyerarşi:
- **Veri:** 25, 30, 28
- **Bilgi:** Son 3 günün sıcaklıkları: 25°C, 30°C, 28°C
- **Bilgi:** Ortalama sıcaklık 27.6°C, artış trendi var
- **Bilgi:** Klima açılmalı ve enerji tasarrufu planı yapılmalı

### 1.2 Günümüzde Verinin Önemi

#### İstatistikler:
- Her gün dünyada **2.5 exabyte** (2.5 milyon terabyte) veri üretiliyor
- Dünyadaki verinin **90%'ı** son 2 yılda üretildi
- 2025'te global veri hacmi **175 zettabyte**'a ulaşacak
- İşletmelerin **%80'i** veri odaklı kararlar almak istiyor

#### Veri Neden Değerli?
1. **Rekabet Avantajı:** Veriye dayalı kararlar %5-6 daha fazla üretkenlik sağlıyor
2. **Müşteri Deneyimi:** Kişiselleştirme ile %20 satış artışı
3. **Operasyonel Verimlilik:** Tahmine dayalı bakım ile %12 maliyet tasarrufu
4. **İnovasyon:** Yeni ürün ve hizmet geliştirme
5. **Risk Yönetimi:** Fraud detection ve güvenlik

> "Veri 21. yüzyılın petrolüdür" - Clive Humby

---

## 2. Veri Türleri ve Sınıflandırması

### 2.1 Yapısal Veri (Structured Data)

**Tanım:** Belirli bir şema ve formatta organize edilmiş, satır ve sütunlardan oluşan veri.

#### Özellikler:
- ✅ Önceden tanımlanmış veri tipleri (integer, string, date)
- ✅ İlişkisel veritabanlarında saklanır
- ✅ SQL ile kolayca sorgulanabilir
- ✅ Analiz ve raporlama kolay
- ❌ Esneklik düşük, şema değişiklikleri zor

#### Örnekler:
```sql
-- Müşteri Tablosu
CREATE TABLE musteriler (
    id INT PRIMARY KEY,
    ad VARCHAR(50),
    soyad VARCHAR(50),
    email VARCHAR(100),
    dogum_tarihi DATE,
    bakiye DECIMAL(10,2)
);
```

**Kullanım Alanları:**
- Excel tabloları
- İlişkisel veritabanları (MySQL, PostgreSQL)
- CRM sistemleri (Salesforce)
- ERP sistemleri (SAP)
- Finans kayıtları

### 2.2 Yarı-Yapısal Veri (Semi-Structured Data)

**Tanım:** Kısmen organize edilmiş, esnek şemalı veri. Metadata veya etiketler içerir.

#### Özellikler:
- ✅ Self-describing (kendi kendini tanımlayan)
- ✅ Esnek yapı, şema değişiklikleri kolay
- ✅ Hiyerarşik veya nested yapılar
- ✅ NoSQL veritabanlarında saklanabilir
- ❌ Geleneksel SQL ile sorgulamak zor olabilir

#### JSON Örneği:
```json
{
  "musteri_id": 12345,
  "ad": "Ahmet",
  "soyad": "Yılmaz",
  "iletisim": {
    "email": "ahmet@example.com",
    "telefon": "+90 532 123 4567",
    "adres": {
      "sehir": "Istanbul",
      "ilce": "Kadikoy",
      "posta_kodu": "34710"
    }
  },
  "siparisler": [
    {
      "siparis_no": "ORD-001",
      "tarih": "2025-01-15",
      "tutar": 450.00
    },
    {
      "siparis_no": "ORD-002",
      "tarih": "2025-01-20",
      "tutar": 230.50
    }
  ]
}
```

#### XML Örneği:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<musteri>
    <id>12345</id>
    <ad>Ahmet</ad>
    <soyad>Yılmaz</soyad>
    <iletisim>
        <email>ahmet@example.com</email>
        <telefon>+90 532 123 4567</telefon>
    </iletisim>
</musteri>
```

**Kullanım Alanları:**
- JSON/XML dosyaları
- API yanıtları
- Log dosyaları
- Config dosyaları
- NoSQL veritabanları (MongoDB)

### 2.3 Yapısal Olmayan Veri (Unstructured Data)

**Tanım:** Önceden tanımlanmış bir yapısı olmayan, serbest format veri.

#### Özellikler:
- ✅ En yaygın veri türü (%80-90)
- ✅ Zengin içerik (metin, görüntü, ses, video)
- ❌ Analiz etmek zor ve maliyetli
- ❌ Depolama gereksinimi yüksek
- ❌ Geleneksel veritabanlarında saklanamaz

#### Örnekler:
1. **Metinsel İçerik:**
   - E-postalar
   - Word belgeleri
   - PDF dosyaları
   - Sosyal medya gönderileri
   - Blog yazıları

2. **Multimedya:**
   - Fotoğraflar
   - Videolar
   - Ses kayıtları
   - Podcast'ler

3. **Diğer:**
   - PowerPoint sunumları
   - Tarayıcı geçmişi
   - IoT sensor ham verileri

**Teknolojiler:**
- Object Storage (AWS S3, Azure Blob)
- Data Lake
- Full-text search (Elasticsearch)
- Computer Vision (görüntü analizi)
- NLP (doğal dil işleme)

### 2.4 Karşılaştırma Tablosu

| Özellik | Yapısal | Yarı-Yapısal | Yapısal Olmayan |
|---------|---------|--------------|-----------------|
| **Şema** | Sabit | Esnek | Yok |
| **Depolama** | RDBMS | NoSQL, Files | Object Storage, Data Lake |
| **Sorgulama** | SQL | JSON/XML parsers | Full-text search, AI |
| **Oran** | ~10% | ~10% | ~80% |
| **Analiz** | Kolay | Orta | Zor |
| **Örnek** | Excel | JSON | Video |

---

## 3. Veri Kaynakları

### 3.1 İç Kaynaklar (Internal Sources)

#### 3.1.1 Kurumsal Sistemler
1. **ERP (Enterprise Resource Planning)**
   - SAP, Oracle ERP
   - Finans, İnsan Kaynakları, Üretim verileri
   - Yüksek veri kalitesi, doğruluğu

2. **CRM (Customer Relationship Management)**
   - Salesforce, Microsoft Dynamics
   - Müşteri bilgileri, satış, destek kayıtları
   - Müşteri yaşam döngüsü analizi

3. **İşlem Sistemleri (Transactional Systems)**
   - POS (Point of Sale) sistemleri
   - E-ticaret platformları
   - Banka işlemleri
   - Gerçek zamanlı veri

4. **Operasyonel Veritabanları**
   - Üretim veritabanları
   - Günlük operasyonlar
   - OLTP sistemleri

#### 3.1.2 IoT ve Sensörler
- Fabrika sensörleri (sıcaklık, basınç, titreşim)
- Akıllı cihazlar (smartwatch, fitness tracker)
- Araç telematiği
- Akıllı bina sistemleri
- **Özellik:** Yüksek hacim, gerçek zamanlı

#### 3.1.3 Log Dosyaları
```log
2025-01-29 10:15:32 INFO User logged in: user_id=12345
2025-01-29 10:15:45 DEBUG Query executed: SELECT * FROM products
2025-01-29 10:16:01 ERROR Database connection failed: timeout
2025-01-29 10:16:15 WARN High memory usage: 85%
```

**Türler:**
- Uygulama logları
- Web server logları (Apache, Nginx)
- Veritabanı logları
- Güvenlik logları

### 3.2 Dış Kaynaklar (External Sources)

#### 3.2.1 API'ler (Application Programming Interfaces)
```python
import requests

# Twitter API örneği
response = requests.get(
    'https://api.twitter.com/2/tweets/search/recent',
    params={'query': 'data science'},
    headers={'Authorization': 'Bearer YOUR_TOKEN'}
)
tweets = response.json()
```

**Popüler API'ler:**
- Twitter API (sosyal medya verileri)
- Google Maps API (konum verileri)
- OpenWeather API (hava durumu)
- Alpha Vantage (finans verileri)
- REST ve GraphQL API'ler

#### 3.2.2 Web Scraping
```python
from bs4 import BeautifulSoup
import requests

# Basit web scraping örneği
url = 'https://example.com/products'
response = requests.get(url)
soup = BeautifulSoup(response.content, 'html.parser')

products = []
for item in soup.find_all('div', class_='product'):
    name = item.find('h2').text
    price = item.find('span', class_='price').text
    products.append({'name': name, 'price': price})
```

**Dikkat:** 
- Robots.txt dosyasına uyun
- Rate limiting uygulayın
- Telif hakları ve gizlilik

#### 3.2.3 Açık Veri (Open Data)
**Kamu Kaynakları:**
- data.gov (ABD)
- data.gov.tr (Türkiye)
- Eurostat (Avrupa)
- Dünya Bankası
- WHO (Dünya Sağlık Örgütü)

**Veri Setleri:**
- Nüfus istatistikleri
- Ekonomik göstergeler
- Sağlık verileri
- Ulaşım verileri
- Eğitim istatistikleri

#### 3.2.4 Sosyal Medya
- Twitter: Gerçek zamanlı haber, duygu analizi
- Facebook: Kullanıcı davranışları
- Instagram: Görsel içerik analizi
- LinkedIn: Profesyonel network analizi
- Reddit: Topluluk analizleri

#### 3.2.5 Üçüncü Parti Veri Sağlayıcılar
- Nielsen (pazar araştırması)
- Experian (kredi verileri)
- Bloomberg (finans verileri)
- Yelp (işletme değerlendirmeleri)

### 3.3 Veri Toplama Yöntemleri

#### Gerçek Zamanlı (Real-Time / Streaming)
- **Özellik:** Anlık veri akışı
- **Teknolojiler:** Apache Kafka, Amazon Kinesis
- **Kullanım:** Borsa, IoT, fraud detection
- **Latency:** Milisaniyeler

#### Toplu (Batch)
- **Özellik:** Belirli aralıklarla toplanan veri
- **Teknolojiler:** Cron jobs, Apache Airflow
- **Kullanım:** Günlük raporlar, ETL
- **Latency:** Saatler/günler

---

## 4. Veri Platformlarının Tarihsel Evrimi

### 4.1 1960'lar - İlk Veritabanı Sistemleri

#### Hiyerarşik Veritabanları
- **IBM IMS (Information Management System)** - 1966
- Tree yapısı: Parent-child ilişkileri
- Sadece mainframe bilgisayarlarda
- Apollo programı için geliştirildi

```
         Müşteri (Parent)
           /        \
      Sipariş    Sipariş (Children)
        /           \
    Ürün          Ürün
```

#### Ağ Veritabanları (Network Databases)
- **CODASYL** standardı
- Daha esnek ilişkiler (many-to-many)
- Karmaşık navigasyon

**Sorunlar:**
- Esneklik düşük
- Programlama karmaşık
- Veri bağımsızlığı yok

### 4.2 1970-1980'ler - İlişkisel Veritabanları Devrimi

#### Edgar F. Codd - İlişkisel Model (1970)
**Manifesto:** "A Relational Model of Data for Large Shared Data Banks"

**Temel Prensipler:**
1. Veriler tablolarda (relations) saklanır
2. Matematiksel küme teorisi
3. Veri bağımsızlığı
4. Bildirimsel sorgulama (SQL)

#### SQL'in Doğuşu
```sql
-- İlk SQL sorguları (1970'ler)
SELECT customer_name, order_total
FROM customers, orders
WHERE customers.id = orders.customer_id
AND order_date > '1975-01-01';
```

#### Önemli Sistemler:
- **Oracle Database** (1979) - Larry Ellison
- **IBM DB2** (1983)
- **Microsoft SQL Server** (1989)
- **PostgreSQL** (1986 - akademik, 1996 açık kaynak)

#### ACID Kavramının Standardizasyonu
- **1983:** Jim Gray tarafından formalize edildi
- Transaction güvenliği
- Veri tutarlılığı garantisi

**Etki:**
- Veri yönetiminde devrim
- Endüstri standardı
- Günümüzde hala dominant

### 4.3 1990-2000'ler - Veri Ambarları ve İş Zekası

#### Data Warehouse Çağı
**Bill Inmon (1990):** "Building the Data Warehouse"
- Subject-oriented
- Integrated
- Time-variant
- Non-volatile

#### OLAP Küpleri
- Çok boyutlu analiz
- Slice, dice, drill-down
- Microsoft Analysis Services
- Oracle OLAP

#### ETL Araçları
- Informatica
- IBM DataStage
- Oracle Data Integrator

#### İş Zekası Patlaması
- Crystal Reports
- Business Objects
- Cognos
- MicroStrategy

**Kullanım Senaryoları:**
- Satış analizleri
- Finansal raporlama
- Executive dashboards

### 4.4 2000'ler Sonrası - Big Data ve NoSQL

#### Big Data'nın Doğuşu

**2003-2004: Google Makaleleri**
1. **Google File System (GFS)**
2. **MapReduce**
3. **BigTable**

```
Veri Hacmi: Gigabyte → Terabyte → Petabyte
```

**3V Modeli (Doug Laney, 2001):**
1. **Volume:** Veri miktarı (petabyte'lar)
2. **Velocity:** Veri hızı (gerçek zamanlı)
3. **Variety:** Veri çeşitliliği (yapısal, yarı, yapısal olmayan)

#### Apache Hadoop (2006)
- Açık kaynak MapReduce implementasyonu
- HDFS (Hadoop Distributed File System)
- Commodity hardware üzerinde çalışır
- Yahoo!, Facebook'ta kullanımı

#### NoSQL Hareketi
**2009:** "NoSQL" terimi popülerleşir

**Motivasyon:**
- Web ölçeğinde uygulamalar (Google, Facebook, Amazon)
- Yatay ölçeklenebilirlik ihtiyacı
- Esnek şema gereksinimleri
- ACID'den ödün verme (CAP teoremi)

**Önemli NoSQL Sistemleri:**
- **MongoDB** (2009) - Document Store
- **Cassandra** (2008, Apache 2010) - Column-family
- **Redis** (2009) - Key-Value
- **Neo4j** (2007) - Graph Database

### 4.5 2010'lar - Bulut ve Modern Mimariler

#### Bulut Veri Platformları
**2006:** Amazon AWS lansmanı
- **S3:** Object storage
- **EC2:** Compute
- **RDS:** Managed databases

**DBaaS (Database as a Service):**
- Amazon RDS, DynamoDB, Redshift
- Google BigQuery, Cloud Spanner
- Azure SQL Database, Cosmos DB

**Avantajlar:**
- Elastik ölçeklenebilirlik
- Kullandığın kadar öde
- Yönetim yükü azalır

#### Data Lake Kavramı (2010)
**James Dixon (Pentaho):** "Data Pond" terimi

**Özellikler:**
- Ham veri depolama
- Schema-on-read
- Düşük maliyet (object storage)
- Big Data analytics

**Teknolojiler:**
- Amazon S3
- Azure Data Lake
- Hadoop HDFS

#### Streaming ve Real-Time
- **Apache Kafka** (2011, LinkedIn)
- **Apache Spark** (2012, Berkeley)
- **Apache Flink** (2014)

#### NewSQL (2010'lar)
- **Google Spanner** (2012)
- **CockroachDB** (2015)
- **TiDB** (2016)

**Amaç:** ACID + Ölçeklenebilirlik

### 4.6 2015-2025 - Modern Veri Ekosistemi

#### Data Lakehouse (2020+)
- Data Lake + Data Warehouse
- **Delta Lake** (Databricks)
- **Apache Iceberg** (Netflix)
- **Apache Hudi** (Uber)

#### Modern Data Stack
- **Ingestion:** Fivetran, Airbyte
- **Storage:** Snowflake, BigQuery, Databricks
- **Transformation:** dbt
- **Visualization:** Looker, Tableau, Power BI
- **Orchestration:** Apache Airflow, Prefect

#### Data Mesh (2019)
**Zhamak Dehghani:** Merkeziyetsiz veri sahipliği
- Domain-oriented
- Data as a product
- Self-serve platform
- Federated governance

#### AI/ML Entegrasyonu
- AutoML platformları
- Feature stores
- ML pipelines
- MLOps

#### Gerçek Zamanlı Analitik
- Materialized views
- Streaming SQL
- Lambda/Kappa mimarileri

### 4.7 Evrim Özeti Timeline

```
1960 ━━━━━━ Hiyerarşik/Ağ DB
1970 ━━━━━━ İlişkisel Model & SQL
1980 ━━━━━━ RDBMS Olgunlaşması
1990 ━━━━━━ Data Warehouse & OLAP
2000 ━━━━━━ Big Data & Hadoop
2005 ━━━━━━ NoSQL Hareketi
2010 ━━━━━━ Cloud & Data Lake
2015 ━━━━━━ Streaming & Real-time
2020 ━━━━━━ Lakehouse & Data Mesh
2025 ━━━━━━ AI-Native Platforms
```

---

## 5. Pratik Uygulamalar

### 5.1 Veri Türlerini Keşfetme

#### Python ile CSV Okuma (Yapısal Veri)
```python
import pandas as pd

# CSV dosyasını oku
df = pd.read_csv('customers.csv')

# İlk 5 satırı görüntüle
print(df.head())

# Veri tiplerine bak
print(df.dtypes)

# Temel istatistikler
print(df.describe())

# Eksik değerleri kontrol et
print(df.isnull().sum())
```

#### JSON ile Çalışma (Yarı-Yapısal Veri)
```python
import json

# JSON dosyasını oku
with open('api_response.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# İçeriği görüntüle
print(json.dumps(data, indent=2, ensure_ascii=False))

# Nested verilere erişim
print(data['musteri']['iletisim']['email'])

# DataFrame'e dönüştür
df = pd.json_normalize(data)
print(df.head())

# Nested JSON'u düzleştirme
flat_df = pd.json_normalize(
    data,
    record_path=['siparisler', 'urunler'],
    meta=['ad', 'soyad', ['iletisim', 'email']],
    meta_prefix='musteri_'
)
```

### 5.2 Veri Kalitesi Kontrolü

```python
import pandas as pd
import numpy as np

def veri_kalitesi_raporu(df):
    """Kapsamlı veri kalitesi raporu"""
    
    print("=" * 50)
    print("VERİ KALİTESİ RAPORU")
    print("=" * 50)
    
    # 1. Temel Bilgiler
    print(f"\n1. GENEL BİLGİLER")
    print(f"   Toplam Satır: {len(df)}")
    print(f"   Toplam Sütun: {len(df.columns)}")
    print(f"   Bellek Kullanımı: {df.memory_usage(deep=True).sum() / 1024**2:.2f} MB")
    
    # 2. Eksik Değerler
    print(f"\n2. EKSİK DEĞERLER")
    eksik = df.isnull().sum()
    eksik_oran = (eksik / len(df) * 100).round(2)
    eksik_rapor = pd.DataFrame({
        'Eksik Sayısı': eksik,
        'Eksik Oranı (%)': eksik_oran
    })
    print(eksik_rapor[eksik_rapor['Eksik Sayısı'] > 0])
    
    # 3. Tekrar Eden Kayıtlar
    print(f"\n3. TEKRAR EDEN KAYITLAR")
    duplicates = df.duplicated().sum()
    print(f"   Tekrar Eden Satır: {duplicates} ({duplicates/len(df)*100:.2f}%)")
    
    # 4. Veri Tipleri
    print(f"\n4. VERİ TİPLERİ")
    print(df.dtypes.value_counts())
    
    # 5. Sayısal Sütunlar için İstatistikler
    print(f"\n5. SAYISAL SÜTUN İSTATİSTİKLERİ")
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    if len(numeric_cols) > 0:
        print(df[numeric_cols].describe())
    
    # 6. Kategorik Sütunlar
    print(f"\n6. KATEGORİK SÜTUNLAR")
    categorical_cols = df.select_dtypes(include=['object']).columns
    for col in categorical_cols[:5]:  # İlk 5 kategorik sütun
        print(f"\n   {col}:")
        print(f"   Benzersiz Değer: {df[col].nunique()}")
        print(f"   En Sık 3 Değer:\n{df[col].value_counts().head(3)}")
    
    # 7. Outlier Kontrolü (IQR yöntemi)
    print(f"\n7. OUTLIER KONTROLÜ (IQR)")
    for col in numeric_cols:
        Q1 = df[col].quantile(0.25)
        Q3 = df[col].quantile(0.75)
        IQR = Q3 - Q1
        lower_bound = Q1 - 1.5 * IQR
        upper_bound = Q3 + 1.5 * IQR
        outliers = df[(df[col] < lower_bound) | (df[col] > upper_bound)]
        if len(outliers) > 0:
            print(f"   {col}: {len(outliers)} outlier ({len(outliers)/len(df)*100:.2f}%)")

# Kullanım
df = pd.read_csv('sample_data.csv')
veri_kalitesi_raporu(df)
```