-- Create the pizza_sales database
CREATE DATABASE pizza_sales;

-- Use the pizza_sales database
USE pizza_sales;

-- Create the 'orders' table
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    DATE TEXT,
    TIME TEXT
);

-- Load data from CSV into the 'orders' table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Create the 'order_details' table
CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id TEXT,
    quantity INT
);

-- Load data from CSV into the 'order_details' table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

-- Create a view 'pizza_details'
CREATE VIEW pizza_details AS
SELECT
    p.pizza_id,
    p.pizza_type_id,
    pt.name,
    pt.category,
    p.size,
    p.price,
    pt.ingredients
FROM
    pizzas p
JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id;

-- Display the contents of 'pizza_details' view
SELECT * FROM pizza_details;

-- Display the contents of 'orders' table
SELECT * FROM orders;

-- Modify the 'date' and 'time' columns in the 'orders' table
ALTER TABLE orders
MODIFY date DATE;

ALTER TABLE orders
MODIFY time TIME;

-- Calculate total revenue
SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizza_details p ON od.pizza_id = p.pizza_id;

-- Calculate total pizzas sold
SELECT SUM(od.quantity) AS pizza_sold
FROM order_details od;

-- Calculate total orders
SELECT COUNT(DISTINCT(order_id)) AS total_orders
FROM order_details;

-- Calculate average order value
SELECT ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT(od.order_id)), 2) AS avg_order_value
FROM order_details od
JOIN pizza_details p ON od.pizza_id = p.pizza_id;

-- Calculate average number of pizza per order
SELECT ROUND(SUM(od.quantity) / COUNT(DISTINCT(od.order_id)), 0) AS avg_no_pizza_per_order
FROM order_details od;

-- Calculate total revenue and number of orders per category
SELECT
    p.category,
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue,
    COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN pizza_details p ON p.pizza_id = od.pizza_id
GROUP BY p.category;

-- Calculate total revenue and number of orders per size
SELECT
    p.size,
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue,
    COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN pizza_details p ON p.pizza_id = od.pizza_id
GROUP BY p.size;

-- Calculate hourly trend of orders and revenue of pizza
SELECT
    CASE
        WHEN HOUR(o.time) BETWEEN 9 AND 12 THEN 'Late Morning'
        WHEN HOUR(o.time) BETWEEN 12 AND 15 THEN 'Lunch'
        WHEN HOUR(o.time) BETWEEN 15 AND 18 THEN 'Mid Afternoon'
        WHEN HOUR(o.time) BETWEEN 18 AND 21 THEN 'Dinner'
        WHEN HOUR(o.time) BETWEEN 21 AND 23 THEN 'Late Night'
        ELSE 'Others'
    END AS meal_time,
    COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o ON o.order_id = od.order_id
GROUP BY meal_time
ORDER BY total_orders DESC;

-- Calculate weekdays trend
SELECT
    DAYNAME(o.date) AS day_name,
    COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o ON o.order_id = od.order_id
GROUP BY DAYNAME(o.date)
ORDER BY total_orders DESC;

-- Calculate monthwise trend
SELECT
    MONTHNAME(o.date) AS month_name,
    COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o ON o.order_id = od.order_id
GROUP BY MONTHNAME(o.date)
ORDER BY total_orders DESC;

-- Calculate most ordered pizza
SELECT
    p.name,
    p.size,
    COUNT(od.order_id) AS count_pizzas
FROM order_details od
JOIN pizza_details p ON od.pizza_id = p.pizza_id
GROUP BY p.name, p.size
ORDER BY count_pizzas DESC;

-- Calculate top 5 pizzas by revenue
SELECT
    p.name,
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizza_details p ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY total_revenue DESC;

-- Calculate top pizza by sale
SELECT
    p.name,
    SUM(od.quantity) AS total_sales
FROM order_details od
JOIN pizza_details p ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY total_sales DESC;

-- Pizza analysis
SELECT
    p.name,
    p.price
FROM pizza_details p
ORDER BY p.price DESC;

-- Create a temporary table for numbers
CREATE TEMPORARY TABLE numbers AS (
    SELECT 1 AS n UNION ALL
    SELECT 2 UNION ALL
    SELECT 3 UNION ALL
    SELECT 4 UNION ALL
    SELECT 5 UNION ALL
    SELECT 6 UNION ALL
    SELECT 7 UNION ALL
    SELECT 8 UNION ALL
    SELECT 9 UNION ALL
    SELECT 10
);

-- Calculate top used ingredients
SELECT
    ingredient,
    COUNT(ingredient) AS ingredient_count
FROM (
    SELECT
        SUBSTRING_INDEX(SUBSTRING_INDEX(p.ingredients, ',', n), ',', -1) AS ingredient
    FROM order_details od
    JOIN pizza_details p ON p.pizza_id = od.pizza_id
    JOIN numbers ON CHAR_LENGTH(p.ingredients) - CHAR_LENGTH(REPLACE(p.ingredients, ',', '')) >= n - 1
) AS subquery
GROUP BY ingredient
ORDER BY ingredient_count DESC;
