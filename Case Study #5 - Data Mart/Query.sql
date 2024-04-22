/* --------------------
   Case Study Questions
   --------------------*/

-- A. Data Cleansing Steps --
-- In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
	-- Convert the week_date to a DATE format
	-- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
	-- Add a month_number with the calendar month for each week_date value as the 3rd column
	-- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
	-- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
		-- segment	age_band
		-- 1	Young Adults
		-- 2	Middle Aged
		-- 3 or 4	Retirees
	-- Add a new demographic column using the following mapping for the first letter in the segment values:	
		-- segment	demographic
		-- C	Couples
		-- F	Families
	-- Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
	-- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

DROP TABLE IF EXISTS clean_weekly_sales;
CREATE TABLE clean_weekly_sales
SELECT
	STR_TO_DATE(week_date, '%d/%m/%y') AS week_date,
    WEEK(STR_TO_DATE(week_date, '%d/%m/%y')) AS week_number,
    MONTH(STR_TO_DATE(week_date, '%d/%m/%y')) AS month_number,
    YEAR(STR_TO_DATE(week_date, '%d/%m/%y')) AS calendar_year,
    region, 
    platform, 
    CASE
		WHEN segment = 'null' THEN 'unknown'
        ELSE segment
    END AS segment,
    CASE
		WHEN segment LIKE '%1' THEN 'Young Adults'
        WHEN segment LIKE '%2' THEN 'Middle Aged'
        WHEN segment LIKE '%3' OR segment LIKE '%4' THEN 'Retirees'
        ELSE 'unknown'
    END AS age_band,
    CASE
		WHEN segment LIKE 'C%' THEN 'Couples'
        WHEN segment LIKE 'F%' THEN 'Families'
		ELSE 'unknown'
    END AS demographic,
    customer_type,
    transactions,
    sales,
    ROUND(sales/transactions, 2) AS avg_transaction
FROM weekly_sales;
SELECT * FROM clean_weekly_sales;

-- B. Data Exploration --
-- 1. What day of the week is used for each week_date value?
SELECT DISTINCT DAYNAME(week_date) AS week_day
FROM clean_weekly_sales;

-- 2. What range of week numbers are missing from the dataset?
WITH RECURSIVE week_numbers_cte(week_number) AS(
	SELECT 1
    UNION
    SELECT week_number + 1
	FROM week_numbers_cte
    WHERE week_number + 1 <= 52)
SELECT GROUP_CONCAT(week_number SEPARATOR ' ,') AS week_number_missing
FROM week_numbers_cte
WHERE week_number NOT IN (SELECT week_number FROM clean_weekly_sales);

-- 3. How many total transactions were there for each year in the dataset?
SELECT 
	calendar_year,
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;

-- 4. What is the total sales for each region for each month?
SELECT
	region,
    month_number,
	SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;

-- 5. What is the total count of transactions for each platform
SELECT
	platform,
    SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
SELECT
	month_number,
    ROUND(SUM(CASE WHEN platform = 'Retail' THEN sales END)/SUM(sales) * 100, 2) AS retail_percent,
    ROUND(SUM(CASE WHEN platform = 'Shopify' THEN sales END)/SUM(sales) * 100, 2) AS shopify_percent
FROM clean_weekly_sales
GROUP BY month_number
ORDER BY month_number;

-- 7. What is the percentage of sales by demographic for each year in the dataset?
SELECT
	calendar_year,
    ROUND(SUM(CASE WHEN demographic = 'Couples' THEN sales END)/SUM(sales) * 100, 2) AS couples_percent,
    ROUND(SUM(CASE WHEN demographic = 'Families' THEN sales END)/SUM(sales) * 100, 2) AS families_percent,
    ROUND(SUM(CASE WHEN demographic = 'unknown' THEN sales END)/SUM(sales) * 100, 2) AS unknown_percent
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;

-- 8. Which age_band and demographic values contribute the most to Retail sales?
SELECT
	age_band,
    demographic,
    SUM(sales) AS total_sales,
    ROUND(SUM(sales)/ SUM(SUM(sales)) OVER() * 100, 2) AS sales_percent
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_sales DESC
LIMIT 2;

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT
	calendar_year,
    platform,
    ROUND(SUM(sales)/SUM(transactions), 2) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year;

-- C. Before & After Analysis --
-- This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
-- Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.
-- We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before
-- Using this analysis approach - answer the following questions:

-- 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 4 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 4 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte;

-- 2. What about the entire 12 weeks before and after?
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte;

-- 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_number < WEEK('2020-06-15') AND week_number >= WEEK('2020-06-15') - 12 THEN 'before'
			WHEN week_number >= WEEK('2020-06-15') AND week_number < WEEK('2020-06-15') + 12 THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY calendar_year
ORDER BY calendar_year;

-- D. Bonus Question
-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
	-- region
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	region,
    calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY region
ORDER BY percent_diff;

	-- platform
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	platform,
    calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY platform
ORDER BY percent_diff;

	-- age_band
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	age_band,
    calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY age_band
ORDER BY percent_diff;

	-- demographic
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	demographic,
    calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY demographic
ORDER BY percent_diff;
    
	-- customer_type
WITH cte AS(
	SELECT *,
		CASE
			WHEN week_date < '2020-06-15' AND week_date >= SUBDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'before'
			WHEN week_date >= '2020-06-15' AND week_date < ADDDATE('2020-06-15', INTERVAL 12 WEEK) THEN 'after'
		END AS period
	FROM clean_weekly_sales)
SELECT
	customer_type,
    calendar_year,
	SUM(CASE WHEN period = 'before' THEN sales END) AS before_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) AS after_sales,
    SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END) AS value_diff,
	ROUND((SUM(CASE WHEN period = 'after' THEN sales END) - SUM(CASE WHEN period = 'before' THEN sales END))/SUM(CASE WHEN period = 'before' THEN sales END)*100, 2) AS percent_diff
FROM cte
GROUP BY customer_type
ORDER BY percent_diff;