# Alıştırma 1: Airflow DAG ve Backfill

**Süre:** ~30 dakika · **Dosyalar:** `airflow/dags/elt_pipeline_dag.py`, `airflow/dags/backfill_demo_dag.py`

---

## 1.1 DAG'ı tetikleyin

http://localhost:8090 → admin/admin → **week06_elt_pipeline** → sağ üstten ▶ (Trigger)

**Görev:** Graph görünümünde task'ların sırasıyla yeşile döndüğünü izleyin.

**Soru:** `dbt_deps → dbt_run → dbt_test → publish_summary` sırası koddaki hangi
satırla (`>>`) belirleniyor? `extract_new_orders`'ın sonucu (`n`) neden
`publish_summary(n)`'e parametre olarak veriliyor — bu ikisi arasında bir
**veri bağımlılığı** mı yoksa sadece **sıra bağımlılığı** mı var?

---

## 1.2 Bir task'ı bilerek kırın

`airflow/dags/elt_pipeline_dag.py` içinde `dbt_run` satırındaki `dbt run`'ı
`dbt run --select nonexistent_model` yapın (bir kopyasını alıp deneyin, ya da
container içinde geçici olarak).

```bash
docker exec week06_airflow bash -lc \
  "cd /opt/dbt_project && DBT_PROFILES_DIR=./profiles dbt run --select nonexistent_model"
```

**Soru:** Hata mesajı ne diyor? DAG'ı tekrar tetikleseydiniz `dbt_test` task'ı
çalışır mıydı? Neden?

---

## 1.3 Yeniden deneme (retry)

DAG'ın `default_args`'ına bakın: `"retries": 1, "retry_delay": ... minutes=2`.

**Görev:** `extract_new_orders` task'ını Postgres container'ını geçici olarak
durdurarak başarısız kılın:

```bash
docker compose stop postgres
# DAG'ı tetikleyin, task'ın FAILED → UP_FOR_RETRY → tekrar FAILED olduğunu izleyin
docker compose start postgres
```

**Soru:** Airflow UI'da task'ın rengi hangi aşamalardan geçti? `retries=1` ile
task en fazla kaç kez denenir (ilk deneme dahil mi hariç mi)?

---

## 1.4 Backfill

```bash
docker exec week06_airflow airflow dags backfill \
  week06_backfill_demo --start-date 2026-01-01 --end-date 2026-01-05
```

**Görev:** Log çıktısında her gün için basılan `data_interval_start/end`
değerlerini not edin.

| Çalıştırma | data_interval_start | data_interval_end |
|---|---|---|
| 1 | | |
| 2 | | |
| ... | | |

**Soru:** `start_date=2026-01-01` ve DAG `@daily` planlı. İlk backfill
çalıştırması **hangi günün** verisini işliyor — 1 Ocak'ın kendisini mi,
yoksa 31 Aralık'ın mı? (İpucu: Airflow'da bir çalıştırma, "interval'in
SONUNDA" tetiklenir — kafa karıştıran ama kasıtlı bir tasarım.)

---

## 1.5 `catchup=True` vs `False`

`elt_pipeline_dag.py`'de `catchup=False`, `backfill_demo_dag.py`'de `catchup=True`.

**Soru:** Elle backfill yapmadan, sadece DAG'ı **unpause** ederseniz:
- `week06_elt_pipeline` (catchup=False) kaç çalıştırma tetikler?
- `week06_backfill_demo` (catchup=True, start_date epeyce geride) kaç çalıştırma tetikler?

Bu ayrımı neden `elt_pipeline`'da `False` seçtik? (İpucu: dbt'yi "geçmişteki
her gün için" tekrar tekrar çalıştırmanın maliyeti nedir?)

---

## ✅ Ne öğrendik

- Task bağımlılığı (`>>`) ile veri bağımlılığı (fonksiyon parametresi, XCom)
  farklı şeylerdir; ikisi birlikte kullanılabilir.
- Bir task başarısız olursa **ondan sonraki** task'lar çalışmaz — pipeline güvenli şekilde durur.
- `retries` ile geçici hatalar (ağ, kaynak henüz hazır değil) otomatik telafi edilir.
- **"Execution date" aslında interval'in BAŞLANGICIdır**, çalıştırma interval'in SONUNDA tetiklenir.
- `catchup=True`, geçmişi "yakalamak" istediğiniz DAG'larda; günlük pipeline'larda genelde `False` istersiniz.

📎 [Çözüm](./solutions/01-airflow-dag.md)
