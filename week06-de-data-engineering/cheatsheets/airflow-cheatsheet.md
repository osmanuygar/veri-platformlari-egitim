# 📋 Airflow Cheatsheet

Airflow UI: **http://localhost:8090** (admin / admin)

```bash
alias af='docker exec week06_airflow airflow'
```

---

## 🗂 DAG İşlemleri

```bash
af dags list                                  # tüm DAG'lar
af dags list-runs -d week06_elt_pipeline       # geçmiş çalıştırmalar
af dags trigger week06_elt_pipeline            # manuel tetikle
af dags pause week06_elt_pipeline              # zamanlamayı durdur
af dags unpause week06_elt_pipeline

# Backfill: geçmiş tarihler için çalıştır
af dags backfill week06_backfill_demo \
   --start-date 2026-01-01 --end-date 2026-01-05

# DAG dosyasında sözdizim hatası var mı?
af dags list-import-errors
```

---

## 🧩 Task İşlemleri

```bash
af tasks list week06_elt_pipeline                     # task'ları listele
af tasks states-for-dag-run week06_elt_pipeline <run_id>

# Tek bir task'ı elle çalıştır (test amaçlı — state kaydetmez)
af tasks test week06_elt_pipeline dbt_run 2026-01-01

# Başarısız task'ı yeniden dene
af tasks clear week06_elt_pipeline -t dbt_run -s 2026-01-01 -e 2026-01-01
```

---

## 🔍 Loglar

```bash
# Container logu (webserver + scheduler bir arada, standalone modda)
docker compose logs -f airflow

# Belirli bir task'ın log dosyası container içinde:
docker exec week06_airflow find /opt/airflow/logs -name "*.log" | tail -5
```

UI'dan: **DAG → Graph → task kutusuna tıkla → Logs**

---

## ⚙️ Kavramlar

| Terim | Anlamı |
|---|---|
| **DAG** | Directed Acyclic Graph — task'lar ve aralarındaki bağımlılıklar |
| **Task** | DAG içindeki tek bir iş birimi |
| **Operator** | Task'ın NE yapacağını tanımlayan sınıf (`BashOperator`, `@task` ile PythonOperator) |
| **XCom** | Task'lar arası küçük veri aktarımı (cross-communication) |
| **Scheduler** | DAG'ları zamanına göre tetikleyen süreç |
| **Execution date / data interval** | "Bugün çalıştı" değil, "hangi veri aralığını işliyor" — kafa karıştıran ama kritik ayrım |
| **Catchup** | `start_date`'ten bugüne kadar kaçırılan tüm çalıştırmaları otomatik sırayla tetikler |
| **Backfill** | Geçmiş tarihler için elle/toplu çalıştırma |

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| DAG UI'da görünmüyor | Python söz dizimi hatası | `af dags list-import-errors` |
| Task hep `queued` kalıyor | Scheduler'ın DAG'ı henüz taraması | Birkaç dakika bekleyin / `docker compose restart airflow` |
| `dbt: command not found` | BashOperator container'da farklı image'de çalışıyor | `airflow/Dockerfile`'da dbt kurulu mu kontrol edin |
| Aynı gün onlarca kez tetiklendi | `catchup=True` + eski `start_date` | `catchup=False` yapın ya da `start_date`'i güncelleyin |
| Task "geçmişte" çalışmış görünüyor | `execution_date` ile `çalışma zamanı` karıştırılıyor | "Data interval" kavramını okuyun |

---

**[← Hafta 6 README](../README.md)** · **[dbt Cheatsheet →](./dbt-cheatsheet.md)**
