-- Week 5 - Window Functions Solutions

-- ALIŞTIRMA 1: ROW_NUMBER
SELECT
    product_name,
    category_id,
    price,
    ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY price DESC) as row_num
FROM products
ORDER BY category_id, row_num;

-- ALIŞTIRMA 2: RANK vs DENSE_RANK
SELECT
    product_name,
    price,
    RANK() OVER (ORDER BY price DESC) as rank,
    DENSE_RANK() OVER (ORDER BY price DESC) as dense_rank
FROM products
ORDER BY price DESC;

-- ALIŞTIRMA 3: Top N per Group
WITH ranked_products AS (
    SELECT
        product_name,
        category_id,
        price,
        RANK() OVER (PARTITION BY category_id ORDER BY price DESC) as price_rank
    FROM products
)
SELECT * FROM ranked_products
WHERE price_rank <= 3
ORDER BY category_id, price_rank;

-- ALIŞTIRMA 4: Running Total
SELECT
    customer_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date
    ) as running_total
FROM orders
ORDER BY customer_id, order_date;

-- ALIŞTIRMA 5: Moving Average
SELECT
    order_date,
    COUNT(*) as daily_orders,
    AVG(COUNT(*)) OVER (
        ORDER BY order_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_7days
FROM orders
GROUP BY order_date
ORDER BY order_date;

-- ALIŞTIRMA 6: LEAD ve LAG
SELECT
    order_id,
    customer_id,
    order_date,
    LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) as previous_order,
    LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) as next_order
FROM orders
ORDER BY customer_id, order_date;

-- ALIŞTIRMA 7: FIRST_VALUE ve LAST_VALUE
SELECT DISTINCT
    category_id,
    FIRST_VALUE(product_name) OVER (
        PARTITION BY category_id
        ORDER BY created_at
    ) as first_product,
    LAST_VALUE(product_name) OVER (
        PARTITION BY category_id
        ORDER BY created_at
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as last_product
FROM products
ORDER BY category_id;

-- ALIŞTIRMA 8: PERCENT_RANK
SELECT
    product_name,
    price,
    PERCENT_RANK() OVER (ORDER BY price) as price_percentile,
    ROUND(PERCENT_RANK() OVER (ORDER BY price) * 100, 2) as percentile_pct
FROM products
ORDER BY price;

-- ALIŞTIRMA 9: NTILE
SELECT
    customer_id,
    first_name || ' ' || last_name as customer_name,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) as quartile
FROM (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COALESCE(SUM(o.total_amount), 0) as total_spent
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
) customer_totals
ORDER BY total_spent DESC;

-- ALIŞTIRMA 10: Complex Window
WITH customer_stats AS (
    SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name as customer_name,
        c.customer_segment,
        COUNT(o.order_id) as total_orders,
        COALESCE(SUM(o.total_amount), 0) as total_spent,
        COALESCE(AVG(o.total_amount), 0) as avg_order_value
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.customer_segment
)
SELECT
    customer_name,
    customer_segment,
    total_orders,
    ROUND(total_spent, 2) as total_spent,
    ROUND(avg_order_value, 2) as avg_order_value,
    RANK() OVER (PARTITION BY customer_segment ORDER BY total_spent DESC) as segment_rank
FROM customer_stats
ORDER BY customer_segment, segment_rank;