"""
PostgreSQL → MinIO ETL DAG
OLTP database'den veri çekip MinIO'ya Parquet olarak yükler
"""

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime, timedelta
import pandas as pd
from minio import Minio
import logging
import io

logger = logging.getLogger(__name__)

# Default arguments
default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

# MinIO Configuration
MINIO_ENDPOINT = "minio:9000"
MINIO_ACCESS_KEY = "minio_admin"
MINIO_SECRET_KEY = "minio_password123"
MINIO_BUCKET = "raw-data"


def get_minio_client():
    """MinIO client oluştur"""
    return Minio(
        MINIO_ENDPOINT,
        access_key=MINIO_ACCESS_KEY,
        secret_key=MINIO_SECRET_KEY,
        secure=False
    )


def extract_from_postgres(table_name, **context):
    """PostgreSQL'den veri çek"""
    logger.info(f"📥 {table_name} tablosu çekiliyor...")

    # PostgresHook ile bağlan
    # Not: Connection 'postgres_oltp' Web UI'dan tanımlanmalı
    hook = PostgresHook(postgres_conn_id='postgres_oltp')

    # SQL query
    sql = f"SELECT * FROM {table_name}"

    # DataFrame'e çevir
    df = hook.get_pandas_df(sql)

    logger.info(f"✓ {len(df)} satır çekildi")

    # XCom'a kaydet (küçük veriler için)
    context['ti'].xcom_push(key=f'{table_name}_count', value=len(df))

    return df


def upload_to_minio(table_name, **context):
    """MinIO'ya Parquet olarak yükle"""
    logger.info(f"📤 {table_name} MinIO'ya yükleniyor...")

    # Önceki task'tan veri al
    df = context['ti'].xcom_pull(task_ids=f'extract_{table_name}')

    if df is None or len(df) == 0:
        logger.warning(f"⚠ {table_name} için veri yok")
        return

    # Parquet buffer'a yaz
    buffer = io.BytesIO()
    df.to_parquet(buffer, engine='pyarrow', compression='snappy', index=False)
    buffer.seek(0)

    # MinIO client
    client = get_minio_client()

    # Bucket kontrolü
    if not client.bucket_exists(MINIO_BUCKET):
        client.make_bucket(MINIO_BUCKET)
        logger.info(f"✓ Bucket oluşturuldu: {MINIO_BUCKET}")

    # Dosya adı (timestamp ile)
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    object_name = f"airflow-etl/{table_name}/{timestamp}.parquet"

    # MinIO'ya yükle
    client.put_object(
        MINIO_BUCKET,
        object_name,
        buffer,
        length=buffer.getbuffer().nbytes,
        content_type='application/octet-stream'
    )

    logger.info(f"✓ Yüklendi: {object_name} ({len(df)} satır)")

    return object_name


# DAG tanımı
with DAG(
        dag_id='postgres_to_minio_dag',
        default_args=default_args,
        description='PostgreSQL verilerini MinIO\'ya Parquet olarak yükle',
        schedule='0 3 * * *',  # Her gün 03:00
        start_date=datetime(2024, 1, 1),
        catchup=False,
        tags=['etl', 'postgres', 'minio', 'parquet'],
        doc_md="""
    ## PostgreSQL → MinIO ETL

    Bu DAG:
    1. PostgreSQL OLTP database'den 3 tablo çeker
    2. Her tabloyu Parquet formatına dönüştürür
    3. MinIO Data Lake'e yükler

    **Tablolar:**
    - customers
    - products
    - orders
    """,
) as dag:
    # Tablolar
    tables = ['customers', 'products', 'orders']

    # Her tablo için extract ve upload task'ları oluştur
    for table in tables:
        extract_task = PythonOperator(
            task_id=f'extract_{table}',
            python_callable=extract_from_postgres,
            op_kwargs={'table_name': table},
        )

        upload_task = PythonOperator(
            task_id=f'upload_{table}',
            python_callable=upload_to_minio,
            op_kwargs={'table_name': table},
        )

        # Task bağımlılığı
        extract_task >> upload_task