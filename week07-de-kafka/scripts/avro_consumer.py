#!/usr/bin/env python3
"""
Hafta 7 — Avro tüketicisi

Şemayı Registry'den otomatik çeker. v1 yazılmış mesajları da,
v2 yazılmış mesajları da aynı kodla okur — geriye uyumluluk budur.

Kullanım:
    python avro_consumer.py --from-beginning
"""
import argparse
import signal

from common import BOOTSTRAP, SCHEMA_REGISTRY_URL, TOPIC_ORDERS_AVRO, C, banner, require

require("confluent_kafka")
require("fastavro")
from confluent_kafka import Consumer, KafkaError  # noqa: E402
from confluent_kafka.schema_registry import SchemaRegistryClient  # noqa: E402
from confluent_kafka.schema_registry.avro import AvroDeserializer  # noqa: E402
from confluent_kafka.serialization import SerializationContext, MessageField  # noqa: E402

_running = True


def _stop(*_):
    global _running
    _running = False


def main():
    ap = argparse.ArgumentParser(description="Avro consumer")
    ap.add_argument("--topic", default=TOPIC_ORDERS_AVRO)
    ap.add_argument("--group", default="avro-readers")
    ap.add_argument("--from-beginning", action="store_true")
    args = ap.parse_args()

    signal.signal(signal.SIGINT, _stop)

    sr = SchemaRegistryClient({"url": SCHEMA_REGISTRY_URL})
    # Şema verilmiyor: her mesajın başındaki 5 baytlık kimlikten
    # yazıldığı şema Registry'den çözülür.
    deser = AvroDeserializer(sr)

    consumer = Consumer({
        "bootstrap.servers": BOOTSTRAP,
        "group.id": args.group,
        "auto.offset.reset": "earliest" if args.from_beginning else "latest",
    })
    consumer.subscribe([args.topic])

    banner(f"Avro Consumer ← {args.topic}", f"group={args.group}   ·   Çıkış: Ctrl+C")

    ctx = SerializationContext(args.topic, MessageField.VALUE)
    n = 0
    try:
        while _running:
            msg = consumer.poll(1.0)
            if msg is None:
                continue
            if msg.error():
                if msg.error().code() != KafkaError._PARTITION_EOF:
                    print(f"{C.RED}✖ {msg.error()}{C.RESET}")
                continue
            try:
                rec = deser(msg.value(), ctx)
            except Exception as e:
                print(f"{C.RED}✖ Çözümlenemedi: {e}{C.RESET}")
                continue

            # v1 mesajında 'channel' yok; v2'de var. Kod ikisini de kaldırıyor.
            ch = rec.get("channel", f"{C.DIM}(v1 — alan yok){C.RESET}")
            print(f"{C.BLUE}p{msg.partition()}{C.RESET}@{msg.offset():<5} "
                  f"{rec['sku']:<10} x{rec['quantity']}  "
                  f"{rec['total']:>10.2f} TL   kanal={ch}")
            n += 1
    finally:
        consumer.close()
        print(f"\n{C.BOLD}Okunan: {n}{C.RESET}")


if __name__ == "__main__":
    main()
