/*------Created by Shehnaz Fatima---------*/
-- Domain: Food & Restaurant Analytics
-- Project Name: Zomato Analytics

-- Database Creation: to store all project-related tables and analysis.  
create database zomatoanalyticsdb;
use zomatoanalyticsdb;

-- Tables Creation and Data Modeling: We designed 4 tables & Relationships were created using Foreign keys.    
create table country (
CountryID int primary key,
Countryname varchar(100)
);

create table currency (
Currency varchar(50) primary key,
`USD Rate` decimal(10,6)
);

create table calendar (
DateKey varchar(10) primary key,
Date date,
Year year,
MonthNum tinyint,
Monthfullname varchar(10),
Quarter char(2),
YearMonth varchar(8),
WeekdayNum tinyint,
WeekdayName varchar(10),
DayOfMonth tinyint,
FinancialMonth char(4),
FinancialQuarter char(4)
);

create table main (
RestaurantID varchar(32) primary key,
RestaurantName varchar(255),
CountryCode	int, foreign key (CountryCode) references country(CountryID),
City varchar(100),
Address text,
Locality varchar(150),
LocalityVerbose text,
Longitude decimal(10,7),
Latitude decimal(10,7),
Cuisines text,
Currency varchar(50), foreign key (Currency) references currency(Currency),
Has_Table_booking varchar(5),
Has_Online_delivery varchar(5),
Is_delivering_now varchar(5),
Switch_to_order_menu varchar(5),
Price_range tinyint,
Votes int,
Average_Cost_for_two int,
Rating decimal(3,2),
Datekey_Opening varchar(10), foreign key (Datekey_Opening) references calendar(DateKey),
Date date
);

-- Data Loading & Data Preparation: 
show tables;
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/country.csv"
INTO TABLE country
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/currency.csv"
INTO TABLE currency
CHARACTER SET latin1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/calendar.csv"
INTO TABLE calendar
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(DateKey, @Date, Year, MonthNum, Monthfullname, Quarter, YearMonth, WeekdayNum,
WeekdayName, DayOfMonth, FinancialMonth, FinancialQuarter)
SET
Date = STR_TO_DATE(@Date,'%d-%m-%Y');

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/main.csv"
INTO TABLE main
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(RestaurantID, RestaurantName, CountryCode, City, Address, Locality, LocalityVerbose, Longitude, Latitude,
@Cuisines, Currency, Has_Table_booking, Has_Online_delivery, Is_delivering_now, Switch_to_order_menu,
Price_range, Votes, Average_Cost_for_two, Rating, Datekey_Opening, @Date)
set
Cuisines = nullif(@Cuisines, ''),
Date = str_to_date(trim(@Date),'%d-%m-%Y');

select * from main limit 10;
select * from main;
select * from country;
select * from currency;
select * from calendar;

/*---------------------------------------KPIs------------------------------------------*/
-- KPI Analysis: 

-- Total Restaurants
select count(distinct RestaurantID) as Total_Restaurants from main;

-- Total Countries
select count(distinct Countryname) as Total_Countries from country;

-- Total Cities
select count(distinct City) as Total_Cities from main;

-- Average Rating
select round(avg(Rating),1) as Average_Rating from main;

-- Top Rated Restaurants (≥ 4.5)
select count(*) as Top_Rated_Restaurants from main where Rating >=4.5;


/*---- 3. Convert the Average cost for 2 column into USD dollars (currently the Average cost for 2 in local currencies)----*/
-- Cost Conversion Analysis: 
create view Avg_Cost_data as
select m.RestaurantID, m.RestaurantName, m.Currency, m.Average_Cost_for_two,
round(m.Average_Cost_for_two * c.`USD Rate`,2) as Avg_Cost_for2_USD,
round((m.Average_Cost_for_two/2) * c.`USD Rate`,2) as Avg_Cost_USD
from main as m join currency as c
on m.Currency = c.Currency;

select * from Avg_Cost_data;


-- **Business Analysis & Insights: 
/*------4.Find the Numbers of Restaurants based on City and Country.-------------*/
-- Restaurant Distribution by City & Country: 
select c.Countryname, m.City, count(distinct m.RestaurantID) as Restaurant_Count
from main as m join country as c
on m.CountryCode = c.CountryID
group by c.Countryname, m.City
order by Restaurant_Count desc;

/*-------5.Numbers of Restaurants opening based on Year, Quarter, Month--------*/
-- Restaurant Opening Trend: 
select year(Date) as Year, quarter(Date) as Quarter, month(Date) as Month, count(*) as Restaurants from main
group by Year, Quarter, Month 
order by Year, Quarter, Month;

/*----------6. Count of Restaurants based on Average Ratings-----------------*/
-- Rating Distribution: 
select case
when Rating <=1 then "Poor"
when Rating <=2 then "Below Average"
when Rating <=3 then "Average"
when Rating <=4 then "Good"
else "Excellent"
end as Rating_Group,
count(*) as Restaurants
from main
group by Rating_Group
order by Restaurants desc;

/*-------7. Create buckets based on Average Price of reasonable size and find out how many restaurants falls in each buckets----*/
-- Price Bucket Analysis: 
select case
when Avg_Cost_USD <=10 then "Budget"
when Avg_Cost_USD <=30 then "Affordable"
when Avg_Cost_USD <=60 then "Mid Range"
when Avg_Cost_USD <=100 then "Premium"
else "Luxury"
end as Price_Bucket,
case
when Avg_Cost_USD <=10 then "$0-10"
when Avg_Cost_USD <=30 then "$10-30"
when Avg_Cost_USD <=60 then "$30-60"
when Avg_Cost_USD <=100 then "$60-100"
else ">$100"
end as Price_Bucket_Range,
count(*) as Restaurant_Count
from avg_cost_data 
group by Price_Bucket, Price_Bucket_Range;

/*----------8.Percentage of Restaurants based on "Has_Table_booking"-----------*/
-- Table Booking Analysis: 
select has_table_booking, count(*) as Restaurant_Count,
concat(round(count(*) * 100/ sum(count(*)) over (), 2), " %") as Percentage
from main
group by has_table_booking;

/*----------9.Percentage of Restaurants based on "Has_Online_delivery"-----------*/
-- Online Delivery Analysis: 
select has_online_delivery, count(*) as Restaurant_Count,
concat(round(count(*) * 100/ sum(count(*)) over (), 2), " %") as Percentage
from main
group by has_online_delivery;


-- **Advanced Insights: 
/*----------10. Top 10 Cuisines by Restaurants----------------------------*/
select Cuisines, count(*) as Restaurant_Count
from main
group by Cuisines
Order by Restaurant_Count desc
limit 10;

/*----------11. Locality-wise Restaurant Density----------------------------*/
select Locality, count(*) as Restaurant_Count
from main
group by Locality
order by Restaurant_Count desc
limit 10;

/*----------12. Cost vs Rating----------------------------*/
select round(m.Rating,0) as Rating_Group, concat("$ ",round(avg(a.Avg_Cost_USD),2)) as Average_Cost
from main as m join avg_cost_data as a 
on m.RestaurantID=a.RestaurantID
group by Rating_Group
order by Rating_group;

/*----------13. Restaurant Density by Locality + Avg Rating----------------------------*/
select Locality, count(*) as Restaurants, round(avg(Rating),1) as Average_Rating
from main
group by Locality
order by Restaurants desc;

/*--------------------------------END---------------------------------*/