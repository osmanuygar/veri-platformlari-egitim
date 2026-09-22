# Hafta 6 — Airflow + dbt aynı image'de
#
# Neden birlikte? BashOperator'ın konteyner içinden `dbt run` çalıştırabilmesi
# için dbt'nin o image'de kurulu olması gerekiyor. Production'da bunun yerine
# KubernetesPodOperator ya da ayrı bir dbt image'i (Cosmos, dbt Cloud) tercih edilir.
FROM apache/airflow:2.9.3-python3.11

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential libpq-dev git \
    && rm -rf /var/lib/apt/lists/*

USER airflow
RUN pip install --no-cache-dir \
    dbt-core==1.8.8 \
    dbt-postgres==1.8.2 \
    duckdb==1.1.1 \
    psycopg2-binary==2.9.9
