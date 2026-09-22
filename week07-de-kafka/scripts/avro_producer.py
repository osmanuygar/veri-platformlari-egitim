#!/usr/bin/env python3
"""
Hafta 7 — Alıştırma 3: Schema Registry + Avro

JSON'da alan adını yanlış yazarsanız kimse fark etmez; tüketici aylar sonra çöker.
Avro + Schema Registry'de şema merkezi olarak doğrulanır ve evrimi kurallara bağlanır.

Kullanım:
    python avro_producer.py --count 20
    python avro_producer.py --schema v2 --count 5     # geriye uyumlu alan ekleme
    python avro_producer.py --schema bad --count 1    # uyumsuz değişiklik → REDDEDİLİR
"""
import argparse
import random
import uuid
from datetime import datetime, timezone

from common import BOOTSTRAP, SCHEMA_REGISTRY_URL, TOPIC_ORDERS_AVRO, C, banner, require

require("confluent_kafka")
require("fastavro")
from confluent_kafka import Producer  # noqa: E402
from confluent_kafka.schema_registry import SchemaRegistryClient  # noqa: E402
from confluent_kafka.schema_registry.avro import AvroSerializer  # noqa: E402
from confluent_kafka.serialization import SerializationContext, MessageField, StringSerializer  # noqa: E402

# ── v1: başlangıç şeması ─────────────────────────────────────
SCHEMA_V1 = """
{
  "type": "record",
  "name": "Order",
  "namespace": "tr.egitim.week07",
  "fields": [
    {"name": "order_id",    "type": "string"},
    {"name": "customer_id", "type": "int"},
    {"name": "sku",         "type": "string"},
    {"name": "quantity",    "type": "int"},
    {"name": "total",       "type": "double"},
    {"name": "created_at",  "type": "string"}
  ]
}
"""

# ── v2: GERİYE UYUMLU — yeni alanın VARSAYILANI var ──────────
# Eski tüketiciler bu mesajı okuyabilir; yeni alanı görmezden gelir.
SCHEMA_V2 = """
{
  "type": "record",
  "name": "Order",
  "namespace": "tr.egitim.week07",
  "fields": [
    {"name": "order_id",    "type": "string"},
    {"name": "customer_id", "type": "int"},
    {"name": "sku",         "type": "string"},
    {"name": "quantity",    "type": "int"},
    {"name": "total",       "type": "double"},
    {"name": "created_at",  "type": "string"},
    {"name": "channel",     "type": "string", "default": "web"},
    {"name": "discount",    "type": ["null", "double"], "default": null}
  ]
}
"""

# ── bad: UYUMSUZ — zorunlu alan SİLİNDİ ──────────────────────
# Registry 'backward' uyumluluk modunda bunu reddeder.
SCHEMA_BAD = """
{
  "type": "record",
  "name": "Order",
  "namespace": "tr.egitim.week07",
  "fields": [
    {"name": "order_id",    "type": "string"},
    {"name": "customer_id", "type": "int"},
    {"name": "amount",      "type": "double"}
  ]
}
"""

SCHEMAS = {"v1": SCHEMA_V1, "v2": SCHEMA_V2, "bad": SCHEMA_BAD}
SKUS = ["LPT-001", "PHN-001", "HDP-001", "MON-001", "KBD-001", "MSE-001"]


def build(version: str) -> dict:
    o = {
        "order_id":    str(uuid.uuid4()),
        "customer_id": random.randint(1, 8),
        "sku":         random.choice(SKUS),
        "quantity":    random.randint(1, 3),
        "total":       round(random.uniform(900, 55000), 2),
        "created_at":  datetime.now(timezone.utc).isoformat(),
    }
    if version == "v2":
        o["channel"] = random.choice(["web", "mobil", "magaza"])
        o["discount"] = random.choice([None, 50.0, 100.0, 250.0])
    if version == "bad":
        o = {"order_id": o["order_id"], "customer_id": o["customer_id"], "amount": o["total"]}
    return o


def main():
    ap = argparse.ArgumentParser(description="Avro producer")
    ap.add_argument("--topic", default=TOPIC_ORDERS_AVRO)
    ap.add_argument("--schema", default="v1", choices=list(SCHEMAS))
    ap.add_argument("--count", type=int, default=10)
    args = ap.parse_args()

    sr = SchemaRegistryClient({"url": SCHEMA_REGISTRY_URL})
    banner(f"Avro Producer → {args.topic}",
           f"şema={args.schema}   registry={SCHEMA_REGISTRY_URL}")

    try:
        serializer = AvroSerializer(sr, SCHEMAS[args.schema])
    except Exception as e:
        print(f"{C.RED}✖ Serializer kurulamadı: {e}{C.RESET}")
        return

    producer = Producer({"bootstrap.servers": BOOTSTRAP})
    keyser = StringSerializer("utf_8")
    ctx = SerializationContext(args.topic, MessageField.VALUE)

    sent, failed = 0, 0
    for _ in range(args.count):
        rec = build(args.schema)
        try:
            payload = serializer(rec, ctx)
        except Exception as e:
            failed += 1
            print(f"{C.RED}✖ Şema reddedildi{C.RESET}")
            print(f"  {C.DIM}{type(e).__name__}: {str(e)[:300]}{C.RESET}")
            print(f"\n{C.YELLOW}Bu beklenen sonuç.{C.RESET} Registry 'backward' modunda; "
                  f"zorunlu alan silmek eski tüketicileri kırardı.")
            print(f"{C.DIM}Uyumluluk modunu görmek için:"
                  f"  curl {SCHEMA_REGISTRY_URL}/config{C.RESET}")
            break
        producer.produce(topic=args.topic,
                         key=keyser(str(rec["customer_id"])),
                         value=payload)
        producer.poll(0)
        sent += 1
        print(f"{C.GREEN}✔{C.RESET} {rec.get('sku', '—'):<10} "
              f"{C.DIM}{ {k: v for k, v in rec.items() if k != 'order_id'} }{C.RESET}")

    producer.flush(10)

    print(f"\n{C.BOLD}Gönderilen: {sent}  ·  Reddedilen: {failed}{C.RESET}")
    if sent:
        subject = f"{args.topic}-value"
        print(f"\n{C.DIM}Kayıtlı şema sürümleri:"
              f"  curl {SCHEMA_REGISTRY_URL}/subjects/{subject}/versions{C.RESET}")


if __name__ == "__main__":
    main()
