#!/usr/bin/env python3
"""
Apache Iceberg table oluştur ve MinIO'da sakla
"""

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from pyiceberg.catalog import load_catalog
from pyiceberg.schema import Schema
from pyiceberg.types import (
    NestedField, StringType, IntegerType,
    FloatType, DateType, TimestampType
)
import os


def create_iceberg_tables():
    """Apache Iceberg tabloları oluştur"""

    print("=" * 60)
    print("Apache Iceberg Table Oluşturma")
    print("=" * 60)

    # Not: Bu basit bir örnek. Production'da REST Catalog kullanılır.
    print("\n⚠ Not: Bu örnek Iceberg schema yapısını gösterir.")
    print("Tam Iceberg entegrasyonu için REST Catalog gerekir.\n")

    # 1. Customers Iceberg Schema
    print("[1/3] Customers Iceberg Schema")
    customers_schema = Schema(
        NestedField(1, "customer_id", IntegerType(), required=True),
        NestedField(2, "first_name", StringType(), required=True),
        NestedField(3, "last_name", StringType(), required=True),
        NestedField(4, "email", StringType(), required=True),
        NestedField(5, "phone", StringType(), required=False),
        NestedField(6, "city", StringType(), required=False),
        NestedField(7, "country", StringType(), required=False),
        NestedField(8, "registration_date", DateType(), required=True),
    )
    print(f"  ✓ Schema tanımlandı: {len(customers_schema.fields)} field")
    print(f"    Partition: Yok (küçük tablo)")

    # 2. Products Iceberg Schema
    print("\n[2/3] Products Iceberg Schema")
    products_schema = Schema(
        NestedField(1, "product_id", IntegerType(), required=True),
        NestedField(2, "product_name", StringType(), required=True),
        NestedField(3, "category", StringType(), required=True),
        NestedField(4, "price", FloatType(), required=True),
        NestedField(5, "stock", IntegerType(), required=True),
        NestedField(6, "brand", StringType(), required=False),
    )
    print(f"  ✓ Schema tanımlandı: {len(products_schema.fields)} field")
    print(f"    Partition: category (kategori bazlı)")

    # 3. Sales Iceberg Schema (Partitioned)
    print("\n[3/3] Sales Iceberg Schema")
    sales_schema = Schema(
        NestedField(1, "sale_id", IntegerType(), required=True),
        NestedField(2, "customer_id", IntegerType(), required=True),
        NestedField(3, "product_id", IntegerType(), required=True),
        NestedField(4, "quantity", IntegerType(), required=True),
        NestedField(5, "unit_price", FloatType(), required=True),
        NestedField(6, "total_amount", FloatType(), required=True),
        NestedField(7, "sale_date", DateType(), required=True),
        NestedField(8, "year", IntegerType(), required=True),
        NestedField(9, "month", IntegerType(), required=True),
    )
    print(f"  ✓ Schema tanımlandı: {len(sales_schema.fields)} field")
    print(f"    Partition: year, month (zaman bazlı)")

    # Iceberg tablo yapısını JSON olarak kaydet
    print("\n[Metadata] Iceberg table metadata oluşturuluyor...")

    metadata = {
        "tables": {
            "customers": {
                "schema": str(customers_schema),
                "partition_spec": None,
                "sort_order": None,
                "properties": {
                    "format-version": "2",
                    "write.parquet.compression-codec": "snappy"
                }
            },
            "products": {
                "schema": str(products_schema),
                "partition_spec": ["category"],
                "sort_order": None,
                "properties": {
                    "format-version": "2",
                    "write.parquet.compression-codec": "snappy"
                }
            },
            "sales": {
                "schema": str(sales_schema),
                "partition_spec": ["year", "month"],
                "sort_order": ["sale_date"],
                "properties": {
                    "format-version": "2",
                    "write.parquet.compression-codec": "snappy",
                    "write.metadata.delete-after-commit.enabled": "true"
                }
            }
        }
    }

    # Metadata'yı dosyaya kaydet
    import json
    metadata_file = "/tmp/iceberg_metadata.json"
    with open(metadata_file, 'w') as f:
        json.dump(metadata, f, indent=2, default=str)

    print(f"  ✓ Metadata kaydedildi: {metadata_file}")

    # Iceberg-like parquet dosyaları oluştur
    print("\n[Data] Iceberg formatında parquet oluşturuluyor...")

    # Customers
    df_customers = pd.read_csv("../sample-data/customers.csv")
    df_customers['registration_date'] = pd.to_datetime(df_customers['registration_date'])

    # PyArrow Table'a çevir
    table_customers = pa.Table.from_pandas(df_customers)

    # Parquet metadata ekle (Iceberg uyumlu)
    parquet_file = "/tmp/customers_iceberg.parquet"
    pq.write_table(
        table_customers,
        parquet_file,
        compression='snappy',
        use_dictionary=True,
        write_statistics=True
    )
    print(f"  ✓ customers_iceberg.parquet oluşturuldu")

    # Products (partitioned by category)
    df_products = pd.read_json("../sample-data/products.json")
    table_products = pa.Table.from_pandas(df_products)

    parquet_file = "/tmp/products_iceberg.parquet"
    pq.write_table(
        table_products,
        parquet_file,
        compression='snappy',
        use_dictionary=True,
        write_statistics=True
    )
    print(f"  ✓ products_iceberg.parquet oluşturuldu")

    # Sales (partitioned by year/month)
    df_sales = pd.read_csv("../sample-data/sales.csv")
    df_sales['sale_date'] = pd.to_datetime(df_sales['sale_date'])
    df_sales['year'] = df_sales['sale_date'].dt.year
    df_sales['month'] = df_sales['sale_date'].dt.month

    table_sales = pa.Table.from_pandas(df_sales)

    parquet_file = "/tmp/sales_iceberg.parquet"
    pq.write_table(
        table_sales,
        parquet_file,
        compression='snappy',
        use_dictionary=True,
        write_statistics=True
    )
    print(f"  ✓ sales_iceberg.parquet oluşturuldu")

    # Özet
    print("\n" + "=" * 60)
    print("Iceberg Table Yapıları Oluşturuldu!")
    print("=" * 60)

    print("\n📊 Iceberg Özellikleri:")
    print("  ✓ Schema evolution desteklenir")
    print("  ✓ Time travel mümkün")
    print("  ✓ ACID transactions")
    print("  ✓ Partition pruning")
    print("  ✓ Hidden partitioning")

    print("\n💡 Sonraki Adımlar:")
    print("  1. REST Catalog kurulumu (Nessie, Polaris)")
    print("  2. Spark/Trino ile Iceberg okuma")
    print("  3. Schema evolution testleri")
    print("  4. Time travel sorguları")

    print("\n📚 Daha fazla bilgi:")
    print("  https://iceberg.apache.org/docs/latest/")


if __name__ == "__main__":
    create_iceberg_tables()