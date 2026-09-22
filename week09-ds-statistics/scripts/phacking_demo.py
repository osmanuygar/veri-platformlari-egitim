#!/usr/bin/env python3
"""
Hafta 9 — ✨ WOW DEMOSU: p-hacking simülasyonu

20 TAMAMEN İLİNTİSİZ (rastgele üretilmiş, gerçekte hiçbir ilişkisi olmayan)
değişken çifti üretir ve her biri için bağımsız t-testi çalıştırır.

α=0.05 eşiğiyle, ortalama olarak her 20 testten BİRİ "anlamlı" çıkar —
sırf şans eseri. Bu, çoklu karşılaştırma yapıp "anlamlı" olanı seçip
sunmanın (p-hacking / HARKing) neden bu kadar tehlikeli olduğunu gösterir.

Kullanım:
    python scripts/phacking_demo.py
    python scripts/phacking_demo.py --n-tests 100 --seed 7
"""
import argparse
from scipy import stats
import numpy as np


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n-tests", type=int, default=20)
    ap.add_argument("--sample-size", type=int, default=100)
    ap.add_argument("--alpha", type=float, default=0.05)
    ap.add_argument("--seed", type=int, default=2)
    args = ap.parse_args()

    rng = np.random.default_rng(args.seed)

    print(f"\n{'─'*64}")
    print(f"  {args.n_tests} bağımsız test, hepsi GERÇEKTE İLİNTİSİZ veriler üzerinde")
    print(f"  (iki grup da AYNI dağılımdan (μ=0, σ=1) üretildi)")
    print(f"{'─'*64}\n")

    significant = []
    for i in range(1, args.n_tests + 1):
        group_a = rng.normal(0, 1, args.sample_size)
        group_b = rng.normal(0, 1, args.sample_size)   # aynı dağılım — gerçek fark YOK

        t_stat, p_value = stats.ttest_ind(group_a, group_b)
        flag = "🔴 ANLAMLI (yanlış pozitif!)" if p_value < args.alpha else "  —"
        if p_value < args.alpha:
            significant.append(i)
        print(f"  Test {i:>3}:  p = {p_value:.4f}   {flag}")

    print(f"\n{'─'*64}")
    print(f"  Sonuç: {len(significant)}/{args.n_tests} test 'anlamlı' çıktı "
          f"(α={args.alpha})")
    print(f"  Testler: {significant if significant else '(yok)'}")
    print(f"  Beklenen yanlış pozitif oranı: ~%{args.alpha*100:.0f}")
    print(f"{'─'*64}")
    print(f"\n  ⚠️  Bu testlerin HİÇBİRİNDE gerçek bir ilişki yok — iki grup da\n"
          f"  aynı dağılımdan üretildi. 'Anlamlı' çıkanlar sadece şans eseri.\n"
          f"  20 farklı hipotezi test edip sadece 'anlamlı' çıkanı sunmak\n"
          f"  (p-hacking), bilimsel yayınlarda ve A/B testlerinde en sık\n"
          f"  yapılan istatistiksel hatalardan biridir.\n")


if __name__ == "__main__":
    main()
