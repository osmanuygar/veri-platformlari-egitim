#!/usr/bin/env python3
"""
Hafta 12 — Alıştırma 2: Marquez'e OpenLineage olayları gönder

Gerçek bir orkestratör (Airflow, hafta 4/6) her task çalıştığında OpenLineage
formatında START/COMPLETE olayları yayınlar; Marquez bunları dinleyip bir
soy ağacı (lineage graph) inşa eder. Bu script, aynı mekanizmayı ELLE
tetikleyerek 3 adımlı sahte bir pipeline'ın lineage'ını üretir:

    raw.customers ─┐
                    ├──▶ [transform_customer_marts] ──▶ marts.customers_masked
    raw.orders    ─┘
                                                              │
                                                              ▼
                                                      [export_to_bi]
                                                              │
                                                              ▼
                                                    bi.customer_export

Kullanım:
    python scripts/emit_lineage.py
    python scripts/emit_lineage.py --fail-transform   # bir job'u BAŞARISIZ gönder
"""
import argparse
import sys
import uuid
from datetime import datetime, timezone

from common import MARQUEZ_URL, C, banner

try:
    from openlineage.client import OpenLineageClient
    from openlineage.client.run import RunEvent, RunState, Run, Job, Dataset
    from openlineage.client.facet import (
        SqlJobFacet, SchemaDatasetFacet, SchemaField, ErrorMessageRunFacet,
    )
except ImportError:
    print(f"{C.RED}✖ openlineage-python kurulu değil: pip install -r requirements.txt{C.RESET}")
    sys.exit(1)

NAMESPACE = "week12-dg"
PRODUCER = "https://github.com/osmanuygar/veri-platformlari-egitim/week12"


def now():
    return datetime.now(timezone.utc).isoformat()


def ds(name, fields=None):
    facets = {}
    if fields:
        facets["schema"] = SchemaDatasetFacet(
            fields=[SchemaField(name=f, type=t) for f, t in fields]
        )
    return Dataset(namespace=NAMESPACE, name=name, facets=facets)


def run_job(client, job_name, inputs, outputs, sql=None, fail=False):
    """Bir job için START ve COMPLETE (ya da FAIL) olayı gönderir."""
    run_id = str(uuid.uuid4())
    run = Run(runId=run_id)
    job = Job(namespace=NAMESPACE, name=job_name)
    facets = {"sql": SqlJobFacet(query=sql)} if sql else {}

    print(f"  {C.DIM}▶ START{C.RESET}  {job_name}  (run_id={run_id[:8]}…)")
    client.emit(RunEvent(
        eventType=RunState.START, eventTime=now(), run=run,
        job=Job(namespace=NAMESPACE, name=job_name, facets=facets),
        inputs=inputs, outputs=outputs, producer=PRODUCER,
    ))

    import time as _time
    _time.sleep(0.3)  # gerçekçi bir çalışma süresi hissi versin

    if fail:
        print(f"  {C.RED}✖ FAIL{C.RESET}   {job_name}")
        client.emit(RunEvent(
            eventType=RunState.FAIL, eventTime=now(), run=run,
            job=Job(namespace=NAMESPACE, name=job_name),
            inputs=inputs, outputs=outputs, producer=PRODUCER,
        ))
    else:
        print(f"  {C.GREEN}✔ COMPLETE{C.RESET}  {job_name}")
        client.emit(RunEvent(
            eventType=RunState.COMPLETE, eventTime=now(), run=run,
            job=Job(namespace=NAMESPACE, name=job_name),
            inputs=inputs, outputs=outputs, producer=PRODUCER,
        ))
    return run_id


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--fail-transform", action="store_true",
                    help="'transform_customer_marts' job'ını başarısız olarak gönder")
    args = ap.parse_args()

    client = OpenLineageClient(url=MARQUEZ_URL)
    banner("OpenLineage → Marquez", f"namespace={NAMESPACE}  url={MARQUEZ_URL}")

    raw_customers = ds("raw.customers", [("id", "int"), ("tckn", "varchar"),
                                          ("email", "varchar"), ("phone", "varchar")])
    raw_orders = ds("raw.orders", [("id", "int"), ("customer_id", "int"), ("amount", "numeric")])
    masked = ds("marts.customers_masked", [("id", "int"), ("tckn_masked", "varchar"),
                                            ("email_masked", "varchar")])
    export = ds("bi.customer_export", [("id", "int"), ("segment", "varchar")])

    # 1) extract — sadece raw.customers'ı "okuyan" bir job (kaynak sistemden alım simülasyonu)
    run_job(client, "extract_customers", inputs=[], outputs=[raw_customers],
            sql="SELECT * FROM source_system.customers")

    # 2) transform — raw.customers + raw.orders → marts.customers_masked
    run_job(client, "transform_customer_marts", inputs=[raw_customers, raw_orders],
            outputs=[masked],
            sql="SELECT id, mask(tckn), mask(email) FROM raw.customers JOIN raw.orders ...",
            fail=args.fail_transform)

    if args.fail_transform:
        print(f"\n{C.YELLOW}⚠ transform_customer_marts BAŞARISIZ gönderildi — "
              f"export_to_bi ATLANIYOR (gerçek bir pipeline'da da bağımlı job çalışmazdı).{C.RESET}")
    else:
        # 3) export — marts.customers_masked → bi.customer_export (hafta 11'e köprü)
        run_job(client, "export_to_bi", inputs=[masked], outputs=[export],
                sql="SELECT id, segment FROM marts.customers_masked")

    print(f"\n{C.BOLD}Marquez Web'de inceleyin:{C.RESET} http://localhost:3002"
          f"\n  Namespace: {NAMESPACE}"
          f"\n  → 'transform_customer_marts' job'ına tıklayıp giriş/çıkış "
          f"dataset'lerini görün.\n")


if __name__ == "__main__":
    main()
