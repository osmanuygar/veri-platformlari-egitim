"""Hafta 12 — paylaşılan ayarlar."""
import os
from pathlib import Path

try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).resolve().parent.parent / ".env")
except ImportError:
    pass

PG = dict(
    host=os.getenv("PGHOST", "localhost"),
    port=int(os.getenv("PGPORT", "5440")),
    user=os.getenv("PGUSER", "dg_user"),
    password=os.getenv("PGPASSWORD", "dg_pass"),
    dbname=os.getenv("PGDATABASE", "dg_db"),
)
PG_URI = f"postgresql://{PG['user']}:{PG['password']}@{PG['host']}:{PG['port']}/{PG['dbname']}"

MARQUEZ_URL = os.getenv("MARQUEZ_URL", "http://localhost:5002")


class C:
    RESET = "\033[0m"; DIM = "\033[2m"; BOLD = "\033[1m"
    RED = "\033[31m"; GREEN = "\033[32m"; YELLOW = "\033[33m"; CYAN = "\033[36m"


def banner(title, subtitle=""):
    line = "─" * 62
    print(f"\n{C.CYAN}{line}{C.RESET}\n{C.BOLD}  {title}{C.RESET}")
    if subtitle:
        print(f"{C.DIM}  {subtitle}{C.RESET}")
    print(f"{C.CYAN}{line}{C.RESET}\n")
