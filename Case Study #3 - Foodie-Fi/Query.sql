/* --------------------
   Case Study Questions
   --------------------*/

-- A. Customer Journey --
-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey
	-- for this and other questions, we will create a temporary table subscriptions_temp to caculate the end_date of each plan
		-- from subscription table we create a cte table that:
			-- inner join plans to get plan_name
			-- create date_diff column to caculate the duration between current plan and previous plan
			-- create previous_plan column by using LAG() window function
		-- create end_date column based on previous_plan and date_diff
DROP TABLE IF EXISTS subscriptions_temp;
CREATE TEMPORARY TABLE subscriptions_temp
WITH cte AS(
	SELECT
		customer_id,
        s.plan_id,
		plan_name,
        price,
		start_date,
		DATEDIFF(start_date, LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date)) AS date_diff,
		CASE
			WHEN plan_name = 'churn' THEN LAG(plan_name) OVER(PARTITION BY customer_id ORDER BY start_date)
			ELSE NULL
		END AS plan_before_churn
	FROM subscriptions s
	INNER JOIN plans p
		ON s.plan_id = p.plan_id)
SELECT customer_id, plan_id, plan_name, price, start_date,
	CASE
		WHEN plan_before_churn = 'trial' THEN ADDDATE(LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date), INTERVAL 7 DAY)
        WHEN plan_before_churn LIKE '%monthly' THEN 
			ADDDATE(LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date), INTERVAL CEILING(date_diff/31) MONTH)
		WHEN plan_before_churn = 'pro annual' THEN 
			ADDDATE(LAG(start_date) OVER(PARTITION BY customer_id ORDER BY start_date), INTERVAL CEILING(date_diff/365) YEAR)
		ELSE SUBDATE(LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date), INTERVAL 1 DAY)
    END AS end_date
FROM cte;
SELECT * FROM subscription_temp;

    -- filter needed customer_id
SELECT customer_id, plan_name, start_date, end_date
FROM subscriptions_temp
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19); 

-- B. Data Analysis Questions --
-- 1. How many customers has Foodie-Fi ever had?
SELECT 
    COUNT(DISTINCT customer_id) AS total_customer
FROM
    subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT 
    MONTHNAME(start_date) AS month, COUNT(*) AS total_trial
FROM
    subscriptions
WHERE
    plan_id = 0
GROUP BY month
ORDER BY MONTH(start_date);

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT 
    plan_name, COUNT(*) AS total_plan
FROM
    subscriptions s
        INNER JOIN
    plans p ON s.plan_id = p.plan_id
WHERE
    YEAR(start_date) > 2020
GROUP BY s.plan_id;

