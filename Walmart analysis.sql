CREATE DATABASE IF NOT EXISTS SalesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY, 
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30),
    Customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(10,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1)
);

---------------------------------------------------------------------------------------------------------

--------------------------------- Feature Engineering ----------------------------------------------------

--- Time of the day

SELECT 
	time,
    (CASE
		WHEN time between "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time between "12:00:01" and "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END) AS time_of_day
FROM Sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales 
SET time_of_day = (
	CASE
		WHEN time between "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time between "12:00:01" and "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
); 

--- day_name

SELECT 
	date,dayname(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);

UPDATE sales 
SET day_name = dayname(date); 

--- month_name

SELECT
	date, monthname(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month VARCHAR(20);

UPDATE sales 
SET month = monthname(date); 


---------------------------------------------------------------------------------------------------
--------------------------------- EXPLORATORY ANALYSIS --------------------------------------------

# How many unique cities does the data have ?

select distinct city
from sales;

-- There are 3 cities. They are Yangon,Naypyitaw,Mandalay

# In Which city is each branch ?

select  city, branch
from sales
group by city;

--- The branch A is in Yangon, C is in Naypyitaw and B is in Mandalay

# Product Analysis

# 1. How many unique product lines does that data have ?

select count(distinct product_line)
from sales;

select distinct product_line
from sales;

--- There are 6 products. They are Food and beverages Health and beauty Sports and travel Fashion accessories Home and lifestyle
--- and Electronic accessories

# What is the most common payment method ?

SELECT payment_method, COUNT(payment_method) as payment_count
FROM sales
GROUP BY payment_method
ORDER BY payment_count DESC;

--- Cash is the most used payment method followed by Ewallet

# 4. What is the most selling product line ?

SELECT
	SUM(quantity) as qty,
    product_line
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

--- Electronic accessories are the most sold product line

# 5. What is the total revenue by month ?

SELECT
	month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month 
ORDER BY total_revenue;

--- February has the highest total revenue.

# What month had the largest COGS ?
SELECT
	month,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month 
ORDER BY cogs;

--- Febraury

# 6. What product line had the largest revenue ?

SELECT
	product_line,
	SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

--- Food and beverages has the highest revenue

# 7. What is the city with the larget revenue ?

select city, sum(total) as total_revenue
from sales
group by city;

--- Yangon has the highest revenue

# 8. What product line had the largest VAT ?

select product_line,AVG(VAT) as avg_vt
from sales
group by product_line
order by avg_vt desc;

--- Home and lifestyle has highest vat

# 9. Fetch each product line and add a column to those product line showing "Good", "Bad".
# Good if its greater than average sales

SELECT product_line, ROUND(AVG(total),2) AS avg_sales,
(CASE
WHEN AVG(total) > (SELECT AVG(total) FROM sales) THEN "Good"
ELSE "Bad"
END)
AS Remarks
FROM sales
GROUP BY product_line;

# 10. Which branch sold more products than average product sold?

select branch, sum(quantity) as products_sold
from sales
group by branch
having avg(quantity) > (select avg(quantity) from sales);

-- C has more products sold than average

# 11. What is the most common product line by gender

select product_line,Gender,sum(quantity) as sum
from sales
group by Gender
order by sum desc;

--- Female = Health and beauty while Male Food and beverages

# 12. What is the average rating of each product line

select product_line , avg(rating)
from sales
group by product_line;

--------------------------------------------------------------------------------------------------
--- Sales

# 1. Number of sales made in each time of the day per weekday

select  time_of_day,count(*)
from sales
group by time_of_day
order by count(*);

# 2. Which of the customer types brings the most revenue ?

select customer_type, sum(total)
from sales
group by customer_type;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;

---------------------------------------------------------------------------------------------------
----------- Customers

# Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;


# What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

# What is the gender distribution per branch?
SELECT
	branch, gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY  branch
ORDER BY gender_cnt DESC;


# Gender per branch is more or less the same hence, I don't think has
# an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


# Which time of the day do customers give most ratings per branch?

SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;


# Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?

# Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;







