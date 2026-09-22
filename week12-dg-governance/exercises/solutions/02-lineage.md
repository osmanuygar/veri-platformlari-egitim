# ✅ Çözüm 2: Marquez ile Soy Ağacı

## 2.1-2.2 Etki analizi

`transform_customer_marts` job'una tıklandığında, giriş dataset'leri
(`raw.customers`, `raw.orders`) ve çıkış dataset'i (`marts.customers_masked`)
grafikte bağlı olarak görünür.

`raw.customers`'ın `tckn` sütununu değiştirmenin etkisi: `transform_customer_marts`
job'u (onu okuyan) ve dolayısıyla `marts.customers_masked` (ondan üretilen)
ve zincirleme olarak `export_to_bi`/`bi.customer_export` etkilenir.

Lineage grafiği olmadan bu soruyu cevaplamak, kod tabanında `grep -r tckn`
yapıp her sonucu elle takip etmeyi, muhtemelen birden fazla ekibin
kodlarını (Airflow DAG'ları, dbt modelleri, ad-hoc scriptler) taramayı
gerektirirdi — büyük bir organizasyonda bu **günler** sürebilir ve
kolayca bir kullanım yeri **kaçırılabilir**. Lineage grafiği bu süreyi
**dakikalara** indirir ve "unutulan bir tüketici" riskini azaltır.

## 2.3 Başarısız çalıştırma

`--fail-transform` ile çalıştırıldığında, script `export_to_bi` job'unu
**hiç çağırmaz** — kodda bu, `if args.fail_transform: ... else: run_job(...)`
dallanmasıyla sağlanır (script, Python seviyesinde "sonraki adımı atla" kararını verir).

Gerçek bir Airflow DAG'ında bu davranış **otomatiktir**: bir task
`FAILED` olduğunda, ona bağımlı (`>>` ile bağlı) downstream task'lar
varsayılan olarak `upstream_failed` durumuna geçer ve hiç çalıştırılmaz
(hafta 6, Alıştırma 1.2'de gördüğümüz davranışın ta kendisi).

## 2.4 Kök neden analizi

Marquez olmadan: `bi.customer_export`'u kimin/hangi kodun ürettiğini bulmak
için önce ilgili ekibe sormanız, sonra o ekibin pipeline kodunu okumanız,
sonra o pipeline'ın hangi tablolardan beslendiğini SQL'i okuyarak
çıkarmanız gerekirdi — birden fazla ekip arası iletişim ve kod okuma
turu gerektirir.

Marquez ile: `bi.customer_export` dataset sayfasından **tek tıkla**
upstream'e gidip `export_to_bi` → `marts.customers_masked` →
`transform_customer_marts` → `raw.customers`/`raw.orders` zincirini
görsel olarak takip edersiniz — kimseye sormadan, kod okumadan.

## 2.5 REST API kullanımı

`latestRun` alanı, bir job'un en son çalıştırmasının durumunu
(`COMPLETED`/`FAILED`/`RUNNING`) ve zamanını taşır. Bu, bir izleme
aracında (ya da basit bir cron script'inde) şu kontrolü otomatikleştirmek
için kullanılabilir: *"Tüm kritik job'ların `latestRun.state`'i son 24
saat içinde `COMPLETED` mi?"* — değilse bir Slack/e-posta alarmı tetiklenir.
Bu, hafta 6'daki Airflow SLA kavramının, pipeline'ın **kendisinden bağımsız**
bir izleme katmanındaki karşılığıdır.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Etki analizi | Lineage olmadan kod taraması, lineage ile tek tıkla |
| Başarısız job | Downstream job'lar otomatik atlanır (Airflow ile aynı ilke) |
| Kök neden analizi | Upstream'e geriye doğru izleme, kod okumadan |
| REST API | İzleme/alarm otomasyonunun temeli |

**[← Alıştırma 2](../02-lineage.md)**
