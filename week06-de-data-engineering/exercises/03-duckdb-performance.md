# Alıştırma 3: DuckDB Performans Karşılaştırması

**Süre:** ~25 dakika · **Dosyalar:** `scripts/generate_parquet.py`, `scripts/duckdb_demo.py`, `scripts/compare_performance.py`

---

## 3.1 Veri üretin

```bash
python scripts/generate_parquet.py --rows 1000000
```

**Soru:** Üretilen `data/sales.parquet` dosyasının boyutu kaç MB? Aynı veriyi
CSV olarak kaydetseydiniz (yaklaşık) kaç kat daha büyük olurdu? (İpucu:
Parquet sütunsal + sıkıştırmalı, CSV metin tabanlı)

---

## 3.2 Yüklemeden sorgulayın

```bash
python scripts/duckdb_demo.py
```

**Soru:** Script hiçbir yerde `CREATE TABLE` ya da `COPY INTO` çalıştırmıyor.
1 milyon satırlık dosyayı DuckDB nasıl "sorgulanabilir" hale getiriyor?

---

## 3.3 Postgres ile karşılaştırın

```bash
python scripts/compare_performance.py --load-postgres
```

**Görev:** İki motorun süresini kaydedin.

| Motor | Süre |
|---|---|
| DuckDB (Parquet) | |
| PostgreSQL (tablo, indekssiz) | |

**Soru:** Hangisi daha hızlı çıktı? Postgres tablosuna
`CREATE INDEX ON raw.perf_sales (city, category)` eklerseniz fark azalır mı?
Deneyin:

```bash
docker exec week06_postgres psql -U de_user -d de_db \
  -c "CREATE INDEX idx_perf_sales_city_cat ON raw.perf_sales (city, category);"
python scripts/compare_performance.py
```

---

## 3.4 Adil olmayan karşılaştırma

**Soru:** Bu karşılaştırma neden "DuckDB her zaman kazanır" sonucuna
**varılmaması** gereken bir karşılaştırma? Şu senaryoyu düşünün: 50 kullanıcı
aynı anda `raw.perf_sales` tablosuna INSERT yapıyor, bir yandan da bu
agregasyon sorgusu çalışıyor. DuckDB bu senaryoda kullanılabilir mi?

---

## 3.5 Ne zaman DuckDB, ne zaman Postgres?

Tabloyu doldurun:

| Senaryo | DuckDB | Postgres | Neden |
|---|---|---|---|
| Veri bilimcinin dizüstünde 10 GB'lık CSV analizi | | | |
| 200 kullanıcılı bir e-ticaret sitesinin sipariş veritabanı | | | |
| Hafta 4'teki data lake'te ad-hoc analitik sorgu | | | |
| Gerçek zamanlı stok güncellemesi | | | |
| CI/CD'de veri kalitesi testi (hızlı, tek seferlik) | | | |

---

## ✅ Ne öğrendik

- DuckDB, dosyayı **hiç yüklemeden** doğrudan sorgular — "sıfır ETL analitik".
- Sütunsal format (Parquet) + vektörize çalıştırma, tek makinede agregasyon
  sorgularını OLTP veritabanlarından çok daha hızlı yapabilir.
- Bu bir "DuckDB > Postgres" karşılaştırması değil — **iş yükü tipine göre**
  doğru aracı seçme meselesi. OLTP'de (çok kullanıcılı, sık yazma) Postgres
  kazanır; tek kullanıcılı analitik toplu okumada DuckDB kazanır.

📎 [Çözüm](./solutions/03-duckdb-performance.md)
