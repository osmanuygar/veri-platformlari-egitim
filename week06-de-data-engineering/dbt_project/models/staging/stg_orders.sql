select
    id          as order_id,
    customer_id,
    order_date,
    status
from {{ source('raw', 'raw_orders') }}
