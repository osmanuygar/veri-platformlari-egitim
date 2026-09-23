# 🔄 Alternatifler ve Ekosistem Haritası

Bu eğitimde her katman için **bir** araç seçtik: Docker'da tek komutla kalkabilen,
ücretsiz ve öğretici olan araçlar. Gerçek hayatta ise aynı iş için onlarca seçenek var ve
kurumların çoğu açık kaynak ile enterprise araçları **karışık** kullanıyor.

Bu sayfa iki soruya cevap veriyor:

1. Derste kullandığımız aracın yerine **başka ne kullanılabilir?**
2. Bir alternatifi **neye bakarak** değerlendirmeli?

> 💡 Amaç araç ezberlemek değil. Bir aracı iyi öğrenen kişi, aynı kategorideki başka
> bir aracı birkaç günde öğrenir. Kalıcı olan **kategori bilgisi** ve **seçim ölçütleri**.

**Sütunlar:**
**Açık kaynak** = OSI onaylı lisans (Apache 2.0, MIT, BSD, GPL/AGPL …) ·
**Enterprise / Yönetilen** = ticari ürün veya açık kaynak bir aracın bulut/yönetilen sürümü

---

## 📚 İçindekiler

1. [Nasıl değerlendirilir?](#-nasıl-değerlendirilir)
2. [Lisans okuryazarlığı](#-lisans-okuryazarlığı)
3. [Veritabanları (Hafta 2–3)](#-veritabanları-hafta-23)
4. [Depolama, Ambar ve İşleme (Hafta 4–6)](#-depolama-ambar-ve-i̇şleme-hafta-46)
5. [Orkestrasyon, Dönüşüm ve Veri Alma (Hafta 6)](#-orkestrasyon-dönüşüm-ve-veri-alma-hafta-6)
6. [Akış ve CDC (Hafta 7)](#-akış-ve-cdc-hafta-7)
7. [Analiz, İstatistik ve ML (Hafta 1, 8–10)](#-analiz-i̇statistik-ve-ml-hafta-1-810)
8. [İş Zekası (Hafta 11)](#-i̇ş-zekası-hafta-11)
9. [Yönetişim, Kalite ve Katalog (Hafta 12)](#-yönetişim-kalite-ve-katalog-hafta-12)
10. [AI / LLM (Hafta 13)](#-ai--llm-hafta-13)

---

## 🧭 Nasıl değerlendirilir?

Her hafta sonundaki tabloda "ne zaman değerlendirilmeli" sütunu var. Genel olarak şu
sorular her kategoride geçerli:

| Kriter | Soru |
|---|---|
| **Toplam sahip olma maliyeti (TCO)** | Lisans ücreti + altyapı + onu işletecek insanların maaşı. "Ücretsiz" açık kaynak, işletme maliyeti yüzünden pahalı olabilir. |
| **Ölçek** | Bugünkü veri hacmi ve 3 yıl sonrası. Çoğu şirket "büyük veri"ye hiç ulaşmaz. |
| **Ekip yetkinliği** | Ekip SQL mi, Python mı, JVM mi biliyor? En iyi araç, ekibin işletebildiği araçtır. |
| **Vendor lock-in** | Veriyi ve iş mantığını başka araca taşımak ne kadar zor? Açık format (Parquet, Iceberg) ve standart SQL bu riski azaltır. |
| **Yönetilen vs kendin kur** | 7/24 nöbeti kim tutacak? Küçük ekip için yönetilen servis çoğu zaman daha ucuzdur. |
| **Veri yerelliği & KVKK** | Veri yurt dışına çıkabilir mi? Bulut bölgesi, sınır ötesi aktarım izni (Hafta 12). |
| **Destek & topluluk** | Sorun olduğunda kime soracaksınız? Türkiye'de partner/entegratör var mı? |
| **Ekosistem uyumu** | Mevcut araçlarla konektör/entegrasyon var mı? |
| **Lisans riski** | Lisans değişirse ne olur? (aşağıya bakın) |

---

## 📜 Lisans okuryazarlığı

"Kaynak kodu GitHub'da" ile "açık kaynak" aynı şey değil. Son yıllarda birçok popüler
proje, bulut sağlayıcıların ürünü yeniden satmasını engellemek için lisans değiştirdi;
topluluk da çoğu zaman **fork** ile cevap verdi.

| Lisans tipi | Örnek | Anlamı |
|---|---|---|
| **İzin verici (permissive)** | Apache 2.0, MIT, BSD | Ticari kullanım dahil neredeyse serbest |
| **Copyleft** | GPL, AGPL | Serbest, ama türev ürünü dağıtırsanız (AGPL'de ağ üzerinden sunarsanız) kodu açmanız gerekir |
| **Kaynağı açık (source-available)** | BSL, SSPL, Elastic License, Confluent Community License | Kod görülebilir, ücretsiz kullanılabilir ama **OSI tanımına göre açık kaynak değildir**; rakip bir yönetilen servis sunmak yasaktır |
| **Açık çekirdek (open core)** | Metabase, Neo4j, Great Expectations | Temel sürüm açık kaynak; SSO, RLS, denetim gibi kurumsal özellikler ücretli sürümde |

**Derste karşılaştığımız lisans olayları:**

| Proje | Ne oldu | Topluluk cevabı |
|---|---|---|
| **Redis** (Hafta 3) | 2024'te BSD'den RSAL/SSPL'e geçti; Redis 8 ile AGPL seçeneği eklendi | **Valkey** (Linux Foundation, BSD) |
| **Elasticsearch** (Hafta 13) | 2021'de SSPL/Elastic License'a geçti; 2024'te AGPL seçeneği eklendi | **OpenSearch** (Apache 2.0) |
| **CockroachDB** (Hafta 3) | 2024'te ücretsiz "core" sürümü kaldırıldı; enterprise lisans (küçük şirketlere ücretsiz) | YugabyteDB, TiDB gibi Apache lisanslı NewSQL'ler |
| **MinIO** (Hafta 4) | AGPL; 2025'te community sürümünden web konsolunun yönetim özellikleri çıkarıldı, hazır binary/imaj dağıtımı kısıtlandı | SeaweedFS, Garage, Ceph RGW |
| **Confluent Schema Registry** (Hafta 7) | Baştan beri Confluent Community License | Apicurio Registry, Karapace (Apache 2.0) |
| **Redpanda** (Hafta 7) | BSL | — (Kafka'nın kendisi Apache 2.0) |
| **Greenplum** (Hafta 4) | PostgreSQL tabanlı açık kaynak MPP ambardı; 2024'te Broadcom kaynak kodu depolarını arşivledi, kapalı kaynağa döndü | **Apache Cloudberry** (Greenplum fork'u) |

> ⚠️ Bir aracı üretime almadan önce lisansını **o günkü haliyle** kontrol edin; bu tablo
> hazırlandığı tarihteki durumu yansıtır.

---

## 💾 Veritabanları (Hafta 2–3)

| Kategori | Derste | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|---|
| **İlişkisel (RDBMS)** | PostgreSQL, MySQL | MariaDB, SQLite | Oracle Database, Microsoft SQL Server, IBM Db2, SAP HANA, SAP ASE (Sybase), IBM Informix · Amazon RDS/Aurora, Cloud SQL/AlloyDB, Azure Database for PostgreSQL | Mevcut kurumsal lisans/ekosistem (Oracle, Microsoft), yönetilen yedek ve HA ihtiyacı |
| **DB yönetim arayüzü** | pgAdmin, Adminer | DBeaver Community, Beekeeper Studio | DataGrip, DBeaver Pro, TablePlus, Toad | Çok farklı veritabanına tek arayüzden bağlanma, ekip içi standart |
| **Document** | MongoDB | FerretDB (Postgres üzerinde Mongo protokolü), CouchDB | MongoDB Atlas, Couchbase, Azure Cosmos DB, Amazon DocumentDB | Yönetilen servis, çoklu bölge, MongoDB lisansından (SSPL) kaçınma |
| **Key-value / cache** | Redis | **Valkey**, Dragonfly, KeyDB, Memcached | Redis Cloud/Enterprise, Amazon ElastiCache/MemoryDB, Azure Cache for Redis | Lisans hassasiyeti, çok çekirdekli performans, yönetilen HA |
| **Wide-column** | Cassandra | ScyllaDB (C++ ile yeniden yazılmış, Cassandra uyumlu), HBase | DataStax Astra DB, Amazon Keyspaces, Azure Managed Instance for Cassandra | Düşük gecikme + yüksek yazma hacmi, operasyon yükünü azaltma |
| **Graph** | Neo4j (Community) | Memgraph, ArangoDB, JanusGraph, Apache AGE (Postgres eklentisi) | Neo4j Enterprise/AuraDB, Amazon Neptune, TigerGraph | Kümeleme/HA (Neo4j Community'de yok), büyük ölçek, bulut entegrasyonu |
| **NewSQL** | — | YugabyteDB, TiDB | Google Cloud Spanner, CockroachDB, Aurora DSQL | Global dağıtık + ACID ihtiyacı |
| **Bellek içi / HTAP** | — | Apache Ignite, TiDB (TiFlash) | SAP HANA, SingleStore, Oracle TimesTen, Hazelcast | Aynı veri üzerinde hem işlem hem analitik, milisaniye gecikme |
| **Zaman serisi** | — (Hafta 14 IoT vakası) | TimescaleDB (Postgres uzantısı), InfluxDB, QuestDB, VictoriaMetrics, Prometheus (metrik) | Timescale Cloud, InfluxDB Cloud, kdb+ (KX), Amazon Timestream, Azure Data Explorer | Sensör/metrik verisi, zaman aralığı sorguları, otomatik downsampling ve saklama politikası |
| **Arama motoru** | — (Hafta 13'te vektör arama) | OpenSearch, Apache Solr, Meilisearch, Typesense · Elasticsearch (AGPL seçeneği) | Elastic Cloud, Amazon OpenSearch Service, Algolia, Azure AI Search | Tam metin arama, log analitiği, yazım hatasına dayanıklı filtreli arama |
| **Federe sorgu** | Trino | Presto, Apache Drill, DuckDB (küçük ölçek) | Starburst, Dremio, Amazon Athena, BigQuery Omni | Kurumsal güvenlik/erişim yönetimi, yönetilen servis, önbellek/hızlandırma |

---

## 🏭 Depolama, Ambar ve İşleme (Hafta 4–6)

| Kategori | Derste | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|---|
| **Nesne depolama** | MinIO | SeaweedFS, Garage, Ceph (RGW) | Amazon S3, Azure Blob/ADLS Gen2, Google Cloud Storage, Cloudflare R2 | Bulutta çalışılıyorsa neredeyse her zaman bulut sağlayıcının servisi |
| **Tablo formatı** | Iceberg (tanıtım) | Apache Iceberg, Delta Lake, Apache Hudi, Apache Paimon | Databricks (Delta/Unity), Snowflake/AWS/Google yönetilen Iceberg tabloları | Hangi motorların (Spark, Trino, Snowflake…) aynı tabloyu okuyacağı |
| **Bulut veri ambarı** | PostgreSQL (star schema) | — (açık kaynak karşılıkları alttaki iki satırda) | Snowflake, Google BigQuery, Amazon Redshift, Databricks SQL, Microsoft Fabric/Synapse, Oracle Autonomous Data Warehouse, Firebolt | Yönetim yükü istenmiyorsa; depolama ve işlem ayrı ölçeklensin, kullandıkça öde |
| **MPP / kurum içi (on-prem) ambar** | PostgreSQL (star schema) | Apache Cloudberry (Greenplum fork'u), Apache Doris, StarRocks, MonetDB | **Vertica**, Teradata, Oracle Exadata, IBM Netezza, Exasol, SAP HANA / SAP BW/4HANA, Yellowbrick, Greenplum (Broadcom) | Veri kurum dışına çıkamıyorsa (bankacılık, telekom, kamu), yüksek eşzamanlılık, mevcut donanım/lisans yatırımı |
| **Gerçek zamanlı OLAP** | — | ClickHouse, Apache Druid, Apache Pinot, StarRocks | ClickHouse Cloud, Imply (Druid), StarTree (Pinot) | Alt-saniye dashboard, olay/log verisi, müşteriye dönük analitik |
| **Dağıtık işleme** | Apache Spark | Apache Flink (batch), Ray, Dask, Polars/DuckDB (tek makine) | Databricks, Amazon EMR, Google Dataproc, Azure HDInsight/Fabric | Veri tek makineye sığıyorsa Spark'a hiç gerek olmayabilir |
| **Tek makinede analitik** | DuckDB | Polars, chDB (gömülü ClickHouse), DataFusion | MotherDuck | Paylaşılan/bulut DuckDB ihtiyacı |

> 🇹🇷 **Sahada sık karşılaşılan:** Türkiye'de bankacılık, telekom ve kamuda kurum içi MPP ambarlar
> (Teradata, Oracle Exadata, Vertica, IBM Netezza, Greenplum, SAP HANA) hâlâ çok yaygın; son yıllarda
> bunlardan bulut ambarlarına veya lakehouse'a geçiş projeleri de sık. İş ilanlarında bu isimleri görürsünüz.
> Hepsi Hafta 4'te gördüğünüz kavramları paylaşır: **kolon tabanlı depolama, MPP (paylaşımsız paralel
> işleme), dağıtım anahtarı, sıkıştırma**. Örneğin Vertica, Michael Stonebraker'ın C-Store araştırma
> projesinden doğmuş kolon tabanlı bir MPP veritabanıdır; "projection" kavramı indeks + materialized
> view karışımı gibi düşünülebilir.

---

## 🔧 Orkestrasyon, Dönüşüm ve Veri Alma (Hafta 6)

| Kategori | Derste | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|---|
| **Orkestrasyon** | Apache Airflow | Dagster, Prefect, Kestra, Mage, Argo Workflows | Astronomer, Amazon MWAA, Google Cloud Composer, Dagster+, Prefect Cloud, Azure Data Factory, Control-M | Asset/veri odaklı düşünme (Dagster), Python-yerli basitlik (Prefect), YAML tabanlı (Kestra), Airflow'u işletmek istemiyorsanız yönetilen |
| **Dönüşüm (SQL)** | dbt Core | SQLMesh | dbt Cloud, Google Dataform, Coalesce, Matillion | Sanal ortamlar/plan-apply (SQLMesh), BigQuery'e gömülü (Dataform), ekip arayüzü ve zamanlama (dbt Cloud) |
| **Veri alma (ingestion)** | Python script, Airflow | Airbyte, dlt, Meltano, Apache NiFi | Fivetran, Stitch, Informatica, Talend/Qlik, Azure Data Factory, AWS Glue | Çok sayıda SaaS kaynağı (hazır konektör), konektör bakımına ayıracak ekip yoksa |

---

## 🌊 Akış ve CDC (Hafta 7)

| Kategori | Derste | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|---|
| **Olay akışı (log)** | Apache Kafka | Apache Pulsar, RabbitMQ Streams, NATS JetStream · (Redpanda: BSL) | Confluent Cloud/Platform, Amazon MSK, Azure Event Hubs (Kafka uyumlu), Google Pub/Sub, Aiven, WarpStream | Küme işletmek istemiyorsanız yönetilen; çok kiracılı/katmanlı depolama (Pulsar); JVM'siz basitlik (Redpanda) |
| **Şema kaydı** | Confluent Schema Registry | Apicurio Registry, Karapace | Confluent Cloud Schema Registry, AWS Glue Schema Registry, Azure Schema Registry | Lisans hassasiyeti, bulut sağlayıcı entegrasyonu |
| **CDC** | Debezium | Maxwell, Flink CDC, Airbyte CDC | Oracle GoldenGate, Qlik Replicate, Fivetran (HVR), AWS DMS, Striim | Oracle/Db2/mainframe kaynakları, kurumsal destek, Kafka'sız hedefler |
| **Stream işleme** | — (tanıtım) | Apache Flink, Kafka Streams, Spark Structured Streaming, RisingWave, Apache Beam | Confluent Cloud for Flink, Amazon Managed Flink, Google Dataflow, Azure Stream Analytics, Databricks | Karmaşık durum ve olay zamanı (Flink), yönetilen servis |

---

## 🔬 Analiz, İstatistik ve ML (Hafta 1, 8–10)

| Kategori | Derste | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|---|
| **Notebook ortamı** | JupyterLab | VS Code Notebooks, marimo, Apache Zeppelin | Google Colab, Databricks Notebooks, Hex, Deepnote, SageMaker Studio | Ekip içi paylaşım/işbirliği, GPU, veri ambarına doğrudan bağlantı |
| **DataFrame** | pandas | Polars, DuckDB, PySpark, Modin | Snowpark, Databricks | Veri RAM'e sığmıyor veya pandas yavaş kalıyorsa |
| **Görselleştirme** | matplotlib, seaborn | plotly, Altair, Bokeh | (BI araçları — Hafta 11) | Etkileşimli grafik, web'e gömme |
| **Kodsuz analitik** | — | KNIME, Orange | Alteryx, SAS, IBM SPSS Modeler, Dataiku | Kod yazmayan analist ekipler |
| **İstatistik** | scipy, statsmodels | R, pingouin, JASP, jamovi | IBM SPSS Statistics, SAS/STAT, Stata | Akademi/klinik araştırma gelenekleri, düzenleyici raporlama |
| **A/B test platformu** | scipy ile elle | GrowthBook | Optimizely, Statsig, Eppo, LaunchDarkly | Deneyi elle hesaplamak yerine atama + analiz + feature flag birlikte |
| **Klasik ML** | scikit-learn | XGBoost, LightGBM, CatBoost | H2O Driverless AI, DataRobot, SageMaker Autopilot, Vertex AI AutoML | Tablo verisinde en iyi performans (gradient boosting), AutoML |
| **Hiperparametre arama** | Optuna | Hyperopt, Ray Tune | SageMaker/Vertex AI tuning, W&B Sweeps | Dağıtık arama, çoklu GPU |
| **Deney takibi / MLOps** | MLflow | ClearML, DVC, Aim, Kubeflow | Weights & Biases, Neptune, Comet, Databricks Managed MLflow, SageMaker, Vertex AI, Azure ML | Ekip işbirliği, model izleme, uçtan uca yönetilen ML platformu |

---

## 📊 İş Zekası (Hafta 11)

| Kategori | Derste | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|---|
| **BI / dashboard** | Metabase, Apache Superset | Lightdash, Redash, Evidence, Grafana (operasyonel) | Microsoft Power BI, Tableau, Looker, Qlik Sense, Metabase Pro, Preset (yönetilen Superset) | Microsoft 365 ekosistemi (Power BI), gelişmiş görsel keşif (Tableau), güçlü semantik katman (Looker), kurumsal lisans zaten varsa |
| **Semantik / metrik katmanı** | SQL view'lar | Cube, dbt Semantic Layer (MetricFlow), Lightdash | LookML (Looker), AtScale, Power BI semantik modeli | Aynı KPI farklı dashboard'larda farklı çıkıyorsa |

---

## 🔐 Yönetişim, Kalite ve Katalog (Hafta 12)

| Kategori | Derste | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|---|
| **Veri kalitesi** | Great Expectations | Soda Core, dbt tests, Pandera, Deequ (Spark), Elementary | GX Cloud, Soda Cloud, Monte Carlo, Bigeye, Anomalo, Informatica Data Quality | Kural yazmak yerine otomatik anomali tespiti (data observability) |
| **Lineage** | Marquez / OpenLineage | OpenMetadata, DataHub, Apache Atlas | Collibra, Alation, Atlan, Microsoft Purview, Databricks Unity Catalog | Sütun seviyesi lineage, çok sayıda kaynak sistem |
| **Veri kataloğu** | (Marquez) | DataHub, OpenMetadata, Amundsen | Collibra, Alation, Atlan, Informatica, Microsoft Purview, Google Dataplex | İş sözlüğü, veri sahipliği iş akışları, denetim raporları |
| **Erişim / maskeleme** | PostgreSQL rol + view | Apache Ranger, Open Policy Agent | Immuta, Privacera, Snowflake/BigQuery yerleşik politikalar, Unity Catalog | Çok sayıda motor üzerinde merkezi politika, KVKK denetimi |

---

## 🤖 AI / LLM (Hafta 13)

| Kategori | Derste | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|---|
| **Yerel model çalıştırma** | Ollama | llama.cpp, vLLM, LM Studio (ücretsiz, açık kaynak değil), LocalAI, Hugging Face TGI | NVIDIA NIM, bulut GPU hizmetleri | Yüksek eşzamanlılık/throughput (vLLM), masaüstü arayüz (LM Studio) |
| **LLM API** | (yerel model) | Açık ağırlıklı modeller: Llama, Mistral, Qwen, Gemma | Anthropic Claude, OpenAI, Google Gemini · Amazon Bedrock, Azure OpenAI, Google Vertex AI | Kalite gerektiren görevler; kurumsal sözleşme, veri işleme taahhüdü ve bölge seçimi (KVKK) |
| **Vektör veritabanı** | pgvector, Qdrant | Weaviate, Milvus, Chroma, OpenSearch/Elasticsearch (vektör), LanceDB | Pinecone, Zilliz Cloud, Qdrant Cloud, MongoDB Atlas Vector Search, Azure AI Search | Milyarlarca vektör, yönetilen servis, mevcut arama altyapısını kullanmak |
| **Gömme (embedding) modeli** | Ollama (nomic-embed vb.) | sentence-transformers, BGE, E5 | Voyage AI, Cohere, OpenAI, Google embedding API'leri | Türkçe/alan özelinde kalite, çok dilli arama |
| **RAG çatısı** | Python ile elle | LlamaIndex, LangChain, Haystack | Amazon Bedrock Knowledge Bases, Vertex AI Search, Azure AI Search | Hızlı prototip vs. kontrol; yönetilen RAG |
| **RAG değerlendirme** | Elle kontrol | Ragas, DeepEval, promptfoo | LangSmith, Arize, Weights & Biases Weave | Üretimde kalite izleme, regresyon testleri |

---

## 🎓 Hafta 14 ile bağlantı

Vaka çalışmalarında yazacağınız **ADR (Mimari Karar Kaydı)** tam olarak bu sayfanın
pratiği: seçtiğiniz aracı değil, **elediğiniz alternatifleri ve neden elediğinizi**
yazın. Bu sayfayı başlangıç listesi olarak kullanın, ama değerlendirme kriterlerini
kendi vakanıza göre ağırlıklandırın.

---

> 📝 Bu liste bilerek eksik: amaç tam bir pazar haritası değil, her kategoride
> "başka ne var?" sorusunu açmak. Eklemek istediğiniz bir araç varsa PR açın —
> [WEEK_TEMPLATE.md](./WEEK_TEMPLATE.md)'deki kurallara uyarak ilgili haftanın tablosunu da güncelleyin.

**[🏠 Ana Sayfa](./README.md)** · **[🔌 Port Haritası](./PORTS.md)** · **[🧩 Hafta Şablonu](./WEEK_TEMPLATE.md)**
