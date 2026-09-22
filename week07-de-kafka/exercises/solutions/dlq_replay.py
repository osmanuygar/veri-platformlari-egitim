#!/usr/bin/env python3
"""
Hafta 7 — Alıştırma 5.4 çözümü: DLQ replay

DLQ'daki mesajları okur, DÜZELTİLEBİLİR olanları onarır ve orijinal topic'e
geri yazar. Düzeltilemeyenleri atlar.

Sonsuz döngüye karşı iki koruma var:
  1. Sadece bilinen ve onarılabilir hatalar replay edilir
  2. Her replay'de 'x-retry-count' başlığı artar; sınırı aşan mesaj atlanır

Kullanım:
    python exercises/solutions/dlq_replay.py --dry-run     # sadece göster
    python exercises/solutions/dlq_replay.py               # gerçekten yaz
    python exercises/solutions/dlq_replay.py --max-retry 5
"""
import argparse
import json
import sys
from datetime import datetime
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "scripts"))
from common import BOOTSTRAP, TOPIC_ORDERS, TOPIC_ORDERS_DLQ, C, banner, require  # noqa: E402

require("confluent_kafka")
from confluent_kafka import Consumer, Producer, KafkaError  # noqa: E402

MAX_RETRY_DEFAULT = 3
TURKISH_NUMBERS = {"bir": 1, "iki": 2, "üç": 3, "uc": 3, "dört": 4, "dort": 4, "beş": 5, "bes": 5}


def try_repair(raw: str, reason: str):
    """Mesajı onarmayı dene.

    Döner: (onarılmış_dict, açıklama) ya da (None, neden_onarılamadı)
    """
    try:
        data = json.loads(raw)
    except (json.JSONDecodeError, TypeError):
        # parse hataları onarılamaz: ham byte'lar zaten bozuk
        return None, "JSON çözümlenemiyor — onarılamaz"

    if not isinstance(data, dict):
        return None, "JSON bir nesne değil"

    fixes = []

    # 1) quantity metin olarak gelmiş: "iki" → 2, "3" → 3
    q = data.get("quantity")
    if isinstance(q, str):
        low = q.strip().lower()
        if low.isdigit():
            data["quantity"] = int(low); fixes.append(f"quantity '{q}' → {data['quantity']}")
        elif low in TURKISH_NUMBERS:
            data["quantity"] = TURKISH_NUMBERS[low]; fixes.append(f"quantity '{q}' → {data['quantity']}")
        else:
            return None, f"quantity '{q}' sayıya çevrilemiyor"

    # 2) total metin olarak gelmiş
    t = data.get("total")
    if isinstance(t, str):
        try:
            data["total"] = float(t.replace(",", "."))
            fixes.append(f"total '{t}' → {data['total']}")
        except ValueError:
            return None, f"total '{t}' sayıya çevrilemiyor"

    # 3) negatif quantity: işaret hatası varsayıp mutlak değer al
    if isinstance(data.get("quantity"), int) and data["quantity"] < 0:
        data["quantity"] = abs(data["quantity"]); fixes.append("quantity işareti düzeltildi")

    # 4) Onarılamayacak eksikler
    for field in ("order_id", "customer_id", "sku"):
        if field not in data:
            return None, f"'{field}' eksik — türetilemez"

    if data.get("quantity") is None or data.get("total") is None:
        return None, "quantity/total eksik — türetilemez"

    if not fixes:
        return None, "onarılacak bilinen bir sorun bulunamadı"

    return data, "; ".join(fixes)


def header_int(headers, name, default=0):
    for k, v in (headers or []):
        if k == name:
            try:
                return int(v.decode())
            except (ValueError, AttributeError):
                return default
    return default


def main():
    ap = argparse.ArgumentParser(description="DLQ replay")
    ap.add_argument("--dry-run", action="store_true", help="yazma, sadece göster")
    ap.add_argument("--max-retry", type=int, default=MAX_RETRY_DEFAULT)
    args = ap.parse_args()

    consumer = Consumer({
        "bootstrap.servers": BOOTSTRAP,
        "group.id": "dlq-replay",
        "auto.offset.reset": "earliest",
        "enable.auto.commit": False,
    })
    consumer.subscribe([TOPIC_ORDERS_DLQ])
    producer = Producer({"bootstrap.servers": BOOTSTRAP, "acks": "all",
                         "enable.idempotence": True})

    banner("DLQ Replay",
           f"{TOPIC_ORDERS_DLQ} → onar → {TOPIC_ORDERS}"
           + ("   [PROVA — hiçbir şey yazılmayacak]" if args.dry_run else ""))

    repaired = skipped = exhausted = 0
    empty = 0
    try:
        while empty < 5:
            msg = consumer.poll(1.0)
            if msg is None:
                empty += 1
                continue
            if msg.error():
                if msg.error().code() != KafkaError._PARTITION_EOF:
                    print(f"{C.RED}✖ {msg.error()}{C.RESET}")
                continue
            empty = 0

            try:
                env = json.loads(msg.value().decode("utf-8"))
            except (json.JSONDecodeError, UnicodeDecodeError):
                skipped += 1
                print(f"{C.DIM}⏭  DLQ zarfı bozuk, atlandı{C.RESET}")
                continue

            # ── Koruma 1: deneme sayacı ──────────────────────
            retries = header_int(msg.headers(), "x-retry-count")
            if retries >= args.max_retry:
                exhausted += 1
                print(f"{C.RED}🛑 Deneme hakkı bitti ({retries}/{args.max_retry}){C.RESET} "
                      f"{C.DIM}{env.get('failure_reason', '')[:60]}{C.RESET}")
                if not args.dry_run:
                    consumer.commit(msg, asynchronous=False)
                continue

            # ── Koruma 2: sadece onarılabilir olanlar ────────
            fixed, note = try_repair(env.get("raw_value"), env.get("failure_reason", ""))
            origin = (f"{env.get('source_topic')}"
                      f"[p{env.get('source_partition')}]@{env.get('source_offset')}")

            if fixed is None:
                skipped += 1
                print(f"{C.YELLOW}⏭  Atlandı{C.RESET} {C.DIM}{origin}  —  {note}{C.RESET}")
                continue

            repaired += 1
            print(f"{C.GREEN}🔧 Onarıldı{C.RESET} {C.DIM}{origin}{C.RESET}  {note}")

            if not args.dry_run:
                producer.produce(
                    TOPIC_ORDERS,
                    key=(env.get("key") or "").encode() or None,
                    value=json.dumps(fixed, ensure_ascii=False).encode(),
                    headers=[
                        ("x-retry-count", str(retries + 1).encode()),
                        ("x-replayed-at", datetime.now().isoformat().encode()),
                        ("x-original-offset", str(env.get("source_offset")).encode()),
                    ],
                )
                producer.poll(0)
                consumer.commit(msg, asynchronous=False)
    finally:
        producer.flush(10)
        consumer.close()
        print(f"\n{C.BOLD}Onarılan: {repaired}  ·  Atlanan: {skipped}  ·  "
              f"Hakkı biten: {exhausted}{C.RESET}")
        if args.dry_run:
            print(f"{C.DIM}Prova modundaydı — hiçbir şey yazılmadı. "
                  f"Gerçekten çalıştırmak için --dry-run'ı kaldırın.{C.RESET}")


if __name__ == "__main__":
    main()
