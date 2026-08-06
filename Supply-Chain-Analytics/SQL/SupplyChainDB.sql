-- Created by: Shehnaz Fatima 
-- Project Name: Supply Chain Management Analytics 

create database SupplyChainDB;
use Supplychaindb;

select * from product;
select * from supplier;
select * from warehouse;
select * from customer;
select * from inventory;
select * from orders;

/*-------------------------KPI Analysis--------------------------------*/
-- Total Orders
select concat(round(count(distinct order_id)/1000,0), " K") as Total_Orders from orders; 

-- Total Sales Revenue
select concat(round(sum(revenue)/1000000,2), " M") as Total_Sales_Revenue from orders;

-- On-Time Delivery
select count(Order_ID) as On_Time_Orders from orders
where Delivery_Status="On-time";

select concat(round(sum(case when delivery_status="On-Time" then 1 else 0 end)*100/count(*),2), " %") as On_Time_Delivery
from orders;

-- Fill Rate %
select concat(round(avg(fill_rate_pct),2), " %") as Fill_Rate from orders;

-- Stock on Hand
select concat(round(sum(stock_on_hand)/1000000,2), " M") as Stock_on_Hand from inventory;  

-- 1. Orders by Ship Mode		
select ship_mode, count(order_id) as Orders from orders
group by 1
order by 2 desc;

-- 2. Top 5 Cities by Revenue			
select a.customer_city as Cities, concat(round(sum(b.revenue)/1000000,2), " M") as Revenue from customer as a join orders as b
on a.customer_id=b.customer_id
group by Customer_City
order by sum(b.revenue) desc
limit 5;

-- 3. Average Lead Time by Ship Mode		
select ship_mode, round(avg(lead_time_days),1) as Average_Lead_Time from orders
group by 1
order by 2 desc;

-- 4. Orders by Region		
select a.customer_region as Region, count(b.order_id) as Number_of_Orders
from customer as a join orders as b
on a.Customer_ID=b.Customer_ID
group by 1
order by 2 desc;
		
-- 5. Forecast vs Actual Demand by Category		
select a.category, concat(round(sum(b.units_shipped)/1000,1), " K") as Forecast_Demand,
concat(round(sum(b.units_received)/1000,1), " K") as Actual_Demand 
from product as a join inventory as b
on a.product_id=b.product_id
group by 1
order by 2 desc;
		
-- 6. Ordered vs Shipped Quantity by Category		
select a.category, concat(round(sum(b.order_quantity)/1000,2), " K") as Ordered_Quantity, 
concat(round(sum(b.shipped_quantity)/1000,2), " K") as Shipped_Quantity
from product as a join orders as b
on a.Product_ID=b.Product_ID
group by 1
order by sum(b.order_quantity) desc;

-- 7. Revenue by Category
select a.category, concat(round(sum(b.revenue)/1000000,2), " M") as Revenue
from product as a join orders as b
on a.Product_ID=b.Product_ID
group by 1
order by sum(b.Revenue) desc;

/*-------------------------END------------------------------------*/