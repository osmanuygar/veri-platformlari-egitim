-- Week 5 - Advanced SQL: Schema

-- Customers
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(50),
    country VARCHAR(50),
    registration_date DATE NOT NULL,
    customer_segment VARCHAR(20) -- Bronze, Silver, Gold, Platinum
);

-- Categories (Hierarchical)
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES categories(category_id),
    description TEXT
);

-- Products
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_id INTEGER REFERENCES categories(category_id),
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL -- pending, completed, cancelled
);

-- Order Items
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id),
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL
);

-- Employee (for self-join examples)
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    manager_id INTEGER REFERENCES employees(employee_id),
    department VARCHAR(50),
    salary DECIMAL(10,2)
);

COMMENT ON TABLE customers IS 'Customer information';
COMMENT ON TABLE categories IS 'Product categories with hierarchy';
COMMENT ON TABLE products IS 'Product catalog';
COMMENT ON TABLE orders IS 'Order headers';
COMMENT ON TABLE order_items IS 'Order line items';
COMMENT ON TABLE employees IS 'Employee hierarchy for self-join examples';