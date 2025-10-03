# Custom Airflow Dockerfile (opsiyonel - extra dependencies için)
FROM apache/airflow:2.7.3-python3.11
LABEL authors="osmanuygar.kose"
USER root

# System dependencies (gerekirse)
# RUN apt-get update && apt-get install -y \
#     some-package \
#     && rm -rf /var/lib/apt/lists/*

USER airflow

# Python dependencies
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Custom modules (gerekirse)
# COPY --chown=airflow:root ./custom_modules /opt/airflow/custom_modules