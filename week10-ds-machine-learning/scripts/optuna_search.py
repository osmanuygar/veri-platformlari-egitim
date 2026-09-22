#!/usr/bin/env python3
"""
Hafta 10 — Alıştırma 4 (bonus): Optuna ile hiperparametre araması

Grid search yerine Bayesian optimizasyon: her deneme bir öncekinden
ders çıkararak bir sonraki denemenin parametrelerini seçer.

Her Optuna denemesi de MLflow'a loglanır — iki aracın birlikte
kullanıldığı tipik bir kurulum.

Kullanım:
    python scripts/optuna_search.py --n-trials 30
"""
import argparse

import mlflow
import optuna
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import roc_auc_score

from common import load_data, make_split, make_pipeline, banner, C, MLFLOW_TRACKING_URI

EXPERIMENT = "week10-churn-prediction"


def objective(trial, X_train, X_test, y_train, y_test):
    params = {
        "n_estimators": trial.suggest_int("n_estimators", 50, 300),
        "max_depth": trial.suggest_int("max_depth", 2, 20),
        "min_samples_split": trial.suggest_int("min_samples_split", 2, 20),
        "min_samples_leaf": trial.suggest_int("min_samples_leaf", 1, 10),
        "max_features": trial.suggest_categorical("max_features", ["sqrt", "log2", None]),
    }

    with mlflow.start_run(run_name=f"optuna_trial_{trial.number}", nested=False):
        mlflow.log_params(params)
        mlflow.set_tag("optimizer", "optuna")

        model = RandomForestClassifier(**params, random_state=42,
                                       class_weight="balanced", n_jobs=-1)
        pipe = make_pipeline(model)
        pipe.fit(X_train, y_train)
        y_proba = pipe.predict_proba(X_test)[:, 1]
        auc = roc_auc_score(y_test, y_proba)

        mlflow.log_metric("roc_auc", auc)

    return auc


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n-trials", type=int, default=30)
    args = ap.parse_args()

    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
    mlflow.set_experiment(EXPERIMENT)

    banner("Optuna Hiperparametre Araması", f"{args.n_trials} deneme, RandomForest")

    df = load_data()
    X_train, X_test, y_train, y_test = make_split(df)

    study = optuna.create_study(direction="maximize",
                                sampler=optuna.samplers.TPESampler(seed=42))
    study.optimize(
        lambda t: objective(t, X_train, X_test, y_train, y_test),
        n_trials=args.n_trials,
        show_progress_bar=False,
    )

    print(f"\n{C.BOLD}En iyi deneme:{C.RESET} #{study.best_trial.number}")
    print(f"  ROC-AUC : {study.best_value:.4f}")
    print(f"  Parametreler:")
    for k, v in study.best_params.items():
        print(f"    {k}: {v}")

    print(f"\n{C.DIM}MLflow UI'da 'optuna_trial_*' isimli {args.n_trials} çalıştırmayı "
          f"'roc_auc' sütununa göre sıralayarak aynı sonucu görsel olarak inceleyebilirsiniz.{C.RESET}\n")


if __name__ == "__main__":
    main()
