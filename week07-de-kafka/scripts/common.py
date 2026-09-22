"""Hafta 7 — tüm scriptlerin paylaştığı ayarlar ve küçük yardımcılar."""
import os
import sys
from pathlib import Path

try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).resolve().parent.parent / ".env")
except ImportError:  # python-dotenv kurulu değilse varsayılanlarla devam et
    pass

BOOTSTRAP            = os.getenv("KAFKA_BOOTSTRAP", "localhost:9092")
SCHEMA_REGISTRY_URL  = os.getenv("SCHEMA_REGISTRY_URL", "http://localhost:8095")
CONNECT_URL          = os.getenv("CONNECT_URL", "http://localhost:8096")

TOPIC_ORDERS     = os.getenv("TOPIC_ORDERS", "orders")
TOPIC_ORDERS_DLQ = os.getenv("TOPIC_ORDERS_DLQ", "orders.dlq")
TOPIC_STOCK      = os.getenv("TOPIC_STOCK", "stock-events")
TOPIC_ORDERS_AVRO = "orders-avro"

PG = dict(
    host     = os.getenv("PGHOST", "localhost"),
    port     = int(os.getenv("PGPORT", "5437")),
    user     = os.getenv("PGUSER", "kafka_user"),
    password = os.getenv("PGPASSWORD", "kafka_pass"),
    dbname   = os.getenv("PGDATABASE", "shopdb"),
)

# ── Terminal renkleri ────────────────────────────────────────
class C:
    RESET  = "\033[0m"
    DIM    = "\033[2m"
    BOLD   = "\033[1m"
    RED    = "\033[31m"
    GREEN  = "\033[32m"
    YELLOW = "\033[33m"
    BLUE   = "\033[34m"
    MAGENTA= "\033[35m"
    CYAN   = "\033[36m"


def banner(title: str, subtitle: str = "") -> None:
    line = "─" * 62
    print(f"\n{C.CYAN}{line}{C.RESET}")
    print(f"{C.BOLD}  {title}{C.RESET}")
    if subtitle:
        print(f"{C.DIM}  {subtitle}{C.RESET}")
    print(f"{C.CYAN}{line}{C.RESET}\n")


def require(module_name: str) -> None:
    """Bağımlılık eksikse anlaşılır bir mesajla çık."""
    try:
        __import__(module_name)
    except ImportError:
        print(f"{C.RED}❌ '{module_name}' kurulu değil.{C.RESET}")
        print(f"   Çözüm: {C.BOLD}pip install -r requirements.txt{C.RESET}")
        sys.exit(1)
