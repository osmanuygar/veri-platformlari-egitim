#!/usr/bin/env python3
"""
Hafta 6 — Alıştırma 3 hazırlığı: büyük bir Parquet dosyası üret

DuckDB ile Postgres performansını karşılaştırmak için ~1M satırlık
sahte satış verisi üretir. `data/sales.parquet` dosyasına yazar.

Kullanım:
    python scripts/generate_parquet.py                # 1.000.000 satır
    python scripts/generate_parquet.py --rows 5000000
"""
import argparse
import random
from datetime import datetime, timedelta
from pathlib import Path

from common import banner, C

try:
    import pandas as pd
except ImportError:
    print(f"{C.RED}pandas kurulu değil: pip install -r requirements.txt{C.RESET}")
    raise SystemExit(1)

CITIES = ["İstanbul", "Ankara", "İzmir", "Bursa", "Antalya", "Adana", "Konya", "Gaziantep"]
CATEGORIES = ["Elektronik", "Giyim", "Ev & Yaşam", "Kitap", "Spor"]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rows", type=int, default=1_000_000)
    ap.add_argument("--out", default="data/sales.parquet")
    args = ap.parse_args()

    out = Path(__file__).resolve().parent.parent / args.out
    out.parent.mkdir(parents=True, exist_ok=True)

    banner("Parquet üretimi", f"{args.rows:,} satır → {out}")

    start = datetime(2025, 1, 1)
    rng = random.Random(42)

    print(f"{C.DIM}Üretiliyor (birkaç saniye sürebilir)…{C.RESET}")
    df = pd.DataFrame({
        "order_id":  range(1, args.rows + 1),
        "order_date": [start + timedelta(days=rng.randint(0, 364)) for _ in range(args.rows)],
        "city":      [rng.choice(CITIES) for _ in range(args.rows)],
        "category":  [rng.choice(CATEGORIES) for _ in range(args.rows)],
        "quantity":  [rng.randint(1, 5) for _ in range(args.rows)],
        "unit_price": [round(rng.uniform(20, 5000), 2) for _ in range(args.rows)],
    })
    df["total"] = (df["quantity"] * df["unit_price"]).round(2)

    df.to_parquet(out, index=False)
    size_mb = out.stat().st_size / 1024 / 1024
    print(f"{C.GREEN}✔{C.RESET} Yazıldı: {out}  ({size_mb:.1f} MB, {len(df):,} satır)")


if __name__ == "__main__":
    main()
