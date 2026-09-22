#!/usr/bin/env python3
"""
Hafta 9 — Alıştırma 3: Bootstrap ile güven aralığı

Medyan gibi metriklerin kapalı-form (formülle hesaplanan) güven aralığı
yoktur ya da hesaplaması zordur. Bootstrap, veriyi kendisinden TEKRAR
TEKRAR (yerine koyarak) örnekleyip dağılımı ampirik olarak inşa eder.

Kullanım:
    python scripts/generate_datasets.py    # önce veri üret
    python scripts/bootstrap_ci.py
    python scripts/bootstrap_ci.py --n-boot 5000 --statistic mean
"""
import argparse
from pathlib import Path
import numpy as np
import pandas as pd

DATA = Path(__file__).resolve().parent.parent / "data-samples" / "order_values.csv"

STATS = {
    "median": np.median,
    "mean": np.mean,
    "p90": lambda x: np.percentile(x, 90),
}


def bootstrap_ci(data, stat_fn, n_boot=2000, ci=0.95, seed=42):
    rng = np.random.default_rng(seed)
    n = len(data)
    boot_stats = np.empty(n_boot)
    for i in range(n_boot):
        sample = rng.choice(data, size=n, replace=True)   # yerine koyarak örnekle
        boot_stats[i] = stat_fn(sample)
    lower = np.percentile(boot_stats, (1 - ci) / 2 * 100)
    upper = np.percentile(boot_stats, (1 + ci) / 2 * 100)
    return lower, upper, boot_stats


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--statistic", choices=list(STATS), default="median")
    ap.add_argument("--n-boot", type=int, default=2000)
    ap.add_argument("--ci", type=float, default=0.95)
    args = ap.parse_args()

    if not DATA.exists():
        print(f"✖ {DATA} yok. Önce: python scripts/generate_datasets.py")
        raise SystemExit(1)

    df = pd.read_csv(DATA)
    values = df["order_value"].to_numpy()
    stat_fn = STATS[args.statistic]
    point_estimate = stat_fn(values)

    print(f"\n{'─'*56}")
    print(f"  Bootstrap Güven Aralığı — {args.statistic}")
    print(f"{'─'*56}")
    print(f"  Veri: {len(values)} sipariş, gözlemlenen {args.statistic} = {point_estimate:.2f} TL")
    print(f"  Bootstrap tekrar sayısı: {args.n_boot}")

    lower, upper, boot_stats = bootstrap_ci(values, stat_fn, args.n_boot, args.ci)

    print(f"\n  %{args.ci*100:.0f} Güven Aralığı: [{lower:.2f}, {upper:.2f}] TL")
    print(f"  Yorum: Bu prosedürü defalarca tekrarlasak, üretilen aralıkların")
    print(f"  yaklaşık %{args.ci*100:.0f}'i gerçek {args.statistic} değerini içerirdi.")
    print(f"{'─'*56}\n")


if __name__ == "__main__":
    main()
