# Hafta 5: SQL ve İleri SQL ile Veri İşleme

## 📚 İçindekiler

1. [Window Functions (Analitik Fonksiyonlar)](#1-window-functions-analitik-fonksiyonlar)
2. [Common Table Expressions (CTE)](#2-common-table-expressions-cte)
3. [Normalizasyon](#3-normalizasyon)
4. [İndeksleme (Indexing)](#4-indeksleme-indexing)
5. [Query Optimization](#5-query-optimization)
6. [Stored Procedures ve Functions](#6-stored-procedures-ve-functions)
7. [Triggers](#7-triggers)
8. [Partitioning](#8-partitioning)
9. [Alternatifler ve Ekosistem](#-alternatifler-ve-ekosistem)
10. [Pratik Uygulamalar](#9-pratik-uygulamalar)
11. [Alıştırmalar](#10-alıştırmalar)

---

## 1. Window Functions (Analitik Fonksiyonlar)

### 1.1 Tanım

**Window Functions:** Satırlar üzerinde hesaplamalar yapar ancak GROUP BY gibi satırları birleştirmez.

```sql
-- GROUP BY: Satırları gruplar
SELECT department, AVG(salary)
FROM employees
GROUP BY department;  -- Her departman için 1 satır

-- WINDOW: Her satır korunur
SELECT 
    name,
    department,
    salary,
    AVG(salary) OVER (PARTITION BY department) as dept_avg_salary
FROM employees;  -- Tüm satırlar korunur
```

### 1.2 Temel Syntax

```sql
function_name([expression]) OVER (
    [PARTITION BY partition_expression]
    [ORDER BY sort_expression [ASC | DESC]]
    [ROWS | RANGE frame_clause]
)
```

### 1.3 Ranking Functions

#### ROW_NUMBER()
Her satıra benzersiz sıra numarası verir.

```sql
-- Her departmandaki çalışanları maaşa göre sırala
SELECT 
    name,
    department,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY department 
        ORDER BY salary DESC
    ) as rank_in_dept
FROM employees;

-- En yüksek maaşlı 3 kişiyi her departmandan seç
WITH ranked_employees AS (
    SELECT 
        name,
        department,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as rn
    FROM employees
)
SELECT * FROM ranked_employees WHERE rn <= 3;
```

#### RANK() ve DENSE_RANK()
```sql
SELECT 
    name,
    score,
    -- RANK: Aynı değerler aynı rank, sonraki atlanır
    RANK() OVER (ORDER BY score DESC) as rank,
    
    -- DENSE_RANK: Aynı değerler aynı rank, sonraki atlanmaz
    DENSE_RANK() OVER (ORDER BY score DESC) as dense_rank,
    
    -- ROW_NUMBER: Her satır benzersiz
    ROW_NUMBER() OVER (ORDER BY score DESC) as row_num
FROM exam_scores;

/*
Örnek Sonuç:
name    score   rank   dense_rank   row_num
-----   -----   ----   ----------   -------
Ali     95      1      1            1
Ayşe    95      1      1            2
Mehmet  90      3      2            3
Fatma   85      4      3            4
*/
```

#### NTILE()
Satırları eşit gruplara böler.

```sql
-- Müşterileri 4 gruba böl (quartile)
SELECT 
    customer_id,
    total_purchases,
    NTILE(4) OVER (ORDER BY total_purchases DESC) as quartile
FROM customers;

-- Her quartile'daki ortalama
WITH customer_quartiles AS (
    SELECT 
        customer_id,
        total_purchases,
        NTILE(4) OVER (ORDER BY total_purchases DESC) as quartile
    FROM customers
)
SELECT 
    quartile,
    COUNT(*) as customer_count,
    AVG(total_purchases) as avg_purchases,
    MIN(total_purchases) as min_purchases,
    MAX(total_purchases) as max_purchases
FROM customer_quartiles
GROUP BY quartile
ORDER BY quartile;
```

### 1.4 Aggregate Window Functions

```sql
SELECT 
    order_date,
    daily_revenue,
    
    -- Kümülatif toplam (Running Total)
    SUM(daily_revenue) OVER (ORDER BY order_date) as cumulative_revenue,
    
    -- Hareketli ortalama (7 günlük)
    AVG(daily_revenue) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) as moving_avg_7day,
    
    -- Önceki günle karşılaştırma
    LAG(daily_revenue) OVER (ORDER BY order_date) as prev_day_revenue,
    daily_revenue - LAG(daily_revenue) OVER (ORDER BY order_date) as day_over_day_change,
    
    -- Departman içinde oran
    daily_revenue / SUM(daily_revenue) OVER () * 100 as pct_of_total
FROM daily_sales
ORDER BY order_date;
```

### 1.5 LEAD() ve LAG()

```sql
-- Önceki ve sonraki değerlere erişim
SELECT 
    product_id,
    sale_date,
    quantity,
    
    -- Önceki satış
    LAG(quantity, 1) OVER (
        PARTITION BY product_id 
        ORDER BY sale_date
    ) as prev_quantity,
    
    -- Sonraki satış
    LEAD(quantity, 1) OVER (
        PARTITION BY product_id 
        ORDER BY sale_date
    ) as next_quantity,
    
    -- Değişim oranı
    ROUND(
        (quantity - LAG(quantity) OVER (PARTITION BY product_id ORDER BY sale_date)) 
        / LAG(quantity) OVER (PARTITION BY product_id ORDER BY sale_date) * 100, 
        2
    ) as pct_change
FROM product_sales;
```

### 1.6 Frame Clause

```sql
-- ROWS: Fiziksel satır sayısı
SELECT 
    order_date,
    revenue,
    AVG(revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING  -- Önceki 2 + mevcut + sonraki 2
    ) as moving_avg_5
FROM daily_orders;

-- RANGE: Değer aralığı
SELECT 
    order_date,
    revenue,
    SUM(revenue) OVER (
        ORDER BY order_date
        RANGE BETWEEN INTERVAL '7 days' PRECEDING AND CURRENT ROW
    ) as last_7_days_revenue
FROM daily_orders;

-- Frame şartları:
-- UNBOUNDED PRECEDING: En baştan
-- UNBOUNDED FOLLOWING: En sona
-- CURRENT ROW: Mevcut satır
-- N PRECEDING: N satır önce
-- N FOLLOWING: N satır sonra
```

### 1.7 Gerçek Dünya Örneği: Satış Analizi

```sql
WITH sales_analytics AS (
    SELECT 
        sale_date,
        product_id,
        quantity,
        revenue,
        
        -- Ranking
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY revenue DESC
        ) as best_day_rank,
        
        -- Running totals
        SUM(revenue) OVER (
            PARTITION BY product_id 
            ORDER BY sale_date
        ) as cumulative_revenue,
        
        -- Moving averages
        AVG(revenue) OVER (
            PARTITION BY product_id 
            ORDER BY sale_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) as ma_7day,
        
        AVG(revenue) OVER (
            PARTITION BY product_id 
            ORDER BY sale_date 
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) as ma_30day,
        
        -- Growth metrics
        revenue - LAG(revenue) OVER (
            PARTITION BY product_id 
            ORDER BY sale_date
        ) as day_over_day_change,
        
        ROUND(
            (revenue - LAG(revenue, 7) OVER (PARTITION BY product_id ORDER BY sale_date))
            / NULLIF(LAG(revenue, 7) OVER (PARTITION BY product_id ORDER BY sale_date), 0)
            * 100, 
            2
        ) as week_over_week_growth_pct
        
    FROM product_sales
)
SELECT * FROM sales_analytics
WHERE sale_date >= CURRENT_DATE - INTERVAL '90 days'
ORDER BY product_id, sale_date;
```

---

## 2. Common Table Expressions (CTE)

### 2.1 Basit CTE

```sql
-- WITH clause ile temporary result set
WITH high_value_customers AS (
    SELECT 
        customer_id,
        SUM(order_total) as total_spent
    FROM orders
    GROUP BY customer_id
    HAVING SUM(order_total) > 10000
)
SELECT 
    c.customer_name,
    c.email,
    hvc.total_spent
FROM high_value_customers hvc
JOIN customers c ON hvc.customer_id = c.customer_id
ORDER BY hvc.total_spent DESC;
```

### 2.2 Çoklu CTE

```sql
WITH 
-- CTE 1: Aylık satışlar
monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', order_date) as month,
        SUM(total_amount) as revenue
    FROM orders
    GROUP BY month
),

-- CTE 2: Aylık maliyetler
monthly_costs AS (
    SELECT 
        DATE_TRUNC('month', expense_date) as month,
        SUM(amount) as total_cost
    FROM expenses
    GROUP BY month
),

-- CTE 3: Kar marjı
monthly_profit AS (
    SELECT 
        COALESCE(s.month, c.month) as month,
        COALESCE(s.revenue, 0) as revenue,
        COALESCE(c.total_cost, 0) as cost,
        COALESCE(s.revenue, 0) - COALESCE(c.total_cost, 0) as profit
    FROM monthly_sales s
    FULL OUTER JOIN monthly_costs c ON s.month = c.month
)

-- Ana sorgu
SELECT 
    month,
    revenue,
    cost,
    profit,
    ROUND(profit / NULLIF(revenue, 0) * 100, 2) as profit_margin_pct
FROM monthly_profit
ORDER BY month DESC;
```

### 2.3 Recursive CTE

#### Organizational Hierarchy
```sql
-- Şirket hiyerarşisi
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: CEO (yöneticisi yok)
    SELECT 
        employee_id,
        employee_name,
        manager_id,
        1 as level,
        CAST(employee_name AS VARCHAR(1000)) as path
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: Astlar
    SELECT 
        e.employee_id,
        e.employee_name,
        e.manager_id,
        eh.level + 1,
        eh.path || ' -> ' || e.employee_name
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT 
    REPEAT('  ', level - 1) || employee_name as hierarchy,
    level,
    path
FROM employee_hierarchy
ORDER BY path;
```

#### Date Series (Tarih aralığı oluşturma)
```sql
WITH RECURSIVE date_series AS (
    -- Start date
    SELECT DATE '2024-01-01' as date
    
    UNION ALL
    
    -- Increment
    SELECT date + INTERVAL '1 day'
    FROM date_series
    WHERE date < DATE '2024-12-31'
)
SELECT 
    date,
    TO_CHAR(date, 'Day') as day_name,
    EXTRACT(WEEK FROM date) as week_number,
    EXTRACT(MONTH FROM date) as month
FROM date_series;
```

#### Bill of Materials (BOM)
```sql
-- Ürün ağacı (parça-alt parça ilişkisi)
WITH RECURSIVE parts_explosion AS (
    -- Ana ürün
    SELECT 
        product_id,
        product_name,
        parent_product_id,
        quantity,
        1 as level
    FROM products
    WHERE product_id = 100  -- Ana ürün ID
    
    UNION ALL
    
    -- Alt parçalar
    SELECT 
        p.product_id,
        p.product_name,
        p.parent_product_id,
        p.quantity * pe.quantity as total_quantity,
        pe.level + 1
    FROM products p
    INNER JOIN parts_explosion pe ON p.parent_product_id = pe.product_id
)
SELECT 
    REPEAT('--', level - 1) || product_name as part_hierarchy,
    total_quantity,
    level
FROM parts_explosion
ORDER BY level, product_name;
```

---

## 3. Normalizasyon

### 3.1 Normal Formlar

#### Unnormalized (0NF)
```sql
-- Tekrar eden gruplar var
CREATE TABLE orders_bad (
    order_id INT,
    customer_name VARCHAR(100),
    product1 VARCHAR(100),
    quantity1 INT,
    product2 VARCHAR(100),
    quantity2 INT,
    product3 VARCHAR(100),
    quantity3 INT
);
```

#### First Normal Form (1NF)
**Kural:** Atomic değerler, tekrar eden gruplar yok

```sql
-- ✅ 1NF: Her hücre atomic
CREATE TABLE orders (
    order_id INT,
    customer_name VARCHAR(100),
    product_name VARCHAR(100),
    quantity INT,
    PRIMARY KEY (order_id, product_name)
);
```

#### Second Normal Form (2NF)
**Kural:** 1NF + Partial dependency yok

```sql
-- ❌ 1NF ama 2NF değil: customer_name sadece order_id'ye bağlı
CREATE TABLE orders (
    order_id INT,
    product_name VARCHAR(100),
    customer_name VARCHAR(100),  -- Partial dependency!
    quantity INT,
    PRIMARY KEY (order_id, product_name)
);

-- ✅ 2NF: Ayrı tablolar
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE order_items (
    order_id INT,
    product_name VARCHAR(100),
    quantity INT,
    PRIMARY KEY (order_id, product_name),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
```

#### Third Normal Form (3NF)
**Kural:** 2NF + Transitive dependency yok

```sql
-- ❌ 2NF ama 3NF değil: city → country (transitive)
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    city VARCHAR(50),
    country VARCHAR(50)  -- Transitive: employee → city → country
);

-- ✅ 3NF: Transitive dependency kaldırıldı
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    city_id INT,
    FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(50),
    country VARCHAR(50)
);
```

#### Boyce-Codd Normal Form (BCNF)
**Kural:** 3NF + Her determinant candidate key

```sql
-- ❌ 3NF ama BCNF değil
CREATE TABLE course_instructors (
    student_id INT,
    course_id INT,
    instructor VARCHAR(100),
    PRIMARY KEY (student_id, course_id),
    -- Problem: instructor → course_id ama instructor PK değil
);

-- ✅ BCNF
CREATE TABLE student_courses (
    student_id INT,
    course_id INT,
    PRIMARY KEY (student_id, course_id)
);

CREATE TABLE course_instructors (
    course_id INT PRIMARY KEY,
    instructor VARCHAR(100)
);
```

### 3.2 Denormalizasyon

**Ne Zaman?**
- ✅ Read-heavy sistemler
- ✅ Performans kritik
- ✅ Çok fazla JOIN

```sql
-- Normalize (çok JOIN)
SELECT 
    o.order_id,
    c.customer_name,
    p.product_name,
    oi.quantity
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- Denormalize (tek tablo, hızlı ama redundant)
CREATE TABLE order_details_denorm (
    order_id INT,
    order_date DATE,
    customer_id INT,
    customer_name VARCHAR(100),  -- Redundant
    customer_email VARCHAR(100), -- Redundant
    product_id INT,
    product_name VARCHAR(100),   -- Redundant
    quantity INT,
    unit_price DECIMAL(10,2)
);

-- Sorgu çok basit ve hızlı
SELECT * FROM order_details_denorm WHERE order_id = 12345;
```

---

## 4. İndeksleme (Indexing)

### 4.1 Neden İndeks?

```sql
-- İndeks olmadan: Full table scan O(n)
SELECT * FROM users WHERE email = 'user@example.com';
-- 1 milyon satır → 1 milyon satır taranır

-- İndeks ile: O(log n)
CREATE INDEX idx_users_email ON users(email);
-- 1 milyon satır → ~20 satır taranır (B-Tree depth)
```

### 4.2 İndeks Türleri

#### B-Tree Index (Default)
```sql
-- Tek sütun
CREATE INDEX idx_orders_customer ON orders(customer_id);

-- Composite (çoklu sütun)
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);

-- Unique index
CREATE UNIQUE INDEX idx_users_email ON users(email);

-- Partial index (şartlı)
CREATE INDEX idx_active_users ON users(email) WHERE is_active = TRUE;
```

#### Hash Index
```sql
-- Sadece equality (=) için
CREATE INDEX idx_users_email_hash ON users USING HASH (email);

-- Kullanım
SELECT * FROM users WHERE email = 'user@example.com';  -- ✅ Hızlı
SELECT * FROM users WHERE email LIKE 'user%';          -- ❌ Index kullanmaz
```

#### GiST Index (Generalized Search Tree)
```sql
-- Full-text search
CREATE EXTENSION pg_trgm;
CREATE INDEX idx_products_name_gist ON products USING GIST (product_name gist_trgm_ops);

-- Kullanım
SELECT * FROM products WHERE product_name % 'laptop';  -- Fuzzy search
```

#### GIN Index (Generalized Inverted Index)
```sql
-- Array sütunlar için
CREATE INDEX idx_posts_tags ON posts USING GIN (tags);

-- Kullanım
SELECT * FROM posts WHERE tags @> ARRAY['postgresql', 'database'];

-- JSONB için
CREATE INDEX idx_users_preferences ON users USING GIN (preferences);
SELECT * FROM users WHERE preferences @> '{"theme": "dark"}';
```

### 4.3 Composite Index Sırası

```sql
-- ❌ Yanlış sıra
CREATE INDEX idx_bad ON orders(order_date, customer_id);
-- Bu sorgu index'i kullanamaz:
SELECT * FROM orders WHERE customer_id = 123;

-- ✅ Doğru sıra
CREATE INDEX idx_good ON orders(customer_id, order_date);
-- Her iki sorgu da index kullanır:
SELECT * FROM orders WHERE customer_id = 123;
SELECT * FROM orders WHERE customer_id = 123 AND order_date > '2024-01-01';

-- Kural: En seçici (selective) sütun önce
```

### 4.4 Covering Index
```sql
-- Index tüm gerekli sütunları içerir
CREATE INDEX idx_orders_covering ON orders(customer_id, order_date, total_amount);

-- Bu sorgu sadece index'ten çalışır (Index-Only Scan)
SELECT order_date, total_amount 
FROM orders 
WHERE customer_id = 123;
```

### 4.5 İndeks Bakımı

```sql
-- İndeks durumu
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan,  -- Kaç kez kullanıldı
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Kullanılmayan indeksler
SELECT 
    schemaname,
    tablename,
    indexname
FROM pg_stat_user_indexes
WHERE idx_scan = 0
AND indexrelname NOT LIKE 'pg_toast%';

-- İndeks boyutu
SELECT 
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as size
FROM pg_stat_user_indexes
ORDER BY pg_relation_size(indexrelid) DESC;

-- Bloated indexes (REINDEX gerekebilir)
REINDEX INDEX idx_users_email;
REINDEX TABLE users;
```

---

## 5. Query Optimization

### 5.1 EXPLAIN ANALYZE

```sql
EXPLAIN ANALYZE
SELECT 
    c.customer_name,
    COUNT(o.order_id) as order_count,
    SUM(o.total_amount) as total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE c.signup_date >= '2024-01-01'
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.total_amount) > 1000
ORDER BY total_spent DESC;

/*
Seq Scan on customers  (cost=0.00..1234.56 rows=1000 width=50) (actual time=0.123..45.678 rows=500 loops=1)
  Filter: (signup_date >= '2024-01-01'::date)
  Rows Removed by Filter: 500
Hash Join  (cost=567.89..9876.54 rows=500 width=58) (actual time=12.345..123.456 rows=500 loops=1)
  ...
*/
```

**Önemli Metrikler:**
- **cost:** Tahmini maliyet
- **rows:** Tahmini satır sayısı  
- **actual time:** Gerçek süre (ms)
- **loops:** Kaç kez çalıştı

### 5.2 Yaygın Performans Sorunları

#### 1. SELECT * Kullanımı
```sql
-- ❌ Yavaş: Tüm sütunları çeker
SELECT * FROM large_table WHERE id = 123;

-- ✅ Hızlı: Sadece gerekli sütunlar
SELECT id, name, email FROM large_table WHERE id = 123;
```

#### 2. Function'lar WHERE'de
```sql
-- ❌ İndeks kullanılamaz
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';

-- ✅ İndeks kullanılır
SELECT * FROM users WHERE email = LOWER('user@example.com');

-- Veya functional index:
CREATE INDEX idx_users_email_lower ON users(LOWER(email));
```

#### 3. Implicit Type Conversion
```sql
-- ❌ İndeks kullanılamaz (customer_id INT ama '123' string)
SELECT * FROM orders WHERE customer_id = '123';

-- ✅ Doğru tip
SELECT * FROM orders WHERE customer_id = 123;
```

#### 4. OR vs UNION
```sql
-- ❌ Yavaş: İki ayrı scan
SELECT * FROM products WHERE category = 'Electronics' OR category = 'Books';

-- ✅ Hızlı: Her biri index kullanır
SELECT * FROM products WHERE category = 'Electronics'
UNION ALL
SELECT * FROM products WHERE category = 'Books';
```

#### 5. NOT IN vs NOT EXISTS
```sql
-- ❌ Yavaş
SELECT * FROM orders WHERE customer_id NOT IN (SELECT customer_id FROM blacklist);

-- ✅ Hızlı
SELECT * FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM blacklist b WHERE b.customer_id = o.customer_id);
```

### 5.3 Query Optimization Checklist

```sql
-- 1. İndeksleri kontrol et
SELECT * FROM pg_indexes WHERE tablename = 'orders';

-- 2. İstatistikleri güncelle
ANALYZE orders;

-- 3. Sorgu planını incele
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) 
SELECT ...;

-- 4. Yavaş sorguları logla
-- postgresql.conf:
log_min_duration_statement = 1000  -- 1 saniyeden yavaş

-- 5. Connection pooling kullan
-- PgBouncer, pgpool-II

-- 6. Vacuum düzenli çalıştır
VACUUM ANALYZE;
```

---

## 6. Stored Procedures ve Functions

### 6.1 Functions

```sql
-- Basit function
CREATE OR REPLACE FUNCTION calculate_discount(
    original_price DECIMAL,
    discount_pct INT
)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $
BEGIN
    RETURN original_price * (1 - discount_pct / 100.0);
END;
$;

-- Kullanım
SELECT 
    product_name,
    price,
    calculate_discount(price, 20) as discounted_price
FROM products;
```

### 6.2 Stored Procedures

```sql
CREATE OR REPLACE PROCEDURE process_daily_orders()
LANGUAGE plpgsql
AS $
DECLARE
    order_count INT;
BEGIN
    -- Günlük siparişleri işle
    INSERT INTO daily_stats (stat_date, total_orders, total_revenue)
    SELECT 
        CURRENT_DATE,
        COUNT(*),
        SUM(total_amount)
    FROM orders
    WHERE order_date = CURRENT_DATE;
    
    GET DIAGNOSTICS order_count = ROW_COUNT;
    
    RAISE NOTICE 'Processed % orders', order_count;
    
    COMMIT;
END;
$;

-- Çalıştır
CALL process_daily_orders();
```

---

## 7. Triggers

```sql
-- Trigger function
CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $
BEGIN
    -- Sipariş eklendiğinde stoğu azalt
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    
    -- Stok kontrolü
    IF (SELECT stock_quantity FROM products WHERE product_id = NEW.product_id) < 0 THEN
        RAISE EXCEPTION 'Yetersiz stok!';
    END IF;
    
    RETURN NEW;
END;
$;

-- Trigger
CREATE TRIGGER trg_update_stock
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();
```

---

## 8. Partitioning

```sql
-- Range partitioning
CREATE TABLE orders (
    order_id BIGINT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2)
) PARTITION BY RANGE (order_date);

-- Partitions
CREATE TABLE orders_2024_q1 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE orders_2024_q2 PARTITION OF orders
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');
```

---

## 🔄 Alternatifler ve Ekosistem

Bu haftanın aracı SQL'in kendisi. Öğrendiğiniz kavramlar (window function, CTE, indeks,
EXPLAIN, partitioning) neredeyse her veritabanında var, ama **sözdizimi ve araçlar** değişiyor:

| Kullandığımız | Açık kaynak alternatif | Enterprise / Yönetilen | Ne zaman değerlendirilmeli |
|---|---|---|---|
| **PostgreSQL (PL/pgSQL)** | MySQL/MariaDB, DuckDB, ClickHouse | Oracle (PL/SQL), SQL Server (T-SQL), Snowflake, BigQuery | Kurumun mevcut veritabanı hangisiyse; aynı sorgu farklı lehçede yazılmalı |
| **EXPLAIN ANALYZE** | pgBadger, pg_stat_statements, explain.dalibo.com | Oracle AWR/SQL Tuning Advisor, SQL Server Query Store, Datadog DBM, pganalyze | Sürekli performans izleme, çok sayıda sunucu |
| **SQL formatlama / lint** | SQLFluff, sqlfmt | DataGrip, Redgate SQL Prompt | Ekipte ortak SQL stili, CI'da kontrol |

**Değerlendirirken bakılacaklar:** lehçe taşınabilirliği (ANSI SQL'e ne kadar yakın?), stored procedure bağımlılığı (taşımayı en çok zorlaştıran şey), izleme araçlarının ücretsiz/ücretli olması.

**Sık karşılaşılan lehçe farkları:**

| Ne | PostgreSQL | SQL Server (T-SQL) | Oracle | BigQuery |
|---|---|---|---|---|
| İlk N satır | `LIMIT 10` | `TOP 10` / `OFFSET … FETCH` | `FETCH FIRST 10 ROWS ONLY` | `LIMIT 10` |
| Metin birleştirme | `a \|\| b` | `a + b` / `CONCAT` | `a \|\| b` | `CONCAT(a, b)` |
| Bugün | `CURRENT_DATE` | `CAST(GETDATE() AS date)` | `TRUNC(SYSDATE)` | `CURRENT_DATE()` |
| Prosedür dili | PL/pgSQL | T-SQL | PL/SQL | SQL scripting |
| Window filtre | alt sorgu / CTE | alt sorgu / CTE | alt sorgu / CTE | `QUALIFY` |

📎 Tüm katmanların haritası ve lisans rehberi: [ALTERNATIVES.md](../ALTERNATIVES.md#-veritabanları-hafta-23)

---

## 9. Pratik Uygulamalar

```bash
# PostgreSQL başlat
docker-compose up -d postgres

# Örnek dosyaları çalıştır
docker exec -it veri_postgres psql -U veri_user -d veri_db -f /docker-entrypoint-initdb.d/window-functions.sql
```

---

## 10. Alıştırmalar

### Alıştırma 1: Window Functions
Aylık satış trendini ve hareketli ortalamaları hesaplayın.

### Alıştırma 2: Recursive CTE
Organizasyon hiyerarşisini oluşturun.

### Alıştırma 3: Query Optimization
Yavaş bir sorguyu optimize edin ve EXPLAIN ANALYZE ile karşılaştırın.

---

**Özet:** Bu haftada ileri SQL tekniklerini, window functions, CTE, normalizasyon, indeksleme ve query optimization konularını öğrendik.

**[← Hafta 4: Veri Ambarları, Veri Gölleri ve Mimariler](../week04-de-datawarehouse/README.md) | [🏠 Ana Sayfa](../README.md) | [Hafta 6: Veri Mühendisliğine Giriş ve Modern Veri Ekosistemi →](../week06-de-data-engineering/README.md)**