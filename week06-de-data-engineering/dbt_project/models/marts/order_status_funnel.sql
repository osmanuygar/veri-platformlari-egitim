select
    status,
    count(*)                                            as order_count,
    round(100.0 * count(*) / sum(count(*)) over (), 1)  as pct_of_total
from {{ ref('stg_orders') }}
group by status
order by order_count desc
