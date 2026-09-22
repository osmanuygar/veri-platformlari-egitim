#!/usr/bin/env python3
"""
Hafta 7 — CDC için veritabanı hareketi üretir

cdc_watch.py'yi başka bir terminalde açık tutun; buradaki her işlemin
anında oraya düştüğünü göreceksiniz.

Kullanım:
    python db_simulator.py                 # karışık işlemler, 2 sn arayla
    python db_simulator.py --op update     # sadece UPDATE
    python db_simulator.py --count 10 --delay 0.5
"""
import argparse
import random
import signal
import time
from datetime import datetime

from common import PG, C, banner, require

require("psycopg2")
import psycopg2  # noqa: E402

_running = True


def _stop(*_):
    global _running
    _running = False


def op_insert_customer(cur):
    n = random.randint(1000, 999999)
    cur.execute(
        "INSERT INTO shop.customers (full_name, email, city, segment) "
        "VALUES (%s, %s, %s, %s) RETURNING id",
        (f"Test Müşteri {n}", f"test{n}@example.com",
         random.choice(["İstanbul", "Ankara", "İzmir", "Bursa"]),
         random.choice(["standard", "premium", "gold"])),
    )
    return f"customers ➕ yeni müşteri id={cur.fetchone()[0]}"


def op_update_price(cur):
    cur.execute("SELECT id, sku, price FROM shop.products ORDER BY random() LIMIT 1")
    pid, sku, old = cur.fetchone()
    new = round(float(old) * random.uniform(0.85, 1.20), 2)
    cur.execute("UPDATE shop.products SET price = %s WHERE id = %s", (new, pid))
    return f"products  ✏️  {sku}: {old} → {new} TL"


def op_update_stock(cur):
    cur.execute("SELECT id, sku, stock FROM shop.products WHERE stock > 0 ORDER BY random() LIMIT 1")
    row = cur.fetchone()
    if not row:
        return None
    pid, sku, stock = row
    sold = min(stock, random.randint(1, 3))
    cur.execute("UPDATE shop.products SET stock = stock - %s WHERE id = %s", (sold, pid))
    return f"products  📦 {sku}: stok {stock} → {stock - sold}"


def op_new_order(cur):
    cur.execute("SELECT id FROM shop.customers ORDER BY random() LIMIT 1")
    cid = cur.fetchone()[0]
    cur.execute("SELECT id, price FROM shop.products ORDER BY random() LIMIT 1")
    pid, price = cur.fetchone()
    qty = random.randint(1, 3)
    total = round(float(price) * qty, 2)
    cur.execute(
        "INSERT INTO shop.orders (customer_id, status, total_amount) "
        "VALUES (%s, 'created', %s) RETURNING id", (cid, total))
    oid = cur.fetchone()[0]
    cur.execute(
        "INSERT INTO shop.order_items (order_id, product_id, quantity, unit_price) "
        "VALUES (%s, %s, %s, %s)", (oid, pid, qty, price))
    return f"orders    🛒 sipariş #{oid}, {total} TL ({qty} adet)"


def op_advance_status(cur):
    flow = {"created": "paid", "paid": "shipped", "shipped": "completed"}
    cur.execute(
        "SELECT id, status FROM shop.orders WHERE status <> 'completed' ORDER BY random() LIMIT 1")
    row = cur.fetchone()
    if not row:
        return None
    oid, st = row
    nxt = flow.get(st, "completed")
    cur.execute("UPDATE shop.orders SET status = %s WHERE id = %s", (nxt, oid))
    return f"orders    ➡️  #{oid}: {st} → {nxt}"


def op_delete_test_customer(cur):
    cur.execute(
        "SELECT id FROM shop.customers WHERE email LIKE 'test%%@example.com' "
        "AND id NOT IN (SELECT customer_id FROM shop.orders) ORDER BY random() LIMIT 1")
    row = cur.fetchone()
    if not row:
        return None
    cur.execute("DELETE FROM shop.customers WHERE id = %s", (row[0],))
    return f"customers 🗑  test müşterisi id={row[0]} silindi"


OPS = {
    "insert": [op_insert_customer, op_new_order],
    "update": [op_update_price, op_update_stock, op_advance_status],
    "delete": [op_delete_test_customer],
}


def main():
    ap = argparse.ArgumentParser(description="CDC için veritabanı hareketi üretici")
    ap.add_argument("--op", choices=["all", "insert", "update", "delete"], default="all")
    ap.add_argument("--count", type=int, default=0, help="0 = sonsuz")
    ap.add_argument("--delay", type=float, default=2.0, help="işlemler arası saniye")
    args = ap.parse_args()

    signal.signal(signal.SIGINT, _stop)

    pool = sum(OPS.values(), []) if args.op == "all" else OPS[args.op]

    conn = psycopg2.connect(**PG)
    conn.autocommit = True  # her işlem hemen commit → CDC anında görünür

    banner("🎲 Veritabanı hareket üreteci",
           f"{PG['host']}:{PG['port']}/{PG['dbname']}   ·   mod={args.op}   ·   Çıkış: Ctrl+C")
    print(f"{C.DIM}Diğer terminalde 'python cdc_watch.py' açık olsun.{C.RESET}\n")

    done = 0
    try:
        with conn.cursor() as cur:
            while _running and (args.count == 0 or done < args.count):
                try:
                    desc = random.choice(pool)(cur)
                except psycopg2.Error as e:
                    print(f"{C.RED}✖ SQL hatası: {str(e).strip()}{C.RESET}")
                    continue
                if desc:
                    print(f"{C.DIM}{datetime.now():%H:%M:%S}{C.RESET}  {desc}")
                    done += 1
                if args.delay:
                    time.sleep(args.delay)
    finally:
        conn.close()
        print(f"\n{C.BOLD}Uygulanan işlem: {done}{C.RESET}")


if __name__ == "__main__":
    main()
