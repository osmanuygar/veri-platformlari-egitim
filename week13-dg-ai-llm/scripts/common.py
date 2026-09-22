"""Hafta 13 — paylaşılan ayarlar ve yardımcılar."""
import os
from pathlib import Path

try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).resolve().parent.parent / ".env")
except ImportError:
    pass

PG = dict(
    host=os.getenv("PGHOST", "localhost"),
    port=int(os.getenv("PGPORT", "5441")),
    user=os.getenv("PGUSER", "ai_user"),
    password=os.getenv("PGPASSWORD", "ai_pass"),
    dbname=os.getenv("PGDATABASE", "ai_db"),
)

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
OLLAMA_CHAT_MODEL = os.getenv("OLLAMA_CHAT_MODEL", "llama3.2:1b")
OLLAMA_EMBED_MODEL = os.getenv("OLLAMA_EMBED_MODEL", "nomic-embed-text")

QDRANT_URL = os.getenv("QDRANT_URL", "http://localhost:6333")
QDRANT_COLLECTION = os.getenv("QDRANT_COLLECTION", "course_chunks")

# Repo kökü — ders notlarını (week*/README.md) bulmak için
REPO_ROOT = Path(__file__).resolve().parents[2]


class C:
    RESET = "\033[0m"; DIM = "\033[2m"; BOLD = "\033[1m"
    RED = "\033[31m"; GREEN = "\033[32m"; YELLOW = "\033[33m"; CYAN = "\033[36m"; MAGENTA = "\033[35m"


def banner(title, subtitle=""):
    line = "─" * 62
    print(f"\n{C.CYAN}{line}{C.RESET}\n{C.BOLD}  {title}{C.RESET}")
    if subtitle:
        print(f"{C.DIM}  {subtitle}{C.RESET}")
    print(f"{C.CYAN}{line}{C.RESET}\n")


def require(module_name):
    import sys
    try:
        __import__(module_name)
    except ImportError:
        print(f"{C.RED}❌ '{module_name}' kurulu değil: pip install -r requirements.txt{C.RESET}")
        sys.exit(1)
