#!/usr/bin/env python3
"""
Hafta 9 — alıştırma veri setlerini üretir

1. data-samples/ab_test_checkout.csv  — iki checkout tasarımının dönüşüm verisi
2. data-samples/order_values.csv       — bootstrap için sipariş tutarları (çarpık dağılım)

Kullanım:
    python scripts/generate_datasets.py
"""
from pathlib import Path
import numpy as np
import pandas as pd

OUT = Path(__file__).resolve().parent.parent / "data-samples"
OUT.mkdir(exist_ok=True)
rng = np.random.default_rng(42)


def make_ab_test():
    """
    A: eski checkout tasarımı, dönüşüm ~%11
    B: yeni checkout tasarımı, dönüşüm ~%13  (gerçek, küçük ama var olan bir etki)
    """
    n_a, n_b = 4200, 4300
    conv_a = rng.binomial(1, 0.11, n_a)
    conv_b = rng.binomial(1, 0.13, n_b)

    df = pd.concat([
        pd.DataFrame({"variant": "A", "converted": conv_a}),
        pd.DataFrame({"variant": "B", "converted": conv_b}),
    ], ignore_index=True)
    return df.sample(frac=1, random_state=1).reset_index(drop=True)


def make_order_values():
    """Sipariş tutarları — lognormal, gerçekçi şekilde sağa çarpık."""
    values = rng.lognormal(mean=5.5, sigma=0.7, size=3000)
    return pd.DataFrame({"order_id": range(1, len(values) + 1),
                          "order_value": np.round(values, 2)})


def main():
    df1 = make_ab_test()
    p1 = OUT / "ab_test_checkout.csv"
    df1.to_csv(p1, index=False)
    rates = df1.groupby("variant")["converted"].mean()
    print(f"✓ {p1}  (A={rates['A']:.1%}, B={rates['B']:.1%}, n={len(df1)})")

    df2 = make_order_values()
    p2 = OUT / "order_values.csv"
    df2.to_csv(p2, index=False)
    print(f"✓ {p2}  (medyan={df2['order_value'].median():.2f}, "
          f"ortalama={df2['order_value'].mean():.2f}, n={len(df2)})")


if __name__ == "__main__":
    main()
