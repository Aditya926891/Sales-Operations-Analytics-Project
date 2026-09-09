CREATE DATABASE sales_project;
USE sales_project;
CREATE TABLE customers (
    customer_id VARCHAR(10) PRIMARY KEY,
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    region VARCHAR(50),
    city VARCHAR(100),
    signup_date DATE
);

CREATE TABLE products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(150),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

CREATE TABLE sales_reps (
    rep_id VARCHAR(10) PRIMARY KEY,
    rep_name VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE orders (
    order_id VARCHAR(10) PRIMARY KEY,
    order_date DATE,
    ship_date DATE,
    customer_id VARCHAR(10),
    product_id VARCHAR(10),
    rep_id VARCHAR(10),
    quantity INT,
    discount DECIMAL(4,2),
    sales_amount DECIMAL(10,2),
    profit DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (rep_id) REFERENCES sales_reps(rep_id)
);

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM sales_reps;
SELECT COUNT(*) FROM orders;

SELECT 
    o.order_id,
    o.order_date,
    c.customer_name,
    c.region,
    p.product_name,
    p.category,
    o.quantity,
    o.sales_amount,
    o.profit
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id
LIMIT 20;

SELECT COUNT(*) 
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN products p ON o.product_id = p.product_id;

SELECT 
    c.region,
    SUM(o.sales_amount) AS total_revenue,
    SUM(o.profit) AS total_profit,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.region
ORDER BY total_revenue DESC;

#revenue by category
SELECT 
    p.category,
    SUM(o.sales_amount) AS total_revenue,
    SUM(o.profit) AS total_profit,
    COUNT(o.order_id) AS total_orders
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

#Revenue by month
SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(sales_amount) AS total_revenue,
    SUM(profit) AS total_profit
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

SELECT 
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(sales_amount) AS monthly_revenue,
    SUM(SUM(sales_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS running_total,
    LAG(SUM(sales_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS prev_month_revenue
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

SELECT  
    month,
    monthly_revenue,
    running_total,
    prev_month_revenue,
    ROUND(((monthly_revenue - prev_month_revenue) / prev_month_revenue) * 100, 2) AS growth_pct
FROM (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(sales_amount) AS monthly_revenue,
        SUM(SUM(sales_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS running_total,
        LAG(SUM(sales_amount)) OVER (ORDER BY DATE_FORMAT(order_date, '%Y-%m')) AS prev_month_revenue
    FROM orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
) AS monthly_data
ORDER BY month;