#!/usr/bin/env python3
"""
MinIO'ya örnek verileri yükle
"""

from minio import Minio
from minio.error import S3Error
import os

# MinIO bağlantı ayarları
MINIO_ENDPOINT = "localhost:9000"
MINIO_ACCESS_KEY = "minio_admin"
MINIO_SECRET_KEY = "minio_password123"
BUCKET_NAME = "raw-data"


def upload_sample_data():
    """Örnek verileri MinIO'ya yükle"""

    # MinIO client oluştur
    client = Minio(
        MINIO_ENDPOINT,
        access_key=MINIO_ACCESS_KEY,
        secret_key=MINIO_SECRET_KEY,
        secure=False
    )

    print(f"MinIO'ya bağlanılıyor: {MINIO_ENDPOINT}")

    # Bucket var mı kontrol et
    if not client.bucket_exists(BUCKET_NAME):
        print(f"✗ Bucket bulunamadı: {BUCKET_NAME}")
        return

    print(f"✓ Bucket bulundu: {BUCKET_NAME}")

    # Yüklenecek dosyalar
    sample_dir = "../sample-data"
    files_to_upload = [
        "customers.csv",
        "products.json",
        "sales.csv"
    ]

    # Dosyaları yükle
    for filename in files_to_upload:
        file_path = os.path.join(sample_dir, filename)

        if not os.path.exists(file_path):
            print(f"⚠ Dosya bulunamadı: {file_path}")
            continue

        try:
            # Dosyayı yükle
            client.fput_object(
                BUCKET_NAME,
                f"samples/{filename}",
                file_path
            )
            print(f"✓ Yüklendi: {filename}")

        except S3Error as e:
            print(f"✗ Hata ({filename}): {e}")

    print("\n✓ Yükleme tamamlandı!")

    # Yüklenen dosyaları listele
    print(f"\n{BUCKET_NAME} içeriği:")
    objects = client.list_objects(BUCKET_NAME, recursive=True)
    for obj in objects:
        print(f"  - {obj.object_name} ({obj.size} bytes)")


if __name__ == "__main__":
    upload_sample_data()