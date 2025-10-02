#!/usr/bin/env python3
"""
Spark Job: MinIO'dan Parquet Okuma ve Analiz
MinIO'daki Parquet dosyalarını okur ve temel analizler yapar
"""

from pyspark.sql import SparkSession
from pyspark.sql import functions as F


def create_spark_session():
    """Spark session oluştur"""

    spark = SparkSession.builder \
        .appName("Read from MinIO") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
        .config("spark.hadoop.fs.s3a.access.key", "minio_admin") \
        .config("spark.hadoop.fs.s3a.secret.key", "minio_password123") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.jars.packages", "org.apache.hadoop:hadoop-aws:3.3.4") \
        .getOrCreate()

    spark.sparkContext.setLogLevel("WARN")
    return spark


def read_parquet(spark, path):
    """Parquet dosyasını oku"""

    print(f"[READ] {path}")
    df = spark.read.parquet(path)
    print(f"  ✓ {df.count()} satır okundu")
    return df


def analyze_customers(spark):
    """Müşteri analizi"""

    print("\n" + "=" * 60)
    print("MÜŞTERİ ANALİZİ")
    print("=" * 60)

    # Parquet'i oku
    df = read_parquet(spark, "s3a://processed-data/spark-etl/customers/")

    # Schema
    print("\nSchema:")
    df.printSchema()

    # Şehir bazında müşteri sayısı
    print("\nŞehir bazında müşteri sayısı:")
    df.groupBy("city") \
        .count() \
        .orderBy("count", ascending=False) \
        .show()

    # Ülke bazında müşteri sayısı
    print("\nÜlke bazında müşteri sayısı:")
    df.groupBy("country") \
        .count() \
        .show()


def analyze_products(spark):
    """Ürün analizi"""

    print("\n" + "=" * 60)
    print("ÜRÜN ANALİZİ")
    print("=" * 60)

    # Parquet'i oku
    df = read_parquet(spark, "s3a://processed-data/spark-etl/products/")

    # Kategori bazında ürün sayısı
    print("\nKategori bazında ürün sayısı:")
    df.groupBy("category_name") \
        .count() \
        .orderBy("count", ascending=False) \
        .show()

    # Ortalama fiyat
    print("\nOrtalama fiyat:")
    df.select(F.avg("price").alias("avg_price")).show()

    # En pahalı 5 ürün
    print("\nEn pahalı 5 ürün:")
    df.select("product_name", "price") \
        .orderBy("price", ascending=False) \
        .limit(5) \
        .show(truncate=False)


def analyze_orders(spark):
    """Sipariş analizi"""

    print("\n" + "=" * 60)
    print("SİPARİŞ ANALİZİ")
    print("=" * 60)

    # Parquet'i oku
    df = read_parquet(spark, "s3a://processed-data/spark-etl/orders/")

    # Sipariş durumu bazında sayı
    print("\nSipariş durumuna göre dağılım:")
    df.groupBy("order_status") \
        .count() \
        .orderBy("count", ascending=False) \
        .show()

    # Ödeme durumu
    print("\nÖdeme durumuna göre dağılım:")
    df.groupBy("payment_status") \
        .count() \
        .show()

    # Toplam sipariş tutarı
    print("\nToplam sipariş istatistikleri:")
    df.select(
        F.sum("total_amount").alias("total_revenue"),
        F.avg("total_amount").alias("avg_order_value"),
        F.count("order_id").alias("total_orders")
    ).show()


def analyze_order_items(spark):
    """Sipariş detay analizi"""

    print("\n" + "=" * 60)
    print("SİPARİŞ DETAY ANALİZİ")
    print("=" * 60)

    # Parquet'i oku
    df = read_parquet(spark, "s3a://processed-data/spark-etl/order_items/")

    # Ürün bazında satış
    print("\nÜrün bazında satış toplamı (Top 10):")
    df.groupBy("product_id") \
        .agg(
        F.sum("quantity").alias("total_quantity"),
        F.sum("total_amount").alias("total_revenue")
    ) \
        .orderBy("total_revenue", ascending=False) \
        .limit(10) \
        .show()

    # Toplam istatistikler
    print("\nGenel satış istatistikleri:")
    df.select(
        F.sum("quantity").alias("total_items_sold"),
        F.sum("total_amount").alias("total_revenue"),
        F.avg("unit_price").alias("avg_unit_price")
    ).show()


def main():
    """Ana fonksiyon"""

    print("=" * 60)
    print("MinIO Parquet Okuma ve Analiz")
    print("=" * 60)

    # Spark session
    spark = create_spark_session()

    try:
        # Analizler
        analyze_customers(spark)
        analyze_products(spark)
        analyze_orders(spark)
        analyze_order_items(spark)

        print("\n" + "=" * 60)
        print("✓ Tüm analizler tamamlandı!")
        print("=" * 60)

    except Exception as e:
        print(f"\n✗ Hata: {e}")
        import traceback
        traceback.print_exc()

    finally:
        spark.stop()


if __name__ == "__main__":
    main()