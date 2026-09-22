"""Hafta 6 — paylaşılan ayarlar."""
import os
from pathlib import Path

try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).resolve().parent.parent / ".env")
except ImportError:
    pass

PG = dict(
    host=os.getenv("PGHOST", "localhost"),
    port=int(os.getenv("PGPORT", "5436")),
    user=os.getenv("PGUSER", "de_user"),
    password=os.getenv("PGPASSWORD", "de_pass"),
    dbname=os.getenv("PGDATABASE", "de_db"),
)


class C:
    RESET = "\033[0m"; DIM = "\033[2m"; BOLD = "\033[1m"
    RED = "\033[31m"; GREEN = "\033[32m"; YELLOW = "\033[33m"; CYAN = "\033[36m"


def banner(title, subtitle=""):
    line = "─" * 62
    print(f"\n{C.CYAN}{line}{C.RESET}\n{C.BOLD}  {title}{C.RESET}")
    if subtitle:
        print(f"{C.DIM}  {subtitle}{C.RESET}")
    print(f"{C.CYAN}{line}{C.RESET}\n")
