"""
Load Module - OLAP'a Veri Yükleme
Loads transformed data into OLAP database and Data Lake
"""

import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
from minio import Minio
from minio.error import S3Error
from datetime import datetime
from typing import Dict, List
import io
from config import config, logger


class OLAPLoader:
    """OLAP database loader"""

    def __init__(self):
        self.config = config.olap
        self.conn = None
        self.cursor = None

    def connect(self):
        """Establish connection to OLAP database"""
        try:
            self.conn = psycopg2.connect(
                host=self.config.host,
                port=self.config.port,
                database=self.config.database,
                user=self.config.user,
                password=self.config.password
            )
            self.cursor = self.conn.cursor()
            logger.info(f"✓ Connected to OLAP: {self.config.database}")
            return True
        except Exception as e:
            logger.error(f"✗ Failed to connect to OLAP: {e}")
            raise

    def disconnect(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
            logger.info("✓ Disconnected from OLAP")

    def truncate_table(self, table_name: str):
        """Truncate table for full refresh"""
        try:
            self.cursor.execute(f"TRUNCATE TABLE {table_name} CASCADE")
            self.conn.commit()
            logger.info(f"✓ Truncated {table_name}")
        except Exception as e:
            self.conn.rollback()
            logger.error(f"✗ Failed to truncate {table_name}: {e}")
            raise

    def load_dataframe_bulk(self, df: pd.DataFrame, table_name: str, truncate: bool = True):
        """
        Load DataFrame to OLAP table using bulk insert

        Args:
            df: DataFrame to load
            table_name: Target table name
            truncate: Whether to truncate table first (default: True)
        """
        logger.info(f"← Loading {len(df)} rows to {table_name}...")

        try:
            # Truncate if requested
            if truncate:
                self.truncate_table(table_name)

            # Prepare data
            cols = df.columns.tolist()

            # Convert DataFrame to list of tuples
            data_tuples = [tuple(x) for x in df.to_numpy()]

            # Build INSERT query
            cols_str = ','.join(cols)
            query = f"INSERT INTO {table_name} ({cols_str}) VALUES %s"

            # Execute bulk insert
            execute_values(
                self.cursor,
                query,
                data_tuples,
                template=None,
                page_size=1000
            )

            self.conn.commit()
            logger.info(f"✓ Loaded {len(df)} rows to {table_name}")

        except Exception as e:
            self.conn.rollback()
            logger.error(f"✗ Failed to load data to {table_name}: {e}")
            raise

    def load_dataframe_copy(self, df: pd.DataFrame, table_name: str, truncate: bool = True):
        """
        Load DataFrame using COPY command (faster for large datasets)

        Args:
            df: DataFrame to load
            table_name: Target table name
            truncate: Whether to truncate table first
        """
        logger.info(f"← Loading {len(df)} rows to {table_name} (COPY method)...")

        try:
            # Truncate if requested
            if truncate:
                self.truncate_table(table_name)

            # Create CSV buffer
            buffer = io.StringIO()
            df.to_csv(buffer, index=False, header=False, sep='\t', na_rep='\\N')
            buffer.seek(0)

            # Get column names
            cols = ','.join(df.columns.tolist())

            # Execute COPY
            self.cursor.copy_expert(
                f"COPY {table_name} ({cols}) FROM STDIN WITH CSV DELIMITER '\t' NULL '\\N'",
                buffer
            )

            self.conn.commit()
            logger.info(f"✓ Loaded {len(df)} rows to {table_name}")

        except Exception as e:
            self.conn.rollback()
            logger.error(f"✗ Failed to load data to {table_name}: {e}")
            raise

    def upsert_dataframe(self, df: pd.DataFrame, table_name: str, conflict_columns: List[str]):
        """
        Upsert DataFrame (INSERT or UPDATE on conflict)

        Args:
            df: DataFrame to upsert
            table_name: Target table name
            conflict_columns: Columns to check for conflicts
        """
        logger.info(f"← Upserting {len(df)} rows to {table_name}...")

        try:
            cols = df.columns.tolist()
            data_tuples = [tuple(x) for x in df.to_numpy()]

            # Build upsert query
            cols_str = ','.join(cols)
            conflict_str = ','.join(conflict_columns)
            update_cols = [c for c in cols if c not in conflict_columns]
            update_str = ','.join([f"{c}=EXCLUDED.{c}" for c in update_cols])

            query = f"""
            INSERT INTO {table_name} ({cols_str}) 
            VALUES %s
            ON CONFLICT ({conflict_str})
            DO UPDATE SET {update_str}
            """

            execute_values(self.cursor, query, data_tuples, page_size=1000)
            self.conn.commit()

            logger.info(f"✓ Upserted {len(df)} rows to {table_name}")

        except Exception as e:
            self.conn.rollback()
            logger.error(f"✗ Failed to upsert data to {table_name}: {e}")
            raise

    def get_table_row_count(self, table_name: str) -> int:
        """Get row count for a table"""
        try:
            self.cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
            count = self.cursor.fetchone()[0]
            return count
        except Exception as e:
            logger.error(f"✗ Failed to get row count for {table_name}: {e}")
            return 0

    def verify_load(self, table_name: str, expected_count: int) -> bool:
        """Verify that data was loaded correctly"""
        actual_count = self.get_table_row_count(table_name)

        if actual_count == expected_count:
            logger.info(f"✓ Verified {table_name}: {actual_count} rows")
            return True
        else:
            logger.warning(f"✗ Row count mismatch in {table_name}: expected {expected_count}, got {actual_count}")
            return False


class DataLakeLoader:
    """MinIO/Data Lake loader"""

    def __init__(self):
        self.config = config.minio
        self.client = None

    def connect(self):
        """Establish connection to MinIO"""
        try:
            self.client = Minio(
                self.config.endpoint,
                access_key=self.config.access_key,
                secret_key=self.config.secret_key,
                secure=self.config.secure
            )

            # Ensure bucket exists
            if not self.client.bucket_exists(self.config.bucket):
                self.client.make_bucket(self.config.bucket)
                logger.info(f"✓ Created bucket: {self.config.bucket}")
            else:
                logger.info(f"✓ Connected to MinIO bucket: {self.config.bucket}")

            return True

        except S3Error as e:
            logger.error(f"✗ Failed to connect to MinIO: {e}")
            raise

    def upload_dataframe(
            self,
            df: pd.DataFrame,
            object_name: str,
            format: str = 'parquet'
    ):
        """
        Upload DataFrame to Data Lake

        Args:
            df: DataFrame to upload
            object_name: Object name/path in bucket
            format: File format (parquet, csv, json)
        """
        try:
            # Create temporary file
            temp_file = f"/tmp/{object_name.split('/')[-1]}"

            # Save DataFrame in specified format
            if format == 'parquet':
                df.to_parquet(temp_file, engine='pyarrow', compression='snappy')
            elif format == 'csv':
                df.to_csv(temp_file, index=False)
            elif format == 'json':
                df.to_json(temp_file, orient='records', lines=True)
            else:
                raise ValueError(f"Unsupported format: {format}")

            # Upload to MinIO
            self.client.fput_object(
                self.config.bucket,
                object_name,
                temp_file
            )

            # Clean up temp file
            import os
            os.remove(temp_file)

            logger.info(f"✓ Uploaded {object_name} to Data Lake ({len(df)} rows, {format})")

        except Exception as e:
            logger.error(f"✗ Failed to upload {object_name}: {e}")
            raise

    def archive_table(self, df: pd.DataFrame, table_name: str):
        """
        Archive table data to Data Lake with timestamp

        Args:
            df: DataFrame to archive
            table_name: Table name
        """
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        object_name = f"{config.archive_path}/{table_name}/{timestamp}.parquet"

        logger.info(f"📦 Archiving {table_name} to Data Lake...")
        self.upload_dataframe(df, object_name, format='parquet')

    def list_objects(self, prefix: str = '') -> List[str]:
        """List objects in bucket with given prefix"""
        try:
            objects = self.client.list_objects(
                self.config.bucket,
                prefix=prefix,
                recursive=True
            )

            object_list = [obj.object_name for obj in objects]
            return object_list

        except S3Error as e:
            logger.error(f"✗ Failed to list objects: {e}")
            return []


class ETLLoader:
    """Main ETL Loader - coordinates OLAP and Data Lake loading"""

    def __init__(self):
        self.olap_loader = OLAPLoader()
        self.datalake_loader = DataLakeLoader()
        self.load_stats = {}

    def connect_all(self):
        """Connect to all targets"""
        logger.info("=== Connecting to Load Targets ===")
        self.olap_loader.connect()
        self.datalake_loader.connect()

    def disconnect_all(self):
        """Disconnect from all targets"""
        self.olap_loader.disconnect()

    def load_dimension(self, df: pd.DataFrame, table_name: str):
        """Load dimension table"""
        logger.info(f"\n→ Loading dimension: {table_name}")

        # Load to OLAP
        self.olap_loader.load_dataframe_bulk(df, table_name, truncate=True)

        # Verify
        self.olap_loader.verify_load(table_name, len(df))

        # Archive to Data Lake
        self.datalake_loader.archive_table(df, table_name)

        self.load_stats[table_name] = len(df)

    def load_fact(self, df: pd.DataFrame, table_name: str):
        """Load fact table (may use different strategy)"""
        logger.info(f"\n→ Loading fact: {table_name}")

        # For large fact tables, use COPY method
        if len(df) > 10000:
            self.olap_loader.load_dataframe_copy(df, table_name, truncate=True)
        else:
            self.olap_loader.load_dataframe_bulk(df, table_name, truncate=True)

        # Verify
        self.olap_loader.verify_load(table_name, len(df))

        # Archive to Data Lake
        self.datalake_loader.archive_table(df, table_name)

        self.load_stats[table_name] = len(df)

    def load_all(self, transformed_data: Dict[str, pd.DataFrame]):
        """
        Load all transformed data

        Args:
            transformed_data: Dictionary of transformed DataFrames
        """
        logger.info("=" * 60)
        logger.info("Starting load process...")
        logger.info("=" * 60)

        # Load dimensions first (for referential integrity)
        dimensions = ['dim_date', 'dim_customer', 'dim_product', 'dim_category']
        for dim_name in dimensions:
            if dim_name in transformed_data:
                self.load_dimension(transformed_data[dim_name], dim_name)

        # Load facts
        facts = ['fact_sales', 'fact_inventory']
        for fact_name in facts:
            if fact_name in transformed_data:
                self.load_fact(transformed_data[fact_name], fact_name)

        self._print_load_summary()

    def _print_load_summary(self):
        """Print load summary"""
        logger.info("\n" + "=" * 60)
        logger.info("Load Summary:")
        logger.info("=" * 60)

        for table, count in self.load_stats.items():
            logger.info(f"  {table:20s}: {count:6d} rows")

        total_rows = sum(self.load_stats.values())
        logger.info("=" * 60)
        logger.info(f"  {'TOTAL':20s}: {total_rows:6d} rows")
        logger.info("=" * 60)


def main():
    """Test load module"""
    loader = ETLLoader()

    try:
        # Connect
        loader.connect_all()

        # Create sample data
        sample_data = pd.DataFrame({
            'date_key': [20240101, 20240102],
            'date': ['2024-01-01', '2024-01-02'],
            'year': [2024, 2024],
            'month': [1, 1],
            'day': [1, 2]
        })

        # Test load
        logger.info("\n=== Testing Load ===")
        loader.load_dimension(sample_data, 'dim_date')

        # List archived files
        logger.info("\n=== Archived Files ===")
        files = loader.datalake_loader.list_objects(prefix='archive/')
        for f in files[:10]:  # Show first 10
            print(f"  {f}")

    finally:
        loader.disconnect_all()


if __name__ == "__main__":
    main()