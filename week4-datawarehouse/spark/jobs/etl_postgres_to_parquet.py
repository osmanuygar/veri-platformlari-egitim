#!/usr/bin/env python3
"""
Spark ETL Job: PostgreSQL → Parquet → MinIO
OLTP database'den veri çeker, Parquet formatına dönüştürür ve MinIO'ya yazar
"""

from pyspark.sql import SparkSession
import sys

# JDBC bağlantı bilgileri
POSTGRES_HOST = "postgres-oltp"
POSTGRES_PORT = "5432"
POSTGRES_DB = "ecommerce_oltp"
POSTGRES_USER = "oltp_user"
POSTGRES_PASSWORD = "oltp_pass123"

# MinIO bilgileri
MINIO_ENDPOINT = "http://minio:9000"
MINIO_ACCESS_KEY = "minio_admin"
MINIO_SECRET_KEY = "minio_password123"
MINIO_BUCKET = "processed-data"


def create_spark_session():
    """Spark session oluştur (MinIO/S3 konfigürasyonu ile)"""

    spark = SparkSession.builder \
        .appName("PostgreSQL to Parquet ETL") \
        .config("spark.hadoop.fs.s3a.endpoint", MINIO_ENDPOINT) \
        .config("spark.hadoop.fs.s3a.access.key", MINIO_ACCESS_KEY) \
        .config("spark.hadoop.fs.s3a.secret.key", MINIO_SECRET_KEY) \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.jars.packages", "org.postgresql:postgresql:42.6.0,org.apache.hadoop:hadoop-aws:3.3.4") \
        .getOrCreate()

    spark.sparkContext.setLogLevel("WARN")
    return spark


def read_from_postgres(spark, table_name):
    """PostgreSQL'den tablo oku"""

    print(f"[READ] PostgreSQL'den okuma: {table_name}")

    jdbc_url = f"jdbc:postgresql://{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"

    df = spark.read \
        .format("jdbc") \
        .option("url", jdbc_url) \
        .option("dbtable", table_name) \
        .option("user", POSTGRES_USER) \
        .option("password", POSTGRES_PASSWORD) \
        .option("driver", "org.postgresql.Driver") \
        .load()

    print(f"  ✓ {df.count()} satır okundu")
    return df


def write_to_parquet(df, table_name):
    """Parquet formatında MinIO'ya yaz"""

    print(f"[WRITE] MinIO'ya yazma: {table_name}")

    output_path = f"s3a://{MINIO_BUCKET}/spark-etl/{table_name}/"

    df.write \
        .mode("overwrite") \
        .parquet(output_path)

    print(f"  ✓ Yazıldı: {output_path}")


def main():
    """Ana ETL süreci"""

    print("=" * 60)
    print("Spark ETL: PostgreSQL → Parquet → MinIO")
    print("=" * 60)

    # Spark session
    spark = create_spark_session()

    # İşlenecek tablolar
    tables = ["customers", "products", "orders", "order_items"]

    try:
        for table in tables:
            print(f"\n[{table.upper()}]")

            # PostgreSQL'den oku
            df = read_from_postgres(spark, table)

            # Schema'yı göster
            print(f"  Schema:")
            df.printSchema()

            # Örnek veri göster
            print(f"  İlk 3 satır:")
            df.show(3, truncate=False)

            # MinIO'ya yaz
            write_to_parquet(df, table)

            print(f"  ✓ {table} işlendi")

        print("\n" + "=" * 60)
        print("✓ ETL Tamamlandı!")
        print("=" * 60)

    except Exception as e:
        print(f"\n✗ Hata: {e}")
        sys.exit(1)

    finally:
        spark.stop()


if __name__ == "__main__":
    main()