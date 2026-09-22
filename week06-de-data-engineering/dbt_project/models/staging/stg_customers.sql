-- Staging katmanı kuralı: kaynağa BİRE BİR karşılık gelir, sadece
-- yeniden adlandırma ve tip dönüşümü yapılır. İş mantığı YOK.

select
    id          as customer_id,
    first_name,
    last_name,
    first_name || ' ' || last_name as full_name,
    email,
    city,
    created_at::date as created_at
from {{ source('raw', 'raw_customers') }}
