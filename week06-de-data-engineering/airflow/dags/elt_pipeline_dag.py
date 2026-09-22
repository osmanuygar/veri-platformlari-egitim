"""
Hafta 6 — Alıştırma 1: uçtan uca ELT DAG'ı

extract_new_orders  →  dbt_run  →  dbt_test  →  publish_summary
                                        │
                                        └── başarısız olursa dbt_run'ı
                                            tekrar denemez (retry mantıksız
                                            olurdu); alarm task'ı tetiklenir

Neden ELT (extract-load-TRANSFORM) ve ETL değil? Dönüşüm zaten Postgres
içinde (dbt ile) yapılıyor. Veri önce olduğu gibi yüklenir, dönüşüm SQL
motorunun gücüyle SONRA yapılır — hafta 6 ders notundaki "ETL'den ELT'ye
geçiş" bölümünün canlı örneği.
"""
from __future__ import annotations

import pendulum
from airflow.decorators import dag, task
from airflow.operators.bash import BashOperator
from airflow.exceptions import AirflowFailException

DBT_DIR = "/opt/dbt_project"
DBT_ENV = {
    "DBT_PROFILES_DIR": f"{DBT_DIR}/profiles",
}


@dag(
    dag_id="week06_elt_pipeline",
    description="raw → dbt (staging+marts) → test → özet",
    schedule="@daily",
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    catchup=False,
    tags=["week06", "elt", "dbt"],
    default_args={"retries": 1, "retry_delay": pendulum.duration(minutes=2)},
)
def week06_elt_pipeline():

    @task
    def extract_new_orders() -> int:
        """Gerçek hayatta burada bir API/dosya/kaynak veritabanından çekim olurdu.
        Bu haftanın verisi zaten Postgres'te (init/ ile yüklendi), o yüzden
        sadece kaç satır olduğunu doğrulayıp XCom'a yazıyoruz."""
        import psycopg2
        conn = psycopg2.connect(
            host="postgres", port=5432, user="de_user", password="de_pass", dbname="de_db"
        )
        with conn.cursor() as cur:
            cur.execute("SELECT count(*) FROM raw.raw_orders")
            (n,) = cur.fetchone()
        conn.close()
        if n == 0:
            raise AirflowFailException("raw.raw_orders boş — init scriptleri çalışmamış olabilir")
        return n

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"cd {DBT_DIR} && dbt deps",
        env=DBT_ENV,
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=f"cd {DBT_DIR} && dbt run",
        env=DBT_ENV,
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {DBT_DIR} && dbt test",
        env=DBT_ENV,
    )

    @task
    def publish_summary(order_count: int):
        """Gerçek hayatta burada bir Slack/e-posta bildirimi olurdu."""
        print(f"✅ Pipeline tamam. Kaynakta {order_count} sipariş işlendi.")
        print("   analytics.customer_segment ve analytics.daily_sales_summary güncel.")

    n = extract_new_orders()
    n >> dbt_deps >> dbt_run >> dbt_test >> publish_summary(n)


week06_elt_pipeline()
