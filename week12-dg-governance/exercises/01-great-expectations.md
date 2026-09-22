# Alıştırma 1: Great Expectations ile Kalite Kontrolü

**Süre:** ~30 dakika · **Dosya:** `scripts/ge_validate.py`

---

## 1.1 İlk çalıştırma

```bash
python scripts/ge_validate.py
```

**Görev:** Kaç beklenti başarılı, kaç tanesi başarısız oldu? Başarısız
olanların hangi sütunlarla ilgili olduğunu not edin.

---

## 1.2 Başarısızlıkların kök nedenini bulun

```bash
docker exec week12_postgres psql -U dg_user -d dg_db -c "SELECT * FROM raw.customers WHERE tckn !~ '^[1-9][0-9]{10}\$';"
```

**Görev:** Her başarısız beklenti için, hangi satırın/satırların sorumlu
olduğunu SQL ile bulun.

---

## 1.3 Data Docs'u inceleyin

```bash
open great_expectations/gx/uncommitted/data_docs/local_site/index.html
```

**Soru:** Data Docs sayfasında, başarısız bir expectation'a tıkladığınızda
size ne gösteriliyor? Bu, bir veri mühendisinin "neden başarısız oldu"
sorusunu cevaplamasına nasıl yardım ediyor?

---

## 1.4 Yeni bir beklenti ekleyin

**Görev:** `scripts/ge_validate.py`'ye 11. bir beklenti ekleyin:
`orders.amount` sütununun her zaman pozitif olduğunu doğrulayan bir kural
(ipucu: `orders` tablosunu da `pd.read_sql` ile ayrıca yükleyip ikinci bir
validator kurmanız gerekecek).

```python
validator2 = context.sources.pandas_default.read_dataframe(orders_df)
validator2.expect_column_values_to_be_between("amount", min_value=0)
```

---

## 1.5 Kalite kapısı (quality gate) düşüncesi

**Soru:** Bu script'i hafta 6'daki Airflow DAG'ının bir task'ı olarak
hayal edin (`dbt_run`'dan SONRA, `dbt_test`'ten ÖNCE ya da PARALEL).
`checkpoint.run().success` `False` dönerse, pipeline'ın geri kalanının
**durması** mı yoksa sadece **uyarı vermesi** mi daha doğru olur? Hangi
tür hatalar "durdur", hangileri "uyar ama devam et" kategorisine girer?

---

## ✅ Ne öğrendik

- Great Expectations, veri kalitesi kurallarını **kod olarak** (versiyon
  kontrolüne girebilen, test edilebilen) ifade eder.
- Data Docs, her çalıştırmanın kalıcı, paylaşılabilir bir kaydını tutar.
- Kalite kapıları, pipeline'a **entegre edildiğinde** asıl değerini kazanır
  — tek seferlik bir kontrol değil, sürekli bir güvence olmalıdır.

📎 [Çözüm](./solutions/01-great-expectations.md)
