#!/usr/bin/env python3
"""
CSV ve JSON dosyalarını Parquet formatına dönüştür ve MinIO'ya yükle
"""

import pandas as pd
from minio import Minio
from minio.error import S3Error
import os
import json

# MinIO ayarları
MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT", "localhost:9000")
MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY", "minio_admin")
MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY", "minio_password123")
BUCKET_NAME = "processed-data"


def create_parquet_files():
    """CSV ve JSON'ı Parquet'e dönüştür"""

    print("=" * 60)
    print("CSV/JSON → Parquet Dönüşümü")
    print("=" * 60)

    # MinIO client
    client = Minio(
        MINIO_ENDPOINT,
        access_key=MINIO_ACCESS_KEY,
        secret_key=MINIO_SECRET_KEY,
        secure=False
    )

    # Bucket kontrolü
    if not client.bucket_exists(BUCKET_NAME):
        print(f"✗ Bucket bulunamadı: {BUCKET_NAME}")
        return

    # 1. Customers CSV → Parquet
    print("\n[1/3] Customers: CSV → Parquet")
    try:
        df_customers = pd.read_csv("../sample-data/customers.csv")

        # Veri tipi optimizasyonu
        df_customers['customer_id'] = df_customers['customer_id'].astype('int32')
        df_customers['registration_date'] = pd.to_datetime(df_customers['registration_date'])

        print(f"  ✓ Okundu: {len(df_customers)} kayıt")

        # Parquet olarak kaydet
        parquet_file = "/tmp/customers.parquet"
        df_customers.to_parquet(
            parquet_file,
            engine='pyarrow',
            compression='snappy',
            index=False
        )

        # MinIO'ya yükle
        client.fput_object(
            BUCKET_NAME,
            "tables/customers/customers.parquet",
            parquet_file
        )

        file_size = os.path.getsize(parquet_file) / 1024
        print(f"  ✓ Parquet oluşturuldu ve yüklendi ({file_size:.2f} KB)")
        os.remove(parquet_file)

    except Exception as e:
        print(f"  ✗ Hata: {e}")

    # 2. Products JSON → Parquet
    print("\n[2/3] Products: JSON → Parquet")
    try:
        df_products = pd.read_json("../sample-data/products.json")

        # Veri tipi optimizasyonu
        df_products['product_id'] = df_products['product_id'].astype('int32')
        df_products['price'] = df_products['price'].astype('float32')
        df_products['stock'] = df_products['stock'].astype('int32')

        print(f"  ✓ Okundu: {len(df_products)} kayıt")

        # Parquet olarak kaydet
        parquet_file = "/tmp/products.parquet"
        df_products.to_parquet(
            parquet_file,
            engine='pyarrow',
            compression='snappy',
            index=False
        )

        # MinIO'ya yükle
        client.fput_object(
            BUCKET_NAME,
            "tables/products/products.parquet",
            parquet_file
        )

        file_size = os.path.getsize(parquet_file) / 1024
        print(f"  ✓ Parquet oluşturuldu ve yüklendi ({file_size:.2f} KB)")
        os.remove(parquet_file)

    except Exception as e:
        print(f"  ✗ Hata: {e}")

    # 3. Sales CSV → Parquet (Partitioned by date)
    print("\n[3/3] Sales: CSV → Partitioned Parquet")
    try:
        df_sales = pd.read_csv("../sample-data/sales.csv")

        # Veri tipi optimizasyonu
        df_sales['sale_id'] = df_sales['sale_id'].astype('int32')
        df_sales['customer_id'] = df_sales['customer_id'].astype('int32')
        df_sales['product_id'] = df_sales['product_id'].astype('int32')
        df_sales['quantity'] = df_sales['quantity'].astype('int32')
        df_sales['sale_date'] = pd.to_datetime(df_sales['sale_date'])

        # Yıl ve ay sütunları ekle (partitioning için)
        df_sales['year'] = df_sales['sale_date'].dt.year
        df_sales['month'] = df_sales['sale_date'].dt.month

        print(f"  ✓ Okundu: {len(df_sales)} kayıt")

        # Partitioned parquet olarak kaydet
        parquet_dir = "/tmp/sales_partitioned"
        df_sales.to_parquet(
            parquet_dir,
            engine='pyarrow',
            compression='snappy',
            partition_cols=['year', 'month'],
            index=False
        )

        # Tüm partition dosyalarını yükle
        uploaded_count = 0
        for root, dirs, files in os.walk(parquet_dir):
            for file in files:
                if file.endswith('.parquet'):
                    local_path = os.path.join(root, file)
                    relative_path = os.path.relpath(local_path, parquet_dir)
                    object_name = f"tables/sales/{relative_path}"

                    client.fput_object(
                        BUCKET_NAME,
                        object_name,
                        local_path
                    )
                    uploaded_count += 1

        print(f"  ✓ Partitioned parquet oluşturuldu ve yüklendi ({uploaded_count} dosya)")

        # Temizlik
        import shutil
        shutil.rmtree(parquet_dir)

    except Exception as e:
        print(f"  ✗ Hata: {e}")

    # Özet
    print("\n" + "=" * 60)
    print("Dönüşüm Tamamlandı!")
    print("=" * 60)

    print("\nParquet dosyaları:")
    objects = client.list_objects(BUCKET_NAME, prefix="tables/", recursive=True)
    for obj in objects:
        size_kb = obj.size / 1024
        print(f"  - {obj.object_name} ({size_kb:.2f} KB)")


if __name__ == "__main__":
    create_parquet_files()