#!/usr/bin/env python3
"""
Hafta 6 — Alıştırma 3: DuckDB ile doğrudan Parquet sorgulama

DuckDB, dosyayı hiç "yüklemeden" doğrudan SQL ile sorgular. Sunucu yok,
kurulum yok — tek bir Python kütüphanesi.

Kullanım:
    python scripts/generate_parquet.py             # önce veri üret
    python scripts/duckdb_demo.py
"""
import time
from pathlib import Path

from common import banner, C

try:
    import duckdb
except ImportError:
    print(f"{C.RED}duckdb kurulu değil: pip install -r requirements.txt{C.RESET}")
    raise SystemExit(1)

DATA = Path(__file__).resolve().parent.parent / "data" / "sales.parquet"


def main():
    if not DATA.exists():
        print(f"{C.RED}✖ {DATA} yok. Önce: python scripts/generate_parquet.py{C.RESET}")
        raise SystemExit(1)

    banner("DuckDB — dosyayı hiç yüklemeden sorgulama", str(DATA))

    con = duckdb.connect()  # bellek içi, kalıcı dosya yok

    t0 = time.time()
    total_rows = con.execute(f"SELECT count(*) FROM '{DATA}'").fetchone()[0]
    print(f"{C.DIM}Toplam satır: {total_rows:,}  ({time.time()-t0:.2f} sn){C.RESET}\n")

    print(f"{C.BOLD}Şehre göre ciro (ilk 5):{C.RESET}")
    t0 = time.time()
    res = con.execute(f"""
        SELECT city, round(sum(total), 2) AS revenue, count(*) AS orders
        FROM '{DATA}'
        GROUP BY city
        ORDER BY revenue DESC
        LIMIT 5
    """).fetchall()
    for city, revenue, orders in res:
        print(f"  {city:<12} {revenue:>14,.2f} TL   ({orders:,} sipariş)")
    print(f"{C.DIM}({time.time()-t0:.2f} sn){C.RESET}\n")

    print(f"{C.BOLD}Ay bazında trend (pencere fonksiyonu):{C.RESET}")
    t0 = time.time()
    res = con.execute(f"""
        SELECT
            date_trunc('month', order_date) AS month,
            round(sum(total), 2) AS revenue,
            round(sum(total) - lag(sum(total)) OVER (ORDER BY date_trunc('month', order_date)), 2) AS delta
        FROM '{DATA}'
        GROUP BY 1
        ORDER BY 1
    """).fetchall()
    for month, revenue, delta in res:
        arrow = "—" if delta is None else (f"{C.GREEN}▲{delta:,.0f}{C.RESET}" if delta >= 0 else f"{C.RED}▼{abs(delta):,.0f}{C.RESET}")
        print(f"  {str(month)[:7]}   {revenue:>14,.2f} TL   {arrow}")
    print(f"{C.DIM}({time.time()-t0:.2f} sn){C.RESET}")

    print(f"\n{C.BOLD}Not:{C.RESET} Yukarıdaki hiçbir sorgu öncesinde veriyi bir "
          f"tabloya YÜKLEMEDİK. DuckDB Parquet dosyasını doğrudan okuyor.")


if __name__ == "__main__":
    main()
