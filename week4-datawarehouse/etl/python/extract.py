"""
Extract Module - OLTP'den Veri Çekme
Extracts data from OLTP database (Source System)
"""

import pandas as pd
import psycopg2
from psycopg2.extras import RealDictCursor
from typing import Optional, Dict, List
from datetime import datetime, timedelta
from config import config, logger


class OLTPExtractor:
    """OLTP database extractor"""

    def __init__(self):
        self.config = config.oltp
        self.conn = None
        self.cursor = None

    def connect(self):
        """Establish connection to OLTP database"""
        try:
            self.conn = psycopg2.connect(
                host=self.config.host,
                port=self.config.port,
                database=self.config.database,
                user=self.config.user,
                password=self.config.password
            )
            self.cursor = self.conn.cursor(cursor_factory=RealDictCursor)
            logger.info(f"✓ Connected to OLTP: {self.config.database}")
            return True
        except Exception as e:
            logger.error(f"✗ Failed to connect to OLTP: {e}")
            raise

    def disconnect(self):
        """Close database connection"""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
            logger.info("✓ Disconnected from OLTP")

    def extract_table(self, table_name: str, query: Optional[str] = None) -> pd.DataFrame:
        """
        Extract entire table or custom query

        Args:
            table_name: Name of the table
            query: Optional custom SQL query

        Returns:
            pandas DataFrame with extracted data
        """
        if query is None:
            query = f"SELECT * FROM {table_name}"

        logger.info(f"→ Extracting from {table_name}...")

        try:
            df = pd.read_sql_query(query, self.conn)
            logger.info(f"✓ Extracted {len(df)} rows from {table_name}")
            return df
        except Exception as e:
            logger.error(f"✗ Failed to extract from {table_name}: {e}")
            raise

    def extract_incremental(
            self,
            table_name: str,
            timestamp_column: str,
            last_extract_time: Optional[datetime] = None
    ) -> pd.DataFrame:
        """
        Extract only new/updated records (incremental load)

        Args:
            table_name: Name of the table
            timestamp_column: Column name for timestamp (e.g., 'updated_at')
            last_extract_time: Last extraction timestamp

        Returns:
            pandas DataFrame with new/updated records
        """
        if last_extract_time is None:
            # If no last time, get last 24 hours
            last_extract_time = datetime.now() - timedelta(days=1)

        query = f"""
        SELECT * FROM {table_name}
        WHERE {timestamp_column} > '{last_extract_time}'
        ORDER BY {timestamp_column}
        """

        logger.info(f"→ Extracting incremental data from {table_name} (since {last_extract_time})")

        try:
            df = pd.read_sql_query(query, self.conn)
            logger.info(f"✓ Extracted {len(df)} new/updated rows from {table_name}")
            return df
        except Exception as e:
            logger.error(f"✗ Failed to extract incremental data from {table_name}: {e}")
            raise

    def extract_customers(self) -> pd.DataFrame:
        """Extract customer data with related information"""
        query = """
        SELECT 
            c.customer_id,
            c.first_name,
            c.last_name,
            c.email,
            c.phone,
            c.segment,
            c.created_at,
            c.updated_at,
            COUNT(DISTINCT o.order_id) as total_orders,
            COALESCE(SUM(o.total_amount), 0) as total_spent
        FROM customers c
        LEFT JOIN orders o ON c.customer_id = o.customer_id
        GROUP BY c.customer_id
        """
        return self.extract_table('customers', query)

    def extract_products(self) -> pd.DataFrame:
        """Extract product data with category information"""
        query = """
        SELECT 
            p.product_id,
            p.product_name,
            p.description,
            p.sku,
            p.price,
            p.sale_price,
            p.stock_quantity,
            p.category_id,
            c.category_name,
            c.parent_category_id,
            p.created_at,
            p.updated_at
        FROM products p
        LEFT JOIN categories c ON p.category_id = c.category_id
        """
        return self.extract_table('products', query)

    def extract_orders(self) -> pd.DataFrame:
        """Extract order data"""
        query = """
        SELECT 
            o.order_id,
            o.customer_id,
            o.order_status,
            o.payment_status,
            o.shipping_address_id,
            o.billing_address_id,
            o.payment_method_id,
            o.subtotal,
            o.tax_amount,
            o.shipping_cost,
            o.discount_amount,
            o.total_amount,
            o.created_at,
            o.updated_at
        FROM orders o
        """
        return self.extract_table('orders', query)

    def extract_order_items(self) -> pd.DataFrame:
        """Extract order items (fact table basis)"""
        query = """
        SELECT 
            oi.order_item_id,
            oi.order_id,
            oi.product_id,
            oi.quantity,
            oi.unit_price,
            oi.discount_amount,
            oi.tax_amount,
            oi.total_amount,
            o.customer_id,
            o.order_status,
            o.payment_status,
            o.created_at as order_date,
            p.product_name,
            p.category_id
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        JOIN products p ON oi.product_id = p.product_id
        """
        return self.extract_table('order_items', query)

    def extract_categories(self) -> pd.DataFrame:
        """Extract category hierarchy"""
        query = """
        SELECT 
            c.category_id,
            c.category_name,
            c.parent_category_id,
            pc.category_name as parent_category_name,
            c.description
        FROM categories c
        LEFT JOIN categories pc ON c.parent_category_id = pc.category_id
        """
        return self.extract_table('categories', query)

    def extract_addresses(self) -> pd.DataFrame:
        """Extract address information"""
        return self.extract_table('addresses')

    def extract_payment_methods(self) -> pd.DataFrame:
        """Extract payment methods"""
        return self.extract_table('payment_methods')

    def get_table_stats(self, table_name: str) -> Dict:
        """Get statistics about a table"""
        query = f"""
        SELECT 
            COUNT(*) as row_count,
            pg_size_pretty(pg_total_relation_size('{table_name}')) as total_size
        FROM {table_name}
        """

        self.cursor.execute(query)
        result = self.cursor.fetchone()

        return {
            'table_name': table_name,
            'row_count': result['row_count'],
            'total_size': result['total_size']
        }

    def get_all_table_stats(self) -> List[Dict]:
        """Get statistics for all main tables"""
        tables = [
            'customers', 'products', 'categories',
            'orders', 'order_items', 'addresses',
            'payment_methods'
        ]

        stats = []
        for table in tables:
            try:
                stats.append(self.get_table_stats(table))
            except Exception as e:
                logger.warning(f"Could not get stats for {table}: {e}")

        return stats

    def extract_all(self) -> Dict[str, pd.DataFrame]:
        """
        Extract all tables for full ETL

        Returns:
            Dictionary with table names as keys and DataFrames as values
        """
        logger.info("→ Starting full extraction from OLTP...")

        data = {
            'customers': self.extract_customers(),
            'products': self.extract_products(),
            'categories': self.extract_categories(),
            'orders': self.extract_orders(),
            'order_items': self.extract_order_items(),
            'addresses': self.extract_addresses(),
            'payment_methods': self.extract_payment_methods()
        }

        total_rows = sum(len(df) for df in data.values())
        logger.info(f"✓ Full extraction completed: {total_rows} total rows")

        return data


def main():
    """Test extraction module"""
    extractor = OLTPExtractor()

    try:
        # Connect
        extractor.connect()

        # Get statistics
        logger.info("\n=== Table Statistics ===")
        stats = extractor.get_all_table_stats()
        for stat in stats:
            print(f"{stat['table_name']}: {stat['row_count']} rows ({stat['total_size']})")

        # Test extraction
        logger.info("\n=== Testing Extraction ===")
        customers = extractor.extract_customers()
        print(f"\nCustomers sample:\n{customers.head()}")

        products = extractor.extract_products()
        print(f"\nProducts sample:\n{products.head()}")

    finally:
        extractor.disconnect()


if __name__ == "__main__":
    main()