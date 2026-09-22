# Hafta 11 — Superset yapılandırması (eğitim ortamı)
import os

SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY", "week11_egitim_amacli")

SQLALCHEMY_DATABASE_URI = (
    f"postgresql+psycopg2://{os.environ.get('DATABASE_USER')}:"
    f"{os.environ.get('DATABASE_PASSWORD')}@{os.environ.get('DATABASE_HOST')}:"
    f"{os.environ.get('DATABASE_PORT')}/{os.environ.get('DATABASE_DB')}"
)

FEATURE_FLAGS = {
    "DASHBOARD_NATIVE_FILTERS": True,
    "ENABLE_TEMPLATE_PROCESSING": True,
}
