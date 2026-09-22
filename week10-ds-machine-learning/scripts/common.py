"""Hafta 10 — paylaşılan veri hazırlama ve yardımcılar."""
import os
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, OneHotEncoder

try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).resolve().parent.parent / ".env")
except ImportError:
    pass

DATA = Path(__file__).resolve().parent.parent / "data-samples" / "telco_churn.csv"
MLFLOW_TRACKING_URI = os.getenv("MLFLOW_TRACKING_URI", "http://localhost:5500")

NUMERIC_FEATURES = ["tenure_months", "monthly_charge", "support_calls",
                     "has_addons", "payment_late_count"]
CATEGORICAL_FEATURES = ["contract_type"]
TARGET = "churned"


class C:
    RESET = "\033[0m"; DIM = "\033[2m"; BOLD = "\033[1m"
    RED = "\033[31m"; GREEN = "\033[32m"; YELLOW = "\033[33m"; CYAN = "\033[36m"


def banner(title, subtitle=""):
    line = "─" * 62
    print(f"\n{C.CYAN}{line}{C.RESET}\n{C.BOLD}  {title}{C.RESET}")
    if subtitle:
        print(f"{C.DIM}  {subtitle}{C.RESET}")
    print(f"{C.CYAN}{line}{C.RESET}\n")


def load_data():
    if not DATA.exists():
        print(f"{C.RED}✖ {DATA} yok. Önce: python scripts/generate_churn_dataset.py{C.RESET}")
        raise SystemExit(1)
    return pd.read_csv(DATA)


def make_split(df, test_size=0.2, random_state=42):
    """Stratified split: churn oranı train/test'te AYNI kalır."""
    X = df[NUMERIC_FEATURES + CATEGORICAL_FEATURES]
    y = df[TARGET]
    return train_test_split(X, y, test_size=test_size, random_state=random_state, stratify=y)


def make_preprocessor():
    """Sızıntısız dönüşüm: fit() SADECE train'de çağrılır (Pipeline garantisi)."""
    return ColumnTransformer([
        ("num", StandardScaler(), NUMERIC_FEATURES),
        ("cat", OneHotEncoder(handle_unknown="ignore"), CATEGORICAL_FEATURES),
    ])


def make_pipeline(model):
    return Pipeline([
        ("preprocess", make_preprocessor()),
        ("model", model),
    ])
