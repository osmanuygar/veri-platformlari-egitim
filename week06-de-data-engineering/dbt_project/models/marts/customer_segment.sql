-- Marts katmanı: iş mantığı BURADA yaşar. Staging modellerini birleştirip
-- iş sorusuna cevap veren, doğrudan BI aracına bağlanabilecek bir tablo üretir.

with orders as (
    select * from {{ ref('stg_orders') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

order_totals as (
    select
        o.customer_id,
        o.order_id,
        coalesce(sum(p.amount), 0) as order_amount
    from orders o
    left join payments p on p.order_id = o.order_id
    where o.status not in ('cancelled')   -- iptal edilen sipariş harcama sayılmaz
    group by 1, 2
),

customer_totals as (
    select
        customer_id,
        count(distinct order_id)  as order_count,
        sum(order_amount)         as total_spent
    from order_totals
    group by 1
)

select
    c.customer_id,
    c.full_name,
    c.city,
    coalesce(ct.order_count, 0)  as order_count,
    coalesce(ct.total_spent, 0)  as total_spent,
    case
        when coalesce(ct.total_spent, 0) >= 20000 then 'gold'
        when coalesce(ct.total_spent, 0) >= 8000  then 'silver'
        else 'bronze'
    end as segment
from customers c
left join customer_totals ct on ct.customer_id = c.customer_id
