CREATE DATABASE STORES;
USE STORES;

-- 1. Supplier Table
CREATE TABLE IF NOT EXISTS supplier (
    sup_id TINYINT PRIMARY KEY,
    sup_name VARCHAR(255),
    address TEXT
);
SELECT * FROM SUPPLIER;

-- 2. Categories Table
CREATE TABLE IF NOT EXISTS categories (
    cat_id TINYINT PRIMARY KEY,
    cat_name VARCHAR(255)
);
SELECT * FROM categories;

-- 3. Employees Table
CREATE TABLE IF NOT EXISTS employees (
    emp_id TINYINT PRIMARY KEY,
    emp_name VARCHAR(255),
    hire_date VARCHAR(255)
);
SELECT * FROM employees;


-- 4. Customers Table
CREATE TABLE IF NOT EXISTS customers (
    cust_id SMALLINT PRIMARY KEY,
    cust_name VARCHAR(255),
    address TEXT
);
SELECT * FROM customers;

-- 5. Products Table
CREATE TABLE IF NOT EXISTS products (
    prod_id TINYINT PRIMARY KEY,
    prod_name VARCHAR(255),
    sup_id TINYINT,
    cat_id TINYINT,
    price DECIMAL(10,2),
    FOREIGN KEY (sup_id) REFERENCES supplier(sup_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (cat_id) REFERENCES categories(cat_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
SELECT * FROM products;
-- 6. Orders Table
CREATE TABLE IF NOT EXISTS orders (
    ord_id SMALLINT PRIMARY KEY,
    cust_id SMALLINT,
    emp_id TINYINT,
    order_date VARCHAR(255),
    FOREIGN KEY (cust_id) REFERENCES customers(cust_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
SELECT * FROM orders;


-- 7. Order_Details Table
CREATE TABLE IF NOT EXISTS order_details (
    ord_detID SMALLINT AUTO_INCREMENT PRIMARY KEY,
    ord_id SMALLINT,
    prod_id TINYINT,
    quantity TINYINT,
    each_price DECIMAL(10,2),
    total_price DECIMAL(10,2),
    FOREIGN KEY (ord_id) REFERENCES orders(ord_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (prod_id) REFERENCES products(prod_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);
SELECT * FROM order_details;

-- Customer Insights
-- Unique customers who placed orders
SELECT COUNT(DISTINCT cust_id) AS unique_customers
FROM orders;

-- Customers with the highest number of orders
SELECT c.cust_name, COUNT(o.ord_id) AS total_orders
FROM customers c
JOIN orders o ON c.cust_id = o.cust_id
GROUP BY c.cust_id
ORDER BY total_orders DESC;

-- Total and average purchase value per customer
SELECT c.cust_name,
       SUM(od.total_price) AS total_purchase,
       AVG(od.total_price) AS average_purchase
FROM customers c
JOIN orders o ON c.cust_id = o.cust_id
JOIN order_details od ON o.ord_id = od.ord_id
GROUP BY c.cust_id
ORDER BY total_purchase DESC;

-- Top 5 customers by total purchase amount
SELECT c.cust_name, SUM(od.total_price) AS total_spent
FROM customers c
JOIN orders o ON c.cust_id = o.cust_id
JOIN order_details od ON o.ord_id = od.ord_id
GROUP BY c.cust_id
ORDER BY total_spent DESC
LIMIT 5;

-- Product Performance
-- Products count in each category
SELECT cat.cat_name, COUNT(p.prod_id) AS product_count
FROM categories cat
JOIN products p ON cat.cat_id = p.cat_id
GROUP BY cat.cat_id;

--  Average product price by category
SELECT cat.cat_name, AVG(p.price) AS average_price
FROM categories cat
JOIN products p ON cat.cat_id = p.cat_id
GROUP BY cat.cat_id;
-- Products with highest total sales volume (by quantity)
SELECT p.prod_name, SUM(od.quantity) AS total_quantity_sold
FROM products p
JOIN order_details od ON p.prod_id = od.prod_id
GROUP BY p.prod_id
ORDER BY total_quantity_sold DESC;
-- Total revenue per product
SELECT p.prod_name, SUM(od.total_price) AS total_revenue
FROM products p
JOIN order_details od ON p.prod_id = od.prod_id
GROUP BY p.prod_id
ORDER BY total_revenue DESC;
-- Product sales by category and supplier
SELECT c.cat_name, s.sup_name, SUM(od.total_price) AS revenue
FROM order_details od
JOIN products p ON od.prod_id = p.prod_id
JOIN categories c ON p.cat_id = c.cat_id
JOIN supplier s ON p.sup_id = s.sup_id
GROUP BY c.cat_name, s.sup_name
ORDER BY revenue DESC;

-- Sales and Order Trends
-- Total number of orders
SELECT COUNT(*) AS total_orders
FROM orders;
-- Average order value
SELECT AVG(order_total) AS avg_order_value
FROM (
    SELECT ord_id, SUM(total_price) AS order_total
    FROM order_details
    GROUP BY ord_id
) AS order_totals;
-- Dates with most orders
SELECT order_date, COUNT(ord_id) AS order_count
FROM orders
GROUP BY order_date
ORDER BY order_count DESC;
-- Monthly order and revenue trends
SELECT 
  LEFT(order_date, 7) AS month,
  COUNT(DISTINCT o.ord_id) AS total_orders,
  SUM(od.total_price) AS total_revenue
FROM orders o
JOIN order_details od ON o.ord_id = od.ord_id
GROUP BY month
ORDER BY month;

SELECT DISTINCT order_date
FROM orders
LIMIT 20;

SET SQL_SAFE_UPDATES = 0;

UPDATE orders
SET order_date = DATE_FORMAT(STR_TO_DATE(order_date, '%m/%d/%Y'), '%Y-%m-%d')
WHERE order_date LIKE '__/__/____';

SET SQL_SAFE_UPDATES = 0;


UPDATE orders
SET order_date = DATE_FORMAT(STR_TO_DATE(order_date, '%d-%m-%Y'), '%Y-%m-%d')
WHERE order_date LIKE '__-__-____';
-- Weekday vs weekend order patterns
-- (Assumes order_date format is YYYY-MM-DD)
SELECT
  DAYNAME(STR_TO_DATE(order_date, '%Y-%m-%d')) AS day,
  COUNT(*) AS total_orders
FROM orders
GROUP BY day
ORDER BY FIELD(day, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');

-- Supplier Contribution
-- Number of suppliers
SELECT COUNT(*) AS total_suppliers
FROM supplier;

-- Supplier with the most products
SELECT s.sup_name, COUNT(p.prod_id) AS product_count
FROM supplier s
JOIN products p ON s.sup_id = p.sup_id
GROUP BY s.sup_id
ORDER BY product_count DESC;
-- Average product price by supplier
SELECT s.sup_name, AVG(p.price) AS avg_price
FROM supplier s
JOIN products p ON s.sup_id = p.sup_id
GROUP BY s.sup_id;
-- Supplier revenue contribution
SELECT s.sup_name, SUM(od.total_price) AS total_revenue
FROM supplier s
JOIN products p ON s.sup_id = p.sup_id
JOIN order_details od ON p.prod_id = od.prod_id
GROUP BY s.sup_id
ORDER BY total_revenue DESC;

-- Employee Performance
-- Number of employees who processed orders
SELECT COUNT(DISTINCT emp_id) AS employees_with_orders
FROM orders;
-- Employee with most orders
SELECT e.emp_name, COUNT(o.ord_id) AS total_orders
FROM employees e
JOIN orders o ON e.emp_id = o.emp_id
GROUP BY e.emp_id
ORDER BY total_orders DESC;
-- Total sales value by each employee
SELECT e.emp_name, SUM(od.total_price) AS total_sales
FROM employees e
JOIN orders o ON e.emp_id = o.emp_id
JOIN order_details od ON o.ord_id = od.ord_id
GROUP BY e.emp_id
ORDER BY total_sales DESC;
-- Average order value per employee
SELECT e.emp_name, AVG(order_totals.total) AS avg_order_value
FROM employees e
JOIN (
  SELECT o.emp_id, o.ord_id, SUM(od.total_price) AS total
  FROM orders o
  JOIN order_details od ON o.ord_id = od.ord_id
  GROUP BY o.ord_id
) AS order_totals ON e.emp_id = order_totals.emp_id
GROUP BY e.emp_id;

-- Order Details Deep Dive
-- Quantity vs total price relationship
SELECT quantity, AVG(total_price) AS avg_total_price
FROM order_details
GROUP BY quantity
ORDER BY quantity;
-- Average quantity per product
SELECT p.prod_name, AVG(od.quantity) AS avg_quantity
FROM products p
JOIN order_details od ON p.prod_id = od.prod_id
GROUP BY p.prod_id;
-- Unit price variation across order
SELECT p.prod_name, AVG(od.each_price) AS avg_unit_price, 
       MIN(od.each_price) AS min_price, 
       MAX(od.each_price) AS max_price
FROM products p
JOIN order_details od ON p.prod_id = od.prod_id
GROUP BY p.prod_id;



