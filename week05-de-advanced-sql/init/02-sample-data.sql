-- Week 5 - Sample Data

-- Customers (100 sample)
INSERT INTO customers (first_name, last_name, email, city, country, registration_date, customer_segment)
SELECT
    'Customer' || i,
    'Surname' || i,
    'customer' || i || '@example.com',
    (ARRAY['Istanbul', 'Ankara', 'Izmir', 'Bursa', 'Antalya'])[1 + (i % 5)],
    'Turkey',
    CURRENT_DATE - (i || ' days')::INTERVAL,
    (ARRAY['Bronze', 'Silver', 'Gold', 'Platinum'])[1 + (i % 4)]
FROM generate_series(1, 100) AS i;

-- Categories (hierarchical)
INSERT INTO categories (category_name, parent_id, description) VALUES
('Electronics', NULL, 'Electronic devices'),
('Computers', 1, 'Computer products'),
('Laptops', 2, 'Laptop computers'),
('Desktops', 2, 'Desktop computers'),
('Peripherals', 1, 'Computer peripherals'),
('Keyboards', 5, 'Keyboard products'),
('Mice', 5, 'Mouse products'),
('Furniture', NULL, 'Office furniture'),
('Desks', 8, 'Office desks'),
('Chairs', 8, 'Office chairs');

-- Products (50 sample)
INSERT INTO products (product_name, category_id, price, stock_quantity)
SELECT
    'Product ' || i,
    1 + (i % 10),
    (random() * 1000 + 50)::DECIMAL(10,2),
    (random() * 100)::INTEGER
FROM generate_series(1, 50) AS i;

-- Employees (for self-join)
INSERT INTO employees (first_name, last_name, manager_id, department, salary) VALUES
('John', 'CEO', NULL, 'Executive', 150000),
('Jane', 'CTO', 1, 'Technology', 120000),
('Mike', 'CFO', 1, 'Finance', 120000),
('Sarah', 'Dev Lead', 2, 'Technology', 90000),
('Tom', 'Dev', 4, 'Technology', 70000),
('Emma', 'Dev', 4, 'Technology', 75000),
('David', 'Accountant', 3, 'Finance', 60000);

-- Orders (200 sample)
INSERT INTO orders (customer_id, order_date, total_amount, status)
SELECT
    1 + (random() * 99)::INTEGER,
    CURRENT_DATE - (random() * 365)::INTEGER,
    (random() * 1000 + 50)::DECIMAL(10,2),
    (ARRAY['pending', 'completed', 'cancelled'])[1 + (random() * 2)::INTEGER]
FROM generate_series(1, 200);

-- Order Items (400 sample)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price)
SELECT
    1 + (random() * 199)::INTEGER,
    1 + (random() * 49)::INTEGER,
    1 + (random() * 5)::INTEGER AS qty,
    p.price AS unit_price,
    (1 + (random() * 5)::INTEGER) * p.price AS total_price
FROM generate_series(1, 400) AS i
CROSS JOIN LATERAL (
    SELECT price FROM products
    WHERE product_id = 1 + (random() * 49)::INTEGER
    LIMIT 1
) p;

-- Update order totals
UPDATE orders o
SET total_amount = (
    SELECT COALESCE(SUM(total_price), 0)
    FROM order_items oi
    WHERE oi.order_id = o.order_id
);

ANALYZE customers;
ANALYZE categories;
ANALYZE products;
ANALYZE orders;
ANALYZE order_items;
ANALYZE employees;