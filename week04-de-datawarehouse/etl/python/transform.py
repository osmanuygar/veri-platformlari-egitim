"""
Transform Module - Veri Dönüştürme
Transforms data from OLTP format to OLAP dimensional model
"""

import pandas as pd
import numpy as np
from datetime import datetime
from typing import Dict
from config import logger


class DataTransformer:
    """Data transformation for dimensional model"""

    def __init__(self):
        self.transformation_stats = {}

    # ============================================
    # DIMENSION TRANSFORMATIONS
    # ============================================

    def transform_dim_customer(self, customers_df: pd.DataFrame) -> pd.DataFrame:
        """
        Transform customer data for dim_customer

        Transformations:
        - Combine first/last name
        - Calculate customer lifetime value
        - Determine customer tier
        - Extract registration date parts
        """
        logger.info("⚙ Transforming dim_customer...")

        df = customers_df.copy()

        # Combine names
        df['full_name'] = df['first_name'] + ' ' + df['last_name']

        # Calculate lifetime value tier
        df['lifetime_value'] = df['total_spent'].fillna(0)
        df['customer_tier'] = pd.cut(
            df['lifetime_value'],
            bins=[0, 100, 500, 1000, float('inf')],
            labels=['Bronze', 'Silver', 'Gold', 'Platinum']
        )

        # Extract date parts
        df['registration_date'] = pd.to_datetime(df['created_at']).dt.date
        df['registration_year'] = pd.to_datetime(df['created_at']).dt.year
        df['registration_month'] = pd.to_datetime(df['created_at']).dt.month

        # Calculate days since registration
        df['days_since_registration'] = (
                datetime.now() - pd.to_datetime(df['created_at'])
        ).dt.days

        # Select final columns
        transformed = df[[
            'customer_id',
            'full_name',
            'email',
            'phone',
            'segment',
            'customer_tier',
            'lifetime_value',
            'total_orders',
            'registration_date',
            'registration_year',
            'registration_month',
            'days_since_registration'
        ]]

        self._log_transformation('dim_customer', len(df))
        return transformed

    def transform_dim_product(self, products_df: pd.DataFrame) -> pd.DataFrame:
        """
        Transform product data for dim_product

        Transformations:
        - Calculate discount percentage
        - Determine stock status
        - Calculate price tier
        - Create product hierarchy
        """
        logger.info("⚙ Transforming dim_product...")

        df = products_df.copy()

        # Calculate discount percentage
        df['discount_percentage'] = (
                (df['price'] - df['sale_price']) / df['price'] * 100
        ).fillna(0).round(2)

        # Determine if product is on sale
        df['is_on_sale'] = df['sale_price'] < df['price']

        # Calculate effective price
        df['effective_price'] = df['sale_price'].fillna(df['price'])

        # Determine stock status
        df['stock_status'] = pd.cut(
            df['stock_quantity'],
            bins=[-1, 0, 10, 50, float('inf')],
            labels=['Out of Stock', 'Low Stock', 'Medium Stock', 'In Stock']
        )

        # Price tier
        df['price_tier'] = pd.cut(
            df['effective_price'],
            bins=[0, 20, 50, 100, float('inf')],
            labels=['Budget', 'Mid-Range', 'Premium', 'Luxury']
        )

        # Select final columns
        transformed = df[[
            'product_id',
            'product_name',
            'description',
            'sku',
            'category_id',
            'category_name',
            'price',
            'sale_price',
            'effective_price',
            'discount_percentage',
            'is_on_sale',
            'stock_quantity',
            'stock_status',
            'price_tier'
        ]]

        self._log_transformation('dim_product', len(df))
        return transformed

    def transform_dim_category(self, categories_df: pd.DataFrame) -> pd.DataFrame:
        """
        Transform category data for dim_category

        Transformations:
        - Build category hierarchy
        - Calculate category level
        """
        logger.info("⚙ Transforming dim_category...")

        df = categories_df.copy()

        # Determine category level (1 = root, 2 = subcategory)
        df['category_level'] = df['parent_category_id'].isna().map({True: 1, False: 2})

        # Fill parent info for root categories
        df['parent_category_name'] = df['parent_category_name'].fillna('Root')

        transformed = df[[
            'category_id',
            'category_name',
            'parent_category_id',
            'parent_category_name',
            'category_level',
            'description'
        ]]

        self._log_transformation('dim_category', len(df))
        return transformed

    def transform_dim_date(self, start_date: str = '2020-01-01', end_date: str = '2025-12-31') -> pd.DataFrame:
        """
        Create date dimension

        Args:
            start_date: Start date for dimension
            end_date: End date for dimension

        Returns:
            Date dimension DataFrame
        """
        logger.info("⚙ Creating dim_date...")

        # Generate date range
        dates = pd.date_range(start=start_date, end=end_date, freq='D')

        df = pd.DataFrame({'date': dates})

        # Extract date parts
        df['date_key'] = df['date'].dt.strftime('%Y%m%d').astype(int)
        df['year'] = df['date'].dt.year
        df['quarter'] = df['date'].dt.quarter
        df['month'] = df['date'].dt.month
        df['month_name'] = df['date'].dt.month_name()
        df['week'] = df['date'].dt.isocalendar().week
        df['day'] = df['date'].dt.day
        df['day_of_week'] = df['date'].dt.dayofweek + 1  # Monday = 1
        df['day_name'] = df['date'].dt.day_name()
        df['day_of_year'] = df['date'].dt.dayofyear

        # Boolean flags
        df['is_weekend'] = df['day_of_week'].isin([6, 7])
        df['is_month_start'] = df['date'].dt.is_month_start
        df['is_month_end'] = df['date'].dt.is_month_end
        df['is_quarter_start'] = df['date'].dt.is_quarter_start
        df['is_quarter_end'] = df['date'].dt.is_quarter_end
        df['is_year_start'] = df['date'].dt.is_year_start
        df['is_year_end'] = df['date'].dt.is_year_end

        self._log_transformation('dim_date', len(df))
        return df

    # ============================================
    # FACT TABLE TRANSFORMATIONS
    # ============================================

    def transform_fact_sales(self, order_items_df: pd.DataFrame) -> pd.DataFrame:
        """
        Transform order items to fact_sales

        Transformations:
        - Calculate metrics (revenue, profit, etc.)
        - Create date keys
        - Add calculated measures
        """
        logger.info("⚙ Transforming fact_sales...")

        df = order_items_df.copy()

        # Extract date information
        df['order_date'] = pd.to_datetime(df['order_date']).dt.date
        df['date_key'] = pd.to_datetime(df['order_date']).dt.strftime('%Y%m%d').astype(int)

        # Calculate metrics
        df['gross_amount'] = df['quantity'] * df['unit_price']
        df['discount_amount'] = df['discount_amount'].fillna(0)
        df['tax_amount'] = df['tax_amount'].fillna(0)
        df['net_amount'] = df['total_amount']

        # Calculate unit metrics
        df['average_unit_price'] = df['unit_price']
        df['discount_percentage'] = (
                df['discount_amount'] / df['gross_amount'] * 100
        ).fillna(0).round(2)

        # Select final columns
        transformed = df[[
            'order_item_id',
            'order_id',
            'product_id',
            'customer_id',
            'date_key',
            'order_date',
            'quantity',
            'unit_price',
            'gross_amount',
            'discount_amount',
            'discount_percentage',
            'tax_amount',
            'net_amount',
            'order_status',
            'payment_status'
        ]]

        self._log_transformation('fact_sales', len(df))
        return transformed

    def transform_fact_inventory(self, products_df: pd.DataFrame) -> pd.DataFrame:
        """
        Transform products to fact_inventory (snapshot)

        Creates a snapshot of current inventory levels
        """
        logger.info("⚙ Transforming fact_inventory...")

        df = products_df.copy()

        # Add snapshot date
        snapshot_date = datetime.now().date()
        df['snapshot_date'] = snapshot_date
        df['date_key'] = int(datetime.now().strftime('%Y%m%d'))

        # Calculate inventory value
        df['inventory_value'] = df['stock_quantity'] * df['price']
        df['sale_inventory_value'] = df['stock_quantity'] * df['sale_price'].fillna(df['price'])

        transformed = df[[
            'product_id',
            'date_key',
            'snapshot_date',
            'stock_quantity',
            'price',
            'sale_price',
            'inventory_value',
            'sale_inventory_value'
        ]]

        self._log_transformation('fact_inventory', len(df))
        return transformed

    # ============================================
    # HELPER METHODS
    # ============================================

    def transform_all(self, extracted_data: Dict[str, pd.DataFrame]) -> Dict[str, pd.DataFrame]:
        """
        Transform all extracted data

        Args:
            extracted_data: Dictionary of extracted DataFrames

        Returns:
            Dictionary of transformed DataFrames ready for loading
        """
        logger.info("=" * 60)
        logger.info("Starting complete transformation process...")
        logger.info("=" * 60)

        transformed = {}

        # Transform dimensions
        transformed['dim_customer'] = self.transform_dim_customer(extracted_data['customers'])
        transformed['dim_product'] = self.transform_dim_product(extracted_data['products'])
        transformed['dim_category'] = self.transform_dim_category(extracted_data['categories'])
        transformed['dim_date'] = self.transform_dim_date()

        # Transform facts
        transformed['fact_sales'] = self.transform_fact_sales(extracted_data['order_items'])
        transformed['fact_inventory'] = self.transform_fact_inventory(extracted_data['products'])

        self._print_transformation_summary()

        return transformed

    def _log_transformation(self, table_name: str, row_count: int):
        """Log transformation statistics"""
        self.transformation_stats[table_name] = row_count
        logger.info(f"✓ Transformed {row_count} rows for {table_name}")

    def _print_transformation_summary(self):
        """Print transformation summary"""
        logger.info("\n" + "=" * 60)
        logger.info("Transformation Summary:")
        logger.info("=" * 60)

        for table, count in self.transformation_stats.items():
            logger.info(f"  {table:20s}: {count:6d} rows")

        total_rows = sum(self.transformation_stats.values())
        logger.info("=" * 60)
        logger.info(f"  {'TOTAL':20s}: {total_rows:6d} rows")
        logger.info("=" * 60)

    def validate_transformations(self, transformed_data: Dict[str, pd.DataFrame]) -> bool:
        """
        Validate transformed data

        Returns:
            True if all validations pass
        """
        logger.info("\n=== Validating Transformations ===")

        validations = []

        # Check for null values in key columns
        if 'dim_customer' in transformed_data:
            df = transformed_data['dim_customer']
            null_check = df['customer_id'].isnull().sum() == 0
            validations.append(('dim_customer.customer_id not null', null_check))

        if 'fact_sales' in transformed_data:
            df = transformed_data['fact_sales']
            null_check = df['order_item_id'].isnull().sum() == 0
            validations.append(('fact_sales.order_item_id not null', null_check))

            # Check for negative values
            positive_check = (df['quantity'] > 0).all()
            validations.append(('fact_sales.quantity > 0', positive_check))

        # Print validation results
        all_passed = True
        for check_name, passed in validations:
            status = "✓" if passed else "✗"
            logger.info(f"{status} {check_name}")
            all_passed = all_passed and passed

        if all_passed:
            logger.info("✓ All validations passed")
        else:
            logger.warning("✗ Some validations failed")

        return all_passed


def main():
    """Test transformation module"""
    # Create sample data for testing
    sample_customers = pd.DataFrame({
        'customer_id': [1, 2, 3],
        'first_name': ['John', 'Jane', 'Bob'],
        'last_name': ['Doe', 'Smith', 'Johnson'],
        'email': ['john@example.com', 'jane@example.com', 'bob@example.com'],
        'phone': ['1234567890', '0987654321', '1122334455'],
        'segment': ['Premium', 'Standard', 'Premium'],
        'created_at': ['2023-01-15', '2023-03-20', '2023-06-10'],
        'total_orders': [5, 3, 7],
        'total_spent': [500.00, 150.00, 1200.00]
    })

    transformer = DataTransformer()

    # Test customer transformation
    dim_customer = transformer.transform_dim_customer(sample_customers)
    print("\n=== Transformed Customer Dimension ===")
    print(dim_customer)

    # Test date dimension
    dim_date = transformer.transform_dim_date('2024-01-01', '2024-01-31')
    print("\n=== Date Dimension Sample ===")
    print(dim_date.head())


if __name__ == "__main__":
    main()