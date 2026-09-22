# Apache Airflow - Workflow Orchestration

Apache Airflow ile ETL pipeline'larını schedule etme ve orkestrasyon.

## 🚀 Hızlı Başlangıç

### 1. Airflow'u Başlat

```bash
# Airflow klasörüne git
cd airflow

# Airflow cluster'ı başlat
docker-compose up -d

# Logları izle
docker-compose logs -f

# Durumu kontrol et
docker-compose ps
```

### 2. Web UI'ya Eriş

```
URL: http://localhost:8080
Kullanıcı: airflow
Şifre: airflow123
```

### 3. İlk DAG'ı Çalıştır

1. Web UI'da **DAGs** sayfasına git
2. `example_etl_dag` DAG'ını bul
3. Toggle switch ile aktif et
4. ▶️ **Trigger DAG** butonuna tıkla
5. **Graph** view'da çalışmayı izle

## 📅 DAG'lar (Data Pipelines)

### 1. example_etl_dag.py
Basit ETL örneği - Extract, Transform, Load adımları.

**Schedule:** Her gün 02:00  
**Tasks:**
- `extract`: Veri çekme
- `transform`: Veri dönüştürme
- `load`: Veri yükleme

```bash
# Manuel tetikleme
docker exec airflow-webserver airflow dags trigger example_etl_dag

# Backfill (geçmiş tarih için çalıştırma)
docker exec airflow-webserver airflow dags backfill example_etl_dag \
    --start-date 2024-01-01 --end-date 2024-01-07
```

### 2. postgres_to_minio_dag.py
PostgreSQL'den MinIO'ya veri transfer.

**Schedule:** Her gün 03:00  
**Tasks:**
- `extract_customers`: Müşteri verisi
- `extract_products`: Ürün verisi
- `extract_orders`: Sipariş verisi
- `upload_to_minio`: MinIO'ya yükleme

### 3. daily_sales_dag.py
Günlük satış raporu oluşturma.

**Schedule:** Her gün 04:00  
**Tasks:**
- `calculate_daily_sales`: Satış hesaplama
- `aggregate_by_product`: Ürün bazında toplama
- `save_report`: Rapor kaydetme

## 💻 DAG Yazma

### Basit DAG Yapısı

```python
from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

# Default arguments
default_args = {
    'owner': 'data-team',
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

# DAG tanımla
with DAG(
    dag_id='my_simple_dag',
    default_args=default_args,
    description='Basit örnek DAG',
    schedule='0 2 * * *',  # Her gün 02:00
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=['example'],
) as dag:
    
    def extract_data():
        print("Veri çekiliyor...")
        return "data"
    
    def transform_data(ti):
        data = ti.xcom_pull(task_ids='extract')
        print(f"Veri dönüştürülüyor: {data}")
        return f"transformed_{data}"
    
    def load_data(ti):
        data = ti.xcom_pull(task_ids='transform')
        print(f"Veri yükleniyor: {data}")
    
    # Task'ları tanımla
    extract = PythonOperator(
        task_id='extract',
        python_callable=extract_data,
    )
    
    transform = PythonOperator(
        task_id='transform',
        python_callable=transform_data,
    )
    
    load = PythonOperator(
        task_id='load',
        python_callable=load_data,
    )
    
    # Task sırası
    extract >> transform >> load
```

## 🔧 Task Dependencies (Bağımlılıklar)

### Linear (Doğrusal)
```python
task1 >> task2 >> task3 >> task4
```

### Parallel (Paralel)
```python
start >> [task1, task2, task3] >> end
```

### Conditional (Koşullu)
```python
from airflow.operators.python import BranchPythonOperator

def choose_branch():
    if condition:
        return 'task_a'
    else:
        return 'task_b'

branch = BranchPythonOperator(
    task_id='branch',
    python_callable=choose_branch,
)

branch >> [task_a, task_b]
```

## 🗄️ Connections (Bağlantılar)

### PostgreSQL Connection Ekleme

**Web UI'dan:**
1. Admin > Connections > + (Add)
2. Connection Type: `Postgres`
3. Connection Id: `postgres_oltp`
4. Host: `postgres-oltp`
5. Schema: `ecommerce_oltp`
6. Login: `oltp_user`
7. Password: `oltp_pass123`
8. Port: `5432`

**CLI'dan:**
```bash
docker exec airflow-webserver airflow connections add \
    'postgres_oltp' \
    --conn-type 'postgres' \
    --conn-host 'postgres-oltp' \
    --conn-schema 'ecommerce_oltp' \
    --conn-login 'oltp_user' \
    --conn-password 'oltp_pass123' \
    --conn-port 5432
```

### MinIO/S3 Connection
```bash
docker exec airflow-webserver airflow connections add \
    'minio_conn' \
    --conn-type 's3' \
    --conn-host 'http://minio:9000' \
    --conn-login 'minio_admin' \
    --conn-password 'minio_password123'
```

## 📊 Operators (Task Tipleri)

### PythonOperator
```python
from airflow.operators.python import PythonOperator

task = PythonOperator(
    task_id='my_task',
    python_callable=my_function,
)
```

### PostgresOperator
```python
from airflow.providers.postgres.operators.postgres import PostgresOperator

task = PostgresOperator(
    task_id='query_db',
    postgres_conn_id='postgres_oltp',
    sql='SELECT * FROM customers LIMIT 10;',
)
```

### BashOperator
```python
from airflow.operators.bash import BashOperator

task = BashOperator(
    task_id='run_script',
    bash_command='echo "Hello from Airflow"',
)
```

