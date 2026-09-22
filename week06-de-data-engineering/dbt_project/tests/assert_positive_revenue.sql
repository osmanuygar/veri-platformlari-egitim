-- Özel (singular) test: dbt, bu sorgu SATIR DÖNDÜRÜRSE testi BAŞARISIZ sayar.
-- "Hiçbir günün cirosu negatif olamaz" kuralını burada ifade ediyoruz.
select order_date, revenue
from {{ ref('daily_sales_summary') }}
where revenue < 0
