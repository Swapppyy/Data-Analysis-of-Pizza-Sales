CREATE DATABASE pizza_sales;

USE pizza_sales;

CREATE TABLE orders(

order_id INT PRIMARY KEY,
DATE TEXT,
TIME TEXT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders
FIELDS terminated by ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select * from order_details;

Create table order_details(

order_details int primary key,
order_id int,
pizza_id text,
quantity int


);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_details.csv'
INTO TABLE order_details
FIELDS terminated by ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;



create view pizza_details as 
select p.pizza_id, p.pizza_type_id, pt.name,pt.category,p.size, p.price, pt.ingredients

from pizzas p
join pizza_types pt
on pt.pizza_type_id = p.pizza_type_id;

select * from pizza_details;
select * from orders;


ALTER TABLE orders
modify date DATE;

ALTER TABLE orders
modify time TIME;

-- total revenue --

select round(sum(od.quantity * p.price),2) as total_revenue
from order_details od
join pizza_details p 
on od.pizza_id = p.pizza_id;


-- total pizzas sold

select sum(od.quantity) as pizza_sold
from order_details od; 

-- total orders

select count(distinct(order_id)) as total_orders
from order_details;

-- average order value

select round(SUM(od.quantity * p.price ) / count(distinct(od.order_id)),2) as avg_order_value
from order_details od
join pizza_details p 
on od.pizza_id = p.pizza_id; 

-- average number of pizza per order

select round(sum(od.quantity) / count(distinct(od.order_id)),0) as avg_no_pizza_per_order
from order_details od;


-- total revenue and no.of orders per category

select p.category, round(sum(od.quantity * p.price),2) as total_revenue, count(distinct(od.order_id)) as total_orders
from order_details od
join pizza_details p 
on p.pizza_id = od.pizza_id
group by p.category;


-- total revenue and number of orders per size

select p.size, round(sum(od.quantity * p.price),2) as total_revenue, count(distinct(od.order_id)) as total_orders
from order_details od
join pizza_details p 
on p.pizza_id = od.pizza_id
group by p.size;


-- hourly, daily, monthly trend of orders and revenue of pizza

select 
case 
when hour(o.time) between 9 and 12 then 'Late Morning'
when hour(o.time) between 12 and 15 then 'Lunch'
when hour(o.time) between 15 and 18 then 'Mid Afternoon'
when hour(o.time) between 18 and 21 then 'Dinner'
when hour(o.time) between 21 and 23 then 'Late Night'
else 'others'
end as meal_time, count(distinct(od.order_id)) as total_orders
from order_details od
join orders o 
on o.order_id = od.order_id
group by meal_time
order by total_orders desc;

-- weekdays

select dayname(o.date) AS day_name, count(distinct(od.order_id)) as total_orders
from order_details od
join orders o
on o.order_id = od.order_id
group by dayname(o.date)
order by total_orders desc;

-- monthwise trend 

select monthname(o.date) AS month_name, count(distinct(od.order_id)) as total_orders
from order_details od
join orders o
on o.order_id = od.order_id
group by monthname(o.date)
order by total_orders desc;

-- most_ordered_pizza || we can also calculate irrespective of size (just remove p.size from the query) || (Add limit at the end to see top categories)

select p.name, p.size, count(od.order_id) as count_pizzas
from order_details od
join pizza_details p 
on od.pizza_id = p.pizza_id
group by p.name, p.size
order by count_pizzas desc;

-- top 5 pizzas by revenue

select p.name, round(sum(od.quantity * p.price ),2) as total_revenue
from order_details od 
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.name
order by total_revenue desc;

-- top pizza by sale

select p.name, sum(od.quantity ) as total_sales
from order_details od 
join pizza_details p
on od.pizza_id = p.pizza_id
group by p.name
order by total_sales desc;

-- pizza analysis

select p.name, p.price
from pizza_details p
order by p.price desc;

-- top used ingredients

create temporary table numbers as (

	select 1 as n union all
    select 2 union all
    select 3 union all
    select 4 union all
    select 5 union all
    select 6 union all
    select 7 union all
    select 8 union all
    select 9 union all
    select 10
    );
    
    
    select ingredient, count(ingredient) as ingredient_count
    from(
    select substring_index(substring_index(ingredients, ',', n), ',', -1) as ingredient
    from order_details od
    join pizza_details p
    on p.pizza_id = od.pizza_id
    join numbers on char_length(ingredients) - char_length(replace(ingredients, ',', '')) >= n-1
    ) as subquery
    
group by ingredient
order by ingredient_count desc


-- 