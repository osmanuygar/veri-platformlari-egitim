FROM python:3.11-slim
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*
RUN pip install --no-cache-dir mlflow==2.16.2 psycopg2-binary==2.9.9 boto3==1.35.36
