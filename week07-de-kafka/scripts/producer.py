#!/usr/bin/env python3
"""
Hafta 7 — Alıştırma 1: Producer

Sipariş olaylarını 'orders' topic'ine basar.

Öğrendiğimiz noktalar:
  • key seçimi partition dağılımını belirler (aynı key → aynı partition → sıra garantisi)
  • acks ayarı dayanıklılık/gecikme ödünleşmesidir
  • produce() asenkrondur; flush() olmadan mesaj kaybedilebilir

Kullanım:
    python producer.py                      # saniyede 5 olay, sonsuz
    python producer.py --count 100          # 100 olay üret ve dur
    python producer.py --rate 50            # saniyede 50 olay
    python producer.py --acks 0             # 'ateşle ve unut' modunu gözlemle
    python producer.py --key-by random      # key'i rastgele yap, dağılımı karşılaştır
"""
import argparse
import json
import random
import signal
import time
import uuid
from datetime import datetime, timezone

from common import BOOTSTRAP, TOPIC_ORDERS, C, banner, require

require("confluent_kafka")
from confluent_kafka import Producer  # noqa: E402

CITIES   = ["İstanbul", "Ankara", "İzmir", "Bursa", "Antalya", "Adana", "Konya"]
PRODUCTS = [
    ("LPT-001", "Ultrabook 14\"",      32999.00),
    ("PHN-001", "Akıllı Telefon 128GB", 21499.00),
    ("HDP-001", "Kablosuz Kulaklık",     3299.00),
    ("MON-001", "27\" 4K Monitör",       9899.00),
    ("KBD-001", "Mekanik Klavye",        2499.00),
    ("MSE-001", "Kablosuz Mouse",         899.00),
]

_running = True


def _stop(*_):
    global _running
    _running = False
    print(f"\n{C.YELLOW}⏹  Durduruluyor… (bekleyen mesajlar gönderiliyor){C.RESET}")


def make_order() -> dict:
    sku, name, price = random.choice(PRODUCTS)
    qty = random.randint(1, 3)
    return {
        "order_id":    str(uuid.uuid4()),
        "customer_id": random.randint(1, 8),
        "city":        random.choice(CITIES),
        "sku":         sku,
        "product":     name,
        "quantity":    qty,
        "unit_price":  price,
        "total":       round(price * qty, 2),
        "status":      "created",
        "created_at":  datetime.now(timezone.utc).isoformat(),
    }


def on_delivery(err, msg):
    """produce() çağrısı başına bir kez çalışır — ASENKRON.

    Bu callback tetiklendiğinde mesaj broker tarafından ONAYLANMIŞTIR.
    acks=0 ise onay beklenmez; hata burada hiç görünmeyebilir.
    """
    if err is not None:
        print(f"{C.RED}✖ Teslim edilemedi: {err}{C.RESET}")
    else:
        print(
            f"{C.GREEN}✔{C.RESET} {msg.topic()}"
            f"[p{msg.partition()}] @offset {msg.offset()}  "
            f"{C.DIM}key={msg.key().decode() if msg.key() else '—'}{C.RESET}"
        )


def main():
    ap = argparse.ArgumentParser(description="Kafka sipariş producer'ı")
    ap.add_argument("--topic", default=TOPIC_ORDERS)
    ap.add_argument("--count", type=int, default=0, help="0 = sonsuz")
    ap.add_argument("--rate",  type=float, default=5.0, help="saniyedeki olay sayısı")
    ap.add_argument("--acks",  default="all", choices=["0", "1", "all"],
                    help="0=onay bekleme, 1=lider yazdı, all=tüm ISR yazdı")
    ap.add_argument("--key-by", default="customer", choices=["customer", "city", "random", "none"],
                    help="partition dağılımını belirleyen key")
    ap.add_argument("--quiet", action="store_true", help="teslim loglarını yazdırma")
    args = ap.parse_args()

    signal.signal(signal.SIGINT, _stop)

    conf = {
        "bootstrap.servers": BOOTSTRAP,
        "client.id": "week07-producer",
        "acks": args.acks,
        # Aşağıdaki üçlü verimi doğrudan etkiler:
        "linger.ms": 10,          # 10 ms bekle, mesajları topla (batch)
        "batch.size": 32 * 1024,  # batch üst sınırı
        "compression.type": "snappy",
        # Idempotent producer: yeniden denemede tekrar yazmayı önler.
        # acks=all zorunludur, bu yüzden sadece o modda açıyoruz.
        "enable.idempotence": args.acks == "all",
    }

    producer = Producer(conf)

    banner(
        f"Producer → {args.topic}",
        f"acks={args.acks}  rate={args.rate}/sn  key={args.key_by}  "
        f"idempotence={conf['enable.idempotence']}",
    )

    interval = 1.0 / args.rate if args.rate > 0 else 0
    sent = 0
    started = time.time()

    while _running and (args.count == 0 or sent < args.count):
        order = make_order()

        if args.key_by == "customer":
            key = str(order["customer_id"])
        elif args.key_by == "city":
            key = order["city"]
        elif args.key_by == "random":
            key = str(uuid.uuid4())
        else:
            key = None  # key yoksa round-robin dağılır

        producer.produce(
            topic=args.topic,
            key=key.encode("utf-8") if key else None,
            value=json.dumps(order, ensure_ascii=False).encode("utf-8"),
            on_delivery=None if args.quiet else on_delivery,
        )

        # poll(0): kuyruktaki teslim callback'lerini işler. Çağrılmazsa
        # callback'ler birikir ve bellekte şişer.
        producer.poll(0)

        sent += 1
        if interval:
            time.sleep(interval)

    # flush(): bekleyen TÜM mesajlar teslim edilene kadar bloke eder.
    # Bunu unutmak, üretilen son mesajların kaybolmasının 1 numaralı sebebidir.
    remaining = producer.flush(timeout=10)
    elapsed = time.time() - started

    print(f"\n{C.BOLD}Özet{C.RESET}")
    print(f"  Üretilen  : {sent}")
    print(f"  Teslim edilmeyen : {remaining}")
    print(f"  Süre      : {elapsed:.1f} sn  ({sent/elapsed if elapsed else 0:.1f} msg/sn)")


if __name__ == "__main__":
    main()
