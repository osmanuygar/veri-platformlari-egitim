# 🔌 Port Haritası

Tüm haftaların servisleri **aynı anda** ayağa kalkabilsin diye portlar çakışmayacak şekilde dağıtıldı.
Bir port kullanımdaysa ilgili haftanın `docker-compose.yml` dosyasında sol taraftaki değeri değiştirin.

## Haftaya Göre

| Hafta | Servis | Host Port | Arayüz |
|---|---|---|---|
| 01 | Jupyter Lab | `8888` | http://localhost:8888 |
| 02 | PostgreSQL | `5432` | — |
| 02 | MySQL | `3306` | — |
| 02 | pgAdmin | `5050` | http://localhost:5050 |
| 02 | Adminer | `8080` | http://localhost:8080 |
| 03 | MongoDB | `27017` | — |
| 03 | Redis | `6379` | — |
| 03 | Cassandra | `9042` | — |
| 03 | Neo4j | `7474 / 7687` | http://localhost:7474 |
| 03 | Mongo Express | `8081` | http://localhost:8081 |
| 03 | Trino | `8085` | http://localhost:8085 |
| 04 | PostgreSQL (OLTP) | `5433` | — |
| 04 | PostgreSQL (OLAP) | `5434` | — |
| 04 | MinIO | `9000 / 9001` | http://localhost:9001 |
| 04 | Spark | `8083 / 7077` | http://localhost:8083 |
| 04 | Airflow | `8089` | http://localhost:8089 |
| 04 | Superset | `8088` | http://localhost:8088 |
| 05 | PostgreSQL | `5435` | — |
| 06 | Airflow | `8090` | http://localhost:8090 |
| 06 | PostgreSQL (kaynak) | `5436` | — |
| 06 | dbt docs | `8091` | http://localhost:8091 |
| 07 | Kafka (KRaft) | `9092` | — |
| 07 | Kafka UI | `8092` | http://localhost:8092 |
| 07 | Schema Registry | `8095` | http://localhost:8095 |
| 07 | Kafka Connect (Debezium) | `8096` | http://localhost:8096 |
| 07 | PostgreSQL (CDC kaynağı) | `5437` | — |
| 08 | Jupyter Lab (DS) | `8889` | http://localhost:8889 |
| 09 | Jupyter Lab (İstatistik) | `8890` | http://localhost:8890 |
| 10 | Jupyter Lab (ML) | `8891` | http://localhost:8891 |
| 10 | MLflow | `5500` | http://localhost:5500 |
| 10 | PostgreSQL (MLflow backend) | `5438` | — |
| 10 | MinIO (artifact store) | `9000 / 9001` | http://localhost:9001 |
| 11 | Metabase | `3001` | http://localhost:3001 |
| 11 | Superset | `8098` | http://localhost:8098 |
| 11 | PostgreSQL (BI kaynağı) | `5439` | — |
| 12 | Marquez API | `5002` | http://localhost:5002 |
| 12 | Marquez Web | `3002` | http://localhost:3002 |
| 12 | PostgreSQL (Marquez) | `5440` | — |
| 12 | Great Expectations Data Docs | `8099` | http://localhost:8099 |
| 13 | Ollama | `11434` | http://localhost:11434 |
| 13 | PostgreSQL + pgvector | `5441` | — |
| 13 | Qdrant | `6333` | http://localhost:6333/dashboard |
| 13 | Open WebUI | `3003` | http://localhost:3003 |
| 13 | Jupyter Lab (LLM) | `8892` | http://localhost:8892 |

## Aralık Tahsisi

| Aralık | Kullanım |
|---|---|
| `3000–3099` | Web arayüzleri (Metabase, Marquez Web, Open WebUI) |
| `5002, 5050, 5500` | Uygulama API/UI (Marquez API, pgAdmin, MLflow) |
| `5432–5449` | PostgreSQL örnekleri (her hafta kendi instance'ı) |
| `6333, 6379` | Qdrant, Redis |
| `7077, 7199, 7474, 7687` | Spark, Cassandra JMX, Neo4j |
| `8080–8099` | Web UI'lar (Adminer, Superset, Airflow, Kafka UI, Trino…) |
| `8888–8899` | Jupyter Lab örnekleri |
| `9000–9099` | MinIO, Kafka, Cassandra CQL |
| `11434` | Ollama |
| `27017` | MongoDB |

## Port Çakışması Çözümü

```bash
# macOS / Linux — portu kim tutuyor?
lsof -i :8888

# Windows
netstat -ano | findstr :8888

# Çözüm: ilgili docker-compose.yml içinde sol tarafı değiştir
#   ports:
#     - "8898:8888"   # host:container
```

---

**[🏠 Ana Sayfa](./README.md)**
