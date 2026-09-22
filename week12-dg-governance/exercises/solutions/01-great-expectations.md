# ✅ Çözüm 1: Great Expectations ile Kalite Kontrolü

## 1.1 İlk çalıştırma

Beklenen sonuç: **10 beklentiden 6'sı başarılı, 4'ü başarısız** (%60).
Başarısız olanlar:

- `expect_column_values_to_match_regex` (tckn) — `'123'` formatı geçersiz
- `expect_column_values_to_match_regex` (email) — `'gecersiz-email'` formatı geçersiz
- `expect_column_values_to_not_be_null` (email) — bir satırda email `NULL`
- `expect_column_values_to_be_between` (birth_date) — `2030-01-01` gelecekte

## 1.2 Kök neden

```sql
SELECT * FROM raw.customers WHERE tckn !~ '^[1-9][0-9]{10}$';
-- → Emre Arslan, tckn='123'

SELECT * FROM raw.customers WHERE email IS NULL OR email !~ '^[^@]+@[^@]+\.[^@]+$';
-- → Emre Arslan (gecersiz-email), Elif Doğan (email NULL)

SELECT * FROM raw.customers WHERE birth_date > '2010-01-01';
-- → Elif Doğan, birth_date='2030-01-01'
```

Dikkat: **Emre Arslan tek satırıyla 3 farklı testi birden düşürüyor**
(tckn, email formatı, email null olmasa da format hatası). Bu, veri
kalitesi sorunlarının genelde **kümelendiğini** gösterir — bir kaynaktaki
tek bir bozuk kayıt, birden fazla kontrolü aynı anda tetikleyebilir.

## 1.3 Data Docs

Başarısız bir expectation'a tıkladığınızda: **beklenen kural**, **kaç
satırın** beklentiyi karşılamadığı, ve (örnekleme yapılandırılmışsa)
**hangi örnek değerlerin** sorunlu olduğu gösterilir. Bu, bir mühendisin
SQL yazıp elle araştırmasına gerek kalmadan "neyin, neden bozuk olduğunu"
saniyeler içinde anlamasını sağlar — bu haftanın 1.2 adımını GE'nin
kendisi otomatik yapmış olur.

## 1.4 Yeni beklenti

```python
orders_df = pd.read_sql("SELECT * FROM raw.orders", engine)
validator2 = context.sources.pandas_default.read_dataframe(orders_df)
validator2.expect_column_values_to_be_between("amount", min_value=0)
```

Bu haftaki `orders` verisinde tüm `amount` değerleri pozitif olduğu için
bu test **geçmelidir** — negatif bir tutar, muhtemelen bir iade/iptal
kaydının yanlış işlenmesi anlamına gelirdi.

## 1.5 Kalite kapısı düşüncesi

Genel prensip: **"Durdur"** kategorisi, downstream'e akarsa ciddi iş
hasarı verecek hatalar için (örn. birincil anahtar tekrarı, finansal
tutarlarda mantıksız değerler). **"Uyar ama devam et"** kategorisi,
istatistiksel toleransla kabul edilebilir küçük sapmalar için (örn.
`mostly=0.95` ile zaten tolere edilen eksik telefon numaraları).

Bu haftaki senaryoda: `tckn`/`email` format hataları ve gelecekteki
doğum tarihi muhtemelen **durdurulması gereken** hatalardır (aşağı akışta
KVKK/pazarlama süreçlerini bozabilir); ama küçük oranlı eksik `city`
değerleri (zaten `mostly=0.85` ile tolere ediliyor) **uyarı** seviyesinde kalabilir.

---

## 📌 Özet

| Kavram | Kural |
|---|---|
| Beklenen başarısızlık | Kasıtlı kirli veri, testin doğru çalıştığının kanıtı |
| Kümelenmiş hatalar | Tek bozuk kayıt birden fazla testi düşürebilir |
| Data Docs | Kök neden analizini SQL yazmadan hızlandırır |
| Durdur vs uyar | Hasarın ciddiyetine göre ayrılmalı |

**[← Alıştırma 1](../01-great-expectations.md)**
