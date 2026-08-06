/*------Created by Shehnaz Fatima---------*/
-- Domain: E-Commerce
-- Project Name: Olist Store Analysis
-- Dataset: Total 9 files


create database p1281ecommerceanalyticsdb;
use p1281ecommerceanalyticsdb;

create table customers (
customer_id varchar(32) primary key,
customer_unique_id varchar(32),
customer_zip_code_prefix int,
customer_city varchar(100),
customer_state char(2)
);

-- null
create table orders (
order_id	varchar(32) primary key,
customer_id	varchar(32), foreign key (customer_id) references customers(customer_id),
order_status	varchar(20),
order_purchase_timestamp	datetime,
order_approved_at	datetime,   -- null
order_delivered_carrier_date	datetime,   -- null
order_delivered_customer_date	datetime,    -- null
order_estimated_delivery_date datetime
);

create table product_category_name_translation (
product_category_name	varchar(64) primary key,
product_category_name_english varchar(64)
);

-- null
create table products (
product_id	varchar(32) primary key,
product_category_name	varchar(64), 
-- foreign key (product_category_name) references product_category_name_translation(product_category_name),  -- null
product_name_lenght	int,   -- null
product_description_lenght	int,  -- null
product_photos_qty	int, -- null
product_weight_g	int, -- null
product_length_cm	int, -- null
product_height_cm	int, -- null
product_width_cm int   -- null
);

create table sellers (
seller_id	varchar(32) primary key,
seller_zip_code_prefix	int,
seller_city	varchar(100),
seller_state char(2)
);

create table order_items (
order_id varchar(32), foreign key (order_id) references orders(order_id),
order_item_id int,
product_id varchar(32), foreign key (product_id) references products(product_id),
seller_id varchar(32), foreign key (seller_id) references sellers(seller_id),
shipping_limit_date datetime,
price	decimal(8,2), 
freight_value decimal(8,2)
);

create table order_payments (
order_id varchar(32), foreign key (order_id) references orders(order_id),
payment_sequential	int,
payment_type	varchar(20),
payment_installments	int,
payment_value decimal(10,2)
);

create table order_reviews (
review_id	varchar(32),
order_id	varchar(32), foreign key (order_id) references orders(order_id),
review_score	tinyint,
review_creation_date	datetime,
review_answer_timestamp datetime
);

create table geolocation (
geolocation_zip_code_prefix int,
geolocation_lat decimal(10,8),
geolocation_lng decimal(11,8),
geolocation_city varchar(100),
geolocation_state char(2)
);

show tables;
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers.csv"
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders.csv"
INTO TABLE orders
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, order_purchase_timestamp, 
@order_approved_at, @order_delivered_carrier_date, @order_delivered_customer_date, 
order_estimated_delivery_date)
set
order_approved_at = nullif(@order_approved_at, ''),
order_delivered_carrier_date = nullif(@order_delivered_carrier_date, ''), 
order_delivered_customer_date = nullif(@order_delivered_customer_date, '') ;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_product_category_name.csv"
INTO TABLE product_category_name_translation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products.csv"
INTO TABLE products
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, 
@product_category_name, @product_name_lenght, @product_description_lenght, @product_photos_qty, 
@product_weight_g, @product_length_cm, @product_height_cm, @product_width_cm)
set
product_category_name = nullif(@product_category_name, ''),
product_name_lenght = nullif(@product_name_lenght, ''),  
product_description_lenght = nullif(@product_description_lenght, ''), 
product_photos_qty = nullif(@product_photos_qty, ''),
product_weight_g = nullif(@product_weight_g, ''),
product_length_cm = nullif(@product_length_cm, ''),
product_height_cm = nullif(@product_height_cm, ''),
product_width_cm = nullif(@product_width_cm, '');

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_sellers.csv"
INTO TABLE sellers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items.csv"
INTO TABLE order_items
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments.csv"
INTO TABLE order_payments
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- loaded with warning
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_reviews.csv"
INTO TABLE order_reviews
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- loaded with warning
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_geolocation.csv"
INTO TABLE geolocation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from customers limit 10;
select * from orders limit 10;
select * from products limit 10;
select * from order_reviews limit 10;
select * from order_payments limit 10;
select * from order_items limit 10;
select * from sellers limit 10;
select * from product_category_name_translation limit 10;
select * from geolocation limit 10;

/*---------------------------------------KPIs------------------------------------------*/
/*------1. Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics-------------*/
select 
case when DAYOFWEEK(o.order_purchase_timestamp) in (1,7) then 'Weekend'
	else 'Weekday'
    end as day_type,
count(distinct o.order_id) as total_orders,
round(sum(p.payment_value),2) as total_payment,
round(avg(p.payment_value),2) as avg_payment,
concat(round((sum(p.payment_value)*100) / (select sum(payment_value) from order_payments),2), ' %') as `% Contribution`
from orders as o join order_payments as p
on o.order_id = p.order_id
group by day_type;

/*-------2. Number of Orders with review score 5 and payment type as credit card--------*/
select count(distinct o.order_id) as total_orders 
from orders as o join order_reviews as r
on o.order_id = r.order_id
join order_payments as p
on o.order_id = p.order_id
where r.review_score = 5 and p.payment_type = 'credit_card';

/*-------3. Average number of days taken for order_delivered_customer_date for pet_shop---*/
select round(avg(datediff(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) as avg_delivery_days
from orders as o join order_items as oi
on o.order_id = oi.order_id
join products p
on oi.product_id = p.product_id
where p.product_category_name = 'pet_shop' and o.order_delivered_customer_date is not null;

/*-------4. Average price and payment values from customers of sao paulo city-------------*/
select round(avg(oi.price),2) as avg_price,
round(avg(op.payment_value),2) as avg_payment_value
from customers as c join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
join order_payments as op
on o.order_id = op.order_id
where upper(c.customer_city) = 'SAO PAULO';

/*-----5. Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores-----*/
select r.review_score, 
round(avg(datediff(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) as avg_shipping_days
from orders as o join order_reviews as r
on o.order_id = r.order_id
where o.order_delivered_customer_date is not null
group by r.review_score
order by r.review_score;

/*--------------------------------END---------------------------------*/