-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT 
    COUNT(DISTINCT customer_id) AS churned_customer,
    ROUND(COUNT(DISTINCT customer_id) / 
			(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 1) AS churned_customer_percentage
FROM
    subscriptions
WHERE
    plan_id = 4;

-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH cte AS(
	SELECT *,
		LAG(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS previous_plan_id
	FROM subscriptions)
SELECT
	COUNT(*) AS churned_after_trial_count,
	ROUND(COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 0) AS churned_after_trial_percentage
FROM cte
WHERE plan_id = 4 AND previous_plan_id = 0;

-- 6. What is the number and percentage of customer plans after their initial free trial?
WITH cte AS(
	SELECT 
		customer_id, 
        plan_name,
		LAG(s.plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS previous_plan_id
    FROM subscriptions s
	INNER JOIN plans p 
		ON s.plan_id = p.plan_id)
SELECT
	plan_name,
	COUNT(*) AS after_trial_count,
	ROUND(COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100, 2) AS after_trial_percentage
FROM cte
WHERE previous_plan_id = 0
GROUP BY plan_name;

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
	-- we will use the temporary table we create at part A
SELECT
	plan_name,
    COUNT(*) AS total_customer,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER() * 100, 2) AS percentage
FROM subscriptions_temp
WHERE start_date <= '2020-12-31'
	AND (end_date >= '2020-12-31' OR end_date IS NULL)
GROUP BY plan_id;

-- 8. How many customers have upgraded to an annual plan in 2020?
SELECT COUNT(DISTINCT customer_id) AS total_customer
FROM subscriptions
WHERE plan_id = 3 AND YEAR(start_date) = '2020';

-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi
WITH trial AS(
	SELECT *
    FROM subscriptions
    WHERE plan_id = 0),
annual AS(
	SELECT *
    FROM subscriptions
    WHERE plan_id = 3)
SELECT ROUND(AVG(DATEDIFF(a.start_date, t.start_date)), 2) AS avg_trial_to_annual
FROM trial t
INNER JOIN annual a
	ON t.customer_id = a.customer_id;

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH trial AS(
	SELECT *
    FROM subscriptions
    WHERE plan_id = 0),
annual AS(
	SELECT *
    FROM subscriptions
    WHERE plan_id = 3),
cte AS(
	SELECT 
		DATEDIFF(a.start_date, t.start_date) AS date_diff,
		FLOOR(DATEDIFF(a.start_date, t.start_date)/30) AS cat
	FROM trial t
	INNER JOIN annual a
		ON t.customer_id = a.customer_id)
SELECT 
	CASE
		WHEN cat = 0 THEN '0-30 days'
        ELSE CONCAT(cat*30 + 1, '-', (cat+1) * 30, ' days')
	END AS period,
	COUNT(*) AS total_customer,
    ROUND(AVG(date_diff), 2) AS avg_trial_to_annual
FROM cte
GROUP BY cat
ORDER BY cat;

-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH cte AS(
	SELECT *,
		LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_plan_id
	FROM subscriptions)
SELECT COUNT(*) AS pro_to_basic
FROM cte
WHERE YEAR(start_date) = '2020' AND plan_id = 2 AND next_plan_id = 1;

-- C. Challenge Payment Question --
-- The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:
	-- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
	-- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
	-- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
	-- once a customer churns they will no longer make payments

	-- first we create a temporary table to store only entries in 2020 and create last_date column to cut off in '2020-12-31' 
DROP TABLE IF EXISTS subscriptions_temp_2020;
CREATE TEMPORARY TABLE subscriptions_temp_2020
SELECT 
	customer_id,
    plan_id,
    plan_name,
    price,
    start_date,
    CASE
		WHEN end_date IS NULL OR end_date > '2020-12-31' THEN '2020-12-31'
        ELSE end_date
    END AS last_date
 FROM subscriptions_temp
 WHERE plan_id IN (1, 2, 3) AND start_date <= '2020-12-31';

	-- create 2020 payments table using recursive cte to generate all payment date based on plan type and last_date
	-- calculate paid amount with note that case upgrade from basic to pro monthly/annual will start immediately and amount will reduced by the current paid amount in that month
DROP TABLE IF EXISTS payments;
CREATE TEMPORARY TABLE payments
WITH RECURSIVE cte(customer_id, plan_id, plan_name, price, payment_date, last_date) AS(
	SELECT
		customer_id,
		plan_id,
		plan_name,
		price,
		start_date,
        last_date
	FROM subscriptions_temp_2020
    UNION ALL
    SELECT
		customer_id,
		plan_id,
		plan_name,
		price,
		CASE
			WHEN plan_id IN (1, 2) THEN ADDDATE(payment_date, INTERVAL 1 MONTH)
            ELSE ADDDATE(payment_date, INTERVAL 1 YEAR)
		END,
        last_date
	FROM cte WHERE 
		(CASE
			WHEN plan_id IN (1, 2) THEN ADDDATE(payment_date, INTERVAL 1 MONTH)
            ELSE ADDDATE(payment_date, INTERVAL 1 YEAR)
		END) < last_date
    )
SELECT customer_id, plan_id, plan_name, payment_date,
	CASE
		WHEN payment_date < ADDDATE(LAG(payment_date) OVER(PARTITION BY customer_id ORDER BY payment_date), INTERVAL 1 MONTH) THEN price - 9.90
        ELSE price
    END AS amount,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
FROM cte;

	-- check customer_id in example outputs to compare result
SELECT * FROM payments
WHERE customer_id IN (1, 2, 13, 15, 16, 18, 19);

	-- check customer update from basic to pro monthly/annual
SELECT * FROM payments
WHERE customer_id IN (SELECT DISTINCT customer_id FROM payments WHERE amount NOT IN (9.90, 19.90, 199.00));
