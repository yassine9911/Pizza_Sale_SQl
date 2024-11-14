-- Retrieve the total number of orders placed.
 SELECT 
    COUNT(Order_id) AS count
FROM
    pizza.orders;
    
-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price), 2) AS Total_Revenue
FROM
    order_details o
        JOIN
    pizzas p ON p.pizza_id = o.pizza_id;
    
-- Identify the highest-priced pizza.
SELECT 
    MAX(price) as Max_Price 
FROM
    pizzas;
    
-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(o.Order_id) AS Count
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
        JOIN
    orders o ON o.order_id = od.order_id
GROUP BY p.size
ORDER BY Count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name AS Pizza_name, COUNT(o.order_id) AS Count
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY Pizza_name
ORDER BY Count DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category AS category, SUM(o.quantity) AS Total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = p.pizza_id
GROUP BY category
ORDER BY Total_quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(orders_time) AS hours, COUNT(order_id) AS Count
FROM
    orders
GROUP BY hours;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS Count
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Total_quantity), 0) AS AVG_Quantity
FROM
    (SELECT 
        orders.orders_date,
            SUM(order_details.quantity) AS Total_quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.orders_date) AS tab;
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(od.quantity * p.price) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND(SUM(p.price * od.quantity) / (SELECT 
                    SUM(p.price * od.quantity)
                FROM
                    pizzas p
                        JOIN
                    order_details od ON p.pizza_id = od.pizza_id) * 100,
            2) AS Percentage
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

-- Analyze the cumulative revenue generated over time.
SELECT dates, round(sum(revenue) over (order by dates),2) as Cumul_revenue
FROM (
    SELECT 
        o.orders_date AS dates, 
        SUM(od.quantity * ps.price) AS revenue 
    FROM 
        orders o 
    JOIN 
        order_details od ON o.order_id = od.order_id 
    JOIN 
        pizzas ps ON ps.pizza_id = od.pizza_id 
    GROUP BY 
        o.orders_date
) as new_table;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category , nam , revenue from (
select category, nam, revenue , rank() over (partition by category order by revenue) as Ranks

from (

SELECT 
    pizza_types.category as category ,
    pizza_types.name as nam,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types 
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category , pizza_types.name ) as tabl1 ) as tabl2
where Ranks <= 3 ;