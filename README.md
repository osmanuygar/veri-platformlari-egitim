#  Veri Platformları Eğitim Projesi 
# ============================---

Modern veri platformlarını öğrenmek için kapsamlı, pratik odaklı Docker tabanlı eğitim ortamı.

[![Docker](https://img.shields.io/badge/Docker-Required-blue)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

## 📚 İçindekiler

- [Genel Bakış](#-genel-bakış)
- [Gereksinimler](#-gereksinimler)
- [Hızlı Başlangıç](#-hızlı-başlangıç)
- [Haftalık Müfredat](#-haftalık-müfredat)
- [Kullanım Kılavuzu](#-kullanım-kılavuzu)
- [Örnek Vakalar](#-örnek-vakalar)
- [Sorun Giderme](#-sorun-giderme)
- [Katkıda Bulunma](#-katkıda-bulunma)

**Yan dosyalar:** [🔌 Port Haritası](./PORTS.md) · [🧩 Hafta Şablonu](./WEEK_TEMPLATE.md)

## 🎯 Genel Bakış

Bu repo, 14 haftalık Veri Platformları dersini desteklemek için hazırlanmış, tamamen Docker container'lar üzerinde çalışan pratik örnekler içerir. Her hafta için:

- ✅ Detaylı ders notları (Markdown formatında)
- ✅ Tek komutla ayağa kalkan Docker ortamı (`setup-weekNN.sh`)
- ✅ Container açılışında otomatik yüklenen örnek veri
- ✅ Hands-on alıştırmalar + ayrı çözüm dosyaları
- ✅ Kopyala-yapıştır cheatsheet'ler
- ✅ Her haftada akılda kalan bir **"wow" demosu**

Program 5 izlekten oluşur: **DI** Veri Temelleri (1–3) → **DE** Veri Mühendisliği (4–7) →
**DS** Veri Bilimi (8–10) → **BI** İş Zekası (11) → **DG** Veri Yönetişimi (12–13) →
**Örnek Vakalar** (14).

Her hafta **kendi klasöründe bağımsız çalışır** — tüm repoyu ayağa kaldırmanız gerekmez,
istediğiniz haftaya girip `docker compose up -d` demeniz yeterli.

## 💻 Gereksinimler

### Minimum Sistem Gereksinimleri
- **RAM**: 8GB (16GB önerilir)
- **Disk**: 30GB boş alan
- **CPU**: 4 core (önerilir)
- **OS**: Windows 10/11, macOS 10.15+, Linux (Ubuntu 20.04+)

### Yazılım Gereksinimleri
- [Docker Desktop](https://www.docker.com/products/docker-desktop) 4.0+ veya Docker Engine 20.10+
- [Docker Compose](https://docs.docker.com/compose/install/) v2.0+
- Docker Yerine  [orbstack] (https://orbstack.dev/) (Mac kullanıcıları için, Docker'a hafif alternatif, ben orbstack kullanıyorum)
- [Git](https://git-scm.com/downloads) 2.30+
- Bir kod editörü (Ben Pycharm kullanıyorum)

### Opsiyonel Araçlar
- [DBeaver](https://dbeaver.io/) - Veritabanı yönetim aracı
- [Postman](https://www.postman.com/) - API testi
- [Python 3.8+](https://www.python.org/) - Script'ler için

## 🚀 Hızlı Başlangıç

### 1. Repoyu Klonlayın
```bash
git clone https://github.com/osmanuygar/veri-platformlari-egitim.git
cd veri-platformlari-egitim
```

### 2. İlgilendiğiniz Haftayı Başlatın
```bash
cd week01-di-intro
docker compose up -d

# Kurulum script'i olan haftalarda:
./setup-week03.sh
```

### 3. Bitince Kapatın
```bash
docker compose down      # durdur, veriyi koru
docker compose down -v   # durdur, veriyi de sil
```

> 💡 **Aynı anda birden fazla hafta çalıştırabilirsiniz** — portlar çakışmayacak şekilde
> dağıtıldı. Tam liste: [🔌 PORTS.md](./PORTS.md)

### ⚠️ 2025 Sezonu: Klasör Adları Değişti

14 haftalık programa geçerken klasörler sıfır dolgulu ve izlek kodlu hale getirildi.
Eski bookmark'larınız için eşleme:

| Eski | Yeni |
|---|---|
| `week1-intro` | [`week01-di-intro`](./week01-di-intro/) |
| `week2-rdbms` | [`week02-di-rdbms`](./week02-di-rdbms/) |
| `week3-nosql` | [`week03-di-nosql`](./week03-di-nosql/) |
| `week4-datawarehouse` | [`week04-de-datawarehouse`](./week04-de-datawarehouse/) |
| `week5-advanced-sql` | [`week05-de-advanced-sql`](./week05-de-advanced-sql/) |

`git pull` sonrası yerel değişiklikleriniz varsa `git status` ile kontrol edin.

## 📖 Haftalık Müfredat

Program **5 izlek** ve **14 hafta** üzerine kurulu. Her hafta kendi klasöründe bağımsız çalışır — istediğiniz haftadan başlayabilirsiniz.

| # | İzlek | Konu | Ana Araçlar | Klasör | Durum |
|---|---|---|---|---|---|
| 01 | 🟦 DI | **Veri Dünyasına Giriş** | Jupyter, pandas | [`week01-di-intro`](./week01-di-intro/) | ✅ Hazır |
| 02 | 🟦 DI | **Temel Veri Tabanı Kavramları** | PostgreSQL, MySQL, pgAdmin | [`week02-di-rdbms`](./week02-di-rdbms/) | ✅ Hazır |
| 03 | 🟦 DI | **NoSQL ve NewSQL Yaklaşımı** | MongoDB, Redis, Cassandra, Neo4j, Trino | [`week03-di-nosql`](./week03-di-nosql/) | ✅ Hazır |
| 04 | 🟩 DE | **Veri Ambarları, Veri Gölleri ve Mimariler** | PostgreSQL, MinIO, Spark, Airflow, Superset | [`week04-de-datawarehouse`](./week04-de-datawarehouse/) | ✅ Hazır |
| 05 | 🟩 DE | **SQL ve İleri SQL ile Veri İşleme** | PostgreSQL | [`week05-de-advanced-sql`](./week05-de-advanced-sql/) | ✅ Hazır |
| 06 | 🟩 DE | **Veri Mühendisliğine Giriş ve Modern Veri Ekosistemi** | Airflow, dbt, DuckDB | [`week06-de-data-engineering`](./week06-de-data-engineering/) | ✅ Hazır |
| 07 | 🟩 DE | **Apache Kafka ile Gerçek Zamanlı Veri Akışı** | Kafka, Schema Registry, Debezium | [`week07-de-kafka`](./week07-de-kafka/) | ✅ Hazır |
| 08 | 🟨 DS | **Veri Bilimine Giriş** | Jupyter, pandas, seaborn | [`week08-ds-intro`](./week08-ds-intro/) | ✅ Hazır |
| 09 | 🟨 DS | **Temel İstatistik ile Veri Okuryazarlığı** | Jupyter, scipy, statsmodels | [`week09-ds-statistics`](./week09-ds-statistics/) | ✅ Hazır |
| 10 | 🟨 DS | **Makine Öğrenmesine Giriş** | scikit-learn, Optuna, MLflow | [`week10-ds-machine-learning`](./week10-ds-machine-learning/) | ✅ Hazır |
| 11 | 🟧 BI | **İş Zekası & Raporlama Sistemleri** | Metabase, Superset | [`week11-bi-reporting`](./week11-bi-reporting/) | ✅ Hazır |
| 12 | 🟥 DG | **Veri Yaşam Döngüsü ve Veri Yönetişimi** | Great Expectations, Marquez/OpenLineage | [`week12-dg-governance`](./week12-dg-governance/) | ✅ Hazır |
| 13 | 🟥 DG | **AI ve LLM Çağında Veri Platformları** | Ollama, pgvector, Qdrant | [`week13-dg-ai-llm`](./week13-dg-ai-llm/) | ✅ Hazır |
| 14 | ⬛ — | **Örnek Vakalar** | Önceki haftaların tümü | [`week14-case-studies`](./week14-case-studies/) | ✅ Hazır |

> **Durum açıklaması:** ✅ Hazır = ders notu + pratik + alıştırma tamam · 🚧 İskelet = başlıklar, öğrenme hedefleri ve servis planı hazır, ders notu yazımda.

### İzlekler

| İzlek | Haftalar | Odak |
|---|---|---|
| 🟦 **DI** — Veri Temelleri | 1–3 | Veri kavramı, ilişkisel model, NoSQL. Herkesin ortak temeli. |
| 🟩 **DE** — Veri Mühendisliği | 4–7 | Depolama mimarileri, SQL derinliği, orkestrasyon, gerçek zamanlı akış. |
| 🟨 **DS** — Veri Bilimi | 8–10 | Keşifçi analiz, istatistik, makine öğrenmesi. |
| 🟧 **BI** — İş Zekası | 11 | Metrik tasarımı, dashboard, raporlama operasyonu. |
| 🟥 **DG** — Veri Yönetişimi | 12–13 | Kalite, lineage, uyumluluk, AI çağının yeni riskleri. |
| ⬛ **Bütünleşik** | 14 | Uçtan uca vakalar. |

---

### 🟦 Hafta 1: [Veri Dünyasına Giriş](./week01-di-intro/)

Veri nedir, veri türleri, veri platformlarının tarihsel evrimi.

**Docker servisleri:** Jupyter Lab

```bash
cd week01-di-intro && docker compose up -d
```

📂 [Hafta 1 klasörü](./week01-di-intro/)

---

### 🟦 Hafta 2: [Temel Veri Tabanı Kavramları](./week02-di-rdbms/)

İlişkisel model, ACID, temel ve ileri SQL, kısıtlar ve trigger'lar.

**Docker servisleri:** PostgreSQL, MySQL, pgAdmin, Adminer

```bash
cd week02-di-rdbms && docker compose up -d
```

📂 [Hafta 2 klasörü](./week02-di-rdbms/)

---

### 🟦 Hafta 3: [NoSQL ve NewSQL Yaklaşımı](./week03-di-nosql/)

CAP teoremi, BASE, dört NoSQL ailesi ve tek SQL'den federasyon.

**Docker servisleri:** MongoDB, Redis, Cassandra, Neo4j, Mongo Express, Trino

```bash
cd week03-di-nosql && docker compose up -d
```

📂 [Hafta 3 klasörü](./week03-di-nosql/)

---

### 🟩 Hafta 4: [Veri Ambarları, Veri Gölleri ve Mimariler](./week04-de-datawarehouse/)

OLTP→OLAP, star şema, data lake, lakehouse ve modern mimariler.

**Docker servisleri:** PostgreSQL (OLTP), PostgreSQL (OLAP), MinIO, Spark, Airflow, Superset

```bash
cd week04-de-datawarehouse && docker compose up -d
```

📂 [Hafta 4 klasörü](./week04-de-datawarehouse/)

---

### 🟩 Hafta 5: [SQL ve İleri SQL ile Veri İşleme](./week05-de-advanced-sql/)

Pencere fonksiyonları, CTE, normalizasyon, indeks ve sorgu optimizasyonu.

**Docker servisleri:** PostgreSQL

```bash
cd week05-de-advanced-sql && docker compose up -d
```

📂 [Hafta 5 klasörü](./week05-de-advanced-sql/)

---

### 🟩 Hafta 6: [Veri Mühendisliğine Giriş ve Modern Veri Ekosistemi](./week06-de-data-engineering/)

Veri mühendisi rolü, modern veri yığını, orkestrasyon ve ELT.

**Öğrenme hedefleri:**

- Veri mühendisinin rolünü, veri analisti ve veri bilimciden ayıran sorumlulukları tanımlamak
- Modern veri yığınının (Modern Data Stack) katmanlarını ve her katmandaki araç seçeneklerini karşılaştırmak
- Batch ve streaming işleme yaklaşımlarının hangi problemde hangisinin doğru olduğunu gerekçelendirmek
- Airflow ile bağımlılıkları olan bir DAG yazıp zamanlanmış şekilde çalıştırmak

**✨ Wow anı:** dbt docs'un otomatik ürettiği soy ağacı (lineage) grafiğinde, tek bir sütunun hangi kaynak tablodan hangi rapora kadar aktığını tıklayarak izlemek.

**Docker servisleri:** Airflow, PostgreSQL (kaynak), dbt docs, DuckDB CLI

```bash
cd week06-de-data-engineering && docker compose up -d
```

📂 [Hafta 6 klasörü](./week06-de-data-engineering/)

---

### 🟩 Hafta 7: [Apache Kafka ile Gerçek Zamanlı Veri Akışı](./week07-de-kafka/)

Event-driven mimari, Kafka iç yapısı, şema yönetimi ve CDC.

**Öğrenme hedefleri:**

- Kafka'nın temel bileşenlerini (broker, topic, partition, offset, consumer group) açıklamak
- Python ile producer ve consumer yazıp mesaj üretip tüketmek
- Partition ve consumer group mantığıyla paralel tüketimi ve yeniden dengelemeyi (rebalance) gözlemlemek
- Schema Registry ile şema evrimini (schema evolution) yönetmek

**✨ Wow anı:** Bir terminalde PostgreSQL'e `UPDATE` atarken, diğer terminalde aynı değişikliğin Kafka topic'ine CDC olayı olarak milisaniyeler içinde düştüğünü görmek.

**Docker servisleri:** Kafka (KRaft), Kafka UI, Schema Registry, Kafka Connect (Debezium), PostgreSQL (CDC kaynağı)

```bash
cd week07-de-kafka && docker compose up -d
```

📂 [Hafta 7 klasörü](./week07-de-kafka/)

---

### 🟨 Hafta 8: [Veri Bilimine Giriş](./week08-ds-intro/)

Veri bilimi yaşam döngüsü, EDA, veri temizleme ve anlatım.

**Öğrenme hedefleri:**

- Veri bilimi yaşam döngüsünü (CRISP-DM) uçtan uca anlatmak
- İş problemini analiz edilebilir bir soruya çevirmek
- pandas ile keşifçi veri analizi (EDA) yapmak
- Eksik veri, aykırı değer ve veri sızıntısı (data leakage) problemlerini tanımak

**✨ Wow anı:** Aynı veri setinden çıkarılan iki grafikle tamamen zıt iki sonuca varılabildiğini görmek (Simpson paradoksu canlı örneği).

**Docker servisleri:** Jupyter Lab (DS)

```bash
cd week08-ds-intro && docker compose up -d
```

📂 [Hafta 8 klasörü](./week08-ds-intro/)

---

### 🟨 Hafta 9: [Temel İstatistik ile Veri Okuryazarlığı](./week09-ds-statistics/)

Betimsel/çıkarımsal istatistik, hipotez testi, A/B testi ve yanılgılar.

**Öğrenme hedefleri:**

- Betimsel ve çıkarımsal istatistiği ayırt etmek
- Olasılık dağılımlarını tanımak ve hangi veride hangisinin uygun olduğunu söylemek
- Hipotez testi kurup p-değerini doğru yorumlamak
- Güven aralığı hesaplamak ve anlamını açıklamak

**✨ Wow anı:** Rastgele üretilmiş, aralarında hiçbir ilişki olmayan 20 değişkenden birinin %95 güvenle 'anlamlı' çıktığını simülasyonla görmek — p-hacking'in neden bu kadar kolay olduğunu anlamak.

**Docker servisleri:** Jupyter Lab (İstatistik)

```bash
cd week09-ds-statistics && docker compose up -d
```

📂 [Hafta 9 klasörü](./week09-ds-statistics/)

---

### 🟨 Hafta 10: [Makine Öğrenmesine Giriş](./week10-ds-machine-learning/)

Gözetimli/gözetimsiz öğrenme, değerlendirme, hiperparametre ve deney takibi.

**Öğrenme hedefleri:**

- Gözetimli ve gözetimsiz öğrenmeyi ayırt etmek
- Bir sınıflandırma ve bir regresyon modelini uçtan uca eğitmek
- Aşırı öğrenme (overfitting) ve yetersiz öğrenmeyi (underfitting) teşhis etmek
- Doğru değerlendirme metriğini iş problemine göre seçmek

**✨ Wow anı:** MLflow arayüzünde 20 farklı denemeyi yan yana koyup, en iyi modeli tek tıkla registry'ye kaydetmek — 'hangi parametreyle neyi denemiştim' kaosunun bitmesi.

**Docker servisleri:** Jupyter Lab (ML), MLflow, PostgreSQL (MLflow backend), MinIO (artifact store)

```bash
cd week10-ds-machine-learning && docker compose up -d
```

📂 [Hafta 10 klasörü](./week10-ds-machine-learning/)

---

### 🟧 Hafta 11: [İş Zekası & Raporlama Sistemleri](./week11-bi-reporting/)

KPI tasarımı, dashboard ilkeleri, self-service BI ve yönetişimi.

**Öğrenme hedefleri:**

- İş zekası ile veri bilimi arasındaki rol farkını açıklamak
- Anlamlı KPI ve metrik tanımlamak, metrik katmanı kurmak
- Metabase ve Superset ile dashboard üretmek ve ikisini karşılaştırmak
- Etkili dashboard tasarım ilkelerini uygulamak

**✨ Wow anı:** Hafta 4'te kurulan star şemanın üstüne 10 dakikada çalışan bir yönetici dashboard'u çıkarmak — haftalar önce yazılan ETL'in nihayet 'iş sonucu' üretmesi.

**Docker servisleri:** Metabase, Superset, PostgreSQL (BI kaynağı)

```bash
cd week11-bi-reporting && docker compose up -d
```

📂 [Hafta 11 klasörü](./week11-bi-reporting/)

---

### 🟥 Hafta 12: [Veri Yaşam Döngüsü ve Veri Yönetişimi](./week12-dg-governance/)

Veri yaşam döngüsü, kalite, lineage, güvenlik, KVKK/GDPR.

**Öğrenme hedefleri:**

- Veri yaşam döngüsünün tüm aşamalarını ve her aşamadaki sorumlulukları tanımlamak
- Veri yönetişimi çerçevesi kurmak: sahiplik, politika, süreç
- Great Expectations ile otomatik veri kalitesi kontrolleri yazmak
- OpenLineage/Marquez ile soy ağacı (lineage) toplamak ve okumak

**✨ Wow anı:** Marquez arayüzünde bir dashboard'dan geriye doğru tıklayarak, o sayıdaki hatanın 4 adım öteki bozuk CSV dosyasından geldiğini bulmak.

**Docker servisleri:** Marquez API, Marquez Web, PostgreSQL (Marquez), Great Expectations Data Docs

```bash
cd week12-dg-governance && docker compose up -d
```

📂 [Hafta 12 klasörü](./week12-dg-governance/)

---

### 🟥 Hafta 13: [AI ve LLM Çağında Veri Platformları](./week13-dg-ai-llm/)

Embedding, vektör arama, RAG, Text-to-SQL ve AI çağı yönetişimi.

**Öğrenme hedefleri:**

- LLM'lerin veri platformlarını nasıl değiştirdiğini somut örneklerle açıklamak
- Gömme (embedding) ve vektör veritabanı mantığını kavramak
- pgvector ve Qdrant ile benzerlik araması yapmak
- Uçtan uca bir RAG (Retrieval-Augmented Generation) hattı kurmak

**✨ Wow anı:** Bu repodaki 14 haftanın tüm ders notlarını gömüp, 'Kafka'da consumer lag nasıl ölçülür?' diye Türkçe sorduğunda doğru haftadan alıntılayarak cevap veren yerel bir bot çalıştırmak.

**Docker servisleri:** Ollama, PostgreSQL + pgvector, Qdrant, Open WebUI, Jupyter Lab (LLM)

```bash
cd week13-dg-ai-llm && docker compose up -d
```

📂 [Hafta 13 klasörü](./week13-dg-ai-llm/)

---

### ⬛ Hafta 14: [Örnek Vakalar](./week14-case-studies/)

14 haftayı birleştiren uçtan uca vakalar ve mimari karar kayıtları.

**Öğrenme hedefleri:**

- 14 haftanın parçalarını tek bir uçtan uca mimaride birleştirmek
- Gerçek bir iş problemi için mimari kararları gerekçelendirmek
- Ödünleşmeleri (maliyet, gecikme, karmaşıklık) açıkça tartışmak
- Bir veri platformu tasarımını sunmak ve savunmak

**✨ Wow anı:** 14 hafta boyunca ayrı ayrı kurulan servislerin tek bir docker-compose ile birlikte ayağa kalkması ve verinin kaynaktan dashboard'a kadar akışını canlı izlemek.

**Docker servisleri:** (Vakaya göre önceki haftaların servisleri)

```bash
cd week14-case-studies && docker compose up -d
```

📂 [Hafta 14 klasörü](./week14-case-studies/)

---
## 🎮 Kullanım Kılavuzu

### Belirli Bir Haftanın Servislerini Çalıştırma

Her haftanın kendi `docker-compose.yml` dosyası var. Klasöre girip çalıştırın:

```bash
cd week02-di-rdbms && docker compose up -d      # PostgreSQL, MySQL, pgAdmin, Adminer
cd week03-di-nosql && ./setup-week03.sh         # MongoDB, Redis, Cassandra, Neo4j, Trino
cd week04-de-datawarehouse && ./setup-week04.sh # OLTP/OLAP, MinIO, Spark, Airflow, Superset
cd week07-de-kafka && ./setup-week07.sh         # Kafka, Schema Registry, Debezium
```

Kök dizindeki `docker-compose.yml` ise **tüm servisleri tek seferde** ayağa kaldırır —
16 GB'ın altındaki makinelerde önerilmez, haftalık compose dosyalarını tercih edin.

```bash
# Kök dizinden seçili servisler
docker compose up -d postgres mysql pgadmin adminer
```

### Veritabanlarına Bağlanma

#### PostgreSQL
```bash
# Komut satırından
docker exec -it veri_postgres psql -U veri_user -d veri_db

# Python'dan
import psycopg2
conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="veri_db",
    user="veri_user",
    password="veri_pass"
)
```

#### MongoDB
```bash
# Komut satırından
docker exec -it veri_mongodb mongosh -u admin -p admin_pass

# Python'dan
from pymongo import MongoClient
client = MongoClient('mongodb://admin:admin_pass@localhost:27017/')
```

#### Redis
```bash
# Komut satırından
docker exec -it veri_redis redis-cli

# Python'dan
import redis
r = redis.Redis(host='localhost', port=6379, db=0)
```

#### Neo4j
```bash
# Browser: http://localhost:7474
# Bolt: bolt://localhost:7687

# Python'dan
from neo4j import GraphDatabase
driver = GraphDatabase.driver("bolt://localhost:7687", 
                               auth=("neo4j", "password123"))
```

### Veri Yükleme ve Yedekleme

```bash
# PostgreSQL dump alma
docker exec veri_postgres pg_dump -U veri_user veri_db > backup.sql

# PostgreSQL dump geri yükleme
docker exec -i veri_postgres psql -U veri_user veri_db < backup.sql

# MongoDB export
docker exec veri_mongodb mongodump --out /backup

# MongoDB import
docker exec veri_mongodb mongorestore /backup
```

### Log İzleme

```bash
# Tüm servislerin logları
docker-compose logs -f

# Belirli bir servisin logları
docker-compose logs -f postgres

# Son 100 satır
docker-compose logs --tail=100 mongodb
```

### Performans İzleme

```bash
# Container kaynak kullanımı
docker stats

# Disk kullanımı
docker system df

# Belirli bir container'ın detayları
docker inspect veri_postgres
```

## 🎯 Örnek Vakalar

Uçtan uca projeler artık [**Hafta 14: Örnek Vakalar**](./week14-case-studies/) altında
toplanıyor. Her vaka, önceki haftalarda kurulan parçaları tek bir mimaride birleştirir.

| # | Vaka | Seviye | Süre | Kullandığı Haftalar |
|---|---|---|---|---|
| 1 | **E-ticaret Gerçek Zamanlı Analitik** — Postgres → Debezium → Kafka → OLAP → dashboard | Orta | 5-6 saat | 2, 4, 7, 11 |
| 2 | **Telekom Churn Platformu** — özellik hazırlama, model eğitimi, MLflow ile yaşam döngüsü | İleri | 6-8 saat | 5, 8, 9, 10 |
| 3 | **Bankacılıkta Veri Yönetişimi** — PII sınıflandırma, maskeleme, lineage, KVKK uyumu | İleri | 5-6 saat | 2, 6, 12 |
| 4 | **Kurumsal Bilgi Asistanı (RAG)** — doküman hattı, vektör deposu, değerlendirme | İleri | 6-8 saat | 1, 12, 13 |
| 5 | **IoT Sensör Platformu** — yüksek hacimli zaman serisi, Lambda vs Kappa kararı | İleri | 8-10 saat | 3, 4, 7 |

Her vaka için mimari diyagram, **Mimari Karar Kaydı (ADR)** ve 15 dakikalık sunum bekleniyor.

📂 [Hafta 14 Klasörü](./week14-case-studies/)

## 🔧 Sorun Giderme

### Port Çakışması
```bash
# Kullanılan portları kontrol et
# Windows
netstat -ano | findstr :5432

# Linux/Mac
lsof -i :5432

# docker-compose.yml'de portları değiştir
ports:
  - "5433:5432"  # 5432 yerine 5433 kullan
```

### Container Başlamıyor
```bash
# Container durumunu kontrol et
docker-compose ps

# Logları incele
docker-compose logs 

# Container'ı yeniden başlat
docker-compose restart 

# Tamamen temiz başlangıç
docker-compose down
docker-compose up -d
```

### Bellek Yetersizliği
```bash
# Docker'a daha fazla bellek ayır
# Docker Desktop > Settings > Resources > Memory

# Sadece gerekli servisleri çalıştır
docker-compose up -d postgres mongodb redis
```

### Veritabanı Bağlantı Hatası
```bash
# Container'ın hazır olup olmadığını kontrol et
docker-compose ps

# Health check
docker inspect --format='{{.State.Health.Status}}' veri_postgres

# Bağlantıyı test et
docker exec -it veri_postgres pg_isready -U veri_user
```

### Tüm Verileri Sıfırlama
```bash
# DİKKAT: Bu komut TÜM verileri siler!
docker-compose down -v

# Yeniden başlat
docker-compose up -d
```

### Disk Alanı Temizliği
```bash
# Kullanılmayan image'leri temizle
docker image prune -a

# Kullanılmayan volume'leri temizle
docker volume prune

# Sistem geneli temizlik
docker system prune -a --volumes
```

## 📚 Ek Kaynaklar

### Resmi Dokümantasyonlar
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MongoDB Manual](https://docs.mongodb.com/manual/)
- [Redis Documentation](https://redis.io/documentation)
- [Neo4j Documentation](https://neo4j.com/docs/)
- [Apache Cassandra Docs](https://cassandra.apache.org/doc/)

### Kitaplar
- "Designing Data-Intensive Applications" - Martin Kleppmann
- "Database Internals" - Alex Petrov
- "The Data Warehouse Toolkit" - Ralph Kimball
- "Seven Databases in Seven Weeks" - Eric Redmond

### YouTube Kanalları
- [Hussein Nasser](https://www.youtube.com/c/HusseinNasser-software-engineering)
- [CMU Database Group](https://www.youtube.com/c/CMUDatabaseGroup)
- [The Art of PostgreSQL](https://www.youtube.com/@tapoueh)

### Blog'lar ve Makaleler
- [High Scalability](http://highscalability.com/)
- [Martin Fowler's Blog](https://martinfowler.com/)
- [Uber Engineering Blog](https://eng.uber.com/)
- [Netflix Tech Blog](https://netflixtechblog.com/)

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Bu projeye nasıl katkıda bulunabileceğiniz:

### Katkı Türleri
- 🐛 Bug raporları
- ✨ Yeni özellik önerileri
- 📝 Dokümantasyon iyileştirmeleri
- 🎓 Yeni alıştırmalar ve örnekler
- 🔧 Kod optimizasyonları


### Katkı Süreci
1. Bu repoyu fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/yeni-ozellik`)
3. Değişikliklerinizi commit edin (`git commit -am 'Yeni özellik: XYZ'`)
4. Branch'inizi push edin (`git push origin feature/yeni-ozellik`)
5. Pull Request oluşturun


## 📋 Roadmap

### v1.0 — 5 haftalık program (tamamlandı)
- ✅ Temel Docker setup
- ✅ PostgreSQL, MySQL
- ✅ MongoDB, Redis, Cassandra, Neo4j, Trino
- ✅ Temel ETL pipeline, MinIO, Spark, Superset
- ✅ Jupyter Lab entegrasyonu
- ✅ Hafta 1–5 ders notları ve alıştırmalar

### v2.0 — 14 haftalık program (tamamlandı)
- ✅ 5 izlekli müfredat yapısı (DI / DE / DS / BI / DG)
- ✅ Klasör adlandırma standardı ve port haritası
- ✅ [Hafta şablonu](./WEEK_TEMPLATE.md) — her hafta aynı iskelet
- ✅ **14 haftanın tamamı tam içerikli:** ders notu, docker ortamı, alıştırma + çözüm, cheatsheet
- ✅ Hafta 6: Airflow + dbt + DuckDB · Hafta 7: Kafka + Debezium CDC
- ✅ Hafta 8-10: EDA, istatistik, ML + MLflow · Hafta 11: Metabase + Superset
- ✅ Hafta 12: Great Expectations + Marquez/OpenLineage
- ✅ Hafta 13: Ollama + pgvector + Qdrant (yerel RAG) · Hafta 14: 5 capstone vaka

### v2.1 — İyileştirme (planlı)
- 🚧 Hafta 4–5 için eksik cheatsheet'lerin tamamlanması
- 🚧 Öğrenci geri bildirimlerine göre alıştırma ayarlamaları
- 📋 Gerçek sınıf pilotundan sonra düzeltmeler

## 🙏 Teşekkürler

Bu proje şu açık kaynak projeleri kullanmaktadır:
- [PostgreSQL](https://www.postgresql.org/)
- [MongoDB](https://www.mongodb.com/)
- [Redis](https://redis.io/)
- [Neo4j](https://neo4j.com/)
- [Apache Cassandra](https://cassandra.apache.org/)
- [MinIO](https://min.io/)
- [Docker](https://www.docker.com/)

Ve tüm katkıda bulunanlara teşekkürler! 🎉

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](./LICENSE) dosyasına bakın.

## 📧 İletişim

- **Proje Sahibi:** Osman Uygar KOSE
- **Email:** osmanuygar@gmail.com
- **LinkedIn:** [linkedin.com/in/osmanuygarkose](https://linkedin.com/in/osman-uygar-kose-56785820/)
- **Issues:** [GitHub Issues](https://github.com/osmanuygar/veri-platformlari-egitim/issues)

## 🌟 Yıldız Verin

Bu projeyi faydalı bulduysanız, lütfen ⭐ vererek destek olun!

