#!/usr/bin/env python3
"""
Hafta 10 — Alıştırma 5: Sızıntılı pipeline'ı bul ve düzelt

`device_model` sütunu (150 farklı değer) churn ile GERÇEKTE hiçbir ilişkiye
sahip değil — veri üretim script'inde tamamen rastgele atandı. Bunu hedef
ortalama kodlama (target mean encoding) ile sayısallaştırırken:

  ❌ leaky_approach()  : ortalama, split'ten ÖNCE tüm veri üzerinden hesaplanır
  ✅ correct_approach(): ortalama, split'ten SONRA sadece train üzerinden hesaplanır

Yüksek kardinaliteli (çok kategorili, kategori başına az örnekli) alanlarda
bu sızıntı ÇOK daha çarpıcıdır — çünkü az örnekli bir kategorinin "ortalaması",
neredeyse o kategorideki tek tük satırın kendi etiketine eşittir.

Kullanım:
    python scripts/leaky_pipeline_demo.py
"""
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score

from common import load_data, NUMERIC_FEATURES, TARGET, C, banner

FEATURES = NUMERIC_FEATURES + ["device_model_encoded"]


def leaky_approach(df):
    """❌ SIZINTILI: 'device_model_encoded', split'ten ÖNCE tüm veri (train+test
    karışık) üzerinden hesaplanan grup ortalamasıdır. Her satırın kodlanmış
    değeri, dolaylı olarak KENDİ etiketinin bilgisini taşır."""
    df = df.copy()
    df["device_model_encoded"] = df.groupby("device_model")[TARGET].transform("mean")

    X, y = df[FEATURES], df[TARGET]
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y)

    model = LogisticRegression(max_iter=1000, class_weight="balanced")
    model.fit(X_train, y_train)
    return roc_auc_score(y_test, model.predict_proba(X_test)[:, 1])


def correct_approach(df):
    """✅ DOĞRU: Önce split, ortalama SADECE train'den öğrenilir, test'e o
    (sabit) ortalamalar uygulanır — test'in kendi etiketi hiç karışmaz."""
    df = df.copy()
    X = df[NUMERIC_FEATURES + ["device_model"]]
    y = df[TARGET]
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y)

    train_means = y_train.groupby(X_train["device_model"]).mean()
    global_mean = y_train.mean()

    X_train = X_train.copy(); X_test = X_test.copy()
    X_train["device_model_encoded"] = X_train["device_model"].map(train_means)
    X_test["device_model_encoded"] = X_test["device_model"].map(train_means).fillna(global_mean)

    model = LogisticRegression(max_iter=1000, class_weight="balanced")
    model.fit(X_train[FEATURES], y_train)
    return roc_auc_score(y_test, model.predict_proba(X_test[FEATURES])[:, 1])


def naive_baseline(df):
    """Karşılaştırma: device_model hiç kullanılmadan, sadece gerçek sinyaller."""
    X, y = df[NUMERIC_FEATURES], df[TARGET]
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y)
    model = LogisticRegression(max_iter=1000, class_weight="balanced")
    model.fit(X_train, y_train)
    return roc_auc_score(y_test, model.predict_proba(X_test)[:, 1])


def main():
    banner("Sızıntılı vs Doğru Pipeline — Yüksek Kardinaliteli Hedef Kodlama",
           "'device_model' churn ile GERÇEKTE ilişkisiz (rastgele atandı)")
    df = load_data()

    baseline = naive_baseline(df)
    leaky = leaky_approach(df)
    correct = correct_approach(df)

    print(f"  {C.DIM}device_model kullanılmadı (baseline)     ROC-AUC = {baseline:.4f}{C.RESET}")
    print(f"  {C.RED}❌ Sızıntılı (TÜM veriye göre kodlama)     ROC-AUC = {leaky:.4f}{C.RESET}")
    print(f"  {C.GREEN}✅ Doğru (SADECE train'e göre kodlama)     ROC-AUC = {correct:.4f}{C.RESET}")

    print(f"\n  Sızıntılı − Doğru fark: {leaky - correct:+.4f}")
    print(f"  Doğru − Baseline fark:  {correct - baseline:+.4f}  "
          f"{C.DIM}(sıfıra yakın olmalı — device_model'in GERÇEK bir sinyali yok){C.RESET}")

    print(f"\n  {C.DIM}Sızıntılı yaklaşım, 150 kategoride kategori başına ortalama ~33\n"
          f"  satırla, her satırın kodlanmış değerine kendi etiketinin bilgisini\n"
          f"  sızdırıyor — model 'device_model_encoded'ı neredeyse hedefin bir\n"
          f"  kopyası gibi kullanmayı öğreniyor. Doğru yaklaşım bu sahte sinyali\n"
          f"  göstermiyor; skoru baseline'a (gerçek sinyallere) yakın kalıyor.{C.RESET}")


if __name__ == "__main__":
    main()
