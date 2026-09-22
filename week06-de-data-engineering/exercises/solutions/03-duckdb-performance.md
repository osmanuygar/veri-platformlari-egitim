# ✅ Çözüm 3: DuckDB Performans Karşılaştırması

## 3.1 Dosya boyutu

1 milyon satır, 7 sütun için tipik Parquet boyutu **~15-25 MB** (Snappy
sıkıştırmayla). Aynı veri CSV olsaydı **~80-120 MB** civarında olurdu —
**4-6 kat** daha büyük.

Sebep: Parquet sütunsaldır ve her sütun kendi veri tipine göre sıkıştırılır
(örn. `city` sütunu az sayıda tekrar eden string içerir — dictionary encoding
ile neredeyse bedavaya sıkışır). CSV ise düz metindir, her sayı bile karakter
karakter yazılır ve tekrarlar sıkıştırılmaz.

---

## 3.2 "Yüklemeden" sorgulamanın mekaniği

DuckDB, Parquet dosyasının **footer**'ını (metadata: şema, satır grubu
konumları, min/max istatistikleri) okuyarak dosyanın yapısını anlar. Sorgu
çalıştırıldığında yalnızca **gereken sütunların, gereken satır gruplarının**
baytlarını diskten okur — dosyanın tamamını belleğe almaz.

`SELECT city, sum(total) FROM 'sales.parquet' GROUP BY city` sorgusu, örneğin
`unit_price` veya `order_id` sütununa **hiç dokunmaz**. Bu "predicate/column
pushdown" adı verilen bir optimizasyondur ve DuckDB'nin Parquet okuyucusunda
yerleşiktir.

"Yükleme" (`CREATE TABLE ... AS SELECT`) atlanır çünkü DuckDB'nin sorgu
motoru dosyayı doğrudan bir tablo gibi okuyabilir.

---

## 3.3 Postgres ile karşılaştırma

Tipik sonuç (1M satır, M1/M2 Mac, yerel disk):

| Motor | Süre |
|---|---|
| DuckDB (Parquet) | ~0.05–0.15 sn |
| PostgreSQL (tablo, indekssiz) | ~0.8–2.5 sn |

İndeks eklemek **bu sorguda pek yardımcı olmaz** (belki hafif iyileşme):
`GROUP BY city, category` gibi geniş bir agregasyon sorgusu, satırların
büyük kısmını okumak zorundadır — bir B-Tree indeksi nokta sorgularında
(`WHERE id = 5`) işe yarar, geniş taramalarda (full scan gerektiren
agregasyon) sınırlı fayda sağlar. Asıl fark **depolama motorunun mimarisinden**
gelir: satır bazlı (Postgres heap) vs sütun bazlı (Parquet + DuckDB).

---

## 3.4 Neden adil değil

Bu karşılaştırma **tek kullanıcılı, salt-okunur, agregasyon ağırlıklı** bir
iş yükünü test ediyor — DuckDB'nin tam olarak optimize edildiği senaryo.

50 kullanıcı aynı anda `raw.perf_sales`'e INSERT yaparken bu agregasyon
sorgusu çalışsaydı:

- **Postgres** bunu native olarak yapar: MVCC (Multi-Version Concurrency
  Control) sayesinde okuyucular yazıcıları bloklamaz, transaction izolasyonu
  garanti edilir.
- **DuckDB** tek yazar/çoklu okuyucu modeliyle sınırlıdır; yüksek eşzamanlı
  yazma yükü için tasarlanmamıştır. Bu senaryoda **kullanılamaz** — ya da
  ciddi kısıtlamalarla kullanılabilir.

Kısacası: DuckDB "her zaman kazanan" değil, **doğru iş yükünde** kazanan bir araçtır.

---

## 3.5 Ne zaman hangisi

| Senaryo | DuckDB | Postgres | Neden |
|---|---|---|---|
| Veri bilimcinin dizüstünde 10 GB CSV analizi | ✅ | ❌ | Tek kullanıcı, analitik, kurulum yok |
| 200 kullanıcılı e-ticaret sipariş veritabanı | ❌ | ✅ | Yüksek eşzamanlı yazma, ACID, ilişkisel bütünlük |
| Data lake'te ad-hoc analitik sorgu | ✅ | ⚠️ | Parquet'i doğrudan okur; Postgres'e yüklemek gereksiz adım |
| Gerçek zamanlı stok güncellemesi | ❌ | ✅ | Sık, eşzamanlı UPDATE; transaction garantisi şart |
| CI/CD'de hızlı veri kalitesi testi | ✅ | ⚠️ | Sunucu kurmadan saniyeler içinde çalışır, tek seferlik |

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Parquet | Sütunsal + sıkıştırmalı → CSV'den 4-6× küçük |
| DuckDB'nin hızı | Column/predicate pushdown — sadece gereken bayt okunur |
| Adil karşılaştırma değil | Tek kullanıcılı analitik vs çok kullanıcılı OLTP farklı işlerdir |
| Doğru araç seçimi | İş yükünün eşzamanlılık ve yazma profiline göre karar verin |

**[← Alıştırma 3](../03-duckdb-performance.md)**
