#!/usr/bin/env python3
"""
Hafta 12 — Alıştırma 1: Great Expectations ile veri kalitesi kontrolleri

raw.customers tablosuna 10 beklenti (expectation) uygular. Veri KASITLI
olarak birkaç kalite sorunu içeriyor (bkz. init/02-sample-data.sql) —
bu yüzden bazı testlerin BAŞARISIZ olması BEKLENEN bir sonuçtur.

Kullanım:
    python scripts/ge_validate.py
    open great_expectations/gx/uncommitted/data_docs/local_site/index.html
    # ya da: docker compose up -d ge-docs  →  http://localhost:8099
"""
import sys
from pathlib import Path

import pandas as pd
import great_expectations as gx

from common import PG_URI, C, banner

PROJECT_DIR = Path(__file__).resolve().parent.parent / "great_expectations"


def load_customers() -> pd.DataFrame:
    try:
        import sqlalchemy
        engine = sqlalchemy.create_engine(PG_URI)
        df = pd.read_sql("SELECT * FROM raw.customers", engine)
        df["birth_date"] = pd.to_datetime(df["birth_date"]).astype("datetime64[ns]")
        return df
    except Exception as e:
        print(f"{C.RED}✖ Postgres'e bağlanılamadı: {e}{C.RESET}")
        print(f"{C.DIM}  docker compose up -d postgres  ile başlatıp tekrar deneyin.{C.RESET}")
        sys.exit(1)


def main():
    banner("Great Expectations — raw.customers doğrulaması")

    df = load_customers()
    print(f"{C.DIM}Yüklenen satır: {len(df)}{C.RESET}\n")

    context = gx.get_context(mode="file", project_root_dir=str(PROJECT_DIR))
    validator = context.sources.pandas_default.read_dataframe(df)

    # ── 10 beklenti ─────────────────────────────────────────────
    # 1-2) Şema bütünlüğü
    validator.expect_column_to_exist("id")
    validator.expect_column_values_to_be_unique("id")

    # 3) Zorunlu alan
    validator.expect_column_values_to_not_be_null("full_name")

    # 4) TCKN formatı: 11 hane, ilk hane 0 olamaz (gerçek checksum algoritması
    #    değil, sadece FORMAT kontrolü — eğitim amaçlı basitleştirildi)
    validator.expect_column_values_to_match_regex("tckn", r"^[1-9][0-9]{10}$")

    # 5) E-posta formatı
    validator.expect_column_values_to_match_regex(
        "email", r"^[^@\s]+@[^@\s]+\.[^@\s]+$", mostly=1.0)

    # 6) E-posta zorunlu (bu satırda mostly YOK — tek bir eksik bile testi düşürsün)
    validator.expect_column_values_to_not_be_null("email")

    # 7) Şehir listesi kapalı küme mi (yaygın yazım hatalarını yakalar)
    validator.expect_column_values_to_be_in_set(
        "city",
        ["İstanbul", "Ankara", "İzmir", "Bursa", "Antalya", "Adana",
         "Konya", "Gaziantep", "Trabzon"],
        mostly=0.85,   # bilinen kısıtlı liste dışına biraz tolerans (yeni şehirler)
    )

    # 8) Doğum tarihi mantıklı bir aralıkta mı (gelecekte olamaz!)
    validator.expect_column_values_to_be_between(
        "birth_date",
        min_value=pd.Timestamp("1920-01-01"), max_value=pd.Timestamp("2010-01-01"))

    # 9) income_band kapalı küme
    validator.expect_column_values_to_be_in_set("income_band", ["low", "medium", "high"])

    # 10) consent_marketing true ise consent_date dolu olmalı (iş kuralı)
    #     row_condition ile şarta bağlı bir alt küme üzerinde test çalıştırılır
    validator.expect_column_values_to_not_be_null(
        "consent_date",
        row_condition="consent_marketing == True",
        condition_parser="pandas",
    )

    validator.expectation_suite_name = "customers_quality_suite"
    validator.save_expectation_suite(discard_failed_expectations=False)

    checkpoint = context.add_or_update_checkpoint(
        name="customers_checkpoint", validator=validator,
    )
    result = checkpoint.run()

    # ── Okunabilir özet ────────────────────────────────────────
    run_result = list(result.run_results.values())[0]
    stats = run_result["validation_result"]["statistics"]

    print(f"\n{C.BOLD}Sonuç:{C.RESET} {stats['successful_expectations']}/"
          f"{stats['evaluated_expectations']} beklenti başarılı "
          f"({stats['success_percent']:.0f}%)\n")

    for r in run_result["validation_result"]["results"]:
        exp_type = r["expectation_config"]["expectation_type"]
        col = r["expectation_config"]["kwargs"].get("column", "-")
        ok = r["success"]
        icon = f"{C.GREEN}✔{C.RESET}" if ok else f"{C.RED}✖{C.RESET}"
        detail = ""
        if not ok:
            uc = r["result"].get("unexpected_count")
            if uc is not None:
                detail = f"  {C.DIM}({uc} satır beklentiyi karşılamıyor){C.RESET}"
        print(f"  {icon} {exp_type:<50} [{col}]{detail}")

    context.build_data_docs()
    docs_path = (PROJECT_DIR / "gx" / "uncommitted" / "data_docs" /
                 "local_site" / "index.html")
    print(f"\n{C.BOLD}📊 Data Docs oluşturuldu:{C.RESET} {docs_path}")
    print(f"{C.DIM}   Tarayıcıda açmak için: open {docs_path}{C.RESET}")
    print(f"{C.DIM}   Ya da: docker compose restart ge-docs → http://localhost:8099{C.RESET}\n")

    if stats["success_percent"] < 100:
        print(f"{C.YELLOW}⚠ Bazı testler BAŞARISIZ oldu — bu BEKLENEN bir sonuç.{C.RESET}")
        print(f"{C.DIM}  Veri kasıtlı olarak kalite sorunları içeriyor (bkz. init/02-sample-data.sql).\n"
              f"  Alıştırma 1'in amacı bu sorunları TESPİT etmek.{C.RESET}\n")


if __name__ == "__main__":
    main()
