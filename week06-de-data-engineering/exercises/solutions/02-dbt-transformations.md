# ✅ Çözüm 2: dbt — Staging'den Marts'a

## 2.1 Materialization ve maliyet

`stg_*` modelleri **view**: sorgulandıkları anda SQL'leri çalıştırılır. Her
`SELECT * FROM stg_customers` çağrısı, arkada `raw.raw_customers`'ı yeniden okur.

`customer_segment` bir **table**: `dbt run` sırasında bir kez hesaplanır ve
diske yazılır; sonraki her sorgu hazır tabloyu okur.

**Maliyet dengesi:**
- View'lar ucuzdur (disk harcamaz) ama **her sorguda yeniden hesaplanır**.
  Staging'de sorun değil çünkü genelde sadece yeniden adlandırma — ucuz bir işlem.
- Table'lar sorgulama anında hızlıdır ama `dbt run` sırasında hesaplama maliyeti
  vardır ve veri **bayatlayabilir** (son `dbt run`'dan beri geçen süre kadar).

Kural: Ağır hesaplama (join, agregasyon) içeren ve **sık sorgulanan** modeller
table olmalı. Basit, seyrek sorgulanan ara adımlar view kalabilir.

---

## 2.2 Bağımlı modelleri güncellemek

`dbt run --select stg_customers` sadece o modeli çalıştırır.
`customer_segment` **güncellenmez** — dbt sadece siz ne istediyseniz onu yapar.

Güncel tutmak için:

```bash
dbt run --select stg_customers+      # stg_customers VE ona bağımlı her şey
# ya da
dbt run                               # tüm proje
```

`+` operatörü yön belirtir: `+model` = yukarı akış (bağımlı olduğu her şey),
`model+` = aşağı akış (ona bağımlı her şey), `+model+` = ikisi birden.

---

## 2.3 `ref()` ile bağımlılık bildirmek

`{{ ref('customer_segment') }}` yazarak dbt'ye "bu model, `customer_segment`
modeline **bağımlı**" dediniz. dbt bunu derleme (compile) anında gerçek
tablo adına (`analytics.customer_segment`) çevirir VE bağımlılık grafiğine ekler.

`from analytics.customer_segment` yazsaydınız (düz SQL), sorgu **çalışırdı**
ama şunları kaybederdiniz:

1. **Otomatik sıra:** dbt `city_leaderboard`'ı `customer_segment`'ten önce
   çalıştırabilirdi — hiçbir hata vermeden, sessizce eski/boş veri okurdunuz.
2. **Lineage grafiği:** `dbt docs`'ta bu bağlantı görünmezdi.
3. **Ortam taşınabilirliği:** `analytics` şema adı dev/staging/prod'da
   farklıysa (`target.schema`), kodu elle değiştirmeniz gerekirdi.
4. **`dbt run --select +city_leaderboard`** çalışmazdı — dbt hangi modellerin
   önce çalışması gerektiğini bilemezdi.

---

## 2.4 Testin yakaladığı hata

```
Failure in test accepted_values_customer_segment_segment__gold__silver__bronze
  Got 3 results, configured to fail if != 0
```

Test, `segment` sütununda `'altin'` değerinin şemada tanımlı
(`gold`/`silver`/`bronze`) olmadığını tam olarak söyler.

**Evet, CI'da yakalanırdı.** Bir CI pipeline'ı her PR'da `dbt build`
(seed+run+test) çalıştırırsa, bu hata **merge edilmeden önce** kırmızı
işaretlenir. Bu, veri mühendisliğinde "shift-left" (hatayı olabildiğince
erken yakalama) pratiğinin somut uygulamasıdır — hafta 12'de veri kalitesi
konusunda daha derinlemesine göreceğiz.

---

## 2.5 Incremental davranış

`--full-refresh` OLMADAN çalıştırdığınızda log'da genelde **1 satır**
işlendiğini görürsünüz (sadece bugünün eklenen siparişi).

Bunu sağlayan blok:

```sql
{% if is_incremental() %}
  where order_date >= (select coalesce(max(order_date), '1900-01-01') from {{ this }})
{% endif %}
```

`is_incremental()` yalnızca model **zaten var** ve `--full-refresh` **verilmemişse**
`true` döner. `{{ this }}` mevcut modelin kendi tablosuna (`analytics.daily_sales_summary`)
işaret eder — yani "bu tabloda zaten olan en son günden itibaren" filtrelenir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| view vs table | view = ucuz+taze, table = hızlı sorgu+bayatlayabilir |
| `dbt run --select model` | Sadece o modeli çalıştırır, bağımlıları GÜNCELLEMEZ |
| `+model` / `model+` | Yukarı / aşağı akışı dahil et |
| `ref()` | Bağımlılık grafiği + ortam taşınabilirliği + lineage |
| Şema testi | CI'da çalıştırılırsa hatayı production'dan ÖNCE yakalar |
| `is_incremental()` | Sadece yeni veriyi işlemenin anahtarı |

**[← Alıştırma 2](../02-dbt-transformations.md)**
