"""
Basit ETL DAG Örneği
Extract → Transform → Load pipeline
"""

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
import logging

# Logger
logger = logging.getLogger(__name__)

# Default arguments
default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'email': ['data-team@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}

# DAG tanımı
with DAG(
        dag_id='example_etl_dag',
        default_args=default_args,
        description='Basit ETL pipeline örneği',
        schedule='0 2 * * *',  # Her gün 02:00
        start_date=datetime(2024, 1, 1),
        catchup=False,
        tags=['example', 'etl', 'tutorial'],
        doc_md="""
    ## ETL Pipeline Örneği

    Bu DAG basit bir ETL pipeline'ı gösterir:
    1. **Extract**: Veri kaynağından veri çek
    2. **Transform**: Veriyi dönüştür
    3. **Load**: Hedefe yükle
    4. **Notify**: Başarı bildirimi
    """,
) as dag:
    # ========================================
    # Task Functions
    # ========================================

    def extract_data(**context):
        """Veri çekme simülasyonu"""
        logger.info("🔍 Veri çekme başladı...")

        # Simulated data
        data = {
            'customers': 100,
            'orders': 250,
            'revenue': 15000.50
        }

        logger.info(f"✓ Veri çekildi: {data}")

        # XCom'a yaz
        context['ti'].xcom_push(key='raw_data', value=data)
        return data


    def transform_data(**context):
        """Veri dönüştürme"""
        logger.info("⚙️ Veri dönüştürme başladı...")

        # XCom'dan oku
        raw_data = context['ti'].xcom_pull(
            task_ids='extract',
            key='raw_data'
        )

        logger.info(f"Ham veri: {raw_data}")

        # Transform
        transformed_data = {
            'total_customers': raw_data['customers'],
            'total_orders': raw_data['orders'],
            'total_revenue': raw_data['revenue'],
            'avg_order_value': round(raw_data['revenue'] / raw_data['orders'], 2),
            'orders_per_customer': round(raw_data['orders'] / raw_data['customers'], 2)
        }

        logger.info(f"✓ Veri dönüştürüldü: {transformed_data}")

        # XCom'a yaz
        context['ti'].xcom_push(key='transformed_data', value=transformed_data)
        return transformed_data


    def load_data(**context):
        """Veri yükleme simülasyonu"""
        logger.info("📤 Veri yükleme başladı...")

        # XCom'dan oku
        transformed_data = context['ti'].xcom_pull(
            task_ids='transform',
            key='transformed_data'
        )

        logger.info(f"Yüklenecek veri: {transformed_data}")

        # Simulated load
        logger.info("✓ Veri hedefe yüklendi")

        return "Load completed successfully"


    def notify_success(**context):
        """Başarı bildirimi"""
        logger.info("📧 Başarı bildirimi gönderiliyor...")

        # Get all results
        raw_data = context['ti'].xcom_pull(task_ids='extract', key='raw_data')
        transformed_data = context['ti'].xcom_pull(task_ids='transform', key='transformed_data')

        message = f"""
        ✅ ETL Pipeline Başarılı!

        📊 Özet:
        - Müşteriler: {raw_data['customers']}
        - Siparişler: {raw_data['orders']}
        - Gelir: ${raw_data['revenue']}
        - Ortalama Sipariş: ${transformed_data['avg_order_value']}
        """

        logger.info(message)
        return "Notification sent"


    # ========================================
    # Tasks
    # ========================================

    # Start task
    start = BashOperator(
        task_id='start',
        bash_command='echo "🚀 ETL Pipeline başlıyor..."',
    )

    # Extract
    extract = PythonOperator(
        task_id='extract',
        python_callable=extract_data,
        doc_md="Veri kaynağından ham veri çeker",
    )

    # Transform
    transform = PythonOperator(
        task_id='transform',
        python_callable=transform_data,
        doc_md="Ham veriyi business logic'e göre dönüştürür",
    )

    # Load
    load = PythonOperator(
        task_id='load',
        python_callable=load_data,
        doc_md="Dönüştürülmüş veriyi hedefe yükler",
    )

    # Notify
    notify = PythonOperator(
        task_id='notify',
        python_callable=notify_success,
        doc_md="Başarı durumunu bildirir",
    )

    # End task
    end = BashOperator(
        task_id='end',
        bash_command='echo "✅ ETL Pipeline tamamlandı!"',
    )

    # ========================================
    # Task Dependencies
    # ========================================

    start >> extract >> transform >> load >> notify >> end