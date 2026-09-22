# 📋 DuckDB Cheatsheet

DuckDB bir sunucu değildir — Python/CLI içinde gömülü çalışan bir kütüphanedir.

```bash
pip install duckdb          # zaten requirements.txt'de var

# CLI (opsiyonel, tek satırlık kurulum)
curl https://install.duckdb.org | sh
```

---

## 🐍 Python'dan Kullanım

```python
import duckdb

con = duckdb.connect()                    # bellek içi (varsayılan)
con = duckdb.connect("analytics.duckdb")  # diske kalıcı yaz

# Parquet'i DOĞRUDAN sorgula — yükleme adımı yok
con.execute("SELECT * FROM 'data/sales.parquet' LIMIT 5").fetchall()

# pandas DataFrame'i doğrudan sorgula
import pandas as pd
df = pd.read_csv("data.csv")
con.execute("SELECT city, sum(total) FROM df GROUP BY city").fetchdf()

# Sonucu pandas'a çevir
result_df = con.execute("SELECT ...").fetchdf()
```

---

## 🗄 Desteklenen Kaynaklar

```sql
-- Parquet
SELECT * FROM 'file.parquet';
SELECT * FROM 'files/*.parquet';           -- birden fazla dosya, tek sorgu

-- CSV (otomatik tip çıkarımı)
SELECT * FROM 'file.csv';
SELECT * FROM read_csv('file.csv', delim=';', header=true);

-- JSON
SELECT * FROM 'file.json';

-- Doğrudan Postgres'e bağlanma (postgres extension)
INSTALL postgres; LOAD postgres;
ATTACH 'host=localhost port=5436 user=de_user dbname=de_db' AS pg (TYPE postgres);
SELECT * FROM pg.raw.raw_orders;

-- S3 / MinIO (hafta 4'teki data lake ile birlikte kullanılabilir)
INSTALL httpfs; LOAD httpfs;
SET s3_endpoint='localhost:9000';
SELECT * FROM 's3://bucket/file.parquet';
```

---

## ⚡ Neden Bu Kadar Hızlı?

| Özellik | Ne demek |
|---|---|
| **Sütunsal (columnar)** | Sadece sorguladığınız sütunlar okunur, diğerleri hiç dokunulmaz |
| **Vektörize çalıştırma** | Satır satır değil, binlik bloklar (vector) halinde işlem yapar |
| **Sıfır kopya (zero-copy)** | Parquet'i belleğe kopyalamadan doğrudan okur |
| **Paralel** | Tek makinedeki tüm çekirdekleri otomatik kullanır |

Postgres bunun tam tersi bir iş için optimize edilmiştir: **satır bazlı**, çok
kullanıcılı, sık INSERT/UPDATE'li OLTP yükleri. Analitik toplu okumada DuckDB,
OLTP'de Postgres kazanır — "hangisi daha iyi" değil, "hangisi bu işe uygun" sorusu.

---

## 🖥 CLI Kullanımı

```bash
duckdb                                      # bellek içi oturum aç
duckdb analytics.duckdb                     # kalıcı dosyaya bağlan

.tables                                     # tabloları listele
.schema tablo_adi                           # şemayı gör
.mode markdown                              # çıktıyı okunur formatta göster
.timer on                                   # sorgu süresini göster

-- Tek satırlık sorgu (shell'den)
duckdb -c "SELECT count(*) FROM 'data/sales.parquet'"
```

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `IO Error: No files found` | Yol yanlış / göreli yol farklı klasörden çalıştırıldı | Mutlak yol kullanın |
| Bellek yetersiz hatası | Çok büyük dosya, RAM sınırı | `PRAGMA memory_limit='4GB'` |
| Postgres extension bulunamadı | `INSTALL postgres` yapılmamış | `INSTALL postgres; LOAD postgres;` |
| pandas DataFrame görünmüyor | Değişken adı DuckDB'nin göreme alanında değil | Aynı Python oturumunda olmalı |

---

**[← dbt Cheatsheet](./dbt-cheatsheet.md)** · **[Hafta 6 README →](../README.md)**
