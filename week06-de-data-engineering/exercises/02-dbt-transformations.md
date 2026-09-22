# Alıştırma 2: dbt — Staging'den Marts'a

**Süre:** ~35 dakika · **Dosyalar:** `dbt_project/models/`

---

## 2.1 Lineage'ı okuyun

```bash
cd dbt_project
export DBT_PROFILES_DIR=./profiles
dbt docs generate && dbt docs serve --port 8091
```

Tarayıcıda **Graph** sekmesine gidin.

**Görev:** `customer_segment` modelinden geriye doğru tıklayarak hangi
kaynak tablolara kadar ulaştığını çizin (elle, kağıda ya da metinle).

**Soru:** `stg_customers`, `stg_orders`, `stg_payments` üçü de birer **view**.
`customer_segment` bir **table**. Bu materialization farkı sorgu performansını
nasıl etkiler? Her sorguda staging modellerini yeniden hesaplamanın maliyeti
ne zaman kabul edilebilir, ne zaman değildir?

---

## 2.2 Yeni bir staging modeli ekleyin

`raw.raw_customers` tablosunda olmayan ama ekleyeceğiniz bir alan üzerinden
gidelim: müşterinin kayıt olduğu **yılı** ayrı bir sütun yapın.

**Görev:** `models/staging/stg_customers.sql`'e `extract(year from created_at) as signup_year`
satırını ekleyin, `dbt run --select stg_customers` çalıştırın.

```bash
dbt run --select stg_customers
```

**Soru:** Sadece `stg_customers`'ı çalıştırdınız. `customer_segment` (ona bağımlı)
güncellendi mi? Güncel olmasını isteseydiniz hangi komutu çalıştırırdınız?
(İpucu: `+` operatörü)

---

## 2.3 Yeni bir mart modeli yazın

**Görev:** `models/marts/city_leaderboard.sql` adında yeni bir model yazın:
her şehrin toplam cirosunu ve müşteri sayısını hesaplasın, ciroya göre sıralasın.

```sql
-- models/marts/city_leaderboard.sql
select
    c.city,
    count(distinct c.customer_id) as customer_count,
    sum(c.total_spent) as city_revenue
from {{ ref('customer_segment') }} c
group by c.city
order by city_revenue desc
```

```bash
dbt run --select city_leaderboard
```

**Soru:** Bu modelin `customer_segment`'e bağımlı olduğunu dbt'ye NASIL
söylediniz? Eğer `{{ ref('customer_segment') }}` yerine düz `from analytics.customer_segment`
yazsaydınız ne kaybederdiniz?

---

## 2.4 Bir testi bilerek kırın

`models/marts/schema.yml`'de `segment` sütununun `accepted_values` testini görün.

**Görev:** `models/marts/customer_segment.sql`'de segment eşik değerlerinden
birini yanlışlıkla `'altin'` (Türkçe, testte tanımlı değil) yapın:

```sql
when coalesce(ct.total_spent, 0) >= 20000 then 'altin'  -- kasıtlı hata
```

```bash
dbt run --select customer_segment
dbt test --select customer_segment
```

**Soru:** Test hatası tam olarak ne söylüyor? Bu testi **CI/CD pipeline'ına**
koysaydınız (her PR'da `dbt test` çalışsaydı), bu hata production'a gitmeden
mi yakalanırdı?

> Bitince `'gold'`a geri alın ve tekrar `dbt run`.

---

## 2.5 Incremental modeli gözlemleyin

```bash
dbt run --select daily_sales_summary --full-refresh
# Postgres'te satır sayısını görün
docker exec week06_postgres psql -U de_user -d de_db \
  -c "SELECT count(*) FROM analytics.daily_sales_summary;"

# Yeni bir sipariş ekleyin (bugünün tarihiyle)
docker exec week06_postgres psql -U de_user -d de_db -c "
  INSERT INTO raw.raw_orders (id, customer_id, order_date, status)
  VALUES (999, 1, current_date, 'completed');
  INSERT INTO raw.raw_payments (id, order_id, payment_method, amount)
  VALUES (999, 999, 'credit_card', 5000);
"

dbt run --select daily_sales_summary    # --full-refresh OLMADAN
```

**Soru:** `dbt run` loglarında kaç satırın işlendiğini görüyorsunuz —
tüm tablo mu, yoksa sadece bugünün satırı mı? `is_incremental()` bloğu
bunu nasıl sağlıyor?

---

## ✅ Ne öğrendik

- `ref()` bağımlılık grafiğini otomatik kurar; `dbt run --select +model` ile
  yukarı akışı, `model+` ile aşağı akışı birlikte çalıştırabilirsiniz.
- Staging = **view** (ucuz, hep taze), marts = **table** (sorgulanacak, hazır).
- Testler CI'da çalıştırıldığında hatalı iş mantığı production'a **gitmeden** yakalanır.
- Incremental modeller `is_incremental()` ile sadece yeni veriyi işler — büyük
  tablolarda saatleri dakikalara indirir.

📎 [Çözüm](./solutions/02-dbt-transformations.md)
