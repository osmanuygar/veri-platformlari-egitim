"""
Hafta 6 — Alıştırma 1.4: backfill

Bu DAG kasıtlı olarak geçmişe dönük bir start_date ile tanımlı ve
catchup=True. Airflow UI'dan tetiklediğinizde ya da
`airflow dags backfill` komutuyla geçmiş tarihler için nasıl "yakalama"
yaptığını gözlemlemek için kullanın.

    docker exec week06_airflow airflow dags backfill \
        week06_backfill_demo --start-date 2026-01-01 --end-date 2026-01-05
"""
from __future__ import annotations

import pendulum
from airflow.decorators import dag, task


@dag(
    dag_id="week06_backfill_demo",
    schedule="@daily",
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    catchup=True,
    tags=["week06", "backfill"],
)
def week06_backfill_demo():

    @task
    def report_run(data_interval_start=None, data_interval_end=None):
        print(f"Bu çalıştırma şu veri aralığını işliyor: "
              f"{data_interval_start} → {data_interval_end}")
        print("Gerçek bir DAG'da burada 'o güne ait' veriyi işlerdik — "
              "'bugünün' verisini değil.")

    report_run()


week06_backfill_demo()
