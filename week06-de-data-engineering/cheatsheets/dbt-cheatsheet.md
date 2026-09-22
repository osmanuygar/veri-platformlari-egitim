# 📋 dbt Cheatsheet

```bash
cd dbt_project
export DBT_PROFILES_DIR=./profiles
# ya da container içinde: docker exec -it week06_airflow bash
```

---

## 🚀 Temel Komutlar

```bash
dbt debug              # bağlantıyı doğrula — İLK sorun giderme adımı
dbt deps                # packages.yml'deki paketleri indir
dbt seed                 # seeds/ altındaki CSV'leri tabloya yükle

dbt run                  # tüm modelleri çalıştır
dbt run --select stg_orders          # tek model
dbt run --select staging             # bir klasördeki tüm modeller
dbt run --select +customer_segment   # customer_segment VE bağımlı olduğu her şey
dbt run --select customer_segment+   # customer_segment VE ona bağımlı her şey
dbt run --full-refresh               # incremental modelleri baştan kur

dbt test                             # tüm testler
dbt test --select stg_orders         # tek modelin testleri

dbt build                # seed + run + test'i doğru sırayla, tek komutta

dbt docs generate        # dokümantasyon + lineage grafiği üret
dbt docs serve --port 8091           # tarayıcıda aç
```

---

## 🗂 Proje Yapısı

```
dbt_project/
├── dbt_project.yml       # proje ayarları, materialization stratejisi
├── profiles/profiles.yml # bağlantı bilgisi (normalde ~/.dbt/ altında)
├── packages.yml          # dbt_utils gibi paket bağımlılıkları
├── models/
│   ├── staging/          # kaynağa bire bir; sadece yeniden adlandırma
│   │   └── schema.yml    # source tanımı + testler
│   └── marts/            # iş mantığı; BI'ın bağlanacağı tablolar
├── seeds/                # statik CSV → tablo
├── macros/                # yeniden kullanılabilir SQL fonksiyonları
└── tests/                 # singular test'ler (SELECT ile yazılan)
```

---

## 🏗 Materialization Stratejileri

| Strateji | Ne yapar | Ne zaman |
|---|---|---|
| `view` | Her sorguda yeniden hesaplanan SQL view | Staging — hafif, hep taze |
| `table` | Her `dbt run`da baştan yazılan tablo | Küçük/orta marts |
| `incremental` | Sadece yeni satırları ekler | Büyük fact tablolar |
| `ephemeral` | CTE olarak diğer modellere gömülür, kendi tablosu yok | Ara adım, hiç sorgulanmayacaksa |

```sql
{{ config(materialized='incremental', unique_key='order_date') }}

select ...
from {{ ref('stg_orders') }}
{% if is_incremental() %}
where order_date > (select max(order_date) from {{ this }})
{% endif %}
```

---

## 🔗 `ref()` ve `source()`

```sql
-- Kaynak tablo (Postgres'teki gerçek tablo)
select * from {{ source('raw', 'raw_orders') }}

-- Başka bir dbt modeli
select * from {{ ref('stg_orders') }}
```

**Neden ham tablo adı yazmayız?** `ref()` ve `source()` kullanınca dbt:
1. Bağımlılık grafiğini otomatik çıkarır (hangi model hangisine dayanıyor)
2. Doğru çalıştırma sırasını kendisi bulur
3. Ortam değişince (dev/prod şeması farklı) kodu değiştirmenize gerek kalmaz
4. Lineage grafiğini bundan üretir

---

## ✅ Test Türleri

**Şema testleri** (`schema.yml` içinde, hazır):

```yaml
columns:
  - name: customer_id
    tests: [unique, not_null]
  - name: status
    tests:
      - accepted_values:
          values: ['placed', 'shipped', 'completed']
  - name: order_id
    tests:
      - relationships:
          to: ref('stg_orders')
          field: order_id
```

**Singular testler** (`tests/*.sql` — SATIR DÖNERSE testi BAŞARISIZ sayılır):

```sql
-- tests/assert_positive_revenue.sql
select * from {{ ref('daily_sales_summary') }} where revenue < 0
```

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `Could not find profile` | `DBT_PROFILES_DIR` ayarlı değil | `export DBT_PROFILES_DIR=./profiles` |
| `Compilation Error: model X depends on Y` | `ref()` ile yanlış isim | Model dosya adını kontrol edin |
| `Database Error: relation does not exist` | `dbt run` hiç çalışmamış | Önce `dbt run` |
| Test her seferinde başarısız | Gerçek bir veri kalitesi sorunu | Görmezden gelmeyin — veriye bakın |
| `dbt_utils` bulunamadı | `dbt deps` çalıştırılmamış | `dbt deps` |
| Incremental model eski veri gösteriyor | `is_incremental()` bloğu eksik/yanlış | Modeldeki `{% if %}` bloğunu kontrol edin |

---

**[← Airflow Cheatsheet](./airflow-cheatsheet.md)** · **[DuckDB Cheatsheet →](./duckdb-cheatsheet.md)**
