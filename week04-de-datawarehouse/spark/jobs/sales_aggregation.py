#!/usr/bin/env python3
"""
Spark Job: Satış Aggregation
Satış verilerini farklı boyutlarda aggregate eder
"""

from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.window import Window


def create_spark_session():
    """Spark session oluştur"""

    spark = SparkSession.builder \
        .appName("Sales Aggregation") \
        .config("spark.hadoop.fs.s3a.endpoint", "http://minio:9000") \
        .config("spark.hadoop.fs.s3a.access.key", "minio_admin") \
        .config("spark.hadoop.fs.s3a.secret.key", "minio_password123") \
        .config("spark.hadoop.fs.s3a.path.style.access", "true") \
        .config("spark.hadoop.fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
        .config("spark.jars.packages", "org.apache.hadoop:hadoop-aws:3.3.4") \
        .getOrCreate()

    spark.sparkContext.setLogLevel("WARN")
    return spark


def load_data(spark):
    """Gerekli tabloları yükle"""

    print("[LOAD] Verileri yüklüyorum...")

    # Order items
    order_items = spark.read.parquet("s3a://processed-data/spark-etl/order_items/")

    # Products
    products = spark.read.parquet("s3a://processed-data/spark-etl/products/")

    # Orders
    orders = spark.read.parquet("s3a://processed-data/spark-etl/orders/")

    print(f"  ✓ Order Items: {order_items.count()} satır")
    print(f"  ✓ Products: {products.count()} satır")
    print(f"  ✓ Orders: {orders.count()} satır")

    return order_items, products, orders


def daily_sales_aggregation(order_items, orders):
    """Günlük satış aggregation"""

    print("\n" + "=" * 60)
    print("GÜNLÜK SATIŞ ANALİZİ")
    print("=" * 60)

    # Join order_items with orders to get date
    df = order_items.join(
        orders.select("order_id", "created_at"),
        "order_id"
    )

    # Extract date
    df = df.withColumn("sale_date", F.to_date("created_at"))

    # Daily aggregation
    daily_sales = df.groupBy("sale_date") \
        .agg(
        F.count("order_item_id").alias("total_items"),
        F.sum("quantity").alias("total_quantity"),
        F.sum("total_amount").alias("total_revenue"),
        F.avg("unit_price").alias("avg_price")
    ) \
        .orderBy("sale_date")

    print("\nGünlük satış özeti:")
    daily_sales.show(10)

    # MinIO'ya kaydet
    output_path = "s3a://processed-data/aggregations/daily_sales/"
    daily_sales.write.mode("overwrite").parquet(output_path)
    print(f"\n✓ Kaydedildi: {output_path}")

    return daily_sales


def product_sales_aggregation(order_items, products):
    """Ürün bazında satış aggregation"""

    print("\n" + "=" * 60)
    print("ÜRÜN BAZINDA SATIŞ ANALİZİ")
    print("=" * 60)

    # Join with products
    df = order_items.join(
        products.select("product_id", "product_name", "category_name"),
        "product_id"
    )

    # Product aggregation
    product_sales = df.groupBy("product_id", "product_name", "category_name") \
        .agg(
        F.sum("quantity").alias("total_quantity_sold"),
        F.sum("total_amount").alias("total_revenue"),
        F.avg("unit_price").alias("avg_price"),
        F.count("order_item_id").alias("times_sold")
    ) \
        .orderBy("total_revenue", ascending=False)

    print("\nÜrün satış özeti (Top 10):")
    product_sales.show(10, truncate=False)

    # MinIO'ya kaydet
    output_path = "s3a://processed-data/aggregations/product_sales/"
    product_sales.write.mode("overwrite").parquet(output_path)
    print(f"\n✓ Kaydedildi: {output_path}")

    return product_sales


def category_sales_aggregation(order_items, products):
    """Kategori bazında satış aggregation"""

    print("\n" + "=" * 60)
    print("KATEGORİ BAZINDA SATIŞ ANALİZİ")
    print("=" * 60)

    # Join with products
    df = order_items.join(
        products.select("product_id", "category_name"),
        "product_id"
    )

    # Category aggregation
    category_sales = df.groupBy("category_name") \
        .agg(
        F.sum("quantity").alias("total_quantity"),
        F.sum("total_amount").alias("total_revenue"),
        F.count("order_item_id").alias("total_items"),
        F.avg("unit_price").alias("avg_price")
    ) \
        .orderBy("total_revenue", ascending=False)

    print("\nKategori satış özeti:")
    category_sales.show(truncate=False)

    # MinIO'ya kaydet
    output_path = "s3a://processed-data/aggregations/category_sales/"
    category_sales.write.mode("overwrite").parquet(output_path)
    print(f"\n✓ Kaydedildi: {output_path}")

    return category_sales


def customer_sales_analysis(order_items, orders):
    """Müşteri bazında satış analizi"""

    print("\n" + "=" * 60)
    print("MÜŞTERİ BAZINDA SATIŞ ANALİZİ")
    print("=" * 60)

    # Join with orders
    df = order_items.join(
        orders.select("order_id", "customer_id"),
        "order_id"
    )

    # Customer aggregation
    customer_sales = df.groupBy("customer_id") \
        .agg(
        F.count("order_item_id").alias("total_items"),
        F.sum("total_amount").alias("total_spent"),
        F.avg("total_amount").alias("avg_order_value"),
        F.countDistinct("order_id").alias("total_orders")
    ) \
        .orderBy("total_spent", ascending=False)

    print("\nMüşteri satış özeti (Top 10):")
    customer_sales.show(10)

    # MinIO'ya kaydet
    output_path = "s3a://processed-data/aggregations/customer_sales/"
    customer_sales.write.mode("overwrite").parquet(output_path)
    print(f"\n✓ Kaydedildi: {output_path}")

    return customer_sales


def running_totals(daily_sales):
    """Kümülatif toplam hesapla (Window function örneği)"""

    print("\n" + "=" * 60)
    print("KÜMÜLATİF TOPLAM (Running Total)")
    print("=" * 60)

    # Window spec
    window_spec = Window.orderBy("sale_date").rowsBetween(Window.unboundedPreceding, 0)

    # Running total
    result = daily_sales.withColumn(
        "cumulative_revenue",
        F.sum("total_revenue").over(window_spec)
    )

    print("\nGünlük ve kümülatif gelir:")
    result.select("sale_date", "total_revenue", "cumulative_revenue").show(10)

    return result


def main():
    """Ana fonksiyon"""

    print("=" * 60)
    print("Satış Aggregation Pipeline")
    print("=" * 60)

    # Spark session
    spark = create_spark_session()

    try:
        # Verileri yükle
        order_items, products, orders = load_data(spark)

        # Aggregation'lar
        daily_sales = daily_sales_aggregation(order_items, orders)
        product_sales = product_sales_aggregation(order_items, products)
        category_sales = category_sales_aggregation(order_items, products)
        customer_sales = customer_sales_analysis(order_items, orders)

        # Window function örneği
        running_totals(daily_sales)

        print("\n" + "=" * 60)
        print("✓ Tüm aggregation'lar tamamlandı!")
        print("=" * 60)

        print("\nOluşturulan agregasyonlar:")
        print("  - s3a://processed-data/aggregations/daily_sales/")
        print("  - s3a://processed-data/aggregations/product_sales/")
        print("  - s3a://processed-data/aggregations/category_sales/")
        print("  - s3a://processed-data/aggregations/customer_sales/")

    except Exception as e:
        print(f"\n✗ Hata: {e}")
        import traceback
        traceback.print_exc()

    finally:
        spark.stop()


if __name__ == "__main__":
    main()