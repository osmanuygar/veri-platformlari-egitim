"""
Günlük Satış Raporu DAG
Her gün satış verilerini analiz eder ve rapor oluşturur
"""

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from datetime import datetime, timedelta
import pandas as pd
import logging

logger = logging.getLogger(__name__)

# Default arguments
default_args = {
    'owner': 'analytics-team',
    'depends_on_past': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=3),
}


def calculate_daily_sales(**context):
    """Günlük satış toplamlarını hesapla"""
    logger.info("📊 Günlük satış hesaplanıyor...")

    # Execution date (DAG'ın çalıştığı tarih)
    execution_date = context['execution_date']
    target_date = execution_date.strftime('%Y-%m-%d')

    logger.info(f"Hedef tarih: {target_date}")

    # PostgreSQL'den veri çek
    hook = PostgresHook(postgres_conn_id='postgres_olap')

    sql = f"""
    SELECT 
        d.date,
        COUNT(DISTINCT f.order_id) as order_count,
        SUM(f.quantity) as total_quantity,
        SUM(f.net_amount) as total_revenue,
        AVG(f.unit_price) as avg_price
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    WHERE d.date = '{target_date}'
    GROUP BY d.date
    """

    df = hook.get_pandas_df(sql)

    if len(df) == 0:
        logger.warning(f"⚠ {target_date} için satış verisi yok")
        return None

    result = df.to_dict('records')[0]
    logger.info(f"✓ Günlük satış: {result}")

    # XCom'a yaz
    context['ti'].xcom_push(key='daily_sales', value=result)

    return result


def aggregate_by_product(**context):
    """Ürün bazında satışları topla"""
    logger.info("📦 Ürün bazında toplama yapılıyor...")

    execution_date = context['execution_date']
    target_date = execution_date.strftime('%Y-%m-%d')

    hook = PostgresHook(postgres_conn_id='postgres_olap')

    sql = f"""
    SELECT 
        p.product_id,
        p.product_name,
        p.category_name,
        SUM(f.quantity) as total_quantity,
        SUM(f.net_amount) as total_revenue
    FROM fact_sales f
    JOIN dim_product p ON f.product_id = p.product_id
    JOIN dim_date d ON f.date_key = d.date_key
    WHERE d.date = '{target_date}'
    GROUP BY p.product_id, p.product_name, p.category_name
    ORDER BY total_revenue DESC
    LIMIT 10
    """

    df = hook.get_pandas_df(sql)

    if len(df) == 0:
        logger.warning(f"⚠ {target_date} için ürün verisi yok")
        return None

    result = df.to_dict('records')
    logger.info(f"✓ Top 10 ürün: {len(result)} kayıt")

    # XCom'a yaz
    context['ti'].xcom_push(key='top_products', value=result)

    return result


def aggregate_by_category(**context):
    """Kategori bazında satışları topla"""
    logger.info("🏷️ Kategori bazında toplama yapılıyor...")

    execution_date = context['execution_date']
    target_date = execution_date.strftime('%Y-%m-%d')

    hook = PostgresHook(postgres_conn_id='postgres_olap')

    sql = f"""
    SELECT 
        p.category_name,
        COUNT(DISTINCT f.product_id) as product_count,
        SUM(f.quantity) as total_quantity,
        SUM(f.net_amount) as total_revenue
    FROM fact_sales f
    JOIN dim_product p ON f.product_id = p.product_id
    JOIN dim_date d ON f.date_key = d.date_key
    WHERE d.date = '{target_date}'
    GROUP BY p.category_name
    ORDER BY total_revenue DESC
    """

    df = hook.get_pandas_df(sql)

    if len(df) == 0:
        logger.warning(f"⚠ {target_date} için kategori verisi yok")
        return None

    result = df.to_dict('records')
    logger.info(f"✓ Kategori analizi: {len(result)} kategori")

    # XCom'a yaz
    context['ti'].xcom_push(key='category_sales', value=result)

    return result


def save_report(**context):
    """Raporu kaydet ve özet oluştur"""
    logger.info("💾 Rapor kaydediliyor...")

    execution_date = context['execution_date']
    target_date = execution_date.strftime('%Y-%m-%d')

    # XCom'dan verileri al
    daily_sales = context['ti'].xcom_pull(task_ids='calculate_daily_sales', key='daily_sales')
    top_products = context['ti'].xcom_pull(task_ids='aggregate_by_product', key='top_products')
    category_sales = context['ti'].xcom_pull(task_ids='aggregate_by_category', key='category_sales')

    # Rapor oluştur
    report = f"""
    ====================================
    GÜNLÜK SATIŞ RAPORU
    Tarih: {target_date}
    ====================================

    📊 GENEL ÖZET:
    - Sipariş Sayısı: {daily_sales.get('order_count', 0) if daily_sales else 0}
    - Toplam Ürün: {daily_sales.get('total_quantity', 0) if daily_sales else 0}
    - Toplam Gelir: ${daily_sales.get('total_revenue', 0):.2f if daily_sales else 0:.2f}
    - Ortalama Fiyat: ${daily_sales.get('avg_price', 0):.2f if daily_sales else 0:.2f}

    🏆 TOP 10 ÜRÜN:
    """

    if top_products:
        for i, product in enumerate(top_products, 1):
            report += f"\n    {i}. {product['product_name']}: ${product['total_revenue']:.2f}"

    report += "\n\n📦 KATEGORİ ANALİZİ:\n"

    if category_sales:
        for cat in category_sales:
            report += f"\n    {cat['category_name']}: ${cat['total_revenue']:.2f} ({cat['product_count']} ürün)"

    report += "\n\n===================================="

    logger.info(report)

    # Raporu dosyaya kaydet (opsiyonel)
    # report_path = f"/opt/airflow/logs/sales_report_{target_date}.txt"
    # with open(report_path, 'w') as f:
    #     f.write(report)

    return "Report saved successfully"


# DAG tanımı
with DAG(
        dag_id='daily_sales_dag',
        default_args=default_args,
        description='Günlük satış raporu oluştur',
        schedule='0 4 * * *',  # Her gün 04:00
        start_date=datetime(2024, 1, 1),
        catchup=False,
        tags=['analytics', 'sales', 'daily', 'report'],
        doc_md="""
    ## Günlük Satış Raporu

    Bu DAG her gün:
    1. Günlük satış toplamlarını hesaplar
    2. Ürün bazında analiz yapar
    3. Kategori bazında analiz yapar
    4. Kapsamlı rapor oluşturur

    **Çalışma saati:** 04:00 (ETL'den sonra)
    """,
) as dag:
    # Start
    start = BashOperator(
        task_id='start',
        bash_command='echo "📈 Günlük satış raporu başlıyor..."',
    )

    # Calculate daily sales
    calc_sales = PythonOperator(
        task_id='calculate_daily_sales',
        python_callable=calculate_daily_sales,
    )

    # Aggregate by product
    agg_product = PythonOperator(
        task_id='aggregate_by_product',
        python_callable=aggregate_by_product,
    )

    # Aggregate by category
    agg_category = PythonOperator(
        task_id='aggregate_by_category',
        python_callable=aggregate_by_category,
    )

    # Save report
    save = PythonOperator(
        task_id='save_report',
        python_callable=save_report,
    )

    # End
    end = BashOperator(
        task_id='end',
        bash_command='echo "✅ Günlük satış raporu tamamlandı!"',
    )

    # Task dependencies (parallel aggregations)
    start >> calc_sales >> [agg_product, agg_category] >> save >> end