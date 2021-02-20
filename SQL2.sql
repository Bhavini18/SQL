create database miniproject_2;
use miniproject_2;

#1 Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

CREATE TABLE combined_table AS
SELECT 
	mf.Ord_id, mf.Prod_id, mf.Ship_id, mf.Cust_id, Sales, 
    Discount, Order_Quantity, Profit, Shipping_Cost, Product_Base_Margin, 
    cd.Customer_Name, cd.Province, cd.Region, cd.Customer_Segment, 
    orders.Order_Date, orders.Order_Priority, prod.Product_Category, 
    prod.Product_Sub_Category, orders.Order_ID, sd.Ship_Mode, sd.Ship_Date
FROM
    market_fact AS mf
INNER JOIN
	cust_dimen AS cd ON mf.Cust_id = cd.Cust_id
INNER JOIN
	orders_dimen AS orders ON orders.Ord_id = mf.Ord_id
INNER JOIN
	prod_dimen AS prod ON prod.Prod_id = mf.Prod_id
INNER JOIN
	shipping_dimen AS sd ON sd.Ship_id = mf.Ship_id;
    
    
#2 Find the top 3 customers who have the maximum number of orders

select * from cust_dimen where Cust_id in(
select Cust_id from market_fact group by Cust_id order by count(Ord_id) desc)  limit 3;


#3 Create a new column DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.

select od.Order_ID, str_to_date(sd.Ship_Date, '%Y-%m-%d') ship_date, str_to_date(od.Order_Date, '%d-%m-%Y') order_date, 
datediff(str_to_date(sd.Ship_Date, '%Y-%m-%d'), str_to_date(od.Order_Date, '%d-%m-%Y')) diff 
from orders_dimen od join shipping_dimen sd on od.Order_ID = sd.Order_ID order by diff desc;

#4Find the customer whose order took the maximum time to get delivered.

select * from cust_dimen where Cust_id = (
select Cust_id from market_fact where Ord_id = ( 
with new1 as (
select od.Order_ID, 
datediff(str_to_date(sd.Ship_Date, '%Y-%m-%d'), str_to_date(od.Order_Date, '%d-%m-%Y')) diff from orders_dimen od
join shipping_dimen sd on od.Order_ID = sd.Order_ID order by diff desc limit 1)
select od1.Ord_id from orders_dimen od1 join new1 on od1.Order_ID = new1.Order_ID
where od.Order_ID = new1.Order_ID));

#5  Retrieve total sales made by each product from the data (use Windows function)
select distinct Prod_id, sum(Sales) over(partition by Prod_id ) sales_sum from market_fact order by sales_sum desc;

# 6 Retrieve total profit made from each product from the data (use windows function)
select distinct Prod_id, sum(Profit) over(partition by Prod_id) profit from market_fact order by profit desc;

#7a. Count the total number of unique customers in January. and how many of them came back every month over the entire year in 2011
SELECT distinct Year(order_date), Month(order_date), 
count(cust_id) OVER (PARTITION BY month(order_date) order by month(order_date)) AS total
FROM combined_table 
WHERE year(order_date)=2011 AND cust_id 
IN (SELECT DISTINCT cust_id
	FROM combined_table
	WHERE month(order_date)=1
	AND year(order_date)=2011);

# 8 Retrieve month-by-month customer retention rate since the start of the business.(using views)

select * from market_fact;
select * from orders_dimen;

with new2 as (
select distinct mf.Cust_id, 
month(str_to_date(od.Order_Date, '%Y-%m-%d')) s,
count(Cust_id) over(partition by mf.Cust_id) r
from orders_dimen od join 
market_fact mf on od.Ord_id = mf.Ord_id),
cte2 as (
select new2.s, new2.cust_id,
lag(s, 1) over(partition by new2.cust_id) as prev_month
from new2 
order by s asc)
select  cte2.s,
sum(case when prev_month <2 then 1 else null end) as irregular, 
sum(case when isnull(prev_month) then 1 else null end) as churned,
sum(case when prev_month > 1  then 1 else null end) as retained
from cte2 group by cte2.s;


