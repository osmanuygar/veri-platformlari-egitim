# Apache Superset - BI & Data Visualization

Apache Superset ile modern BI dashboard'ları ve veri görselleştirme.

## 🚀 Hızlı Başlangıç

### 1. Superset'i Başlat

```bash
# Superset klasörüne git
cd superset

# Superset'i başlat
docker-compose up -d

# İlk kurulum (kullanıcı oluşturma, örnekler)
docker-compose exec superset bash scripts/init_superset.sh

# Logları izle
docker-compose logs -f superset
```

### 2. Web UI'ya Eriş

```
URL: http://localhost:8088
Kullanıcı: admin
Şifre: admin123
```

### 3. İlk Bağlantı - OLAP Database

Dashboard'da **Settings > Database Connections > + Database** tıklayın:

```
Database: PostgreSQL
Display Name: OLAP Data Warehouse
SQLAlchemy URI: postgresql://olap_user:olap_pass123@postgres-olap:5432/ecommerce_dw
```

Test Connection → Connect

## 📊 Temel Kullanım

### Dataset Ekleme

1. **Data > Datasets > + Dataset**
2. Database seç: `OLAP Data Warehouse`
3. Schema: `public`
4. Table seç: `fact_sales`, `dim_customer`, vb.
5. **Add**

### Chart Oluşturma

1. **Charts > + Chart**
2. Dataset seç (örn: `fact_sales`)
3. Visualization type seç:
   - **Bar Chart**: Kategori bazında satış
   - **Line Chart**: Zaman serisi
   - **Pie Chart**: Dağılım
   - **Table**: Detaylı veri
4. Metrics ve Filters ayarla
5. **Save**

### Dashboard Oluşturma

1. **Dashboards > + Dashboard**
2. İsim ver: "Sales Dashboard"
3. Chart'ları sürükle-bırak
4. Layout düzenle
5. **Save**

## 🎨 Örnek Dashboard'lar

### 1. Sales Overview Dashboard

**Charts:**
- Total Revenue (Big Number)
- Daily Sales Trend (Line Chart)
- Top Products (Bar Chart)
- Sales by Category (Pie Chart)

### 2. Customer Analytics Dashboard

**Charts:**
- Customer Count (Big Number)
- Customer Segment Distribution (Pie Chart)
- Top Customers by Revenue (Table)
- Customer Growth (Line Chart)

### 3. Product Performance Dashboard

**Charts:**
- Total Products (Big Number)
- Category Performance (Bar Chart)
- Stock Status (Pie Chart)
- Price Distribution (Histogram)

## 💻 SQL ile Custom Query

### SQL Lab Kullanımı

1. **SQL > SQL Lab**
2. Database seç: `OLAP Data Warehouse`
3. Schema: `public`
4. Query yaz:

```sql
-- Günlük satış toplamı
SELECT 
    d.date,
    COUNT(DISTINCT f.order_id) as order_count,
    SUM(f.net_amount) as total_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.date
ORDER BY d.date DESC
LIMIT 30;
```

5. **Run** → Chart oluştur

### Custom Dataset (SQL Query)

1. **Data > Datasets > + Dataset**
2. **Virtual** sekmesine geç
3. SQL query yaz:

```sql
SELECT 
    p.product_name,
    p.category_name,
    SUM(f.quantity) as total_sold,
    SUM(f.net_amount) as total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name, p.category_name
```

4. **Save & Explore**

## 🔧 Database Bağlantıları

### OLAP (Data Warehouse)
```
postgresql://olap_user:olap_pass123@postgres-olap:5432/ecommerce_dw
```

### OLTP (Opsiyonel - Read-only için)
```
postgresql://oltp_user:oltp_pass123@postgres-oltp:5432/ecommerce_oltp
```

### MinIO/S3 (Parquet dosyaları için - İleri seviye)
Presto/Trino ile entegrasyon gerekir.

## 📈 Visualization Types

### Basit Görselleştirmeler
- **Big Number**: KPI'lar (Toplam satış, müşteri sayısı)
- **Table**: Detaylı veri listesi
- **Pivot Table**: Çok boyutlu analiz

### Chart'lar
- **Bar Chart**: Kategori karşılaştırmaları
- **Line Chart**: Zaman serisi trendleri
- **Pie Chart**: Oran/dağılım
- **Area Chart**: Kümülatif trendler

