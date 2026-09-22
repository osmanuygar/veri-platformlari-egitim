#!/usr/bin/env python3
"""
Hafta 7 — ✨ WOW DEMOSU: Debezium CDC akışını canlı izle

İki terminal açın:
    Terminal 1:  python cdc_watch.py
    Terminal 2:  python db_simulator.py        (veya psql ile elle UPDATE atın)

PostgreSQL'de yaptığınız her INSERT / UPDATE / DELETE'in milisaniyeler içinde
Kafka topic'ine düştüğünü göreceksiniz. Uygulamaya tek satır kod eklemeden.

Kullanım:
    python cdc_watch.py                    # tüm shop.* tablolarını izle
    python cdc_watch.py --table products   # sadece products
    python cdc_watch.py --raw              # ham JSON'u da bas
"""
import argparse
import json
import signal
from datetime import datetime

from common import BOOTSTRAP, C, banner, require

require("confluent_kafka")
from confluent_kafka import Consumer, KafkaError  # noqa: E402

# Debezium op kodları
OPS = {
    "c": (f"{C.GREEN}INSERT{C.RESET}", "➕"),
    "r": (f"{C.CYAN}SNAPSHOT{C.RESET}", "📸"),
    "u": (f"{C.YELLOW}UPDATE{C.RESET}", "✏️ "),
    "d": (f"{C.RED}DELETE{C.RESET}", "🗑 "),
}

_running = True


def _stop(*_):
    global _running
    _running = False


def fmt_row(payload: dict, limit: int = 5) -> str:
    """Satırı kısa ve okunur biçimde yazdır."""
    if not payload:
        return f"{C.DIM}(boş){C.RESET}"
    skip = {"__op", "__source_ts_ms", "__source_lsn", "__deleted"}
    items = [(k, v) for k, v in payload.items() if k not in skip]
    shown = items[:limit]
    parts = []
    for k, v in shown:
        s = str(v)
        if len(s) > 28:
            s = s[:25] + "…"
        parts.append(f"{C.DIM}{k}={C.RESET}{s}")
    more = f" {C.DIM}(+{len(items)-limit} alan){C.RESET}" if len(items) > limit else ""
    return "  ".join(parts) + more


def main():
    ap = argparse.ArgumentParser(description="Debezium CDC izleyici")
    ap.add_argument("--table", help="sadece bu tabloyu izle (customers|products|orders|order_items)")
    ap.add_argument("--raw", action="store_true", help="ham JSON'u da bas")
    ap.add_argument("--from-beginning", action="store_true",
                    help="snapshot dahil baştan oku")
    args = ap.parse_args()

    signal.signal(signal.SIGINT, _stop)

    consumer = Consumer({
        "bootstrap.servers": BOOTSTRAP,
        "group.id": f"cdc-watch-{datetime.now().timestamp():.0f}",  # her çalıştırmada taze grup
        "auto.offset.reset": "earliest" if args.from_beginning else "latest",
        "enable.auto.commit": False,
    })

    if args.table:
        topics = [f"shop.shop.{args.table}"]
        consumer.subscribe(topics)
        scope = args.table
    else:
        # ^ ile başlayan ifade regex olarak yorumlanır
        consumer.subscribe(["^shop\\.shop\\..*"])
        scope = "tüm shop.* tabloları"

    banner("🔴 CANLI — Debezium CDC akışı", f"İzlenen: {scope}   ·   Çıkış: Ctrl+C")
    print(f"{C.DIM}Başka bir terminalde 'python db_simulator.py' çalıştırın "
          f"ya da psql ile UPDATE atın.{C.RESET}\n")

    seen = 0
    try:
        while _running:
            msg = consumer.poll(timeout=1.0)
            if msg is None:
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    continue
                print(f"{C.RED}✖ {msg.error()}{C.RESET}")
                continue

            table = msg.topic().split(".")[-1]
            raw = msg.value()

            if raw is None:
                # DELETE sonrası "tombstone": aynı key'e null değer.
                # Log compaction'ın kaydı silmesi için gerekir.
                print(f"{C.DIM}🪦 TOMBSTONE  {table:<12} key={msg.key().decode() if msg.key() else '—'}{C.RESET}")
                seen += 1
                continue

            try:
                payload = json.loads(raw.decode("utf-8"))
            except (json.JSONDecodeError, UnicodeDecodeError):
                print(f"{C.RED}✖ JSON çözümlenemedi{C.RESET}")
                continue

            # ExtractNewRecordState SMT açıkken op bilgisi __op alanında gelir
            op = payload.get("__op", "?")
            label, icon = OPS.get(op, (f"{C.DIM}{op}{C.RESET}", "•"))
            ts = datetime.now().strftime("%H:%M:%S.%f")[:-3]

            print(f"{icon} {ts}  {label:<20} {C.BOLD}{table:<13}{C.RESET} {fmt_row(payload)}")

            if args.raw:
                print(f"   {C.DIM}{json.dumps(payload, ensure_ascii=False)}{C.RESET}")

            seen += 1
    finally:
        consumer.close()
        print(f"\n{C.BOLD}Yakalanan CDC olayı: {seen}{C.RESET}")


if __name__ == "__main__":
    main()
