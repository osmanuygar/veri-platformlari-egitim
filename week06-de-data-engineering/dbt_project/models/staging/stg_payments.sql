select
    id       as payment_id,
    order_id,
    payment_method,
    amount / 100.0 as amount   -- kuruştan TL'ye
from {{ source('raw', 'raw_payments') }}
