#!/usr/bin/env python3
"""
Hafta 7 — Alıştırma 2: Consumer ve Consumer Group

Aynı --group ile birden fazla kopya çalıştırın: partition'lar aralarında paylaşılır.
Birini kapatın: rebalance'ı canlı görün.

Kullanım:
    python consumer.py --group analytics
    python consumer.py --group analytics          # 2. terminal
    python consumer.py --group analytics          # 3. terminal
    python consumer.py --group audit --from-beginning
    python consumer.py --group slow --manual-commit --process-ms 500
"""
import argparse
import json
import signal
import time

from common import BOOTSTRAP, TOPIC_ORDERS, C, banner, require

require("confluent_kafka")
from confluent_kafka import Consumer, KafkaError, TopicPartition  # noqa: E402

_running = True


def _stop(*_):
    global _running
    _running = False
    print(f"\n{C.YELLOW}⏹  Gruptan ayrılınıyor…{C.RESET}")


def on_assign(consumer, partitions):
    """Rebalance sonucu bu tüketiciye atanan partition'lar."""
    ids = sorted(p.partition for p in partitions)
    print(f"{C.GREEN}⇄ ATAMA{C.RESET}  bu tüketiciye düşen partition'lar: {ids or '— (boşta)'}")


def on_revoke(consumer, partitions):
    """Rebalance başlarken tüm atamalar geri alınır."""
    ids = sorted(p.partition for p in partitions)
    print(f"{C.YELLOW}⇄ GERİ ALMA{C.RESET}  bırakılan partition'lar: {ids}")


def main():
    ap = argparse.ArgumentParser(description="Kafka consumer")
    ap.add_argument("--topic", default=TOPIC_ORDERS)
    ap.add_argument("--group", default="analytics", help="consumer group id")
    ap.add_argument("--from-beginning", action="store_true",
                    help="grup ilk kez çalışıyorsa en baştan oku")
    ap.add_argument("--manual-commit", action="store_true",
                    help="offset'i işlem bittikten SONRA elle commit et (at-least-once)")
    ap.add_argument("--process-ms", type=int, default=0,
                    help="her mesaj için yapay işlem süresi (lag üretmek için)")
    args = ap.parse_args()

    signal.signal(signal.SIGINT, _stop)

    conf = {
        "bootstrap.servers": BOOTSTRAP,
        "group.id": args.group,
        "auto.offset.reset": "earliest" if args.from_beginning else "latest",
        "enable.auto.commit": not args.manual_commit,
        # Bu süre içinde poll() çağrılmazsa tüketici "öldü" sayılır ve rebalance tetiklenir.
        "max.poll.interval.ms": 300000,
        "session.timeout.ms": 45000,
        # Cooperative sticky: rebalance sırasında TÜM partition'ları bırakmak yerine
        # sadece gerekenleri taşır — "stop-the-world" duraklamasını azaltır.
        "partition.assignment.strategy": "cooperative-sticky",
    }

    consumer = Consumer(conf)
    consumer.subscribe([args.topic], on_assign=on_assign, on_revoke=on_revoke)

    banner(
        f"Consumer ← {args.topic}",
        f"group={args.group}  commit={'manuel' if args.manual_commit else 'otomatik'}  "
        f"başlangıç={'earliest' if args.from_beginning else 'latest'}",
    )
    print(f"{C.DIM}İpucu: aynı komutu başka terminalde çalıştırın, partition'ların "
          f"paylaşıldığını görün.{C.RESET}\n")

    count = 0
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

            try:
                value = json.loads(msg.value().decode("utf-8"))
                label = value.get("product") or value.get("sku") or "—"
                total = value.get("total", "")
            except (json.JSONDecodeError, UnicodeDecodeError):
                label, total = f"{C.RED}<çözümlenemedi>{C.RESET}", ""

            key = msg.key().decode() if msg.key() else "—"
            print(
                f"{C.BLUE}p{msg.partition()}{C.RESET}"
                f"{C.DIM}@{msg.offset():<6}{C.RESET} "
                f"key={key:<10} {label:<24} {total}"
            )

            if args.process_ms:
                time.sleep(args.process_ms / 1000.0)

            count += 1

            if args.manual_commit:
                # İŞLEM BİTTİKTEN SONRA commit → at-least-once.
                # Burada çökersek mesaj yeniden işlenir (tekrar), ama KAYBOLMAZ.
                consumer.commit(asynchronous=False)
    finally:
        # close() grubu düzgünce terk eder ve rebalance'ı hemen tetikler.
        # Çağrılmazsa grup session.timeout.ms kadar bekler.
        consumer.close()
        print(f"\n{C.BOLD}Toplam işlenen: {count} mesaj{C.RESET}")


if __name__ == "__main__":
    main()
