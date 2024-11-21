-- Create the database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Create a table
CREATE TABLE IF NOT EXISTS walmartSales.sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- ********************************************************************************************** --
-- ----------------------------------Feature Engineering ---------------------------------------- --
-- ********************************************************************************************** --

-- Add the `time_of_day` column
SELECT time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM walmartsales.sales;


ALTER TABLE walmartsales.sales ADD COLUMN time_of_day VARCHAR(20);

-- For this to work turn off safe mode for update
-- Edit > Preferences > SQL Edito > scroll down and toggle safe mode
-- Reconnect to MySQL: Query > Reconnect to server
UPDATE walmartsales.sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);


-- Add the `day_name` column that contains extracted days of the week
SELECT date,
	DAYNAME(date) AS day_name
FROM walmartsales.sales;

ALTER TABLE walmartsales.sales ADD COLUMN day_name VARCHAR(10);

UPDATE walmartsales.sales
SET day_name = DAYNAME(date);


-- Add month_name column that contains extracted months of the year
SELECT date,
	MONTHNAME(date) AS month_name
FROM walmartsales.sales;

ALTER TABLE walmartsales.sales ADD COLUMN month_name VARCHAR(10);

UPDATE walmartsales.sales
SET month_name = MONTHNAME(date);


-- ********************************************************************************************** --
-- ----------------------------------Exploratory Data Analysis ---------------------------------- --
-- ********************************************************************************************** --

-- GENERIC QUESTIONS

		-- 1. How many unique cities does the data have?
		SELECT DISTINCT city
		FROM walmartsales.sales;

		-- 2. In which city is each branch?
		SELECT DISTINCT branch
		FROM walmartsales.sales;

		SELECT DISTINCT city, branch
		FROM walmartsales.sales;

-- PRODUCT QUESTIONS
		
        -- 1. How many unique product lines does the data have?
		SELECT DISTINCT product_line
        FROM walmartsales.sales;
        
        -- 2.What is the most common payment method?
        SELECT payment, COUNT(payment) AS count
        FROM walmartsales.sales
        GROUP BY payment;
        
        -- 3. What is the most selling product line?
		SELECT product_line, COUNT(product_line) AS count
        FROM walmartsales.sales
        GROUP BY product_line
        ORDER BY count DESC;

		-- 4. What is the total revenue by month?
		SELECT month_name AS month,
			SUM(total) AS total_revenue
        FROM walmartsales.sales
        GROUP BY month_name
        ORDER BY total_revenue DESC;
        
        -- 5. What month had the largest COGS?
        SELECT month_name AS month,
			SUM(cogs) AS cogs
        FROM walmartsales.sales
        GROUP BY month_name
        ORDER BY cogs DESC;
        
        -- 6. What product line had the largest revenue?
		SELECT product_line,
			SUM(total) AS total_revenue
		FROM walmartsales.sales
        GROUP BY product_line
        ORDER BY total_revenue DESC;
        
        -- 7. What is the city with the largest revenue?
		SELECT city,
			SUM(total) as total_revenue
        FROM walmartsales.sales
        GROUP BY city
        ORDER BY total_revenue;
        
        -- 8. What product line had the largest VAT?
		SELECT product_line,
			AVG(tax_pct) AS ave_tax
        FROM walmartsales.sales
        GROUP BY product_line
        ORDER BY ave_tax DESC;
        
        -- 9. Which branch sold more products than average product sold?
		SELECT branch, 
			SUM(quantity) AS sum_qty
        FROM walmartsales.sales
        GROUP BY branch
        HAVING sum_qty > (SELECT AVG(quantity) FROM walmartsales.sales);
        
        -- 10. What is the most common product line by gender?
        SELECT gender,
			product_line,
            COUNT(product_line) AS count
        FROM walmartsales.sales
        GROUP BY gender, product_line
        ORDER BY count DESC;
        
        -- 11. What is the average rating of each product line?
		SELECT  product_line, rating,
			ROUND(AVG(rating), 2) AS ave_rating
        FROM walmartsales.sales
        GROUP BY rating, product_line
        ORDER BY ave_rating DESC;
        
        -- 12. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
		SELECT product_line, 
			CASE
				WHEN AVG(quantity) > 6 THEN "Good"
                ELSE "Bad"
            END AS remark
        FROM walmartsales.sales
        GROUP BY product_line;
        
-- SALES QUESTIONS

		-- 1. Number of sales made in each time of the day per weekday
        SELECT time_of_day,
			COUNT(*) AS total_sales
        FROM walmartsales.sales
        WHERE day_name = "Sunday"
        GROUP BY time_of_day
        ORDER BY total_sales;
        
        -- 2.Which of the customer types brings the most revenue?
		SELECT customer_type,
			ROUND(SUM(total), 2) AS total_rev
        FROM walmartsales.sales
        GROUP BY customer_type
        ORDER BY total_rev DESC;
        
        -- 3. Which city has the largest tax percent/ VAT (Value Added Tax)?
		SELECT city,
			ROUND(AVG(tax_pct)) AS VAT
        FROM walmartsales.sales
        GROUP BY city
        ORDER BY VAT DESC;
        
        -- 4. Which customer type pays the most in VAT?
        SELECT invoice_id, gender,
			ROUND(AVG(tax_pct)) AS VAT
        FROM walmartsales.sales
        GROUP BY invoice_id, gender
        ORDER BY VAT DESC;
	
    -- CUSTOMER QUESTIONS
    
		-- 1. How many unique customer types does the data have?
		SELECT DISTINCT customer_type
        FROM walmartsales.sales;
        
        -- 2. How many unique payment methods does the data have?
		SELECT DISTINCT payment
        FROM walmartsales.sales;
        
        -- 3. What is the most common customer type?
		SELECT customer_type, 
			COUNT(customer_type) AS count
        FROM walmartsales.sales
        GROUP BY customer_type
        ORDER BY count DESC;
        
        -- 4. What is the gender of most of the customers?
		SELECT gender,
			COUNT(*) AS count
        FROM walmartsales.sales
        GROUP BY gender;
        
        -- 5. What is the gender distribution per branch?
		SELECT branch, gender,
			COUNT(*) AS count
        FROM walmartsales.sales
        GROUP BY branch, gender
        ORDER BY count DESC;
        
        -- 6. Which time of the day do customers give most ratings?
		SELECT time_of_day,
			ROUND(AVG(rating), 2) AS ave_rating
        FROM walmartsales.sales
        GROUP BY time_of_day
        ORDER BY ave_rating DESC;
        
        -- 7. Which day fo the week has the best avg ratings?
		SELECT day_name,
			ROUND(AVG(rating), 2) AS ave_rating
        FROM walmartsales.sales
        GROUP BY day_name
        ORDER BY ave_rating DESC;

        
        
		
        


 



