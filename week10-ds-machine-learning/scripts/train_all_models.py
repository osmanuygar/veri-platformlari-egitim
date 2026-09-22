#!/usr/bin/env python3
"""
Hafta 10 — Alıştırma 4: 4 algoritmayı eğitip MLflow'a kaydeder

✨ Bu haftanın "wow" anı: script bittiğinde MLflow UI'da (http://localhost:5500)
20'ye yakın deneme (4 model × birkaç hiperparametre varyasyonu) yan yana
görünür — hangi parametreyle neyi denediğinizi bir daha asla unutmazsınız.

Kullanım:
    python scripts/generate_churn_dataset.py    # önce veri üret
    python scripts/train_all_models.py
"""
import os
import time

import mlflow
import mlflow.sklearn
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.metrics import (accuracy_score, precision_score, recall_score,
                              f1_score, roc_auc_score, average_precision_score,
                              confusion_matrix)

from common import load_data, make_split, make_pipeline, banner, C, MLFLOW_TRACKING_URI

EXPERIMENT = "week10-churn-prediction"


def evaluate(y_true, y_pred, y_proba):
    return {
        "accuracy":  accuracy_score(y_true, y_pred),
        "precision": precision_score(y_true, y_pred, zero_division=0),
        "recall":    recall_score(y_true, y_pred, zero_division=0),
        "f1":        f1_score(y_true, y_pred, zero_division=0),
        "roc_auc":   roc_auc_score(y_true, y_proba),
        "pr_auc":    average_precision_score(y_true, y_proba),
    }


def run_one(name, model, params, X_train, X_test, y_train, y_test):
    with mlflow.start_run(run_name=name):
        mlflow.log_params(params)
        mlflow.log_param("model_type", type(model).__name__)

        pipe = make_pipeline(model)
        t0 = time.time()
        pipe.fit(X_train, y_train)
        train_time = time.time() - t0

        y_pred = pipe.predict(X_test)
        y_proba = pipe.predict_proba(X_test)[:, 1]
        metrics = evaluate(y_test, y_pred, y_proba)
        metrics["train_seconds"] = train_time

        mlflow.log_metrics(metrics)

        cm = confusion_matrix(y_test, y_pred)
        mlflow.log_text(
            f"Confusion Matrix (satır=gerçek, sütun=tahmin)\n"
            f"              tahmin:0   tahmin:1\n"
            f"gerçek:0      {cm[0,0]:>8}   {cm[0,1]:>8}\n"
            f"gerçek:1      {cm[1,0]:>8}   {cm[1,1]:>8}\n",
            "confusion_matrix.txt",
        )

        mlflow.sklearn.log_model(pipe, "model")

        print(f"  {name:<28} acc={metrics['accuracy']:.3f}  "
              f"f1={metrics['f1']:.3f}  roc_auc={metrics['roc_auc']:.3f}  "
              f"pr_auc={metrics['pr_auc']:.3f}  ({train_time:.2f}sn)")
        return metrics


def main():
    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
    mlflow.set_experiment(EXPERIMENT)

    banner("4 Model × Hiperparametre Varyasyonları → MLflow",
           f"tracking: {MLFLOW_TRACKING_URI}  ·  experiment: {EXPERIMENT}")

    df = load_data()
    X_train, X_test, y_train, y_test = make_split(df)
    print(f"{C.DIM}Eğitim: {len(X_train)}  ·  Test: {len(X_test)}  ·  "
          f"Churn oranı (train): %{y_train.mean()*100:.1f}{C.RESET}\n")

    runs = []

    # ── 1. Lojistik Regresyon — birkaç düzenlileştirme gücü ──
    for C_val in [0.01, 0.1, 1.0, 10.0]:
        name = f"logreg_C{C_val}"
        model = LogisticRegression(C=C_val, max_iter=1000, class_weight="balanced")
        m = run_one(name, model, {"C": C_val, "class_weight": "balanced"},
                    X_train, X_test, y_train, y_test)
        runs.append((name, m))

    # ── 2. Karar Ağacı — farklı derinlikler (overfitting demosu) ──
    for depth in [2, 4, 8, None]:
        name = f"tree_depth{depth}"
        model = DecisionTreeClassifier(max_depth=depth, random_state=42, class_weight="balanced")
        m = run_one(name, model, {"max_depth": depth}, X_train, X_test, y_train, y_test)
        runs.append((name, m))

    # ── 3. Random Forest — ağaç sayısı ──
    for n_est in [50, 100, 200]:
        name = f"rf_n{n_est}"
        model = RandomForestClassifier(n_estimators=n_est, random_state=42,
                                       class_weight="balanced", n_jobs=-1)
        m = run_one(name, model, {"n_estimators": n_est}, X_train, X_test, y_train, y_test)
        runs.append((name, m))

    # ── 4. Gradient Boosting — öğrenme oranı ──
    for lr in [0.01, 0.1, 0.3]:
        name = f"gboost_lr{lr}"
        model = GradientBoostingClassifier(learning_rate=lr, n_estimators=100, random_state=42)
        m = run_one(name, model, {"learning_rate": lr}, X_train, X_test, y_train, y_test)
        runs.append((name, m))

    best = max(runs, key=lambda r: r[1]["roc_auc"])
    banner("Sonuç", f"En iyi model (ROC-AUC'a göre): {best[0]}  →  "
                     f"roc_auc={best[1]['roc_auc']:.3f}")
    print(f"MLflow UI: {MLFLOW_TRACKING_URI}  (Experiment: {EXPERIMENT})")
    print(f"Deneme sayısı: {len(runs)}\n")


if __name__ == "__main__":
    main()