### İleri Seviye
- **Heatmap**: İlişki matrisleri
- **Scatter Plot**: Korelasyon analizi
- **Box Plot**: Dağılım analizi
- **Sankey Diagram**: Akış analizi

## 🎯 Dashboard Best Practices

### 1. Yapı
- Üstte KPI'lar (Big Numbers)
- Ortada trendler (Line/Bar Charts)
- Altta detaylar (Tables)

### 2. Renkler
- Tutarlı renk paleti kullan
- Önemli verileri vurgula
- Yeşil = iyi, Kırmızı = dikkat

### 3. Filtreler
- Tarih aralığı filtresi ekle
- Kategori/segment filtreleri
- Dashboard-level filters kullan

### 4. Performance
- Büyük veri için cache aktif et
- SQL'i optimize et (indexler)
- Gereksiz metric'lerden kaçın

## 🔒 Güvenlik ve Kullanıcılar

### Yeni Kullanıcı Ekleme

```bash
# Container'a gir
docker exec -it superset bash

# Kullanıcı oluştur
superset fab create-user \
    --username john \
    --firstname John \
    --lastname Doe \
    --email john@example.com \
    --role Alpha \
    --password userpass123
```

### Roller
- **Admin**: Tüm yetkiler
- **Alpha**: Dashboard ve chart oluşturma
- **Gamma**: Sadece görüntüleme

## 🐳 Docker Compose Detayları

### Servisler
- **superset**: Superset web sunucusu (port 8088)
- **superset-init**: İlk kurulum servisi
- **postgres-superset**: Superset metadata database'i

### Volume'ler
- `superset_data`: Superset home dizini
- `postgres_superset_data`: PostgreSQL verileri

## 🔍 Troubleshooting

### Superset başlamıyor
```bash
# Logları kontrol et
docker-compose logs superset

# Database migration
docker-compose exec superset superset db upgrade

# Yeniden başlat
docker-compose restart superset
```

### Database bağlantı hatası
```bash
# Network kontrolü
docker exec superset ping postgres-olap

# Connection string test et
docker exec superset python -c "
from sqlalchemy import create_engine
engine = create_engine('postgresql://olap_user:olap_pass123@postgres-olap:5432/ecommerce_dw')
print(engine.connect())
"
```

### Cache temizleme
```bash
docker-compose exec superset superset clear-cache
```

## 📚 Örnek Queries

### Top 10 Ürün
```sql
SELECT 
    p.product_name,
    SUM(f.quantity) as total_sold,
    SUM(f.net_amount) as revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY revenue DESC
LIMIT 10;
```

### Aylık Satış Trendi
```sql
SELECT 
    TO_CHAR(d.date, 'YYYY-MM') as month,
    SUM(f.net_amount) as revenue,
    COUNT(DISTINCT f.order_id) as order_count
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY TO_CHAR(d.date, 'YYYY-MM')
ORDER BY month;
```

### Kategori Performance
```sql
SELECT 
    p.category_name,
    COUNT(DISTINCT f.product_id) as product_count,
    SUM(f.quantity) as total_quantity,
    SUM(f.net_amount) as total_revenue,
    AVG(f.net_amount) as avg_sale_value
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.category_name
ORDER BY total_revenue DESC;
```

## 🎓 Öğrenme Kaynakları

- [Superset Documentation](https://superset.apache.org/docs/intro)
- [Creating Your First Dashboard](https://superset.apache.org/docs/creating-charts-dashboards/creating-your-first-dashboard)
- [SQL Lab](https://superset.apache.org/docs/creating-charts-dashboards/exploring-data)

## 💡 İpuçları

1. **İlk adım**: SQL Lab ile veriyi keşfet
2. **Prototype**: Basit chart'larla başla
3. **Refine**: Filtreleri ve drill-down'ları ekle
4. **Share**: Dashboard'u takımla paylaş
5. **Iterate**: Geri bildirimlere göre iyileştir

## 🔗 Entegrasyonlar

Bu Superset kurulumu Week 4 eğitiminin parçasıdır:
- ✅ OLAP Database (PostgreSQL)
- ✅ Fact ve Dimension tabloları
- ✅ `datawarehouse_network` network
- ✅ ETL pipeline çıktıları

## 🛑 Durdurma ve Temizlik

```bash
# Durdur
docker-compose down

# Volume'ler ile birlikte sil
docker-compose down -v

# Yeniden başlat
docker-compose restart
```