#!/usr/bin/env python3
"""
Hafta 8 — Alıştırma veri setlerini üretir

İki dosya üretir:
  1. data-samples/customers_dirty.csv   — kasıtlı olarak "kirli" müşteri verisi
     (eksik değerler, aykırı değerler, kopya satırlar, sızıntı sütunu)
  2. data-samples/campaign_simpsons.csv — Simpson paradoksu demosu için
     kampanya dönüşüm verisi

Kullanım:
    python scripts/generate_dataset.py
"""
import random
from datetime import datetime, timedelta
from pathlib import Path

try:
    import pandas as pd
    import numpy as np
    from faker import Faker
except ImportError:
    print("pandas/numpy/faker kurulu değil. pip install -r requirements.txt")
    raise SystemExit(1)

OUT = Path(__file__).resolve().parent.parent / "data-samples"
OUT.mkdir(exist_ok=True)

random.seed(42)
np.random.seed(42)
fake = Faker("tr_TR")
Faker.seed(42)


def make_dirty_customers(n=2000):
    """Gerçekçi bir e-ticaret müşteri veri seti — kasıtlı kusurlarla."""
    cities = ["İstanbul", "Ankara", "İzmir", "Bursa", "Antalya", "Adana", "Konya", "Gaziantep"]
    segments = ["bronze", "silver", "gold"]

    rows = []
    for i in range(1, n + 1):
        signup = datetime(2023, 1, 1) + timedelta(days=random.randint(0, 700))
        # Gelir dağılımı sağa çarpık (birkaç çok yüksek gelirli müşteri) — çarpıklık dersi için
        income = max(8000, np.random.lognormal(mean=9.5, sigma=0.6))
        age = int(np.clip(np.random.normal(38, 12), 18, 85))
        order_count = np.random.poisson(6)
        total_spent = round(order_count * np.random.uniform(150, 900), 2)

        row = {
            "customer_id": i,
            "full_name": fake.name(),
            "age": age,
            "city": random.choice(cities),
            "income": round(income, 2),
            "signup_date": signup.date().isoformat(),
            "segment": random.choices(segments, weights=[0.5, 0.35, 0.15])[0],
            "order_count": order_count,
            "total_spent": total_spent,
            "avg_order_value": round(total_spent / order_count, 2) if order_count else 0,
            "churned": random.choices([0, 1], weights=[0.75, 0.25])[0],
        }

        # ── Kasıtlı kusurlar ──────────────────────────────────
        # 1) Eksik değer: income'ın %8'i, city'nin %3'ü eksik (MCAR benzeri)
        if random.random() < 0.08:
            row["income"] = None
        if random.random() < 0.03:
            row["city"] = None
        # age'de sistematik eksiklik: yaşlı müşterilerde formu doldurmama eğilimi (MAR benzeri)
        if age > 65 and random.random() < 0.25:
            row["age"] = None

        # 2) Aykırı değer: %1 ihtimalle veri girişi hatası (yaş 150, gelir negatif vb.)
        if random.random() < 0.01:
            row["age"] = random.choice([150, -5, 999])
        if random.random() < 0.01:
            row["income"] = -abs(row["income"] or 1000)  # veri girişi hatası

        # 3) VERİ SIZINTISI TUZAĞI: 'has_cancelled_after_churn' aslında churn
        #    OLDUKTAN SONRA bilinen bir bilgi — model eğitiminde kullanılırsa
        #    "gelecekten bilgi sızdırma" (data leakage) örneği olur.
        row["cancellation_flag_POST_CHURN"] = row["churned"]  # kasıtlı: churn ile %100 ilişkili

        rows.append(row)

    df = pd.DataFrame(rows)

    # 4) Kopya satırlar: %2 oranında bilerek tekrar ekle
    dupes = df.sample(frac=0.02, random_state=1)
    df = pd.concat([df, dupes], ignore_index=True)

    # 5) Tutarsız string biçimi: city sütununda bazı satırlarda baş/son boşluk, büyük harf
    mask = df.sample(frac=0.05, random_state=2).index
    df.loc[mask, "city"] = df.loc[mask, "city"].astype(str).str.upper() + "  "

    return df.sample(frac=1, random_state=3).reset_index(drop=True)  # karıştır


def make_simpsons_paradox_campaign():
    """
    Simpson paradoksu demosu: B kampanyası HER cihaz türünde A'dan daha iyi
    dönüşüm sağlar — ama genel (toplam) rakamlara bakınca A daha iyi GÖRÜNÜR.

    Sır: A'nın trafiğinin çoğu zaten yüksek dönüşümlü "masaüstü" segmentinde,
    B'nin trafiğinin çoğu düşük dönüşümlü "mobil" segmentinde yoğunlaşmış.
    Bu karışım etkisi (confounding), her segmentte kaybeden A'yı genelde
    kazanan gibi gösteriyor — klasik "böbrek taşı tedavisi" paradoksuyla
    birebir aynı istatistiksel yapı.
    """
    # (kampanya, cihaz, gösterim, dönüşüm)
    data = [
        ("A", "mobil",     1000,   10),   # %1.0  dönüşüm  (B'den KÖTÜ)
        ("A", "masaüstü",  9000, 1800),   # %20.0 dönüşüm  (B'den KÖTÜ)
        ("B", "mobil",     9000,  900),   # %10.0 dönüşüm  (A'dan İYİ)
        ("B", "masaüstü",  1000,  300),   # %30.0 dönüşüm  (A'dan İYİ)
    ]

    rows = []
    for campaign, device, impressions, conversions in data:
        converted_flags = [1] * conversions + [0] * (impressions - conversions)
        random.shuffle(converted_flags)
        for c in converted_flags:
            rows.append({"campaign": campaign, "device": device, "converted": c})

    df = pd.DataFrame(rows).sample(frac=1, random_state=4).reset_index(drop=True)
    return df


def main():
    df1 = make_dirty_customers()
    p1 = OUT / "customers_dirty.csv"
    df1.to_csv(p1, index=False)
    print(f"✓ {p1}  ({len(df1)} satır, {df1.isna().sum().sum()} eksik hücre)")

    df2 = make_simpsons_paradox_campaign()
    p2 = OUT / "campaign_simpsons.csv"
    df2.to_csv(p2, index=False)
    print(f"✓ {p2}  ({len(df2)} satır)")

    # Doğrulama: genel oranlar A > B, cihaz bazında B > A olmalı
    overall = df2.groupby("campaign")["converted"].mean()
    by_device = df2.groupby(["campaign", "device"])["converted"].mean()
    paradox_ok = (overall["A"] > overall["B"]) and \
                 (by_device["A", "mobil"] < by_device["B", "mobil"]) and \
                 (by_device["A", "masaüstü"] < by_device["B", "masaüstü"])
    print(f"\nGenel dönüşüm: A={overall['A']:.1%}  B={overall['B']:.1%}  "
          f"({'A daha iyi görünüyor' if overall['A'] > overall['B'] else 'B daha iyi görünüyor'})")
    print("Cihaz bazında (B her ikisinde de A'dan iyi olmalı):")
    print(by_device.apply(lambda x: f"{x:.1%}"))
    print(f"\n{'✓ Simpson paradoksu doğrulandı' if paradox_ok else '✗ PARADOKS OLUŞMADI — sayıları kontrol edin'}")


if __name__ == "__main__":
    main()
