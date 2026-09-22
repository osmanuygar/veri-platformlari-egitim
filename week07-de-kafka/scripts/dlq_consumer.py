#!/usr/bin/env python3
"""
Hafta 7 — Alıştırma 5: Dead Letter Topic (DLQ)

Gerçek akışta er ya da geç bozuk mesaj gelir. İki kötü seçenek vardır:
  1) Çöküp durmak      → tüm akış tıkanır ("poison pill")
  2) Sessizce atlamak  → veri sessizce kaybolur

Doğrusu üçüncüsü: işlenemeyen mesajı hata bilgisiyle DLQ topic'ine yaz,
akışa devam et, DLQ'yu ayrıca incele.

Kullanım:
    Terminal 1:  python dlq_consumer.py --group robust
    Terminal 2:  python poison_producer.py
    Terminal 3:  python dlq_consumer.py --inspect     # DLQ'yu oku
"""
import argparse
import json
import signal
from datetime import datetime, timezone

from common import BOOTSTRAP, TOPIC_ORDERS, TOPIC_ORDERS_DLQ, C, banner, require

require("confluent_kafka")
from confluent_kafka import Consumer, Producer, KafkaError  # noqa: E402

_running = True


def _stop(*_):
    global _running
    _running = False


def validate(order: dict) -> None:
    """İş kuralları. İhlal edilirse ValueError fırlatır."""
    for field in ("order_id", "customer_id", "sku", "quantity", "total"):
        if field not in order:
            raise ValueError(f"zorunlu alan eksik: {field}")
    if not isinstance(order["quantity"], int) or order["quantity"] <= 0:
        raise ValueError(f"geçersiz quantity: {order['quantity']!r}")
    if not isinstance(order["total"], (int, float)) or order["total"] < 0:
        raise ValueError(f"geçersiz total: {order['total']!r}")


def to_dlq(producer, msg, reason: str, stage: str):
    """Orijinal mesajı, nereden geldiğini ve neden düştüğünü birlikte sakla."""
    envelope = {
        "failed_at":       datetime.now(timezone.utc).isoformat(),
        "failure_stage":   stage,
        "failure_reason":  reason,
        "source_topic":    msg.topic(),
        "source_partition": msg.partition(),
        "source_offset":   msg.offset(),
        "key":             msg.key().decode("utf-8", "replace") if msg.key() else None,
        "raw_value":       msg.value().decode("utf-8", "replace") if msg.value() else None,
    }
    producer.produce(TOPIC_ORDERS_DLQ,
                     key=msg.key(),
                     value=json.dumps(envelope, ensure_ascii=False).encode("utf-8"))
    producer.poll(0)


def run_consumer(args):
    consumer = Consumer({
        "bootstrap.servers": BOOTSTRAP,
        "group.id": args.group,
        "auto.offset.reset": "earliest" if args.from_beginning else "latest",
        "enable.auto.commit": False,
    })
    consumer.subscribe([args.topic])
    producer = Producer({"bootstrap.servers": BOOTSTRAP, "acks": "all"})

    banner("Dayanıklı Consumer + DLQ",
           f"{args.topic} → işle · hata olursa → {TOPIC_ORDERS_DLQ}")

    ok = bad = 0
    try:
        while _running:
            msg = consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                if msg.error().code() != KafkaError._PARTITION_EOF:
                    print(f"{C.RED}✖ {msg.error()}{C.RESET}")
                continue

            # 1. aşama: çözümleme (parse)
            try:
                order = json.loads(msg.value().decode("utf-8"))
            except (json.JSONDecodeError, UnicodeDecodeError) as e:
                bad += 1
                to_dlq(producer, msg, str(e), "parse")
                print(f"{C.RED}→ DLQ{C.RESET} {C.DIM}(çözümlenemedi){C.RESET} "
                      f"offset={msg.offset()}  {str(e)[:60]}")
                consumer.commit(msg, asynchronous=False)
                continue

            # 2. aşama: doğrulama (validate)
            try:
                validate(order)
            except ValueError as e:
                bad += 1
                to_dlq(producer, msg, str(e), "validate")
                print(f"{C.RED}→ DLQ{C.RESET} {C.DIM}(doğrulama){C.RESET} "
                      f"offset={msg.offset()}  {e}")
                consumer.commit(msg, asynchronous=False)
                continue

            # 3. aşama: işle
            ok += 1
            print(f"{C.GREEN}✔{C.RESET} p{msg.partition()}@{msg.offset():<6} "
                  f"{order['sku']:<10} x{order['quantity']:<3} {order['total']:>10} TL")

            # Offset'i işlemden SONRA commit ediyoruz → at-least-once.
            consumer.commit(msg, asynchronous=False)
    finally:
        producer.flush(5)
        consumer.close()
        total = ok + bad
        rate = (bad / total * 100) if total else 0
        print(f"\n{C.BOLD}Başarılı: {ok}  ·  DLQ'ya düşen: {bad}  "
              f"({rate:.1f}% hata){C.RESET}")
        if bad:
            print(f"{C.DIM}İncelemek için: python dlq_consumer.py --inspect{C.RESET}")


def inspect():
    consumer = Consumer({
        "bootstrap.servers": BOOTSTRAP,
        "group.id": f"dlq-inspect-{datetime.now().timestamp():.0f}",
        "auto.offset.reset": "earliest",
        "enable.auto.commit": False,
    })
    consumer.subscribe([TOPIC_ORDERS_DLQ])
    banner(f"DLQ incelemesi — {TOPIC_ORDERS_DLQ}", "Yeni kayıt gelmeyince çıkar")

    n = 0
    try:
        empty = 0
        while _running and empty < 5:
            msg = consumer.poll(1.0)
            if msg is None:
                empty += 1
                continue
            if msg.error():
                continue
            empty = 0
            e = json.loads(msg.value().decode("utf-8"))
            n += 1
            print(f"{C.YELLOW}#{n}{C.RESET} {e['failed_at'][:19]}  "
                  f"{C.BOLD}{e['failure_stage']}{C.RESET}: {e['failure_reason']}")
            print(f"   {C.DIM}kaynak: {e['source_topic']}"
                  f"[p{e['source_partition']}]@{e['source_offset']}{C.RESET}")
            print(f"   {C.DIM}ham: {(e['raw_value'] or '')[:120]}{C.RESET}\n")
    finally:
        consumer.close()
        print(f"{C.BOLD}DLQ'daki kayıt: {n}{C.RESET}")


def main():
    ap = argparse.ArgumentParser(description="DLQ'lu dayanıklı consumer")
    ap.add_argument("--topic", default=TOPIC_ORDERS)
    ap.add_argument("--group", default="robust")
    ap.add_argument("--from-beginning", action="store_true")
    ap.add_argument("--inspect", action="store_true", help="DLQ içeriğini oku")
    args = ap.parse_args()

    signal.signal(signal.SIGINT, _stop)
    inspect() if args.inspect else run_consumer(args)


if __name__ == "__main__":
    main()
