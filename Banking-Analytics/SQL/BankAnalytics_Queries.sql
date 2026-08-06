/*--------------Created by Shehnaz------------------------------------*/
/*--------------Finance Loan Performance & Risk Analysis--------------*/

create database P1231BankAnalyticsDB;
show databases;
use P1231BankAnalyticsDB;

drop table if exists finance_1;
    
create table Finance_1 (
	id int primary key,
	member_id int,
	loan_amnt int,
	funded_amnt int,
	funded_amnt_inv float,
	`term (in Months)` int,
	int_rate float,
	installment float,
	grade char(1),
	sub_grade char(2),
	home_ownership varchar(10),
	annual_inc float,
	verification_status varchar(20),
	issue_d date,
	loan_status varchar(20),
	purpose varchar(30),
	addr_state char(2),
	dti float,
	Default_rate_Flag tinyint
	);
    
show tables;
desc Finance_1;

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Finance_1.csv"
INTO TABLE Finance_1
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from Finance_1;
select * from Finance_1 limit 10;

 drop table if exists finance_2;
 
create table Finance_2 (
	id int, foreign key (id) references Finance_1(id),
	delinq_2yrs int,
	earliest_cr_line date,
	inq_last_6mths int,
	open_acc int,
	pub_rec int,
	revol_bal float,
	total_acc int,
	out_prncp int,
	out_prncp_inv int,
	total_pymnt float,
	total_pymnt_inv float,
	total_rec_prncp float,
	total_rec_int float,
	total_rec_late_fee float,
	recoveries float,
	collection_recovery_fee float,
	last_pymnt_d date,
	last_pymnt_amnt float
    );

desc Finance_2;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Finance_2.csv"
INTO TABLE Finance_2
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from Finance_2;

/*---------------KPIs-----------------------*/
-- Total Loan Amount
select sum(loan_amnt) from finance_1;
select concat(round(sum(loan_amnt)/1000000,2), " M") as total_loan from finance_1;

-- Total Payment
select sum(total_pymnt) from finance_2;
select concat(round(sum(total_pymnt)/1000000,2), " M") as total_payment from finance_2;

-- Average Interest Rate
select avg(int_rate) from finance_1;
select concat(round(avg(int_rate),2), " %") as average_interest_rate from finance_1;

-- Total No. of Loans
select count(*) from finance_1;
select count(a.id) from finance_1 as a join finance_2 as b
on a.id=b.id; 

-- Default Rate (Risk Analysis)
select concat(round(100*(sum(default_rate_flag)/count(*)),2), " %") as default_rate from finance_1;


-- Merge Finance_1 and Finance_2 and create a View FinanceData
drop view if exists financedata;

create view FinanceData as 
select a.id, a.loan_amnt, a.int_rate, a.grade, a.sub_grade, a.home_ownership, a.verification_status,
		a.issue_d, a.loan_status, a.purpose, a.addr_state, a.dti, a.default_rate_flag,
		b.revol_bal, b.total_pymnt, b.total_rec_prncp, b.total_rec_int, b.last_pymnt_d, b.last_pymnt_amnt
from finance_1 as a join finance_2 as b
on a.id=b.id;


/*------------------1.	Year wise loan amount Stats-------------------*/
select year(issue_d) as Year, 
round(sum(loan_amnt)/1000000,2) as `Total Loan Amount (in millions)`, 
round(avg(loan_amnt)/1000,2) as  `Average Loan (in thousands)`,
count(*) as `Total No. of Loans`
from financedata 
group by 1
order by 1;


/*-------------2.	Grade and sub grade wise revol_bal-------------------*/
-- using View
select grade, sub_grade, round(sum(revol_bal)/1000000,2) as `Revolving Balance (in millions)` from financedata
group by 1,2
order by 1,2;

-- Joins
select a.grade, a.sub_grade, sum(b.revol_bal) as total_revolving_balance
from finance_1 as a join finance_2 as b
on a.id=b.id
group by 1,2
order by 1,2;


/*-------------3.	Total Payment for Verified Status Vs Non Verified Status-------------------*/
-- using View
select verification_status, round(sum(total_pymnt)/1000000,2) as Total_Payment_in_millions
from financedata
group by 1
having verification_status in ("Verified", "Not Verified");

-- Joins
select a.verification_status, concat(round(sum(b.total_pymnt)/1000000,2), " M") as Total_Payment
from finance_1 as a join finance_2 as b
on a.id=b.id
group by 1
having verification_status in ("Verified", "Not Verified");


/*-------------4.	State-wise and Month-wise loan status-------------------*/
-- Seasonality analysis
select addr_state as State, monthname(issue_d) as Month, loan_status, 
count(*) as Total_Loans,
round(sum(loan_amnt)/1000,2) as total_loan_amount_in_thousands
from finance_1
group by 1,2,3
order by 5 desc;

-- Trend analysis
select addr_state as State, date_format(issue_d, "%Y-%m") as Month, loan_status, 
count(*) as Total_Loans,
round(sum(loan_amnt)/1000,2) as total_loan_amount_in_thousands
from finance_1
group by 1,2,3
order by 2,5 desc;


/*-------------5.	Home ownership Vs last payment date stats-------------------*/
-- using View
select home_ownership, date_format(last_pymnt_d, "%Y-%m") as last_payment_month,
count(*) as total_loans,
round(sum(last_pymnt_amnt),2) as total_payment,
round(avg(last_pymnt_amnt),2) as average_payment
from financedata
group by 1,2
order by 2;

-- Joins
select a.home_ownership, date_format(b.last_pymnt_d, "%Y-%m") as last_payment_month,
count(*) as total_loans,
round(sum(b.last_pymnt_amnt),2) as total_payment,
round(avg(b.last_pymnt_amnt),2) as average_payment
from finance_1 as a join finance_2 as b
on a.id=b.id
group by 1,2
order by 2;

/*---------------------------End-----------------------------------*/