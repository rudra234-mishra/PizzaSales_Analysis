select top 3*from pizzas
select top 2*from pizza_types
select top 2*from orders
select top 2*from order_details
---
select count(*) from order_details
----
select count(*) from orders

--Data Cleaning step
alter table order_details drop column total;
alter table order_details add total money;
update order_details 
set total= price*quantity
from pizzas as p join order_details as o
on p.pizza_id=o.pizza_id

--top 3 most ordered pizza types based on revenue for each pizza category
select category,pizza_type_id,rev from
(select category,p.pizza_type_id,round(sum(price*quantity),2) as rev,
ROW_NUMBER()over(partition by category order by sum(price*quantity) desc) as df
from orders as o
join order_details as o1
on o.order_id=o1.order_id
join pizzas as p
on p.pizza_id=o1.pizza_id
join pizza_types as p1
on p1.pizza_type_id=p.pizza_type_id
group by category,p.pizza_type_id)rudra
where df<=3 order by rev desc;

--percentage contribution of each pizza type to total revenue
select p.pizza_type_id,round(sum(price*quantity)*100/(select sum(price*quantity) from order_details as o
join pizzas as p 
on p.pizza_id=o.pizza_id),2) as pct
from pizzas as p
join pizza_types as p1
on p.pizza_type_id=p1.pizza_type_id
join order_details as o
on o.pizza_id=p.pizza_id
join orders as o1
on o1.order_id=o.order_id
group by p.pizza_type_id order by pct desc;

--cumulative revenue generated over time
select *,sum(total)over(partition by datename(hour,time) order by total 
rows between unbounded preceding and current row) as cm_sum
from orders as o 
join order_details as o1
on o.order_id=o1.order_id
join pizzas as p
on p.pizza_id=o1.pizza_id

--top 3 most ordered pizza types based on revenue
select  top 3 pizza_type_id,round(sum(price*quantity),2) as rev
from order_details as o
join pizzas as p
on o.pizza_id=p.pizza_id
group by pizza_type_id order by rev desc;

--
select top 3 pizza_type_id,sum(total) as rev
from order_details as o
join pizzas as p
on p.pizza_id=o.pizza_id
group by pizza_type_id order by rev desc;

--calculate the average number of pizzas ordered per day
select datename(weekday,date),sum(quantity) as total
from orders as o
join order_details as o1
on o.order_id=o1.order_id
group by datename(weekday,date) order by total desc;

--find the category-wise distribution of pizzas
select category,sum(quantity) as total_dis
from pizzas as p
join order_details as o
on p.pizza_id=o.pizza_id
join pizza_types as p1
on p1.pizza_type_id=p.pizza_type_id
group by category order by total_dis desc;

--Determine the distribution of orders by hour of the day
select datename(hour,time) as hour,sum(quantity) as total
from orders as o
join order_details as o1
on o.order_id=o1.order_id
group by datename(hour,time) order by total desc;

--top 5 most ordered pizza types along with their quantities.
select top 5  pizza_type_id,sum(quantity) as total_order
from pizzas as p
join order_details as o
on p.pizza_id=o.pizza_id
group by pizza_type_id order by total_order desc;

--Identify the most common pizza size ordered
select top 1 size,sum(quantity) as orders
from pizzas as p
join order_details as o
on p.pizza_id=o.pizza_id
group by size order by orders desc;

--Identify the highest-priced pizza
select*
from pizzas where price=(select max(price) from pizzas)

--Calculate the total revenue generated from pizza sales
select round(sum(quantity*price),2) as total_rev
from pizzas as p 
join order_details as o
on p.pizza_id=o.pizza_id;
--
select round(sum(total),2) from order_details;

---Retrieve the total number of orders placed
select sum(quantity) as total_order from order_details;

--Average order Per id
select sum(quantity)/(select count(distinct order_id) from order_details)
from order_details




