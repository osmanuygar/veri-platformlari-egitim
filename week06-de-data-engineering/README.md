# Hafta 6: Veri Mühendisliğine Giriş ve Modern Veri Ekosistemi

> 🟩 **İzlek:** Veri Mühendisliği (DE) &nbsp;·&nbsp; **Durum:** ✅ Hazır &nbsp;·&nbsp; **Süre:** 3 saat ders + 2 saat pratik

---

## 📚 İçindekiler

1. [Öğrenme Hedefleri](#-öğrenme-hedefleri)
2. [Veri Mühendisliği Nedir?](#1-veri-mühendisliği-nedir)
3. [Modern Veri Yığını](#2-modern-veri-yığını-modern-data-stack)
4. [Veri Alma (Ingestion)](#3-veri-alma-ingestion)
5. [Orkestrasyon: Apache Airflow](#4-orkestrasyon-apache-airflow)
6. [Dönüşüm Katmanı: dbt](#5-dönüşüm-katmanı-dbt)
7. [Tek Makinede Analitik: DuckDB](#6-tek-makinede-analitik-duckdb)
8. [Batch vs Streaming](#7-batch-vs-streaming)
9. [Alternatifler ve Ekosistem](#-alternatifler-ve-ekosistem)
10. [Hızlı Başlangıç](#-hızlı-başlangıç)
11. [Pratik Uygulamalar](#-pratik-uygulamalar)
12. [Alıştırmalar](#-alıştırmalar)
13. [Cheatsheet](#-cheatsheet)
14. [Kaynaklar](#-kaynaklar)

---

## 🎯 Öğrenme Hedefleri

- [ ] Veri mühendisinin rolünü, veri analisti ve veri bilimciden ayıran sorumlulukları tanımlamak
- [ ] Modern veri yığınının (Modern Data Stack) katmanlarını ve her katmandaki araç seçeneklerini karşılaştırmak
- [ ] Batch ve streaming işleme yaklaşımlarının hangi problemde hangisinin doğru olduğunu gerekçelendirmek
- [ ] Airflow ile bağımlılıkları olan bir DAG yazıp zamanlanmış şekilde çalıştırmak
- [ ] dbt ile SQL tabanlı dönüşüm katmanı kurmak, model/test/dokümantasyon üçlüsünü kullanmak
- [ ] DuckDB ile tek makinede analitik sorgulama yapıp Postgres ile performans karşılaştırması yapmak

---

## 1. Veri Mühendisliği Nedir?

### 1.1 Rol tanımı

**Veri mühendisi**, verinin kaynaktan karar noktasına kadar **güvenilir, tekrarlanabilir
ve ölçeklenebilir** şekilde akmasını sağlayan kişidir. İş, "veriyi taşımak" değil —
verinin **her zaman doğru, güncel ve erişilebilir** olmasını garanti eden sistemler kurmaktır.

Hafta 1-5'te öğrendiğiniz her şey bu haftanın malzemesi:

| Önceki hafta | Bu haftaki rolü |
|---|---|
| Hafta 2: RDBMS, ACID | Veri mühendisinin kaynak ve hedef sistemleri |
| Hafta 3: NoSQL, CAP | Ölçek gerektiren kaynaklar |
| Hafta 4: OLTP/OLAP, star schema | **Neyi** inşa ediyoruz |
| Hafta 5: İleri SQL | dbt modellerinin içindeki dilin ta kendisi |

Bu hafta **nasıl** inşa edeceğimizi, yani **orkestrasyon** ve **dönüşüm otomasyonunu**
ekliyoruz.

### 1.2 Veri mühendisi vs veri analisti vs veri bilimci vs analytics engineer

| Rol | Odak | Tipik araçlar | Sorduğu soru |
|---|---|---|---|
| **Veri mühendisi** | Boru hattı, altyapı, güvenilirlik | Airflow, Spark, Kafka, bulut | "Bu veri her sabah 06:00'da hazır olacak mı?" |
| **Analytics engineer** | Ham veriyi iş metriğine çevirmek | dbt, SQL | "`total_spent` tam olarak nasıl hesaplanmalı?" |
| **Veri analisti** | İş sorularını cevaplamak | SQL, BI araçları | "Geçen ay hangi şehirde satış düştü?" |
| **Veri bilimci** | Tahmin, örüntü keşfi | Python, scikit-learn | "Bu müşteri gelecek ay ayrılır mı?" |

Bu roller çoğu zaman aynı kişide birleşir (küçük ekiplerde), ama büyük
organizasyonlarda ayrı ayrı işe alınır. **Analytics engineer** rolü,
dbt'nin popülerleşmesiyle 2020 sonrası ortaya çıkan, veri mühendisliği ile
veri analistliği arasında köprü kuran nispeten yeni bir tanımdır.

### 1.3 Bir veri ekibinin olgunluk seviyeleri

```
Seviye 0: Excel + e-posta                      "Raporu kim güncelleyecek?"
Seviye 1: Tek bir büyük SQL script, elle çalıştırılıyor
Seviye 2: Zamanlanmış cron job'lar, log yok, kırılınca kimse bilmiyor
Seviye 3: Orkestrasyon (Airflow) + izleme, ama dönüşüm hâlâ karman çorman SQL
Seviye 4: dbt ile test edilmiş, dokümante edilmiş, versiyonlanmış dönüşümler  ← bu hafta buraya varıyoruz
Seviye 5: Veri sözleşmeleri, otomatik kalite kapıları, self-service         ← hafta 12
```

Hafta 4'te Airflow'u tanıdınız (seviye 3). Bu hafta dbt ile **seviye 4**'e geçiyoruz.

### 1.4 Türkiye ve dünyada kariyer yolları

Veri mühendisliği, 2020 sonrası en hızlı büyüyen teknik rollerden biri.
Tipik ilerleme: Backend/Data Analyst → Junior Data Engineer → Data Engineer →
Senior/Staff Data Engineer → Data Platform Lead / Architect.

Beklenen yetkinlikler: SQL (ileri düzey), en az bir genel amaçlı dil (Python
en yaygını), dağıtık sistem temelleri, bulut platformu deneyimi (AWS/GCP/Azure),
ve — giderek artan biçimde — **dbt + orkestrasyon** araçlarında pratik deneyim.

---

## 2. Modern Veri Yığını (Modern Data Stack)

### 2.1 Katmanlar

```
┌──────────────┐   ┌───────────┐   ┌───────────────┐   ┌──────────┐   ┌──────────────┐
│  INGESTION   │──▶│  STORAGE  │──▶│ TRANSFORMATION │──▶│  SERVING │──▶│ OBSERVABILITY│
│ (veri alma)  │   │ (depolama)│   │  (dönüşüm)     │   │ (sunum)  │   │ (izleme)     │
└──────────────┘   └───────────┘   └───────────────┘   └──────────┘   └──────────────┘
  Fivetran, dlt      Snowflake,       dbt, SQLMesh       Metabase,      Great Expect.,
  Airbyte, Kafka      BigQuery,                          Superset       Monte Carlo,
                      S3+Parquet                          (hafta 11)     OpenLineage
                                                                          (hafta 12)
```

Her katmanda açık kaynak ve ticari seçenekler vardır. Bu hafta **ingestion**'a
kısaca değinip **orkestrasyon** (Airflow) ve **transformation** (dbt) katmanlarına
odaklanıyoruz; **serving** hafta 11'de, **observability** hafta 12'de.

### 2.2 ETL'den ELT'ye: neden depolama önce, dönüşüm sonra?

**Klasik ETL** (2000'ler): Extract → **Transform** (ayrı bir sunucuda, pahalı
ETL aracıyla) → **Load** (temiz veri, hedefe yazılır).

**Modern ELT**: Extract → **Load** (ham veri, olduğu gibi hedefe yazılır) →
**Transform** (hedefin kendi SQL motorunda — dbt ile).

```
ETL (2000'ler)                          ELT (2015+)
┌────────┐  ┌───────────┐  ┌──────┐    ┌────────┐  ┌──────┐  ┌───────────┐
│ Kaynak │─▶│ Transform  │─▶│ Ambar│    │ Kaynak │─▶│ Ambar│─▶│ Transform │
└────────┘  │ (ayrı sunucu)│  └──────┘    └────────┘  │(ham) │  │ (dbt, SQL) │
             └───────────┘                            └──────┘  └───────────┘
```

**Neden bu geçiş oldu?**

1. **Depolama ucuzladı.** Ham veriyi olduğu gibi saklamanın maliyeti artık
   önemsiz — 2005'te disk pahalıydı, "sadece ihtiyacınız olanı tutun" mantıklıydı.
2. **Bulut ambarları çok güçlendi.** Snowflake/BigQuery gibi sistemler,
   ayrı bir "transform sunucusundan" daha hızlı SQL çalıştırabiliyor.
3. **Ham veri geriye dönük değerlidir.** Dönüşüm mantığını değiştirdiğinizde
   (örn. "segment eşiğini değiştirdik"), ETL'de kaynağa yeniden gitmeniz
   gerekir. ELT'de ham veri zaten ambarda — sadece dönüşüm SQL'ini değiştirip
   yeniden çalıştırırsınız.

Bu haftaki `init/01-schema.sql`'deki `raw` şeması ile `analytics` şeması
arasındaki ayrım tam olarak budur: `raw` ham veriyi olduğu gibi tutar,
`analytics` (dbt'nin ürettiği) dönüştürülmüş sonuçtur.

### 2.3 Build vs buy

| | Açık kaynak (build) | Ticari SaaS (buy) |
|---|---|---|
| Örnek | Airflow + dbt-core + Postgres | Airflow (MWAA) + dbt Cloud + Snowflake |
| Maliyet modeli | Mühendis zamanı + altyapı | Abonelik + kullanım |
| Kontrol | Tam | Sınırlı, ama daha az operasyon yükü |
| Ne zaman doğru | Küçük ekip, esneklik önemli, maliyet hassasiyeti yüksek | Hız önemli, ekip küçük ama bütçe var |

Bu haftanın ortamı **tamamen açık kaynak** (Airflow standalone + dbt-core +
PostgreSQL) — prensipler birebir aynı, sadece ölçek ve operasyon yükü farklı.

---

## 3. Veri Alma (Ingestion)

### 3.1 Batch ingestion desenleri

| Desen | Nasıl çalışır | Ne zaman |
|---|---|---|
| **Full load** | Her seferinde TÜM tabloyu kopyala | Küçük tablo, basit |
| **Incremental (append)** | Sadece yeni satırları ekle (`created_at > son_calisma`) | Değişmeyen (immutable) event verisi |
| **Incremental (upsert)** | Yeni + değişen satırları güncelle | Değişebilen (mutable) durum verisi (sipariş durumu gibi) |
| **CDC** | Kaynağın change log'unu oku | Silme dahil her değişikliği yakalamak gerekiyorsa (hafta 7) |

### 3.2 Araç karşılaştırması

| Araç | Tipi | Not |
|---|---|---|
| **Fivetran** | Ticari SaaS | Yüzlerce hazır konektör, "kurulumsuz" ama pahalı |
| **Airbyte** | Açık kaynak / SaaS | Fivetran'ın açık kaynak alternatifi |
| **dlt (data load tool)** | Python kütüphanesi | Kod-öncelikli, hafif, hızlı prototipleme |
| **Kafka + Debezium** | Kendi kümenizi işletirsiniz | Gerçek zamanlı + CDC (hafta 7) |

### 3.3 Idempotency: yeniden çalıştırılabilirlik

Bir ingestion işi **iki kez çalıştırıldığında aynı sonucu vermelidir** —
veri iki kez eklenmemeli. Bu haftaki dbt seed/run komutları doğası gereği
idempotent'tir: `dbt run` on kez çalıştırılsa da tablo aynı son duruma sahip olur.

Kendi ingestion kodunuzu yazarken bu ilkeyi hatırlayın (hafta 7'deki
"idempotent tüketim" kavramıyla aynı köke sahiptir — tekrar çalıştırma
kaçınılmazdır, önemli olan onu zararsız kılmaktır).

---

## 4. Orkestrasyon: Apache Airflow

### 4.1 Temel kavramlar

| Kavram | Anlamı |
|---|---|
| **DAG** | Directed Acyclic Graph — task'lar ve bağımlılıkları |
| **Task** | Tek bir iş birimi |
| **Operator** | Task'ın NE yaptığını tanımlar (`BashOperator`, `@task`) |
| **Scheduler** | DAG'ları zamanına göre tetikleyen süreç |
| **XCom** | Task'lar arası küçük veri aktarımı |

Bu hafta kullandığımız `@dag`/`@task` dekoratör sözdizimi (**TaskFlow API**),
Airflow 2.0 ile gelen modern yazım şeklidir — eski `PythonOperator(python_callable=...)`
kalıbından çok daha az tekrar (boilerplate) gerektirir.

```python
@dag(schedule="@daily", start_date=pendulum.datetime(2026,1,1), catchup=False)
def my_pipeline():
    @task
    def extract(): ...
    @task
    def load(data): ...

    load(extract())   # bağımlılık otomatik kurulur
```

### 4.2 Scheduling, backfill, catchup

**`data_interval_start`/`data_interval_end`** bir çalıştırmanın **hangi veri
aralığını** işlediğini gösterir. Kafa karıştıran nokta: bir `@daily` DAG'ın
1 Ocak'ı işleyen çalıştırması, gerçekte **2 Ocak'ta** tetiklenir — çünkü
Airflow bir günün ancak o gün BİTTİKTEN sonra "kesinleştiğini" varsayar.

**`catchup`**: `True` ise, `start_date`'ten bugüne kadar kaçırılan tüm
çalıştırmalar sırayla tetiklenir. Kümülatif hesaplamalarda (dbt gibi)
genelde `False` istenir — her interval'i ayrı ayrı yeniden hesaplamanın
anlamı yoktur.

**`backfill`**: Elle, belirli bir tarih aralığı için geçmişe dönük çalıştırma.

### 4.3 XCom ile veri aktarımı

```python
@task
def extract() -> int:
    return 42          # otomatik XCom'a yazılır

@task
def load(n: int):       # otomatik XCom'dan okunur
    print(n)

load(extract())
```

⚠️ XCom **küçük** veriler içindir (varsayılan olarak birkaç KB — metadata
veritabanında saklanır). Büyük veri kümelerini XCom ile taşımayın; bunun
yerine ara sonucu bir dosyaya/tabloya yazıp **yolunu** XCom ile aktarın.

### 4.4 Retry, SLA, alerting

```python
default_args={
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
    "sla": timedelta(hours=1),          # bu sürede bitmezse alarm
    "on_failure_callback": send_slack_alert,
}
```

Geçici hatalar (ağ dalgalanması, kaynağın henüz hazır olmaması) `retries` ile
otomatik telafi edilir. Kalıcı hatalar (bozuk SQL, yanlış kimlik bilgisi)
retry ile çözülmez — bunlar için **alerting** (Slack/e-posta bildirimi) gerekir.

---

## 5. Dönüşüm Katmanı: dbt

### 5.1 dbt'nin temel fikri

> **"Yazılım mühendisliği pratiklerini (versiyon kontrolü, test, dokümantasyon,
> modülerlik) analitik SQL'e getir."**

dbt kendisi veri **taşımaz** — sadece **SELECT** sorguları yazar ve bunları
sırayla, bağımlılıklarına göre çalıştırır. "T" (transform) harfidir; E ve L
başka araçların (Airflow, Fivetran, Debezium) işidir.

### 5.2 Model, seed, snapshot, test, macro

| Kavram | Ne işe yarar |
|---|---|
| **Model** | Bir `SELECT` sorgusu içeren `.sql` dosyası → bir tablo/view olur |
| **Seed** | Statik bir CSV → doğrudan tabloya yüklenir (referans/lookup verisi) |
| **Snapshot** | Yavaş değişen boyutları (SCD Type 2) zaman içinde izler |
| **Test** | Veri kalitesi kuralı — şema testi ya da singular (SQL) test |
| **Macro** | Jinja ile yazılan, tekrar kullanılabilir SQL fonksiyonu |

### 5.3 Katmanlı yapı: staging → marts

```
raw (Postgres şeması)          dbt models/staging/          dbt models/marts/
┌──────────────┐               ┌──────────────┐             ┌──────────────────┐
│ raw_customers│──ref/source──▶│ stg_customers│──┐          │                  │
├──────────────┤               ├──────────────┤  │  ──join──▶│ customer_segment │
│ raw_orders   │──────────────▶│ stg_orders   │──┤          │                  │
├──────────────┤               ├──────────────┤  │          ├──────────────────┤
│ raw_payments │──────────────▶│ stg_payments │──┘          │ daily_sales_...  │
└──────────────┘               └──────────────┘             └──────────────────┘
     bire bir                    yeniden adlandırma            İŞ MANTIĞI burada
```

**Kural:** Staging sadece yeniden adlandırır ve tip dönüştürür — iş mantığı
(join, filtre, hesaplama) içermez. Marts, iş sorusuna cevap verir ve BI
araçlarının (hafta 11) doğrudan bağlanacağı katmandır.

### 5.4 `ref()` ve `source()`: dbt'nin kalbi

```sql
select * from {{ source('raw', 'raw_orders') }}   -- ham tabloya işaret eder
select * from {{ ref('stg_orders') }}              -- başka bir dbt modeline işaret eder
```

Bunlar sadece "syntax şekeri" değildir. dbt, projedeki tüm `ref()`/`source()`
çağrılarını tarayarak bir **bağımlılık grafiği (DAG)** kurar — Airflow'un
task'lar için yaptığının SQL modelleri için karşılığıdır. Bu grafik sayesinde:

- Doğru çalıştırma sırası **otomatik** bulunur
- `dbt run --select +customer_segment` ile "bu modelin ihtiyaç duyduğu her şeyi" çalıştırabilirsiniz
- `dbt docs`'ta görsel bir **lineage grafiği** üretilir

### 5.5 dbt test: veri kalitesi kod içinde yaşar

```yaml
columns:
  - name: customer_id
    tests: [unique, not_null]
  - name: status
    tests:
      - accepted_values:
          values: ['placed', 'shipped', 'completed']
```

Bu testler `dbt test` (ya da `dbt build`) ile çalıştırılır ve CI/CD'ye
eklenebilir — hatalı bir dönüşüm **production'a gitmeden** yakalanır.
Hafta 12'de bu fikri Great Expectations ile daha da genişleteceğiz.

### 5.6 `dbt docs`: otomatik dokümantasyon ve lineage

```bash
dbt docs generate && dbt docs serve --port 8091
```

Bu komut, `schema.yml` dosyalarınızdaki açıklamaları ve `ref()` grafiğini
tarayarak **tıklanabilir bir soy ağacı (lineage)** üretir. Bir sütunun hangi
kaynak tablodan hangi mart tabloya kadar aktığını görsel olarak izleyebilirsiniz
— bu haftanın "wow" anı tam olarak budur.

### 5.7 Incremental model stratejileri

```sql
{{ config(materialized='incremental', unique_key='order_date') }}

select ...
{% if is_incremental() %}
where order_date > (select max(order_date) from {{ this }})
{% endif %}
```

Büyük fact tablolarda (`daily_sales_summary` gibi, ama gerçek hayatta
milyarlarca satırlı) her `dbt run`'da **tüm tabloyu** yeniden hesaplamak
saatler sürebilir. Incremental strateji, sadece **yeni** veriyi işleyerek
bunu dakikalara indirir.

---

## 6. Tek Makinede Analitik: DuckDB

### 6.1 "Analitiğin SQLite'ı"

DuckDB, SQLite'ın felsefesini (gömülü, sunucusuz, tek dosya) analitik
(OLAP) iş yüküne uyarlar. Kurulum gerektirmez — `pip install duckdb` yeterli.

### 6.2 Parquet/CSV dosyalarını doğrudan sorgulama

```python
import duckdb
duckdb.sql("SELECT city, sum(total) FROM 'sales.parquet' GROUP BY city")
```

Herhangi bir `CREATE TABLE` ya da yükleme adımı yok. DuckDB dosyanın
metadata'sını (şema, satır grupları) okuyup sorguyu doğrudan dosya
üzerinde çalıştırır — sütunsal format ve vektörize çalıştırma sayesinde
bu, tipik bir Postgres tablosundan (indekssiz) **kat kat hızlıdır**
(bkz. Alıştırma 3).

### 6.3 Ne zaman DuckDB, ne zaman Postgres

| | DuckDB | Postgres |
|---|---|---|
| İş yükü | OLAP (analitik, agregasyon) | OLTP (çok kullanıcılı, sık yazma) |
| Eşzamanlılık | Tek yazar | Yüzlerce eşzamanlı bağlantı |
| Kurulum | Yok (kütüphane) | Sunucu gerekir |
| Tipik kullanım | Veri bilimci dizüstünde, CI'da hızlı test, data lake üzerinde ad-hoc sorgu | Uygulama veritabanı, işlemsel sistemler |

### 6.4 MotherDuck ve gömülü analitik trendi

DuckDB'nin popülerleşmesi, "her analitik sorgu için dev bir bulut ambarına
ihtiyacınız yok" fikrinin somutlaşmasıdır. **MotherDuck**, DuckDB'yi buluta
taşıyan bir servis; "gömülü analitik" trendinin en görünür örneklerinden.

---

## 7. Batch vs Streaming

### 7.1 Gecikme (latency) bütçesi

Her veri akışı tasarımı şu soruyla başlamalı: **"Bu olay olduktan kaç saniye/dakika
sonra karar verilmiş olmalı?"** Bu sayı mimariyi belirler — 24 saatlik bir
bütçe için gece batch'i yeterliyken, 100 ms'lik bir bütçe tam bir streaming
altyapısı (hafta 7) gerektirir.

### 7.2 Lambda ve Kappa mimarileri

| Mimari | Fikir |
|---|---|
| **Lambda** | Batch layer (kesin, yavaş) + Speed layer (yaklaşık, hızlı) birlikte çalışır |
| **Kappa** | Tek bir streaming katmanı; batch de "yeniden oynatma" (replay) ile aynı koddan geçer |

Kappa, Lambda'nın "aynı mantığı iki kere yazma" sorununu çözer ama her
problem için uygun değildir — hafta 14'te vakalar üzerinden tartışacağız.

### 7.3 Karar tablosu

| Belirti | Yaklaşım |
|---|---|
| Rapor "yarın sabah hazır olsun" yeterli | Batch |
| Karar saniyeler içinde verilmeli | Streaming |
| Veri hacmi büyük ama hız kritik değil | Batch (daha ucuz, daha basit) |
| Anlık uyarı/alarm gerekiyor | Streaming |
| Ekip küçük, operasyon yükü kaldıramıyor | Batch'le başlayın, ihtiyaç kanıtlanınca streaming'e geçin |

### 7.4 Hafta 7'ye köprü

Bu hafta kurduğumuz `daily_sales_summary` **batch**'tir — günde bir kez,
dbt ile hesaplanır. Hafta 7'de aynı verinin **event olarak, anında**
nasıl akıtılabileceğini (Kafka + Debezium ile) göreceğiz. İkisi rakip değil,
**tamamlayıcı** yaklaşımlardır — gecikme bütçenize göre seçersiniz.

---

## 🔄 Alternatifler ve Ekosistem

§3.2'de ingestion araçlarını, §2.3'te build-vs-buy kararını gördük. Bu tablo haftanın
diğer araçlarını da aynı gözle ele alıyor:

| Kullandığımız | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|
| **Apache Airflow** | Dagster, Prefect, Kestra, Mage, Argo Workflows | Astronomer, Amazon MWAA, Google Cloud Composer, Dagster+, Prefect Cloud, Azure Data Factory, Control-M | Veri varlığı (asset) odaklı düşünme → Dagster; Python-yerli sadelik → Prefect; YAML tabanlı → Kestra; Airflow'u işletmek istemiyorsanız yönetilen |
| **dbt Core** | SQLMesh | dbt Cloud, Google Dataform, Coalesce, Matillion | Sanal ortam ve plan/apply akışı (SQLMesh); BigQuery'e gömülü ücretsiz (Dataform); ekip arayüzü + zamanlama (dbt Cloud) |
| **DuckDB** | Polars, chDB, DataFusion, ClickHouse Local | MotherDuck | Paylaşılan/bulut DuckDB; DataFrame API tercih ediliyorsa Polars |
| **PostgreSQL (ambar)** | ClickHouse, StarRocks | Snowflake, BigQuery, Redshift, Databricks SQL | Bkz. Hafta 4 |
| **Ingestion** (§3.2) | Airbyte, dlt, Meltano, Apache NiFi | Fivetran, Stitch, Informatica, AWS Glue | Bkz. §3.2 |

**Değerlendirirken bakılacaklar:** ekibin dili (SQL/Python), zamanlayıcıyı kimin işleteceği, test ve CI desteği, lineage/dokümantasyon üretimi, konektör sayısı ve bakımı, maliyet modeli (satır başı vs. sabit).

📎 Tüm katmanların haritası ve lisans rehberi: [ALTERNATIVES.md](../ALTERNATIVES.md#-orkestrasyon-dönüşüm-ve-veri-alma-hafta-6)

---

## 🚀 Hızlı Başlangıç

```bash
cd week06-de-data-engineering
./setup-week06.sh
pip install -r requirements.txt
```

### Servisler

| Servis | Image | Port | Arayüz |
|---|---|---|---|
| PostgreSQL | `postgres:15` | `5436` | — |
| Airflow (standalone) | özel (Airflow + dbt) | `8090` | http://localhost:8090 (admin/admin) |

**Bellek ihtiyacı:** ~2 GB.

### Durdurma ve Temizlik

```bash
docker compose down        # durdur (veri kalır)
docker compose down -v     # durdur + volume sil
```

---

## 🧪 Pratik Uygulamalar

- Airflow'da 3 aşamalı bir DAG'ı tetiklemek, backfill çalıştırmak
- dbt ile staging/marts katmanları kurmak, testleri çalıştırmak, `dbt docs` ile lineage'i incelemek
- Aynı sorguyu Postgres ve DuckDB üzerinde çalıştırıp süreleri karşılaştırmak
- Parquet dosyasını DuckDB ile hiç yüklemeden doğrudan sorgulamak

### ✨ Bu Haftanın "Wow" Anı

```bash
cd dbt_project
export DBT_PROFILES_DIR=./profiles
dbt docs generate && dbt docs serve --port 8091
```

Tarayıcıda açılan sayfada **Graph** görünümüne gidin ve `customer_segment`
modeline tıklayın. Tek bir tıkla, bu tablonun **hangi ham tablolardan**
(`raw_customers`, `raw_orders`, `raw_payments`) türediğini gösteren canlı bir
soy ağacı göreceksiniz. Haftalarca elle takip etmeniz gereken "bu sütun
nereden geliyor" sorusunun cevabı, artık tek tıkla.

---

## 📝 Alıştırmalar

| # | Alıştırma | Süre | Odak |
|---|---|---|---|
| 1 | [Airflow DAG ve Backfill](./exercises/01-airflow-dag.md) | 30 dk | Bağımlılık, backfill, data interval |
| 2 | [dbt: Staging'den Marts'a](./exercises/02-dbt-transformations.md) | 35 dk | `ref()`, materialization, testler |
| 3 | [DuckDB Performans Karşılaştırması](./exercises/03-duckdb-performance.md) | 25 dk | Sütunsal motor, ne zaman hangisi |
| 4 | [Batch vs Streaming Kararı](./exercises/04-batch-vs-streaming.md) | 20 dk | Gecikme bütçesi, mimari karar |

Çözümler: [`exercises/solutions/`](./exercises/solutions/)

---

## 📋 Cheatsheet

- 📎 [**Airflow Cheatsheet**](./cheatsheets/airflow-cheatsheet.md)
- 📎 [**dbt Cheatsheet**](./cheatsheets/dbt-cheatsheet.md)
- 📎 [**DuckDB Cheatsheet**](./cheatsheets/duckdb-cheatsheet.md)

---

## 🧯 Sık Karşılaşılan Sorunlar

| Belirti | Sebep | Çözüm |
|---|---|---|
| Airflow UI açılmıyor | Standalone mod henüz başlamadı | `docker compose logs airflow`, ~1 dk bekleyin |
| `dbt: command not found` (host'ta) | dbt host'a kurulmamış | `pip install -r requirements.txt` |
| `Could not find profile` | `DBT_PROFILES_DIR` ayarlı değil | `export DBT_PROFILES_DIR=./profiles` |
| DAG UI'da görünmüyor | Python söz dizim hatası | `docker exec week06_airflow airflow dags list-import-errors` |
| dbt testleri başarısız | Gerçek bir veri sorunu OLABİLİR | Görmezden gelmeyin — [dbt cheatsheet](./cheatsheets/dbt-cheatsheet.md) |

---

## 📖 Kaynaklar

- [Airflow Documentation](https://airflow.apache.org/docs/)
- [dbt Developer Hub](https://docs.getdbt.com/)
- [DuckDB Documentation](https://duckdb.org/docs/)
- **"Fundamentals of Data Engineering"** — Joe Reis & Matt Housley
- [Modern Data Stack landscape](https://www.moderndatastack.xyz/)
- [dbt'nin jaffle_shop örnek projesi](https://github.com/dbt-labs/jaffle-shop) — bu haftanın veri şeması buradan esinlenmiştir

---

## 📝 Hafta Özeti

✅ **Rol netliği** — veri mühendisi, analytics engineer, veri analisti, veri bilimci farkı
✅ **ELT** — ham veriyi önce yükle, dönüşümü hedefin gücüyle sonra yap
✅ **Airflow** — DAG, task, XCom, backfill, data interval
✅ **dbt** — `ref()` ile otomatik bağımlılık grafiği, testler, lineage
✅ **DuckDB** — dosyayı yüklemeden sorgulamak, doğru iş yükünü doğru araca vermek
✅ **Gecikme bütçesi** — her mimari kararın başlangıç noktası

> 💡 **Haftanın tek cümlesi:** Veri mühendisliğinin özü hız değil, **güvenilirlik ve
> tekrarlanabilirliktir** — aynı pipeline'ı 100. kez çalıştırdığınızda da aynı doğru sonucu almak.

---

**[← Hafta 5: SQL ve İleri SQL ile Veri İşleme](../week05-de-advanced-sql/README.md) | [🏠 Ana Sayfa](../README.md) | [Hafta 7: Apache Kafka ile Gerçek Zamanlı Veri Akışı →](../week07-de-kafka/README.md)**
