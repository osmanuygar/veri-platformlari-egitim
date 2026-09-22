# ✅ Çözüm 1: Airflow DAG ve Backfill

## 1.1 Sıra ve veri bağımlılığı

Sıra, `n >> dbt_deps >> dbt_run >> dbt_test >> publish_summary(n)` satırındaki
`>>` operatörleriyle belirlenir — bu **sıra bağımlılığıdır** (task A bitmeden B başlamaz).

`publish_summary(n)` ise ayrıca **veri bağımlılığı** taşır: `extract_new_orders`'ın
dönüş değeri (`n`), Airflow'un XCom mekanizmasıyla otomatik olarak
`publish_summary`'ye parametre olarak geçirilir. TaskFlow API (`@task` dekoratörü)
bunu sizin için XCom push/pull koduna çevirir.

**İkisi birliktedir**: `n >> dbt_deps` görünüşte tuhaftır (n'in dbt_deps ile veri
ilişkisi yok) ama Airflow'da bir task'ı `>>` zincirine sokmak için değişkenini
kullanmak yeterlidir — burada asıl amaç `extract_new_orders`'ın **en başta**
çalışmasını garanti etmektir.

---

## 1.2 Kırık model

Hata: `Compilation Error: Model 'nonexistent_model' not found`. `dbt_run` task'ı
**FAILED** olur.

**Tekrar tetiklerseniz `dbt_test` çalışmaz.** Airflow varsayılan olarak bir task
başarısız olduğunda, ona bağımlı (downstream) task'ları **çalıştırmaz** —
`upstream_failed` durumuna geçerler. Bu, bozuk veriyle test yapıp yanlış bir
"başarılı" sinyali vermemek için kasıtlı bir güvenlik davranışıdır.

---

## 1.3 Retry

Sıra: `queued → running → FAILED → up_for_retry → (2 dk bekle) → queued → running → FAILED`

`retries=1` ile task **toplam 2 kez** denenir: ilk deneme + 1 retry. UI'da bunu
Task Instance detayında "Try Number: 1 of 2" olarak görürsünüz.

---

## 1.4 Backfill

`@daily` planlı ve `start_date=2026-01-01` olan bir DAG için ilk backfill
çalıştırması:

| Çalıştırma | data_interval_start | data_interval_end |
|---|---|---|
| 1 | 2026-01-01 | 2026-01-02 |
| 2 | 2026-01-02 | 2026-01-03 |
| 3 | 2026-01-03 | 2026-01-04 |
| 4 | 2026-01-04 | 2026-01-05 |
| 5 | 2026-01-05 | 2026-01-06 |

**İlk çalıştırma 1 Ocak'ın verisini işler** (`data_interval_start=2026-01-01`,
`data_interval_end=2026-01-02`), ama **fiilen 2 Ocak'ta tetiklenir** — çünkü
Airflow bir günlük interval'in ancak o gün TAMAMLANDIKTAN sonra "o gün artık
kesinleşti, işleyebiliriz" der.

Bu, eski `execution_date` teriminin en çok kafa karıştıran yanıdır: `execution_date`
aslında **interval'in başlangıcı**dır, DAG'ın çalıştığı an değil. Airflow 2.2+
bu yüzden `data_interval_start`/`data_interval_end` isimlerini tercih eder.

---

## 1.5 catchup=True vs False

- **`week06_elt_pipeline` (catchup=False):** Unpause edildiğinde sadece **en
  güncel** interval için bir çalıştırma tetikler; geçmiş günler atlanır.
- **`week06_backfill_demo` (catchup=True, start_date 2026-01-01):** Unpause
  edildiğinde `start_date`'ten bugüne kadar **her gün için ayrı bir çalıştırma**
  tetikler — start_date ne kadar eskiyse o kadar çok çalıştırma.

`elt_pipeline`'da `False` seçtik çünkü dbt modelleri **kümülatif** çalışır —
her `dbt run`, tablonun GÜNCEL halini hesaplar. "1 Ocak'ın halini", "2 Ocak'ın
halini" ayrı ayrı yeniden hesaplamanın hiçbir anlamı yok; sadece gereksiz
hesaplama maliyeti ve dbt Cloud/warehouse faturası demektir.

Buna karşılık `backfill_demo`'daki gibi **gerçekten günlük, birbirinden bağımsız**
bir iş (örn. "o günün log dosyasını işle") için `catchup=True` doğru araçtır.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| `>>` | Sıra bağımlılığı |
| Fonksiyon parametresi (TaskFlow) | Veri bağımlılığı (XCom) |
| Task başarısız | Downstream task'lar `upstream_failed` olur, çalışmaz |
| `retries=N` | Toplam N+1 deneme |
| `data_interval_start/end` | "Hangi veriyi işliyor", çalışma ANI değil |
| `catchup` | Kümülatif işlerde `False`, gerçekten günlük işlerde `True` |

**[← Alıştırma 1](../01-airflow-dag.md)**
