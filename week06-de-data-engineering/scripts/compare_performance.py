#!/usr/bin/env python3
"""
Hafta 6 — Alıştırma 3: Postgres vs DuckDB performans karşılaştırması

Aynı agregasyon sorgusunu hem Postgres'teki tabloda hem DuckDB'nin
doğrudan okuduğu Parquet dosyasında çalıştırır, süreleri karşılaştırır.

Ön koşul: python scripts/generate_parquet.py

Kullanım:
    python scripts/compare_performance.py
    python scripts/compare_performance.py --load-postgres   # önce Postgres'e de yükle
"""
import argparse
import time
from pathlib import Path

from common import PG, banner, C

try:
    import duckdb
    import psycopg2
    import pandas as pd
except ImportError as e:
    print(f"{C.RED}Eksik bağımlılık: {e}. pip install -r requirements.txt{C.RESET}")
    raise SystemExit(1)

DATA = Path(__file__).resolve().parent.parent / "data" / "sales.parquet"

QUERY_TEMPLATE = """
    SELECT city, category, round(sum(total), 2) AS revenue, count(*) AS n
    FROM {source}
    GROUP BY city, category
    ORDER BY revenue DESC
"""


def timeit(label, fn):
    t0 = time.time()
    result = fn()
    dt = time.time() - t0
    print(f"  {label:<28} {dt:>8.3f} sn   ({len(result):,} satır sonuç)")
    return dt


def load_into_postgres():
    print(f"{C.DIM}Parquet → Postgres yükleniyor (yalnızca ilk seferde gerekir)…{C.RESET}")
    df = pd.read_parquet(DATA)
    import sqlalchemy
    engine = sqlalchemy.create_engine(
        f"postgresql://{PG['user']}:{PG['password']}@{PG['host']}:{PG['port']}/{PG['dbname']}"
    )
    df.to_sql("perf_sales", engine, schema="raw", if_exists="replace", index=False,
              chunksize=50_000, method="multi")
    print(f"{C.GREEN}✔ Yüklendi: raw.perf_sales ({len(df):,} satır){C.RESET}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--load-postgres", action="store_true")
    args = ap.parse_args()

    if not DATA.exists():
        print(f"{C.RED}✖ {DATA} yok. Önce: python scripts/generate_parquet.py{C.RESET}")
        raise SystemExit(1)

    banner("Postgres vs DuckDB", str(DATA))

    if args.load_postgres:
        load_into_postgres()

    print(f"\n{C.BOLD}DuckDB (Parquet'i doğrudan okuyarak):{C.RESET}")
    con = duckdb.connect()
    timeit("DuckDB → Parquet", lambda: con.execute(
        QUERY_TEMPLATE.format(source=f"'{DATA}'")).fetchall())

    print(f"\n{C.BOLD}PostgreSQL (raw.perf_sales tablosunda, indekssiz):{C.RESET}")
    try:
        conn = psycopg2.connect(**PG)
        cur = conn.cursor()
        cur.execute("SELECT to_regclass('raw.perf_sales')")
        if cur.fetchone()[0] is None:
            print(f"  {C.YELLOW}raw.perf_sales yok. --load-postgres ile yükleyin.{C.RESET}")
        else:
            def pg_query():
                cur.execute(QUERY_TEMPLATE.format(source="raw.perf_sales"))
                return cur.fetchall()
            timeit("PostgreSQL → tablo", pg_query)
        conn.close()
    except psycopg2.Error as e:
        print(f"  {C.RED}Postgres bağlantı hatası: {e}{C.RESET}")

    print(f"\n{C.DIM}Not: Bu adil bir 'hangisi daha iyi' karşılaştırması değil —\n"
          f"DuckDB tek makinede analitik iş yükü için optimize edilmiştir (sütunsal,\n"
          f"vektörize çalıştırma). Postgres çok kullanıcılı OLTP için optimize edilmiştir.\n"
          f"Doğru araç, doğru iş yüküne göre seçilir.{C.RESET}")


if __name__ == "__main__":
    main()
