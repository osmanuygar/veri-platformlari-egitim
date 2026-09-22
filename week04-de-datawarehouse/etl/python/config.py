"""
ETL Configuration Module
Manages all configuration and connection settings
"""

import os
import logging
import colorlog
from dataclasses import dataclass


def setup_logger(name: str) -> logging.Logger:
    """Setup colored logger"""
    handler = colorlog.StreamHandler()
    handler.setFormatter(colorlog.ColoredFormatter(
        '%(log_color)s%(levelname)s:%(name)s:%(message)s',
        log_colors={
            'DEBUG': 'cyan',
            'INFO': 'green',
            'WARNING': 'yellow',
            'ERROR': 'red',
            'CRITICAL': 'red,bg_white',
        }
    ))

    logger = colorlog.getLogger(name)
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger


@dataclass
class DatabaseConfig:
    """Database connection configuration"""
    host: str
    port: int
    database: str
    user: str
    password: str

    @property
    def connection_string(self) -> str:
        """Get PostgreSQL connection string"""
        return f"postgresql://{self.user}:{self.password}@{self.host}:{self.port}/{self.database}"


@dataclass
class MinIOConfig:
    """MinIO/S3 configuration"""
    endpoint: str
    access_key: str
    secret_key: str
    bucket: str
    secure: bool = False


class ETLConfig:
    """Main ETL configuration class"""

    def __init__(self):
        # OLTP Database (Source)
        self.oltp = DatabaseConfig(
            host=os.getenv('OLTP_HOST', 'postgres-oltp'),
            port=int(os.getenv('OLTP_PORT', 5432)),
            database=os.getenv('OLTP_DB', 'ecommerce_oltp'),
            user=os.getenv('OLTP_USER', 'oltp_user'),
            password=os.getenv('OLTP_PASSWORD', 'oltp_pass123')
        )

        # OLAP Database (Target)
        self.olap = DatabaseConfig(
            host=os.getenv('OLAP_HOST', 'postgres-olap'),
            port=int(os.getenv('OLAP_PORT', 5432)),
            database=os.getenv('OLAP_DB', 'ecommerce_dw'),
            user=os.getenv('OLAP_USER', 'olap_user'),
            password=os.getenv('OLAP_PASSWORD', 'olap_pass123')
        )

        # MinIO/Data Lake
        self.minio = MinIOConfig(
            endpoint=os.getenv('MINIO_ENDPOINT', 'minio:9000'),
            access_key=os.getenv('MINIO_ROOT_USER', 'minio_admin'),
            secret_key=os.getenv('MINIO_ROOT_PASSWORD', 'minio_password123'),
            bucket=os.getenv('MINIO_BUCKET', 'datawarehouse'),
            secure=False
        )

        # ETL Settings
        self.run_mode = os.getenv('ETL_RUN_MODE', 'continuous')
        self.interval_seconds = int(os.getenv('ETL_INTERVAL_SECONDS', 300))
        self.batch_size = int(os.getenv('ETL_BATCH_SIZE', 1000))

        # Data Lake paths
        self.archive_path = 'archive'
        self.staging_path = 'staging'
        self.processed_path = 'processed'

    def validate(self) -> bool:
        """Validate configuration"""
        required_fields = [
            self.oltp.host, self.oltp.database,
            self.olap.host, self.olap.database,
            self.minio.endpoint, self.minio.bucket
        ]

        return all(required_fields)

    def __repr__(self) -> str:
        """String representation"""
        return f"""
ETL Configuration:
==================
OLTP: {self.oltp.host}:{self.oltp.port}/{self.oltp.database}
OLAP: {self.olap.host}:{self.olap.port}/{self.olap.database}
MinIO: {self.minio.endpoint}/{self.minio.bucket}
Run Mode: {self.run_mode}
Interval: {self.interval_seconds}s
"""


# Global logger instance
logger = setup_logger('etl')


# Export configuration
config = ETLConfig()


if __name__ == "__main__":
    # Test configuration
    print(config)
    print(f"Valid: {config.validate()}")