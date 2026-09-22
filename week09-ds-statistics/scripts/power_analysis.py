#!/usr/bin/env python3
"""
Hafta 9 — Alıştırma 2: Örneklem büyüklüğü / güç analizi

"%5'lik bir iyileşmeyi görmek için kaç kullanıcıya ihtiyacım var?" sorusuna
cevap verir. statsmodels'in power modülünü kullanır.

Kullanım:
    python scripts/power_analysis.py --baseline 0.11 --mde 0.02
    python scripts/power_analysis.py --baseline 0.11 --mde 0.005   # küçük etki
"""
import argparse
from statsmodels.stats.power import NormalIndPower
from statsmodels.stats.proportion import proportion_effectsize


def main():
    ap = argparse.ArgumentParser(description="A/B test örneklem büyüklüğü hesaplayıcı")
    ap.add_argument("--baseline", type=float, default=0.11, help="mevcut dönüşüm oranı")
    ap.add_argument("--mde", type=float, default=0.02,
                    help="Minimum Detectable Effect — yakalamak istediğiniz mutlak fark")
    ap.add_argument("--alpha", type=float, default=0.05)
    ap.add_argument("--power", type=float, default=0.80, help="istenen istatistiksel güç")
    args = ap.parse_args()

    p1 = args.baseline
    p2 = args.baseline + args.mde
    effect_size = proportion_effectsize(p1, p2)

    analysis = NormalIndPower()
    n_per_group = analysis.solve_power(
        effect_size=effect_size, alpha=args.alpha, power=args.power, ratio=1.0
    )

    print(f"\n{'─'*56}")
    print(f"  A/B Test Örneklem Büyüklüğü Hesabı")
    print(f"{'─'*56}")
    print(f"  Mevcut (baseline) dönüşüm  : %{p1*100:.1f}")
    print(f"  Yakalanmak istenen fark    : %{args.mde*100:.1f} puan (→ %{p2*100:.1f})")
    print(f"  α (Tip I hata)             : {args.alpha}")
    print(f"  Güç (1-β, Tip II hata pay.) : {args.power}")
    print(f"\n  ▶ Gereken örneklem: GRUP BAŞINA ~{int(n_per_group):,} kullanıcı")
    print(f"    (toplam ~{int(n_per_group*2):,} kullanıcı)")
    print(f"{'─'*56}\n")

    print("Karşılaştırma — MDE küçüldükçe gereken örneklem nasıl büyür:")
    for mde in [0.05, 0.02, 0.01, 0.005, 0.002]:
        es = proportion_effectsize(p1, p1 + mde)
        n = analysis.solve_power(effect_size=es, alpha=args.alpha, power=args.power, ratio=1.0)
        print(f"  MDE=%{mde*100:>4.1f}  →  grup başına ~{int(n):>8,} kullanıcı")
    print()


if __name__ == "__main__":
    main()
