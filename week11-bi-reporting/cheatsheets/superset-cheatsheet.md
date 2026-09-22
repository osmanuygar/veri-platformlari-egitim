# 📋 Superset Cheatsheet

**URL:** http://localhost:8098 · admin / admin

---

## 🔌 Veri Kaynağı Ekleme

**Settings → Database Connections → + Database**

```
postgresql://bi_user:bi_pass@postgres:5432/bi_db
```

(Container ağı içinden `postgres` host adını kullanın, `localhost` değil.)

---

## 📐 Dataset Oluşturma

**Datasets → + Dataset** → şema `bi`, tablo `fact_sales` (ya da bir view/SQL sorgusu).

**SQL Lab**'da yazdığınız bir sorguyu doğrudan dataset'e çevirmek için:
**SQL Lab → sorguyu çalıştır → Save → Save as new dataset**

---

## 📊 Chart Oluşturma

1. **Charts → + Chart**
2. Dataset seç, Chart type seç (Bar, Line, Big Number, Table…)
3. **Metrics**: `SUM(revenue)`, `COUNT(*)` gibi agregasyonlar
4. **Dimensions**: `city`, `category`, tarih sütunları
5. **Filters**: `order_status != 'cancelled'`

---

## 🧩 Sanal Dataset ve Jinja Şablonları

SQL Lab'da doğrudan parametrik SQL yazabilirsiniz:

```sql
SELECT * FROM bi.fact_sales
WHERE order_status = '{{ filter_values("order_status")[0] }}'
  AND date_key >= {{ from_dttm | int }}
```

Bu, dashboard filtrelerinin SQL sorgusuna doğrudan enjekte edilmesini sağlar
— karmaşık, çok tablolu senaryolarda GUI'nin yetmediği yerde kullanılır.

---

## 🔒 Satır Düzeyi Güvenlik (Row-Level Security)

**Settings → Row Level Security → + Rule**

```
Dataset:    fact_sales (dim_customer ile join'li bir view üzerinden)
Filter type: Regular
Clause:     region = '{{ current_username() }}'
Roles:      bölge_muduru
```

Bu kural, `bölge_muduru` rolündeki bir kullanıcının **her sorguda otomatik
olarak** sadece kendi bölgesinin verisini görmesini sağlar — dashboard'u
kimin açtığından bağımsız olarak, veritabanı sorgusuna şart eklenir.

> Bu haftaki `bi.region_managers` tablosu, bu alıştırma için hazırlanmıştır.

---

## 🗂 Dashboard Oluşturma

**Dashboards → + Dashboard** → sağdaki panelden chart'ları sürükle-bırak →
**Native Filters** ile dashboard geneli filtre ekleyin (otomatik tüm
chart'lara uygulanır, Metabase'deki gibi elle bağlamaya gerek yok).

---

## 🆚 Metabase ile Karşılaştırma

| | Metabase | Superset |
|---|---|---|
| Kurulum karmaşıklığı | Düşük | Orta-yüksek |
| Öğrenme eğrisi | Çok kolay | Orta |
| SQL gücü | Sınırlı (Sorularda) | Tam (SQL Lab + Jinja) |
| Satır düzeyi güvenlik | Sınırlı (Enterprise) | Yerleşik, ücretsiz |
| Chart çeşitliliği | Temel | Çok geniş (40+ tür) |
| Kimler için | Hızlı self-service, küçük-orta ekip | Karmaşık gereksinimler, teknik ekip |

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `CSRF token` hatası | Oturum süresi dolmuş | Sayfayı yenileyin, tekrar giriş yapın |
| Veri kaynağı listede yok | `superset init` çalışmamış | `docker exec week11_superset superset init` |
| Chart "No data" gösteriyor | Filtre çok kısıtlayıcı / şema yanlış | SQL Lab'da aynı sorguyu elle deneyin |
| RLS kuralı çalışmıyor | Kullanıcı doğru role atanmamış | **Settings → List Users** üzerinden rolü kontrol edin |

---

**[← Metabase Cheatsheet](./metabase-cheatsheet.md)** · **[Hafta 11 README →](../README.md)**