### EmailOperator
```python
from airflow.operators.email import EmailOperator

task = EmailOperator(
    task_id='send_email',
    to='team@example.com',
    subject='ETL Completed',
    html_content='<p>ETL pipeline başarılı!</p>',
)
```

## 🔄 XCom (Task Arası Veri Paylaşımı)

### Veri Gönderme (Push)
```python
def extract(**context):
    data = {"sales": 1000, "customers": 50}
    # XCom'a yaz
    context['ti'].xcom_push(key='sales_data', value=data)
    # Ya da return (otomatik push)
    return data
```

### Veri Alma (Pull)
```python
def transform(**context):
    # XCom'dan oku
    data = context['ti'].xcom_pull(
        task_ids='extract',
        key='sales_data'
    )
    print(f"Alınan veri: {data}")
```

## ⏰ Schedule Formats

### Cron Expression
```python
schedule='0 2 * * *'     # Her gün 02:00
schedule='0 */4 * * *'   # Her 4 saatte bir
schedule='0 0 * * 1'     # Her Pazartesi 00:00
schedule='0 0 1 * *'     # Her ayın 1'i 00:00
```

### Preset Schedules
```python
from airflow.timetables.trigger import CronTriggerTimetable

schedule='@daily'        # Her gün 00:00
schedule='@hourly'       # Her saat başı
schedule='@weekly'       # Her Pazar 00:00
schedule='@monthly'      # Her ayın 1'i 00:00
schedule=None            # Manuel tetikleme
```

## 🐳 Docker Compose Detayları

### Servisler
- **postgres-airflow**: Metadata database
- **airflow-init**: İlk kurulum (one-time)
- **airflow-webserver**: Web UI (port 8080)
- **airflow-scheduler**: DAG scheduler
- **airflow-worker**: Task executor (opsiyonel)

### Executor Tipleri
Bu setup **LocalExecutor** kullanır (tek worker, basit ve hızlı).

Production için:
- **CeleryExecutor**: Dağıtık task execution
- **KubernetesExecutor**: Kubernetes üzerinde

### Volumes
- `./dags`: DAG dosyaları
- `./logs`: Task logları
- `./plugins`: Custom plugins
- `postgres_airflow_data`: PostgreSQL data

## 🔍 Monitoring ve Debug

### Web UI Features
- **DAGs**: Tüm pipeline'ları listele
- **Graph View**: Task bağımlılıklarını görselleştir
- **Tree View**: Tarihsel çalışmaları görüntüle
- **Gantt Chart**: Task sürelerini analiz et
- **Task Logs**: Her task'ın loglarını oku

### CLI Commands
```bash
# DAG listesi
docker exec airflow-webserver airflow dags list

# DAG detayı
docker exec airflow-webserver airflow dags show example_etl_dag

# Task listesi
docker exec airflow-webserver airflow tasks list example_etl_dag

# Task test (gerçek çalıştırma değil)
docker exec airflow-webserver airflow tasks test example_etl_dag extract 2024-01-01

# DAG test
docker exec airflow-webserver airflow dags test example_etl_dag 2024-01-01
```

### Log Kontrol
```bash
# Webserver logları
docker-compose logs -f airflow-webserver

# Scheduler logları
docker-compose logs -f airflow-scheduler

# Tüm loglar
docker-compose logs -f
```

## 🎯 Best Practices

### 1. İdempotency (Tekrar Çalıştırılabilirlik)
DAG'lar aynı tarihte tekrar çalıştırılabilmeli:
```python
# ✅ İyi
df.write.mode("overwrite").parquet(path)

# ❌ Kötü
df.write.mode("append").parquet(path)
```

### 2. Task Boyutu
- Her task küçük ve tek bir iş yapmalı
- 5-15 dakika arası ideal
- Çok uzun task'ları böl

### 3. Error Handling
```python
default_args = {
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
    'retry_exponential_backoff': True,
}
```

### 4. Documentation
```python
dag = DAG(
    dag_id='my_dag',
    description='Bu DAG şunu yapar...',
    doc_md="""
    ## Detaylı Açıklama
    
    Bu DAG:
    1. PostgreSQL'den veri çeker
    2. Transform eder
    3. MinIO'ya yükler
    """,
)
```

### 5. Tags
```python
dag = DAG(
    dag_id='sales_pipeline',
    tags=['etl', 'sales', 'daily', 'production'],
)
```

## 🛑 Durdurma ve Temizlik

```bash
# Durdur
docker-compose down

# Volume'lerle birlikte sil
docker-compose down -v

# Yeniden başlat
docker-compose restart

# Sadece scheduler'ı yeniden başlat
docker-compose restart airflow-scheduler
```

## 🔗 Bağımlılıklar

Week 4 eğitiminin parçasıdır:
- ✅ PostgreSQL (OLTP/OLAP)
- ✅ MinIO (Data Lake)
- ✅ Spark (opsiyonel)
- ✅ `datawarehouse_network` network

## 📚 Öğrenme Kaynakları

- [Airflow Documentation](https://airflow.apache.org/docs/)
- [Airflow Concepts](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html)
- [Airflow Best Practices](https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html)
- [Airflow Providers](https://airflow.apache.org/docs/apache-airflow-providers/)

## 💡 İpuçları

1. **Geliştirme**: Task'ı önce `airflow tasks test` ile test et
2. **Debug**: Task loglarını Web UI'dan oku
3. **Schedule**: Cron expression'ları test et (crontab.guru)
4. **XCom**: Küçük veriler için kullan (<1MB)
5. **Backfill**: Dikkatli kullan, tüm tarihleri çalıştırır