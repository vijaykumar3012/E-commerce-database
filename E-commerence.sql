-- ============================================================
--  E-COMMERCE DATABASE (MySQL)
--  Tables: customers, categories, products, orders,
--          order_items, payments, shipping
-- ============================================================

CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

-- ─────────────────────────────────────────────
--  1. CUSTOMERS
-- ─────────────────────────────────────────────
CREATE TABLE customers (
    customer_id   INT           AUTO_INCREMENT PRIMARY KEY,
    first_name    VARCHAR(50)   NOT NULL,
    last_name     VARCHAR(50)   NOT NULL,
    email         VARCHAR(100)  NOT NULL UNIQUE,
    phone         VARCHAR(20),
    address       TEXT,
    city          VARCHAR(50),
    country       VARCHAR(50)   DEFAULT 'India',
    created_at    DATETIME      DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────────
--  2. CATEGORIES
-- ─────────────────────────────────────────────
CREATE TABLE categories (
    category_id   INT          AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    parent_id     INT          DEFAULT NULL,                   -- supports sub-categories
    FOREIGN KEY (parent_id) REFERENCES categories(category_id)
);

-- ─────────────────────────────────────────────
--  3. PRODUCTS
-- ─────────────────────────────────────────────
CREATE TABLE products (
    product_id    INT             AUTO_INCREMENT PRIMARY KEY,
    category_id   INT             NOT NULL,
    name          VARCHAR(150)    NOT NULL,
    description   TEXT,
    price         DECIMAL(10, 2)  NOT NULL,
    stock_qty     INT             DEFAULT 0,
    is_active     BOOLEAN         DEFAULT TRUE,
    created_at    DATETIME        DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- ─────────────────────────────────────────────
--  4. ORDERS
-- ─────────────────────────────────────────────
CREATE TABLE orders (
    order_id      INT           AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT           NOT NULL,
    status        ENUM('pending','confirmed','shipped','delivered','cancelled')
                                DEFAULT 'pending',
    total_amount  DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ordered_at    DATETIME      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ─────────────────────────────────────────────
--  5. ORDER ITEMS
-- ─────────────────────────────────────────────
CREATE TABLE order_items (
    item_id       INT             AUTO_INCREMENT PRIMARY KEY,
    order_id      INT             NOT NULL,
    product_id    INT             NOT NULL,
    quantity      INT             NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10, 2)  NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ─────────────────────────────────────────────
--  6. PAYMENTS
-- ─────────────────────────────────────────────
CREATE TABLE payments (
    payment_id    INT             AUTO_INCREMENT PRIMARY KEY,
    order_id      INT             NOT NULL UNIQUE,
    method        ENUM('credit_card','debit_card','upi','net_banking','cod')
                                  NOT NULL,
    status        ENUM('pending','completed','failed','refunded')
                                  DEFAULT 'pending',
    paid_at       DATETIME,
    amount        DECIMAL(10, 2)  NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ─────────────────────────────────────────────
--  7. SHIPPING
-- ─────────────────────────────────────────────
CREATE TABLE shipping (
    shipping_id     INT          AUTO_INCREMENT PRIMARY KEY,
    order_id        INT          NOT NULL UNIQUE,
    carrier         VARCHAR(50),
    tracking_number VARCHAR(100),
    shipped_at      DATETIME,
    estimated_delivery DATE,
    delivered_at    DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


-- ============================================================
--  SAMPLE DATA
-- ============================================================

-- Customers
INSERT INTO customers (first_name, last_name, email, phone, city) VALUES
('Arjun',   'Kumar',   'arjun.kumar@email.com',   '9876543210', 'Chennai'),
('Priya',   'Sharma',  'priya.sharma@email.com',  '9123456780', 'Mumbai'),
('Rahul',   'Verma',   'rahul.verma@email.com',   '9988776655', 'Delhi'),
('Sneha',   'Nair',    'sneha.nair@email.com',    '9001122334', 'Bengaluru'),
('Karthik', 'Rajan',   'karthik.rajan@email.com', '9445566778', 'Hyderabad');

-- Categories
INSERT INTO categories (name, parent_id) VALUES
('Electronics',   NULL),
('Clothing',      NULL),
('Books',         NULL),
('Mobiles',       1),
('Laptops',       1),
('Men\'s Wear',   2),
('Women\'s Wear', 2);

-- Products
INSERT INTO products (category_id, name, price, stock_qty) VALUES
(4, 'Samsung Galaxy S24',     74999.00, 50),
(4, 'iPhone 15',             89999.00, 30),
(5, 'Dell Inspiron 15',      55000.00, 20),
(5, 'MacBook Air M2',        99000.00, 15),
(6, 'Men\'s Casual Shirt',     899.00, 200),
(7, 'Women\'s Kurti',          699.00, 300),
(3, 'Clean Code (Book)',       599.00, 100),
(3, 'SQL in 10 Minutes',       499.00, 80);

-- Orders
INSERT INTO orders (customer_id, status, total_amount, ordered_at) VALUES
(1, 'delivered',  74999.00, '2024-11-01 10:00:00'),
(2, 'shipped',    89999.00, '2024-11-05 14:30:00'),
(3, 'confirmed',  55000.00, '2024-11-10 09:15:00'),
(4, 'pending',     1398.00, '2024-11-15 18:00:00'),
(1, 'delivered',   1098.00, '2024-10-20 11:00:00'),
(5, 'cancelled',  99000.00, '2024-11-12 16:45:00');

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 74999.00),
(2, 2, 1, 89999.00),
(3, 3, 1, 55000.00),
(4, 5, 1,   899.00),
(4, 6, 1,   699.00),
(5, 7, 1,   599.00),
(5, 8, 1,   499.00),
(6, 4, 1, 99000.00);

-- Payments
INSERT INTO payments (order_id, method, status, paid_at, amount) VALUES
(1, 'credit_card', 'completed', '2024-11-01 10:05:00', 74999.00),
(2, 'upi',         'completed', '2024-11-05 14:35:00', 89999.00),
(3, 'net_banking', 'completed', '2024-11-10 09:20:00', 55000.00),
(4, 'cod',         'pending',   NULL,                    1398.00),
(5, 'debit_card',  'completed', '2024-10-20 11:05:00',  1098.00),
(6, 'credit_card', 'refunded',  '2024-11-12 17:00:00', 99000.00);

-- Shipping
INSERT INTO shipping (order_id, carrier, tracking_number, shipped_at, estimated_delivery, delivered_at) VALUES
(1, 'BlueDart', 'BD123456', '2024-11-02 08:00:00', '2024-11-05', '2024-11-04 15:00:00'),
(2, 'DTDC',     'DT789012', '2024-11-06 09:00:00', '2024-11-10', NULL),
(3, 'FedEx',    'FX345678', '2024-11-11 10:00:00', '2024-11-15', NULL),
(5, 'BlueDart', 'BD654321', '2024-10-21 07:30:00', '2024-10-24', '2024-10-23 12:00:00');


-- ============================================================
--  USEFUL QUERIES
-- ============================================================

-- 1. All orders with customer name and status
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    o.status,
    o.total_amount,
    o.ordered_at
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.ordered_at DESC;


-- 2. Order details with product breakdown
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    p.name                                  AS product,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price)           AS line_total
FROM orders o
JOIN customers  c  ON o.customer_id  = c.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
JOIN products   p  ON oi.product_id  = p.product_id;


-- 3. Revenue by category
SELECT
    cat.name                             AS category,
    SUM(oi.quantity * oi.unit_price)     AS total_revenue,
    COUNT(DISTINCT o.order_id)           AS total_orders
FROM order_items oi
JOIN products  p   ON oi.product_id  = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
JOIN orders     o   ON oi.order_id   = o.order_id
WHERE o.status != 'cancelled'
GROUP BY cat.category_id, cat.name
ORDER BY total_revenue DESC;


-- 4. Top customers by spending
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    c.email,
    COUNT(o.order_id)                       AS total_orders,
    SUM(o.total_amount)                     AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status != 'cancelled'
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 5;


-- 5. Low stock products (qty < 25)
SELECT
    p.product_id,
    p.name,
    p.stock_qty,
    cat.name AS category
FROM products p
JOIN categories cat ON p.category_id = cat.category_id
WHERE p.stock_qty < 25 AND p.is_active = TRUE
ORDER BY p.stock_qty ASC;


-- 6. Payment summary by method
SELECT
    method,
    COUNT(*)          AS transactions,
    SUM(amount)       AS total_amount,
    AVG(amount)       AS avg_amount
FROM payments
WHERE status = 'completed'
GROUP BY method
ORDER BY total_amount DESC;


-- 7. Pending deliveries (shipped but not delivered)
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    s.carrier,
    s.tracking_number,
    s.shipped_at,
    s.estimated_delivery
FROM shipping s
JOIN orders    o ON s.order_id    = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE s.delivered_at IS NULL
  AND o.status = 'shipped';


-- 8. Monthly revenue (last 12 months)
SELECT
    DATE_FORMAT(o.ordered_at, '%Y-%m') AS month,
    COUNT(o.order_id)                  AS orders_count,
    SUM(o.total_amount)                AS revenue
FROM orders o
WHERE o.status NOT IN ('cancelled', 'pending')
  AND o.ordered_at >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
GROUP BY month
ORDER BY month;