use employee;
--
select * from pizzas limit 1;
select * from pizza_types limit 1;
select * from orders limit 1;
select * from order_details limit 1;
-- Data Cleaning Step
alter table order_details add total float;
update order_details as o
join pizzas as p
on o.pizza_id=p.pizza_id 
set total= p.price*quantity;

-- top 3 most ordered pizza types based on revenue for each pizza category
with cte as(
select category,p1.pizza_type_id,round(sum(quantity*price),2) as rev,
row_number()over(partition by category order by sum(quantity*price) desc) as df
from orders as o 
join order_details as o1
on o.order_id=o1.order_id
join pizzas as p
on p.pizza_id=o1.pizza_id
join pizza_types as p1
on p.pizza_type_id=p1.pizza_type_id
group by category,p1.pizza_type_id)
select category,pizza_type_id,rev
from cte  where df<=3 order by rev desc;
--
select category,pizza_type_id,rev from 
(select category,p.pizza_type_id,cast(sum(quantity*price) as decimal(10,2)) as rev,
row_number()over(partition by category order by sum(price*quantity) desc) as df
from orders as o
join order_details as o1
on o.order_id=o1.order_id 
join pizzas as p
on o1.pizza_id=p.pizza_id
join pizza_types as p1
on p.pizza_type_id=p1.pizza_type_id
group by category,pizza_type_id)rudra where df<=3 order by rev desc;

-- percentage contribution of each pizza type to total revenue
select p.pizza_type_id,round(sum(price*quantity)*100/(select sum(quantity*price)
from order_details as o
join pizzas as p 
on o.pizza_id=p.pizza_id),2) as pct
from order_details as o
join pizzas as p
on o.pizza_id=p.pizza_id
group by p.pizza_type_id order by pct desc;

-- Analyze the cumulative revenue generated over time
select*,sum(total)over(partition by hour(time) order by total 
rows between unbounded preceding and current row ) as cm_sum
from orders as o
join order_details as o1
on o.order_id=o1.order_id
join pizzas as p
on p.pizza_id=o1.pizza_id;

-- top 3 most ordered pizza types based on revenue
select p.pizza_type_id,round(sum(quantity*price),2) as rev
from order_details as o
join pizzas as p
on o.pizza_id=p.pizza_id
group by p.pizza_type_id order by rev desc limit 3 ;

-- calculate the average number of pizzas ordered per day
select dayname(date) as day_name,sum(quantity) as total_order
from orders as o 
join order_details as o1
on o.order_id=o1.order_id
group by dayname(date) order by total_order desc;

-- find the category-wise distribution of pizzas
select category,round(sum(quantity*price)*100/(select sum(quantity*price)
from order_details as o
join pizzas as p 
on o.pizza_id=p.pizza_id),2) as pct
from order_details as o
join pizzas as p
on p.pizza_id=o.pizza_id
join pizza_types as p1
on p.pizza_type_id=p1.pizza_type_id
group by category order by pct desc;

-- Determine the distribution of orders by hour of the day
select hour(time) as hour,sum(quantity) as total_order
from orders as o
join order_details as o1
on o.order_id=o1.order_id
group by hour(time) order by total_order desc;

-- find the total quantity of each pizza category ordered.
select category,sum(quantity) as total
from order_details as o
join pizzas as p
on o.pizza_id=p.pizza_id
join pizza_types as p1
 on p1.pizza_type_id=p.pizza_type_id
group by category order by total desc;

-- top 5 most ordered pizza types along with their quantities
select p.pizza_type_id,sum(quantity) as total
from order_details as o
join pizzas as p
on o.pizza_id=p.pizza_id
group by p.pizza_type_id order by total desc limit 5;

-- Identify the most common pizza size ordered.
select p.size,sum(quantity) as total
from order_details as o
join pizzas as p
on o.pizza_id=p.pizza_id
group by p.size order by total desc limit 1;

-- Identify the highest-priced pizza
select*from pizzas 
where price=(select max(price) from pizzas);

-- Calculate the total revenue generated from pizza sales
select round(sum(quantity*price),2) as total_rev
from order_details as o
join pizzas as p
on o.pizza_id=p.pizza_id;
--
select round(sum(total),2) as total_rev from order_details;

-- Retrieve the total number of orders placed
select sum(quantity) as total_order
from order_details;

-- Avg order per id
select round(sum(quantity)/(select count(distinct order_id) from order_details),0) as avg_order
from order_details;

