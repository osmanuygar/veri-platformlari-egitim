#!/usr/bin/env python3
"""
Hafta 7 — Alıştırma 2: Consumer lag ölçümü

Lag = (partition'daki son offset) − (grubun commit ettiği offset)
Yani "tüketici kaç mesaj geride kaldı".

Deney:
    Terminal 1:  python producer.py --rate 200 --quiet
    Terminal 2:  python consumer.py --group slow --process-ms 100
    Terminal 3:  python lag_monitor.py --group slow --watch
                 → lag'in sürekli büyüdüğünü görün. Tüketici üretime yetişemiyor.

Kullanım:
    python lag_monitor.py --group analytics
    python lag_monitor.py --group analytics --watch          # 2 sn'de bir yenile
    python lag_monitor.py --group analytics --topic orders
"""
import argparse
import signal
import time

from common import BOOTSTRAP, TOPIC_ORDERS, C, banner, require

require("confluent_kafka")
from confluent_kafka import Consumer, TopicPartition  # noqa: E402
from confluent_kafka.admin import AdminClient  # noqa: E402

_running = True


def _stop(*_):
    global _running
    _running = False


def partitions_of(topic: str):
    admin = AdminClient({"bootstrap.servers": BOOTSTRAP})
    meta = admin.list_topics(topic=topic, timeout=10)
    t = meta.topics.get(topic)
    if t is None or t.error is not None:
        raise SystemExit(f"{C.RED}✖ '{topic}' topic'i bulunamadı.{C.RESET}")
    return sorted(t.partitions.keys())


def measure(group: str, topic: str):
    """Grubun her partition'daki lag'ini hesapla."""
    # Gruba KATILMADAN sorgu yapıyoruz: subscribe() çağırmıyoruz,
    # bu yüzden çalışan tüketicileri rahatsız etmez, rebalance tetiklemez.
    c = Consumer({
        "bootstrap.servers": BOOTSTRAP,
        "group.id": group,
        "enable.auto.commit": False,
    })
    try:
        parts = [TopicPartition(topic, p) for p in partitions_of(topic)]
        committed = c.committed(parts, timeout=10)

        rows = []
        for tp in committed:
            low, high = c.get_watermark_offsets(
                TopicPartition(topic, tp.partition), timeout=10, cached=False)
            # offset < 0  → bu grup bu partition'da hiç commit yapmamış
            cur = tp.offset if tp.offset is not None and tp.offset >= 0 else None
            lag = (high - cur) if cur is not None else None
            rows.append(dict(partition=tp.partition, low=low, high=high,
                             committed=cur, lag=lag))
        return rows
    finally:
        c.close()


def render(group: str, topic: str, rows):
    total = sum(r["lag"] for r in rows if r["lag"] is not None)
    print(f"{C.BOLD}group={group}  topic={topic}{C.RESET}")
    print(f"{C.DIM}{'part':>5} {'ilk':>10} {'son':>10} {'commit':>10} {'LAG':>10}{C.RESET}")
    print(f"{C.DIM}{'─'*49}{C.RESET}")
    for r in rows:
        lag = r["lag"]
        if lag is None:
            lag_s, color = "—", C.DIM
        else:
            lag_s = str(lag)
            color = C.GREEN if lag == 0 else (C.YELLOW if lag < 1000 else C.RED)
        cm = "—" if r["committed"] is None else r["committed"]
        print(f"{r['partition']:>5} {r['low']:>10} {r['high']:>10} {str(cm):>10} "
              f"{color}{lag_s:>10}{C.RESET}")
    print(f"{C.DIM}{'─'*49}{C.RESET}")
    tcolor = C.GREEN if total == 0 else (C.YELLOW if total < 1000 else C.RED)
    print(f"{'TOPLAM':>38} {tcolor}{C.BOLD}{total:>10}{C.RESET}")
    if any(r["committed"] is None for r in rows):
        print(f"\n{C.DIM}'—' = bu grup o partition'da henüz commit yapmadı.{C.RESET}")


def main():
    ap = argparse.ArgumentParser(description="Consumer lag izleyici")
    ap.add_argument("--group", required=True)
    ap.add_argument("--topic", default=TOPIC_ORDERS)
    ap.add_argument("--watch", action="store_true", help="sürekli yenile")
    ap.add_argument("--interval", type=float, default=2.0)
    args = ap.parse_args()

    signal.signal(signal.SIGINT, _stop)

    if not args.watch:
        banner("Consumer Lag")
        render(args.group, args.topic, measure(args.group, args.topic))
        return

    prev_total = None
    while _running:
        rows = measure(args.group, args.topic)
        total = sum(r["lag"] for r in rows if r["lag"] is not None)
        print("\033[2J\033[H", end="")  # ekranı temizle
        banner("Consumer Lag — canlı", f"yenileme {args.interval}sn   ·   Çıkış: Ctrl+C")
        render(args.group, args.topic, rows)
        if prev_total is not None:
            d = total - prev_total
            trend = (f"{C.RED}↑ büyüyor (+{d})" if d > 0 else
                     f"{C.GREEN}↓ kapanıyor ({d})" if d < 0 else
                     f"{C.DIM}→ sabit")
            print(f"\n  Eğilim: {trend}{C.RESET}")
        prev_total = total
        time.sleep(args.interval)


if __name__ == "__main__":
    main()
