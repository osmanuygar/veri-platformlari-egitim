#!/usr/bin/env python3
"""
Hafta 10 — Telekom benzeri müşteri kaybı (churn) veri seti üretir

Kasıtlı olarak DENGESİZ (imbalanced): müşterilerin azınlığı (~%25-30) churn
eder — gerçek dünya churn veri setlerinin tipik oranı (klasik Telco Churn
veri setinde de ~%26.5). Bu, Alıştırma 2'deki "accuracy tuzağı"nın malzemesidir.

Kullanım:
    python scripts/generate_churn_dataset.py
"""
from pathlib import Path
import numpy as np
import pandas as pd

OUT = Path(__file__).resolve().parent.parent / "data-samples"
OUT.mkdir(exist_ok=True)
rng = np.random.default_rng(7)

N = 5000


def main():
    tenure_months = rng.integers(1, 72, N)
    monthly_charge = np.round(rng.uniform(20, 120, N), 2)
    contract = rng.choice(["month-to-month", "one-year", "two-year"], N, p=[0.55, 0.25, 0.20])
    support_calls = rng.poisson(1.5, N)
    has_addons = rng.choice([0, 1], N, p=[0.6, 0.4])
    payment_late_count = rng.poisson(0.8, N)
    # Yüksek kardinaliteli, churn ile HİÇBİR gerçek ilişkisi olmayan kimlik benzeri alan.
    # Alıştırma 5'te hedef ortalama kodlama (target mean encoding) sızıntısını
    # göstermek için var — az örnekli kategorilerde bu sızıntı çok daha çarpıcıdır.
    device_model = rng.integers(1, 151, N)  # 150 farklı "cihaz modeli", rastgele atanmış

    # Churn olasılığını gerçekçi bir mantıkla, birden fazla faktöre bağlı kur
    logit = (
        -2.2
        - 0.03 * tenure_months            # uzun süreli müşteri daha az churn eder
        + 0.015 * monthly_charge          # yüksek fatura churn riskini artırır
        + 0.35 * support_calls            # çok destek çağrısı = memnuniyetsizlik
        + 0.40 * payment_late_count        # geç ödeme = risk sinyali
        - 0.5 * has_addons                 # ek hizmet alanlar daha bağlı
        + np.where(contract == "month-to-month", 0.9, 0.0)
        + np.where(contract == "one-year", 0.1, 0.0)
    )
    prob_churn = 1 / (1 + np.exp(-logit))
    churned = rng.binomial(1, prob_churn)

    df = pd.DataFrame({
        "customer_id": range(1, N + 1),
        "tenure_months": tenure_months,
        "monthly_charge": monthly_charge,
        "contract_type": contract,
        "support_calls": support_calls,
        "has_addons": has_addons,
        "payment_late_count": payment_late_count,
        "device_model": device_model,
        "churned": churned,
    })

    p = OUT / "telco_churn.csv"
    df.to_csv(p, index=False)
    rate = df["churned"].mean()
    print(f"✓ {p}  (n={len(df)}, churn oranı=%{rate*100:.1f})")
    print(f"  Sadece '{ (df['churned']==0).mean()*100:.1f}%' diyen bir model bile "
          f"%{(df['churned']==0).mean()*100:.1f} accuracy alır — bkz. Alıştırma 2.")


if __name__ == "__main__":
    main()
