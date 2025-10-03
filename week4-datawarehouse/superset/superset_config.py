"""
Superset Configuration File
Custom configuration for Week 4 Data Warehouse
"""

import os

# ============================================
# Superset Metadata Database
# ============================================
SQLALCHEMY_DATABASE_URI = os.getenv(
    'SQLALCHEMY_DATABASE_URI',
    'postgresql://superset:superset123@postgres-superset:5432/superset'
)

# ============================================
# Security
# ============================================
SECRET_KEY = os.getenv('SUPERSET_SECRET_KEY', 'changeMeInProduction')

# ============================================
# Feature Flags
# ============================================
FEATURE_FLAGS = {
    'ENABLE_TEMPLATE_PROCESSING': True,
    'DASHBOARD_NATIVE_FILTERS': True,
    'DASHBOARD_CROSS_FILTERS': True,
    'DASHBOARD_RBAC': True,
    'EMBEDDABLE_CHARTS': True,
}

# ============================================
# Cache Configuration
# ============================================
CACHE_CONFIG = {
    'CACHE_TYPE': 'SimpleCache',
    'CACHE_DEFAULT_TIMEOUT': 300,
}

# ============================================
# Query Result Limits
# ============================================
ROW_LIMIT = 50000
SQL_MAX_ROW = 100000

# ============================================
# Webserver Configuration
# ============================================
WEBSERVER_THREADS = 4
WEBSERVER_TIMEOUT = 120

# ============================================
# Sample Data (Disable for production)
# ============================================
PREVENT_UNSAFE_DB_CONNECTIONS = False  # Allow local connections

# ============================================
# CSV Export Configuration
# ============================================
CSV_EXPORT = {
    'encoding': 'utf-8',
}

# ============================================
# Chart Time Ranges
# ============================================
DEFAULT_TIME_FILTER = {
    'since': '30 days ago',
    'until': 'now',
}

# ============================================
# SQL Lab Configuration
# ============================================
SQLLAB_ASYNC_TIME_LIMIT_SEC = 300
SQLLAB_TIMEOUT = 300
SQLLAB_DEFAULT_DBID = None

# ============================================
# Language
# ============================================
BABEL_DEFAULT_LOCALE = 'en'
LANGUAGES = {
    'en': {'flag': 'us', 'name': 'English'},
    'tr': {'flag': 'tr', 'name': 'Turkish'},
}

# ============================================
# Email Configuration (Optional)
# ============================================
# SMTP_HOST = 'localhost'
# SMTP_STARTTLS = True
# SMTP_SSL = False
# SMTP_USER = 'your_user'
# SMTP_PORT = 25
# SMTP_PASSWORD = 'your_password'
# SMTP_MAIL_FROM = 'superset@example.com'

# ============================================
# Alert & Report Configuration (Optional)
# ============================================
ENABLE_SCHEDULED_EMAIL_REPORTS = False

# ============================================
# Custom Settings
# ============================================
# Allow dashboard embedding
DASHBOARD_NATIVE_FILTERS_SET = True

# Enable data upload
ENABLE_PROXY_FIX = True

# ============================================
# Logging
# ============================================
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
LOG_FORMAT = '%(asctime)s:%(levelname)s:%(name)s:%(message)s'

print("✓ Custom Superset configuration loaded")