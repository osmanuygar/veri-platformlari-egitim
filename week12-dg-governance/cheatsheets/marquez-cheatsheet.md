# 📋 Marquez & OpenLineage Cheatsheet

Marquez Web: **http://localhost:3002** · API: **http://localhost:5002**

---

## 🧬 OpenLineage Temel Kavramlar

| Kavram | Anlamı |
|---|---|
| **Namespace** | Bir organizasyon/proje sınırı (bu haftada `week12-dg`) |
| **Job** | Bir dönüşüm adımı (Airflow task'ı, dbt modeli, bir script) |
| **Run** | Bir job'un TEK BİR çalıştırması (her tetiklemede yeni bir run_id) |
| **Dataset** | Bir job'un okuduğu ya da yazdığı veri (tablo, dosya) |
| **Facet** | Bir olaya eklenen ek bilgi (şema, SQL sorgusu, veri kalitesi metriği) |

---

## 📡 Olay Gönderme (Python)

```python
from openlineage.client import OpenLineageClient
from openlineage.client.run import RunEvent, RunState, Run, Job, Dataset

client = OpenLineageClient(url="http://localhost:5002")

run = Run(runId="...")  # uuid4
job = Job(namespace="week12-dg", name="transform_customer_marts")

client.emit(RunEvent(
    eventType=RunState.START,      # sonra COMPLETE ya da FAIL
    eventTime="2026-01-01T10:00:00Z",
    run=run, job=job,
    inputs=[Dataset(namespace="week12-dg", name="raw.customers")],
    outputs=[Dataset(namespace="week12-dg", name="marts.customers_masked")],
    producer="https://my-pipeline",
))
```

Her job **en az iki olay** gönderir: `START` (başladığında) ve `COMPLETE`
ya da `FAIL` (bittiğinde). Marquez bu ikisini aynı `runId` ile eşleştirir.

---

## 🔌 Airflow Entegrasyonu (gerçek dünyada)

Bu hafta olayları elle (script ile) gönderiyoruz — gerçek bir kurulumda
Airflow'un `apache-airflow-providers-openlineage` paketi bunu **otomatik**
yapar: her task çalıştığında OpenLineage olayı kendiliğinden Marquez'e gider.

```python
# airflow.cfg / ortam değişkeni
OPENLINEAGE_URL = "http://marquez-api:5000"
```

Hafta 4 ve 6'daki Airflow DAG'larınıza bu entegrasyonu eklemek, elle
script yazmadan otomatik lineage toplamanın yoludur.

---

## 🌐 REST API ile Sorgulama

```bash
# Namespace'leri listele
curl -s http://localhost:5002/api/v1/namespaces | python3 -m json.tool

# Bir namespace'teki job'lar
curl -s http://localhost:5002/api/v1/namespaces/week12-dg/jobs | python3 -m json.tool

# Bir job'un çalıştırmaları
curl -s http://localhost:5002/api/v1/namespaces/week12-dg/jobs/transform_customer_marts/runs

# Bir dataset'in lineage grafiği (yukarı + aşağı akış)
curl -s "http://localhost:5002/api/v1/lineage?nodeId=dataset:week12-dg:marts.customers_masked"
```

---

## 🗺 Marquez Web'de Gezinme

| Yapmak istediğiniz | Nerede |
|---|---|
| Tüm job'ları görmek | **Jobs** sekmesi |
| Bir job'un giriş/çıkışlarını görmek | Job'a tıkla → **Lineage Graph** |
| Bir dataset'in şemasını görmek | **Datasets** → dataset adı |
| Etki analizi ("bunu değiştirirsem ne kırılır") | Dataset → **Lineage Graph** → aşağı akışa bakın |
| Başarısız bir run'ı bulmak | Job → **Runs** sekmesi → kırmızı işaretli olan |

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `Connection refused` | Marquez API henüz hazır değil | `docker compose ps`, `healthcheck` durumuna bakın |
| Grafik boş görünüyor | Hiç olay gönderilmedi | `python scripts/emit_lineage.py` çalıştırın |
| Job COMPLETE olmuyor | START gönderildi ama COMPLETE/FAIL gönderilmedi | Script'in hem START hem COMPLETE/FAIL gönderdiğini kontrol edin |
| Aynı job tekrar tekrar farklı görünüyor | Her çalıştırmada farklı `job.name` kullanılmış | Job adı SABİT olmalı, değişen sadece `runId` |

---

**[← Great Expectations Cheatsheet](./great-expectations-cheatsheet.md)** · **[Hafta 12 README →](../README.md)**
