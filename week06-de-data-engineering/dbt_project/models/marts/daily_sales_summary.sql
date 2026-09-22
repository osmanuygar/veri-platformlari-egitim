{{
    config(
        materialized='incremental',
        unique_key='order_date'
    )
}}

-- Incremental model: her çalıştırmada TÜM tabloyu değil, sadece yeni günleri
-- işler. Büyük fact tablolarda tam yeniden hesaplama (full refresh) saatler
-- sürebilir; incremental bunu dakikalara indirir.

with orders as (
    select * from {{ ref('stg_orders') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

daily as (
    select
        o.order_date,
        count(distinct o.order_id)                    as order_count,
        sum(p.amount)                                  as revenue,
        count(distinct o.order_id) filter (
            where o.status in ('cancelled', 'returned')
        )                                              as cancelled_or_returned
    from orders o
    left join payments p on p.order_id = o.order_id
    group by 1
)

select * from daily

{% if is_incremental() %}
  -- Sadece bu tabloda henüz olmayan (ya da bugünkü, hâlâ değişebilecek) günleri al
  where order_date >= (select coalesce(max(order_date), '1900-01-01') from {{ this }})
{% endif %}
