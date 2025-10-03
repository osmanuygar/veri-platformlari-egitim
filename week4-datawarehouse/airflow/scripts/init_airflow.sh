#!/bin/bash
# Airflow İlk Kurulum ve Connection Setup

echo "================================================"
echo "Airflow İlk Kurulum ve Connection Setup"
echo "================================================"

# PostgreSQL OLTP Connection
echo "[1/3] PostgreSQL OLTP connection ekleniyor..."
airflow connections add 'postgres_oltp' \
    --conn-type 'postgres' \
    --conn-host 'postgres-oltp' \
    --conn-schema 'ecommerce_oltp' \
    --conn-login 'oltp_user' \
    --conn-password 'oltp_pass123' \
    --conn-port 5432 \
    2>/dev/null || echo "  ⚠ Connection zaten mevcut: postgres_oltp"

# PostgreSQL OLAP Connection
echo "[2/3] PostgreSQL OLAP connection ekleniyor..."
airflow connections add 'postgres_olap' \
    --conn-type 'postgres' \
    --conn-host 'postgres-olap' \
    --conn-schema 'ecommerce_dw' \
    --conn-login 'olap_user' \
    --conn-password 'olap_pass123' \
    --conn-port 5432 \
    2>/dev/null || echo "  ⚠ Connection zaten mevcut: postgres_olap"

# MinIO/S3 Connection
echo "[3/3] MinIO connection ekleniyor..."
airflow connections add 'minio_conn' \
    --conn-type 'aws' \
    --conn-extra '{"aws_access_key_id":"minio_admin","aws_secret_access_key":"minio_password123","endpoint_url":"http://minio:9000"}' \
    2>/dev/null || echo "  ⚠ Connection zaten mevcut: minio_conn"

echo ""
echo "================================================"
echo "✓ Connection'lar hazır!"
echo "================================================"
echo ""
echo "Connection'ları kontrol et:"
echo "  airflow connections list"
echo ""
echo "Veya Web UI'dan:"
echo "  Admin > Connections"
echo ""
echo "================================================"