#!/usr/bin/env python3
"""
Hafta 7 — Alıştırma 5 yardımcısı: bilerek bozuk mesaj üret

dlq_consumer.py'yi açık tutup bunu çalıştırın: sağlam mesajlar işlenirken
bozuk olanların DLQ'ya yönlendiğini göreceksiniz.

Kullanım:
    python poison_producer.py                 # %30 bozuk, 20 mesaj
    python poison_producer.py --bad-rate 1.0  # hepsi bozuk
"""
import argparse
import json
import random
import uuid
from datetime import datetime, timezone

from common import BOOTSTRAP, TOPIC_ORDERS, C, banner, require

require("confluent_kafka")
from confluent_kafka import Producer  # noqa: E402

SKUS = ["LPT-001", "PHN-001", "HDP-001", "MON-001"]


def good():
    q = random.randint(1, 3)
    return json.dumps({
        "order_id": str(uuid.uuid4()),
        "customer_id": random.randint(1, 8),
        "sku": random.choice(SKUS),
        "quantity": q,
        "total": round(random.uniform(900, 50000), 2),
        "created_at": datetime.now(timezone.utc).isoformat(),
    }, ensure_ascii=False).encode()


def bad():
    """Gerçekte karşılaşılan bozulma türleri."""
    kind = random.choice(["truncated", "not_json", "missing_field",
                          "negative_qty", "wrong_type", "empty"])
    if kind == "truncated":
        return good()[:random.randint(10, 40)]                    # yarıda kesilmiş JSON
    if kind == "not_json":
        return b"<xml><order>yanlis format</order></xml>"          # yanlış serileştirme
    if kind == "missing_field":
        return json.dumps({"order_id": str(uuid.uuid4()),
                           "sku": "LPT-001"}).encode()             # zorunlu alan yok
    if kind == "negative_qty":
        return json.dumps({"order_id": str(uuid.uuid4()), "customer_id": 3,
                           "sku": "PHN-001", "quantity": -5,
                           "total": 100.0}).encode()               # iş kuralı ihlali
    if kind == "wrong_type":
        return json.dumps({"order_id": str(uuid.uuid4()), "customer_id": 3,
                           "sku": "MON-001", "quantity": "iki",
                           "total": "bedava"}).encode()            # tip hatası
    return b""                                                     # boş gövde


def main():
    ap = argparse.ArgumentParser(description="Bozuk mesaj üreteci")
    ap.add_argument("--count", type=int, default=20)
    ap.add_argument("--bad-rate", type=float, default=0.3, help="0.0–1.0")
    args = ap.parse_args()

    p = Producer({"bootstrap.servers": BOOTSTRAP, "acks": "all"})
    banner("☠️  Bozuk mesaj üreteci",
           f"{args.count} mesaj   ·   bozuk oranı %{args.bad_rate*100:.0f}")

    nb = 0
    for i in range(args.count):
        is_bad = random.random() < args.bad_rate
        payload = bad() if is_bad else good()
        nb += is_bad
        p.produce(TOPIC_ORDERS, key=str(random.randint(1, 8)).encode(), value=payload)
        p.poll(0)
        tag = f"{C.RED}BOZUK{C.RESET}" if is_bad else f"{C.GREEN}SAĞLAM{C.RESET}"
        print(f"{i+1:>3}. {tag}  {C.DIM}{payload[:70]!r}{C.RESET}")

    p.flush(10)
    print(f"\n{C.BOLD}Gönderildi: {args.count}  ·  bozuk: {nb}{C.RESET}")
    print(f"{C.DIM}dlq_consumer.py terminalinde DLQ'ya düşenleri görün.{C.RESET}")


if __name__ == "__main__":
    main()
