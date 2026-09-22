# 📋 MLflow Cheatsheet

MLflow UI: **http://localhost:5500**

```python
import mlflow
mlflow.set_tracking_uri("http://localhost:5500")
mlflow.set_experiment("week10-churn-prediction")
```

---

## 🧪 Temel Kullanım

```python
with mlflow.start_run(run_name="my_experiment"):
    mlflow.log_param("C", 1.0)                    # tek parametre
    mlflow.log_params({"C": 1.0, "max_iter": 1000}) # toplu

    mlflow.log_metric("roc_auc", 0.85)             # tek metrik
    mlflow.log_metrics({"roc_auc": 0.85, "f1": 0.72})

    mlflow.log_text("...", "notes.txt")            # metin dosyası
    mlflow.log_artifact("plot.png")                # herhangi bir dosya

    mlflow.sklearn.log_model(pipe, "model")         # model + metadata
```

---

## 🔍 Sorgulama

```python
# En iyi 5 çalıştırmayı roc_auc'a göre getir
runs = mlflow.search_runs(
    experiment_names=["week10-churn-prediction"],
    order_by=["metrics.roc_auc DESC"],
    max_results=5,
)
print(runs[["run_id", "params.model_type", "metrics.roc_auc"]])
```

---

## 📦 Model Yükleme (Kayıttan Geri Çağırma)

```python
run_id = "abc123..."
model = mlflow.sklearn.load_model(f"runs:/{run_id}/model")
model.predict(X_new)
```

---

## 🗂 Model Registry

```python
# Bir çalıştırmayı registry'e kaydet
mlflow.register_model(f"runs:/{run_id}/model", "churn-classifier")

# Aşama (stage) ata
from mlflow import MlflowClient
client = MlflowClient()
client.transition_model_version_stage("churn-classifier", version=1, stage="Production")

# Production'daki modeli yükle
model = mlflow.sklearn.load_model("models:/churn-classifier/Production")
```

UI'dan: **Models** sekmesi → model adı → versiyon → **Stage** dropdown.

---

## 🗺 UI'da Gezinme

| Yapmak istediğiniz | Nerede |
|---|---|
| Tüm denemeleri karşılaştırmak | Experiment sayfası → satırları seç → **Compare** |
| Metriklere göre sıralamak | Sütun başlığına tıkla |
| Parametre/metrik grafiği | **Compare** → **Parallel Coordinates Plot** |
| Bir modeli indirmek | Run detayı → **Artifacts** → **model** |
| Confusion matrix'i görmek | Run detayı → **Artifacts** → `confusion_matrix.txt` |

---

## 🏗 Bu Haftanın Mimarisi

```
┌──────────┐  log_run()  ┌─────────────┐         ┌──────────────┐
│ Jupyter/ │────────────▶│   MLflow    │────────▶│ PostgreSQL   │  (metrik, parametre)
│ script   │             │   Server    │         │ (backend)    │
└──────────┘             └─────────────┘         └──────────────┘
                                │
                                ▼
                          ┌──────────────┐
                          │ MinIO (S3)   │  (model dosyaları, artifact'lar)
                          │ (artifact    │
                          │  store)      │
                          └──────────────┘
```

**Neden ayrı backend ve artifact store?** Metrik/parametre gibi küçük,
sorgulanabilir veri bir veritabanında (Postgres); model dosyaları gibi
büyük binary veri bir nesne deposunda (S3/MinIO) tutulur — her biri kendi
işine uygun sistemde.

---

## 🧯 Sık Karşılaşılan Hatalar

| Belirti | Sebep | Çözüm |
|---|---|---|
| `Connection refused` | `MLFLOW_TRACKING_URI` yanlış/servis kapalı | `docker compose ps`, URI'yi kontrol edin |
| `NoSuchBucket` hatası | MinIO bucket'ı oluşmamış | `docker compose logs minio-init` |
| Aynı run'lar tekrar tekrar oluşuyor | `start_run()` context manager kullanılmıyor | `with mlflow.start_run():` bloğuna alın |
| Model yüklenemiyor | Yanlış `run_id` ya da artifact path | UI'dan **Artifacts** sekmesindeki tam yolu kopyalayın |

---

**[← scikit-learn Cheatsheet](./sklearn-cheatsheet.md)** · **[Hafta 10 README →](../README.md)**
